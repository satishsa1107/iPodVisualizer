//
//  EffectsViewController.m
//  iPodVisualizer
//
//  Created by Sagar Satish on 2015-12-02.
//  Copyright © 2015 Xinrong Guo. All rights reserved.
//

#import "EffectsViewController.h"
#import "GPUImage.h"
#import "ShaderController.h"
#import "MainViewController.h"
#import "EffectItem.h"

@interface EffectsViewController ()

// View elements
@property (strong, nonatomic) IBOutlet UISlider        *sliderView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBarView;
@property (strong, nonatomic) IBOutlet UIView          *cameraView;
@property (strong, nonatomic) IBOutlet UIPickerView    *pickerView;
@property (strong, nonatomic)          GPUImageView    *filterView;

// App objects
@property (strong, nonatomic) ShaderController         *filter;
@property (strong, nonatomic) NSMutableArray           *effects;
@property (strong, nonatomic) EffectItem               *active_effect;
@property (strong, nonatomic) NSTimer                  *timer;

@end

@implementation EffectsViewController

- (id) init
{
    self = [super init];
    if (self != nil) {
        self.filter = [ShaderController shaderControllerInstance];
        self.effects = [[NSMutableArray alloc] init];
        
        /////////////////////////
        // Create Effect Items //
        /////////////////////////
        
        // (1) Color distortion
        EffectItem *color_effect = [[EffectItem alloc] init];
        color_effect.name = @"CoLoR";
        color_effect.image = nil;
        color_effect.value = 1.73;
        color_effect.min_value = 1.73;
        color_effect.max_value = 10.0;
        color_effect.default_value = 1.73;
        [_effects addObject:color_effect];
        
        // (2) Fisheye distortion
        EffectItem *fisheye_effect = [[EffectItem alloc] init];
        fisheye_effect.name = @"FiShEyE";
        fisheye_effect.image = nil;
        fisheye_effect.value = 1.0;
        fisheye_effect.min_value = 1.0;
        fisheye_effect.max_value = 10.0;
        fisheye_effect.default_value = 1.0;
        [_effects addObject:fisheye_effect];
        
        //////////////////////////
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set up camera view
    [self configureCameraView];
    
    // Set active effect
    _active_effect = [_effects objectAtIndex:0];
    
    // Update slider view
    _sliderView.minimumValue = _active_effect.min_value;
    _sliderView.maximumValue = _active_effect.max_value;
    [_sliderView setValue:_active_effect.value animated:YES];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    // Set timed call to render screen every 1/60 of a second
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self
                                   selector:@selector(updatePowerMeter) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_timer invalidate];
}

// Camera configuration
- (void)configureCameraView {
    
    _filterView = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.cameraView.frame.size.width, self.cameraView.frame.size.height)];
    
    [self.cameraView addSubview:_filterView];
    [_filter addTarget:_filterView];
    
}

- (IBAction) returnToMainViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) updatePowerMeter
{
    static CGFloat scale = 0.0;
    static CGFloat factor;
    if (scale > 1.5) {
        factor = -0.05;
    }
    else if (scale <= 0) {
        factor = +0.05;
    }
    else {
        factor = factor;
    }
    scale = scale+factor;
    [_filter setAudioPowerDistortion:scale];
}

-(IBAction)resetValues:(id)sender
{
    [self setDefaultEffectValues];
}

- (void) setDefaultEffectValues
{
    [_filter setColorDistortion:  ((EffectItem *)[_effects objectAtIndex:0]).default_value];
    [_filter setFishEyeDistortion:((EffectItem *)[_effects objectAtIndex:1]).default_value];
}

#pragma PickerViewController Data Source and Delegate methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_effects count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    EffectItem *temp_item = [_effects objectAtIndex:row];
    return temp_item.name;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // Set active effect
    _active_effect = [_effects objectAtIndex:row];
    
    // Update slider view
    _sliderView.minimumValue = _active_effect.min_value;
    _sliderView.maximumValue = _active_effect.max_value;
    [_sliderView setValue:_active_effect.value animated:YES];
    

}

#pragma SliderView delegate
- (IBAction)UpdateSliderValue:(id)sender
{
    CGFloat sliderValue = [(UISlider *)sender value];
    _active_effect.value = sliderValue;
    
    // Update shader uniforms
    if ([_active_effect.name isEqualToString:@"CoLoR"]) {
        [_filter setColorDistortion:_active_effect.value];
    }
    else if ([_active_effect.name isEqualToString:@"FiShEyE"]) {
        [_filter setFishEyeDistortion:_active_effect.value];
    }
    else {
        NSLog (@"ERROR: Illegal effect selection");
    }
}

@end
