
#import "CLLocation+GPSDictionary.h"

@implementation CLLocation (GPSDictionary)

-(NSDictionary*)GPSDictionary{
    NSTimeZone    *timeZone   = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDateFormatter *formatter  = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"HH:mm:ss.SS"];
    
    CLLocation *location=self;
    NSDictionary *gpsDict = @{(NSString *)kCGImagePropertyGPSLatitude: @(fabs(location.coordinate.latitude)),
                              (NSString *)kCGImagePropertyGPSLatitudeRef: ((location.coordinate.latitude >= 0) ? @"N" : @"S"),
                              (NSString *)kCGImagePropertyGPSLongitude: @(fabs(location.coordinate.longitude)),
                              (NSString *)kCGImagePropertyGPSLongitudeRef: ((location.coordinate.longitude >= 0) ? @"E" : @"W"),
                              (NSString *)kCGImagePropertyGPSTimeStamp: [formatter stringFromDate:[location timestamp]],
                              (NSString *)kCGImagePropertyGPSAltitude: @(fabs(location.altitude)),
                              };
    return gpsDict;
}

@end
