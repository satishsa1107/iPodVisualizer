//
//  GalleryItem.m
//  iPodVisualizer
//
//  Created by Sagar Satish on 2015-11-19.
//  Copyright © 2015 Xinrong Guo. All rights reserved.
//

#import "GalleryItem.h"


@interface GalleryItem ()

@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSURL *fileURL;
@property (strong, nonatomic) NSDate *fileDate;
@property (strong, nonatomic) UIImage *fileImage;

@end

@implementation GalleryItem


-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        self.fileName  = [aDecoder decodeObjectForKey:@"FILE_NAME_KEY"];
        self.fileURL   = [aDecoder decodeObjectForKey:@"FILE_URL_KEY"];
        self.fileDate  = [aDecoder decodeObjectForKey:@"FILE_DATE_KEY"];
        self.fileImage = [aDecoder decodeObjectForKey:@"FILE_IMAGE_KEY"];
    }
    return self;
}

-(GalleryItem *) initWithName:(NSString *)temp_name
                 url:(NSURL *) temp_url
                date:(NSDate *)temp_date
               image:(UIImage *)fileImage
{
    [self setFileName:temp_name];
    [self setFileURL:temp_url];
    [self setFileDate:temp_date];
    [self setFileImage:fileImage];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.fileName  forKey:@"FILE_NAME_KEY"];
    [aCoder encodeObject:self.fileURL   forKey:@"FILE_URL_KEY"];
    [aCoder encodeObject:self.fileDate  forKey:@"FILE_DATE_KEY"];
    [aCoder encodeObject:self.fileImage forKey:@"FILE_IMAGE_KEY"];
}

- (NSURL *) fileURL
{
    return _fileURL;
}

@end
