//
//  P3DMenuViewController.m
//  Present3D-Control
//
//  Created by Stephan Huber on 15.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#import "P3DMenuViewController.h"
#import "ECSlidingViewController.h"
#import "P3DSceneViewController.h"
#import "P3DTextfieldTableViewCell.h"
#import "P3DSwitchTableViewCell.h"

#include "P3DAppInterface.h"
#include "IOSUtils.h"


class MyReadFileCompletionHandler : public ReadFileCompleteHandler {
public:
    MyReadFileCompletionHandler(P3DMenuViewController* controller) : ReadFileCompleteHandler(), _controller(controller) {}
    
    virtual void setIntermediateScene(osg::Node* node, const std::string& file_name) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_controller handleSetIntermediateScene];
        });
    }
    
    virtual void finished(bool success, osg::Node* node, const std::string& file_name) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSUserDefaults standardUserDefaults] setObject: IOSUtils::toNSString(file_name) forKey: @"osgLastOpenedFile"];
            [_controller handleReadFileResult: success withFileName:IOSUtils::toNSString(osgDB::getSimpleFileName(file_name))];
        });
    }
    
private:
    P3DMenuViewController* _controller;
};


struct MyRefreshInterfaceCallback : P3DAppInterface::RefreshInterfaceCallback {

    MyRefreshInterfaceCallback(P3DMenuViewController* controller) : P3DAppInterface::RefreshInterfaceCallback(), _controller(controller) {}
    
    virtual void operator()() {
        [_controller refreshInterface];
    }
private:
    P3DMenuViewController* _controller;
};

@interface P3DMenuViewController ()

@end

@implementation P3DMenuViewController

- (void) commonInit
{
    self.oscSettingsController = [[P3DOSCSettingsController alloc] init];
    self.oscSettingsController.parentViewController = self;
    
    P3DAppInterface::instance()->setRefreshInterfaceCallback(new MyRefreshInterfaceCallback(self));
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // restore saved values
    bool trackball_enabled = [[NSUserDefaults standardUserDefaults] boolForKey: @"osgAllowTrackball"];
    NSString* last_file = [[NSUserDefaults standardUserDefaults] stringForKey: @"osgLastOpenedFile"];
    
    P3DAppInterface::instance()->toggleTrackball(trackball_enabled);
    P3DAppInterface::instance()->reset();
    
    if(last_file) {
        [self startReadingSequence];
        P3DAppInterface::instance()->readFile(IOSUtils::toString(last_file));
    }
    
    [self refreshInterface];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    osg::ref_ptr<P3DAppInterface> app = P3DAppInterface::instance();
    switch(section) {
        case 0:
            app->getLocalFiles()->collect();
            return app->getLocalFiles()->getNumFiles();
            break;
        case 1:
            app->getRemoteFiles()->collect();
            return app->getRemoteFiles()->getNumFiles() + 1;

            break;
        case 2:
            return 1;
            break;
        case 3:
            return 6;
            break;
    }
    
    return 0;
}

-(NSString*) removeDeviceClassesFrom: (NSString*) file_name
{
    NSString* result = file_name;
    result = [result stringByReplacingOccurrencesOfString: @"@iphone5" withString:@""];
    result = [result stringByReplacingOccurrencesOfString: @"@iphone" withString:@""];
    result = [result stringByReplacingOccurrencesOfString: @"@ipad" withString:@""];
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    osg::ref_ptr<P3DAppInterface> app = P3DAppInterface::instance();
    UITableViewCell *cell = NULL;
    
    // Configure the cell...
    switch(indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"LocalFileCell" forIndexPath:indexPath];
            cell.textLabel.text = [self removeDeviceClassesFrom: IOSUtils::toNSString(app->getLocalFiles()->getSimpleNameAt(indexPath.row))];
            break;
            
        case 1:
            if (indexPath.row < app->getRemoteFiles()->getNumFiles())
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"RemoteFileCell" forIndexPath:indexPath];
                cell.textLabel.text = IOSUtils::toNSString(app->getRemoteFiles()->getSimpleNameAt(indexPath.row));
                cell.detailTextLabel.text = IOSUtils::toNSString(app->getRemoteFiles()->getDetailedAt(indexPath.row));
            }
            else
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"TextfieldCell" forIndexPath:indexPath];
                P3DTextfieldTableViewCell* tf_cell = (P3DTextfieldTableViewCell*)(cell);
                tf_cell.textfield.delegate = self;
                [tf_cell.textfield setKeyboardType:UIKeyboardTypeURL];
            }
            break;
            
        case 2:
            switch(indexPath.row) {
                case 0:
                    {
                        P3DSwitchTableViewCell* the_cell =[tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
                        the_cell.textLabel.text = @"allow trackball";
                        the_cell.toggleSwitch.on = P3DAppInterface::instance()->isTrackballEnabled();
                        
                        [the_cell.toggleSwitch addTarget: self action:@selector(toggleAllowTrackball:) forControlEvents:UIControlEventValueChanged];
                        cell = the_cell;
                    }
                    break;
            }
            break;
        case 3:
            
            switch(indexPath.row) {
                case 0:
                    {
                        P3DSwitchTableViewCell* the_cell =[tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
                        the_cell.textLabel.text = @"Automatic discovery";
                        [the_cell.toggleSwitch addTarget: self.oscSettingsController action:@selector(toggleDiscovery:) forControlEvents:UIControlEventValueChanged];
                        self.oscSettingsController.toggleSwitch = the_cell.toggleSwitch;
                        cell = the_cell;
                    }
                    break;
                case 1:
                    {
                        cell = [tableView dequeueReusableCellWithIdentifier:@"LocalFileCell" forIndexPath:indexPath];
                        cell.textLabel.text = @"Autodiscovered Hosts";
                        self.oscSettingsController.autodiscoveredHostsCell = cell;

                    }
                    break;
                    
                case 2:
                    {
                        P3DTextfieldTableViewCell* the_cell =[tableView dequeueReusableCellWithIdentifier:@"LabelTextfieldCell" forIndexPath:indexPath];
                        the_cell.textLabel.text = @"Host";
                        self.oscSettingsController.hostTextfield = the_cell.textfield;
                        
                        cell = the_cell;
                    }
                    break;

                case 3:
                    {
                        P3DTextfieldTableViewCell* the_cell =[tableView dequeueReusableCellWithIdentifier:@"LabelTextfieldCell" forIndexPath:indexPath];
                        the_cell.textLabel.text = @"Port";
                        self.oscSettingsController.portTextfield = the_cell.textfield;

                        cell = the_cell;
                    }
                    break;
                case 4:
                    {
                        P3DTextfieldTableViewCell* the_cell =[tableView dequeueReusableCellWithIdentifier:@"LabelTextfieldCell" forIndexPath:indexPath];
                        the_cell.textLabel.text = @"Messages / event";
                        self.oscSettingsController.numMessagesTextfield = the_cell.textfield;

                        cell = the_cell;
                    }
                    break;
                    
                case 5:
                    {
                        P3DTextfieldTableViewCell* the_cell =[tableView dequeueReusableCellWithIdentifier:@"LabelTextfieldCell" forIndexPath:indexPath];
                        the_cell.textLabel.text = @"Delay (ms)";
                        self.oscSettingsController.delayTextfield = the_cell.textfield;
                        
                        cell = the_cell;
                    }
                    break;


                default:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
                    break;
            }
            
            [self.oscSettingsController updateDelegates];
            break;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"localFileSectionName", @"localFileSectionName");
            break;
        case 1:
            sectionName = NSLocalizedString(@"remoteFileSectionName", @"remoteFileSectionName");
            break;
        case 2:
            sectionName = NSLocalizedString(@"settingsSectionName", @"settingsSectionName");
            break;
         case 3:
            sectionName = NSLocalizedString(@"oscSettingsSectionName", @"oscSettingsSectionName");
            break;
            
        // ...
        default:
            sectionName = @"";
            break;
    }    
    return ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) ? Nil : sectionName;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    osg::ref_ptr<P3DAppInterface> app = P3DAppInterface::instance();
    
    switch (indexPath.section) {
        case 0:
            [self startReadingSequence];
            app->getLocalFiles()->loadAt(indexPath.row);
            break;
            
        case 1:
            if(indexPath.row < app->getRemoteFiles()->getNumFiles())
            {
                [self startReadingSequence];
                app->getRemoteFiles()->loadAt(indexPath.row);
            }
            break;
        case 3:
            if(indexPath.row == 1) {
                [self showAutodiscoveredHosts];
            }
        default:
            break;
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    osg::ref_ptr<P3DAppInterface> app = P3DAppInterface::instance();
    
    std::string entered_address = IOSUtils::toString(textField.text);
    
    // app->getRemoteFiles()->addTemporaryFile(entered_text);
    
    // [self.tableView reloadData];
    
    [self startReadingSequence];
    app->readFile(entered_address);

    // textField.text = @"";

    return YES;
}


- (void)startReadingSequence
{
    ECSlidingViewController* svc = (ECSlidingViewController*)[self parentViewController];
    
    [(P3DSceneViewController*)svc.topViewController startReadingSequence];
    
    P3DAppInterface::instance()->setReadFileCompleteHandler(new MyReadFileCompletionHandler(self));
}


-(void) handleSetIntermediateScene
{
    ECSlidingViewController* svc = (ECSlidingViewController*)[self parentViewController];
    [(P3DSceneViewController*)svc.topViewController handleSetIntermediateScene];
    P3DAppInterface::instance()->applyIntermediateSceneData();
}


-(void) handleReadFileResult: (BOOL) success withFileName:(NSString *)fileName
{
    ECSlidingViewController* svc = (ECSlidingViewController*)[self parentViewController];
    [(P3DSceneViewController*)svc.topViewController stopReadingSequence];
    if (success)
    {
        P3DAppInterface::instance()->applySceneData();
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject: NULL forKey: @"osgLastOpenedFile"];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: @"Error" message: [NSString stringWithFormat: @"Could not read scene-file %@", fileName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}


-(void)toggleAllowTrackball:(id)sender {
    UISwitch* ui_switch = (UISwitch*)(sender);
    P3DAppInterface::instance()->toggleTrackball(ui_switch.on);
    [[NSUserDefaults standardUserDefaults] setBool: ui_switch.on forKey: @"osgAllowTrackball"];

}


-(void) showAutodiscoveredHosts
{
    NSLog(@"show autodiscovered hosts");
    
    ECSlidingViewController* svc = (ECSlidingViewController*)[self parentViewController];
    
    [_oscSettingsController showAutoDiscoveredHosts:svc.view];
}


-(void) refreshInterface
{
    [self.tableView reloadData];
    
    ECSlidingViewController* svc = (ECSlidingViewController*)[self parentViewController];
    [(P3DSceneViewController*)svc.topViewController refreshInterface];
    
    [_oscSettingsController refreshInterface];
    
}

@end
