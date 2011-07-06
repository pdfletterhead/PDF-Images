//
//  cliWrapper.h
//  pdfimages
//
//  Created by Pim Snel on 05-07-11.
//  Copyright 2011 Lingewoud B.V. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface cliWrapper : NSObject {
@private
    
}

-(void)cw_printUsage;


-(void)cw_runPdfimages: (NSString *) argIn :(BOOL) useJpeg;


@end
