//
//  P3DSwitchTableViewCell.h
//  Present3D-Control
//
//  Created by Stephan Huber on 22.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface P3DSwitchTableViewCell : UITableViewCell {

}

@property (nonatomic, weak) IBOutlet UISwitch *toggleSwitch;
@property (nonatomic, weak) IBOutlet UILabel *textLabel;

- (void)handleTap:(id)sender;

@end
