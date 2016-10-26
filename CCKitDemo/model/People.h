//
//  People.h
//  CCKitDemo
//
//  Created by KudoCC on 16/10/26.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+CCModel.h"

@interface People : NSObject <CCModel>
@property NSString *name;
@property int age;
@end
