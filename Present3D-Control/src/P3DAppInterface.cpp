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
#include <osgUtil/Optimizer>
#include <osgViewer/api/IOS/GraphicsWindowIOS>
#include <osgGA/MultiTouchTrackballManipulator>
#include <osgDB/ReadFile>

#include "ZeroConfDiscoverEventHandler.h"

USE_GRAPICSWINDOW_IMPLEMENTATION(IOS)

USE_OSGPLUGIN(imageio)
USE_OSGPLUGIN(rgb)
USE_OSGPLUGIN(osc)
USE_OSGPLUGIN(zeroconf)
USE_OSGPLUGIN(p3d)
USE_OSGPLUGIN(curl)
USE_OSGPLUGIN(osg)
USE_OSGPLUGIN(osg2)
USE_OSGPLUGIN(freetype)

USE_SERIALIZER_WRAPPER_LIBRARY(osg)
USE_SERIALIZER_WRAPPER_LIBRARY(osgAnimation)
USE_SERIALIZER_WRAPPER_LIBRARY(osgFX)
USE_SERIALIZER_WRAPPER_LIBRARY(osgManipulator)
USE_SERIALIZER_WRAPPER_LIBRARY(osgParticle)
USE_SERIALIZER_WRAPPER_LIBRARY(osgSim)
USE_SERIALIZER_WRAPPER_LIBRARY(osgText)

USE_SERIALIZER_WRAPPER_LIBRARY(osgTerrain)
USE_SERIALIZER_WRAPPER_LIBRARY(osgShadow)
USE_SERIALIZER_WRAPPER_LIBRARY(osgVolume)



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
        //_files.push_back("http://quincy.local/gsc_ipad/interface.p3d");
        //_files.push_back("http://svn.openscenegraph.org/osg/OpenSceneGraph-Data/trunk/cow.osgt");
        for(FilesVector::iterator i = _discoveredFiles.begin(); i != _discoveredFiles.end(); ++i) {
            _files.push_back(*i);
        }
    }
    
    virtual bool add(const std::string& file_name) {
        _discoveredFiles.push_back(file_name);
        return true;
    }
    
    virtual bool remove(const std::string& file_name) {
        _discoveredFiles.erase(std::remove(_discoveredFiles.begin(),  _discoveredFiles.end(), file_name), _discoveredFiles.end());
        return true;
    }
    
    
private:
    FilesVector _discoveredFiles;
};


P3DAppInterface::P3DAppInterface()
    : osg::Referenced()
    , _sceneNode(NULL)
    , _refreshInterfaceCallback(NULL)
    , _oscController(new OscController())
{
    addSupportedFileType("osgt");
    addSupportedFileType("osgb");
    addSupportedFileType("p3d");
    
    _files[FileCollection::LOCAL] = new LocalFileCollection();
    _files[FileCollection::REMOTE] = new RemoteFileCollection();
    
    _viewer = new osgViewer::Viewer();
    _trackball = new ToggleMultiTouchTrackball();
    _viewer->setCameraManipulator(_trackball);
    
    _viewer->getEventHandlers().push_front(new ZeroConfDiscoverEventHandler(this));
    _viewer->getEventQueue()->setFirstTouchEmulatesMouse(false);
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
    
    unsetenv("P3D_CONTROL_ALLOW_TRACKBALL");
    unsetenv("P3D_CONTROL_MENU_BUTTON_CAPTION");
    
    _menuBtnCaption = "Menu";
    refreshInterface();
    
    _readFileThread = new ReadFileThread(file_name);
    _readFileThread->start();
}


void P3DAppInterface::setIntermediateScene(osg::Node* node)
{
    std::cout << "setIntermediateScene: " << _readFileThread->getFileName() << std::endl;
    _intermediateSceneNode = node;
    if (_readFileCompleteHandler) {
        _readFileCompleteHandler->setIntermediateScene(node, _readFileThread->getFileName());
    }
}


void P3DAppInterface::readFinished(bool success, osg::Node* node, const std::string& file_name)
{
    std::cout << "finished with file: " << _readFileThread->getFileName() << std::endl;
    _sceneNode = node;
    if (_readFileCompleteHandler) {
        _readFileCompleteHandler->finished(success, node, file_name);
    }
    

    
}

void P3DAppInterface::applyIntermediateSceneData()
{
    checkEnvVars();
    _viewer->setSceneData(_intermediateSceneNode);
    _intermediateSceneNode = NULL;
}

void P3DAppInterface::applySceneData()
{
    checkEnvVars();
    _readFileThread = NULL;
    std::cout << "applying scene data" << std::endl;
    
    _viewer->setSceneData(_sceneNode);
    _sceneNode = NULL;
    
    getViewer()->getEventQueue()->keyPress(' ');
    getViewer()->getEventQueue()->keyRelease(' ');
    getViewer()->getEventQueue()->keyPress(osgGA::GUIEventAdapter::KEY_Home);
    getViewer()->getEventQueue()->keyRelease(osgGA::GUIEventAdapter::KEY_Home);
}


void P3DAppInterface::setupViewer(int width, int height)
{
    _viewer->getCamera()->setProjectionMatrixAsPerspective(30.0f, static_cast<double>(width)/static_cast<double>(height), 1.0f, 10000.0f);
}


UIView* P3DAppInterface::initInView(UIView *view, int width, int height)
{
    _viewer->setThreadingModel(osgViewer::Viewer::SingleThreaded);
    _viewer->getEventQueue()->setFirstTouchEmulatesMouse(true);
    
 
    osg::ref_ptr<osgViewer::GraphicsWindowIOS::WindowData> window_data = new osgViewer::GraphicsWindowIOS::WindowData(view, osgViewer::GraphicsWindowIOS::WindowData::IGNORE_ORIENTATION);
    window_data->setViewContentScaleFactor(1.0);
    osg::ref_ptr<osg::GraphicsContext::Traits> traits = new osg::GraphicsContext::Traits();
    
    traits->x = 0;
    traits->y = 0;
    traits->width = width;
    traits->height = height;
    traits->depth = 24; //keep memory down, default is currently 24
    traits->alpha = 0;
    traits->windowDecoration = false;
    traits->doubleBuffer = true;
    traits->sharedContext = 0;
    
    traits->samples = 4;
    traits->sampleBuffers = 1;
    
    traits->inheritedWindowData = window_data;
    osg::ref_ptr<osgViewer::GraphicsWindowIOS> graphicsContext = dynamic_cast<osgViewer::GraphicsWindowIOS*>(osg::GraphicsContext::createGraphicsContext(traits));

    if(graphicsContext)
    {
        _viewer->getCamera()->setGraphicsContext(graphicsContext);
        _viewer->getCamera()->setViewport(new osg::Viewport(0, 0, traits->width, traits->height));
        setupViewer(width, height);
        _viewer->realize();
        return (UIView*)(graphicsContext->getView());
    }
    
    
    return NULL;
    
}



void P3DAppInterface::handleMemoryWarning()
{
    osgDB::Registry::instance()->clearObjectCache();
}


void P3DAppInterface::addDevice(osgGA::Device *device)
{
    std::cout << "TODO: adddevice" << std::endl;
}


void P3DAppInterface::checkEnvVars()
{
    {
        const char* p3dControlAllowTrackball = getenv("P3D_CONTROL_ALLOW_TRACKBALL");
        if (p3dControlAllowTrackball)
        {
            unsigned int val = atoi(p3dControlAllowTrackball);
            toggleTrackball( val != 0 );
            refreshInterface();
        }
    }
    _menuBtnCaption = "Menu";
    {
        const char* p3dControlMenuButtonCaption = getenv("P3D_CONTROL_MENU_BUTTON_CAPTION");
        if (p3dControlMenuButtonCaption)
        {
            _menuBtnCaption = std::string(p3dControlMenuButtonCaption);
        }
    }
    refreshInterface();

    /*
    {
        const char* p3dTimeOut = getenv("P3D_TIMEOUT");
        if(p3dTimeOut)
        {
            unsigned int new_max_idle_time = atoi(p3dTimeOut);
            if (new_max_idle_time > 0)
            {
                if (!_idleTimerEventHandler.valid())
                {
                    _idleTimerEventHandler = new IdleTimerEventHandler(new_max_idle_time);
                    _viewer->getEventHandlers().push_front(_idleTimerEventHandler);
                }
                _idleTimerEventHandler->setNewMaxIdleTime(new_max_idle_time);
            }
        }
    }*/
    
    {
        char* OSGNOTIFYLEVEL=getenv("OSG_NOTIFY_LEVEL");
        if (!OSGNOTIFYLEVEL) OSGNOTIFYLEVEL=getenv("OSGNOTIFYLEVEL");
        if(OSGNOTIFYLEVEL)
        {
            osg::NotifySeverity notifyLevel = osg::NOTICE;
            std::string stringOSGNOTIFYLEVEL(OSGNOTIFYLEVEL);

            // Convert to upper case
            for(std::string::iterator i=stringOSGNOTIFYLEVEL.begin();
                i!=stringOSGNOTIFYLEVEL.end();
                ++i)
            {
                *i=toupper(*i);
            }

            if(stringOSGNOTIFYLEVEL.find("ALWAYS")!=std::string::npos)          notifyLevel=osg::ALWAYS;
            else if(stringOSGNOTIFYLEVEL.find("FATAL")!=std::string::npos)      notifyLevel=osg::FATAL;
            else if(stringOSGNOTIFYLEVEL.find("WARN")!=std::string::npos)       notifyLevel=osg::WARN;
            else if(stringOSGNOTIFYLEVEL.find("NOTICE")!=std::string::npos)     notifyLevel=osg::NOTICE;
            else if(stringOSGNOTIFYLEVEL.find("DEBUG_INFO")!=std::string::npos) notifyLevel=osg::DEBUG_INFO;
            else if(stringOSGNOTIFYLEVEL.find("DEBUG_FP")!=std::string::npos)   notifyLevel=osg::DEBUG_FP;
            else if(stringOSGNOTIFYLEVEL.find("DEBUG")!=std::string::npos)      notifyLevel=osg::DEBUG_INFO;
            else if(stringOSGNOTIFYLEVEL.find("INFO")!=std::string::npos)       notifyLevel=osg::INFO;
            else std::cout << "Warning: invalid OSG_NOTIFY_LEVEL set ("<<stringOSGNOTIFYLEVEL<<")"<<std::endl;
            
            osg::setNotifyLevel(notifyLevel);

        }
    }
}
