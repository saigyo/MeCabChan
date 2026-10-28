//
//  MyDocumentTests.m
//  MeCabChanTests
//

#import <XCTest/XCTest.h>
#import "MyDocument.h"
#import "MecabTagger.h"

@interface AlertCountingDocument : MyDocument
@property (nonatomic) NSInteger presentedTaggerErrorCount;
@end

@implementation AlertCountingDocument

- (void)presentTaggerError
{
    self.presentedTaggerErrorCount++;
}

@end

@interface MyDocumentTests : XCTestCase
@end

@implementation MyDocumentTests

- (NSTextField *)sourceFieldWithText:(NSString *)text
{
    NSTextField *field = [[NSTextField alloc] initWithFrame:NSZeroRect];
    field.stringValue = text;
    return field;
}

- (void)testTokenizingWithoutTaggerPresentsErrorAndLeavesNodesEmpty
{
    NSError *error = [NSError errorWithDomain:MecabTaggerErrorDomain
                                         code:MecabTaggerErrorDictionaryMissing
                                     userInfo:@{NSLocalizedDescriptionKey: @"dictionary missing"}];
    AlertCountingDocument *document = [[AlertCountingDocument alloc] initWithTagger:nil taggerError:error];

    XCTAssertEqualObjects(document.taggerError, error);
    [document setValue:[self sourceFieldWithText:@"今日は良い天気です。"] forKey:@"source"];

    [document tokenize:nil];

    XCTAssertEqual(document.presentedTaggerErrorCount, 1);
    XCTAssertEqual(document.mecabNodes.count, 0);
}

- (void)testTokenizingWithWorkingTaggerParsesWithoutPresentingError
{
    NSError *error = nil;
    MecabTagger *tagger = [[MecabTagger alloc] initWithError:&error];
    XCTAssertNotNil(tagger);
    XCTAssertNil(error);

    AlertCountingDocument *document = [[AlertCountingDocument alloc] initWithTagger:tagger taggerError:error];
    [document setValue:[self sourceFieldWithText:@"今日は良い天気です。"] forKey:@"source"];

    [document tokenize:nil];

    XCTAssertEqual(document.presentedTaggerErrorCount, 0);
    XCTAssertEqual(document.mecabNodes.count, 6);
}

@end
