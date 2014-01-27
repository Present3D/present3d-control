//
//  IOSUtils.cpp
//  cefix-iphone-particles-ios
//
//  Created by Stephan Maximilian Huber on 22.03.12.
//  Copyright (c) 2012 stephanmaximilianhuber.com. All rights reserved.
//

#include "IOSUtils.h"
#include <sys/socket.h>
#include <netdb.h>


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

std::string convertCFString( CFStringRef str )
{
        char buffer[4096];
        bool worked = CFStringGetCString( str, buffer, 4095, kCFStringEncodingUTF8 );
        if( worked ) {
                std::string result( buffer );
                return result;
        }
        else
                return std::string();
}


std::string IOSUtils::lookupHost(const std::string& address) {

    std::string result_str = address;
    struct addrinfo *result = NULL;
    struct addrinfo hints;

    memset(&hints, 0, sizeof(hints));
    hints.ai_flags = AI_NUMERICHOST;
    hints.ai_family = PF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = 0;

    int errorStatus = getaddrinfo(address.c_str(), NULL, &hints, &result);
    if (errorStatus == 0)
    {
        CFDataRef addressRef = CFDataCreate(NULL, (UInt8 *)result->ai_addr, result->ai_addrlen);
        if (addressRef != nil)
        {
            CFHostRef hostRef = CFHostCreateWithAddress(kCFAllocatorDefault, addressRef);
            BOOL succeeded = CFHostStartInfoResolution(hostRef, kCFHostNames, NULL);
            if (succeeded)
            {
                CFArrayRef hostnamesRef = CFHostGetNames(hostRef, NULL);
                if (hostnamesRef && (CFArrayGetCount(hostnamesRef) > 0))
                {
                        CFStringRef first_hostname = (CFStringRef)CFArrayGetValueAtIndex(hostnamesRef, 0);
                    
                        result_str = convertCFString(first_hostname);
                        //CFRelease(first_hostname);
                }
                // CFRelease(hostnamesRef);
            }
            CFRelease(hostRef);

        }
        CFRelease(addressRef);

    }
    freeaddrinfo(result);
    
    return result_str;
    
}