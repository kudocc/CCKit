//
//  UIImage+CCKit.h
//  performance
//
//  Created by KudoCC on 16/5/9.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CCKit)

///---------------------
/// @name Create a image with UIColor
///---------------------

/// create a image with UIColor
+ (UIImage *)cc_imageWithColor:(UIColor *)color size:(CGSize)size;

/// create a image with UIColor as background, border width, border line color, corner radius
+ (UIImage *)cc_imageWithColor:(UIColor *)color size:(CGSize)size borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor cornerRadius:(CGFloat)radius;

/// create a image with UIColor, dash line width, dash line border color and corner radius
+ (UIImage *)cc_imageWithColor:(UIColor *)color size:(CGSize)size lineWidth:(CGFloat)lineWidth dashLineColor:(UIColor *)dashLineColor cornerRadius:(CGFloat)radius;


///---------------------
/// @name Create a image through resize self with UIViewContentMode
///---------------------

/// resize image to `size` response to `contentMode`
+ (UIImage *)cc_resizeImage:(UIImage *)image contentMode:(UIViewContentMode)contentMode size:(CGSize)size;

///---------------------
/// @name Create a round corner image through modifying self with many options
///---------------------

/// create a round corner image with `size`, scale image with `UIViewContentModeScaleToFill` contentMode
- (UIImage *)cc_imageWithSize:(CGSize)size cornerRadius:(CGFloat)radius;
/// create a round corner image with `size`, scale image with `contentMode`, no border
- (UIImage *)cc_imageWithSize:(CGSize)size cornerRadius:(CGFloat)radius contentMode:(UIViewContentMode)contentMode;
/// create a round corner image with `size`, scale image with `contentMode`, with border and border color
- (UIImage *)cc_imageWithSize:(CGSize)size cornerRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor contentMode:(UIViewContentMode)contentMode;

///---------------------
/// @name Others
///---------------------

+ (UIImage *)cc_imageWithQRCodeString:(NSString *)qrCode imageSize:(CGSize)size;

/// convert UIImageOrientation to exif orientation
+ (int)cc_iOSOrientationToExifOrientation:(UIImageOrientation)iOSOrientation;
/// convert exif orientation to UIImageOrientation
+ (UIImageOrientation)cc_exifOrientationToiOSOrientation:(int)exifOrientation;

- (NSString *)cc_description;

@end


@interface UIImage (fixOrientation)

// http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
// http://stackoverflow.com/questions/7838699/save-uiimage-load-it-in-wrong-orientation/10632187#10632187
// orientation保存在图片的metadata中
// 因为PNG并没有orientation的信息，或者上传的图片可能丢失了orientation的信息，这里的两个方法都将图片转换成了UIImageOrientationUp
// 所以即使丢失了信息，UIImageOrientationUp也是默认的展示方式，不会出现问题
- (UIImage *)fixOrientation;
- (UIImage *)fixOrientationV2;

@end

@interface UIImage (UIImagePickerController)

- (NSData *)pngDataWithMetadata:(NSDictionary *)metadata;
- (NSData *)jpegDataWithMetadata:(NSDictionary *)metadata compressQuality:(CGFloat)compressionQuality;

- (BOOL)writePNGDataWithMetadata:(NSDictionary *)metadata toURL:(NSURL *)url;
- (BOOL)writeJPEGDataWithMetadata:(NSDictionary *)metadata compressQuality:(CGFloat)compressionQuality toURL:(NSURL *)url;

@end

@interface UIImage (ImageMask)

- (UIImage *)cc_imageMask;

@end