//
//  ReadFileThread.cpp
//  Present3D-Control
//
//  Created by Stephan Huber on 16.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#include "ReadFileThread.h"
#include "P3DAppInterface.h"


ReadFileThread::ReadFileThread(const std::string& file_name)
    : OpenThreads::Thread()
    , osg::Referenced()
    , _fileName(file_name)
    , _node(NULL)
{
}


void ReadFileThread::run()
{
    OpenThreads::Thread::microSleep(3 * 1000 * 1000);
    
    P3DAppInterface::instance()->readFinished(false, _node, _fileName);
}