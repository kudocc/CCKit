//
//  IncrementalImageSourceViewController.h
//  demo
//
//  Created by KudoCC on 16/5/18.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "BaseViewController.h"

/**
 创建一个Incremental的CGImageSource with CGImageSourceCreateIncremental，从server下载图片，渐进加载图片
 */
@interface IncrementalImageSourceViewController : BaseViewController <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@end
