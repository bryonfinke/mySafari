//
//  ViewController.m
//  MySafari2
//
//  Created by Bryon Finke on 6/13/15.
//  Copyright (c) 2015 Bryon Finke. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Bookmark.h"

@interface ViewController () <UIWebViewDelegate, UITextFieldDelegate, UIScrollViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkButton;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property NSManagedObjectContext *moc;
@property NSArray *bookmarks;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self goToUrlString:@"http://www.marketsquarehome.com"];
    [self.urlTextField setReturnKeyType:UIReturnKeyDone];
    self.webView.scrollView.delegate = self;
    CALayer *TopBorder = [CALayer layer];

    TopBorder.frame = CGRectMake(0.0f, 0.0f, self.buttonView.frame.size.width, 1.0f);
    TopBorder.backgroundColor = [UIColor colorWithRed:230/255.0
                                                green:230/255.0
                                                 blue:230/255.0
                                                alpha:1].CGColor;
    [self.buttonView.layer addSublayer:TopBorder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self goToUrlString:self.urlTextField.text];

    return YES;
}

- (void)goToUrlString:(NSString *)urlString {
    NSURL *url;
    if ([urlString hasPrefix:@"http://www."]) {
        url = [NSURL URLWithString:urlString];
    } else if ([urlString hasPrefix:@"www."]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", urlString]];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.%@", urlString]];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    [self.spinner startAnimating];
    [self.stopButton setEnabled: YES];
    [self.reloadButton setEnabled: NO];
    [self.bookmarkButton setEnabled: NO];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.spinner stopAnimating];
    [self.stopButton setEnabled: NO];
    [self.reloadButton setEnabled: YES];
    [self.bookmarkButton setEnabled: YES];
    self.urlTextField.placeholder = [NSString stringWithFormat:@"%@", self.webView.request.URL.absoluteString];
    if ([self.webView canGoBack] == YES) {
        [self.backButton setEnabled: YES];
    } else {
        [self.backButton setEnabled: NO];
    }

    if ([self.webView canGoForward] == YES) {
        [self.forwardButton setEnabled: YES];
    } else {
        [self.forwardButton setEnabled: NO];
    }
    webView.scrollView.scrollEnabled = TRUE;
}

- (IBAction)onBackButtonPressed:(UIButton *)sender {
    [self.webView goBack];
}

- (IBAction)onForwardButtonPressed:(UIButton *)sender {
    [self.webView goForward];
}

- (IBAction)onStopButtonPressed:(UIButton *)sender {
    [self.webView stopLoading];
}

- (IBAction)onReloadButtonPressed:(UIButton *)sender {
    [self.webView reload];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    ScrollDirection scrollDirection;
    if (self.lastContentOffset < scrollView.contentOffset.y) {
        scrollDirection = ScrollDirectionUp;
    } else if (self.lastContentOffset > scrollView.contentOffset.y) {
        scrollDirection = ScrollDirectionDown;
    }

    self.lastContentOffset = scrollView.contentOffset.y;

    if (scrollDirection) {
        if (self.lastContentOffset == 0) {
            [self.urlTextField setHidden:NO];
            [self.buttonView setHidden:NO];
        } else if (scrollDirection == ScrollDirectionUp) {
            [self.urlTextField setHidden:YES];
            [self.buttonView setHidden:YES];
        } else if (scrollDirection == ScrollDirectionDown) {
            [self.urlTextField setHidden:NO];
            [self.buttonView setHidden:NO];
        }
    }
}

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

- (IBAction)onPlusButtonPressed:(UIButton *)sender {
    NSString *webTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add Bookmark" message:webTitle preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSManagedObject *bookmark = [NSEntityDescription insertNewObjectForEntityForName:@"Bookmark" inManagedObjectContext: self.moc];
        [bookmark setValue:self.webView.request.URL.absoluteString forKey:@"bookmark"];
        [self.moc save:nil];
        [self loadBookmarks];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alertController addAction:addAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)loadBookmarks {
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Bookmark"];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"bookmark" ascending:YES];
    request.sortDescriptors = @[sortDescriptor1];
    self.bookmarks = [self.moc executeFetchRequest:request error:nil];
    NSLog(@"%lu", self.bookmarks.count);
}

@end
