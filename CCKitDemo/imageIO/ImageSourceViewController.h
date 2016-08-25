//
//  ImageSourceViewController.h
//  demo
//
//  Created by KudoCC on 16/5/16.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "BaseViewController.h"
#import "ImageIO.h"

/**
 最开始有一个GIF图片的例子，然后都是从Camera和PhotoAlbum拿图片
 图片的数据源是Camera和PhotoAlbum，从数据源中拿到UIImage和metadata
 打印出他们的值，使用CGImageSourceRef解析PNG和JPEG的图片并查看他们的属性
 */

/** PNG 对比JPEG，PNG少了许多属性，比如Orientation和{Exif}，由于PNG少了Orientation属性，所以他的图片是旋转的
2016-05-18 07:41:58.847 demo[287:26953] container property:{
    FileSize = 12222168;
}
2016-05-18 07:41:58.848 demo[287:26953] image at index 0 property:{
    ColorModel = RGB;
    Depth = 8;
    PixelHeight = 2448;
    PixelWidth = 3264;
    ProfileName = "sRGB IEC61966-2.1";
    "{PNG}" =     {
        Chromaticities =         (
                                  "0.3127",
                                  "0.329",
                                  "0.64",
                                  "0.33",
                                  "0.3",
                                  "0.6000000000000001",
                                  "0.15",
                                  "0.06"
                                  );
        Gamma = "0.45455";
        InterlaceType = 0;
        sRGBIntent = 0;
    };
}
2016-05-18 07:41:58.848 demo[287:26953] image count:1
*/

/** JPEG
 2016-05-18 07:40:46.007 demo[284:26254] container property:{
    FileSize = 1608159;
}
2016-05-18 07:40:46.008 demo[284:26254] image at index 0 property:{
    ColorModel = RGB;
    Depth = 8;
    Orientation = 6;
    PixelHeight = 2448;
    PixelWidth = 3264;
    ProfileName = "sRGB IEC61966-2.1";
    "{Exif}" =     {
        ColorSpace = 1;
        PixelXDimension = 3264;
        PixelYDimension = 2448;
    };
    "{JFIF}" =     {
        DensityUnit = 0;
        JFIFVersion =         (
                               1,
                               0,
                               1
                               );
        XDensity = 72;
        YDensity = 72;
    };
    "{TIFF}" =     {
        Orientation = 6;
    };
}
2016-05-18 07:40:46.008 demo[284:26254] image count:1
*/

@interface ImageSourceViewController : BaseViewController

@end
