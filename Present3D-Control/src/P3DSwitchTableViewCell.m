//
//  P3DSwitchTableViewCell.m
//  Present3D-Control
//
//  Created by Stephan Huber on 22.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#import "P3DSwitchTableViewCell.h"

@implementation P3DSwitchTableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


- (void)handleTap:(id)sender {
    // NSLog(@"toggle: %d", _toggleSwitch.on);
    
    [_toggleSwitch setOn: !_toggleSwitch.on animated: YES];
    [_toggleSwitch sendActionsForControlEvents: UIControlEventValueChanged];
}


@end
