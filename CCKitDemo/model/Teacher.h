//
//  Teacher.h
//  CCKitDemo
//
//  Created by KudoCC on 16/10/26.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "People.h"

@interface Teacher : People <NSCopying, NSCoding>
@property int subject;
@end
