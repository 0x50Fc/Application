//
//  APOutlet.m
//  LUI
//
//  Created by zhang hailong on 15/3/14.
//  Copyright (c) 2015年 hailong.org. All rights reserved.
//

#import "APOutlet.h"

#include <objc/runtime.h>
#include <pthread.h>

#import <NSObject+VTValue.h>

@interface APOutletItem : NSObject

@property(nonatomic,strong) id target;
@property(nonatomic,strong) NSString * keyPath;
@property(nonatomic,strong) APOutletValueFunction * valueFunction;

-(void) setObject:(id) object;

@end

@implementation APOutletItem

-(void) setObject:(id) object {
    
    @try {
        [_target setValue:[_valueFunction valueForObject:object] forKeyPath:_keyPath];
    }
    @catch(NSException * exception){
        NSLog(@"%@",exception);
    }
}

@end

@implementation APOutletValueFunction

-(id) valueForObject:(id) object{
    return object;
}

@end

@implementation APOutletKeyPathValueFunction

-(id) valueForObject:(id) object{
    
    id value = [object objectValueForKeyPath:_keyPath];
    
    if( value && _valueClass){
        if(! [value isKindOfClass:_valueClass]){
            value = [_valueClass valueOf:value];
        }
    }
    
    return value;
}

-(id) initWithKeyPath:(NSString *) keyPath valueClass:(Class)valueClass{
    
    if((self = [super init])){
        _keyPath = keyPath;
        _valueClass = valueClass;
    }
    
    return self;
}

+(id) outletKeyPathFunction:(NSString *)keyPath valueClass:(Class)valueClass{
    return [[self alloc] initWithKeyPath:keyPath valueClass:valueClass];
}

@end

@interface APOutlet() {
    NSMutableArray * _items;
}

@property(nonatomic,strong) id target;

+(APOutlet *) peekOutlet;

@end

static pthread_key_t APOutletKey = 0;

static void APOutletKeyDealloc(void * data){
    @autoreleasepool {
        objc_unretainedObject(data);
    }
}

@implementation APOutlet

+ (void)load{
    [super load];
    
    pthread_key_create(& APOutletKey, APOutletKeyDealloc);
    
}

-(void) addOutlet:(id) target keyPath:(NSString *) keyPath
    valueFunction:(APOutletValueFunction *) valueFunction{
    if(_items == nil){
        _items = [[NSMutableArray alloc] initWithCapacity:4];
    }
    APOutletItem * item = [[APOutletItem alloc] init];
    item.target = target;
    item.keyPath = keyPath;
    item.valueFunction = valueFunction;
    [_items addObject:item];
}

-(void) setObject:(id) object{
    
    for (APOutletItem * item in _items) {
        [item setObject:object];
    }
    
}

+(void) setTargetObject:(id) target {
    [[APOutlet peekOutlet] setTarget:target];
}

+(void) setKeyPath:(NSString *) keyPath valueFunction:(APOutletValueFunction *) valueFunction{
    
    APOutlet * outlet = [APOutlet peekOutlet];
    
    if(outlet && outlet.target && keyPath && valueFunction){
        [outlet addOutlet:outlet.target keyPath:keyPath valueFunction:valueFunction];
    }
    
}

+(void) beginOutlet{
    
    NSMutableArray * outlets = (__bridge NSMutableArray *) (pthread_getspecific(APOutletKey));
    
    if(outlets == nil){
        outlets = [[NSMutableArray alloc] initWithCapacity:4];
        pthread_setspecific(APOutletKey, (__bridge_retained void *) outlets);
    }
    
    APOutlet * outlet = [[APOutlet alloc] init];
    
    [outlets addObject:outlet];
    
}

+(void) cancelOutlet{
    
    NSMutableArray * outlets = (__bridge NSMutableArray *) (pthread_getspecific(APOutletKey));
    
    [outlets removeLastObject];
    
}

+(APOutlet *) commitOutlet{
    
    NSMutableArray * outlets = (__bridge NSMutableArray *) (pthread_getspecific(APOutletKey));
    
    __block APOutlet * outlet = [outlets lastObject];
    
    [outlet setTarget:nil];
    
    [outlets removeLastObject];
    
    return outlet;
}

+(APOutlet *) peekOutlet {
    NSMutableArray * outlets = (__bridge NSMutableArray *) (pthread_getspecific(APOutletKey));
    return [outlets lastObject];
}

-(void) setValue:(id)value forKeyPath:(NSString *)keyPath{
    
    if([value hasPrefix:@"#"]){
       
        if(_target){
            
            NSArray * vs = [[value substringFromIndex:1] componentsSeparatedByString:@":"];
            
            if([vs count] > 0){
                NSString * vkey = [vs objectAtIndex:0];
                Class valueClass = nil;
                
                if([vs count] > 1){
                    valueClass = NSClassFromString([vs objectAtIndex:1]);
                }
                
                [self addOutlet:_target keyPath:keyPath valueFunction:[APOutletKeyPathValueFunction outletKeyPathFunction:vkey valueClass:valueClass]];
                
            }
        }
    }
    else {
        [super setValue:value forKeyPath:keyPath];
    }
}

@end

@implementation NSObject(APOutlet)

-(APOutlet *) outlet {
    
    APOutlet * outlet = objc_getAssociatedObject(self, "_outlet");
    
    if(outlet == nil){
        
        outlet = [APOutlet peekOutlet];
        
        [APOutlet setTargetObject:self];
        
        if(outlet){
            objc_setAssociatedObject(self, "_outlet", outlet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
    }
    
    return outlet;
}

+ (id) valueOf:(id)value{
    return value;
}

@end

@implementation NSString(APOutlet)

+ (id) valueOf:(id)value{
    return [NSString stringWithFormat:@"%@",value];
}

@end

@implementation NSNumber(APOutlet)

+(id) valueOf:(id)value{
    return [NSNumber numberWithDouble:[value doubleValue]];
}

@end
