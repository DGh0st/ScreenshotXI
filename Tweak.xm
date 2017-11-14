#import "headers.h"

extern "C" UIImage *_UICreateScreenUIImageWithRotation(BOOL rotate);

ESSWindow *window = nil; // need it to be global so it can be accessed in ESSContainerView.mm

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)arg1 {
	%orig(arg1);

	if (window != nil)
		[window release];
	
	SXIPreferences *preferenceManager = [SXIPreferences sharedInstance];

	SBLockScreenManager *manager = [%c(SBLockScreenManager) sharedInstance];
	if (manager != nil) {
		SBLockScreenViewControllerBase *lockScreenViewController = [manager lockScreenViewController];
		if ([lockScreenViewController isKindOfClass:%c(SBLockScreenViewController)]) {
			UIView *lockScreenView = [(SBLockScreenViewController *)lockScreenViewController lockScreenView];
			preferenceManager.aboveLockscreenWindowLevel = lockScreenView.window.windowLevel + 1;
			preferenceManager.aboveHomeAndAppsWindowLevel = lockScreenView.window.windowLevel - 2;
		} else if ([lockScreenViewController isKindOfClass:%c(SBDashBoardViewController)]) {
			UIView *dashBoardView = [(SBDashBoardViewController *)lockScreenViewController dashBoardView];
			preferenceManager.aboveLockscreenWindowLevel = dashBoardView.window.windowLevel + 1;
			preferenceManager.aboveHomeAndAppsWindowLevel = dashBoardView.window.windowLevel - 2;
		}
	}

	[preferenceManager updatePriority];

	window = [[ESSWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

-(void)noteInterfaceOrientationChanged:(UIInterfaceOrientation)arg1 duration:(CGFloat)arg2 logMessage:(id)arg3 {
	%orig(arg1, arg2, arg3);

	if (window != nil) { // manual rotation to fix split view controllers rotations
		ESSController *viewController = (ESSController *)(window.rootViewController);
		viewController.rotationEnabled = YES;
		[window _updateToInterfaceOrientation:arg1 animated:YES];
		viewController.rotationEnabled = NO;
	}
}

-(void)noteInterfaceOrientationChanged:(UIInterfaceOrientation)arg1 duration:(CGFloat)arg2 {
	%orig(arg1, arg2);

	if (window != nil) { // manual rotation to fix split view controllers rotations
		ESSController *viewController = (ESSController *)(window.rootViewController);
		viewController.rotationEnabled = YES;
		[window _updateToInterfaceOrientation:arg1 animated:YES];
		viewController.rotationEnabled = NO;
	}
}

-(void)frontDisplayDidChange:(id)arg1 {
	%orig(arg1);

	if (window != nil) {
		ESSController *viewController = (ESSController *)(window.rootViewController);
		viewController.rotationEnabled = YES;
		[window _updateToInterfaceOrientation:[self activeInterfaceOrientation] animated:YES];
		viewController.rotationEnabled = NO;

		[viewController updateUndoAndRedoButtons];

		SXIPreferences *preferenceManager = [SXIPreferences sharedInstance];

		if ([arg1 isKindOfClass:%c(SBLockScreenViewController)] || [arg1 isKindOfClass:%c(SBDashBoardViewController)]) {
			DisplayedControllerType currentControllerType = [viewController currentlyHostingViewControllerType];
			if (preferenceManager.isDismissOnLockEnabled) {
				for (UIView *view in viewController.containerViews) {
					[NSObject cancelPreviousPerformRequestsWithTarget:viewController selector:@selector(autoHide:) object:view];
					if ([view isKindOfClass:%c(ESSContainerView)] && currentControllerType == kNone && preferenceManager.isSaveOnSwipeDismissEnabled)
						[viewController saveScreenshot:((ESSContainerView *)view).image];
					[viewController forceHideWithoutAnimations:view];
				}

				if (currentControllerType == kEditor) {
					[viewController forceSaveMarkUpWithCompletion:^{
						window.windowLevel = preferenceManager.currentTweakLevel;
					}];
				} else if (currentControllerType == kShareSheet) {
					[viewController dismissShareSheetAnimated:NO completion:^{
						window.windowLevel = preferenceManager.currentTweakLevel;
					}];
				} else {
					window.windowLevel = preferenceManager.currentTweakLevel;
				}
			} else {
				if (currentControllerType == kEditor && preferenceManager.isLockscreenEditDisabled) {
					[viewController forceSaveMarkUpWithCompletion:^{
						window.windowLevel = preferenceManager.currentTweakLevel;
					}];
				} else if (currentControllerType == kShareSheet && preferenceManager.isLockscreenShareDisabled) {
					[viewController dismissShareSheetAnimated:NO completion:^{
						window.windowLevel = preferenceManager.currentTweakLevel;
					}];
				} else {
					window.windowLevel = preferenceManager.currentTweakLevel;
				}
			}
		} else {
			if (preferenceManager.currentTweakLevel == preferenceManager.aboveLockscreenWindowLevel)
				window.windowLevel = preferenceManager.aboveHomeAndAppsWindowLevel;
		}
	}
}
%end

%hook SBScreenshotManager
-(void)saveScreenshotsWithCompletion:(id)arg1 {
	SXIPreferences *preferenceManager = [SXIPreferences sharedInstance];
	if (window != nil && preferenceManager.isEnabled) {
		ESSController *viewController = (ESSController *)(window.rootViewController);
		if ([viewController currentlyHostingViewControllerType] != kNone)
			return;

		for (UIView *view in viewController.containerViews) {
			[NSObject cancelPreviousPerformRequestsWithTarget:viewController selector:@selector(autoHide:) object:view];
			[view.layer removeAllAnimations];
			view.hidden = TRUE;
			[view setNeedsDisplay];
			if (preferenceManager.isSpamSaveEnabled && [view isKindOfClass:%c(ESSContainerView)])
				[viewController saveScreenshot:((ESSContainerView *)view).image];
			[viewController forceHideWithoutAnimations:view];
		}

		if ([(SpringBoard *)[%c(SpringBoard) sharedApplication] isLocked])
			[[%c(SBBacklightController) sharedInstance] resetLockScreenIdleTimer];

		dispatch_async(dispatch_get_main_queue(), ^{
			if (!preferenceManager.isShutterSoundDisabled)
				AudioServicesPlaySystemSound(kPhotoShutterSystemSound);

			SBScreenFlash *flasher = [%c(SBScreenFlash) mainScreenFlasher];
			UIImage *screenImage = _UICreateScreenUIImageWithRotation(TRUE);
			[flasher setScreenshotImage:screenImage];
			[flasher screenshotwithCompletion:nil];
		});
	} else {
		%orig(arg1);
	}
}
%end

%hook SBScreenShotter
-(void)saveScreenshot:(BOOL)arg1 {
	SXIPreferences *preferenceManager = [SXIPreferences sharedInstance];
	if (window != nil && preferenceManager.isEnabled) {
		ESSController *viewController = (ESSController *)(window.rootViewController);
		if ([viewController currentlyHostingViewControllerType] != kNone)
			return;

		for (UIView *view in viewController.containerViews) {
			[NSObject cancelPreviousPerformRequestsWithTarget:viewController selector:@selector(autoHide:) object:view];
			[view.layer removeAllAnimations];
			view.hidden = TRUE;
			[view setNeedsDisplay];
			if (preferenceManager.isSpamSaveEnabled && [view isKindOfClass:%c(ESSContainerView)])
				[viewController saveScreenshot:((ESSContainerView *)view).image];
			[viewController forceHideWithoutAnimations:view];
		}

		if ([(SpringBoard *)[%c(SpringBoard) sharedApplication] isLocked])
			[[%c(SBBacklightController) sharedInstance] resetLockScreenIdleTimer];

		dispatch_async(dispatch_get_main_queue(), ^{
			if (!preferenceManager.isShutterSoundDisabled)
				AudioServicesPlaySystemSound(kPhotoShutterSystemSound);

			SBScreenFlash *flasher = [%c(SBScreenFlash) mainScreenFlasher];
			UIImage *screenImage = _UICreateScreenUIImageWithRotation(TRUE);
			[flasher setScreenshotImage:screenImage];
			[flasher screenshotwithCompletion:nil];
		});
	} else {
		%orig(arg1);
	}
}
%end

%hook SBScreenFlash
UIImage *_screenshotImage;

%new
-(void)screenshotwithCompletion:(id)arg1 {
	[self flashColor:[UIColor clearColor] withCompletion:arg1];

	if (window != nil) {
		ESSController *viewController = (ESSController *)(window.rootViewController);
		SXIPreferences *preferenceManager = [SXIPreferences sharedInstance];
		
		CGFloat imageViewWidth = window.frame.size.width * preferenceManager.miniImageScale;
		CGFloat imageViewHeight = window.frame.size.height * preferenceManager.miniImageScale;

		UIWindow *_flashWindow = MSHookIvar<UIWindow *>(self, "_flashWindow");
		if (_flashWindow != nil) {
			_flashWindow.hidden = YES;
			window.windowLevel = _flashWindow.windowLevel; // 2200 for flash window

			if (preferenceManager.screenFlashWindowLevel != window.windowLevel) {
				preferenceManager.screenFlashWindowLevel = window.windowLevel;
				[preferenceManager updatePriority];
			}
		}

		if (preferenceManager.isNotifyApplicationsEnabled) {
			UIRemoteApplication *remoteApplication = [(SpringBoard *)[%c(SpringBoard) sharedApplication] _accessibilityFrontMostApplication].remoteApplication;
			[remoteApplication didTakeScreenshot];
		}

		if ([(SpringBoard *)[%c(SpringBoard) sharedApplication] isLocked])
			[[%c(SBBacklightController) sharedInstance] resetLockScreenIdleTimer];

		UIColor *borderColor = [LCPParseColorString([preferenceManager uiHexColor], @"#FFFFFF") retain];
		ESSContainerView *containerView = [[ESSContainerView alloc] initWithFrame:CGRectMake(preferenceManager.miniImageMargin, window.frame.size.height - imageViewHeight - preferenceManager.miniImageMargin - 2 * preferenceManager.miniImageWhitePadding, imageViewWidth + 2 * preferenceManager.miniImageWhitePadding, imageViewHeight + 2 * preferenceManager.miniImageWhitePadding) withColor:borderColor];
		[viewController.containerViews addObject:containerView];
		[viewController.view addSubview:containerView];

		[UIView animateWithDuration:preferenceManager.animationSpeed animations:^{
			[containerView setTransform:CGAffineTransformMakeScale(1, 1)];
			containerView.center = CGPointMake(preferenceManager.miniImageMargin + preferenceManager.miniImageWhitePadding + imageViewWidth / 2, window.frame.size.height - imageViewHeight / 2 - preferenceManager.miniImageMargin - preferenceManager.miniImageWhitePadding);
			[containerView.layer setCornerRadius:preferenceManager.miniImageRoundness];
		} completion:^(BOOL finished) {
			if (preferenceManager.currentTweakLevel == preferenceManager.aboveLockscreenWindowLevel)
				window.windowLevel = ([(SpringBoard *)[%c(SpringBoard) sharedApplication] isLocked]) ? preferenceManager.aboveLockscreenWindowLevel : preferenceManager.aboveHomeAndAppsWindowLevel;
			else
				window.windowLevel = preferenceManager.currentTweakLevel;

			if (finished) {
				UIImage *image = _screenshotImage;
				_screenshotImage = nil;
				if (image == nil) { // just in case (should never actually go inside this if statement)
					PLPhotoLibrary *library = [PLPhotoLibrary sharedPhotoLibrary];
					PLManagedAlbum *album = [library.albums firstObject];
					PLManagedAsset *photo = [album.assets lastObject];
					image = [[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[photo mainFileURL]]] autorelease];
				}

				UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
				imageView.frame = CGRectMake(preferenceManager.miniImageWhitePadding, preferenceManager.miniImageWhitePadding, imageViewWidth, imageViewHeight);
				imageView.clipsToBounds = YES;
				imageView.contentMode = UIViewContentModeScaleAspectFit;

				UIBlurEffect *blur = nil;
				// lightness code stolen from https://stackoverflow.com/questions/2509443/check-if-uicolor-is-dark-or-bright
				const CGFloat *rgba = CGColorGetComponents(borderColor.CGColor);
				CGFloat brightness = (rgba[0] * 299 + rgba[1] * 587 * rgba[2] * 114) / 1000;
				if (brightness < 0.5)
					blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
				else
					blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
				UIVisualEffectView *lightBlurView = [[UIVisualEffectView alloc] initWithEffect:blur];
				[lightBlurView setFrame:imageView.bounds];
				[imageView addSubview:lightBlurView];
				[containerView insertSubview:imageView atIndex:0];

				[UIView transitionWithView:imageView duration:preferenceManager.dismissAnimationSpeed options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
					[lightBlurView setEffect:nil];
				} completion:^(BOOL finished) {
					if (finished) {
						[lightBlurView removeFromSuperview];
						[lightBlurView release];

						if (preferenceManager.isCopyToPasteBoardEnabled)
							[UIPasteboard generalPasteboard].image = image;
					}
				}];

				UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:viewController action:@selector(imageTapped:)];
				[tapRecognizer setDelegate:viewController];
				[containerView addGestureRecognizer:tapRecognizer];

				UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:viewController action:@selector(imagePanned:)];
				[panRecognizer setDelegate:viewController];
				panRecognizer.minimumNumberOfTouches = 1;
				[containerView addGestureRecognizer:panRecognizer];

				UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:viewController action:@selector(imageLongPressed:)];
				[longPressRecognizer setDelegate:viewController];			
				longPressRecognizer.numberOfTapsRequired = 0;
				longPressRecognizer.minimumPressDuration = kLongPressStartDuration;
				longPressRecognizer.allowableMovement = kLongPressRange;
				[containerView addGestureRecognizer:longPressRecognizer];

				[tapRecognizer requireGestureRecognizerToFail:longPressRecognizer];
				[panRecognizer requireGestureRecognizerToFail:longPressRecognizer];

				containerView.image = image;

				if (!preferenceManager.isUnlimitedDismissTimeEnabled)
					[viewController performSelector:@selector(autoHide:) withObject:containerView afterDelay:preferenceManager.dismissTime];

				[imageView release];
				[tapRecognizer release];
				[panRecognizer release];
				[longPressRecognizer release];

				if ([(SpringBoard *)[%c(SpringBoard) sharedApplication] isLocked])
					[[%c(SBBacklightController) sharedInstance] resetLockScreenIdleTimer];
			}
		}];
	}
}

%new
-(void)setScreenshotImage:(id)image {
	_screenshotImage = image;
}

%new
-(UIImage *)screenshotImage {
	return _screenshotImage;
}
%end

%hook MarkupViewController
-(void)_updateUndoButtonWithController:(id)arg1 {
	%orig(arg1);

	if (window != nil) {
		ESSController *viewController = (ESSController *)(window.rootViewController);
		if ([viewController isEqualToMarkUpEditor:self]) // only call update on our view controller
			[viewController updateUndoAndRedoButtons];
	}
}
%end

%hook AKUndoController
-(void)_annotationsWillBeRemoved:(id)arg1 onPageController:(id)arg2 {
	%orig(arg1, arg2);

	if (window != nil) {
		ESSController *viewController = (ESSController *)(window.rootViewController);
		if ([viewController isEqualToUndoController:self]) // only call update on our view controller
			[viewController updateUndoAndRedoButtons];
	}
}

-(void)_annotationsWereAdded:(id)arg1 onPageController:(id)arg2 {
	%orig(arg1, arg2);

	if (window != nil) {
		ESSController *viewController = (ESSController *)(window.rootViewController);
		if ([viewController isEqualToUndoController:self]) // only call update on our view controller
			[viewController updateUndoAndRedoButtons];
	}
}
%end

%hook MUImageContentViewController
-(CGFloat)_zoomToFitZoomFactorIncludingScrollViewEdgeInsets {
	CGFloat result = %orig();
	if (window != nil) {
		ESSController *viewController = (ESSController *)(window.rootViewController);
		if ([viewController isEqualToImageContentViewController:self]) // only modify if it is our mark up editor's image controller
			return result * kImageMinimumScaleMultiplier;
	}
	return result;
}
%end

%hook SBInCallAlertManager // to hide tweak when in phone call
-(void)noteActivatedInCallAlert:(id)arg1 {
	%orig(arg1);

	SXIPreferences *preferenceManager = [SXIPreferences sharedInstance];

	if (window != nil && preferenceManager.isDismissOnCallEnabled) {
		ESSController *viewController = (ESSController *)(window.rootViewController);
		DisplayedControllerType currentControllerType = [viewController currentlyHostingViewControllerType];
		for (UIView *view in viewController.containerViews) {
			[NSObject cancelPreviousPerformRequestsWithTarget:viewController selector:@selector(autoHide:) object:view];
			if ([view isKindOfClass:%c(ESSContainerView)] && currentControllerType == kNone && preferenceManager.isSaveOnSwipeDismissEnabled)
				[viewController saveScreenshot:((ESSContainerView *)view).image];
			[viewController forceHideWithoutAnimations:view];
		}
		[viewController forceSaveMarkUpWithCompletion:nil];
		[viewController dismissShareSheetAnimated:NO completion:nil];
	}
}
%end

%hook MUImageDownsamplingUtilities // winterboard fix (might even fix anemone)
+(CGImageSourceRef)_newImageSourceWithSourceContent:(id)arg1 {
	if (window != nil) {
		ESSController *viewController = (ESSController *)(window.rootViewController);
		if ([viewController isEqualToSourceContent:arg1])
			return %orig(nil);
		return %orig(arg1);
	} else {
		return %orig(arg1);
	}
}
%end

static void preferencesChanged() {
	[[SXIPreferences sharedInstance] updatePreferences];
}

%dtor {
	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFStringRef)kSettingsChangedIdentifier, NULL);

	if (window != nil) {
		[window release];
		window = nil;
	}	
}

%ctor {
	preferencesChanged();

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)preferencesChanged, (CFStringRef)kSettingsChangedIdentifier, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}