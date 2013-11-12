//
//  ZeroConfDiscoverEventHandler.cpp
//  Present3D-Control
//
//  Created by Stephan Huber on 07.11.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#include "ZeroConfDiscoverEventHandler.h"
#include "P3DAppInterface.h"

#include <osgDB/ReadFile>
#include <osgGA/Device>
#include <osg/ValueObject>

#include <sstream>


ZeroConfDiscoverEventHandler::ZeroConfDiscoverEventHandler(P3DAppInterface* app)
    : osgGA::GUIEventHandler()
{
    setup(app);
}

void ZeroConfDiscoverEventHandler::setup(P3DAppInterface* app)
{
    // setup zeroconf
 
    std::vector<std::string> service_types;
    service_types.push_back(httpServiceType());
    service_types.push_back(oscServiceType());
    
    for(std::vector<std::string>::iterator i = service_types.begin(); i != service_types.end(); ++i)
    {
        osgGA::Device* device = osgDB::readFile<osgGA::Device>((*i)+".discover.zeroconf");
        if (device)
        {
            app->getViewer()->addDevice(device);
            
        }
        else
            OSG_WARN << "ZeroConfDiscoverEventHandler :: could not add zeroconf-device: " << (*i) << std::endl;
    }

}




bool ZeroConfDiscoverEventHandler::handle(osgGA::Event* event, osg::Object* object, osg::NodeVisitor* nv) {
    
    


    if ((event->getName() == "/zeroconf/service-added") || (event->getName() == "/zeroconf/service-removed"))
    {
        std::string host(""), type("");
        unsigned int port(0);
            
        event->getUserValue("host", host);
        event->getUserValue("port", port);
        event->getUserValue("type", type);
        
        if (type == httpServiceType())
        {
            std::ostringstream ss;
            ss << "http://" << host << ":" << port << "/interface.p3d";
            if (event->getName() == "/zeroconf/service-added") {
                if (!P3DAppInterface::instance()->getRemoteFiles()->add(ss.str())) {
                    OSG_WARN << "ZeroConfDiscoverEventHandler :: could not add " << ss.str() << " to remote files" << std::endl;
                }
            }
            else
            {
                if (!P3DAppInterface::instance()->getRemoteFiles()->remove(ss.str())) {
                    OSG_WARN << "ZeroConfDiscoverEventHandler :: could not remove " << ss.str() << " to remote files" << std::endl;
                }
            }
            
            P3DAppInterface::instance()->refreshInterface();
            
            return true;
        }
        else if (type == oscServiceType())
        {
            if (P3DAppInterface::instance()->getOscController()->isAutomaticDiscoveryEnabled())
            {
                if (event->getName() == "/zeroconf/service-added")
                {
                    P3DAppInterface::instance()->getOscController()->setAutoDiscoveredHostAndPort(host, port);
                    P3DAppInterface::instance()->getOscController()->reconnect();
                }
                else {
                    P3DAppInterface::instance()->getOscController()->setAutoDiscoveredHostAndPort("", 9000);
                    P3DAppInterface::instance()->getOscController()->clear();
                }
                
                P3DAppInterface::instance()->refreshInterface();
                return true;
            }
            else {
                OSG_NOTICE << "ZeroConfDiscoverEventHandler :: ignore autodiscovered osc-device: " << host << ":" << port << std::endl;
            }
        }
    }
    
    if (!event->asGUIEventAdapter()) {
        forwardEvent(*event);
        return true;
    }
    
    return osgGA::GUIEventHandler::handle(event, object, nv);
}

bool ZeroConfDiscoverEventHandler::handle(const osgGA::GUIEventAdapter& ea, osgGA::GUIActionAdapter& aa, osg::Object*, osg::NodeVisitor*)
{
    // forward all key + user-events to devices
    if ((ea.getEventType() == osgGA::GUIEventAdapter::KEYDOWN) ||
        (ea.getEventType() == osgGA::GUIEventAdapter::KEYUP) ||
        (ea.getEventType() == osgGA::GUIEventAdapter::USER))
    {
        forwardEvent(ea);
    }
    return false;
}

void ZeroConfDiscoverEventHandler::forwardEvent(const osgGA::Event& event) {
    
    osgViewer::Viewer* viewer = P3DAppInterface::instance()->getViewer();
    
    for(osgViewer::View::Devices::iterator i = viewer->getDevices().begin(); i != viewer->getDevices().end(); ++i)
    {
        if ((*i)->getCapabilities() & osgGA::Device::SEND_EVENTS)
            (*i)->sendEvent(event);
    }
}