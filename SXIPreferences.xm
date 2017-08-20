#import "headers.h"

@implementation SXIPreferences
+(SXIPreferences *)sharedInstance {
	static SXIPreferences *sharedObject = nil;
	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
		sharedObject = [self new];
	});
	return sharedObject;
}

-(id)init {
	self = [super init];
	if (self != nil)
		[self updatePreferences];
	return self;
}

-(void)updatePreferences {
	CFPreferencesAppSynchronize((CFStringRef)kTweakIdentifier);

	NSMutableDictionary *prefs = nil;
	if ([NSHomeDirectory() isEqualToString:@"/var/mobile"]) {
		CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)kTweakIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
		if (keyList != nil) {
			prefs = (NSMutableDictionary *)CFPreferencesCopyMultiple(keyList, (CFStringRef)kTweakIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
			if (prefs == nil)
				prefs = [NSMutableDictionary dictionary];
			CFRelease(keyList);
		}
	} else {
		prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kSettingsPath];
	}

	_isEnabled = [prefs objectForKey:@"isEnabled"] ? [[prefs objectForKey:@"isEnabled"] boolValue] : YES;
	_isRightSwipeEnabled = [prefs objectForKey:@"isRightSwipeEnabled"] ? [[prefs objectForKey:@"isRightSwipeEnabled"] boolValue] : NO;
	_dismissTime = [prefs objectForKey:@"dismissTime"] ? [[prefs objectForKey:@"dismissTime"] floatValue] : 5.0;
	_isUnlimitedDismissTimeEnabled = [prefs objectForKey:@"isUnlimitedDismissTimeEnabled"] ? [[prefs objectForKey:@"isUnlimitedDismissTimeEnabled"] boolValue] : NO;
	_isShutterSoundDisabled = [prefs objectForKey:@"isShutterSoundDisabled"] ? [[prefs objectForKey:@"isShutterSoundDisabled"] boolValue] : NO;
	_isSaveOnSwipeDismissEnabled = [prefs objectForKey:@"isSaveOnSwipeDismissEnabled"] ? [[prefs objectForKey:@"isSaveOnSwipeDismissEnabled"] boolValue] : YES;
	_isSaveOnAutoDismissEnabled = [prefs objectForKey:@"isSaveOnAutoDismissEnabled"] ? [[prefs objectForKey:@"isSaveOnAutoDismissEnabled"] boolValue] : YES;
	_isSaveOnShareEnabled = [prefs objectForKey:@"isSaveOnShareEnabled"] ? [[prefs objectForKey:@"isSaveOnShareEnabled"] boolValue] : YES;
	_isSaveUneditedEnabled = [prefs objectForKey:@"isSaveUneditedEnabled"] ? [[prefs objectForKey:@"isSaveUneditedEnabled"] boolValue] : NO;
	_isSaveUneditedOnCancelEnabled = [prefs objectForKey:@"isSaveUneditedOnCancelEnabled"] ? [[prefs objectForKey:@"isSaveUneditedOnCancelEnabled"] boolValue] : YES;
	_isSpamSaveEnabled = [prefs objectForKey:@"isSpamSaveEnabled"] ? [[prefs objectForKey:@"isSpamSaveEnabled"] boolValue] : YES;
	_isDismissOnLockEnabled = [prefs objectForKey:@"isDismissOnLockEnabled"] ? [[prefs objectForKey:@"isDismissOnLockEnabled"] boolValue] : NO;
	_isDismissOnCallEnabled = [prefs objectForKey:@"isDismissOnCallEnabled"] ? [[prefs objectForKey:@"isDismissOnCallEnabled"] boolValue] : YES;
	_isLockscreenShareDisabled = [prefs objectForKey:@"isLockscreenShareDisabled"] ? [[prefs objectForKey:@"isLockscreenShareDisabled"] boolValue] : YES;
	_isLockscreenEditDisabled = [prefs objectForKey:@"isLockscreenEditDisabled"] ? [[prefs objectForKey:@"isLockscreenEditDisabled"] boolValue] : NO;
	
	DisplayWindowLevel windowPriority = [prefs objectForKey:@"windowPriority"] ? (DisplayWindowLevel)[[prefs objectForKey:@"windowPriority"] intValue] : kAboveHomeAppsLockScreens;
	switch (windowPriority) {
		case kAboveHomeAppsLockScreens:
			_currentTweakLevel = 1051;
			break;
		case kAboveControlCenter:
			_currentTweakLevel = 1091;
			break;
		case kAboveNotificationCenter:
			_currentTweakLevel = 1096;
			break;
		case kAboveNotificationBanners:
			_currentTweakLevel = 1101;
			break;
		case kAboveSpringBoardAlerts:
			_currentTweakLevel = 2001;
			break;
		case kScreenshotFlash:
			_currentTweakLevel = 2200;
			break;
		default:
			_currentTweakLevel = 1051;
			break;
	}

	_animationSpeed = [prefs objectForKey:@"animationSpeed"] ? [[prefs objectForKey:@"animationSpeed"] floatValue] : 0.5;
	_miniImageScale = [prefs objectForKey:@"miniImageScale"] ? [[prefs objectForKey:@"miniImageScale"] floatValue] : 0.2;
	_miniImageWhitePadding = [prefs objectForKey:@"miniImageWhitePadding"] ? [[prefs objectForKey:@"miniImageWhitePadding"] floatValue] : 6.0;		
	_miniImageMargin = [prefs objectForKey:@"miniImageMargin"] ? [[prefs objectForKey:@"miniImageMargin"] floatValue] : 10.0;
	_miniImageRoundness = [prefs objectForKey:@"miniImageRoundness"] ? [[prefs objectForKey:@"miniImageRoundness"] floatValue] : 4.0;
	_dismissAnimationSpeed = [prefs objectForKey:@"dismissAnimationSpeed"] ? [[prefs objectForKey:@"dismissAnimationSpeed"] floatValue] : 0.5;
	_previewAnimationSpeed = [prefs objectForKey:@"previewAnimationSpeed"] ? [[prefs objectForKey:@"previewAnimationSpeed"] floatValue] : 0.15;
	_previewAlpha = [prefs objectForKey:@"previewAlpha"] ? [[prefs objectForKey:@"previewAlpha"] floatValue] : 0.25;
	_previewScale = [prefs objectForKey:@"previewScale"] ? [[prefs objectForKey:@"previewScale"] floatValue] : 1.05;
}

-(NSString *)uiHexColor {
	CFPreferencesAppSynchronize((CFStringRef)kColorIdentifier); // not needed
	
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:kColorPath];
	if (prefs != nil) {
		return [prefs objectForKey:@"color"];
	}
	return nil;
}
@end