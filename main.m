//
//  main.m
//  pdfimages
//
//  Created by Sven Thoennissen on 16.11.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "DnDView.h"
int c_main(int argc, char *argv[]);


int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
        
    NSString *argIn     = [args stringForKey:@"in"];
    NSString *argOut    = [args stringForKey:@"out"];

    if(argIn || argOut)
    {
//        NSLog(@"in = %@", argIn);
//        NSLog(@"out = %@", argOut);       
              
        NSString *dir = [argIn stringByDeletingLastPathComponent];
        [[NSFileManager defaultManager] changeCurrentDirectoryPath:dir];
        
        char buffer[1024];
        strlcpy(buffer, [[argIn lastPathComponent] fileSystemRepresentation], sizeof(buffer));
        
        char prefix[1024];
        strlcpy(prefix, [[[argIn lastPathComponent] stringByDeletingPathExtension] fileSystemRepresentation], sizeof(prefix));
        
        char *argv[] = { "pdfimages", "-j", "-q", buffer, prefix };
        c_main(sizeof(argv) / sizeof(char *), argv);
        
    }
    else
    {
        [pool release];
        return NSApplicationMain(argc,  (const char **) argv);
    }
    
    [pool release];
    return 0;
    
}
