/*
 
 File: MyDocument_Pasteboard.m
 
 Abstract: This category reads and writes data from the pasteboard to support copy/paste and dragging.
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Computer, Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
  "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Computer,
 Inc. may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright � 2005-2006 Apple Computer, Inc., All Rights Reserved
 
 */ 

#import "MyDocument_Pasteboard.h"
#import "MecabNode.h"

@implementation MyDocument(Pasteboard)

#pragma mark /* Formatting method in support of writing to the pasteboard */

- (NSString *)stringFromNodes:(NSArray *)nodes {
    // When we are writing out NSStringPboardType, we create a string with one line per transaction and tabs between items in the transaction
    NSMutableString *result = [NSMutableString string];
    
    for (MecabNode *node in nodes) {
        [result appendFormat:@"%@\n", [node tabbedDescriptionString]];
    }
    return result;
}

#pragma mark /* Methods for writing to the pasteboard */

- (NSArray *)writablePasteboardTypes {
    return [NSArray arrayWithObjects:NSStringPboardType, nil];
}

- (BOOL)writeSelectionToPasteboard:(NSPasteboard *)pboard types:(NSArray *)types {
    BOOL result = NO;
    NSMutableArray *typesToDeclare = [NSMutableArray array];
    NSArray *writableTypes = [self writablePasteboardTypes];
    NSString *type;
    
    for (type in writableTypes) {
        if ([types containsObject:type]) [typesToDeclare addObject:type];
    }
    if ([typesToDeclare count] > 0) {
        [pboard declareTypes:typesToDeclare owner:self];
        for (type in typesToDeclare) {
            if ([self writeSelectionToPasteboard:pboard type:type]) result = YES;
        }
    }
    return result;
}
    
- (BOOL)writeSelectionToPasteboard:(NSPasteboard *)pboard type:(NSString *)type {
    BOOL result = NO;
    NSArray *nodes = [tokenizationController selectedObjects];
    if (nodes && [nodes count] > 0) {
        if ([type isEqualToString:NSStringPboardType]) {
            NSString *string = [self stringFromNodes:nodes];
            if (string && [string length] > 0) result = [pboard setString:string forType:NSStringPboardType];
        }
    }
    return result;
}

- (void)copy:(id)sender {
    [self writeSelectionToPasteboard:[NSPasteboard generalPasteboard] types:[self writablePasteboardTypes]];
}



#pragma mark /* Methods for reading from the pasteboard */

- (BOOL)addSourceFromString:(NSString*)string
{
	BOOL result = NO;
    NSUInteger length = [string length], location = 0;
    NSRange lineRange;
	NSMutableString *strings = [[[NSMutableString alloc] init] autorelease];

	while (location < length) {
		lineRange = [string lineRangeForRange:NSMakeRange(location, 1)];
		[strings appendString:[string substringWithRange:lineRange]];
		location = NSMaxRange(lineRange);
		result = YES;
	}
	
	if (result) {
		[source setStringValue:strings];
		[self tokenize:self];
	}
	
	return result;
}

- (NSArray *)readablePasteboardTypes {
    return [NSArray arrayWithObjects:NSStringPboardType, nil];
}

- (BOOL)readSelectionFromPasteboard:(NSPasteboard *)pboard {
    // We go through the available types in our preferred order, and return after the first one that succeeds
    BOOL result = NO;
    NSArray *availableTypes = [pboard types], *readableTypes = [self readablePasteboardTypes];
    NSEnumerator *enumerator = [readableTypes objectEnumerator];
    NSString *type;
    
    while (!result && (type = [enumerator nextObject])) {
        if ([availableTypes containsObject:type]) {
            result = [self readSelectionFromPasteboard:pboard type:type];
        }
    }
    return result;
}

- (BOOL)readSelectionFromPasteboard:(NSPasteboard *)pboard type:(NSString *)type {
    BOOL result = NO;
	if ([type isEqualToString:NSStringPboardType]) {
        NSString *string = [pboard stringForType:NSStringPboardType];
        if (string && [string length] > 0) result = [self addSourceFromString:string];
    }
    return result;}

- (void)paste:(id)sender {
    [self readSelectionFromPasteboard:[NSPasteboard generalPasteboard]];
}

#pragma mark /* Method for enabling services use */

- (id)validRequestorForSendType:(NSString *)sendType returnType:(NSString *)returnType {
    if ((!sendType || [[self writablePasteboardTypes] containsObject:sendType]) && (!returnType || [[self readablePasteboardTypes] containsObject:returnType]) && (!sendType || [[tokenizationController selectedObjects] count] > 0)) return self;
    // We are not actually a subclass of NSResponder; if we were, we would pass this on to super.
    // In this particular application, we know that no responder above the document level handles copy/paste; if there were one, we would pass this on to it.
    return nil;
}


#pragma mark /* Methods for providing services */

+ (void)tokenize:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error {
    // -[NSWindowController currentDocument] works only when app is active, so we use this alternative means of finding the front document
	// [NSApp activateIgnoringOtherApps:YES];
	// [NSApp activateWithOptions:NSApplicationActivateAllWindows];
	NSWindowController *windowController = [[NSApp makeWindowsPerform:@selector(windowController) inOrder:YES] windowController];
	// NSDocumentController *documentController = [NSDocumentController sharedDocumentController];
	// [documentController newDocument:self];
	// [windowController showWindow:self];
	[[windowController window] orderFront:self];
	
	MyDocument *document = [windowController document];
	// MyDocument *document = [documentController currentDocument];
    if (document) {
		// [document showWindows];
		[document readSelectionFromPasteboard:pboard];	
	}
}

+ (void)exportData:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error {
	NSWindowController *windowController = [[NSApp makeWindowsPerform:@selector(windowController) inOrder:YES] windowController];
    MyDocument *document = [windowController document];
    if (document) [document writeSelectionToPasteboard:pboard types:[document writablePasteboardTypes]];
}

@end
