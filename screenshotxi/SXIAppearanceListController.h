#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

// needed for libcolorpicker
@interface PSListController (Private)
-(void)clearCache;
-(void)reload;
@end

@interface SXIAppearanceListController : PSListController

@end