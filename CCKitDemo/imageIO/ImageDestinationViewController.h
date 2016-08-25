//
//  ImageDestinationViewController.h
//  demo
//
//  Created by KudoCC on 16/5/16.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "BaseViewController.h"
#import "ImageIO.h"

/* PNG without metadata，图片是翻转的，顺时针翻转了90度

2016-05-17 17:52:54.275 demo[1027:182023] imagePickerController:didFinishPickingMediaWithInfo:, {
    UIImagePickerControllerMediaMetadata =     {
        DPIHeight = 72;
        DPIWidth = 72;
        Orientation = 6;
        "{Exif}" =         {
            ApertureValue = "2.27500704749987";
            BrightnessValue = "3.330792046005048";
            ColorSpace = 1;
            DateTimeDigitized = "2016:05:17 17:52:53";
            DateTimeOriginal = "2016:05:17 17:52:53";
            ExposureBiasValue = 0;
            ExposureMode = 0;
            ExposureProgram = 2;
            ExposureTime = "0.0303030303030303";
            FNumber = "2.2";
            Flash = 24;
            FocalLenIn35mmFilm = 29;
            FocalLength = "4.15";
            ISOSpeedRatings =             (
                                           50
                                           );
            LensMake = Apple;
            LensModel = "iPhone 6 back camera 4.15mm f/2.2";
            LensSpecification =             (
                                             "4.15",
                                             "4.15",
                                             "2.2",
                                             "2.2"
                                             );
            MeteringMode = 5;
            PixelXDimension = 3264;
            PixelYDimension = 2448;
            SceneType = 1;
            SensingMethod = 2;
            ShutterSpeedValue = "5.060000179460458";
            SubjectArea =             (
                                       1631,
                                       1223,
                                       1795,
                                       1077
                                       );
            SubsecTimeDigitized = 300;
            SubsecTimeOriginal = 300;
            WhiteBalance = 0;
        };
        "{MakerApple}" =         {
            1 = 4;
            14 = 0;
            2 = <0f001000 1100c800 13001300 2a003300 11001600 dc001000 30004c00 2e003800 10001100 1300de00 15001500 2a003700 13001600 f1000d00 2d004a00 20002a00 11001300 1400f500 18001700 17002300 14001400 fe000c00 2b004200 2c003200 12001400 17001401 19001900 18001700 16001600 08010d00 2b004900 2c002900 14001500 19003701 3e002100 1b001a00 18001800 1b010e00 2b004100 1e002f00 15001700 2b007301 ed006e00 25003000 4b002100 2f011200 2b004c00 2f002800 18001900 2a009801 f2001501 b8009300 d9009800 3f011800 2b004b00 22002f00 1e001b00 3100a301 13011101 0601dc00 f500e100 63011f00 2b004d00 2d002a00 25002200 3500a201 c800cc00 be00b300 b600aa00 74012900 2b005400 25003000 2a002c00 4000a401 17011c01 0901ea00 0301f000 70013300 2b005100 2e003100 33002500 4800ac01 49014c01 36011101 43011301 60013a00 2a005b00 34003700 33002f00 69009b01 0f011b01 0e01f300 0e01f200 3e014000 2a005700 24003300 2b003b00 54008d01 23011c01 0701f800 1801f100 23014700 29006300 37003700 2e003f00 40006301 e700f700 f700d200 f500d300 fd004d00 29006600 24003400 23002e00 2e002a01 93008d00 7e007700 68005a00 da005100 2a006700 35003400 75009800 bf005f01 ff002901 2d017201 77017901 97015400 29006f00 2a003100>;
            20 = 4;
            3 =             {
                epoch = 0;
                flags = 1;
                timescale = 1000000000;
                value = 32212996910958;
            };
            4 = 1;
            5 = 128;
            6 = 133;
            7 = 1;
            8 =             (
                             "-0.01560388",
                             "-0.7891992",
                             "-0.6109641"
                             );
            9 = 275;
        };
        "{TIFF}" =         {
            DateTime = "2016:05:17 17:52:53";
            Make = Apple;
            Model = "iPhone 6";
            ResolutionUnit = 2;
            Software = "9.3.1";
            XResolution = 72;
            YResolution = 72;
        };
    };
    UIImagePickerControllerMediaType = "public.image";
    UIImagePickerControllerOriginalImage = "<UIImage: 0x145837eb0> size {2448, 3264} orientation 3 scale 1.000000";
}
2016-05-17 17:52:57.546 demo[1027:182023] container property:{
    FileSize = 10212920;
}
2016-05-17 17:52:57.549 demo[1027:182023] image at index 0 property:{
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
    };
}
*/

/*
 
 PNG with metadata
 2016-05-17 17:47:15.698 demo[1022:179984] imagePickerController:didFinishPickingMediaWithInfo:, {
    UIImagePickerControllerMediaMetadata =     {
        DPIHeight = 72;
        DPIWidth = 72;
        FaceRegions =         {
            Regions =             {
                HeightAppliedTo = 2448;
                RegionList =                 (
                                              {
                                                  AngleInfoRoll = 270;
                                                  AngleInfoYaw = 0;
                                                  ConfidenceLevel = 99;
                                                  FaceID = 1;
                                                  Height = "0.058";
                                                  Timestamp = 763642368654;
                                                  Type = Face;
                                                  Width = "0.04399999999999998";
                                                  X = "0.151";
                                                  Y = "0.034";
                                              }
                                              );
                WidthAppliedTo = 3264;
            };
        };
        Orientation = 6;
        "{Exif}" =         {
            ApertureValue = "2.27500704749987";
            BrightnessValue = "2.708469997319947";
            ColorSpace = 1;
            DateTimeDigitized = "2016:05:17 17:46:18";
            DateTimeOriginal = "2016:05:17 17:46:18";
            ExposureBiasValue = 0;
            ExposureMode = 0;
            ExposureProgram = 2;
            ExposureTime = "0.0303030303030303";
            FNumber = "2.2";
            Flash = 24;
            FocalLenIn35mmFilm = 29;
            FocalLength = "4.15";
            ISOSpeedRatings =             (
                                           125
                                           );
            LensMake = Apple;
            LensModel = "iPhone 6 back camera 4.15mm f/2.2";
            LensSpecification =             (
                                             "4.15",
                                             "4.15",
                                             "2.2",
                                             "2.2"
                                             );
            MeteringMode = 5;
            PixelXDimension = 3264;
            PixelYDimension = 2448;
            SceneType = 1;
            SensingMethod = 2;
            ShutterSpeedValue = "5.060000179460458";
            SubjectArea =             (
                                       490,
                                       75,
                                       127,
                                       127
                                       );
            SubsecTimeDigitized = 913;
            SubsecTimeOriginal = 913;
            WhiteBalance = 0;
        };
        "{MakerApple}" =         {
            1 = 4;
            14 = 0;
            2 = <b3008e00 80004c00 0701fe00 ed001401 94018f01 e0014102 25014601 e8009301 c200c600 d3005e00 1a011e01 11010e01 47016c01 c6010d02 16025602 8a01b401 6f018501 d9006100 3d005400 37002e00 43006b00 9201a601 8b01b201 6c01ab01 ab019d00 29002600 28003e00 5a006200 4b006900 26012d01 5901a201 8a01a901 4a013900 2b002f00 48005d00 9900b800 85004200 70007e00 64016101 e9009c01 d2002b00 33003900 0c013601 59016501 de003200 8d007800 3001c601 cc01b701 ab003100 4a004900 4a015801 5b016201 f9008100 b102a402 1902d301 0b02f601 90002d00 35003f00 66015201 53015701 0e01b700 a102db02 a802b101 0802fe01 7f002800 32003900 52014801 40011f01 f2006500 41025b02 5202a201 ed01e101 85002300 33002900 72006f00 5d005500 52004900 3e00ec00 6002c401 cd01c501 94002e00 37003800 38003b00 3b003600 35003a00 3c007200 8f016701 bc01b501 a700a100 73006800 65006000 65005d00 57005500 6800ec00 4a016001 af018d01 ac00ba00 b400c800 8b008b00 89007300 63004000 8500f700 58012101 57012501 a700a500 8f009d00 93008600 7c007600 6f006e00 43008a00 f100ac00 02012801 a7008000 39002600 70006c00 63007200 a2006600 4a003900 c800a400 ca00ec00 d8007900 38002c00 6a006800 61000501 ad003a00 3b003f00 23015800 35006900>;
            20 = 4;
            3 =             {
                epoch = 0;
                flags = 1;
                timescale = 1000000000;
                value = 31818598786458;
            };
            4 = 0;
            5 = 200;
            6 = 205;
            7 = 1;
            8 =             (
                             "0.030963",
                             "-0.9689508",
                             "-0.2280504"
                             );
            9 = 275;
        };
        "{TIFF}" =         {
            DateTime = "2016:05:17 17:46:18";
            Make = Apple;
            Model = "iPhone 6";
            ResolutionUnit = 2;
            Software = "9.3.1";
            XResolution = 72;
            YResolution = 72;
        };
    };
    UIImagePickerControllerMediaType = "public.image";
    UIImagePickerControllerOriginalImage = "<UIImage: 0x14701b110> size {2448, 3264} orientation 3 scale 1.000000";
}
2016-05-17 17:47:27.229 demo[1022:179984] container property:{
    FileSize = 8166737;
}
2016-05-17 17:47:27.243 demo[1022:179984] image at index 0 property:{
    ColorModel = RGB;
    DPIHeight = 72;
    DPIWidth = 72;
    Depth = 8;
    PixelHeight = 3264;
    PixelWidth = 2448;
    ProfileName = "sRGB IEC61966-2.1";
    "{Exif}" =     {
        ApertureValue = "2.275007124536905";
        BrightnessValue = "2.708470124753775";
        ColorSpace = 1;
        DateTimeDigitized = "2016:05:17 17:46:18";
        DateTimeOriginal = "2016:05:17 17:46:18";
        ExposureBiasValue = 0;
        ExposureMode = 0;
        ExposureProgram = 2;
        ExposureTime = "0.0303030303030303";
        FNumber = "2.2";
        Flash = 24;
        FocalLenIn35mmFilm = 29;
        FocalLength = "4.15";
        ISOSpeedRatings =         (
                                   125
                                   );
        LensMake = Apple;
        LensModel = "iPhone 6 back camera 4.15mm f/2.2";
        LensSpecification =         (
                                     "4.15",
                                     "4.15",
                                     "2.2",
                                     "2.2"
                                     );
        MeteringMode = 5;
        PixelXDimension = 3264;
        PixelYDimension = 2448;
        SceneType = 1;
        SensingMethod = 2;
        ShutterSpeedValue = "5.06";
        SubjectArea =         (
                               490,
                               75,
                               127,
                               127
                               );
        SubsecTimeDigitized = 913;
        SubsecTimeOriginal = 913;
        WhiteBalance = 0;
    };
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
        Software = "9.3.1";
        XPixelsPerMeter = 2835;
        YPixelsPerMeter = 2835;
    };
    "{TIFF}" =     {
        DateTime = "2016:05:17 17:46:18";
        Make = Apple;
        Model = "iPhone 6";
        ResolutionUnit = 2;
        Software = "9.3.1";
        XResolution = 72;
        YResolution = 72;
    };
}
*/

/** JPEG without metadata，直接使用函数UIImageJPEGRepresentation将UIImage转换成JPEG，就拿到了orientation的值
2016-05-18 07:13:04.021 demo[268:18798] container property:{
    FileSize = 1289430;
}
2016-05-18 07:13:04.022 demo[268:18798] image at index 0 property:{
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
*/

/**
 图片的数据源是Camera和PhotoAlbum，从数据源中拿到UIImage和metadata
 1.将图片转换成PNG或JPEG格式，写入到文件中并保持其metadata，注意：PNG文件没有orientation属性，而我们使用图片时默认值为UP(比如[UIImage imageWithCGImage:]或者[UIImage imageWithData:])，如果写入PNG图片的时候不根据UIImage的imageOrientation指定CGImageDestinationAddImageFromSource的kCGImagePropertyOrientation属性，那么可能会导致图片翻转（除非照片本身的orientation就是UIImageOrientationUp），那么为什么PNG图片没有orientation属性还能让他保持正常呢，主要是写入的时候会根据传入的kCGImagePropertyOrientation直接对图片进行翻转；
 不同于PNG，JPEG格式的文件，使用UIImageJPEGRepresentation转换拿到的NSData就包含一些Exif和Orientation的信息，即使在写入文件时不传入metadata，它的方向也是对的
 2.将UIImage写回到相册中，并保持其metadata
 */

@interface ImageDestinationViewController : BaseViewController

@end
