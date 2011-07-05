//
//  AppController.h
//  pdfimages
//
//  Created by Sven Thoennissen on 16.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DnDView.h"

@interface PdfImagesAppController : NSDocumentController
{
	IBOutlet DnDView *dndView;
	IBOutlet NSProgressIndicator *progress;
}
@end
