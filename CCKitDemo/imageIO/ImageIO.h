//
//  ImageIO.h
//  demo
//
//  Created by KudoCC on 16/5/16.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageIO : NSObject

+ (instancetype)sharedImageIO;

- (NSString *)fileDirectory;

@end
