//
//  ViewController.m
//  demo
//
//  Created by ChunmengYang on 2019/3/18.
//  Copyright © 2019年 ChunmengYang. All rights reserved.
//

#import "BeaconViewController.h"
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CoreLocation.h>

@interface BeaconViewController ()
@property(nonatomic, retain) CLLocationManager *localtionManager;
@property(nonatomic, retain) CLBeaconRegion *beaconRegion;

@property (retain, nonatomic) IBOutlet UILabel *label;
@end

@implementation BeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.label.textColor = [UIColor purpleColor];
    self.label.numberOfLines = 0;
    [self.label setText:@"Scanning"];
    NSLog(@"================viewDidLoad End================");
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.localtionManager = [[CLLocationManager alloc] init];
    self.localtionManager.delegate = self;
    self.beaconRegion = [[CLBeaconRegion alloc]
                         initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"74278BDA-B644-4520-8F0C-720EAF059935"]
                         identifier:@"media"];
    
    // 有定位权限
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse
        || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        
        if ([CLLocationManager locationServicesEnabled]) {
            //定位功能可用
            [self.localtionManager startMonitoringForRegion:self.beaconRegion];
            [self.localtionManager startRangingBeaconsInRegion:self.beaconRegion];
            NSLog(@"================Scanning================");
        } else {
            //需要打开定位服务
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:nil
                                        message:@"扫描信标需要使用您的定位服务"
                                        preferredStyle:UIAlertControllerStyleAlert];
            
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"点击取消");
            }];
            [alert addAction:cancelAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            NSLog(@"================kCLAuthorizationStatusDenied================");
            //必须获得定位权限
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:nil
                                        message:@"扫描信标需要使用您的定位服务"
                                        preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"点击取消");
            }];
            [alert addAction:cancelAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        if ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusNotDetermined) {
            //请求定位权限
            [self.localtionManager requestWhenInUseAuthorization];
        }
    }
    NSLog(@"================viewWillAppear End================");
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.localtionManager stopMonitoringForRegion:self.beaconRegion];
    [self.localtionManager stopRangingBeaconsInRegion:self.beaconRegion];
    
    [self.localtionManager release];
    [self.beaconRegion release];
    [self.label release];
    
    NSLog(@"================viewWillDisappear End================");
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways|| status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.localtionManager startMonitoringForRegion:self.beaconRegion];
        [self.localtionManager startRangingBeaconsInRegion:self.beaconRegion];
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    //打印所有iBeacon的信息
    
    NSLog(@"================didRangeBeacons:%ld================", beacons.count);
    for (CLBeacon* beacon in beacons) {
        NSLog(@"uuid: %@,rssi :%ld-====mj%d-====min%d", beacon.proximityUUID.UUIDString, beacon.rssi, beacon.major.intValue, beacon.minor.intValue);
        
        [self.label setText:[NSString stringWithFormat:@"uuid: %@,\nrssi :%ld\n-====mj%d-====min%d", beacon.proximityUUID.UUIDString, beacon.rssi, beacon.major.intValue, beacon.minor.intValue]];
    }
}
- (void)dealloc {
    [_label release];
    [super dealloc];
}
- (IBAction)Back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"================Scan iBeacon Back================");
}
@end
