//
//  ViewController.h
//  demo
//
//  Created by ChunmengYang on 2019/3/18.
//  Copyright © 2019年 ChunmengYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <CoreBluetooth/CBPeripheralManager.h>

@interface BeaconViewController : UIViewController<CLLocationManagerDelegate, CBPeripheralManagerDelegate>

@end

