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
#include <osg/Node>
#include <osgViewer/Viewer>

#include "FileCollection.h"
#include "ReadFileThread.h"
#include "ReadFileCompleteHandler.h"
#include "OscController.h"
#include "ToggleMultiTouchTrackball.h"

#ifdef __OBJC__
@class UIView;
#else
class UIView;
#endif

class P3DAppInterface : public osg::Referenced {
public:
    
    typedef std::set<std::string> SupportedFileTypesSet;
    typedef std::map<FileCollection::Type, osg::ref_ptr<FileCollection> > FilesMap;
    
    struct RefreshInterfaceCallback : osg::Referenced {
    virtual void operator()() = 0;
    };
    
    P3DAppInterface();
    
    static P3DAppInterface* instance();
    
    FileCollection* getFiles(FileCollection::Type type) {
        FilesMap::iterator i = _files.find(type);
        return i != _files.end() ? i->second.get() : NULL;
    }
    
    FileCollection* getLocalFiles() { return getFiles(FileCollection::LOCAL); }
    FileCollection* getRemoteFiles() { return getFiles(FileCollection::REMOTE); }

    
    void addSupportedFileType(const std::string& file_type) { _supportedFileTypes.insert(file_type); }
    void addLocalFilePath(const std::string& path);
    
    void setReadFileCompleteHandler(ReadFileCompleteHandler* handler) { _readFileCompleteHandler = handler; }
    
    void applySceneData();
    void applyIntermediateSceneData();
    void checkEnvVars();

    void readFile(const std::string& file);
    
    UIView* initInView(UIView* view, int width, int height);
    
    inline void frame() {
        _viewer->frame();
    }
        
    void handleMemoryWarning();
    
    void addDevice(osgGA::Device* device);
    
    void toggleTrackball(bool b) {
        _trackball->setEnabled(b);
    }
    bool isTrackballEnabled() const { return _trackball->isEnabled(); }
    
    void setRefreshInterfaceCallback(RefreshInterfaceCallback* cb) { _refreshInterfaceCallback = cb; }
    
    void refreshInterface() {
        if (_refreshInterfaceCallback.valid())
            (*_refreshInterfaceCallback)();
    };
    
    osgViewer::Viewer* getViewer() { return _viewer; }
    
    OscController* getOscController() { return _oscController; }
    
    const std::string& getMenuBtnCaption() const { return _menuBtnCaption; }
    
protected:
    void setupViewer(int width, int heigth);
    
private:
    void setIntermediateScene(osg::Node* node);
    void readFinished(bool success, osg::Node* node, const std::string& file_name);
    bool fileTypeSupported(const std::string& file_extension);
    
    FilesMap _files;
    SupportedFileTypesSet _supportedFileTypes;
    
    osg::ref_ptr<ReadFileThread> _readFileThread;
    osg::ref_ptr<ReadFileCompleteHandler> _readFileCompleteHandler;
    osg::ref_ptr<osg::Node> _sceneNode, _intermediateSceneNode;
    
    friend class LocalFileCollection;
    friend class RemoteFileCollection;
    friend class ReadFileThread;
    osg::ref_ptr<osgViewer::Viewer> _viewer;
    osg::ref_ptr<ToggleMultiTouchTrackball> _trackball;
    
    osg::ref_ptr<RefreshInterfaceCallback> _refreshInterfaceCallback;
    osg::ref_ptr<OscController> _oscController;
    
    std::string _menuBtnCaption;
};
