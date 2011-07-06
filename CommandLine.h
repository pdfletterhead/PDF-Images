/*
 CommandLine
 
 Validate and parse a command line
 
 Usage:
 
 1) Send message "setOptionsMatrix" with definition of expected options
 2) Send message "parse" to process the command line parameters
 3) When parse successful, query the options, option values and parameters
 
 Sample: CommandLineParser.m (enclosed)
 
 Written by Ivo Kendra, 2009. This is a free software, use at your own risk.
 */

#import <Foundation/Foundation.h>

#define CL_OPTION_REQUIRED                  @"RQD"
#define CL_OPTION_OPTIONAL                  @"OPT"
#define CL_OPTION_REQUIRED_WITH_VALUE       @"RQDV"
#define CL_OPTION_OPTIONAL_WITH_VALUE       @"OPTV"
#define CL_OPTION_VALUE_EXPECTED            @"VALUE_EXPECTED"
#define CL_OPTION_VALUE_FOUND               @"FOUND"

#define CL_MAXOPTIONS                       128

#define CL_ERRORMESSAGE_OK                  @"Success"
#define CL_ERRORMESSAGE_SYNTAX_ERROR        @"Syntax error near:"
#define CL_ERRORMESSAGE_UNKNOWN_OPTION      @"Unknown option:"
#define CL_ERRORMESSAGE_PARAMS_MISSING      @"Missing required parameters"
#define CL_ERRORMESSAGE_MISSING_VALUE       @"Missing value for option:"
#define CL_ERRORMESSAGE_OPTION_NOT_FOUND    @"Required option not found:"

#define CL_BEGIN_OPTION                     '-'
#define CL_SPACE                            ' '
#define CL_T                                '\t'
#define CL_N                                '\n'

#define CL_STATE_OPTION                     1
#define CL_STATE_PARAMETER                  2
#define CL_STATE_WHITE                      3

@interface CommandLine : NSObject {
@private
    int minNumberOfParams;
    int parameterCount;
    
    NSDictionary *optionsMatrix;
    NSString *commandLine;
    NSMutableDictionary *parsedCommandLine;
    NSString *lastParsedOption;
    
    NSString *commandLineStr;

    
    BOOL resultSuccess;
    NSString *resultText;
}

/*
 Default constructor
 */
- (CommandLine *) init;

/*
 Initialize the CommandLine class with already prepared command line string
 */
- (CommandLine *) initWithCommandLine: (NSString *) commandLineString;

/*
 Initialize the CommandLine class simply by passing the argc and argv parameters
 */
- (CommandLine *) initWithArgc: (int) argc andArgv: (char *[]) argv;

- (void) cL_setOptionsMatrix: (NSDictionary *) matrix andMinNumberOfParams: (NSInteger) numberOfParams;

/*
 Parse the command line.
 
 Returns value:
 
 YES if parsing was successful. You can enumerate the parsedCommandLine dictionary for 
 the list of parsed values, or use cL_option* and cL_parameter methods to retrieve particular options
 or parameters
 
 NO if error occured. Get resultText for detailed error message
 */
- (BOOL) cL_parse;

/*
 Returns YES is option is set
 */
- (BOOL) cL_optionIsSet: (NSString *) option;

/*
 Return the value of the option (if found)
 */
- (NSString *) cL_optionGetValue: (NSString *) option;

/*
 Return the value of the parameter (if found)
 */
- (NSString *) cL_parameterGetValue: (int) parameter;



@property(readwrite, copy) NSDictionary *optionsMatrix;
@property(readwrite, copy) NSString *commandLine;
@property(readonly, copy) NSString *commandLineStr;
@property(readonly) NSMutableDictionary *parsedCommandLine;
@property(readwrite, copy) NSString *lastParsedOption;
@property(readwrite) BOOL resultSuccess;
@property(readwrite, copy) NSString *resultText;

@end


