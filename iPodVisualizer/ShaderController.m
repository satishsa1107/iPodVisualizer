//
//  ShaderController.m
//  iPodVisualizer
//
//  Created by Sagar Satish on 2015-10-08.
//  Copyright © 2015 Xinrong Guo. All rights reserved.
//

#import "ShaderController.h"

@interface ShaderController ()

@property(readwrite, nonatomic) CGFloat colorDistortion;
@property(readwrite, nonatomic) CGFloat fisheyeDistortion;
@property(readwrite, nonatomic) CGFloat audioPowerDistortion;


@end


@implementation ShaderController

// Singleton function
+(id) shaderControllerInstance
{
    static ShaderController *shaderController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shaderController = [[self alloc] init];
    });
    return shaderController;
}

// Initialization function
-(id) init
{
    NSString *vShaderFilename = @"CustomShader";
    NSString *fShaderFilename = @"CustomShader";
    
    NSString *vShaderPathname = [[NSBundle mainBundle] pathForResource:vShaderFilename ofType:@"vsh"];
    NSString *vShaderString = [NSString stringWithContentsOfFile:vShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    NSString *fShaderPathname = [[NSBundle mainBundle] pathForResource:fShaderFilename ofType:@"fsh"];
    NSString *fShaderString = [NSString stringWithContentsOfFile:fShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    if (!(self = [super initWithVertexShaderFromString:vShaderString
                              fragmentShaderFromString:fShaderString]))
    {
        return nil;
    }
    
    // Custom Shader Variables
    colorDistortionUniform = [filterProgram uniformIndex:@"colorDistortion"];
    fisheyeDistortionUniform = [filterProgram uniformIndex:@"fisheyeDistortion"];
    audioPowerDistortionUniform = [filterProgram uniformIndex:@"audioPowerDistortion"];
    
    // return
    return self;
}

- (void)setAudioPowerDistortion:(CGFloat)newValue;
{
    _audioPowerDistortion = newValue;
    NSLog (@"audioPowerDistortion = %f", _audioPowerDistortion);
    
    [self setFloat:_audioPowerDistortion forUniform:audioPowerDistortionUniform program:filterProgram];
}

- (void)setColorDistortion:(CGFloat)newValue;
{
    _colorDistortion = newValue;
    NSLog (@"ColorDistortion = %f", _colorDistortion);
    [self setFloat:_colorDistortion forUniform:colorDistortionUniform program:filterProgram];
}

- (CGFloat) getColorDistortion
{
    return _colorDistortion;
}

- (void) setFishEyeDistortion:(CGFloat)newValue;
{
    _fisheyeDistortion = newValue;
    NSLog (@"FishEyeDistortion = %f", _fisheyeDistortion);
    [self setFloat:_fisheyeDistortion forUniform:fisheyeDistortionUniform program:filterProgram];
}

- (CGFloat) getFishEyeDistortion
{
    return _fisheyeDistortion;
}


@end
