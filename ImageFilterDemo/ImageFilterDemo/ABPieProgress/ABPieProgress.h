

#import <UIKit/UIKit.h>

@interface ABPieProgress : UIView

@property (nonatomic, assign) CGFloat progressValue;

- (void)startProgress;
- (void)stopProgress;

@end
