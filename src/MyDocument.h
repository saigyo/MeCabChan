//
//  MyDocument.h
//  MeCabChan
//
//  Created by Markus Ackermann on 27.10.10.
//  Copyright 2010 kaixo.de. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "MecabTagger.h"
#import "MecabTagMap.h"

@interface MyDocument : NSDocument 
{
    IBOutlet NSView *mainView;
    
	IBOutlet NSSegmentedControl *historyNavigationControl;
	IBOutlet NSTextField *source;
	IBOutlet NSTableView *tokenizationView;
	IBOutlet NSArrayController *tokenizationController;
    IBOutlet NSButton *tokenizeButton;
    IBOutlet NSButton *translatePosTagsCheckBox;
	
    IBOutlet NSScrollView *tokenizationScrollView;
    
    NSInteger number;
    
	NSMutableArray *sourceTextHistory;
	NSInteger currentPositionInHistory;
	NSArray *mecabNodes;
	MecabTagger *mecab;
    MecabTagMap *tagMap;
    MecabTagMap *inflectionMap;
    BOOL translatePosTags;
}
@property (readwrite, retain) NSArray *mecabNodes;
- (IBAction)clearSource:(id)sender;
- (IBAction)tokenize:(id)sender;
- (IBAction)navigateHistory:(id)sender;
- (IBAction)translatePosTagsToggle:(id)sender;

-(void)updateHistory;
-(void)backInHistory;
-(void)forwardInHistory;
-(void)updateHistoryButtons;

@end

