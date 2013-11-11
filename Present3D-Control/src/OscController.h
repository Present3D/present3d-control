//
//  OscController.h
//  Present3D-Control
//
//  Created by Stephan Huber on 11.11.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#pragma once

#include <osGGA/Device>

class OscController : public osg::Referenced {
public:
    OscController();
    
    bool hasDevice() { return _device.valid(); }
    void setHostAndPort(const std::string& host, unsigned int port) { setHost(host), setPort(port); }
    void setHost(const std::string& host) { _host = host; }
    void setPort(unsigned int port) { _port = port; }
    
    const std::string& getHost() const { return _host; }
    unsigned int getPort() const { return _port; }
    
    unsigned int getNumMessagesPerEvent() const { return _numMessagesPerEvent; }
    unsigned int getDelay() const { return _delay; }
    
    void setNumMessagesPerEvent(unsigned int num) { _numMessagesPerEvent = num; }
    void setDelay(unsigned int delay) { _delay = delay; }
    
    void clear();
    void reconnect();
    
private:
    osg::ref_ptr<osgGA::Device> _device;
    std::string _host;
    unsigned int _port;
    unsigned int _numMessagesPerEvent;
    unsigned int _delay;
    

};
