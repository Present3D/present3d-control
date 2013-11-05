//
//  P3DMenuViewController.h
//  Present3D-Control
//
//  Created by Stephan Huber on 15.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "P3DOSCSettingsController.h"

@interface P3DMenuViewController : UITableViewController<UITextFieldDelegate>{
}

@property (nonatomic, strong) IBOutlet P3DOSCSettingsController* oscSettingsController;

-(void) startReadingSequence;
-(void) handleSetIntermediateScene;
-(void) handleReadFileResult: (BOOL) success withFileName: (NSString*) fileName;
-(void) toggleAllowTrackball: (id)sender;

@end
