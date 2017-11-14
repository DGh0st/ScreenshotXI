#import "SXIConfigurationListController.h"
#import "../headers.h"

@implementation SXIConfigurationListController

- (NSArray *)specifiers {
	if (_specifiers == nil) {
		PSSpecifier *swipeGroup = [PSSpecifier emptyGroupSpecifier];
		PSSpecifier *enableRightSwipe = [PSSpecifier preferenceSpecifierNamed:@"Right Swipe" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[enableRightSwipe setProperty:@NO forKey:@"default"];
		[enableRightSwipe setProperty:kTweakIdentifier forKey:@"defaults"];
		[enableRightSwipe setProperty:@"isRightSwipeEnabled" forKey:@"key"];
		[enableRightSwipe setProperty:@"Right Swipe" forKey:@"label"];
		[enableRightSwipe setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];

		PSSpecifier *notifyApplication = [PSSpecifier preferenceSpecifierNamed:@"Notify Applications" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[notifyApplication setProperty:@YES forKey:@"default"];
		[notifyApplication setProperty:kTweakIdentifier forKey:@"defaults"];
		[notifyApplication setProperty:@"isNotifyApplicationsEnabled" forKey:@"key"];
		[notifyApplication setProperty:@"Notify Applications" forKey:@"label"];
		[notifyApplication setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];

		PSSpecifier *dismissTimeGroup = [PSSpecifier groupSpecifierWithName:@"Mini Image Dismiss Time"];
		[dismissTimeGroup setProperty:@"Mini Image Dismiss Time" forKey:@"label"];
		[dismissTimeGroup setProperty:@"With unlimited dimiss time, mini-image still gets dismissed when image is shared or edited" forKey:@"footerText"];
		PSSpecifier *miniImageDismissSlider = [PSSpecifier preferenceSpecifierNamed:@"Mini-Image Dismiss Time" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
		[miniImageDismissSlider setProperty:%c(SXISliderCell) forKey:@"cellClass"];
		[miniImageDismissSlider setProperty:[NSNumber numberWithFloat:1.0] forKey:@"min"];
		[miniImageDismissSlider setProperty:[NSNumber numberWithFloat:25.0] forKey:@"max"];
		[miniImageDismissSlider setProperty:@YES forKey:@"showValue"];
		[miniImageDismissSlider setProperty:[NSNumber numberWithFloat:5.0] forKey:@"default"];
		[miniImageDismissSlider setProperty:kTweakIdentifier forKey:@"defaults"];
		[miniImageDismissSlider setProperty:@"dismissTime" forKey:@"key"];
		[miniImageDismissSlider setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];
		PSSpecifier *unlimitedDismiss = [PSSpecifier preferenceSpecifierNamed:@"Unlimited Dismiss Time" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[unlimitedDismiss setProperty:@NO forKey:@"default"];
		[unlimitedDismiss setProperty:kTweakIdentifier forKey:@"defaults"];
		[unlimitedDismiss setProperty:@"isUnlimitedDismissTimeEnabled" forKey:@"key"];
		[unlimitedDismiss setProperty:@"Unlimited Dismiss Time" forKey:@"label"];
		[unlimitedDismiss setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];

		PSSpecifier *soundGroup = [PSSpecifier emptyGroupSpecifier];
		PSSpecifier *disableShutterSound = [PSSpecifier preferenceSpecifierNamed:@"Disable Shutter Sound" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[disableShutterSound setProperty:@NO forKey:@"default"];
		[disableShutterSound setProperty:kTweakIdentifier forKey:@"defaults"];
		[disableShutterSound setProperty:@"isShutterSoundDisabled" forKey:@"key"];
		[disableShutterSound setProperty:@"Disable Shutter Sound" forKey:@"label"];
		[disableShutterSound setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];
		PSSpecifier *copyToClipboard = [PSSpecifier preferenceSpecifierNamed:@"Copy to clipboard" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[copyToClipboard setProperty:@NO forKey:@"default"];
		[copyToClipboard setProperty:kTweakIdentifier forKey:@"defaults"];
		[copyToClipboard setProperty:@"isCopyToPasteBoardEnabled" forKey:@"key"];
		[copyToClipboard setProperty:@"Copy to clipboard" forKey:@"label"];
		[copyToClipboard setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];

		PSSpecifier *saveGroup = [PSSpecifier groupSpecifierWithName:@"Screenshot"];
		[saveGroup setProperty:@"Screenshot" forKey:@"label"];
		[saveGroup setProperty:@"Spam screenshots is when new screenshot is taken while there is already a mini image on screen or the animation is in progress" forKey:@"footerText"];
		PSSpecifier *dismissAction = [PSSpecifier preferenceSpecifierNamed:@"Save on Manual Dismiss" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[dismissAction setProperty:@YES forKey:@"default"];
		[dismissAction setProperty:kTweakIdentifier forKey:@"defaults"];
		[dismissAction setProperty:@"isSaveOnSwipeDismissEnabled" forKey:@"key"];
		[dismissAction setProperty:@"Save on Manual Dismiss" forKey:@"label"];
		[dismissAction setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];
		PSSpecifier *autoDimissAction = [PSSpecifier preferenceSpecifierNamed:@"Save on Auto Dismiss" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[autoDimissAction setProperty:@YES forKey:@"default"];
		[autoDimissAction setProperty:kTweakIdentifier forKey:@"defaults"];
		[autoDimissAction setProperty:@"isSaveOnAutoDismissEnabled" forKey:@"key"];
		[autoDimissAction setProperty:@"Save on Auto Dismiss" forKey:@"label"];
		[autoDimissAction setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];
		PSSpecifier *shareAction = [PSSpecifier preferenceSpecifierNamed:@"Save on Share" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[shareAction setProperty:@YES forKey:@"default"];
		[shareAction setProperty:kTweakIdentifier forKey:@"defaults"];
		[shareAction setProperty:@"isSaveOnShareEnabled" forKey:@"key"];
		[shareAction setProperty:@"Save on Share" forKey:@"label"];
		[shareAction setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];
		PSSpecifier *editorAction = [PSSpecifier preferenceSpecifierNamed:@"Save Unedited (With Edited)" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[editorAction setProperty:@NO forKey:@"default"];
		[editorAction setProperty:kTweakIdentifier forKey:@"defaults"];
		[editorAction setProperty:@"isSaveUneditedEnabled" forKey:@"key"];
		[editorAction setProperty:@"Save Unedited (With Edited)" forKey:@"label"];
		[editorAction setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];
		PSSpecifier *editorCancelAction = [PSSpecifier preferenceSpecifierNamed:@"Save Unedited On Cancel" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[editorCancelAction setProperty:@YES forKey:@"default"];
		[editorCancelAction setProperty:kTweakIdentifier forKey:@"defaults"];
		[editorCancelAction setProperty:@"isSaveUneditedOnCancelEnabled" forKey:@"key"];
		[editorCancelAction setProperty:@"Save Unedited On Cancel" forKey:@"label"];
		[editorCancelAction setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];
		PSSpecifier *spamSave = [PSSpecifier preferenceSpecifierNamed:@"Save spam screenshots" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[spamSave setProperty:@YES forKey:@"default"];
		[spamSave setProperty:kTweakIdentifier forKey:@"defaults"];
		[spamSave setProperty:@"isSpamSaveEnabled" forKey:@"key"];
		[spamSave setProperty:@"Save spam screenshots" forKey:@"label"];
		[spamSave setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];

		PSSpecifier *behavior = [PSSpecifier groupSpecifierWithName:@"Force Dismiss"];
		[behavior setProperty:@"Force Dismiss" forKey:@"label"];
		[behavior setProperty:@"Force dismiss editor, share sheet and mini image automatically when device locked or call received" forKey:@"footerText"];
		PSSpecifier *dismissOnLock = [PSSpecifier preferenceSpecifierNamed:@"Dismiss on Lock" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[dismissOnLock setProperty:@NO forKey:@"default"];
		[dismissOnLock setProperty:kTweakIdentifier forKey:@"defaults"];
		[dismissOnLock setProperty:@"isDismissOnLockEnabled" forKey:@"key"];
		[dismissOnLock setProperty:@"Dismiss on Lock" forKey:@"label"];
		[dismissOnLock setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];
		PSSpecifier *dismissOnCall = [PSSpecifier preferenceSpecifierNamed:@"Dismiss on Call" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[dismissOnCall setProperty:@YES forKey:@"default"];
		[dismissOnCall setProperty:kTweakIdentifier forKey:@"defaults"];
		[dismissOnCall setProperty:@"isDismissOnCallEnabled" forKey:@"key"];
		[dismissOnCall setProperty:@"Dismiss on Call" forKey:@"label"];
		[dismissOnCall setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];

		PSSpecifier *lockscreen = [PSSpecifier groupSpecifierWithName:@"Lockscreen"];
		[lockscreen setProperty:@"Lockscreen" forKey:@"label"];
		[lockscreen setProperty:@"Disable certain features on lockscreen" forKey:@"footerText"];
		PSSpecifier *share = [PSSpecifier preferenceSpecifierNamed:@"Disable Sharing" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[share setProperty:@YES forKey:@"default"];
		[share setProperty:kTweakIdentifier forKey:@"defaults"];
		[share setProperty:@"isLockscreenShareDisabled" forKey:@"key"];
		[share setProperty:@"Disable Sharing" forKey:@"label"];
		[share setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];
		PSSpecifier *editing = [PSSpecifier preferenceSpecifierNamed:@"Disable Editing" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[editing setProperty:@NO forKey:@"default"];
		[editing setProperty:kTweakIdentifier forKey:@"defaults"];
		[editing setProperty:@"isLockscreenEditDisabled" forKey:@"key"];
		[editing setProperty:@"Disable Editing" forKey:@"label"];
		[editing setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];

		PSSpecifier *resetGroup = [PSSpecifier emptyGroupSpecifier];
		PSSpecifier *resetConfigurationButton = [PSSpecifier preferenceSpecifierNamed:@"Reset Configuration" target:self set:NULL get:NULL detail:nil cell:PSButtonCell edit:nil];
		resetConfigurationButton->action = @selector(resetConfiguration);
		[resetConfigurationButton setProperty:@"Reset Configuration" forKey:@"label"];
		[resetConfigurationButton setProperty:@1 forKey:@"alignment"];

		_specifiers = [@[swipeGroup, enableRightSwipe, notifyApplication, dismissTimeGroup, miniImageDismissSlider, unlimitedDismiss, soundGroup, disableShutterSound, copyToClipboard, saveGroup, dismissAction, autoDimissAction, shareAction, editorAction, editorCancelAction, spamSave, behavior, dismissOnLock, dismissOnCall, lockscreen, share, editing, resetGroup, resetConfigurationButton] retain];
	}

	return _specifiers;
}

- (void)resetConfiguration {
	for (PSSpecifier *specifier in _specifiers)
		if ([specifier propertyForKey:@"key"] != nil)
			[self setPreferenceValue:[specifier propertyForKey:@"default"] specifier:specifier];
	[self reloadSpecifiers];
}

@end