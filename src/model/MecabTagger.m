//
//  MecabTagger.m
//  CocoaMeCab
//
//  Created by Markus Ackermann on 25.10.10.
//  Copyright 2010 kaixo.de. All rights reserved.
//

#import <os/log.h>
#import "MecabTagger.h"
#import "MecabNode.h"

NSString * const MecabTaggerErrorDomain = @"de.kaixo.MeCabChan.MecabTagger";

static os_log_t MecabTaggerLog(void)
{
    static os_log_t log = OS_LOG_DEFAULT;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        log = os_log_create("de.kaixo.MeCabChan", "Tagger");
    });
    return log;
}

static NSError *MecabTaggerError(MecabTaggerErrorCode code, NSString *description, NSString *reason)
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:description forKey:NSLocalizedDescriptionKey];
    if (reason) {
        [userInfo setObject:reason forKey:NSLocalizedFailureReasonErrorKey];
    }
    return [NSError errorWithDomain:MecabTaggerErrorDomain code:code userInfo:userInfo];
}

@implementation MecabTagger

-(id)init
{
	return [self initWithError:NULL];
}

-(id)initWithError:(NSError **)error
{
	NSBundle* bundle = [NSBundle mainBundle];
	NSString* resourcePath = [bundle resourcePath];

	return [self initWithDictionaryPath:[resourcePath stringByAppendingPathComponent:@"ipadic"]
	                         configPath:[resourcePath stringByAppendingPathComponent:@"mecabrc"]
	                              error:error];
}

-(id)initWithDictionaryPath:(NSString *)dictionaryPath configPath:(NSString *)configPath error:(NSError **)error
{
	self = [super init];
	if (!self) {
		return nil;
	}

	NSFileManager* fileManager = [NSFileManager defaultManager];
	BOOL isDirectory = NO;
	NSError* failure = nil;

	if (!dictionaryPath || ![fileManager fileExistsAtPath:dictionaryPath isDirectory:&isDirectory] || !isDirectory) {
		failure = MecabTaggerError(MecabTaggerErrorDictionaryMissing,
		                           @"MeCabChan could not load its Japanese dictionary.",
		                           [NSString stringWithFormat:@"The dictionary folder is missing from the application bundle (%@).", dictionaryPath ?: @"unknown"]);
	} else if (![fileManager fileExistsAtPath:[dictionaryPath stringByAppendingPathComponent:@"sys.dic"]]) {
		failure = MecabTaggerError(MecabTaggerErrorDictionaryIncomplete,
		                           @"MeCabChan could not load its Japanese dictionary.",
		                           [NSString stringWithFormat:@"The dictionary folder is incomplete: sys.dic is missing (%@).", dictionaryPath]);
	} else if (!configPath || ![fileManager fileExistsAtPath:configPath]) {
		failure = MecabTaggerError(MecabTaggerErrorConfigMissing,
		                           @"MeCabChan could not start its tokenizer.",
		                           [NSString stringWithFormat:@"The MeCab configuration file is missing (%@).", configPath ?: @"unknown"]);
	}

	if (failure) {
		if (error) {
			*error = failure;
		}
		os_log_error(MecabTaggerLog(), "cannot create tagger: %{public}@", [failure localizedDescription]);
		return nil;
	}

	NSString* mecabArgs = [NSString stringWithFormat:@"-Ochasen -d%@ -r%@", dictionaryPath, configPath];
	os_log_debug(MecabTaggerLog(), "creating tagger with arguments %{public}@", mecabArgs);

	mecab_tagger = mecab_new2([mecabArgs UTF8String]);
	if (!mecab_tagger) {
		failure = MecabTaggerError(MecabTaggerErrorCreationFailed,
		                           @"MeCabChan could not start its tokenizer.",
		                           @"MeCab rejected the bundled dictionary or configuration.");
		if (error) {
			*error = failure;
		}
		os_log_error(MecabTaggerLog(), "mecab_new2 returned NULL");
		return nil;
	}

	const mecab_dictionary_info_t* dict_info = mecab_dictionary_info(mecab_tagger);
	if (dict_info) {
		os_log_debug(MecabTaggerLog(), "created tagger with dictionary %{public}s, charset %{public}s", dict_info->filename, dict_info->charset);
	}

	return self;
}

-(void)dealloc
{
	mecab_destroy(mecab_tagger);
}

-(NSArray*)parse:(NSString *)sentence
{
	os_log_debug(MecabTaggerLog(), "parsing input of %lu characters", (unsigned long)[sentence length]);
	const char* sentence_cstr = [sentence UTF8String];
	const char* parse_cstr = mecab_sparse_tostr(mecab_tagger, sentence_cstr);
	if (!parse_cstr) {
		os_log_error(MecabTaggerLog(), "mecab_sparse_tostr failed: %{public}s", mecab_strerror(mecab_tagger));
		return @[];
	}
	NSString* parse = [NSString stringWithUTF8String:parse_cstr];

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
	os_log_debug(MecabTaggerLog(), "parsed %lu nodes", (unsigned long)[parseToNodes count]);
	return parseToNodes;
}
@end
