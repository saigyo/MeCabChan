//
//  MecabNode.h
//  CocoaMeCab
//
//  Created by Markus Ackermann on 25.10.10.
//  Copyright 2010 kaixo.de. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MecabTagMap.h"

@interface MecabNode : NSObject {
	NSInteger number;
	NSString* token;
	NSString* reading;
	NSString* lemma;
	NSString* posTag;
	NSString* stemType;
	NSString* inflection;
}
+(id)nodeFromParseLine:(NSString*)line;
+(id)nodeFromParseLine:(NSString*)line withNumber:(NSInteger)number;
+(id)nodeFromParseLine:(NSString*)line withNumber:(NSInteger)number withTagMap:(MecabTagMap*)tagMap;
+(id)nodeFromParseLine:(NSString*)line
            withNumber:(NSInteger)number
            withTagMap:(MecabTagMap*)tagMap
     withInflectionMap:(MecabTagMap*)inflectionMap;
-(id)initFromParseLine:(NSString*)line;
-(id)initFromParseLine:(NSString*)line withNumber:(NSInteger)number;
-(id)initFromParseLine:(NSString*)line withNumber:(NSInteger)number withTagMap:(MecabTagMap*)tagMap;
-(id)initFromParseLine:(NSString*)line
            withNumber:(NSInteger)number
            withTagMap:(MecabTagMap*)tagMap
     withInflectionMap:(MecabTagMap*)inflectionMap;
-(NSString*)tabbedDescriptionString;
@property (readonly) NSInteger number;
@property (readonly) NSString* token;
@property (readonly) NSString* reading;
@property (readonly) NSString* lemma;
@property (readonly) NSString* posTag;
@property (readonly) NSString* stemType;
@property (readonly) NSString* inflection;
@end
