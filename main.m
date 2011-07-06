//
//  main.m
//  pdfimages
//
//  Created by Sven Thoennissen on 16.11.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CommandLine.h"
#import "cliWrapper.h"

//#import "DnDView.h"
//int c_main(int argc, char *argv[]);

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    BOOL parseSuccess;

    CommandLine *commandLine = [[CommandLine alloc] initWithArgc: argc andArgv: argv];
    
    // This sample expects at least one parameter (other that options)
    int MinNumberOfParams = 0;
    
    // Define the matrix describing expected options
    NSDictionary *sampleOptionsMatrix =
    [NSDictionary dictionaryWithObjectsAndKeys:
     CL_OPTION_OPTIONAL, @"h",              
     CL_OPTION_OPTIONAL, @"p",              
     CL_OPTION_OPTIONAL, @"j",              
     CL_OPTION_OPTIONAL_WITH_VALUE, @"i",
     nil];
    
    // Pass on required parameters to the parser and execute the parser
    [commandLine cL_setOptionsMatrix: sampleOptionsMatrix andMinNumberOfParams: MinNumberOfParams];
    parseSuccess = [commandLine cL_parse];
    
    if(([commandLine cL_optionIsSet: @"p"]) || ([[commandLine parsedCommandLine] count] == 1  && [commandLine cL_optionIsSet: @"1"]))
    {
        [pool release];
        [commandLine release];
        return NSApplicationMain(argc,  (const char **) argv);
    }
    else
    {
        cliWrapper *cli = [cliWrapper alloc];

        if (parseSuccess) {

            if ([commandLine cL_optionIsSet: @"h"]) {
                
                [cli cw_printUsage];
            }
            else if ([commandLine cL_optionIsSet: @"i"]) {
              
                [cli cw_runPdfimages: [commandLine cL_optionGetValue : @"i"] : [commandLine cL_optionIsSet: @"j"]];
            }
            else
            {
                [cli cw_printUsage];
            }
            
            [cli release];
        } else {
            //Display the error message
            NSLog(@"%@",commandLine.resultText);
            [cli cw_printUsage];
            return 1;
        }
    
        [pool release];
        [commandLine release];
        
        return 0;
    }
}





