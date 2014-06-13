//
//  SensorViewController.m
//  BonjourWeb
//
//  Created by Edward Baker on 16/03/2014.
//
//

#import "SensorViewController.h"
#import "SensorInfoController.h"
#include <arpa/inet.h>

@interface SensorViewController ()

@end

@implementation SensorViewController
- (IBAction)sensorInfoButton:(id)sender {
    self.sensorInfoViewController = [[SensorInfoController alloc] initWithNibName:@"SensorInfoController" bundle:nil];
    [self presentViewController:self.sensorInfoViewController animated:YES completion:nil];
}
- (IBAction)BackButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeSensorControl:(id)sender {
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
    
    // Construct the URL including the port number
	// Also use the path, username and password fields that can be in the TXT record
	NSDictionary* dict = [[NSNetService dictionaryFromTXTRecordData:[self.service TXTRecordData]] retain];
	NSString *host = [self.service hostName];
    
    host = [host substringToIndex:[host length] - 1];
    
    NSData* address = [self.service addresses][0];
    struct sockaddr_in *socketAddress = (struct sockaddr_in *) [address bytes];
    host = [NSString stringWithUTF8String:inet_ntoa(socketAddress->sin_addr)];
    
	
	NSString* user = [self copyStringFromTXTDict:dict which:@"u"];
	NSString* pass = [self copyStringFromTXTDict:dict which:@"p"];
	
	NSString* portStr = @"";
   
    
    
    // NSData* txtRec = [service TXTRecordData];
	
	// Note that [NSNetService port:] returns an NSInteger in host byte order
	NSInteger port = [self.service port];
	if (port != 0 && port != 80)
        portStr = [[NSString alloc] initWithFormat:@":%d",port];
	
	NSString* path = [self copyStringFromTXTDict:dict which:@"OSDL"];
	if (!path || [path length]==0) {
        [path release];
        path = [[NSString alloc] initWithString:@"/"];
	} else if (![[path substringToIndex:1] isEqual:@"/"]) {
        NSString *tempPath = [[NSString alloc] initWithFormat:@"/%@",path];
        [path release];
        path = tempPath;
	}
	
	NSString* string = [[NSString alloc] initWithFormat:@"http://%@%@%@%@%@",
                        pass?pass:@"",
                        (user||pass)?@"@":@"",
                        host,
                        portStr,
                        path];
    

    	NSURL *url = [[NSURL alloc] initWithString:string];
    
    
	NSData *sensorData = [NSData dataWithContentsOfURL:url];

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:sensorData options:0 error:&error];
    
    NSDictionary *first_sensor = [json objectForKey:@"sensors"][0];
    NSDictionary *first_sensor_name = [first_sensor objectForKey:@"1"][0];
    NSString *sensor_name = [first_sensor_name objectForKey:@"name"];
    
    NSDictionary *first_sensor_infopath = [first_sensor objectForKey:@"1"][1];
    NSString *info_path = [first_sensor_infopath objectForKey:@"data_url"];
    
    self.sensor_info_url = [[NSURL alloc]initWithString:info_path];
    
    NSDictionary *first_sensor_reqpath = [first_sensor objectForKey:@"1"][2];
    NSString *request_path = [first_sensor_reqpath objectForKey:@"request_path"];
    
    self.sensorNameLabel.text = sensor_name;

    string = [[NSString alloc] initWithFormat:@"http://%@%@%@%@%@",
                        pass?pass:@"",
                        (user||pass)?@"@":@"",
                        host,
                        portStr,
                        request_path];
    self.sensor_request_url= [[NSURL alloc] initWithString:string];
    
    NSData *sensorReq = [NSData dataWithContentsOfURL:self.sensor_request_url];
    NSDictionary *req_json = [NSJSONSerialization JSONObjectWithData:sensorReq options:0 error:&error];
    
    NSString* sensor_measurement = [req_json objectForKey:@"basic_value"];
    NSString* sensor_unit = [req_json objectForKey:@"basic_unit"];
    
    self.sensorMeasureLabel.text = sensor_measurement;
    self.sensorUnitLabel.text = sensor_unit;
    
	[url release];
	[string release];
	[portStr release];
	[dict release];
	[path release];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateMeasurement:) userInfo:nil repeats:YES];
}


-(void)updateMeasurement:(NSTimer *)incomingTimer {
    NSError *error;
    NSData *sensorReq = [NSData dataWithContentsOfURL:self.sensor_request_url];
    NSDictionary *req_json = [NSJSONSerialization JSONObjectWithData:sensorReq options:0 error:&error];
    
    NSString* sensor_measurement = [req_json objectForKey:@"basic_value"];
    
    self.sensorMeasureLabel.text = sensor_measurement;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)copyStringFromTXTDict:(NSDictionary *)dict which:(NSString*)which {
	// Helper for getting information from the TXT data
	NSData* data = [dict objectForKey:which];
	NSString *resultString = nil;
	if (data) {
		resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	return resultString;
}

- (void)dealloc {
    [_sensorNameLabel release];
    [_sensorMeasureLabel release];
    [_sensorUnitLabel release];
    [_deltemelater release];
    [super dealloc];
}
- (IBAction)timerChangeButton:(id)sender {
    //Invalidate and clear old timer
    [self.timer invalidate];
    self.timer = nil;
    int interval = 1;
    
    UISegmentedControl *segControl = (UISegmentedControl *)sender;
    int i = [segControl selectedSegmentIndex];
    switch (i) {
        case 1:
            interval = 10;
            break;
        case 2:
            interval = 30;
            break;
        case 3:
            interval = 60;
            break;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateMeasurement:) userInfo:nil repeats:YES];
}
@end
