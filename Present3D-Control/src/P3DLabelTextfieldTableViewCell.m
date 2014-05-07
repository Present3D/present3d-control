//
//  P3DLabelTextfieldTableView.m
//  Present3D-Control
//
//  Created by Stephan Huber on 22.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#import "P3DLabelTextfieldTableViewCell.h"

@implementation P3DLabelTextfieldTableViewCell

@synthesize textLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if(selected)
        [self.textfield becomeFirstResponder];

    // Configure the view for the selected state
}


-(void) setInputEnabled: (BOOL) isEnabled
{
    [self setUserInteractionEnabled: isEnabled];
    self.textfield.enabled = isEnabled;
    self.textLabel.enabled = isEnabled;
    self.textfield.textColor = (isEnabled) ? [UIColor blackColor] : [UIColor lightGrayColor];
}

@end
