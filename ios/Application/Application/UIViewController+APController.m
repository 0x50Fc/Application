//
//  UIViewController+APController.m
//  LUI
//
//  Created by zhang hailong on 15/2/20.
//  Copyright (c) 2015年 hailong.org. All rights reserved.
//

#import "UIViewController+APController.h"
#import "APController.h"
#import "NSURL+QueryValue.h"
#import "APApplication.h"
#import "NSObject+VTValue.h"

@implementation UIViewController(APController)

-(BOOL) controller:(APController *) controller canOpenURL:(NSURL *) url{
    return [[controller parentController] canOpenURL:url];
}

-(BOOL) controller:(APController *) controller openURL:(NSURL *) url animated:(BOOL) animated{
    
    if([url.scheme isEqualToString:@"present"]){
        
        NSString * name = [url firstPathComponent:@"/"];
        
        if([name length]){
            
            if([url.host length] == 0 || [url.host isEqualToString:controller.scheme]){
                
                APController * modelController = controller;
                
                while([modelController modalController]){
                    modelController = [modelController modalController];
                }
                
                NSLog(@"%@",[url absoluteString]);
                
                APController * ctl = [controller.application getController:url basePath:@"/"];
                
                if(ctl){
                    
                    [modelController setModalController:ctl];
                    
                    [ctl loadURL:url basePath:@"/" animated:animated];
                    
                    [modelController.viewController presentViewController:ctl.viewController
                                                                 animated:YES completion:nil];
                    
                    return YES;
                }
                
            }
            
        }
        else if([controller.url.scheme isEqualToString:@"present"]){
            
            NSLog(@"%@",[url absoluteString]);
            
            [self dismissViewControllerAnimated:animated completion:nil];
            
            [controller.parentController setModalController:nil];
            
            return YES;
        }
    }
    else if([url.scheme isEqualToString:@"sidebar"]){
        
        NSString * name = [url firstPathComponent:@"/"];
        
        if([name length]){
            
            if([url.host length] == 0 || [url.host isEqualToString:controller.scheme]){
                
                if(! [self isViewLoaded] || ! self.view.window){
                    return NO;
                }
                
                NSLog(@"%@",[url absoluteString]);
                
                NSDictionary * queryValues = [url queryValues];
                
                CGFloat distance = [queryValues floatValueForKey:@"distance" defaultValue:64 * [APApplication dp]];
                
                if([queryValues valueForKey:@"right"]){
                    
                    APController * ctl = [controller rightSidebarController];
                    
                    if(ctl){
                        
                        if([ctl.name isEqualToString:name]){
                            
                            [ctl loadURL:url basePath:@"/" animated:animated];
                            
                            return YES;
                        }
                        else {
                            if([controller isViewLoaded]){
                                [[controller.viewController view] removeFromSuperview];
                            }
                        }
                        
                    }
                    
                    ctl = [controller.application getController:url basePath:@"/"];
                    
                    [ctl loadURL:url basePath:@"/" animated:animated];
                    
                    [controller setRightSidebarController:ctl animated:animated distance:distance];
                    
                }
                else {
                    
                    APController * ctl = [controller leftSidebarController];
                    
                    if(ctl){
                        
                        if([ctl.name isEqualToString:name]){
                            
                            [ctl loadURL:url basePath:@"/" animated:animated];
                            
                            return YES;
                        }
                        else {
                            if([controller isViewLoaded]){
                                [[controller.viewController view] removeFromSuperview];
                            }
                        }
                        
                    }
                    
                    ctl = [controller.application getController:url basePath:@"/"];
                    
                    [ctl loadURL:url basePath:@"/" animated:animated];
                    
                    [controller setLeftSidebarController:ctl animated:animated distance:distance];
                    
                }
    
                
                return YES;
                
            }
            
        }
        else if([url.host length] == 0 || [url.host isEqualToString:controller.scheme]){
            
            if(! [self isViewLoaded] || ! self.view.window){
                return NO;
            }
            
            NSLog(@"%@",[url absoluteString]);
            
            APController * ctl = [controller rightSidebarController];
            
            if(ctl){
                
                [controller setRightSidebarController:nil animated:animated distance:0];
                
            }
            
            ctl = [controller leftSidebarController];
            
            if(ctl){
                
                [controller setLeftSidebarController:nil animated:animated distance:0];
                
            }

            return YES;
            
        }
        
    }
    
    return [[controller parentController] openURL:url animated:animated];
}

-(NSString *) controller:(APController *) controller loadURL:(NSURL *) url basePath:(NSString *) basePath animated:(BOOL) animated{
    
    NSString * title = [controller.config stringValueForKey:@"title"];
    
    if(title){
        self.title = title;
    }
    
    return [basePath stringByAppendingPathComponent:controller.name];
}

@end
