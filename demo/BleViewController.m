//
//  BLEViewController.m
//  demo
//
//  Created by ChunmengYang on 2019/4/1.
//  Copyright © 2019年 ChunmengYang. All rights reserved.
//
#import "BleViewController.h"
#import <CoreBluetooth/CBCentralManager.h>
#import <CoreBluetooth/CBPeripheral.h>
#import <CoreBluetooth/CBService.h>
#import <CoreBluetooth/CBCharacteristic.h>
#import <CoreBluetooth/CBUUID.h>

NSString *const bleName = @"Blank";
NSString *const serviceUUID = @"0E61690A-B38D-43A0-9394-1FA76DD65E80";
NSString *const readCharacteristicUUID = @"10E662A7-C116-41D5-9C25-6C6996FFB06A";
NSString *const writeNoResponseCharacteristicUUID = @"B309B160-234B-4015-900A-5C08E07770BC";
NSString *const writeCharacteristicUUID = @"8AD25B3F-82EF-47C9-82AA-6910C7D29BAD";

@interface BleViewController()<CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, retain) CBCentralManager *mCentral;
@property (nonatomic, retain) CBPeripheral *mPeripheral;
@property (nonatomic, assign) Boolean canScan;
@property (nonatomic, assign) Boolean isConnected;

@property (retain, nonatomic) IBOutlet UILabel *msgLabel;
@property (retain, nonatomic) IBOutlet UIButton *connButton;
@property (retain, nonatomic) IBOutlet UILabel *readLabel;
@property (retain, nonatomic) IBOutlet UIButton *readButton;
@property (retain, nonatomic) IBOutlet UIButton *writeButton;
@end

@implementation BleViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.msgLabel.textColor = [UIColor purpleColor];
    self.msgLabel.numberOfLines = 0;
    [self.msgLabel setText:@"Please click the Connect button."];
    
    // 设置连接按钮事件
    [self.connButton addTarget:self action:@selector(startScan) forControlEvents:UIControlEventTouchUpInside];
    // 设置读取按钮事件
    [self.readButton addTarget:self action:@selector(read) forControlEvents:UIControlEventTouchUpInside];
    // 设置写入按钮事件
    [self.writeButton addTarget:self action:@selector(writeNoResponse) forControlEvents:UIControlEventTouchUpInside];
    
    self.canScan = false;
    self.isConnected = false;
    if (!_mCentral) {
        _mCentral = [[CBCentralManager alloc] initWithDelegate:self
                                                         queue:dispatch_get_main_queue()
                                                       options:nil];
    }
    NSLog(@"================viewDidLoad End================");
}

-(void)startScan {
    if (self.canScan && !self.isConnected) {
        // 开始搜索外设
        [self.msgLabel setText:@"Scanning"];
        [self.mCentral scanForPeripheralsWithServices:nil   // 通过某些服务筛选外设
                                              options:nil]; // dict条件
    }
}

-(void)read {
    if (nil != self.mPeripheral && self.mPeripheral.state == CBPeripheralStateConnected) {
        
        for (CBService *service in self.mPeripheral.services) {
            if ([serviceUUID isEqualToString:service.UUID.UUIDString]) {
                for (CBCharacteristic *cha in service.characteristics) {
                    if ([writeNoResponseCharacteristicUUID isEqualToString:cha.UUID.UUIDString]) {
                        if (cha.properties & CBCharacteristicPropertyRead) {
                            [self.mPeripheral readValueForCharacteristic:cha];
                        }
                        
                    }
                }
            }
        }
    }
}

-(void)write {
    if (nil != self.mPeripheral && self.mPeripheral.state == CBPeripheralStateConnected) {
        
        for (CBService *service in self.mPeripheral.services) {
            if ([serviceUUID isEqualToString:service.UUID.UUIDString]) {
                for (CBCharacteristic *cha in service.characteristics) {
                    if ([writeCharacteristicUUID isEqualToString:cha.UUID.UUIDString]) {
                        if (cha.properties & CBCharacteristicPropertyWrite) {
                            NSString *value = @"好的";
                            NSData* data = [value dataUsingEncoding:NSUTF8StringEncoding];
                            [self.mPeripheral writeValue:data
                                       forCharacteristic:cha
                                                    type:CBCharacteristicWriteWithResponse];
                        }
                    }
                }
            }
        }
    }
}

-(void)writeNoResponse {
    if (nil != self.mPeripheral && self.mPeripheral.state == CBPeripheralStateConnected) {
        
        for (CBService *service in self.mPeripheral.services) {
            if ([serviceUUID isEqualToString:service.UUID.UUIDString]) {
                for (CBCharacteristic *cha in service.characteristics) {
                    if ([writeNoResponseCharacteristicUUID isEqualToString:cha.UUID.UUIDString]) {
                        if (cha.properties & CBCharacteristicPropertyWriteWithoutResponse) {
                            NSString *value = @"好的";
                            NSData* data = [value dataUsingEncoding:NSUTF8StringEncoding];
                            [self.mPeripheral writeValue:data
                                       forCharacteristic:cha
                                                    type:CBCharacteristicWriteWithoutResponse];
                        }
                    }
                }
            }
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 停止扫描
    if([self.mCentral isScanning]){
        [self.mCentral stopScan];
        NSLog(@"================Stop Scan================");
    }
    // 停止连接
    if(nil != self.mPeripheral && self.mPeripheral.state == CBPeripheralStateConnecting){
        [self.mCentral cancelPeripheralConnection:self.mPeripheral];
        NSLog(@"================Cancel Peripheral Connection================");
    }
    NSLog(@"================viewWillDisappear End================");
}

// 只要中心管理者初始化,就会触发此代理方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStateUnknown:
            [self.msgLabel setText:@"蓝牙状态未知"];
            break;
        case CBManagerStateResetting:
            [self.msgLabel setText:@"蓝牙状态重置中"];
            break;
        case CBManagerStateUnsupported:
            [self.msgLabel setText:@"不支持蓝牙"];
            break;
        case CBManagerStateUnauthorized:
            [self.msgLabel setText:@"蓝牙未授权"];
            break;
        case CBManagerStatePoweredOff:
            [self.msgLabel setText:@"蓝牙关闭状态"];
            break;
        case CBManagerStatePoweredOn:
            // 蓝牙开启状态
            self.canScan = true;
            break;
        default:
            break;
    }
}

// 发现外设后调用的方法
- (void)centralManager:(CBCentralManager *)central // 中心管理者
 didDiscoverPeripheral:(CBPeripheral *)peripheral // 外设
     advertisementData:(NSDictionary *)advertisementData // 外设携带的数据
                  RSSI:(NSNumber *)RSSI // 外设发出的蓝牙信号强度
{
    NSLog(@"=========搜索到设备名：%@，设备ID：%@=========",peripheral.name,peripheral.identifier);
    // 发现完之后就是进行连接
    if([peripheral.name isEqualToString:bleName]){
        // 停止扫描
        if([self.mCentral isScanning]){
            [self.mCentral stopScan];
            NSLog(@"================Stop Scan================");
        }
        
        
        self.mPeripheral = peripheral;
        self.mPeripheral.delegate = self;
        [self.mCentral connectPeripheral:peripheral options:nil];
        
        [self.msgLabel setText:@"Conneting"];
    }
}


// 外设连接成功
- (void)centralManager:(CBCentralManager *)central // 中心管理者
  didConnectPeripheral:(CBPeripheral *)peripheral // 外设
{
    NSLog(@"=========设备连接成功，设备名：%@=========", peripheral.name);
    [self.msgLabel setText:@"Connected"];
    self.isConnected = true;
    
    //发现服务, 传nil代表不过滤
    [self.mPeripheral discoverServices:nil];
}

// 外设连接失败
- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    NSLog(@"=========设备连接失败，设备名：%@==========", peripheral.name);
    [self.msgLabel setText:@"Fail Connect"];
    self.isConnected = false;
}

// 外设连接丢失
- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    NSLog(@"=========设备丢失连接，设备名：%@=========", peripheral.name);
    [self.msgLabel setText:@"DisConnected"];
    self.isConnected = false;
}


// 发现外设的服务后调用的方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    // 是否获取失败
    if (error) {
        NSLog(@"=========设备获取服务失败，设备名：%@=========", peripheral.name);
        return;
    }
    for (CBService *service in peripheral.services) {
        NSLog(@"=========设备获取服务成功，服务名：%@，服务UUID：%@，服务数量：%lu=========",service,service.UUID,peripheral.services.count);
        //外设发现特征
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

// 从服务中发现外设特征的时候调用的代理方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if(error){
        NSLog(@"设备获取特征失败，设备名：%@", peripheral.name);
        return;
    }
    /**
     CBCharacteristicPropertyRead                                                    = 0x02,
     CBCharacteristicPropertyWriteWithoutResponse                                    = 0x04,
     CBCharacteristicPropertyWrite                                                   = 0x08,
     CBCharacteristicPropertyNotify                                                  = 0x10,
     */
    for (CBCharacteristic *cha in service.characteristics) {
        NSLog(@"设备获取特征成功，服务名：%@，特征值名：%@，特征UUID：%@，特征数量：%lu",service,cha,cha.UUID,service.characteristics.count);
    }
}

// 读取数据回调
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if(error){
        NSLog(@"数据读取失败，UUID：%@", characteristic.UUID.UUIDString);
        return;
    }
    
    NSString *value = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSLog(@"数据读取成功, UUID: %@, Value: %@", characteristic.UUID.UUIDString, value);
    
    [self.readLabel setText:value];
}

// 写入数据回调
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if(error){
        NSLog(@"数据写入失败，UUID：%@", characteristic.UUID.UUIDString);
        return;
    }
    
    NSString *value = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSLog(@"=========数据写入成功, UUID：%@，Value：%@=========", characteristic.UUID.UUIDString, value);
}
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"================Ble Back================");
}
@end

