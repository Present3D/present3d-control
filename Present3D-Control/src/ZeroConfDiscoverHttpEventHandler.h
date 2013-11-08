//
//  ZeroConfDiscoverHttpEventHandler.h
//  Present3D-Control
//
//  Created by Stephan Huber on 07.11.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#pragma once
#include <osgGA/GUIEventHandler>

class ZeroConfDiscoverHttpEventHandler : public osgGA::GUIEventHandler {
public:
    ZeroConfDiscoverHttpEventHandler(): osgGA::GUIEventHandler() {}
    
    virtual bool handle(const osgGA::GUIEventAdapter& ea, osgGA::GUIActionAdapter& aa, osg::Object*, osg::NodeVisitor*);

};
