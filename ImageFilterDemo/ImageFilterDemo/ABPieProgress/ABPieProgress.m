
#import "ABPieProgress.h"


static CGFloat offset = 2.f;


@implementation ABPieProgress {
    
    CAShapeLayer *outShapeLayer;
    
    CAShapeLayer *_shapeLayer;
    
    CGPoint radiusCenter;
    
    CGFloat radius;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    self.backgroundColor = [UIColor clearColor];
    self.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.hidden = YES;
    
}

- (void)startProgress
{
    self.hidden = NO;
    
    [self addOutCircle];
    
    [self addCAShapeLayer];
}

- (void)stopProgress
{
    self.hidden = YES;
}

// 外圈
- (void)addOutCircle
{
    
    if (!outShapeLayer) {
        
        outShapeLayer = [CAShapeLayer layer];
        outShapeLayer.frame = self.bounds;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:outShapeLayer.bounds];
        outShapeLayer.path = path.CGPath;
        outShapeLayer.lineWidth = 1.5f;
        outShapeLayer.lineCap = kCALineCapRound;
        outShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        outShapeLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:outShapeLayer];
        
        outShapeLayer.strokeStart = 0.f;
        outShapeLayer.strokeEnd = 1.f;
    }

}

- (void)addCAShapeLayer {
    
    if (!_shapeLayer)
    {
        

    _shapeLayer = [CAShapeLayer layer];
//    _shapeLayer.masksToBounds = YES;
    _shapeLayer.frame = CGRectMake(0, 0, self.bounds.size.width - offset * 2, self.bounds.size.height - offset * 2);
    
    radiusCenter = CGPointMake(_shapeLayer.frame.size.width / 2, _shapeLayer.frame.size.height / 2);
    
    _shapeLayer.position = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    radius = (_shapeLayer.bounds.size.width - offset) / 2; // 要加1
    
    // 绘制扇形
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:radiusCenter];
    [path addArcWithCenter:radiusCenter
                    radius:radius
                startAngle:0
                  endAngle:0
                 clockwise:YES];
    [path addLineToPoint:radiusCenter];
    
    _shapeLayer.path = path.CGPath;
    _shapeLayer.strokeColor = [UIColor clearColor].CGColor;
    _shapeLayer.fillColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:_shapeLayer];
        
    }
}

- (void)setProgressValue:(CGFloat)progressValue {
    _progressValue = progressValue;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:radiusCenter];
    [path addArcWithCenter:radiusCenter
                    radius:radius
                startAngle:0
                  endAngle:2 * M_PI * _progressValue
                 clockwise:YES];
    [path addLineToPoint:radiusCenter];
    
    _shapeLayer.path = path.CGPath;
   
}

@end
