//
//  CSSlider.h
//  CustomUISlider
//
//  Created by Chris Hu on 16/8/31.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSSliderDelegate;

typedef NS_ENUM(NSInteger, CSSliderDirection) {
    CSSliderDirection_Horizontal = 0,
    CSSliderDirection_Vertical,
};

typedef NS_ENUM(NSInteger, CSSliderTrackTintType) {
    CSSliderTrackTintType_Linear = 0,
    CSSliderTrackTintType_Divide,
};

@interface CSSlider : UISlider

@property (nonatomic, weak) id<CSSliderDelegate> delegate;

@property (nonatomic, assign) float middleVaule;

@property (nonatomic, assign) CSSliderDirection sliderDirection;

// Please use CSSliderTrackTintType in viewDidAppear method.
// Please use CSSliderTrackTintType after csMinimumTrackTintColor and csMaximumTrackTintColor set already if you do not want to use the default color.
// Please do not set minimumValueImage and maximumValueImage before fully test.
@property (nonatomic, assign) CSSliderTrackTintType trackTintType;

@property (nonatomic, strong) UIImage *csThumbImage;
@property (nonatomic, strong) UIColor *csMinimumTrackTintColor;
@property (nonatomic, strong) UIColor *csMaximumTrackTintColor;

- (void)increasePercentRate:(NSInteger)percent;
- (void)decreasePercentRate:(NSInteger)percent;

@end


@protocol CSSliderDelegate <NSObject>

- (void)CSSliderValueChanged:(CSSlider *)sender;

@optional
- (void)CSSliderTouchDown:(CSSlider *)sender;
- (void)CSSliderTouchUp:(CSSlider *)sender;
- (void)CSSliderTouchCancel:(CSSlider *)sender;

@end
