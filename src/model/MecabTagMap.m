//
//  MecabTagMap.m
//  MeCabChan
//
//  Created by Markus Ackermann on 30.08.11.
//  Copyright 2011 kaixo.de. All rights reserved.
//

#import "MecabTagMap.h"

@implementation MecabTagMap

+ (NSDictionary*) parse:(NSString*)tagSource
{
    NSMutableArray* descriptions = [NSMutableArray arrayWithCapacity:100];
    NSMutableArray* tags = [NSMutableArray arrayWithCapacity:100];
    
    NSArray* lines = [tagSource componentsSeparatedByString:@"\n"];
    for (int i = 0; i < [lines count]; i++) {
        NSString* line = [lines objectAtIndex:i];
        NSArray* parts = [line componentsSeparatedByString:@" "];
        
        if ([parts count]<3) {
            NSLog(@"MecabTagMap.parse: oops, line %d is too short: %@", i, line);
            continue;
        }
        
        NSString* description = [[parts objectAtIndex:2] stringByReplacingOccurrencesOfString:@"-" withString:@" "];
        [descriptions addObject:description];
        [tags addObject:[parts objectAtIndex:1]];
    }
    
    NSDictionary* dict = [[NSDictionary alloc] initWithObjects:descriptions forKeys:tags];
    
    return dict;
}

- (id)initFrom:(NSString*)resourceFileName
{
    if (!self) {
        self = [super init];
    }
    if (self) {
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* resourcePath = [bundle resourcePath];
        NSString* tagFile = [NSString stringWithFormat:@"%@/%@", resourcePath, resourceFileName];
        
        NSString* tagSource = [NSString stringWithContentsOfFile:tagFile encoding:NSUTF8StringEncoding error:NULL];
        
        map = [MecabTagMap parse:tagSource];
        
        // NSLog(@"MecabTagMap.init: created map from %@: %@", tagFile, [map description]);
    }
    return self;    
}

- (id)init
{
    self = [super init];
    return [self initFrom:@"chasen-tags.txt"];
}

-(void)dealloc
{
    [map dealloc];
    [super dealloc];
}
    
- (NSString *)description
{
    return [NSString stringWithFormat:@"MecabTagMap: %@", [map description]];
}

#pragma mark Properties

@synthesize map;
@end
