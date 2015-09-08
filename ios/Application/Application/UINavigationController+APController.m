//
//  UINavigationController+APController.m
//  LUI
//
//  Created by zhang hailong on 15/2/20.
//  Copyright (c) 2015年 hailong.org. All rights reserved.
//

#import "UINavigationController+APController.h"
#import "UIViewController+APController.h"
#import "APController.h"
#import "NSURL+QueryValue.h"
#import "APApplication.h"

@implementation UINavigationController(APController)

-(NSString *) controller:(APController *)controller loadURL:(NSURL *)url basePath:(NSString *)basePath animated:(BOOL)animated {

    self.delegate = nil;
    
    NSMutableArray * viewControllers = [NSMutableArray arrayWithArray:[self viewControllers]];
    
    NSMutableArray * controllers = [NSMutableArray arrayWithArray:controller.controllers];
    NSMutableArray * newViewControllers = [NSMutableArray arrayWithCapacity:4];
    
    basePath = [basePath stringByAppendingPathComponent:controller.name];
    
    NSString * name = [url firstPathComponent:basePath];
    
    while(name){
        
        
        if([controllers count] >0 && [viewControllers count] > 0){
            
            APController * ctl = [controllers objectAtIndex:0];
            
            if([ctl.name isEqualToString:name]
               && ctl.viewController == [viewControllers objectAtIndex:0]){
                [newViewControllers addObject:ctl.viewController];
                basePath = [ctl loadURL:url basePath:basePath animated:animated];
                [controllers removeObjectAtIndex:0];
                [viewControllers removeObjectAtIndex:0];
                
            }
            else{
                
                for (APController * ctl in controllers) {
                    
                    [ctl remove];
                    
                }
                
                [controllers removeAllObjects];
                [viewControllers removeAllObjects];
            }
        }
        else{
            
            if([controllers count]){
                
                for (APController * ctl in controllers) {
                    
                    [ctl remove];
                    
                }
                
                [controllers removeAllObjects];
                [viewControllers removeAllObjects];
            }
            
            APController * ctl = [controller.application getController:url basePath:basePath];
            
            if(ctl){
                
                [controller addController:ctl];
                
                basePath = [ctl loadURL:url basePath:basePath animated:animated];
                
                [newViewControllers addObject:ctl.viewController];
                
            }
            else{
                break;
            }
        }
        
        name = [url firstPathComponent:basePath];
        
    }
    
    for (APController * ctl in controllers) {
        
        [ctl remove];
        
    }
    
    [controllers removeAllObjects];
    
    controller.topController = [[controller controllers] lastObject];
    
    [self setViewControllers:newViewControllers animated:animated];
  
    self.delegate = controller;
    
    return basePath;
    
}

-(BOOL) controller:(APController *)controller canOpenURL:(NSURL *)url{
    
    NSString * scheme = controller.scheme;
    
    if(scheme == nil){
        controller.scheme = scheme = @"nav";
    }
    
    if([[url scheme] isEqualToString:scheme]){
        return YES;
    }
    
    return [super controller:controller canOpenURL:url];
}

-(BOOL) controller:(APController *)controller openURL:(NSURL *)url animated:(BOOL)animated {
    
    NSString * scheme = controller.scheme;
    
    if(scheme == nil){
        controller.scheme = scheme = @"nav";
    }
    
    if([[url scheme] isEqualToString:scheme]){
        
        NSLog(@"%@",[url absoluteString]);
        
        [self controller:controller loadURL:url basePath:controller.basePath animated:animated];
        
        controller.url = url;
        
        return YES;
        
    }
    
    return [super controller:controller openURL:url animated:animated];
}


@end
