//
//  DnDTextField.h
//
//  Created by Sven Thoennissen on 17.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
@interface WorkerThread : NSThread
{
}
@end
*/

@interface DnDView : NSView
{
	IBOutlet NSProgressIndicator *progress;
	IBOutlet NSTextField *currentFile;
	//WorkerThread *thread;
	BOOL highlighted;
}
- (void)highlight;
- (void)unhighlight;
- (void)workFile:(NSString *)file;
//- (void)work:(NSString *)file;
//- (void)cleanup;
@end
