//
//  UITabBarController+APController.h
//  LUI
//
//  Created by ZhangHailong on 15/2/28.
//  Copyright (c) 2015年 hailong.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APController;

@interface UITabBarController(APController)

-(BOOL) controller:(APController *) controller canOpenURL:(NSURL *) url;

-(BOOL) controller:(APController *) controller openURL:(NSURL *) url animated:(BOOL) animated;

-(NSString *) controller:(APController *) controller loadURL:(NSURL *) url basePath:(NSString *) basePath animated:(BOOL) animated;


@end
