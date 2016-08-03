//
//  CSViewVideoCameraDuration.h
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/3.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAX_VIDEO_DURATION 60 * 10


@interface CSViewVideoCameraDuration : UIView

- (void)startVideoCapture;

- (void)stopVideoCapture;

@end
