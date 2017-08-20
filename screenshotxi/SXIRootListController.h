#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SXIRootListController : PSListController <MFMailComposeViewControllerDelegate>

@end


@interface UIImage (SXIPrivate)
+(UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier format:(NSInteger)format scale:(CGFloat)scale;
@end