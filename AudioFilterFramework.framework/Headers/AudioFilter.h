//
//  AudioFilter.h
//  AudioFilter
//
//  Created by 杨辉 on 16/8/3.
//  Copyright © 2016年 musical.ly. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface AudioFilter : NSObject

- (bool)Init;
- (bool)Uinit;

- (bool)doFilter:(NSBundle *)filterBundle withInput:(NSString *)input withOutput:(NSString *)output withDictionary:(NSDictionary *)dictionary;


@end
