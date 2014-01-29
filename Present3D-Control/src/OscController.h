//
//  OscController.h
//  Present3D-Control
//
//  Created by Stephan Huber on 11.11.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#pragma once

#include <osGGA/Device>
#include <iostream>

class OscController : public osg::Referenced {
public:
    struct HostAndPort {
    
        std::string host;
        unsigned int port;
        HostAndPort() : host(), port() {}
        HostAndPort(const std::string& a_host, unsigned int a_port) : host(a_host), port(a_port) {}
        
        bool operator<(const HostAndPort& p) const {
            return (p.host == host) ?  port < p.port : host < p.host;
        }
        
        bool operator==(const HostAndPort& p) const {
            return (p.host == host) && (port == p.port);
        }
        
        bool valid() const { return !host.empty() && (port != 0); }
    };
    
    OscController();
    
    bool hasDevice() { return _device.valid(); }
    void addAutoDiscoveredHostAndPort(const std::string& host, unsigned int port) {
        std::cout << "registering " << host << ":" << port << std::endl;
        _hostAndPorts.insert(HostAndPort(host, port));
        if (isAutomaticDiscoveryEnabled()) checkConnection();
    }
    
    void removeAutoDiscoveredHostAndPort(const std::string& host, unsigned int port) {
        HostAndPort hap(host, port);
        std::set<HostAndPort>::iterator i = _hostAndPorts.find(hap);
        if (i != _hostAndPorts.end()) {
            std::cout << "deregistering " << host << ":" << port << std::endl;
            _hostAndPorts.erase(i);
        }
        
        if (isAutomaticDiscoveryEnabled()) checkConnection();
    }
    

        
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
    
    void enableAutomaticDiscovery(bool b) {
        _autoDiscoveryEnabled = b;
        if (b && !_hostAndPorts.empty()) {
            checkConnection();
        }
    }
    
    bool isAutomaticDiscoveryEnabled() const { return _autoDiscoveryEnabled; }
    
    void checkConnection();
    
    unsigned int getNumAutoDiscoveredHosts() { return _hostAndPorts.size(); }
    const HostAndPort& getAutoDiscoveredHostAt(unsigned int ndx) {
        std::set<HostAndPort>::const_iterator itr = _hostAndPorts.begin();
        std::advance(itr, ndx);
        return (*itr);
    }
    
    unsigned int getCurrentSelectedAutoDiscoveredHost();
    
    void connectToAutoDiscoveredHostAt(unsigned int ndx);
    
private:
    osg::ref_ptr<osgGA::Device> _device;
    std::string _host;
    unsigned int _port;
    unsigned int _numMessagesPerEvent;
    unsigned int _delay;
    bool _autoDiscoveryEnabled;
    
    std::set<HostAndPort> _hostAndPorts;
    HostAndPort _currentAutoDiscoveredHAP;
    

};
