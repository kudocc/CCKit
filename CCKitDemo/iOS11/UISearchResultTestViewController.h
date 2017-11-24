//
//  UISearchResultTestViewController.h
//  CCKitDemo
//
//  Created by kudocc on 2017/9/26.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "BaseViewController.h"

@interface UISearchResultTestViewController : BaseViewController <UISearchResultsUpdating>

@property (nonatomic) NSMutableArray *items;

@end
