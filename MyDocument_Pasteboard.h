/*
 
 File: MyDocument_Pasteboard.h
 
 */ 

#import "MyDocument.h"

@interface MyDocument(Pasteboard)

/* Methods for writing to the pasteboard */
- (NSArray *)writablePasteboardTypes;
- (BOOL)writeSelectionToPasteboard:(NSPasteboard *)pboard types:(NSArray *)types;
- (BOOL)writeSelectionToPasteboard:(NSPasteboard *)pboard type:(NSString *)type;
- (void)copy:(id)sender;

/* Methods for reading from the pasteboard */
- (NSArray *)readablePasteboardTypes;
- (BOOL)readSelectionFromPasteboard:(NSPasteboard *)pboard;
- (BOOL)readSelectionFromPasteboard:(NSPasteboard *)pboard type:(NSString *)type;
- (void)paste:(id)sender;

@end
