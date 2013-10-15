//
//  IOSUtils.cpp
//  cefix-iphone-particles-ios
//
//  Created by Stephan Maximilian Huber on 22.03.12.
//  Copyright (c) 2012 stephanmaximilianhuber.com. All rights reserved.
//

#include "IOSUtils.h"


NSString* IOSUtils::toNSString(const std::string& str)
{
    return [NSString stringWithUTF8String: str.c_str()];
}



std::string IOSUtils::toString(NSString* str)
{
    return str ? std::string([str UTF8String]) : "";
}


UIImage* IOSUtils::createFromOsgImage(osg::Image* img) {
    
    unsigned int bpp = img->getPixelSizeInBits();
    NSInteger length = img->s() * img->t() * bpp / 8;
    GLubyte *buffer = (GLubyte*)malloc(length);
    memcpy(buffer, img->data(), length);
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, length, NULL);
    int bitsPerComponent = 8;
    int bytesPerRow = bpp / 8 * img->s();
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    if (bpp == 32)
        bitmapInfo |= kCGImageAlphaLast;

    // create the CGImage and then the UIImage
    CGImageRef imageRef = CGImageCreate(img->s(), img->t(), bitsPerComponent, bpp, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}


std::string IOSUtils::getDocumentsFolder() {
    NSString* doc_folder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return toString(doc_folder);
}
