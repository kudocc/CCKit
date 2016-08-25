//
//  CCAsyncLayer.h
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CCAsyncLayer : CALayer

@property (nonatomic) BOOL asyncDisplay;

@end

@class CCAsyncLayerDisplayTask;

@protocol CCAsyncLayerDelegate <NSObject>
@required
/// This method is called to return a new display task when the layer's contents need update.
- (CCAsyncLayerDisplayTask *)newAsyncDisplayTask;
@end


@interface CCAsyncLayerDisplayTask : NSObject

/**
 This block will be called before the asynchronous drawing begins.
 It will be called on the main thread.
 
 @param layer  The layer.
 */
@property (nonatomic, copy) void (^willDisplay)(CALayer *layer);

/**
 This block is called to draw the layer's contents.
 
 @discussion This block may be called on main thread or background thread,
 so is should be thread-safe.
 
 @param context      A new bitmap content created by layer.
 @param size         The content size (typically same as layer's bound size).
 @param isCancelled  If this block returns `YES`, the method should cancel the
 drawing process and return as quickly as possible.
 */
@property (nonatomic, copy) void (^display)(CGContextRef context, CGSize size, BOOL(^isCancelled)(void));

/**
 This block will be called after the asynchronous drawing finished.
 It will be called on the main thread.
 
 @param layer  The layer.
 @param finished  If the draw process is cancelled, it's `NO`, otherwise it's `YES`;
 */
@property (nonatomic, copy) void (^didDisplay)(CALayer *layer, BOOL finished);

@end