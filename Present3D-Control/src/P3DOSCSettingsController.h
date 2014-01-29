//
//  P3DOSCSettingsController.h
//  Present3D-Control
//
//  Created by Stephan Huber on 22.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#import <Foundation/Foundation.h>

@class P3DMenuViewController;

@interface P3DOSCSettingsController : NSObject <UITextFieldDelegate, UIPopoverControllerDelegate> {

}

@property (nonatomic, weak)  UISwitch* toggleSwitch;
@property (nonatomic, weak)  UITextField* hostTextfield;
@property (nonatomic, weak)  UITextField* portTextfield;
@property (nonatomic, weak)  UITextField* numMessagesTextfield;
@property (nonatomic, weak)  UITextField* delayTextfield;
@property (nonatomic, weak)  UITableViewCell* autodiscoveredHostsCell;
@property (nonatomic, strong) UIPopoverController* popover;
@property (nonatomic, weak)  P3DMenuViewController* parentViewController;



- (IBAction)toggleDiscovery:(id)sender;
- (void) updateDelegates;

- (BOOL) getAutomaticDiscovery;
- (void) setAutomaticDiscovery: (BOOL)discovery;
- (NSString*) getHost;
- (void) setHost: (NSString*)host;

-(unsigned int)getPort;
-(void)setPort:(unsigned int)port;

-(unsigned int)getNumMessagesPerEvent;
-(void)setNumMessagesPerEvent:(unsigned int)messages;

-(unsigned int)getDelay;
-(void)setDelay:(unsigned int)delay;

-(void)showAutoDiscoveredHosts: (UIView*)view;
-(void)refreshInterface;
-(void)selectAutoDiscoveredHost: (unsigned int)ndx;

@end
