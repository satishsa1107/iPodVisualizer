//
//  ViewController.m
//

#import "MainViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "ShaderController.h"
#import "MeterTable.h"
#import "GalleryController.h"
#import "EffectsViewController.h"
#import "GalleryItem.h"
#import <GPUImage.h>

@interface MainViewController ()

// Views
@property (strong, nonatomic) GPUImageView *filterView;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UINavigationBar *navBar;
@property (strong, nonatomic) UIButton *recordButton;
@property (strong, nonatomic) UIToolbar *toolBar;

// App objects
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) GPUImageMovieWriter *movieWriter;
@property (strong, nonatomic) NSArray *playItems;
@property (strong, nonatomic) NSTimer *timer;

// Controllers
@property (strong, nonatomic) ShaderController *filter;
@property (strong, nonatomic) GalleryController *galleryVC;
@property (strong, nonatomic) EffectsViewController *effectsVC;

@end

@implementation MainViewController {
    BOOL _isBarHide;
    BOOL _isFXBarHide;
    BOOL _isPlaying;
    BOOL _isCameraOpen;
    
    MeterTable meterTable;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViews];
    [self configureAudioSession];
    [self configureCamera];
    [self configureAudioPlayer];
    
    // Set up Gallery view controller
    self.galleryVC = [[GalleryController alloc] init];
    [self.galleryVC loadUserData];
    
    // Set up Effects view controller
    self.effectsVC = [[EffectsViewController alloc] init];
    // Default all effect values
    [_effectsVC setDefaultEffectValues];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self toggleBars];
    
    // Set timed call to render screen every 1/60 of a second
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self
                                                selector:@selector(updatePowerMeter) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    // Invalidate timer calls
    [_timer invalidate];
    
}


// View Configuration
- (void)configureViews {
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    CGRect frame = self.view.frame;
    
    // Background View
    self.backgroundView = [[UIView alloc] initWithFrame:frame];
    [_backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_backgroundView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:_backgroundView];
    
    // Title Bar
    self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, -32, frame.size.width, 32)];
    [_navBar setBarStyle:UIBarStyleBlackTranslucent];
    [_navBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    UINavigationItem *navTitleItem = [[UINavigationItem alloc] initWithTitle:@"Psilo"];
    [_navBar pushNavigationItem:navTitleItem animated:NO];
    [self.view addSubview:_navBar];
    
    // Record Button
    UIImage *recordImg = [UIImage imageNamed:@"record.png"];
    self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _recordButton.frame = CGRectMake(220 , 200, 120, 120);
    [_recordButton setBackgroundImage:recordImg forState:UIControlStateNormal];
    [_recordButton addTarget:self action:@selector(playPause) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_recordButton];
 
    // Main ToolBar
    self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 320, frame.size.width, 32)];
    
    [_toolBar setBackgroundImage:[UIImage new]
                  forToolbarPosition:UIToolbarPositionAny
                          barMetrics:UIBarMetricsDefault];
    [_toolBar setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.5 ]];
    [_toolBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    UIBarButtonItem *galleryBBI = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gallery.png"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(gotoGallery)];
    
    UIBarButtonItem *musicBBI = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"music.png"]
                                                                 style: UIBarButtonItemStylePlain
                                                                target: self
                                                                action: @selector(pickSong)];
    
    UIBarButtonItem *effectsBBI = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"third_eye.png"]
                                                                  style: UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(gotoEffects)];
    
    UIBarButtonItem *settingsBBI = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"]
                                                                    style: UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:nil];
    
    UIBarButtonItem *spaceBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                 target:nil
                                                                                 action:nil];
    self.playItems = [NSArray arrayWithObjects:galleryBBI, spaceBBI, musicBBI, spaceBBI, effectsBBI, spaceBBI, settingsBBI, nil];
    [_toolBar setItems:_playItems];
    [self.view addSubview:_toolBar];

    // Set Application state
    _isBarHide = YES;
    _isPlaying = NO;
    _isFXBarHide = YES;

    // Enable tap gestures
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    [_backgroundView addGestureRecognizer:tapGR];
}

// Audio Configuration

- (void)configureAudioPlayer {
    NSURL *audioFileURL = [[NSBundle mainBundle] URLForResource:@"DemoSong" withExtension:@"m4a"];
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [_audioPlayer setNumberOfLoops:-1];
    [_audioPlayer setMeteringEnabled:YES];
}

- (void)configureAudioSession {
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    if (error) {
        NSLog(@"Error setting category: %@", [error description]);
    }
}

// Camera configuration
- (void)configureCamera {
    
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1920x1080 cameraPosition:AVCaptureDevicePositionBack];
    _videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeLeft;
    _videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    _videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    _filter = [ShaderController shaderControllerInstance];
    
    _filterView = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.backgroundView.frame.size.width, self.backgroundView.frame.size.height)];
    
    [_backgroundView addSubview:_filterView];
    
    [_videoCamera addTarget:_filter];
    [_filter addTarget:_filterView];
    
    [_videoCamera startCameraCapture];
    
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)tapGR {
    [self toggleBars];
}

- (void)toggleBars {
    CGFloat navBarDis = -32;
    CGFloat toolBarDis = 32;
    if (_isBarHide ) {
        navBarDis = -navBarDis;
        toolBarDis = -toolBarDis;
    }
    
    // Animate current transition
    [UIView animateWithDuration:0.3 animations:^{
        CGPoint navBarCenter = _navBar.center;
        navBarCenter.y += navBarDis;
        [_navBar setCenter:navBarCenter];
        
        CGPoint toolBarCenter = _toolBar.center;
        toolBarCenter.y += toolBarDis;
        [_toolBar setCenter:toolBarCenter];
    }];
    
    _isBarHide = !_isBarHide;
}


-(void) gotoGallery
{
    // Pause video/audio here
    [_audioPlayer pause];
    [self stopVideo];
    _isPlaying = FALSE;
    
    // Present View controller
    [self presentViewController:_galleryVC animated:YES completion:nil];
}

-(void) gotoEffects
{
    // Pause video/audio here
    [_audioPlayer pause];
    [self stopVideo];
    _isPlaying = FALSE;
    
    // Present View controller
    [self presentViewController:_effectsVC animated:YES completion:nil];
}

-(void) saveUserData
{
    [self.galleryVC saveUserData];
}

-(void) loadUserData
{
    [self.galleryVC loadUserData];
}

#pragma mark - Video recording
- (void)recordVideo {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *prefixString = @"pSilo_Video";
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@.m4v", prefixString, guid];
    
    NSLog(@"uniqueFileName: '%@'", uniqueFileName);
    
    NSString *pathToMovie = [path stringByAppendingPathComponent:uniqueFileName];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];

    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(1920.0, 1080.0)];
    _movieWriter.encodingLiveVideo = YES;
    
    [_filter addTarget:_movieWriter];
    
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, 0.0);
    dispatch_after(startTime, dispatch_get_main_queue(), ^(void){
        
        _videoCamera.audioEncodingTarget = _movieWriter;
        [_movieWriter startRecording];
    });
    
    GalleryItem *item = [[GalleryItem alloc] initWithName:uniqueFileName
                                                       url:movieURL
                                                      date:[NSDate date]
                                                     image:nil];
    
    [_galleryVC addGalleryItem:item];
}

- (void) stopVideo {
    
    dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, 0.0);
    dispatch_after(stopTime, dispatch_get_main_queue(), ^(void){
        [_filter removeTarget:_movieWriter];
        _videoCamera.audioEncodingTarget = nil;
        [_movieWriter finishRecording];
    });
}

#pragma mark - Music control

- (void)playPause {
    if (_isPlaying) {
        // Pause video/audio here
        [_audioPlayer pause];
        [self stopVideo];
    }
    else {
        // Play video/audio here
        [_audioPlayer play];
        [self recordVideo];
    }
    _isPlaying = !_isPlaying;
}

- (void)playURL:(NSURL *)url {
    if (_isPlaying) {
        [self playPause]; // Pause the previous audio player
    }

    // Add audioPlayer configurations here
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [_audioPlayer setNumberOfLoops:-1];
    [_audioPlayer setMeteringEnabled:YES];
    
}

- (void)updatePowerMeter
{
    float scale = 0;
    if (_audioPlayer.playing )
    {
        [_audioPlayer updateMeters];
        
        float power = 0.0f;
        for (int i = 0; i < [_audioPlayer numberOfChannels]; i++) {
            power += [_audioPlayer averagePowerForChannel:i];
        }
        power /= [_audioPlayer numberOfChannels];
        
        float level = meterTable.ValueAt(power);
        scale = level;
    }
    // NSLog (@"scale = %f\n", scale);
    [_filter setAudioPowerDistortion:scale];
}

#pragma mark - Media Picker and Delegate

- (void)pickSong {
    
    MPMediaPickerController *songPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    [songPicker setDelegate:self];
    [songPicker setAllowsPickingMultipleItems: NO];
    [self presentViewController:songPicker animated:YES completion:NULL];
}

- (void)mediaPicker:(MPMediaPickerController *) mediaPicker didPickMediaItems:(MPMediaItemCollection *) collection {
  
    // remove the media picker screen
    [self dismissViewControllerAnimated:YES completion:NULL];

    // grab the first selection (media picker is capable of returning more than one selected item,
    // but this app only deals with one song at a time)
    MPMediaItem *item = [[collection items] objectAtIndex:0];
    NSString *title = [item valueForProperty:MPMediaItemPropertyTitle];
    [_navBar.topItem setTitle:title];
  
    // get a URL reference to the selected item
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];

    // pass the URL to playURL:, defined earlier in this file
    [self playURL:url];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *) mediaPicker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
