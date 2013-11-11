//
//  P3DOSCSettingsController.m
//  Present3D-Control
//
//  Created by Stephan Huber on 22.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#import "P3DOSCSettingsController.h"
#import "P3DLabelTextfieldTableViewCell.h"

#include "P3DAppInterface.h"
#include "IOSUtils.h"

NSString *const oscDiscoverKey          = @"oscDiscover";
NSString *const oscHostKey              = @"oscHost";
NSString *const oscPortKey              = @"oscPort";
NSString *const oscMessagesPerEventKey  = @"oscMessagesPerEvent";
NSString *const oscDelayKey             = @"oscDelay";


@implementation P3DOSCSettingsController

- (id)init
{
    self = [super init];
    
    if(self) {
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        [standardDefaults registerDefaults:@{oscDiscoverKey: @TRUE, oscHostKey: @"", oscPortKey: @9000, oscMessagesPerEventKey: @3, oscDelayKey: @1000}];
        [standardDefaults synchronize];
        
        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
        
        OscController* osc_controller = P3DAppInterface::instance()->getOscController();
        
        NSString* host = [standardDefaults stringForKey: oscHostKey];
        unsigned int port = [standardDefaults integerForKey: oscPortKey];
        unsigned int num_messages_per_event = [standardDefaults integerForKey: oscMessagesPerEventKey];
        unsigned int delay = [standardDefaults integerForKey: oscDelayKey];
        osc_controller->setHostAndPort(IOSUtils::toString(host), port);
        osc_controller->setNumMessagesPerEvent(num_messages_per_event);
        osc_controller->setDelay(delay);
        
        if(![[NSUserDefaults standardUserDefaults] boolForKey: oscDiscoverKey])
            osc_controller->reconnect();
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _hostTextfield) {
        [self setHost: textField.text];
    } else if (textField == _portTextfield) {
        [self setPort: [textField.text integerValue]];
    } else if (textField == _numMessagesTextfield) {
        [self setNumMessagesPerEvent: [textField.text integerValue]];
    } else if (textField == _delayTextfield) {
        [self setDelay:[textField.text integerValue]];
    }
    
    // reconnect osc, if necessary
    P3DAppInterface::instance()->getOscController()->reconnect();


    UITextField* fields[4] = { _hostTextfield, _portTextfield, _numMessagesTextfield, _delayTextfield };
    for(unsigned int i=0; i < 4; ++i) {
        if (fields[i] == textField) {
            if (i < 3) {
                [fields[i+1] becomeFirstResponder];
                return YES;
            } else {
                [fields[i] resignFirstResponder];
                return NO;
            }
        }
    }
    
    return YES;
}

- (P3DLabelTextfieldTableViewCell*) getTableCellView: (UIView*) subView {
    UIView* view = subView;
    while(view && ![view isKindOfClass:[P3DLabelTextfieldTableViewCell class]]) {
        view = view.superview;
    }
    return (P3DLabelTextfieldTableViewCell*)view;
}

- (void) toggleHostAndPortInput: (BOOL)enabled {
    P3DLabelTextfieldTableViewCell* cell = [self getTableCellView: self.hostTextfield];
    
    [cell setInputEnabled: enabled];

    cell = [self getTableCellView: self.portTextfield];
    [cell setInputEnabled: enabled];

}

- (IBAction)toggleDiscovery:(id)sender
{
    UISwitch *onoff = (UISwitch *) sender;
    [self toggleHostAndPortInput: !onoff.on];
    [self setAutomaticDiscovery: onoff.on];
}


- (void) updateDelegates
{
    UITextField* fields[4] = { _hostTextfield, _portTextfield, _numMessagesTextfield, _delayTextfield };
    for(unsigned int i=0; i < 4; ++i) {
        if (fields[i]) {
            [fields[i] setDelegate: self];
        }
    }
}

-(void)setToggleSwitch:(UISwitch *)toggleSwitch
{
    _toggleSwitch = toggleSwitch;
    _toggleSwitch.on = [self getAutomaticDiscovery];
    [self toggleDiscovery: _toggleSwitch];

}

-(void)setHostTextfield:(UITextField *)hostTextfield
{
    _hostTextfield = hostTextfield;
    _hostTextfield.text = [self getHost];
    [_hostTextfield setKeyboardType:UIKeyboardTypeURL];
    [self toggleDiscovery: _toggleSwitch];
}

-(void)setPortTextfield:(UITextField *)portTextfield
{
    _portTextfield = portTextfield;
    _portTextfield.text = [NSString stringWithFormat:@"%d", [self getPort]];
    [_portTextfield setKeyboardType:UIKeyboardTypeNumberPad];
    [self toggleDiscovery: _toggleSwitch];
}

-(void)setNumMessagesTextfield:(UITextField *)numMessagesTextfield
{
    _numMessagesTextfield = numMessagesTextfield;
    _numMessagesTextfield.text = [NSString stringWithFormat:@"%d", [self getNumMessagesPerEvent]];
    [_numMessagesTextfield setKeyboardType:UIKeyboardTypeNumberPad];

}

-(void)setDelayTextfield:(UITextField *)delayTextfield
{
    _delayTextfield = delayTextfield;
    _delayTextfield.text = [NSString stringWithFormat:@"%d", [self getDelay]];
    [_delayTextfield setKeyboardType:UIKeyboardTypeNumberPad];

}

- (BOOL) getAutomaticDiscovery {
    return [[NSUserDefaults standardUserDefaults] boolForKey: oscDiscoverKey];
}

- (void) setAutomaticDiscovery: (BOOL)discovery
{
    [[NSUserDefaults standardUserDefaults] setBool: discovery forKey: oscDiscoverKey];
}

- (NSString*) getHost {   
    return IOSUtils::toNSString(P3DAppInterface::instance()->getOscController()->getHost());
}


- (void) setHost: (NSString*)host {
    P3DAppInterface::instance()->getOscController()->setHost(IOSUtils::toString(host));
    [[NSUserDefaults standardUserDefaults] setObject: host forKey: oscHostKey];
}


-(unsigned int)getPort {
    return P3DAppInterface::instance()->getOscController()->getPort();
}

-(void)setPort:(unsigned int)port {
    P3DAppInterface::instance()->getOscController()->setPort(port);
    [[NSUserDefaults standardUserDefaults] setInteger:port forKey: oscPortKey];
}

-(unsigned int)getNumMessagesPerEvent {
    return P3DAppInterface::instance()->getOscController()->getNumMessagesPerEvent();
}

-(void)setNumMessagesPerEvent:(unsigned int)messages {
    P3DAppInterface::instance()->getOscController()->setNumMessagesPerEvent(messages);
    [[NSUserDefaults standardUserDefaults] setInteger:messages forKey: oscMessagesPerEventKey];
}


-(unsigned int)getDelay {
    return P3DAppInterface::instance()->getOscController()->getDelay();
}

-(void)setDelay:(unsigned int)delay {
    P3DAppInterface::instance()->getOscController()->setDelay(delay);
    [[NSUserDefaults standardUserDefaults] setInteger:delay forKey: oscDelayKey];

}

@end


