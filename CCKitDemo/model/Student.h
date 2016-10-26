//
//  Student.h
//  CCKitDemo
//
//  Created by KudoCC on 16/10/26.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "People.h"

@interface Student : People <CCModel, NSCopying, NSCoding>

@property int grade;

@end
