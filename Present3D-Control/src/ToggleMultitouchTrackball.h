//
//  ToggleMultitouchTrackball.h
//  Present3D-Control
//
//  Created by Stephan Huber on 05.11.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#pragma once

#include <osgGA/MultiTouchTrackballManipulator>


class ToggleMultiTouchTrackball : public osgGA::MultiTouchTrackballManipulator {
public:
    ToggleMultiTouchTrackball() : osgGA::MultiTouchTrackballManipulator(), _enabled(true){}
    
    void setEnabled(bool b) { _enabled = b; }
    
    virtual bool handle(const osgGA::GUIEventAdapter& ea, osgGA::GUIActionAdapter& aa)
    {
        if (!_enabled && ((ea.getEventType() == osgGA::GUIEventAdapter::PUSH)
            || (ea.getEventType() == osgGA::GUIEventAdapter::DRAG)
            || (ea.getEventType() == osgGA::GUIEventAdapter::RELEASE)))
            
            return false;
        
        return osgGA::TrackballManipulator::handle(ea, aa);
    }
    
private:
    bool _enabled;
};