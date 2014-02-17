//
//  EHViewController.m
//  Elrohir
//
//  Created by akron on 2/17/14.
//  Copyright (c) 2014 Douban Inc. All rights reserved.
//

#import "EHViewController.h"
#import "EHAPIClient.h"

@interface EHViewController ()

@end

@implementation EHViewController

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
    self.view.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:79.0f/255.0f blue:104.0f/255.0f alpha:1.0f];
    
    UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 100, 20)];
    usernameLabel.text = @"username";
    [self.view addSubview:usernameLabel];
    UITextField *usernameText = [[UITextField alloc] initWithFrame:CGRectMake(100, 30, self.view.frame.size.width-110, 20)];
    usernameText.delegate = self;
    [self.view addSubview:usernameText];
    
    UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 100, 20)];
    passwordLabel.text = @"password";
    [self.view addSubview:passwordLabel];
    UITextField *passwordText = [[UITextField alloc]initWithFrame:CGRectMake(100, 60, self.view.frame.size.width-110, 20)];
    passwordText.delegate = self;
    [self.view addSubview:passwordText];
    
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-50, 90, 100, 20)];
    [loginButton setTitle:@"login" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    UITextView *fetchEventView = [[UITextView alloc] initWithFrame:CGRectMake(10, 130, self.view.frame.size.width-20, 200)];
    fetchEventView.text = @"123";
    [self.view addSubview:fetchEventView];
    
    EHAPIClient *APIClient = [[EHAPIClient alloc] init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)login{
    
}

@end
