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
#include <osgUtil/Optimizer> 


ReadFileThread::ReadFileThread(const std::string& file_name)
    : OpenThreads::Thread()
    , osg::Referenced()
    , _fileName(file_name)
    , _node(NULL)
{
}

osgDB::Options* ReadFileThread::createOptions(const osgDB::ReaderWriter::Options* options)
{
    osg::ref_ptr<osgDB::Options> local_options = options ? options->cloneOptions() : 0;
    if (!local_options)
    {
        local_options = osgDB::Registry::instance()->getOptions() ?
                osgDB::Registry::instance()->getOptions()->cloneOptions() :
                new osgDB::Options;
    }

    return local_options.release();
}

osg::ref_ptr<osg::Node> ReadFileThread::readHoldingSlide(const std::string& filename)
{
    std::string ext = osgDB::getFileExtension(filename);
    if (!osgDB::equalCaseInsensitive(ext,"xml") && 
        !osgDB::equalCaseInsensitive(ext,"p3d")) return 0;

    osg::ref_ptr<osgDB::ReaderWriter::Options> options = createOptions(0);
    options->setObjectCacheHint(osgDB::ReaderWriter::Options::CACHE_NONE);
    options->setOptionString("preview");

    return osgDB::readRefNodeFile(filename, options.get());
}

osg::ref_ptr<osg::Node> ReadFileThread::readPresentation(const std::string& filename,const osgDB::ReaderWriter::Options* options)
{
    std::string ext = osgDB::getFileExtension(filename);
    if (!osgDB::equalCaseInsensitive(ext,"xml") &&
        !osgDB::equalCaseInsensitive(ext,"p3d")) return 0;

    osg::ref_ptr<osgDB::Options> local_options = createOptions(options);
    local_options->setOptionString("main");

    return osgDB::readRefNodeFile(filename, local_options.get());
}

void ReadFileThread::run()
{
    _node = readHoldingSlide(_fileName);

    if (_node) {
         P3DAppInterface::instance()->setIntermediateScene(_node);
    }
    
    _node = readPresentation(_fileName, createOptions(0));
    if(!_node) {
        _node = osgDB::readNodeFile(_fileName);
    }
    
    if (_node.valid()) {
        osgUtil::Optimizer o;
        o.optimize(_node);
    }
    
    P3DAppInterface::instance()->readFinished(_node.valid(), _node, _fileName);
}