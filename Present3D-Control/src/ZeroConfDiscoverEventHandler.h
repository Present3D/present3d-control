//
//  ZeroConfDiscoverEventHandler.h
//  Present3D-Control
//
//  Created by Stephan Huber on 07.11.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#pragma once

#include <osgGA/EventHandler>

class P3DAppInterface;

class ZeroConfDiscoverEventHandler : public osgGA::EventHandler {
public:
    ZeroConfDiscoverEventHandler(P3DAppInterface* app);
    
    virtual bool handle(osgGA::Event* event, osg::Object* object, osg::NodeVisitor* nv);
    
private:
    void setup(P3DAppInterface* app);;
    
    static const char* httpServiceType() { return "_p3d_http._tcp"; }
    static const char* oscServiceType() { return "_p3d_osc._udp"; }

};
