//
//  IOSUtils.h
//  cefix-iphone-particles-ios
//
//  Created by Stephan Maximilian Huber on 22.03.12.
//  Copyright (c) 2012 stephanmaximilianhuber.com. All rights reserved.
//

#pragma once

#include <string>
#include <osg/Image>

#ifdef __OBJC__
@class NSString;
@class UIImage;

#else
class UIImage;
class NSString;
#endif



class IOSUtils {
public:
    static NSString* toNSString(const std::string& str);
    static std::string toString(NSString* str);
    
    static UIImage* createFromOsgImage(osg::Image* img);
    
    static std::string getDocumentsFolder();
    
    static std::string lookupHost(const std::string& address);
    
    static bool isIphone();
    static bool isIphone5();
    static bool isIpad();
    
private:
    IOSUtils() {}
};

