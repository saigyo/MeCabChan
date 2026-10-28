//
//  MecabTaggerTests.m
//  MeCabChanTests
//

#import <XCTest/XCTest.h>
#import "MecabTagger.h"
#import "MecabTagMap.h"
#import "MecabNode.h"

@interface MecabTaggerTests : XCTestCase
@end

@implementation MecabTaggerTests

- (void)testParsesSentenceWithBundledDictionary
{
    MecabTagger *tagger = [[MecabTagger alloc] init];
    XCTAssertNotNil(tagger);

    NSArray *nodes = [tagger parseToNodes:@"今日は良い天気です。"];
    NSArray *tokens = [nodes valueForKey:@"token"];
    XCTAssertEqualObjects(tokens, (@[@"今日", @"は", @"良い", @"天気", @"です", @"。"]));

    MecabNode *first = nodes.firstObject;
    XCTAssertEqual(first.number, 1);
    XCTAssertEqualObjects(first.reading, @"キョウ");
    XCTAssertEqualObjects(first.posTag, @"名詞-副詞可能");
}

- (void)testTranslatesTagsWithTagMap
{
    MecabTagger *tagger = [[MecabTagger alloc] init];
    MecabTagMap *tagMap = [[MecabTagMap alloc] initFrom:@"chasen-tags.txt"];
    MecabTagMap *inflectionMap = [[MecabTagMap alloc] initFrom:@"ipadic-verb-inflections.txt"];

    NSArray *nodes = [tagger parseToNodes:@"今日は良い天気です。" withTagMap:tagMap withInflectionMap:inflectionMap];
    XCTAssertEqualObjects([nodes[0] posTag], @"noun adverbial");
    XCTAssertEqualObjects([nodes[1] posTag], @"particle dependency");
}

- (void)testReportsMissingDictionaryDirectory
{
    NSString *missingPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]]
                             stringByAppendingPathComponent:@"ipadic"];
    NSError *error = nil;

    MecabTagger *tagger = [[MecabTagger alloc] initWithDictionaryPath:missingPath
                                                           configPath:missingPath
                                                                error:&error];

    XCTAssertNil(tagger);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, MecabTaggerErrorDomain);
    XCTAssertEqual(error.code, MecabTaggerErrorDictionaryMissing);
    XCTAssertTrue(error.localizedDescription.length > 0);
    XCTAssertTrue([error.localizedFailureReason containsString:missingPath]);
}

- (void)testReportsIncompleteDictionary
{
    NSString *directory = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    XCTAssertTrue([fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL]);

    NSError *error = nil;
    MecabTagger *tagger = [[MecabTagger alloc] initWithDictionaryPath:directory
                                                           configPath:directory
                                                                error:&error];

    XCTAssertNil(tagger);
    XCTAssertEqualObjects(error.domain, MecabTaggerErrorDomain);
    XCTAssertEqual(error.code, MecabTaggerErrorDictionaryIncomplete);
    XCTAssertTrue([error.localizedFailureReason containsString:@"sys.dic"]);

    [fileManager removeItemAtPath:directory error:NULL];
}

- (void)testReportsMissingConfig
{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *dictionaryPath = [resourcePath stringByAppendingPathComponent:@"ipadic"];
    NSString *configPath = [resourcePath stringByAppendingPathComponent:@"mecabrc-missing"];
    NSError *error = nil;

    MecabTagger *tagger = [[MecabTagger alloc] initWithDictionaryPath:dictionaryPath
                                                           configPath:configPath
                                                                error:&error];

    XCTAssertNil(tagger);
    XCTAssertEqualObjects(error.domain, MecabTaggerErrorDomain);
    XCTAssertEqual(error.code, MecabTaggerErrorConfigMissing);
    XCTAssertTrue([error.localizedFailureReason containsString:configPath]);
}

- (void)testErrorIsNilOnSuccess
{
    NSError *error = nil;

    MecabTagger *tagger = [[MecabTagger alloc] initWithError:&error];

    XCTAssertNotNil(tagger);
    XCTAssertNil(error);
}

@end
