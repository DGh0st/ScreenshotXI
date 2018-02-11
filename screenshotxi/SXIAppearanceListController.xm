#import "SXIAppearanceListController.h"
#import "../headers.h"

@implementation SXIAppearanceListController

- (NSArray *)specifiers {
	if (_specifiers == nil) { // copy pasted code... can probably make a function...
		PSSpecifier *animationSpeedGroup = [PSSpecifier groupSpecifierWithName:@"Animation Speed"];
		[animationSpeedGroup setProperty:@"Animation Speed" forKey:@"label"];
		PSSpecifier *animationSpeedSlider = [PSSpecifier preferenceSpecifierNamed:@"Flash Animation Speed" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
		[animationSpeedSlider setProperty:%c(SXISliderCell) forKey:@"cellClass"];
		[animationSpeedSlider setProperty:[NSNumber numberWithFloat:0.0] forKey:@"min"];
		[animationSpeedSlider setProperty:[NSNumber numberWithFloat:1.0] forKey:@"max"];
		[animationSpeedSlider setProperty:@YES forKey:@"showValue"];
		[animationSpeedSlider setProperty:[NSNumber numberWithFloat:0.5] forKey:@"default"];
		[animationSpeedSlider setProperty:kTweakIdentifier forKey:@"defaults"];
		[animationSpeedSlider setProperty:@"animationSpeed" forKey:@"key"];
		[animationSpeedSlider setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];

		PSSpecifier *colorGroup = [PSSpecifier emptyGroupSpecifier];
		[colorGroup setProperty:@"Set color for flash, and mini image" forKey:@"footerText"];
		PSSpecifier *colorPicker = [PSSpecifier preferenceSpecifierNamed:@"UI Color" target:self set:NULL get:NULL detail:nil cell:PSLinkCell edit:nil];
		[colorPicker setProperty:%c(PFSimpleLiteColorCell) forKey:@"cellClass"];
		[colorPicker setProperty:@"UI Color" forKey:@"label"];
		[colorPicker setProperty:@{
			@"defaults" : kColorIdentifier,
			@"key" : @"color",
			@"fallback" : @"#FFFFFF",
			@"PostNotification" : kColorChangedIdentifier,
			@"alpha" : @NO
		} forKey:@"libcolorpicker"];
		colorPicker->action = @selector(cellAction);

		PSSpecifier *miniImageFinalScaleGroup = [PSSpecifier groupSpecifierWithName:@"Mini Image Scale"];
		[miniImageFinalScaleGroup setProperty:@"label" forKey:@"Mini Image Scale"];
		PSSpecifier *finalScaleSlider = [PSSpecifier preferenceSpecifierNamed:@"Mini-Image Scale" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
		[finalScaleSlider setProperty:%c(SXISliderCell) forKey:@"cellClass"];
		[finalScaleSlider setProperty:[NSNumber numberWithFloat:0.1] forKey:@"min"];
		[finalScaleSlider setProperty:[NSNumber numberWithFloat:0.33] forKey:@"max"];
		[finalScaleSlider setProperty:@YES forKey:@"showValue"];
		[finalScaleSlider setProperty:[NSNumber numberWithFloat:0.2] forKey:@"default"];
		[finalScaleSlider setProperty:kTweakIdentifier forKey:@"defaults"];
		[finalScaleSlider setProperty:@"miniImageScale" forKey:@"key"];
		[finalScaleSlider setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];

		PSSpecifier *miniImageWhitePaddingGroup = [PSSpecifier groupSpecifierWithName:@"Mini Image Border"];
		[miniImageWhitePaddingGroup setProperty:@"label" forKey:@"Mini Image Border"];
		PSSpecifier *miniImageWhitePaddingSlider = [PSSpecifier preferenceSpecifierNamed:@"Mini-Image Border" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
		[miniImageWhitePaddingSlider setProperty:%c(SXISliderCell) forKey:@"cellClass"];
		[miniImageWhitePaddingSlider setProperty:[NSNumber numberWithFloat:1.0] forKey:@"min"];
		[miniImageWhitePaddingSlider setProperty:[NSNumber numberWithFloat:25.0] forKey:@"max"];
		[miniImageWhitePaddingSlider setProperty:@YES forKey:@"showValue"];
		[miniImageWhitePaddingSlider setProperty:[NSNumber numberWithFloat:6.0] forKey:@"default"];
		[miniImageWhitePaddingSlider setProperty:kTweakIdentifier forKey:@"defaults"];
		[miniImageWhitePaddingSlider setProperty:@"miniImageWhitePadding" forKey:@"key"];
		[miniImageWhitePaddingSlider setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];

		PSSpecifier *miniImageMarginGroup = [PSSpecifier groupSpecifierWithName:@"Mini Image Margin"];
		[miniImageMarginGroup setProperty:@"label" forKey:@"Mini Image Margin"];
		PSSpecifier *miniImageMarginSlider = [PSSpecifier preferenceSpecifierNamed:@"Mini-Image Margin" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
		[miniImageMarginSlider setProperty:%c(SXISliderCell) forKey:@"cellClass"];
		[miniImageMarginSlider setProperty:[NSNumber numberWithFloat:0.0] forKey:@"min"];
		[miniImageMarginSlider setProperty:[NSNumber numberWithFloat:25.0] forKey:@"max"];
		[miniImageMarginSlider setProperty:@YES forKey:@"showValue"];
		[miniImageMarginSlider setProperty:[NSNumber numberWithFloat:10.0] forKey:@"default"];
		[miniImageMarginSlider setProperty:kTweakIdentifier forKey:@"defaults"];
		[miniImageMarginSlider setProperty:@"miniImageMargin" forKey:@"key"];
		[miniImageMarginSlider setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];

		PSSpecifier *miniImageRoundnessGroup = [PSSpecifier groupSpecifierWithName:@"Mini Image Roundness"];
		[miniImageRoundnessGroup setProperty:@"label" forKey:@"Mini Image Roundness"];
		PSSpecifier *miniImageRoundnessSlider = [PSSpecifier preferenceSpecifierNamed:@"Mini-Image Roundness" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
		[miniImageRoundnessSlider setProperty:%c(SXISliderCell) forKey:@"cellClass"];
		[miniImageRoundnessSlider setProperty:[NSNumber numberWithFloat:0.0] forKey:@"min"];
		[miniImageRoundnessSlider setProperty:[NSNumber numberWithFloat:25.0] forKey:@"max"];
		[miniImageRoundnessSlider setProperty:@YES forKey:@"showValue"];
		[miniImageRoundnessSlider setProperty:[NSNumber numberWithFloat:4.0] forKey:@"default"];
		[miniImageRoundnessSlider setProperty:kTweakIdentifier forKey:@"defaults"];
		[miniImageRoundnessSlider setProperty:@"miniImageRoundness" forKey:@"key"];
		[miniImageRoundnessSlider setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];

		PSSpecifier *dismissAnimationSpeedGroup = [PSSpecifier groupSpecifierWithName:@"Dismiss Animation Speed"];
		[dismissAnimationSpeedGroup setProperty:@"Dismiss Animation Speed" forKey:@"label"];
		PSSpecifier *dismissAnimationSpeedSlider = [PSSpecifier preferenceSpecifierNamed:@"Mini-Image Dismiss Animation Speed" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
		[dismissAnimationSpeedSlider setProperty:%c(SXISliderCell) forKey:@"cellClass"];
		[dismissAnimationSpeedSlider setProperty:[NSNumber numberWithFloat:0.0] forKey:@"min"];
		[dismissAnimationSpeedSlider setProperty:[NSNumber numberWithFloat:1.0] forKey:@"max"];
		[dismissAnimationSpeedSlider setProperty:@YES forKey:@"showValue"];
		[dismissAnimationSpeedSlider setProperty:[NSNumber numberWithFloat:0.5] forKey:@"default"];
		[dismissAnimationSpeedSlider setProperty:kTweakIdentifier forKey:@"defaults"];
		[dismissAnimationSpeedSlider setProperty:@"dismissAnimationSpeed" forKey:@"key"];
		[dismissAnimationSpeedSlider setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];

		PSSpecifier *previewAnimationSpeedGroup = [PSSpecifier groupSpecifierWithName:@"Preview Animation Speed"];
		[previewAnimationSpeedGroup setProperty:@"Preview Animation Speed" forKey:@"label"];
		[previewAnimationSpeedGroup setProperty:@"Mini Image preview (long press) animation speed" forKey:@"footerText"];
		PSSpecifier *previewAnimationSpeedSlider = [PSSpecifier preferenceSpecifierNamed:@"Mini-Image Preview Animation Speed" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
		[previewAnimationSpeedSlider setProperty:%c(SXISliderCell) forKey:@"cellClass"];
		[previewAnimationSpeedSlider setProperty:[NSNumber numberWithFloat:0.0] forKey:@"min"];
		[previewAnimationSpeedSlider setProperty:[NSNumber numberWithFloat:1.0] forKey:@"max"];
		[previewAnimationSpeedSlider setProperty:@YES forKey:@"showValue"];
		[previewAnimationSpeedSlider setProperty:[NSNumber numberWithFloat:0.15] forKey:@"default"];
		[previewAnimationSpeedSlider setProperty:kTweakIdentifier forKey:@"defaults"];
		[previewAnimationSpeedSlider setProperty:@"previewAnimationSpeed" forKey:@"key"];
		[previewAnimationSpeedSlider setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];

		PSSpecifier *previewAlphaGroup = [PSSpecifier groupSpecifierWithName:@"Preview Alpha"];
		[previewAlphaGroup setProperty:@"Preview Alpha" forKey:@"label"];
		[previewAlphaGroup setProperty:@"Mini Image preview (long press) alpha" forKey:@"footerText"];
		PSSpecifier *previewAlphaSlider = [PSSpecifier preferenceSpecifierNamed:@"Mini-Image Preview Alpha" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
		[previewAlphaSlider setProperty:%c(SXISliderCell) forKey:@"cellClass"];
		[previewAlphaSlider setProperty:[NSNumber numberWithFloat:0.0] forKey:@"min"];
		[previewAlphaSlider setProperty:[NSNumber numberWithFloat:1.0] forKey:@"max"];
		[previewAlphaSlider setProperty:@YES forKey:@"showValue"];
		[previewAlphaSlider setProperty:[NSNumber numberWithFloat:0.25] forKey:@"default"];
		[previewAlphaSlider setProperty:kTweakIdentifier forKey:@"defaults"];
		[previewAlphaSlider setProperty:@"previewAlpha" forKey:@"key"];
		[previewAlphaSlider setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];

		PSSpecifier *previewFinalScaleGroup = [PSSpecifier groupSpecifierWithName:@"Preview Scale"];
		[previewFinalScaleGroup setProperty:@"Preview Scale" forKey:@"label"];
		[previewFinalScaleGroup setProperty:@"Mini Image preview (long press) scale" forKey:@"footerText"];
		PSSpecifier *previewScaleSlider = [PSSpecifier preferenceSpecifierNamed:@"Mini-Image Preview Scale" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSliderCell edit:nil];
		[previewScaleSlider setProperty:%c(SXISliderCell) forKey:@"cellClass"];
		[previewScaleSlider setProperty:[NSNumber numberWithFloat:0.75] forKey:@"min"];
		[previewScaleSlider setProperty:[NSNumber numberWithFloat:1.25] forKey:@"max"];
		[previewScaleSlider setProperty:@YES forKey:@"showValue"];
		[previewScaleSlider setProperty:[NSNumber numberWithFloat:1.05] forKey:@"default"];
		[previewScaleSlider setProperty:kTweakIdentifier forKey:@"defaults"];
		[previewScaleSlider setProperty:@"previewScale" forKey:@"key"];
		[previewScaleSlider setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];

		PSSpecifier *resetGroup = [PSSpecifier emptyGroupSpecifier];
		PSSpecifier *resetAppearanceButton = [PSSpecifier preferenceSpecifierNamed:@"Reset Appearance" target:self set:NULL get:NULL detail:nil cell:PSButtonCell edit:nil];
		resetAppearanceButton->action = @selector(resetAppearance);
		[resetAppearanceButton setProperty:@"Reset Appearance" forKey:@"label"];
		[resetAppearanceButton setProperty:@1 forKey:@"alignment"];

		_specifiers = [@[animationSpeedGroup, animationSpeedSlider, colorGroup, colorPicker, miniImageFinalScaleGroup, finalScaleSlider, miniImageWhitePaddingGroup, miniImageWhitePaddingSlider, miniImageMarginGroup, miniImageMarginSlider, miniImageRoundnessGroup, miniImageRoundnessSlider, dismissAnimationSpeedGroup, dismissAnimationSpeedSlider, previewAnimationSpeedGroup, previewAnimationSpeedSlider, previewAlphaGroup, previewAlphaSlider, previewFinalScaleGroup, previewScaleSlider, resetGroup, resetAppearanceButton] mutableCopy];
	}

	return _specifiers;
}

- (void)resetAppearance {
	for (PSSpecifier *specifier in _specifiers) {
		if ([specifier propertyForKey:@"key"] != nil) {
			[self setPreferenceValue:[specifier propertyForKey:@"default"] specifier:specifier];
		} else if ([specifier propertyForKey:@"libcolorpicker"] != nil) { // manually do it for color picker as its' key works differently
			NSDictionary *colorPickerDictionary = (NSDictionary *)[specifier propertyForKey:@"libcolorpicker"];
			NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", [colorPickerDictionary objectForKey:@"defaults"]];
			NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path] ?: [NSMutableDictionary dictionary];
			[settings setObject:[colorPickerDictionary objectForKey:@"fallback"] forKey:[colorPickerDictionary objectForKey:@"key"]];
			[settings writeToFile:path atomically:YES];
			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)[colorPickerDictionary objectForKey:@"PostNotification"], NULL, NULL, YES);
		}
	}
	[self reloadSpecifiers];
}

- (void)viewWillAppear:(BOOL)animated {
	[self clearCache];
	[self reload];
	[super viewWillAppear:animated];
}

@end