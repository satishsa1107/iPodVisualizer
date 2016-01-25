//
//  ViewController.h
//  iPodVisualizer
//
//  Created by Xinrong Guo on 13-3-23.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class GPUImageVideoCamera;

@interface MainViewController : UIViewController <MPMediaPickerControllerDelegate>

@property (strong, nonatomic) GPUImageVideoCamera *videoCamera;

-(void) saveUserData;
-(void) loadUserData;

@end
