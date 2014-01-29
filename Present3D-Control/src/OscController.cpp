    //
//  OscController.cpp
//  Present3D-Control
//
//  Created by Stephan Huber on 11.11.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#include "OscController.h"
#include "P3DAppInterface.h"

#include <sstream>

#include <osgDB/ReadFile>



OscController::OscController()
    : osg::Referenced()
    , _device(NULL)
    , _host("")
    , _port(9000)
    , _numMessagesPerEvent(3)
    , _delay(10)
    , _autoDiscoveryEnabled(true)
    , _hostAndPorts()
    , _currentAutoDiscoveredHAP()
{
}

void OscController::clear()
{
    _device = NULL;

    osg::ref_ptr<osgViewer::Viewer> viewer = P3DAppInterface::instance()->getViewer();

    osgViewer::View::Devices devices = viewer->getDevices();
    std::vector<osgGA::Device*> to_delete;

    
    for(osgViewer::View::Devices::iterator i = devices.begin(); i != devices.end(); ++i) {
        osgGA::Device* device(*i);
        std::string class_name(device->className());
        if (class_name.find("OSC") != std::string::npos) {
            to_delete.push_back(device);
        }
    }
    
    for(std::vector<osgGA::Device*>::iterator j = to_delete.begin(); j != to_delete.end(); ++j) {
        viewer->removeDevice(*j);
    }
}

void OscController::reconnect()
{
    if (_host.empty() || (_port == 0))
        return;
        
    clear();
    
    std::ostringstream ss, options_ss;
    ss << _host << ":" << _port << ".sender.osc";
    
    options_ss << "numMessagesPerEvent=" << _numMessagesPerEvent << " delayBetweenSendsInMillisecs=" << _delay << std::endl;
    
    osg::ref_ptr<osgDB::Options> options = new osgDB::Options(options_ss.str());
    _device = osgDB::readFile<osgGA::Device>(ss.str(), options);
    if(!_device) {
        OSG_WARN << "could not open device: " << ss.str() << std::endl;
    }
    else {
        P3DAppInterface::instance()->getViewer()->addDevice(_device);
        OSG_ALWAYS << "added osc-device: " << ss.str() << " (" << options_ss.str() << ")" << std::endl;
    }
}


void OscController::checkConnection()
{
    if (!isAutomaticDiscoveryEnabled())
        return;
    
    unsigned int num_haps = _hostAndPorts.size();
    
    // clear any connection, autodiscovered available
    if(num_haps == 0) {
        std::cout << "clearing connections" << std::endl;
        _currentAutoDiscoveredHAP = HostAndPort();
        clear();
        setHostAndPort("", 9000);
        return;
    }
    
    // no connection till now, start a new one
    if (!_currentAutoDiscoveredHAP.valid()) {
        _currentAutoDiscoveredHAP = *_hostAndPorts.begin();
        std::cout << "new connection to " << _currentAutoDiscoveredHAP.host << ":" << _currentAutoDiscoveredHAP.port << std::endl;
        
        setHostAndPort(_currentAutoDiscoveredHAP.host, _currentAutoDiscoveredHAP.port);
        reconnect();
        return;
    }
    
    // see, if our current connection is still available
    bool found = false;
    for(std::set<HostAndPort>::iterator i = _hostAndPorts.begin(); (i != _hostAndPorts.end()) && !found; ++i)
    {
        if ((*i) == _currentAutoDiscoveredHAP) {
            found = true;
        }
    }
    
    // our previous connection is not available anymore, reset and take the first valid.
    if (!found) {
        std::cout << "connection to " << _currentAutoDiscoveredHAP.host << ":" << _currentAutoDiscoveredHAP.port << " not valid anymore" << std::endl;

        _currentAutoDiscoveredHAP = HostAndPort();
        clear();
        checkConnection();
    }
}


unsigned int OscController::getCurrentSelectedAutoDiscoveredHost()
{
    unsigned int ndx(0);
    for(std::set<HostAndPort>::iterator i = _hostAndPorts.begin(); i != _hostAndPorts.end(); ++i, ndx++) {
        if (*i == _currentAutoDiscoveredHAP)
            return ndx;
    }
    
    return 0;
}


void OscController::connectToAutoDiscoveredHostAt(unsigned int ndx)
{
    _currentAutoDiscoveredHAP = getAutoDiscoveredHostAt(ndx);
    setHostAndPort(_currentAutoDiscoveredHAP.host, _currentAutoDiscoveredHAP.port);
    reconnect();
}