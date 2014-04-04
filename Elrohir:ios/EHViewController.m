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

@property (strong, nonatomic) EHAPIClient *APIClient;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UITextField *usernameText;
@property (strong, nonatomic) UILabel *passwordLabel;
@property (strong, nonatomic) UITextField *passwordText;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UITextView *fetchEventView;
@property (strong, nonatomic) UIButton *fetchEventButton;
@property (strong, nonatomic) UIButton *fetchEventUserWishedButton;
@property (strong, nonatomic) UIButton *fetchEventListButton;

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
    
    _usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 100, 20)];
    self.usernameLabel.text = @"username";
    [self.view addSubview:_usernameLabel];
    _usernameText = [[UITextField alloc] initWithFrame:CGRectMake(100, 30, self.view.frame.size.width-110, 20)];
    self.usernameText.delegate = self;
    [self.view addSubview:_usernameText];
    
    _passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 100, 20)];
    self.passwordLabel.text = @"password";
    [self.view addSubview:_passwordLabel];
    _passwordText = [[UITextField alloc]initWithFrame:CGRectMake(100, 60, self.view.frame.size.width-110, 20)];
    self.passwordText.delegate = self;
    self.passwordText.secureTextEntry = YES;
    [self.view addSubview:_passwordText];
    
    _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-50, 90, 100, 20)];
    [self.loginButton setTitle:@"login" forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginButton];
    
    _fetchEventButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-50, 120, 100, 20)];
    [self.fetchEventButton setTitle:@"fetchEvent" forState:UIControlStateNormal];
    [self.fetchEventButton addTarget:self action:@selector(fetchEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_fetchEventButton];
    
    _fetchEventUserWishedButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-100, 150, 200, 20)];
    [self.fetchEventUserWishedButton setTitle:@"fetchEventUserWished" forState:UIControlStateNormal];
    [self.fetchEventUserWishedButton addTarget:self action:@selector(fetchEventUserWished) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_fetchEventUserWishedButton];
    
    _fetchEventListButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-100, 180, 200, 20)];
    [self.fetchEventListButton setTitle:@"fetchEventList" forState:UIControlStateNormal];
    [self.fetchEventListButton addTarget:self action:@selector(fetchEventList) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_fetchEventListButton];
    
    _fetchEventView = [[UITextView alloc] initWithFrame:CGRectMake(10, 260, self.view.frame.size.width-20, 200)];
    self.fetchEventView.text = @"123";
    [self.view addSubview:_fetchEventView];
  
    [EHAPIClient createSharedAPIClientWithClientId:@""
                                            secret:@""
                                       redirectURI:@""
                                           appName:@""
                                        appVersion:@""];
    _APIClient = [EHAPIClient shared];
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
    
    [self.APIClient loginWithUsername:self.usernameText.text password:self.passwordText.text callback:^(NSDictionary *list){
        NSLog(@"%@",list);
    }];
}

- (void)fetchEvent{
    [self.APIClient fetchEventWithId:@"10069638" callback:^(NSDictionary * list){
        NSLog(@"%@",list);
    }];
}

- (void)fetchEventUserWished{
    [self.APIClient fetchEventUserWishedWithId:@"10069638" status:@"ongoing" callback:^(NSDictionary *list){
        NSLog(@"%@",list);
    }];
}

- (void)fetchEventList{
    [self.APIClient fetchEventListWithLocId:@"108288" dayType:@"week" type:@"music" callback:^(NSDictionary *list){
        NSLog(@"%@",list);
    }];
}

@end
