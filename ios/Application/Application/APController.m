//
//  APController.m
//  DocumentApplication
//
//  Created by ZhangHailong on 15/9/8.
//  Copyright (c) 2015年 hailong.org. All rights reserved.
//

#import "APController.h"
#import "UIViewController+APController.h"
#import "APCreatorViewController.h"
#import "NSObject+VTValue.h"
#import "NSURL+QueryValue.h"

@interface APController(){
    NSMutableArray * _controllers;
    CGPoint _panLocation;
    CGPoint _panPrevLocation;
    CGPoint _panDistance;
}

@end

@implementation APController

@synthesize bundle = _bundle;
@synthesize application = _application;
@synthesize url = _url;
@synthesize config = _config;
@synthesize name = _name;
@synthesize basePath = _basePath;
@synthesize scheme = _scheme;
@synthesize parentController = _parentController;
@synthesize topController = _topController;
@synthesize viewController = _viewController;
@synthesize controllers = _controllers;
@synthesize leftSidebarController = _leftSidebarController;
@synthesize rightSidebarController = _rightSidebarController;
@synthesize leftSidebarControllerDistance = _leftSidebarControllerDistance;
@synthesize rightSidebarControllerDistance = _rightSidebarControllerDistance;

-(id) initWithBundle:(NSBundle *) bundle{
    if((self = [super init])){
        _bundle = bundle;
    }
    return self;
}


-(void) setConfig:(id)config{
    _config = config;
    _scheme = [config valueForKey:@"scheme"];
}


-(BOOL) canOpenURL:(NSURL *) url{
    return [[self viewController] controller:self canOpenURL:url];
}

-(BOOL) openURL:(NSURL *) url animated:(BOOL) animated{
    return [[self viewController] controller:self openURL:url animated:animated];
}

-(NSString *) loadURL:(NSURL *) url basePath:(NSString *) basePath animated:(BOOL) animated{
    return [[self viewController] controller:self loadURL:url basePath:basePath animated:animated];
}

+ (NSMutableArray *) platformKeys{
    
    static NSMutableArray * platformKeys = nil;
    
    if(platformKeys == nil){
        
        platformKeys = [[NSMutableArray alloc] initWithCapacity:4];
        
        UIDevice * device = [UIDevice currentDevice];
        double systemVersion = [[device systemVersion] doubleValue];
        
        if([device respondsToSelector:@selector(userInterfaceIdiom)]){
            if([device userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                if(systemVersion >= 7.0){
                    [platformKeys addObject:APPlatform_iPad_iOS7];
                }
                [platformKeys addObject:APPlatform_iPad];
            }
            else{
                CGSize screenSize = [[UIScreen mainScreen] bounds].size;
                if(screenSize.height == 568){
                    if(systemVersion >= 7.0){
                        [platformKeys addObject:APPlatform_iPhone5_iOS7];
                    }
                    [platformKeys addObject:APPlatform_iPhone5];
                }
                [platformKeys addObject:APPlatform_iPhone];
            }
        }
        
        if(systemVersion >= 7.0){
            [platformKeys addObject:APPlatform_iOS7];
        }
        
    }
    
    return platformKeys;
}

-(UIViewController *) viewController{
    
    if(_viewController == nil){
        
        id cfg = self.config;
        id platform = nil;
        
        for(NSString * key in [APController platformKeys]){
            platform = [cfg valueForKey:key];
            if(platform){
                break;
            }
        }
        
        if(platform == nil){
            platform = cfg;
        }
        
        
        NSString * className = [cfg valueForKey:@"class"];
        
        Class clazz = className ? NSClassFromString(className) : [UIViewController class];
        
        if(clazz == nil){
            
            clazz = [UIViewController class];
            
            NSLog(@"Not Found View Controller Class %@",className);
            
        }
        
        NSString * view = [cfg valueForKey:@"view"];
        
        UIViewController * viewController = [[clazz alloc] initWithNibName:view bundle:_bundle];
        
        if([viewController isKindOfClass:[APCreatorViewController class]]){
            [viewController view];
            _viewController = [(APCreatorViewController *) viewController viewController];
        }
        else {
            _viewController = viewController;
        }
        
        NSString * title = [self.config stringValueForKey:@"title"];
        
        if(title){
            [_viewController setTitle:title];
        }
        
    }
    
    return _viewController;
}

-(NSArray *) controllers{
    
    if(_controllers == nil){
        _controllers = [[NSMutableArray alloc] initWithCapacity:4];
    }
    
    return _controllers;
}

-(void) addController:(APController *) controller{
    
    __block APController * ctl = controller;
    
    [ctl remove];
    
    if(_controllers == nil){
        _controllers = [[NSMutableArray alloc] initWithCapacity:4];
    }
    
    [_controllers addObject:ctl];
    
    [ctl setParentController:self];
    
}

-(void) remove{
    
    if(_parentController){
        
        APController * parent = _parentController;
        
        _parentController = nil;
        
        [parent->_controllers removeObject:self];
        
    }
}


-(void) setModalController:(APController *)modalController{
    [_modalController setParentController:nil];
    _modalController = modalController;
    [_modalController setParentController:self];
}

-(void) setLeftSidebarController:(APController *)leftSidebarController {
    [_leftSidebarController setParentController:nil];
    _leftSidebarController = leftSidebarController;
    [_leftSidebarController setParentController:self];
}

-(void) setRightSidebarController:(APController *)rightSidebarController {
    [_rightSidebarController setParentController:nil];
    _rightSidebarController = rightSidebarController;
    [_rightSidebarController setParentController:self];
}

-(void) _sidebarTapGestureAction: (UITapGestureRecognizer * ) gestureRecognizer{
    
    if(_leftSidebarController){
        
        UIView * v = [self.viewController view];
        
        CGPoint p = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
        
        CGRect r = [v frame];
        
        if(CGRectContainsPoint(r, p)) {
            
            [self setLeftSidebarController:nil animated:YES distance:0];
            
        }
    }
    else if(_rightSidebarController){
        
        UIView * v = [self.viewController view];
        
        CGPoint p = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
        
        
        CGRect r = [v frame];
        
        if(CGRectContainsPoint(r, p)) {
            
            [self setRightSidebarController:nil animated:YES distance:0];
            
        }
        
    }
    
}

-(UITapGestureRecognizer *) sidebarTapGestureRecognizer{
    if(_sidebarTapGestureRecognizer == nil){
        _sidebarTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_sidebarTapGestureAction:)];
        [_sidebarTapGestureRecognizer setDelaysTouchesEnded:NO];
        [_sidebarTapGestureRecognizer setCancelsTouchesInView:NO];
    }
    return _sidebarTapGestureRecognizer;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if(gestureRecognizer == _sidebarPanGestureRecognizer){
        
        CGPoint p = [touch locationInView:gestureRecognizer.view.superview];
        
        UIView * v = [self.viewController view];
        
        CGRect r = [v frame];
        
        return CGRectContainsPoint(r, p);
        
    }
    
    return YES;
}

-(void) sidebarPanGestureAction: (UIPanGestureRecognizer * ) gestureRecognizer{
    
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        
        _panLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
        _panPrevLocation = _panLocation;
        
    }
    else if( gestureRecognizer.state == UIGestureRecognizerStateChanged){
        
        CGPoint p = [gestureRecognizer locationInView:gestureRecognizer.view];
        
        _panDistance.x = p.x - _panPrevLocation.x;
        _panDistance.y = p.y - _panPrevLocation.y;
        _panPrevLocation = p;
        
        p.x -= _panLocation.x;
        p.y -= _panLocation.y;
        
        if(_leftSidebarController){
            
            UIView * cv = [self.viewController view];
            UIView * pv = [cv superview];
            UIView * v = [_leftSidebarController.viewController view];
            
            CGRect pr = [pv bounds];
            
            pr.origin = CGPointZero;
            
            CGRect r = [cv frame];
            
            r.origin.x = pr.size.width - _leftSidebarControllerDistance + p.x;
            
            if(r.origin.x < 0){
                r.origin.x = 0;
            }
            else if(r.origin.x > pr.size.width){
                r.origin.x = pr.size.width;
            }
            
            [cv setFrame:r];
            
            [v setAlpha:0.92 + 0.08 * r.origin.x / (pr.size.width - _leftSidebarControllerDistance) ];
            
        }
        else if(_rightSidebarController) {
            
        }
    }
    else {
        
        if(_leftSidebarController){
            
            if(_panDistance.x >= 0){
                UIView * cv = [self.viewController view];
                UIView * pv = [cv superview];
                UIView * v = [_leftSidebarController.viewController view];
                
                CGRect pr = [pv bounds];
                
                pr.origin = CGPointZero;
                
                CGRect r = [cv frame];
                
                r.origin.x = pr.size.width - _leftSidebarControllerDistance ;
                
                [UIView animateWithDuration:0.3 animations:^{
                    
                    [cv setFrame:r];
                    [v setAlpha:1.0];
                }];
            }
            else {
                [self setLeftSidebarController:nil animated:YES distance:0];
            }
            
        }
        else if(_rightSidebarController) {
            
            if(_panDistance.x <= 0){
                
                UIView * cv = [self.viewController view];
                UIView * pv = [cv superview];
                UIView * v = [_rightSidebarController.viewController view];
                
                CGRect pr = [pv bounds];
                
                pr.origin = CGPointZero;
                
                CGRect r = [cv frame];
                
                r.origin.x = _rightSidebarControllerDistance - pr.size.width;
                
                [UIView animateWithDuration:0.3 animations:^{
                    
                    [cv setFrame:r];
                    [v setAlpha:1.0];
                    
                }];
            }
            else {
                [self setRightSidebarController:nil animated:YES distance:0];
            }
            
        }
        
    }
    
}

-(UIPanGestureRecognizer *) sidebarPanGestureRecognizer{
    if(_sidebarPanGestureRecognizer == nil){
        _sidebarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sidebarPanGestureAction:)];
        [_sidebarPanGestureRecognizer setDelegate:self];
    }
    return _sidebarPanGestureRecognizer;
}

-(void) setLeftSidebarController:(APController *)leftSidebarController animated:(BOOL) animated distance:(CGFloat) distance{
    
    _leftSidebarControllerDistance = distance;
    
    if(_leftSidebarController != leftSidebarController && [self isViewLoaded]){
        
        UIView * cv = [self.viewController view];
        UIView * pv = [cv superview];
        CGRect pr = pv.bounds;
        
        pr.origin = CGPointZero;
        
        if(_leftSidebarController){
            
            
            UIView * ov = [_leftSidebarController.viewController view];
            
            if(animated){
                
                __block APController * animController = _leftSidebarController;
                
                [UIView animateWithDuration:0.3 animations:^{
                    [ov setAlpha:0.92];
                } completion:^(BOOL finished) {
                    [ov removeFromSuperview];
                    animController = nil;
                }];
                
            }
            else {
                [ov removeFromSuperview];
            }
            
            if(leftSidebarController){
                
                
                UIView * v = [leftSidebarController.viewController view];
                
                if(animated) {
                    v.frame = pr;
                    v.alpha = 0.92;
                    
                    [pv insertSubview:v atIndex:0];
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        
                        [v setAlpha:1.0];
                        
                    }];
                    
                }
                else {
                    
                    v.frame = pr;
                    v.alpha = 1.0;
                    
                    [pv insertSubview:v atIndex:0];
                    
                }
                
            }
            else {
                
                [cv setUserInteractionEnabled:YES];
                [pv removeGestureRecognizer:self.sidebarTapGestureRecognizer];
                [pv removeGestureRecognizer:self.sidebarPanGestureRecognizer];
                
                if(animated){
                    [UIView animateWithDuration:0.3 animations:^{
                        [cv setFrame:pr];
                    }];
                }
                else {
                    [cv setFrame:pr];
                }
                
            }
            
        }
        else if(leftSidebarController){
            
            UIView * v = [leftSidebarController.viewController view];
            
            if(animated) {
                
                [UIView animateWithDuration:0.3 animations:^{
                    [cv setFrame:CGRectMake(pr.size.width - distance, 0, pr.size.width, pr.size.height)];
                }];
                
                
                v.frame = pr;
                v.alpha = 0.92;
                
                [pv insertSubview:v atIndex:0];
                
                [UIView animateWithDuration:0.3 animations:^{
                    
                    [v setAlpha:1.0];
                    
                }];
                
            }
            else {
                
                cv.frame = CGRectMake(pr.size.width - distance, 0, pr.size.width, pr.size.height);
                cv.alpha = 1.0;
                
                v.frame = pr;
                v.alpha = 1.0;
                
                [pv insertSubview:v atIndex:0];
                
            }
            
            [cv setUserInteractionEnabled:NO];
            [pv addGestureRecognizer:self.sidebarTapGestureRecognizer];
            [pv addGestureRecognizer:self.sidebarPanGestureRecognizer];
        }
        else {
            
            [cv setUserInteractionEnabled:YES];
            [pv removeGestureRecognizer:self.sidebarTapGestureRecognizer];
            [pv removeGestureRecognizer:self.sidebarPanGestureRecognizer];
            
            if(animated) {
                
                [UIView animateWithDuration:0.3 animations:^{
                    [cv setFrame:CGRectMake(0, 0, pr.size.width, pr.size.height)];
                }];
                
            }
            else {
                
                cv.frame = CGRectMake(0, 0, pr.size.width, pr.size.height);
                
                
            }
            
        }
        
        [self setLeftSidebarController:leftSidebarController];
    }
}

-(void) setRightSidebarController:(APController *)rightSidebarController animated:(BOOL) animated distance:(CGFloat) distance{
    
    _rightSidebarControllerDistance = distance;
    
    if(_rightSidebarController != rightSidebarController && [self isViewLoaded]){
        
        UIView * cv = [self.viewController view];
        UIView * pv = [cv superview];
        CGRect pr = pv.bounds;
        
        pr.origin = CGPointZero;
        
        if(_rightSidebarController){
            
            UIView * ov = [_rightSidebarController.viewController view];
            
            if(animated){
                
                __block APController * animController = _rightSidebarController;
                
                [UIView animateWithDuration:0.3 animations:^{
                    [ov setAlpha:0.0];
                } completion:^(BOOL finished) {
                    [ov removeFromSuperview];
                    animController = nil;
                }];
                
            }
            else {
                [ov removeFromSuperview];
            }
            
            if(rightSidebarController){
                
                UIView * v = [rightSidebarController.viewController view];
                
                if(animated) {
                    
                    v.frame = pr;
                    v.alpha = 0.92;
                    
                    [pv insertSubview:v atIndex:0];
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        
                        [v setAlpha:1.0];
                        
                    }];
                    
                }
                else {
                    
                    v.frame = pr;
                    v.alpha = 1.0;
                    
                    [pv insertSubview:v atIndex:0];
                    
                }
            }
            else {
                
                [cv setUserInteractionEnabled:YES];
                [pv removeGestureRecognizer:self.sidebarTapGestureRecognizer];
                [pv removeGestureRecognizer:self.sidebarPanGestureRecognizer];
                
                if(animated){
                    [UIView animateWithDuration:0.3 animations:^{
                        [cv setFrame:pr];
                    }];
                }
                else {
                    [cv setFrame:pr];
                }
                
            }
            
        }
        else if(rightSidebarController){
            
            UIView * v = [rightSidebarController.viewController view];
            
            if(animated) {
                
                [UIView animateWithDuration:0.3 animations:^{
                    [cv setFrame:CGRectMake(distance - pr.size.width, 0, pr.size.width, pr.size.height)];
                }];
                
                
                v.frame = pr;
                v.alpha = 0.92;
                
                [pv insertSubview:v atIndex:0];
                
                [UIView animateWithDuration:0.3 animations:^{
                    
                    [v setAlpha:1.0];
                    
                }];
                
            }
            else {
                
                cv.frame = CGRectMake(distance - pr.size.width, 0, pr.size.width, pr.size.height);
                cv.alpha = 1.0;
                
                v.frame = pr;
                v.alpha = 1.0;
                
                [pv insertSubview:v atIndex:0];
                
            }
            
            
            [cv setUserInteractionEnabled:NO];
            [pv addGestureRecognizer:self.sidebarTapGestureRecognizer];
            [pv addGestureRecognizer:self.sidebarPanGestureRecognizer];
            
        }
        else {
            
            [cv setUserInteractionEnabled:YES];
            [pv removeGestureRecognizer:self.sidebarTapGestureRecognizer];
            [pv removeGestureRecognizer:self.sidebarPanGestureRecognizer];
            
            if(animated) {
                
                [UIView animateWithDuration:0.3 animations:^{
                    [cv setFrame:CGRectMake(0, 0, pr.size.width, pr.size.height)];
                }];
                
            }
            else {
                
                cv.frame = CGRectMake(0, 0, pr.size.width, pr.size.height);
                
                
            }
            
        }
        
        [self setRightSidebarController:rightSidebarController];
    }
}

-(BOOL) isViewControllerLoaded {
    return _viewController != nil;
}

-(BOOL) isViewLoaded {
    return _viewController != nil && [_viewController isViewLoaded];
}

- (void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    NSURL * url = [self url];
    
    NSArray * controllers = [self controllers];
    
    APController * ctl;
    
    while ((ctl = [controllers lastObject])) {
        
        if(ctl.viewController == viewController){
            break;
        }
        else {
            
            [ctl remove];
            
            url = [NSURL URLWithString:@"." relativeToURL:url];
        }
        
    }
    
    if(url != self.url){
        
        NSInteger index = [controllers count] - 1;
        
        NSString * basePath = [self.basePath stringByAppendingPathComponent:self.name];
        
        NSString * name = [url firstPathComponent:basePath];
        
        while(name && index >= 0){
            
            basePath = [[controllers objectAtIndex:index] loadURL:url basePath:basePath animated:animated];
            
            name = [url firstPathComponent:basePath];
            
            index -- ;
        }
        
        self.topController = [controllers lastObject];
        
    }
    
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
    for (APController * ctl in [self controllers]) {
        if(ctl.viewController == viewController){
            self.topController = ctl;
            break;
        }
    }
    
}

@end
