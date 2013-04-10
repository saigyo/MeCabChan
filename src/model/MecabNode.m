//
//  MecabNode.m
//  CocoaMeCab
//
//  Created by Markus Ackermann on 25.10.10.
//  Copyright 2010 kaixo.de. All rights reserved.
//

#import "MecabNode.h"


@implementation MecabNode
+(id)nodeFromParseLine:(NSString *)line
{
	return [MecabNode nodeFromParseLine:line withNumber:0];
}

+(id)nodeFromParseLine:(NSString *)line withNumber:(NSInteger)num
{
    return [MecabNode nodeFromParseLine:line withNumber:num withTagMap:NULL];
}
+(id)nodeFromParseLine:(NSString*)line withNumber:(NSInteger)number withTagMap:(MecabTagMap*)tagMap
{
    return [MecabNode nodeFromParseLine:line withNumber:number withTagMap:tagMap withInflectionMap:NULL];
}
+(id)nodeFromParseLine:(NSString*)line withNumber:(NSInteger)number withTagMap:(MecabTagMap*)tagMap withInflectionMap:(MecabTagMap *)inflectionMap
{
	MecabNode* node = [[[MecabNode alloc] initFromParseLine:line withNumber:number withTagMap:tagMap withInflectionMap:inflectionMap] autorelease];
	// NSLog(@"Created %@", node);
	return node;    
}

-(id)init
{
	return [self initFromParseLine:@""];
}

-(void)dealloc
{
	[token release];
	[reading release];
	[lemma release];
	[posTag release];
	[stemType release];
	[inflection release];
	[super dealloc];
}

-(id)initFromParseLine:(NSString *)line
{
	return [self initFromParseLine:line withNumber:0];
}

-(id)initFromParseLine:(NSString *)line withNumber:(NSInteger)num
{
    return [self initFromParseLine:line withNumber:num withTagMap:NULL];
}

-(id)initFromParseLine:(NSString*)line withNumber:(NSInteger)num withTagMap:(MecabTagMap*)tagMap
{
    return [self initFromParseLine:line withNumber:num withTagMap:tagMap withInflectionMap:NULL];
}

-(id)initFromParseLine:(NSString*)line withNumber:(NSInteger)num withTagMap:(MecabTagMap*)tagMap withInflectionMap:(MecabTagMap *)inflectionMap
{
	[super init];
	number = num;
	NSArray* features = [line componentsSeparatedByString:@"\t"];
	int count = [features count];
	if (count > 0) {
		token = [[features objectAtIndex:0] retain];
	} 
	if (count > 1) {
		reading = [[features objectAtIndex:1] retain];
	}
	if (count > 2) {
		lemma = [[features objectAtIndex:2] retain];
	}
	if (count > 3) {
        if (tagMap) {
            posTag = [[[tagMap map] objectForKey:[features objectAtIndex:3]] retain];
        }
        if (posTag == NULL) {
            posTag = [[features objectAtIndex:3] retain];
        }
	}
	if (count > 4) {
		stemType = [[features objectAtIndex:4] retain];
	}
	if (count > 5) {
        if (inflectionMap) {
            inflection = [[[inflectionMap map] objectForKey:[features objectAtIndex:5]] retain];
        }
        if (inflection == NULL) {
            inflection = [[features objectAtIndex:5] retain];
        }
	}
	
	return self;    
}


- (NSString*)description
{
	return [NSString stringWithFormat:@"MecabNode: number = %ld, token = %@, reading = %@, lemma = %@, posTag = %@, stemType = %@, inflection = %@", number, token, reading, lemma, posTag, stemType, inflection];
}

-(NSString*)tabbedDescriptionString
{
	NSMutableString *result = [NSMutableString stringWithString:token];
	[result appendString:@"\t"];
	if (reading) {
		[result appendFormat:@"%@", reading];
	}
	[result appendString:@"\t"];
	if (lemma) {
		[result appendFormat:@"%@", lemma];
	}
	[result appendString:@"\t"];
	if (posTag) {
		[result appendFormat:@"%@", posTag];
	}
	[result appendString:@"\t"];
	if (stemType) {
		[result appendFormat:@"%@", stemType];
	}
	[result appendString:@"\t"];
	if (inflection) {
		[result appendFormat:@"%@", inflection];
	}
	return result;
}

#pragma mark Properties

@synthesize number;
@synthesize token;
@synthesize reading;
@synthesize lemma;
@synthesize posTag;
@synthesize stemType;
@synthesize inflection;
@end
