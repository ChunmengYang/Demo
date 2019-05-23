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
@property (nonatomic, assign) Boolean isScanning;

@property(nonatomic, retain) CBPeripheralManager *peripheralManager;
@property(nonatomic, retain) CLBeaconRegion *beaconData;
@property (nonatomic, assign) Boolean isAdvertising;

@property (retain, nonatomic) IBOutlet UILabel *beaconLabel;
@property (retain, nonatomic) IBOutlet UILabel *msgLabel;
@end

@implementation BeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.beaconLabel.textColor = [UIColor purpleColor];
    self.beaconLabel.numberOfLines = 0;
    [self.beaconLabel setText:@"Scanning"];
    
    self.msgLabel.textColor = [UIColor purpleColor];
    self.msgLabel.numberOfLines = 0;
    [self.msgLabel setText:@"Click Advertise Button"];
    
    self.isScanning = false;
    self.isAdvertising = false;
    NSLog(@"================viewDidLoad End================");
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startScan];
    NSLog(@"================viewWillAppear End================");
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopScan];
    [self stopAdvertising];
    
    NSLog(@"================viewWillDisappear End================");
}

- (void)startScan {
    if (self.isScanning) {
        return;
    }
    
    self.localtionManager = [[CLLocationManager alloc] init];
    self.localtionManager.delegate = self;
    self.beaconRegion = [[CLBeaconRegion alloc]
                         initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"]
                         identifier:@"media"];
    
    if (![CLLocationManager locationServicesEnabled]) {
        //需要打开定位服务
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:nil
                                    message:@"需要打开定位服务才可以扫描到信标"
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    // 有定位权限
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse
        || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        
        //定位功能可用
        [self.localtionManager startMonitoringForRegion:self.beaconRegion];
        [self.localtionManager startRangingBeaconsInRegion:self.beaconRegion];
        
        self.isScanning = true;
        NSLog(@"================Scanning================");
    } else {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            NSLog(@"================kCLAuthorizationStatusDenied================");
            //必须获得定位权限
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:nil
                                        message:@"需要打开位置权限才可以扫描到信标"
                                        preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addAction:cancelAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        if ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusNotDetermined) {
            //请求定位权限
            [self.localtionManager requestWhenInUseAuthorization];
        }
    }
}

- (void)stopScan {
    NSLog(@"================stopScan Start================");
    
    if (self.localtionManager != nil) {
        [self.localtionManager stopMonitoringForRegion:self.beaconRegion];
        [self.localtionManager stopRangingBeaconsInRegion:self.beaconRegion];
    }
    
    self.localtionManager = nil;
    self.beaconRegion = nil;
    
    NSLog(@"================stopScan End================");
}

// 开启作为iBeacon，只需要打开蓝牙
-(void)startAdvertising {
    NSLog(@"================startAdvertising Start================");
    if (self.isAdvertising) {
        return;
    }
    
    NSString *uuid = @"FDA50693-A4E2-4FB1-AFCF-C6EB07647825";
    int major = 5;
    int minor = 1505;
    
    if (nil == uuid || [uuid isEqualToString:@""] || major <= 0 || minor <= 0) {
        return;
    }
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    self.beaconData = [[CLBeaconRegion alloc]
                       initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid]
                       major:major
                       minor:minor
                       identifier:@"media"];
    
    NSLog(@"================startAdvertising End================");
}

-(void)stopAdvertising {
    NSLog(@"================stopAdvertising Start================");
    
    if (self.peripheralManager != nil) {
        [self.peripheralManager stopAdvertising];
    }
    
    self.peripheralManager = nil;
    self.beaconData = nil;
    
    self.isAdvertising = false;
    
    NSLog(@"================stopAdvertising End================");
}

- (IBAction)Advertise:(id)sender {
    [self startAdvertising];
}

- (IBAction)Back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"================Page Back================");
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways|| status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self startScan];
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    //打印所有iBeacon的信息
    
    NSLog(@"================didRangeBeacons:%ld================", beacons.count);
    for (CLBeacon* beacon in beacons) {
        NSLog(@"uuid: %@ \nrssi :%ld\nmajor: %d, minor: %d", beacon.proximityUUID.UUIDString, beacon.rssi, beacon.major.intValue, beacon.minor.intValue);
        
        [self.beaconLabel setText:[NSString stringWithFormat:@"uuid: %@ \nrssi :%ld\nmajor: %d, minor: %d", beacon.proximityUUID.UUIDString, beacon.rssi, beacon.major.intValue, beacon.minor.intValue]];
    }
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBManagerStatePoweredOn) {
        if (self.beaconData) {
            NSDictionary *peripheralData = nil;
            peripheralData = [self.beaconData peripheralDataWithMeasuredPower:nil];
            if (peripheralData) {
                [self.peripheralManager startAdvertising:peripheralData];
                return;
            }
        }
    }
    
    [self.msgLabel setText:@"需要打开蓝牙才能设置为信标"];
}

-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if (error) {
        [self.msgLabel setText:@"设置为信标失败"];
    } else {
        self.isAdvertising = true;
        
        [self.msgLabel setText:[NSString stringWithFormat:@"uuid: %@,\nmajor: %d, minor: %d \nAdvertising", self.beaconData.proximityUUID.UUIDString, self.beaconData.major.intValue, self.beaconData.minor.intValue]];
        
        NSLog(@"================Advertising================");
    }
}
@end
