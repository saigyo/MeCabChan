//
//  MecabTagger.m
//  CocoaMeCab
//
//  Created by Markus Ackermann on 25.10.10.
//  Copyright 2010 kaixo.de. All rights reserved.
//

#import "MecabTagger.h"
#import "MecabNode.h"

@implementation MecabTagger
-(id)init
{
	self = [super init];
	if (!self) {
		return nil;
	}
	NSBundle* bundle = [NSBundle mainBundle];
	NSString* resourcePath = [bundle resourcePath];
	
	NSString* mecabArgs = [NSString stringWithFormat:@"-Ochasen -d%@/ipadic -r%@/mecabrc", resourcePath, resourcePath];
	NSLog(@"MecabTagger.init: mecab args = %@", mecabArgs);
	
	const char* mecabArgs_cstr = [mecabArgs UTF8String];
	
	mecab_tagger = mecab_new2(mecabArgs_cstr);
	if (!mecab_tagger) {
		NSLog(@"MecabTagger.init: failed to create mecab tagger: %s", mecab_strerror(NULL));
		return nil;
	}
	const mecab_dictionary_info_t* dict_info = mecab_dictionary_info(mecab_tagger);
	
	NSString *dictFilename = [NSString stringWithUTF8String:(dict_info->filename)];
	NSString *dictCharset = [NSString stringWithUTF8String:(dict_info->charset)];
	NSLog(@"MecabTagger.init: created mecab tagger with dictionary %@, charset %@", dictFilename, dictCharset);
	
	return self;
}

-(void)dealloc
{
	mecab_destroy(mecab_tagger);
}

-(NSArray*)parse:(NSString *)sentence
{
	NSLog(@"MecabTagger.parse: sentence = %@", sentence);
	const char* sentence_cstr = [sentence UTF8String];
	const char* parse_cstr = mecab_sparse_tostr(mecab_tagger, sentence_cstr);
	if (!parse_cstr) {
		NSLog(@"MecabTagger.parse: mecab error: %s", mecab_strerror(mecab_tagger));
		return @[];
	}
	NSString* parse = [NSString stringWithUTF8String:parse_cstr];
	NSLog(@"MecabTagger.parse: parse = \n%@", parse);
	
	return [parse componentsSeparatedByString:@"\n"];
}

-(NSArray*)parseToFeatures:(NSString *)sentence
{
	NSArray* parse = [self parse:sentence];
	NSMutableArray* parseToFeatures = [NSMutableArray arrayWithCapacity:[parse count]];
	for(NSString* line in parse) {
		if ([line hasPrefix:@"EOS"]) {
			break;
		}
		[parseToFeatures addObject:[line componentsSeparatedByString:@"\t"]];
	}
	NSLog(@"MecabTagger.parseToFeatures: %@", parseToFeatures);
	return parseToFeatures;
}

-(NSArray*)parseToNodes:(NSString *)sentence
{
    return [self parseToNodes:sentence withTagMap:NULL];
}

-(NSArray*)parseToNodes:(NSString*)sentence withTagMap:(MecabTagMap*)map
{
    return [self parseToNodes:sentence withTagMap:map withInflectionMap:NULL];
}

-(NSArray*)parseToNodes:(NSString*)sentence withTagMap:(MecabTagMap*)tagMap withInflectionMap:(MecabTagMap*)inflMap
{
	NSArray* parse = [self parse:sentence];
	NSMutableArray* parseToNodes = [NSMutableArray arrayWithCapacity:[parse count]];
	NSInteger number = 0;
	for(NSString* line in parse) {
		if ([line hasPrefix:@"EOS"]) {
			break;
		}
		MecabNode* node = [MecabNode nodeFromParseLine:line withNumber:(++number) withTagMap:tagMap withInflectionMap:inflMap];
		[parseToNodes addObject:node];
	}
	// NSLog(@"MecabTagger.parseToNode: %@", parseToNodes);
	return parseToNodes;    
}
@end
