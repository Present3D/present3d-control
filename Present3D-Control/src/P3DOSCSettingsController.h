//
//  P3DOSCSettingsController.h
//  Present3D-Control
//
//  Created by Stephan Huber on 22.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface P3DOSCSettingsController : NSObject <UITextFieldDelegate> {

}

@property (nonatomic, weak)  UISwitch* toggleSwitch;
@property (nonatomic, weak)  UITextField* hostTextfield;
@property (nonatomic, weak)  UITextField* portTextfield;
@property (nonatomic, weak)  UITextField* numMessagesTextfield;
@property (nonatomic, weak)  UITextField* delayTextfield;




- (IBAction)toggleDiscovery:(id)sender;
- (void) updateDelegates;


@end
