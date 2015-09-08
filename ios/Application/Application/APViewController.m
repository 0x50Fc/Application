//
//  APViewController.m
//  LUI
//
//  Created by zhang hailong on 15/2/26.
//  Copyright (c) 2015年 hailong.org. All rights reserved.
//

#import "APViewController.h"

#import "UIViewController+APController.h"
#import "NSObject+VTValue.h"
#import "APBarButtonItem.h"

@implementation APViewController


-(UIBarButtonItem *) leftButtonItem{
    return [self.navigationItem leftBarButtonItem];
}

-(void) setLeftButtonItem:(UIBarButtonItem *)leftButtonItem{
    [self.navigationItem setLeftBarButtonItem:leftButtonItem];
}

-(NSArray *) leftButtonItems{
    return [self.navigationItem leftBarButtonItems];
}

-(void) setLeftButtonItems:(NSArray *)leftButtonItems {
    [self.navigationItem setLeftBarButtonItems:leftButtonItems];
}

-(UIBarButtonItem *) rightButtonItem {
    return [self.navigationItem rightBarButtonItem];
}

-(void) setRightButtonItem:(UIBarButtonItem *)rightButtonItem{
    [self.navigationItem setRightBarButtonItem:rightButtonItem];
}

-(NSArray *) rightButtonItems{
    return [self.navigationItem rightBarButtonItems];
}

-(void) setRightButtonItems:(NSArray *)rightButtonItems {
    [self.navigationItem setRightBarButtonItems:rightButtonItems];
}

-(NSString *) controller:(APController *) controller loadURL:(NSURL *) url basePath:(NSString *) basePath animated:(BOOL) animated{
    
    self.controller = controller;
    self.application = controller.application;
    
    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]){
        
        UIRectEdge edges = UIRectEdgeNone;
        
        NSString * v  = [controller.config stringValueForKey:@"edges"];
        
        if(v){
            
            for(NSString * vv in [v componentsSeparatedByString:@" "]){
                
                if([vv isEqualToString:@"left"]){
                    edges = edges | UIRectEdgeLeft;
                }
                else if([vv isEqualToString:@"top"]){
                    edges = edges | UIRectEdgeTop;
                }
                else if([vv isEqualToString:@"right"]){
                    edges = edges | UIRectEdgeRight;
                }
                else if([vv isEqualToString:@"bottom"]){
                    edges = edges | UIRectEdgeBottom;
                }
            }
            
        }
        
        [self setEdgesForExtendedLayout:edges];
    }
    
    if([controller.config arrayValueForKey:@"leftBarItems"]){
        
        NSMutableArray * leftBarItems = [NSMutableArray arrayWithCapacity:4];
        
        for(id barItem in [controller.config arrayValueForKey:@"leftBarItems"]){
            
            NSString * image = [barItem stringValueForKey:@"image"];
            APBarButtonItem * buttonItem = nil;
            
            if(image){
                buttonItem = [[APBarButtonItem alloc] initWithImage:[UIImage imageNamed:image] style:UIBarButtonItemStyleBordered target:self action:@selector(doOpenURIAction:)];
            }
            else {
                buttonItem = [[APBarButtonItem alloc] initWithTitle:[barItem stringValueForKey:@"title"] style:UIBarButtonItemStyleBordered target:self action:@selector(doOpenURIAction:)];
            }
            
            [buttonItem setOpenURI:[barItem stringValueForKey:@"openURI"]];
            
            [leftBarItems addObject:buttonItem];
            
        }
        
        self.leftButtonItems = leftBarItems;
        
    }
    else if([controller.config dictionaryValueForKey:@"leftBarItem"]){
        
        id barItem = [controller.config dictionaryValueForKey:@"leftBarItem"];
        
        NSString * image = [barItem stringValueForKey:@"image"];
        APBarButtonItem * buttonItem = nil;
        
        if(image){
            buttonItem = [[APBarButtonItem alloc] initWithImage:[UIImage imageNamed:image] style:UIBarButtonItemStyleBordered target:self action:@selector(doOpenURIAction:)];
        }
        else {
            buttonItem = [[APBarButtonItem alloc] initWithTitle:[barItem stringValueForKey:@"title"] style:UIBarButtonItemStyleBordered target:self action:@selector(doOpenURIAction:)];
        }
        
        [buttonItem setOpenURI:[barItem stringValueForKey:@"openURI"]];
        
        self.leftButtonItem = buttonItem;

        
    }
    
    if([controller.config arrayValueForKey:@"rightBarItems"]){
        
        NSMutableArray * leftBarItems = [NSMutableArray arrayWithCapacity:4];
        
        for(id barItem in [controller.config arrayValueForKey:@"rightBarItems"]){
            
            NSString * image = [barItem stringValueForKey:@"image"];
            APBarButtonItem * buttonItem = nil;
            
            if(image){
                buttonItem = [[APBarButtonItem alloc] initWithImage:[UIImage imageNamed:image] style:UIBarButtonItemStyleBordered target:self action:@selector(doOpenURIAction:)];
            }
            else {
                buttonItem = [[APBarButtonItem alloc] initWithTitle:[barItem stringValueForKey:@"title"] style:UIBarButtonItemStyleBordered target:self action:@selector(doOpenURIAction:)];
            }
            
            [buttonItem setOpenURI:[barItem stringValueForKey:@"openURI"]];
            
            [leftBarItems addObject:buttonItem];
            
        }
        
        self.rightButtonItems = leftBarItems;
        
    }
    else if([controller.config dictionaryValueForKey:@"rightBarItem"]){
        
        id barItem = [controller.config dictionaryValueForKey:@"rightBarItem"];
        
        NSString * image = [barItem stringValueForKey:@"image"];
        APBarButtonItem * buttonItem = nil;
        
        if(image){
            buttonItem = [[APBarButtonItem alloc] initWithImage:[UIImage imageNamed:image] style:UIBarButtonItemStyleBordered target:self action:@selector(doOpenURIAction:)];
        }
        else {
            buttonItem = [[APBarButtonItem alloc] initWithTitle:[barItem stringValueForKey:@"title"] style:UIBarButtonItemStyleBordered target:self action:@selector(doOpenURIAction:)];
        }
        
        [buttonItem setOpenURI:[barItem stringValueForKey:@"openURI"]];
        
        self.rightButtonItem = buttonItem;
        
        
    }
    
    if([controller.config objectValueForKey:@"hidesBottomBarWhenPushed"]){
        [self setHidesBottomBarWhenPushed:[controller.config booleanValueForKey:@"hidesBottomBarWhenPushed"]];
    }
    
    return [super controller:controller loadURL:url basePath:basePath animated:animated];
}

-(IBAction) doOpenURIAction:(id)sender{
    
    if([sender respondsToSelector:@selector(openURI)]){
        
        [self openURI:[sender openURI] animated:YES];
        
    }
    
    
    
}

-(BOOL) openURI:(NSString *) uri animated:(BOOL) animated{
    
    return [self.controller openURL:[NSURL URLWithString:uri relativeToURL:self.controller.url] animated:animated];
    
}

-(void) _performOpenURI:(NSString *) uri{
    
    [self openURI:uri animated:YES];
    
}

-(void) performOpenURI:(NSString *) uri afterDelay:(NSTimeInterval) afterDelay{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self performSelector:@selector(_performOpenURI:) withObject:uri afterDelay:afterDelay];
    
}

@end
