//
//  P3DViewController.m
//  Present3D-Control
//
//  Created by Stephan Huber on 14.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#import "P3DRootViewController.h"

@interface P3DRootViewController ()

@end

@implementation P3DRootViewController




- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SceneView"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
