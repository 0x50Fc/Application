//
//  APController.h
//  DocumentApplication
//
//  Created by ZhangHailong on 15/9/8.
//  Copyright (c) 2015年 hailong.org. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APPlatform_iPhone5_iOS7   @"iPhone5_iOS7"
#define APPlatform_iPhone_iOS7    @"iPhone_iOS7"
#define APPlatform_iPad_iOS7      @"iPad_iOS7"
#define APPlatform_iPhone5        @"iPhone5"
#define APPlatform_iPhone         @"iPhone"
#define APPlatform_iPad           @"iPad"
#define APPlatform_iOS7           @"iOS7"

@class APApplication;

@interface APController : NSObject<UIGestureRecognizerDelegate,UINavigationControllerDelegate,UITabBarControllerDelegate>

@property(nonatomic,strong) NSBundle * bundle;
@property(nonatomic,strong) APApplication * application;
@property(nonatomic,strong) NSURL * url;
@property(nonatomic,strong) id config;
@property(nonatomic,strong) NSString * name;
@property(nonatomic,strong) NSString * basePath;
@property(nonatomic,strong) NSString * scheme;
@property(nonatomic,weak) APController * parentController;
@property(nonatomic,strong) APController * topController;
@property(nonatomic,strong) APController * modalController;
@property(nonatomic,strong) APController * leftSidebarController;
@property(nonatomic,strong) APController * rightSidebarController;
@property(nonatomic,strong) UITapGestureRecognizer * sidebarTapGestureRecognizer;
@property(nonatomic,strong) UIPanGestureRecognizer * sidebarPanGestureRecognizer;
@property(nonatomic,assign) CGFloat leftSidebarControllerDistance;
@property(nonatomic,assign) CGFloat rightSidebarControllerDistance;
@property(nonatomic,strong,readonly) UIViewController * viewController;
@property(nonatomic,strong,readonly) NSArray * controllers;
@property(nonatomic,readonly,getter = isViewLoaded) BOOL viewLoaded;
@property(nonatomic,readonly,getter = isViewControllerLoaded) BOOL viewControllerLoaded;

-(void) addController:(APController *) controller;

-(void) remove;

-(id) initWithBundle:(NSBundle *) bundle;

-(BOOL) canOpenURL:(NSURL *) url;

-(BOOL) openURL:(NSURL *) url animated:(BOOL) animated;

-(NSString *) loadURL:(NSURL *) url basePath:(NSString *) basePath animated:(BOOL) animated;

-(void) setLeftSidebarController:(APController *)leftSidebarController animated:(BOOL) animated distance:(CGFloat) distance;

-(void) setRightSidebarController:(APController *)rightSidebarController animated:(BOOL) animated distance:(CGFloat) distance;

-(void) sidebarPanGestureAction: (UIPanGestureRecognizer * ) gestureRecognizer;

@end
