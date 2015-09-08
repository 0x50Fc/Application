//
//  APApplication.h
//  DocumentApplication
//
//  Created by ZhangHailong on 15/9/8.
//  Copyright (c) 2015年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Application/APController.h>

@interface APApplication : NSObject

+(double) dp;

@property(nonatomic,readonly) NSBundle * bundle;
@property(nonatomic,readonly) NSDictionary * appInfo;

-(id) initWithBundle:(NSBundle *) bundle appinfo:(NSString *) appinfo;

-(APController *) rootController;

-(void) makeVisible;

-(APController *) getController:(NSURL *) url basePath:(NSString *) basePath;


@end
