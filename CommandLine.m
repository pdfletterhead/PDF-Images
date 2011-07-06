#import "CommandLine.h" //See the header file for comments

@interface CommandLine (NonPublicMethods)

- (NSString *) cL_createCommandLineString: (int)argc andArgv: (char *[])argv;
- (BOOL) cL_parseOptionsAtOffset: (int)optionBegin endExclusive: (int)switchEnd;
- (void) cL_parseParameter: (int)optionBegin endExclusive: (int)switchEnd;
- (BOOL) cL_parsePostFlight;
- (void) cL_resultSet: (BOOL)success message: (NSString *)message;
- (void) cL_resultReset;

@end

@implementation CommandLine

- (CommandLine *)init {
    self = [super init];
    parsedCommandLine = [NSMutableDictionary dictionaryWithCapacity: CL_MAXOPTIONS];
    [self cL_resultReset];
    parameterCount = 0;
    return self;
}

- (CommandLine *)initWithCommandLine: (NSString *)commandLineString {
    self = [self init];
    self.commandLine = commandLineString;
    
    return self;
}

- (CommandLine *)initWithArgc: (int)argc andArgv: (char *[])argv {
    self = [self init];
    self.commandLine = [self cL_createCommandLineString: argc andArgv: argv];
    return self;
}

- (void)cL_setOptionsMatrix: (NSDictionary *)matrix andMinNumberOfParams: (int) numberOfParams {
    minNumberOfParams = numberOfParams;
    self.optionsMatrix = matrix; 
}

- (BOOL) cL_parse {
    BOOL parseSuccess = YES;
    char clChar;
    int clPointer = 0;
    int optionBegin = 0;
    int parameterBegin = 0;
    int state = CL_STATE_WHITE;

    commandLine = [NSString stringWithFormat: @"%@ ", commandLine];
    commandLineStr = commandLine;
    
    int clLength = [commandLine length];
    
    //NSLog(@"ParameterCount %d",clLength);
    //NSLog(@"ParameterCount %@",commandLine);
    
    while ((clPointer < clLength) && parseSuccess) {
        clChar = [commandLine characterAtIndex: clPointer];
        switch (clChar) {
            case CL_BEGIN_OPTION:
                if (state == CL_STATE_OPTION) {
                    [self cL_resultSet: FALSE message: [NSString stringWithFormat: @"%@ %c", CL_ERRORMESSAGE_SYNTAX_ERROR, clChar]];
                    parseSuccess = NO;
                }
                if (state == CL_STATE_WHITE) {
                    state = CL_STATE_OPTION;
                    clPointer++;
                    optionBegin = clPointer;
                }
                break;
            case CL_SPACE:
            case CL_T:
            case CL_N:
                if (state == CL_STATE_OPTION) {
                    parseSuccess = [self cL_parseOptionsAtOffset: optionBegin endExclusive: clPointer];
                }
                if (state == CL_STATE_PARAMETER) {
                    [self cL_parseParameter: parameterBegin endExclusive: clPointer];
                }
                state = CL_STATE_WHITE;
                clPointer++;
                break;
            default:
                if (state == CL_STATE_WHITE) {
                    state = CL_STATE_PARAMETER;
                    parameterBegin = clPointer;
                }
                clPointer++;
        }
    }
    if (parseSuccess && (parameterCount < minNumberOfParams)) {
        [self cL_resultSet: FALSE message: CL_ERRORMESSAGE_PARAMS_MISSING];
        parseSuccess = NO;
    }
    if (parseSuccess) {
        parseSuccess = [self cL_parsePostFlight];
    }
    return parseSuccess;
}

- (BOOL) cL_optionIsSet: (NSString *) option {
    BOOL returnValue = NO;
    
    for (NSString *key in self.parsedCommandLine) {
        if (![key compare: option]) {
            returnValue = YES;
            break;
        }
    }
    return returnValue;
}

- (NSString *) cL_optionGetValue: (NSString *) option {
    NSString *returnValue;
    for (NSString *key in self.parsedCommandLine) {
        if (![key compare: option]) {
            returnValue = [self.parsedCommandLine valueForKey: key];
            break;
        }
    }
    return returnValue;
}

- (NSString *) cL_parameterGetValue: (int) parameter {
    NSString *parameterString = [NSString stringWithFormat: @"%d", parameter];
    return [self cL_optionGetValue: parameterString];
}

@synthesize optionsMatrix;
@synthesize commandLine;
@synthesize commandLineStr;
@synthesize parsedCommandLine;
@synthesize lastParsedOption;
@synthesize resultSuccess;
@synthesize resultText;

@end

@implementation CommandLine (NonPublicMethods)

- (NSString *)cL_createCommandLineString: (int) argc andArgv: (char *[]) argv {
    NSString *commandLineString = nil;
    int i = 0;

    while (i < argc) {
        if (i == 1) {
            commandLineString = [NSString stringWithFormat: @"%s", argv[1]];
        } else if (i > 0) {
            commandLineString = [NSString stringWithFormat: @"%@ %s", commandLineString, argv[i]];
        }
        i++;
    }
    return commandLineString;
}

- (void) cL_parseParameter: (int) optionBegin endExclusive: (int) switchEnd {
    NSRange range = {optionBegin, switchEnd - optionBegin};
    NSString *parameter = [self.commandLine substringWithRange: range];
    BOOL found = NO;
    
    if (lastParsedOption) {
        for (NSString *key in optionsMatrix) {
            if (![[key description]compare: lastParsedOption] &&
                (![(NSString *)[optionsMatrix valueForKey:key]compare: CL_OPTION_REQUIRED_WITH_VALUE]
                 || ![(NSString *)[optionsMatrix valueForKey:key]compare: CL_OPTION_OPTIONAL_WITH_VALUE]
                 )) {
                [parsedCommandLine setObject: parameter forKey: lastParsedOption];
                self.lastParsedOption = nil;
                found = YES;
            }
        }
    }
    if (!found) {
        NSString *parameterKey = [NSString stringWithFormat: @"%d", ++parameterCount];
        [parsedCommandLine setObject: parameter forKey: parameterKey];
    }
}

- (BOOL) cL_parseOptionsAtOffset: (int) optionBegin endExclusive: (int) switchEnd {
    int clPointer = optionBegin;
    char clChar = 0;
    BOOL found = NO;
    NSString *parsedValue;
    
    if (switchEnd <= clPointer) {
        [self cL_resultSet: FALSE message: CL_ERRORMESSAGE_SYNTAX_ERROR];
    } else {
        while (clPointer < switchEnd) {
            found = NO;
            clChar = [commandLine characterAtIndex: clPointer];
            NSString *switchString = [NSString stringWithFormat: @"%c", clChar];
            for (NSString *key in optionsMatrix) {
                if (![[key description]compare: switchString]) {
                    self.lastParsedOption = switchString;
                    found = YES;
                    if (![(NSString *)[optionsMatrix valueForKey: key] compare: CL_OPTION_REQUIRED_WITH_VALUE]
                        || ![(NSString *)[optionsMatrix valueForKey: key] compare: CL_OPTION_OPTIONAL_WITH_VALUE]
                        ) {
                        parsedValue = CL_OPTION_VALUE_EXPECTED;
                    } else { 
                        parsedValue = CL_OPTION_VALUE_FOUND;
                    }
                }
            }
            if (!found) {
                if (!clChar) {
                    [self cL_resultSet: FALSE message: CL_ERRORMESSAGE_SYNTAX_ERROR];
                } else {
                    [self cL_resultSet: FALSE message: [NSString stringWithFormat: @"%@ %@", CL_ERRORMESSAGE_UNKNOWN_OPTION, switchString]];
                }
                break;
            } else {
                [parsedCommandLine setObject: parsedValue forKey: switchString];
            }
            clPointer++;
        }
    }
    return found;
}

- (BOOL) cL_parsePostFlight {
    BOOL parseSuccess = YES;
    BOOL found;
    NSString *optionValue, *optionType;
    
    for (NSString *keyInMatrix in self.optionsMatrix) {
        optionType = [self.optionsMatrix valueForKey: keyInMatrix];
        found = NO;
        for (NSString *keyInCommandLine in self.parsedCommandLine) {
            if (![keyInMatrix compare: keyInCommandLine]) {
                found = YES;
                optionValue = [self.parsedCommandLine valueForKey: keyInCommandLine];
                
                if (
                    (![optionType compare: CL_OPTION_REQUIRED_WITH_VALUE]
                     ||   ![optionType compare: CL_OPTION_OPTIONAL_WITH_VALUE])
                    &&  ![optionValue compare: CL_OPTION_VALUE_EXPECTED]
                    ) {
                    parseSuccess = NO;
                    [self cL_resultSet: parseSuccess message: [NSString stringWithFormat: @"%@ %@", CL_ERRORMESSAGE_MISSING_VALUE, keyInCommandLine]];
                    break;
                }
            }
        }
        if (!found
        &&  (![optionType compare: CL_OPTION_REQUIRED_WITH_VALUE] || ![optionType compare: CL_OPTION_REQUIRED])
        ) {
            parseSuccess = NO;
            [self cL_resultSet: parseSuccess message: [NSString stringWithFormat: @"%@ %@", CL_ERRORMESSAGE_OPTION_NOT_FOUND, keyInMatrix]];
        }
    }
    return parseSuccess;
}

- (void) cL_resultReset {
    self.resultSuccess = YES;
    self.resultText = nil;
    
}

- (void) cL_resultSet: (BOOL) success message: (NSString *) message {
    self.resultText = message;
    self.resultSuccess = success;
}

@end
