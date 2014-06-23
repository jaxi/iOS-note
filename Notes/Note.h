//
//  Note.h
//  Notes
//
//  Created by Jingkai He on 23/06/2014.
//  Copyright (c) 2014 Jingkai He. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Note : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;

- (instancetype) initWithTitle: (NSString *)title content: (NSString *)content;
@end
