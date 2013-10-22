//
//  P3DLabelTextfieldTableView.h
//  Present3D-Control
//
//  Created by Stephan Huber on 22.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#import "P3DTextfieldTableViewCell.h"

@interface P3DLabelTextfieldTableViewCell : P3DTextfieldTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *textLabel;

-(void) setInputEnabled: (BOOL) isEnabled;

@end
