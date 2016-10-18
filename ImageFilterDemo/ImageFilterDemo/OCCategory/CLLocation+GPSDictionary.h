
#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>

@interface CLLocation (GPSDictionary)

//CLLocation对象转换为图片的GPSDictionary
- (NSDictionary *)GPSDictionary;

@end
