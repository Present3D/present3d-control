//
//  ReadFileThread.h
//  Present3D-Control
//
//  Created by Stephan Huber on 16.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#pragma once

#include <string>
#include <OpenThreads/Thread>
#include <osg/Referenced>
#include <osg/Node>
#include <osgDB/ReaderWriter>

#include "ReadFileCompleteHandler.h"

class ReadFileThread : public OpenThreads::Thread, public osg::Referenced {
public:
    ReadFileThread(const std::string& file_name);
    
    const std::string& getFileName() { return _fileName; }
    
    virtual void run();
    
private:
    osgDB::Options* createOptions(const osgDB::ReaderWriter::Options* options);

    osg::ref_ptr<osg::Node> readHoldingSlide(const std::string& filename);
    osg::ref_ptr<osg::Node> readPresentation(const std::string& filename,const osgDB::ReaderWriter::Options* options);
    
    std::string _fileName;
    osg::ref_ptr<osg::Node> _node;

};