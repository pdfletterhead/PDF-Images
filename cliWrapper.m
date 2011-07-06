//
//  cliWrapper.m
//  pdfimages
//
//  Created by Pim Snel on 05-07-11.
//  Copyright 2011 Lingewoud B.V. All rights reserved.
//

#import "cliWrapper.h"

int c_main(int argc, char *argv[]);


@implementation cliWrapper

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

-(void)cw_printUsage
{
    printf("PDF-Images for Cocoa with cli\n");
    printf("Usage: pdfimages [options]\n");
    printf("\n");
    printf("Without options the drag'n'drop GUI is started.\n");
    printf("\n");
    printf("  -h             : print usage information\n");
    printf("  -i <filePath>  : path to PDF to use as input\n");
    printf("  -j             : write JPEG images as JPEG files\n");
    printf("\n"); 
}

-(void)cw_runPdfimages: (NSString *) argIn :(BOOL) useJpeg  {
         
         NSLog(@"run cli version with file: %@", argIn);
         
         NSString *dir = [argIn stringByDeletingLastPathComponent];
         [[NSFileManager defaultManager] changeCurrentDirectoryPath:dir];
         
         char buffer[1024];
         strlcpy(buffer, [[argIn lastPathComponent] fileSystemRepresentation], sizeof(buffer));
         
         char prefix[1024];
         strlcpy(prefix, [[[argIn lastPathComponent] stringByDeletingPathExtension] fileSystemRepresentation], sizeof(prefix));
         
         if (useJpeg) 
         {
             char *argv[] = { "pdfimages", "-q","-j", buffer, prefix };
             c_main(sizeof(argv) / sizeof(char *), argv);
         }
         else
         {
             char *argv[] = { "pdfimages", "-q", buffer, prefix };                
             c_main(sizeof(argv) / sizeof(char *), argv);
         }
}

@end
