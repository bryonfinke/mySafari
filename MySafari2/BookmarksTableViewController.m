//
//  BookmarksTableViewController.m
//  MySafari2
//
//  Created by Bryon Finke on 6/13/15.
//  Copyright (c) 2015 Bryon Finke. All rights reserved.
//

#import "BookmarksTableViewController.h"
#import "Bookmark.h"
#import "ViewController.h"

@interface BookmarksTableViewController ()

@end

@implementation BookmarksTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%lu", self.bookmarks.count);
}

#pragma mark - Table view data source

- (NSInteger)number:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bookmarks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bookmarkID"];
    Bookmark *bookmark = [self.bookmarks objectAtIndex:indexPath.row];
    cell.textLabel.text = bookmark.title;
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ViewController *vc = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Bookmark *bookmark = [self.bookmarks objectAtIndex:indexPath.row];
    vc.url = bookmark.url;
}

@end
