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

NSString *const ENCODE_UTF8 = @"UTF-8";
NSString *const ENCODE_HEX = @"Hex";

NSString *const bleName = @"Blank";
NSString *const serviceUUID = @"0E61690A-B38D-43A0-9394-1FA76DD65E80";
NSString *const readCharacteristicUUID = @"10E662A7-C116-41D5-9C25-6C6996FFB06A";
NSString *const writeNoResponseCharacteristicUUID = @"B309B160-234B-4015-900A-5C08E07770BC";
NSString *const writeCharacteristicUUID = @"8AD25B3F-82EF-47C9-82AA-6910C7D29BAD";

@interface BleViewController()<CBCentralManagerDelegate, CBPeripheralDelegate, UITextFieldDelegate>
@property (nonatomic, retain) NSString *charsetName;
@property (nonatomic, assign) int expiredSecond;

@property (nonatomic, retain) CBCentralManager *mCentral;
@property (nonatomic, retain) CBPeripheral *mPeripheral;
@property (nonatomic, assign) Boolean canScan;
@property (nonatomic, assign) Boolean isConnected;

@property (retain, nonatomic) IBOutlet UILabel *msgLabel;
@property (retain, nonatomic) IBOutlet UIButton *connButton;
@property (retain, nonatomic) IBOutlet UILabel *readLabel;
@property (retain, nonatomic) IBOutlet UIButton *readButton;
@property (retain, nonatomic) IBOutlet UITextField *writeField;
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
    
    self.writeField.delegate = self;
    
    // BLE数据传输编码格式
    self.charsetName = ENCODE_HEX;
    // 扫描超时时间，单位秒
    self.expiredSecond = 15;
    // 是否可以扫描
    self.canScan = false;
    // 是否已经连接设备
    self.isConnected = false;
    
    if (!_mCentral) {
        _mCentral = [[CBCentralManager alloc] initWithDelegate:self
                                                         queue:dispatch_get_main_queue()
                                                       options:nil];
    }
}

-(void)startScan {
    if (self.canScan && !self.isConnected) {
        // 开始搜索外设
        [self.msgLabel setText:@"Scanning"];
        [self.mCentral scanForPeripheralsWithServices:nil options:nil];
        [self performSelector:@selector(stopScan) withObject:nil afterDelay:self.expiredSecond];
        NSLog(@"================Start Scan================");
    }
}

-(void)stopScan {
    // 停止搜索外设
    if([self.mCentral isScanning]){
        [self.mCentral stopScan];
        [self.msgLabel setText:@"Scan Complete"];
        NSLog(@"================Stop Scan================");
    }
}

-(void)cancelConnection {
    // 停止连接
    if(nil != self.mPeripheral && (self.mPeripheral.state == CBPeripheralStateConnecting || self.mPeripheral.state == CBPeripheralStateConnected)){
        [self.mCentral cancelPeripheralConnection:self.mPeripheral];
        NSLog(@"================Cancel Peripheral Connection================");
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
                            NSString *value = self.writeField.text;
                            NSData* data =  [self toWriteData:value Encode:self.charsetName];
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
                            NSString *value = self.writeField.text;
                            NSData* data =  [self toWriteData:value Encode:self.charsetName];
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
    
    [self stopScan];
    [self cancelConnection];
}

// 只要中心管理者初始化,就会触发此代理方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStateUnknown:
            [self.msgLabel setText:@"蓝牙状态未知"];
            self.canScan = false;
            break;
        case CBManagerStateResetting:
            [self.msgLabel setText:@"蓝牙状态重置中"];
            self.canScan = false;
            break;
        case CBManagerStateUnsupported:
            [self.msgLabel setText:@"不支持蓝牙"];
            self.canScan = false;
            break;
        case CBManagerStateUnauthorized:
            [self.msgLabel setText:@"蓝牙未授权"];
            self.canScan = false;
            break;
        case CBManagerStatePoweredOff:
            [self.msgLabel setText:@"蓝牙关闭状态"];
            self.canScan = false;
            break;
        case CBManagerStatePoweredOn:
            [self.msgLabel setText:@"蓝牙开启状态，可以扫描"];
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
        [self stopScan];
        
        [self cancelConnection];
        self.mPeripheral = nil;
        
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
    
    // 发现服务,传nil代表不过滤
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
        NSLog(@"=========设备获取特征失败，设备名：%@=========", peripheral.name);
        return;
    }
    /**
     CBCharacteristicPropertyRead                                                    = 0x02,
     CBCharacteristicPropertyWriteWithoutResponse                                    = 0x04,
     CBCharacteristicPropertyWrite                                                   = 0x08,
     CBCharacteristicPropertyNotify                                                  = 0x10,
     */
    for (CBCharacteristic *cha in service.characteristics) {
        NSLog(@"=========设备获取特征成功，服务名：%@，特征值名：%@，特征UUID：%@，特征数量：%lu=========",service,cha,cha.UUID,service.characteristics.count);
    }
}

// 读取数据回调
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if(error){
        NSLog(@"=========数据读取失败，UUID：%@=========", characteristic.UUID.UUIDString);
        return;
    }
    
    NSString *value = [self toReadString:characteristic.value Encode:self.charsetName];
    NSLog(@"=========数据读取成功, UUID: %@, Value: %@=========", characteristic.UUID.UUIDString, value);
    
    [self.readLabel setText:value];
}

// 写入数据回调
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if(error){
        NSLog(@"=========数据写入失败，UUID：%@=========", characteristic.UUID.UUIDString);
        return;
    }
    
    NSString *value = [self toReadString:characteristic.value Encode:self.charsetName];
    NSLog(@"=========数据写入成功, UUID：%@，Value：%@=========", characteristic.UUID.UUIDString, value);
}

/*
 * NSData转成UTF-8字符串
 *
 * @param data 需要转换的NSData
 * @return 返回转换完之后的字符串
 * */
-(NSString *)toReadString:(NSData *) data Encode:(NSString *) charsetName {
    if ([ENCODE_UTF8 isEqualToString:charsetName]) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else {
        return [self stringFromHexString:[self convertDataToHexStr: data]];
    }
}
/*
 * 将UTF-8字符串转成NSData
 *
 * @param str 需要转换的字符串
 * @return 返回转换完之后的NSData
 * */
-(NSData *)toWriteData:(NSString *) str Encode:(NSString *) charsetName {
    if ([ENCODE_UTF8 isEqualToString:charsetName]) {
        return [str dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        return [self convertHexStrToData:[self hexStringFromString:str]];
    }
}

// NSData转十六进制字符串
- (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

// 十六进制字符串转NSData
- (NSData *)convertHexStrToData:(NSString *)str
{
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:20];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

// UTF-8字符串转换为十六进制字符串
- (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

// 十六进制转换为UTF-8字符串的
- (NSString *)stringFromHexString:(NSString *)hexString {
    
    if (nil == hexString || [hexString isEqualToString:@""]) {
        return @"";
    }
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:NSUTF8StringEncoding];
    return unicodeString;
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"================Ble Back================");
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
}
@end

