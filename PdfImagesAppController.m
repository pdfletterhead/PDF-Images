//
//  AppController.m
//  pdfimages
//
//  Created by Sven Thoennissen on 16.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PdfImagesAppController.h"

extern const char *the_version;
/*
void NotifyApp(int event)
{
	NSLog(@"notify %d, thread %p", event, [NSThread currentThread]);
//	[[NSApplication sharedApplication] updateWindows];
//	[[NSRunLoop mainRunLoop] runUntilDate:[NSDate date]];
//	[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
//	[[NSRunLoop mainRunLoop] acceptInputForMode:NSRunLoopCommonModes beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
//	[[NSRunLoop mainRunLoop] limitDateForMode:NSDefaultRunLoopMode];
//	[[NSRunLoop mainRunLoop] run];
//NSEventTrackingRunLoopMode;
//	PdfImagesAppController *appCon = [NSApplication delegate];
//	[appCon notify:event];
}
*/

@implementation PdfImagesAppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[dndView registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[dndView unregisterDraggedTypes];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	return YES;
}

- (IBAction)openDocument:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setAllowedFileTypes:[NSArray arrayWithObject:@"pdf"]];
	[panel setAllowsMultipleSelection:YES];
	if ([panel runModal] == NSFileHandlingPanelOKButton) {
		for (NSURL *url in [panel URLs]) {
			[dndView workFile:[url path]];
		}
	}
}

- (id)openDocumentWithContentsOfURL:(NSURL *)absoluteURL display:(BOOL)displayDocument error:(NSError **)outError
{
	NSLog(@"openDocumentWithContentsOfURL %@", [absoluteURL path]);
	[dndView workFile:[absoluteURL path]];
	return nil;
}

- (BOOL)presentError:(NSError *)error
{
	// suppress the error message window that happens because we return nil in -[openDocumentWithContentsOfURL].
	return NO;
}

- (void)orderFrontStandardAboutPanel:(id)sender
{
	NSMutableParagraphStyle *ps = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[ps setAlignment:NSCenterTextAlignment];
	NSString *ver = [NSString stringWithCString:the_version encoding:[NSString defaultCStringEncoding]];
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
		ps, NSParagraphStyleAttributeName,
		[NSFont fontWithName:@"Helvetica" size:11], NSFontAttributeName,
		nil];
	NSAttributedString *credits = [[[NSAttributedString alloc] initWithString:ver attributes:attrs] autorelease];

	[[NSApplication sharedApplication] orderFrontStandardAboutPanelWithOptions:[NSDictionary dictionaryWithObjectsAndKeys:
		credits, @"Credits",
		//@"Mac OS X", @"ApplicationVersion",
		nil
	]];
}

@end
