//
//  IndexViewController.m
//  demo
//
//  Created by ChunmengYang on 2019/3/18.
//  Copyright © 2019年 ChunmengYang. All rights reserved.
//

#import "IndexViewController.h"

@interface IndexViewController ()
@end

@implementation IndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"================viewDidLoad End================");
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"================IndexViewController viewWillAppear================");
}
- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"================IndexViewController viewWillDisappear================");
}
@end
