//
//  UITabBarController+APController.m
//  LUI
//
//  Created by ZhangHailong on 15/2/28.
//  Copyright (c) 2015年 hailong.org. All rights reserved.
//

#import "UITabBarController+APController.h"
#import "UIViewController+APController.h"
#import "APController.h"
#import "NSURL+QueryValue.h"
#import "APApplication.h"
#import "NSObject+VTValue.h"

@implementation UITabBarController(APController)

-(BOOL) controller:(APController *) controller canOpenURL:(NSURL *) url{
    
    NSString * scheme = controller.scheme;
    
    if(scheme == nil){
        controller.scheme = scheme = @"tab";
    }
    
    if([[url scheme] isEqualToString:scheme]){
        return YES;
    }
    
    return [super controller:controller canOpenURL:url];
}

-(BOOL) controller:(APController *)controller openURL:(NSURL *)url animated:(BOOL)animated {
    
    NSString * scheme = controller.scheme;
    
    if(scheme == nil){
        controller.scheme = scheme = @"tab";
    }
    
    if([[url scheme] isEqualToString:scheme]){
        
        NSLog(@"%@",[url absoluteString]);
    
        NSString * name = [url firstPathComponent:controller.basePath];
        
        for(APController * ctl in [controller controllers]){
            
            if([ctl.name isEqualToString:name]){
                
                [self setSelectedViewController:ctl.viewController];
                
                break;
            }
            
        }
        
        return YES;
        
    }
    
    return [super controller:controller openURL:url animated:animated];
}

-(NSString *) controller:(APController *)controller loadURL:(NSURL *)url basePath:(NSString *)basePath animated:(BOOL)animated {
    
    self.delegate = nil;
    
    if([[self viewControllers] count] == 0 ){
        
        NSMutableArray * viewControllers = [NSMutableArray arrayWithCapacity:4];
        
        for (id dataItem in [controller.config arrayValueForKey:@"items"] ) {
            
            APController * ctl = [controller.application getController:[NSURL URLWithString:[dataItem stringValueForKey:@"url"]] basePath:@"/"];
            
            [controller addController:ctl];
            
            UIViewController * viewController = [ctl viewController];
            
            viewController.tabBarItem.title = [dataItem stringValueForKey:@"title"];
            viewController.tabBarItem.image = [UIImage imageNamed:[dataItem stringValueForKey:@"image"]];
            
            [viewControllers addObject:viewController];
            
            [ctl loadURL:ctl.url basePath:ctl.basePath animated:animated];
        }

        [self setViewControllers:viewControllers animated:animated];
        
        if([[controller controllers] count]){
            controller.topController = [[controller controllers] objectAtIndex:0];
        }
        else {
            controller.topController = nil;
        }
    }
    
    self.delegate = controller;
    
    return [super controller:controller loadURL:url basePath:basePath animated:animated];
    
}

@end
