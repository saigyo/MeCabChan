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

@end
