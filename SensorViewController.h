//
//  SensorViewController.h
//  BonjourWeb
//
//  Created by Edward Baker on 16/03/2014.
//
//

#import <UIKit/UIKit.h>

@interface SensorViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIButton *deltemelater;

@property (retain, nonatomic) IBOutlet UILabel *sensorNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *sensorMeasureLabel;
@property (retain, nonatomic) IBOutlet UILabel *sensorUnitLabel;
@property (strong, nonatomic) NSNetService *service;
@property (strong, nonatomic) NSURL *sensor_request_url;
@property (strong, nonatomic) NSURL *sensor_info_url;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIViewController  *sensorInfoViewController;
@end
