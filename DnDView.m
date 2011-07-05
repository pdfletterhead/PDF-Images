//
//  DnDTextField.m
//
//  Created by Sven Thoennissen on 17.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DnDView.h"

int c_main(int argc, char *argv[]);

/*
@implementation WorkerThread

- (void)main
{
//	NSLog(@"worker thread %p starting", self);

	NSRunLoop *runloop = [NSRunLoop currentRunLoop];

	while (![self isCancelled]) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		[runloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
//		NSLog(@"iteration thread %p seq %d", self, count++);
		[pool drain];
	}

//	NSLog(@"worker thread %p ending, cancelled %d", self, [self isCancelled]);
}

@end
*/

@implementation DnDView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect])) {
		highlighted = NO;
//		NSLog(@"dndview init");
	}
	return self;
}

/*- (void)dealloc
{
//	[self cleanup];
	[super dealloc];
}

- (void)cleanup
{
//	NSLog(@"dndview cleanup");
	if (thread) {
		while (![thread isFinished]) {
			[thread cancel];
			[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
		}
		[thread release];
		thread = nil;
	}
}
*/
- (void)drawRect:(NSRect)dirtyRect
{
	if (highlighted) {
		[[NSColor colorWithDeviceWhite:1.0 alpha:0.6] set];
		NSRectFill(dirtyRect);
	}
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];
 
/*    if ( [[pboard types] containsObject:NSColorPboardType] ) {
        if (sourceDragMask & NSDragOperationGeneric) {
            return NSDragOperationGeneric;
        }
    }*/
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {

		NSArray *classes = [[NSArray alloc] initWithObjects:[NSURL class], [NSAttributedString class], [NSString class], nil];
		NSDictionary *options = [NSDictionary dictionary];
		NSArray *copiedItems = [pboard readObjectsForClasses:classes options:options];
		if (copiedItems == nil)
			return NSDragOperationNone;

		int pdfcount = 0;
		for (id item in copiedItems) {
			NSString *file = [item description];
			if ([item isKindOfClass:[NSURL class]])
				file = [item path];
			//NSLog(@"checking file %@", file);
			if ([[[file lowercaseString] pathExtension] isEqualToString:@"pdf"])
					pdfcount++;
		}
		if (pdfcount == 0)
			return NSDragOperationNone;

        if (sourceDragMask & NSDragOperationLink) {
			//NSLog(@"dnd link");
			[self highlight];
            return NSDragOperationLink;
        } else if (sourceDragMask & NSDragOperationCopy) {
			NSLog(@"dnd copy");
            return NSDragOperationCopy;
        }
    }
	NSLog(@"dnd none");
    return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	[self unhighlight];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];

	[self unhighlight];
 
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		for (NSString *file in files) {
			NSLog(@"dnd file %@", file);
			if ([[[file lowercaseString] pathExtension] isEqualToString:@"pdf"]) {
				[self workFile:file];
			}
		}
    }
    return YES;
}

- (void)workFile:(NSString *)file
{
	[[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:file]];

/*	if (!thread) {
		thread = [[WorkerThread alloc] init];
		[thread start];
	}
*/
//	NSLog(@"workFile thread %p", [NSThread currentThread]);

//	[self performSelector:@selector(work:) onThread:thread withObject:file waitUntilDone:NO];
/*	[self work:file];
}

- (void)work:(NSString *)file
{
*/
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

//	[progress performSelectorOnMainThread:@selector(startAnimation:) withObject:self waitUntilDone:NO];
//	[currentFile performSelectorOnMainThread:@selector(setStringValue:) withObject:file waitUntilDone:NO];
	[progress startAnimation:self];
	[currentFile setStringValue:file];
	[[NSRunLoop mainRunLoop] runUntilDate:[NSDate date]]; // let the currentFile label refresh itself

//	NSLog(@"work thread %p, on file %@", [NSThread currentThread], file);

	NSString *dir = [file stringByDeletingLastPathComponent];
	[[NSFileManager defaultManager] changeCurrentDirectoryPath:dir];

	char buffer[1024];
	strlcpy(buffer, [[file lastPathComponent] fileSystemRepresentation], sizeof(buffer));

	char prefix[1024];
	strlcpy(prefix, [[[file lastPathComponent] stringByDeletingPathExtension] fileSystemRepresentation], sizeof(prefix));

	char *argv[] = { "pdfimages", "-j", "-q", buffer, prefix };
	c_main(sizeof(argv) / sizeof(char *), argv);

//	[progress performSelectorOnMainThread:@selector(stopAnimation:) withObject:self waitUntilDone:NO];
//	[currentFile performSelectorOnMainThread:@selector(setStringValue:) withObject:@"" waitUntilDone:NO];
	[progress stopAnimation:self];
	[currentFile setStringValue:@""];

//	[pool drain];
}

- (void)highlight
{
	highlighted = YES;
	[self setNeedsDisplay:YES];
}

- (void)unhighlight
{
	highlighted = NO;
	[self setNeedsDisplay:YES];
}

@end
