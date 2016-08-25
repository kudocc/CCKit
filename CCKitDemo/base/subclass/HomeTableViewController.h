//
//  HomeTableViewController.h
//  demo
//
//  Created by KudoCC on 16/5/11.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^TableViewCellSelectedBlock)(NSIndexPath *path);

@interface HomeTableViewController : BaseViewController

@property (nonatomic, strong) NSArray *arrayTitle;
@property (nonatomic, strong) NSArray *arrayClass;
/**
 set property with key value coding, if it is [NSNull null], do not set.
 */
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *arraySetProperty;

@property (nonatomic) TableViewCellSelectedBlock cellSelectedBlock;

@end
