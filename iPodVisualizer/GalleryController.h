//
//  GalleryController.h
//  iPodVisualizer
//
//  Created by Sagar Satish on 2015-11-20.
//  Copyright © 2015 Xinrong Guo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalleryItem.h"

@interface GalleryController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

- (void) addGalleryItem:(GalleryItem *)item;
//- (void) EmptySandbox;
- (void) saveUserData;
- (void) loadUserData;

@end
