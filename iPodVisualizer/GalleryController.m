//
//  GalleryController.m
//  iPodVisualizer
//
//  Created by Sagar Satish on 2015-11-20.
//  Copyright © 2015 Xinrong Guo. All rights reserved.
//

#import "GalleryController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface GalleryController ()

@property (strong, nonatomic) NSMutableArray *files;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;

@end

@implementation GalleryController

- (id) init
{
    self = [super init];
    if (self != nil) {
        self.files = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    // do a quick check of validity of @Documents folder
    [self checkItemsInDatabase];
    
    // Register cellNib
    UINib *cellNib = [UINib nibWithNibName:@"NibCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"cvCell"];
    
    // Register collectionViewLayout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(100, 100);
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = 10;
    [self.collectionView setCollectionViewLayout:flowLayout];
}

- (void) checkItemsInDatabase
{
    
    int file_count = 0;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *folderPath = paths.firstObject;
    NSArray *itemsInFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:NULL];
    
    NSString *itemPath;
    BOOL isDirectory;
    for (NSString *item in itemsInFolder){
        itemPath = [NSString stringWithFormat:@"%@/%@", folderPath, item];
        [[NSFileManager defaultManager] fileExistsAtPath:item isDirectory:&isDirectory];
        if (!isDirectory) {
            file_count = file_count + 1;
        }
    }
    
    if (file_count != [_files count]) {
        NSLog (@"DATA CHECK FAILED!!! file_count = %0d, files count = %0lu", file_count, (unsigned long)[_files count]);
    }
    else {
        NSLog (@"DATA CHECK PASSED. file_count = %0d, files count = %0lu", file_count, (unsigned long)[_files count]);
    }
}

- (void) addGalleryItem:(GalleryItem *)item
{
    [_files addObject:item];
}

- (void) saveUserData
{
    // Convert objects to NSData
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:_files.count];
    for (GalleryItem *item in _files) {
        NSData *itemEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:item];
        [archiveArray addObject:itemEncodedObject];
    }
    
    // Save _files array to UserData
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:archiveArray forKey:@"GalleryItems"];
    [userDefaults synchronize];
}

- (void) loadUserData
{
    // Load _files array from UserData
    NSLog (@"BEFORE FILES = %@", _files);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *arrayOfImages = [userDefaults objectForKey:@"GalleryItems"];
    for (NSData *item in arrayOfImages) [_files addObject:[NSKeyedUnarchiver unarchiveObjectWithData:item]];
    NSLog (@"AFTER FILES = %@", _files);
}

-(UIImage *)generateThumbImage : (NSURL *)url
{
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = [asset duration];
    time.value = 0;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    
    return thumbnail;
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_files count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"cvCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    GalleryItem *cellItem = (GalleryItem *)[_files objectAtIndex:indexPath.row];
    UIImage *cellImage = [self generateThumbImage:[cellItem fileURL]];
    UIImageView *cellView = [[UIImageView alloc] initWithImage:cellImage];
    cell.backgroundView = cellView;
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory  error:nil];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[filePathsArray objectAtIndex:indexPath.row]];
    
    NSURL *movieURL = [NSURL fileURLWithPath:filePath];
    AVPlayerViewController *avc = [[AVPlayerViewController alloc] init];
    avc.player = [[AVPlayer alloc] initWithURL:movieURL];
    [self presentViewController:avc animated:YES completion:nil];
    
}

- (IBAction) returnToMainViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction)EmptySandbox:(id)sender
{
    // Clear NSUserDefaults data
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    // Clear Documents folder
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *files = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    while (files.count > 0) {
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
        if (error == nil) {
            for (NSString *path in directoryContents) {
                NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
                BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
                files = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
                if (!removeSuccess) {
                    // Error
                }
            }
        } else {
            // Error
        }
    }
    
    [self.files removeAllObjects];
    [self.collectionView reloadData];
}




@end
