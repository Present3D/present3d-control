//
//  ReadFileThread.cpp
//  Present3D-Control
//
//  Created by Stephan Huber on 16.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#include "ReadFileThread.h"
#include "P3DAppInterface.h"
#include <osgDB/ReadFile>


ReadFileThread::ReadFileThread(const std::string& file_name)
    : OpenThreads::Thread()
    , osg::Referenced()
    , _fileName(file_name)
    , _node(NULL)
{
}


void ReadFileThread::run()
{
    _node = osgDB::readNodeFile(_fileName);
    
    P3DAppInterface::instance()->readFinished(_node.valid(), _node, _fileName);
}