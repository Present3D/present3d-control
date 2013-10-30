//
//  P3DOSCSettingsController.m
//  Present3D-Control
//
//  Created by Stephan Huber on 22.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#import "P3DOSCSettingsController.h"
#import "P3DLabelTextfieldTableViewCell.h"

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
    return [[NSUserDefaults standardUserDefaults] stringForKey: oscHostKey];
}


- (void) setHost: (NSString*)host {
    [[NSUserDefaults standardUserDefaults] setObject: host forKey: oscHostKey];
}


-(unsigned int)getPort {
    return [[NSUserDefaults standardUserDefaults] integerForKey: oscPortKey];
}

-(void)setPort:(unsigned int)port {
    [[NSUserDefaults standardUserDefaults] setInteger:port forKey: oscPortKey];
}

-(unsigned int)getNumMessagesPerEvent {
    return [[NSUserDefaults standardUserDefaults] integerForKey: oscMessagesPerEventKey];
}

-(void)setNumMessagesPerEvent:(unsigned int)messages {
    [[NSUserDefaults standardUserDefaults] setInteger:messages forKey: oscMessagesPerEventKey];
}


-(unsigned int)getDelay {
    return [[NSUserDefaults standardUserDefaults] integerForKey: oscDelayKey];
}

-(void)setDelay:(unsigned int)delay {
    [[NSUserDefaults standardUserDefaults] setInteger:delay forKey: oscDelayKey];

}

@end


