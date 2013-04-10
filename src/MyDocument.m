//
//  MyDocument.m
//  MeCabChan
//
//  Created by Markus Ackermann on 27.10.10.
//  Copyright 2010 kaixo.de. All rights reserved.
//

#import "MyDocument.h"
#import "MyDocument_Pasteboard.h"

@implementation MyDocument
@synthesize mecabNodes;

- (id)init
{
	static BOOL registeredServices = NO;
    static int nextDocumentNumber = 0;
    self = [super init];
    if (self) {    
		sourceTextHistory = [[NSMutableArray alloc] initWithCapacity:16];
	    [sourceTextHistory addObject:@""];
		currentPositionInHistory = 0;
		mecabNodes = [[NSArray alloc] init];
		mecab = [[MecabTagger alloc] init];
        tagMap = [[MecabTagMap alloc] initFrom:@"chasen-tags.txt"];
        inflectionMap = [[MecabTagMap alloc] initFrom:@"ipadic-verb-inflections.txt"];
        translatePosTags = FALSE;
        
        number = nextDocumentNumber++;
        
        // preset landscape for printing
        NSPrintInfo *printInfo = [self printInfo];
        [printInfo setOrientation:NSLandscapeOrientation];
        [self setPrintInfo:printInfo];
                        
        // register service
        if (!registeredServices) {
            // register as service provider
            [NSApp setServicesProvider:[self class]];
            // register as service consumer
			[NSApp registerServicesMenuSendTypes:[self writablePasteboardTypes] returnTypes:[self readablePasteboardTypes]];
            registeredServices = YES;
        }
    }
    return self;	
}

#pragma mark *** Actions ***

-(IBAction)clearSource:(id)sender
{
	[source setStringValue:@""];
}

-(IBAction)tokenize:(id)sender
{
	NSString* sentence = [source stringValue];
	if ([sentence length] > 0) {
		NSArray* nodes = [mecab parseToNodes:sentence
                                  withTagMap:(translatePosTags?tagMap:NULL)
                           withInflectionMap:(translatePosTags?inflectionMap:NULL)];
		[self setMecabNodes:nodes];
		[self updateHistory];
	}
}

- (IBAction)navigateHistory:(id)sender
{
	NSInteger selectedSegment = [historyNavigationControl selectedSegment];
	NSLog(@"History navigation selected segment: %ld", selectedSegment);
	[historyNavigationControl setSelected:NO forSegment:selectedSegment];
	switch (selectedSegment) {
		case 0:
			[self backInHistory];
			break;
		case 1:
			[self forwardInHistory];
			break;
		default:
			break;
	}
}

- (IBAction)translatePosTagsToggle:(id)sender
{
    switch ([translatePosTagsCheckBox state]) {
        case NSOnState:
            translatePosTags = TRUE;
            break;
        case NSOffState:
            translatePosTags = FALSE;
            break;
        default:
            break;
    }
    [self tokenize:self];
}

#pragma mark *** History navigation ***

-(void)updateHistory
{
	NSString* sentence = [source stringValue];
	NSString* currentHistoryString = [sourceTextHistory objectAtIndex:currentPositionInHistory];
	if (currentPositionInHistory == 0 && [currentHistoryString length] == 0) {
		[sourceTextHistory replaceObjectAtIndex:0 withObject:sentence];
	}
	else if (![sentence isEqualToString:currentHistoryString]) {
		if (currentPositionInHistory == [sourceTextHistory count] - 1) {
			[sourceTextHistory addObject:sentence];
			currentPositionInHistory++;
		} else {
			NSInteger nextPosition = currentPositionInHistory+1;
			[sourceTextHistory removeObjectsInRange:NSMakeRange(nextPosition, [sourceTextHistory count]-nextPosition)];
			[sourceTextHistory addObject:sentence];
			currentPositionInHistory++;
		}
	}
	[self updateHistoryButtons];
}

-(void)backInHistory
{
	if (currentPositionInHistory > 0) {
		currentPositionInHistory--;
		[source setStringValue:[sourceTextHistory objectAtIndex:currentPositionInHistory]];
		[self performSelector:[source action] withObject:self];
	}
}

-(void)forwardInHistory
{
	if (currentPositionInHistory < [sourceTextHistory count] - 1) {
		currentPositionInHistory++;
		[source setStringValue:[sourceTextHistory objectAtIndex:currentPositionInHistory]];
		[self performSelector:[source action] withObject:self];
	}	
}

-(void)updateHistoryButtons
{
	[historyNavigationControl setEnabled:(currentPositionInHistory > 0) forSegment:0];
	[historyNavigationControl setEnabled:(currentPositionInHistory < [sourceTextHistory count]-1) forSegment:1];
}

#pragma mark *** Printing ***

- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings error:(NSError **)outError
{
    // Construct the print operation and setup Print panel
    NSPrintOperation *op = [NSPrintOperation
                            printOperationWithView:tokenizationScrollView
                            printInfo:[self printInfo]];
    
    return op;
}

#pragma mark *** Overriding some specific NSDocument methods ***

- (BOOL)isDocumentEdited
{
    return FALSE;
}

- (NSString*) displayName
{
    if (number == 0) {
        return @"MeCabChan";
    } else {
        return [NSString stringWithFormat:@"MeCabChan %ld", number];
    }
}

#pragma mark *** NIB stuff ***

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
	[self updateHistoryButtons];
    
    // install distance constraints
//    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(historyNavigationControl, source, tokenizeButton);
//    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[historyNavigationControl]-[source(>=50)]-[tokenizeButton]-|" 
//                                                                   options:0 
//                                                                   metrics:nil 
//                                                                     views:viewsDict];
//    [mainView addConstraints:constraints];
}

#pragma mark *** Document stuff ***

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}
@end

