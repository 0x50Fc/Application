//
//  APViewController.h
//  LUI
//
//  Created by zhang hailong on 15/2/26.
//  Copyright (c) 2015年 hailong.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Application/APController.h>

@protocol APActionProtocol

@property(nonatomic,strong) NSString * openURI;

@end

@interface APViewController : UIViewController

@property(nonatomic,strong) APApplication * application;
@property(nonatomic,weak) APController * controller;
@property(nonatomic,strong) IBOutlet UIBarButtonItem * leftButtonItem;
@property(nonatomic,strong) IBOutlet UIBarButtonItem * rightButtonItem;
@property(nonatomic,strong) IBOutletCollection(UIBarButtonItem) NSArray * leftButtonItems;
@property(nonatomic,strong) IBOutletCollection(UIBarButtonItem) NSArray * rightButtonItems;

-(IBAction) doOpenURIAction:(id)sender;

-(BOOL) openURI:(NSString *) uri animated:(BOOL) animated;

@end
