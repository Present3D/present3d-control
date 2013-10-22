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
    
    virtual void operator()(bool success, osg::Node* node, const std::string& file_name) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_controller handleReadFileResult: success withFileName:IOSUtils::toNSString(osgDB::getSimpleFileName(file_name))];
        });
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
#warning Incomplete method implementation.
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
            return 5;
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    osg::ref_ptr<P3DAppInterface> app = P3DAppInterface::instance();
    UITableViewCell *cell = NULL;
    
    // Configure the cell...
    switch(indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"LocalFileCell" forIndexPath:indexPath];
            cell.textLabel.text = IOSUtils::toNSString(app->getLocalFiles()->getSimpleNameAt(indexPath.row));
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
            }
            break;
        case 2:
            switch(indexPath.row) {
                case 0:
                    {
                        P3DSwitchTableViewCell* the_cell =[tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
                        the_cell.textLabel.text = @"Disable interface";
                        cell = the_cell;
                    }
                    break;
            }

            
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
                        P3DTextfieldTableViewCell* the_cell =[tableView dequeueReusableCellWithIdentifier:@"LabelTextfieldCell" forIndexPath:indexPath];
                        the_cell.textLabel.text = @"Host";
                        self.oscSettingsController.hostTextfield = the_cell.textfield;

                        cell = the_cell;
                    }
                    break;

                case 2:
                    {
                        P3DTextfieldTableViewCell* the_cell =[tableView dequeueReusableCellWithIdentifier:@"LabelTextfieldCell" forIndexPath:indexPath];
                        the_cell.textLabel.text = @"Port";
                        self.oscSettingsController.portTextfield = the_cell.textfield;

                        cell = the_cell;
                    }
                    break;
                case 3:
                    {
                        P3DTextfieldTableViewCell* the_cell =[tableView dequeueReusableCellWithIdentifier:@"LabelTextfieldCell" forIndexPath:indexPath];
                        the_cell.textLabel.text = @"Messages / event";
                        self.oscSettingsController.numMessagesTextfield = the_cell.textfield;

                        cell = the_cell;
                    }
                    break;
                    
                case 4:
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
    return sectionName;
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

-(void) handleReadFileResult: (BOOL) success withFileName:(NSString *)fileName
{
    ECSlidingViewController* svc = (ECSlidingViewController*)[self parentViewController];
    [(P3DSceneViewController*)svc.topViewController stopReadingSequence];
    if (success)
        P3DAppInterface::instance()->applySceneData();
    else {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: @"Error" message: [NSString stringWithFormat: @"Could not read scene-file %@", fileName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

@end
