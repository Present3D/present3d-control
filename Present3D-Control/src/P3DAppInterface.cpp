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



class LocalFileCollection : public FileCollection {
public:
    LocalFileCollection() : FileCollection(LOCAL) {}
    
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
        P3DAppInterface::instance()->readFile(_files[ndx]);;
    }

    
    void addLocalFilePath(const std::string& file_path) { _localFilePaths.push_back(file_path); }


private:
    FilesVector _localFilePaths;
};


class RemoteFileCollection : public FileCollection {
public:
    RemoteFileCollection()
        : FileCollection(REMOTE)
    {
    }
    
    virtual void loadAt(unsigned int ndx) {
        P3DAppInterface::instance()->readFile(_files[ndx]);;
    }
    
    virtual std::string getDetailedAt(unsigned int ndx) { return osgDB::getServerAddress(_files[ndx]); }
    
    virtual void collect()
    {
        _files.clear();
        _files.push_back("http://192.168.1.1/test_presentation.p3d");
        _files.push_back("http://svn.openscenegraph.org/osg/OpenSceneGraph-Data/trunk/cow.osgt");
    }

};


P3DAppInterface::P3DAppInterface()
    : osg::Referenced()
    , _sceneNode(NULL)
{
    addSupportedFileType("osgt");
    addSupportedFileType("osgb");
    addSupportedFileType("p3d");
    
    _files[FileCollection::LOCAL] = new LocalFileCollection();
    _files[FileCollection::REMOTE] = new RemoteFileCollection();
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
    LocalFileCollection* fc = dynamic_cast<LocalFileCollection*>(getFiles(FileCollection::LOCAL));
    if (fc)
        fc->addLocalFilePath(path);
}

void P3DAppInterface::readFile(const std::string& file_name)
{
    std::cout << "read file: " << file_name << std::endl;
    
    _readFileThread = new ReadFileThread(file_name);
    _readFileThread->start();
}

void P3DAppInterface::readFinished(bool success, osg::Node* node, const std::string& file_name)
{
    std::cout << "finished with file: " << _readFileThread->getFileName() << std::endl;
    _sceneNode = node;
    if (_readFileCompleteHandler) {
        _readFileCompleteHandler->operator()(success, node, file_name);
    }
}


void P3DAppInterface::applySceneData()
{
    _readFileThread = NULL;
    std::cout << "applying scene data" << std::endl;
}

