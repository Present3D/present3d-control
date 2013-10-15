//
//  P3DAppInterface.cpp
//  Present3D-Control
//
//  Created by Stephan Huber on 15.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#include "P3DAppInterface.h"
#include <osg/ref_ptr>
#include <osgDB/FileUtils>
#include <osgDB/FileNameUtils>



class LocalFileCollection : public P3DAppInterface::FileCollection {
public:
    LocalFileCollection() : FileCollection(P3DAppInterface::LOCAL) {}
    
    virtual void collect()
    {
        _files.clear();
        osg::ref_ptr<P3DAppInterface> app = P3DAppInterface::instance();
        
        for(FilesVector::iterator i = _localFilePaths.begin(); i != _localFilePaths.end(); ++i)
        {
            osgDB::DirectoryContents contents = osgDB::getDirectoryContents(*i);
            for(osgDB::DirectoryContents::iterator j = contents.begin(); j != contents.end(); ++j)
            {
                std::string full_file_path = (*i) + "/" + (*j);
                if ((osgDB::fileType(full_file_path) == osgDB::REGULAR_FILE) && app->fileTypeSupported(osgDB::getFileExtension(full_file_path)))
                {
                    _files.push_back(full_file_path);
                }
            }
        }
    }
    
    virtual void loadAt(unsigned int ndx) {
        std::cout << "loading local file from " << _files[ndx] << std::endl;
    }

    
    void addLocalFilePath(const std::string& file_path) { _localFilePaths.push_back(file_path); }


private:
    FilesVector _localFilePaths;
};


class RemoteFileCollection : public P3DAppInterface::FileCollection {
public:
    RemoteFileCollection() : P3DAppInterface::FileCollection(P3DAppInterface::REMOTE) {}
    
    virtual void loadAt(unsigned int ndx) {
        std::cout << "loading remote file from " << _files[ndx] << std::endl;
    }
    
    virtual void collect()
    {
        _files.clear();
    }

};


P3DAppInterface::P3DAppInterface()
    : osg::Referenced()
{
    addSupportedFileType("osgt");
    addSupportedFileType("osgb");
    addSupportedFileType("p3d");
    
    _files[LOCAL] = new LocalFileCollection();
    _files[REMOTE] = new RemoteFileCollection();
    
    
}


P3DAppInterface* P3DAppInterface::instance()
{
    static osg::ref_ptr<P3DAppInterface> s_ptr = new P3DAppInterface();
    return s_ptr.get();
}

bool P3DAppInterface::fileTypeSupported(const std::string& file_extension)
{
    SupportedFileTypesSet::iterator i = _supportedFileTypes.find(file_extension);
    return (i != _supportedFileTypes.end());
}


void P3DAppInterface::addLocalFilePath(const std::string& path)
{
    LocalFileCollection* fc = dynamic_cast<LocalFileCollection*>(getFiles(LOCAL));
    if (fc)
        fc->addLocalFilePath(path);
}




