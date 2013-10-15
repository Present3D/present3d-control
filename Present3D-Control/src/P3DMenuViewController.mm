//
//  P3DMenuViewController.m
//  Present3D-Control
//
//  Created by Stephan Huber on 15.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#import "P3DMenuViewController.h"

#include "P3DAppInterface.h"
#include "IOSUtils.h"

@interface P3DMenuViewController ()

@end

@implementation P3DMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
    return 3;
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
            return 4;
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
            }
            else
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"ConnectRemoteCell" forIndexPath:indexPath];
            }
            break;
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
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
            app->getLocalFiles()->loadAt(indexPath.row);
            break;
        case 1:
            if(indexPath.row < app->getRemoteFiles()->getNumFiles())
                app->getRemoteFiles()->loadAt(indexPath.row);
            break;

        default:
            break;
    }
}

@end
