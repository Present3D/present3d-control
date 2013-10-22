//
//  P3DOSCSettingsController.m
//  Present3D-Control
//
//  Created by Stephan Huber on 22.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#import "P3DOSCSettingsController.h"
#import "P3DLabelTextfieldTableViewCell.h"

@implementation P3DOSCSettingsController

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
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
}


- (void) updateDelegates
{
    UITextField* fields[4] = { _hostTextfield, _portTextfield, _numMessagesTextfield, _delayTextfield };
    for(unsigned int i=0; i < 4; ++i) {
        if (fields[i])
            [fields[i] setDelegate: self];
    }
}

@end


