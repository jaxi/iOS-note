//
//  Note.m
//  Notes
//
//  Created by Jingkai He on 23/06/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import "Note.h"

@implementation Note


- (instancetype) init
{
    self = [super init];
    
    if (self) {
        // Under Construction...
    }
    
    return self;
}

- (instancetype) initWithTitle: (NSString *)title content: (NSString *)content
{
    self = [super init];
    
    if (self) {
        [self setTitle:title];
        [self setContent:content];
    }
    
    return self;
}
@end
