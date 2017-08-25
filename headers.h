#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Photos/Photos.h>
#import <libcolorpicker.h>

#define kLongPressStartDuration 0.15 // time till long press starts
#define kLongPressEndDuration 0.33 // additional duration after long press starts
#define kLongPressRange 7.5 // finger movement allowed for long press

#define kTweakIdentifier @"com.dgh0st.screenshotxi"
#define kSettingsChangedIdentifier @"com.dgh0st.screenshotxi/settingschanged"
#define kSettingsPath @"/var/mobile/Library/Preferences/com.dgh0st.screenshotxi.plist"
#define kColorIdentifier @"com.dgh0st.screenshotxi.color"
#define kColorChangedIdentifier @"com.dgh0st.screenshotxi/colorchanged"
#define kColorPath @"/var/mobile/Library/Preferences/com.dgh0st.screenshotxi.color.plist"
#define kBundlePath @"/Library/Application Support/ScreenshotXI/ImageAssets.bundle"
#define kPhotoShutterSystemSound 0x454
#define kImageMinimumScaleMultiplier 0.75
#define kHideBehindLockscreenWindowLevel 1048
#define kLockscreenWindowLevel 1051

/* 
------------------------------ iOS's Window Level (Atleast on iOS 10 iPhone 6+) ------------------------------
HomeScreen Wallpaper = -3
HomeScreen = -2
Application = 0 
(alerts in applications are displayed in same window, UIAlertController are presented from UIViewController)
LockScreen Wallpaper = 1049
LockScreen = 1050
Control Center = 1090
Notification Center = 1095
Notification Banners = 1100
SpringBoard Alert = 2000
Screenshot Flash = 2200
--------------------------------------------------------------------------------------------------------------
*/

typedef enum {
	kAboveHomeAppsLockScreens = 1,
	kAboveControlCenter = 2,
	kAboveNotificationCenter = 3,
	kAboveNotificationBanners = 4,
	kAboveSpringBoardAlerts = 5,
	kScreenshotFlash = 6
} DisplayWindowLevel;

typedef enum {
	kNone = 0,
	kShareSheet,
	kEditor
} DisplayedControllerType;

@interface _SBScreenshotPersistenceCoordinator : NSObject
-(void)saveScreenshot:(id)arg1 withCompletion:(id)arg2;
@end

@interface SBScreenshotManager : NSObject
-(void)saveScreenshotsWithCompletion:(id)arg1;
-(_SBScreenshotPersistenceCoordinator *)_persistenceCoordinator;
@end

@interface SBScreenShotter : NSObject
+(id)sharedInstance;
-(void)saveScreenshot:(BOOL)arg1;
@end

@interface PLPhotoLibrary : NSObject
@property (nonatomic,copy,readonly) NSArray * albums;
+(id)sharedPhotoLibrary;
@end

@interface PLManagedAsset : NSObject
@property (nonatomic,copy,readonly) NSURL * mainFileURL;
@end

@interface PLManagedAlbum : NSObject
@property (nonatomic,retain) NSOrderedSet * assets;
@end

@interface AKUndoController : NSObject
@end

@interface AKOverlayView : UIView
@end

@interface AKPageController : NSObject
@property (nonatomic,retain) UIView *overlayView;
@property (assign) BOOL shouldPixelate;
@end

@interface AKModelController
-(void)deselectAllAnnotations;
@end

@interface AKController : NSObject
@property (retain) AKUndoController *undoController;
@property (retain) AKModelController *modelController; 
@property (assign, nonatomic) BOOL overlayShouldPixelate;
-(AKPageController *)currentPageController;
@end

@interface MUImageContentViewController : UIViewController
@end

@protocol MarkupViewControllerDelegate <NSObject>
@end

@interface MarkupViewController : UIViewController <UINavigationBarDelegate>
@property (retain) MUImageContentViewController *contentViewController;
@property (nonatomic,retain) UINavigationBar *navBar;
@property (nonatomic,retain) NSUndoManager *akUndoManager;
@property (retain) AKController *annotationController;
@property (nonatomic, retain) id sourceContent;
-(void)setImage:(id)arg1;
-(void)setShapeDetectionEnabled:(BOOL)arg1;
-(void)setAnnotationEditingEnabled:(BOOL)arg1; // iOS 10.0 +
-(void)setDelegate:(id)arg1;
@end

@interface SBScreenFlash : NSObject
+(id)mainScreenFlasher;
-(void)setScreenshotImage:(id)image;
-(UIImage *)screenshotImage;
-(void)flashColor:(id)arg1 withCompletion:(id)arg2;
-(void)screenshotwithCompletion:(id)arg2;
@end

@interface UIWindow (SXIPrivate)
-(void)_setSecure:(BOOL)arg1;
-(void)_updateToInterfaceOrientation:(UIInterfaceOrientation)arg1 animated:(BOOL)arg2;
@end

@interface UIScreen (SXIPrivate)
-(id)_snapshotExcludingWindows:(id)arg1 withRect:(CGRect)arg2;
-(id)snapshotViewAfterScreenUpdates:(BOOL)arg1;
@end

@interface UIApplication (SXIPrivate)
-(void)setStatusBarHidden:(BOOL)arg1;
@end

@interface UIActivityViewController (SXIPrivate)
@property (assign,nonatomic) BOOL showKeyboardAutomatically;
-(void)setDismissCompletionHandler:(id)arg1;
@end

@interface UIBarButtonItem (SXIPrivate)
-(id)view;
@end

@interface SBBacklightController
+(id)sharedInstance;
-(void)resetLockScreenIdleTimer;
@end

@interface SpringBoard : UIApplication
@property (nonatomic,readonly) SBScreenshotManager *screenshotManager;
-(BOOL)isLocked;
-(UIInterfaceOrientation)activeInterfaceOrientation;
-(id)_accessibilityFrontMostApplication;
@end

@interface SBUIController : NSObject
+(id)sharedInstance;
-(void)_hideKeyboard;
@end

@interface ESSContainerView : UIView {
	UIColor *_color;
}
@property (nonatomic, strong) UIImage *image;
-(id)initWithFrame:(CGRect)frame withColor:(UIColor *)color;
-(void)highlightViewWithCompletion:(id)completion;
-(void)unhighlightViewWithCompletion:(id)completion;
-(void)shake;
@end

@interface ESSController : UIViewController <UIGestureRecognizerDelegate, MarkupViewControllerDelegate> {
	UIActivityViewController *_activityViewController;
	MarkupViewController *_markUpEditor;
	NSTimeInterval pressStartTime;
	CGPoint pressStartLocation;
	BOOL useLongPressAsPan;
	BOOL timerDidTrigger;
	UIBarButtonItem *redoButton;
	UIBarButtonItem *undoButton;
	UIBarButtonItem *saveButton;
	UIBarButtonItem *shareButton;
	BOOL didHideStatusBar;
	UIImage *resultEditedImage;
}
@property (nonatomic, assign) BOOL rotationEnabled;
@property (nonatomic, strong) NSMutableArray *containerViews;
+(UIImage *)imageFromView:(UIView *)view andView:(UIView *)secondView;
-(DisplayedControllerType)currentlyHostingViewControllerType;
-(void)saveScreenshot:(UIImage *)image;
-(void)autoHide:(UIView *)view;
-(void)forceHide:(UIView *)view;
-(void)forceHideWithoutAnimations:(UIView *)view;
-(void)updateUndoAndRedoButtons;
-(BOOL)isEqualToMarkUpEditor:(id)editor;
-(BOOL)isEqualToUndoController:(id)undoController;
-(BOOL)isEqualToImageContentViewController:(id)imageContentViewController;
-(BOOL)isEqualToSourceContent:(id)sourceContent;
-(BOOL)isPresentingEditor;
-(void)forceSaveMarkUpWithCompletion:(void (^)())completion;
-(void)dismissMarkUpEditorAnimated:(BOOL)animated completion:(void (^)())completion;
-(void)dismissShareSheetAnimated:(BOOL)animated completion:(void (^)(void))completion;
@end

@interface ESSWindow : UIWindow
@end

// anemone fix
@interface ANEMSettingsManager : NSObject
+(instancetype)sharedManager;
-(void)setCGImageHookEnabled:(BOOL)enabled;
@end

@interface SXIPreferences : NSObject
@property (nonatomic, assign, readonly) BOOL isEnabled;
@property (nonatomic, assign, readonly) BOOL isRightSwipeEnabled;
@property (nonatomic, assign, readonly) CGFloat dismissTime;
@property (nonatomic, assign, readonly) BOOL isUnlimitedDismissTimeEnabled;
@property (nonatomic, assign, readonly) BOOL isShutterSoundDisabled;
@property (nonatomic, assign, readonly) BOOL isSaveOnSwipeDismissEnabled;
@property (nonatomic, assign, readonly) BOOL isSaveOnAutoDismissEnabled;
@property (nonatomic, assign, readonly) BOOL isSaveOnShareEnabled;
@property (nonatomic, assign, readonly) BOOL isSaveUneditedEnabled;
@property (nonatomic, assign, readonly) BOOL isSaveUneditedOnCancelEnabled;
@property (nonatomic, assign, readonly) BOOL isSpamSaveEnabled;
@property (nonatomic, assign, readonly) BOOL isDismissOnLockEnabled;
@property (nonatomic, assign, readonly) BOOL isDismissOnCallEnabled;
@property (nonatomic, assign, readonly) BOOL isLockscreenShareDisabled;
@property (nonatomic, assign, readonly) BOOL isLockscreenEditDisabled;
@property (nonatomic, assign, readonly) UIWindowLevel currentTweakLevel;
@property (nonatomic, assign, readonly) CGFloat animationSpeed;
@property (nonatomic, assign, readonly) CGFloat miniImageScale;
@property (nonatomic, assign, readonly) CGFloat miniImageWhitePadding;
@property (nonatomic, assign, readonly) CGFloat miniImageMargin;
@property (nonatomic, assign, readonly) CGFloat miniImageRoundness;
@property (nonatomic, assign, readonly) CGFloat dismissAnimationSpeed;
@property (nonatomic, assign, readonly) CGFloat previewAnimationSpeed;
@property (nonatomic, assign, readonly) CGFloat previewAlpha;
@property (nonatomic, assign, readonly) CGFloat previewScale;
+(SXIPreferences *)sharedInstance;
-(void)updatePreferences;
-(NSString *)uiHexColor;
@end