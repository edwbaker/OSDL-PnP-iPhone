//
//  SensorInfoController.m
//  BonjourWeb
//
//  Created by Edward Baker on 17/03/2014.
//
//

#import "SensorInfoController.h"

@interface SensorInfoController ()

@property (strong, nonatomic) NSURL *sensor_info_path;

@end

@implementation SensorInfoController
- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
