//
//  APOutlet.h
//  LUI
//
//  Created by zhang hailong on 15/3/14.
//  Copyright (c) 2015年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APOutletValueFunction : NSObject

-(id) valueForObject:(id) object;

@end

@interface APOutletKeyPathValueFunction : APOutletValueFunction

@property(nonatomic,readonly,strong) NSString * keyPath;
@property(nonatomic,readonly,strong) Class valueClass;

-(id) initWithKeyPath:(NSString *) keyPath valueClass:(Class) valueClass;

+(id) outletKeyPathFunction:(NSString *) keyPath valueClass:(Class) valueClass;

@end

@interface APOutlet : NSObject

-(void) addOutlet:(id) target keyPath:(NSString *) keyPath
    valueFunction:(APOutletValueFunction *) valueFunction;

-(void) setObject:(id) object;

+(void) setTargetObject:(id) target;

+(void) setKeyPath:(NSString *) keyPath valueFunction:(APOutletValueFunction *) valueFunction;

+(void) beginOutlet;

+(void) cancelOutlet;

+(APOutlet *) commitOutlet;

@end

@interface NSObject(APOutlet)

@property(nonatomic,readonly) APOutlet * outlet;

+ (id) valueOf:(id) value;

@end

@interface NSString(APOutlet)


@end

@interface NSNumber(APOutlet)


@end
