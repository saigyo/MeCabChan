//
//  MecabTagMap.m
//  MeCabChan
//
//  Created by Markus Ackermann on 30.08.11.
//  Copyright 2011 kaixo.de. All rights reserved.
//

#import <os/log.h>
#import "MecabTagMap.h"

static os_log_t MecabTagMapLog(void)
{
    static os_log_t log = OS_LOG_DEFAULT;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        log = os_log_create("de.kaixo.MeCabChan", "TagMap");
    });
    return log;
}

@implementation MecabTagMap

+ (NSDictionary*) parse:(NSString*)tagSource
{
    NSMutableArray* descriptions = [NSMutableArray arrayWithCapacity:100];
    NSMutableArray* tags = [NSMutableArray arrayWithCapacity:100];
    
    NSArray* lines = [tagSource componentsSeparatedByString:@"\n"];
    for (NSUInteger i = 0; i < [lines count]; i++) {
        NSString* line = [lines objectAtIndex:i];
        NSArray* parts = [line componentsSeparatedByString:@" "];
        
        if ([parts count]<3) {
            os_log_error(MecabTagMapLog(), "malformed tag map line at index %lu", (unsigned long)i);
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
    self = [super init];
    if (self) {
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* resourcePath = [bundle resourcePath];
        NSString* tagFile = [NSString stringWithFormat:@"%@/%@", resourcePath, resourceFileName];
        
        NSString* tagSource = [NSString stringWithContentsOfFile:tagFile encoding:NSUTF8StringEncoding error:NULL];
        
        map = [MecabTagMap parse:tagSource];
    }
    return self;    
}

- (id)init
{
    return [self initFrom:@"chasen-tags.txt"];
}

    
- (NSString *)description
{
    return [NSString stringWithFormat:@"MecabTagMap: %@", [map description]];
}

#pragma mark Properties

@synthesize map;
@end
