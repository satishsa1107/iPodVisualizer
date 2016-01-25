//
//  ShaderController.h
//  iPodVisualizer
//
//  Created by Sagar Satish on 2015-10-08.
//  Copyright © 2015 Xinrong Guo. All rights reserved.
//

#import <GPUImage.h>

@interface ShaderController : GPUImageFilter
{
    GLint colorDistortionUniform;
    GLint fisheyeDistortionUniform;
    GLint audioPowerDistortionUniform;
}

+ (id) shaderControllerInstance;
- (void) setAudioPowerDistortion:(CGFloat)newValue;
- (void) setColorDistortion:(CGFloat)newValue;
- (CGFloat) getColorDistortion;
- (void) setFishEyeDistortion:(CGFloat)newValue;
- (CGFloat) getFishEyeDistortion;

@end
