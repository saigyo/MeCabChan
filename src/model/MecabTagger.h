//
//  MecabTagger.h
//  CocoaMeCab
//
//  Created by Markus Ackermann on 25.10.10.
//  Copyright 2010 kaixo.de. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "mecab.h"
#import "MecabTagMap.h"

extern NSString * const MecabTaggerErrorDomain;

typedef NS_ENUM(NSInteger, MecabTaggerErrorCode) {
    MecabTaggerErrorDictionaryMissing = 1,
    MecabTaggerErrorDictionaryIncomplete,
    MecabTaggerErrorConfigMissing,
    MecabTaggerErrorCreationFailed,
};

@interface MecabTagger : NSObject {
	mecab_t* mecab_tagger;
}
-(id)init;
-(id)initWithError:(NSError **)error;
-(id)initWithDictionaryPath:(NSString *)dictionaryPath
                 configPath:(NSString *)configPath
                      error:(NSError **)error;
-(NSArray*)parse:(NSString*)sentence;
-(NSArray*)parseToFeatures:(NSString*)sentence;
-(NSArray*)parseToNodes:(NSString*)sentence;
-(NSArray*)parseToNodes:(NSString*)sentence withTagMap:(MecabTagMap*)tagMap;
-(NSArray*)parseToNodes:(NSString*)sentence withTagMap:(MecabTagMap*)tagMap withInflectionMap:(MecabTagMap*)inflMap;
@end
