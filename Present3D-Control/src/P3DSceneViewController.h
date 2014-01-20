//
//  P3DSceneViewController.h
//  Present3D-Control
//
//  Created by Stephan Huber on 14.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#include "P3DAppInterface.h"

@interface P3DSceneViewController : UIViewController {

    IBOutlet UIButton* toggleButton;
    IBOutlet UIView* loadingView;
    
    P3DAppInterface*    _app;
    CADisplayLink*      _displayLink;
    UIView*             _openGLView;

}

- (IBAction)toggleButtonTapped:(id)sender;
- (void)startReadingSequence;
- (void)handleSetIntermediateScene;
- (void)stopReadingSequence;
- (void)initCommon;
- (void)guidedAccessChanged;
- (void)updateScene;
- (void)refreshInterface;

@end
