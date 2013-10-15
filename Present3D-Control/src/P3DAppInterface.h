//
//  P3DAppInterface.h
//  Present3D-Control
//
//  Created by Stephan Huber on 15.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#pragma once

#include <vector>
#include <map>
#include <set>
#include <string>
#include <osg/Referenced>
#include <osg/ref_ptr>
#include <osgDB/FileNameUtils>

class P3DAppInterface : public osg::Referenced {
public:
    
    enum FileCollectionType {
        LOCAL,
        REMOTE
    };
    
    class FileCollection : public osg::Referenced {
    public:
        typedef std::vector<std::string> FilesVector;

        FileCollection(FileCollectionType type) : osg::Referenced(), _type(type) {}
        unsigned int getNumFiles() const { return _files.size(); }
        
        virtual void collect() = 0;
        virtual void loadAt(unsigned int ndx) = 0;
        virtual std::string getSimpleNameAt(unsigned int ndx) { return osgDB::getSimpleFileName(_files[ndx]); }
        virtual std::string getDetailedAt(unsigned int ndx) { return ""; }
        
    protected:
        
        FileCollectionType _type;
        FilesVector _files;
    };
    
    typedef std::set<std::string> SupportedFileTypesSet;
    typedef std::map<FileCollectionType, osg::ref_ptr<FileCollection> > FilesMap;
    P3DAppInterface();
    
    static P3DAppInterface* instance();
    
    FileCollection* getFiles(FileCollectionType type) {
        FilesMap::iterator i = _files.find(type);
        return i != _files.end() ? i->second.get() : NULL;
    }
    
    FileCollection* getLocalFiles() { return getFiles(LOCAL); }
    FileCollection* getRemoteFiles() { return getFiles(REMOTE); }

    
    void addSupportedFileType(const std::string& file_type) { _supportedFileTypes.insert(file_type); }
    void addLocalFilePath(const std::string& path);

private:
    bool fileTypeSupported(const std::string& file_extension);
    
    FilesMap _files;
    SupportedFileTypesSet _supportedFileTypes;
    
    friend class LocalFileCollection;
    friend class RemoteFileCollection;
};
