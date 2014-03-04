//
//  P3DOSCChooseHostViewController.h
//  Present3D-Control
//
//  Created by Stephan Huber on 29.01.14.
//  Copyright (c) 2014 Stephan Huber. All rights reserved.
//

#import <UIKit/UIKit.h>

@class P3DOSCSettingsController;
@interface P3DOSCHostPickerViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate> {

}


@property (nonatomic, weak) IBOutlet UIPickerView* picker;
@property (nonatomic, weak) IBOutlet UIButton* cancelBtn;
@property (nonatomic, weak)  P3DOSCSettingsController* parentController;

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (IBAction)handleCancelBtn:(id)sender;

@end
