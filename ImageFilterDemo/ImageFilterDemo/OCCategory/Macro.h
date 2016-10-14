/**
 *	@brief  屏幕尺寸
 */
#define kCSScreenSize   [[UIScreen mainScreen] bounds].size
#define kCSScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define kCSScreenHeight [[UIScreen mainScreen] bounds].size.height

#define RGB(r,g,b)        [UIColor colorWithRed:r / 255.f green:g / 255.f blue:b / 255.f alpha:1.f]
#define RGBA(r,g,b,a)     [UIColor colorWithRed:r / 255.f green:g / 255.f blue:b / 255.f alpha:a]
#define RGBHEX(hex)       RGBA((float)((hex & 0xFF0000) >> 16),(float)((hex & 0xFF00) >> 8),(float)(hex & 0xFF),1.f)
#define RGBAHEX(hex,a)    RGBA((float)((hex & 0xFF0000) >> 16),(float)((hex & 0xFF00) >> 8),(float)(hex & 0xFF),a)
