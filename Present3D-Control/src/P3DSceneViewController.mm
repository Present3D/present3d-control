//
//  P3DSceneViewController.m
//  Present3D-Control
//
//  Created by Stephan Huber on 14.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#import "P3DSceneViewController.h"
#import "P3DMenuViewController.h"

@interface P3DSceneViewController ()

@end

@implementation P3DSceneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initCommon];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder ];
    if (self) {
        [self initCommon];
    }
    return self;

}

- (void)initCommon
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(guidedAccessChanged) name:UIAccessibilityGuidedAccessStatusDidChangeNotification object:nil];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)guidedAccessChanged
{
    bool toggle_btn_enabled = !(UIAccessibilityIsGuidedAccessEnabled());
    
    [UIView animateWithDuration:0.25 animations:^{ toggleButton.alpha = toggle_btn_enabled ? 1 : 0;}];
    
    if (!toggle_btn_enabled) {
        [self.slidingViewController resetTopView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (![self.slidingViewController.underLeftViewController isKindOfClass:[P3DMenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }

    // TODO
    //[self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    [self.slidingViewController setAnchorRightRevealAmount:280.0f];
    self.slidingViewController.underLeftWidthLayout = ECFixedRevealWidth;


    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    if (_displayLink)
        [_displayLink invalidate];
    
    //_displayLink = [self.view.window.screen displayLinkWithTarget:self selector:@selector(updateScene)];
    //
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateScene)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    _app = P3DAppInterface::instance();
    _openGLView = _app->initInView(self.view, self.view.frame.size.width, self.view.frame.size.height);
    [self.view sendSubviewToBack: _openGLView];
    _openGLView.backgroundColor = [UIColor redColor];
    
    NSLog(@"subviews: %@",self.view.subviews);
    NSLog(@"view bounds: %fx%f, %fx%f)", _openGLView.frame.origin.x, _openGLView.frame.origin.y, _openGLView.frame.size.width, _openGLView.frame.size.height);
    _app->realize();
    
    [_openGLView setBounds: CGRectMake(200,200,self.view.frame.size.width-400, self.view.frame.size.height-400)];
    NSLog(@"view bounds: %fx%f, %fx%f)", _openGLView.frame.origin.x, _openGLView.frame.origin.y, _openGLView.frame.size.width, _openGLView.frame.size.height);

    
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (_displayLink)
        [_displayLink invalidate];
    _displayLink = NULL;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    _app->handleMemoryWarning();
}

- (IBAction)toggleButtonTapped:(id)sender
{
    if([self.slidingViewController underLeftShowing])
        [self.slidingViewController resetTopView];
    else
        [self.slidingViewController anchorTopViewTo: ECRight animations:nil onComplete:nil];
}

- (void)updateScene
{
    _app->frame();
}

- (void)startReadingSequence
{
    [self.slidingViewController resetTopView];
    
    loadingView.hidden = FALSE;
    loadingView.alpha = 0.0;
    [UIView animateWithDuration:0.25 animations:^{ loadingView.alpha = 1.0;}];
}

- (void)stopReadingSequence
{
    [UIView animateWithDuration:0.25 animations:^{ loadingView.alpha = 0.0;}];
}

@end
