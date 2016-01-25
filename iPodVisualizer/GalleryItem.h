//
//  GalleryItem.h
//  iPodVisualizer
//
//  Created by Sagar Satish on 2015-11-19.
//  Copyright © 2015 Xinrong Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GalleryItem : NSObject

-(GalleryItem *) initWithName:(NSString *)temp_name url:(NSURL *)temp_url date:(NSDate *)temp_date image:(UIImage *)fileImage;

- (NSURL *) fileURL;
@end
