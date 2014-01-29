//
//  P3DOSCChooseHostViewController.m
//  Present3D-Control
//
//  Created by Stephan Huber on 29.01.14.
//  Copyright (c) 2014 Stephan Huber. All rights reserved.
//

#import "P3DOSCHostPickerViewController.h"

#include "P3DAppInterface.h"
#include "OscController.h"
#include <sstream>
#include "IOSUtils.h"
#include "P3DOSCSettingsController.h"

@interface P3DOSCHostPickerViewController ()

@end

@implementation P3DOSCHostPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return P3DAppInterface::instance()->getOscController()->getNumAutoDiscoveredHosts();
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    OscController::HostAndPort hap =  P3DAppInterface::instance()->getOscController()->getAutoDiscoveredHostAt(row);
    
    std::ostringstream ss;
    ss << hap.host << ":" << hap.port;
    
    return IOSUtils::toNSString(ss.str());
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.parentController selectAutoDiscoveredHost: row];
}


@end
