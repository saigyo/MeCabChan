//
//  MecabTagMap.h
//  MeCabChan
//
//  Created by Markus Ackermann on 30.08.11.
//  Copyright 2011 kaixo.de. All rights reserved.
//



@interface MecabTagMap : NSObject {
    NSDictionary *map;
}
- (id)initFrom:(NSString*)resourceFileName;
@property (readonly) NSDictionary* map;
@end
