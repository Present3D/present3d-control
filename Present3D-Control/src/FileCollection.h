//
//  FileCollection.h
//  Present3D-Control
//
//  Created by Stephan Huber on 16.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#pragma once

#include <vector>
#include <osg/Referenced>
#include <osgDB/FileNameUtils>


class FileCollection : public osg::Referenced {

public:
    typedef std::vector<std::string> FilesVector;
    enum Type {
        LOCAL,
        REMOTE
    };


    FileCollection(Type type) : osg::Referenced(), _type(type) {}
    unsigned int getNumFiles() const { return _files.size(); }
    
    virtual void collect() = 0;
    virtual void loadAt(unsigned int ndx) = 0;
    virtual std::string getSimpleNameAt(unsigned int ndx) { return osgDB::getSimpleFileName(_files[ndx]); }
    virtual std::string getDetailedAt(unsigned int ndx) { return ""; }
    
protected:
    
    Type _type;
    FilesVector _files;
};