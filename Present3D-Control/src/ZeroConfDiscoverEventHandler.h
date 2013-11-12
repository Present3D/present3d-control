//
//  ZeroConfDiscoverEventHandler.h
//  Present3D-Control
//
//  Created by Stephan Huber on 07.11.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#pragma once

#include <osgGA/GUIEventHandler>

class P3DAppInterface;

class ZeroConfDiscoverEventHandler : public osgGA::GUIEventHandler {
public:
    ZeroConfDiscoverEventHandler(P3DAppInterface* app);
    
    virtual bool handle(osgGA::Event* event, osg::Object* object, osg::NodeVisitor* nv);
    virtual bool handle(const osgGA::GUIEventAdapter& ea, osgGA::GUIActionAdapter& aa, osg::Object*, osg::NodeVisitor*);

private:
    void setup(P3DAppInterface* app);
    void forwardEvent(const osgGA::Event& event);
    
    static const char* httpServiceType() { return "_p3d_http._tcp"; }
    static const char* oscServiceType() { return "_p3d_osc._udp"; }

};
