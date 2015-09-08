//
//  APApplication.m
//  DocumentApplication
//
//  Created by ZhangHailong on 15/9/8.
//  Copyright (c) 2015年 hailong.org. All rights reserved.
//

#import "APApplication.h"
#import "APCreatorViewController.h"
#import "NSURL+QueryValue.h"

@interface APApplication(){
    APController * _rootController;
}

@end

@implementation APApplication

+(double) dp {
    
    static double dp = 0;
    
    if(dp == 0){
        
        CGSize size = [[UIScreen mainScreen] bounds].size;
        
        if(size.width >= 768 ){
            dp = size.width / 768.0;
        }
        else {
            dp = size.width / 320.0;
        }
    }
    
    return dp;
}

-(id) initWithBundle:(NSBundle *) bundle appinfo:(NSString *) appinfo{
    
    if((self = [super init])){
        _bundle = bundle;
        _appInfo = [[NSDictionary alloc] initWithContentsOfFile:[bundle pathForResource:appinfo ofType:@"plist"]];
    }
    
    return self;
}

-(APController *) rootController{
    
    if(_rootController == nil){
        NSURL * url = [NSURL URLWithString:[self.appInfo valueForKey:@"url"]];
        _rootController = [self getController:url basePath:@"/"];
    }
    
    return _rootController;
}

-(APController *) getController:(NSURL *) url basePath:(NSString *) basePath{
    
    NSString * name = [url firstPathComponent:basePath];
    
    if(name){
        
        id ui = [self.appInfo valueForKey:@"ui"];
        
        id config = [ui valueForKey:name];
        
        if(config){
            
            APController * controller = [[APController alloc] initWithBundle:_bundle];
            
            controller.application = self;
            controller.name = name;
            controller.url = url;
            controller.basePath = basePath;
            controller.config = config;
            
            return controller;
            
        }
        
    }
    
    return nil;
}

-(void) makeVisible{
    APController * rootController = [self rootController];
    [rootController loadURL:rootController.url basePath:@"/" animated:NO];
}

@end
