//
//  ViewController.h
//  ImageMask
//
//  Created by KudoCC on 16/1/7.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "HomeTableViewController.h"

// Core Graphics framework
// Image I/O framework
// Core Image framework
// vImage framework


/*
 Image I/O
 
 The preferred way to read and write image data is to use the Image I/O framework, which is available in iOS 4 and Mac OS X 10.4 and later. See Image I/O Programming Guide for more information on the CGImageSourceRef and CGImageDestinationRef opaque data types. Image sources and destinations not only offer access to image data, but also provide better support for accessing image metadata.
 */


/*
 vImage
 
 For the best performance when working with raw image data, use the vImage framework. You can import image data to vImage from a CGImageRef reference with the vImageBuffer_InitWithCGImage function. For details, see Accelerate Release Notes
 */
@interface Quartz2DViewController : HomeTableViewController

@end

