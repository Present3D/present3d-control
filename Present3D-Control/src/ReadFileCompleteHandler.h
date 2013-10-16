//
//  ReadFileCompleteHandler.h
//  Present3D-Control
//
//  Created by Stephan Huber on 16.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#pragma once

#include <osg/Referenced>
#include <osg/Node>


class ReadFileCompleteHandler : public osg::Referenced {

public:
    ReadFileCompleteHandler() : osg::Referenced() {}
    
    virtual void operator()(bool read_successful, osg::Node* node) = 0;
};