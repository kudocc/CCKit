//
//  CCStack.h
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCStack : NSObject

- (id)top;

- (void)push:(id)obj;

- (id)pop;
- (void)popAll;

- (BOOL)isEmpty;

@end
