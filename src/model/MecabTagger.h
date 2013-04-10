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

@interface MecabTagger : NSObject {
	mecab_t* mecab_tagger;
}
-(NSArray*)parse:(NSString*)sentence;
-(NSArray*)parseToFeatures:(NSString*)sentence;
-(NSArray*)parseToNodes:(NSString*)sentence;
-(NSArray*)parseToNodes:(NSString*)sentence withTagMap:(MecabTagMap*)tagMap;
-(NSArray*)parseToNodes:(NSString*)sentence withTagMap:(MecabTagMap*)tagMap withInflectionMap:(MecabTagMap*)inflMap;
@end
