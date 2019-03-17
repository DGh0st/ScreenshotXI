#import <QuartzCore/QuartzCore.h>
#import "headers.h"

extern ESSWindow *window;

@implementation ESSController
+(UIImage *)imageFromView:(UIView *)view andView:(UIView *)secondView {
	UIGraphicsBeginImageContextWithOptions([view bounds].size, NO, 0.0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	if (CGAffineTransformIsIdentity(secondView.transform)) {
		[view.layer renderInContext:context];
		[secondView.layer renderInContext:context];
	} else {
		// calculate the translations and scales
		CGFloat scaleX = secondView.transform.a * view.frame.size.width / secondView.frame.size.width;
		CGFloat scaleY = secondView.transform.d * view.frame.size.height / secondView.frame.size.height;
		CGFloat translateX = scaleX < 0.0 ? [secondView bounds].size.width * -scaleX : 0.0;
		CGFloat translateY = scaleY < 0.0 ? [secondView bounds].size.height * -scaleY : 0.0;

		[view.layer renderInContext:context];
		CGContextSaveGState(context);
		CGContextTranslateCTM(context, translateX, translateY);
		CGContextScaleCTM(context, scaleX, scaleY);
		[secondView.layer renderInContext:context];
		CGContextRestoreGState(context);
	}
	UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return [result retain];
}

-(id)init {
	self = [super init];
	if (self != nil) {
		self.containerViews = [NSMutableArray array];
		_activityViewController = nil;
		_markUpEditor = nil;
		self.rotationEnabled = NO;
		useLongPressAsPan = YES;
		timerDidTrigger = NO;
		didHideStatusBar = NO;
		resultEditedImage = nil;
	}
	return self;
}

-(void)dealloc {
	for (ESSContainerView *view in self.containerViews) {
		[view release];
		view = nil;
	}
	if (_activityViewController != nil)
		[_activityViewController release];
	_activityViewController = nil;
	if (_markUpEditor != nil) {
		if (_markUpEditor.navBar != nil)
			[_markUpEditor.navBar release];
		_markUpEditor.navBar = nil;
		[_markUpEditor release];
	}
	_markUpEditor = nil;
	if (redoButton != nil)
		[redoButton release];
	redoButton = nil;
	if (undoButton != nil)
		[undoButton release];
	undoButton = nil;
	if (saveButton != nil)
		[saveButton release];
	saveButton = nil;
	if (shareButton != nil)
		[shareButton release];
	shareButton = nil;
	if (resultEditedImage != nil) 
		[resultEditedImage release];
	resultEditedImage = nil;
	[super dealloc];
}

-(void)saveScreenshot:(UIImage *)image {
	if (%c(SBScreenShotter))
		UIImageWriteToSavedPhotosAlbum(image, [%c(SBScreenShotter) sharedInstance], @selector(finishedWritingScreenshot:didFinishSavingWithError:context:), nil);
	else if (%c(SBScreenshotManager))
		[[((SpringBoard *)[%c(SpringBoard) sharedApplication]).screenshotManager _persistenceCoordinator] saveScreenshot:image withCompletion:nil];
}

-(BOOL)shouldAutorotate {
	return self.rotationEnabled;
}

-(void)viewWillTransitionToSize:(CGSize)arg1 withTransitionCoordinator:(id)arg2 {
	[super viewWillTransitionToSize:arg1 withTransitionCoordinator:arg2];

	if (_markUpEditor != nil && _markUpEditor.navBar != nil)
		[arg2 animateAlongsideTransition:^(id context) {
			_markUpEditor.navBar.frame = CGRectMake(0, 0, arg1.width, 44);
		} completion:nil];
}

-(void)displayShareSheet:(ESSContainerView *)view {
	SXIPreferences *preferenceManager = [SXIPreferences sharedInstance];

	if ([(SpringBoard *)[%c(SpringBoard) sharedApplication] isLocked] && preferenceManager.isLockscreenShareDisabled) {
		[view shake];
		if (!preferenceManager.isUnlimitedDismissTimeEnabled)
			[self performSelector:@selector(autoHide:) withObject:view afterDelay:preferenceManager.dismissTime];
	} else {
		if (_activityViewController == nil) {
			SpringBoard *springBoardApplication = (SpringBoard *)[%c(SpringBoard) sharedApplication];
			if ([springBoardApplication _accessibilityFrontMostApplication] == nil)
				[springBoardApplication sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
			else
				[[%c(SBUIController) sharedInstance] _hideKeyboard];

			_activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[view.image] applicationActivities:nil];
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
				_activityViewController.popoverPresentationController.sourceView = view;
			[_activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activtyError) {
				[_activityViewController release];
				_activityViewController = nil;
				if (completed) {
					[self forceHide:view];

					if (activityType != UIActivityTypeSaveToCameraRoll && preferenceManager.isSaveOnShareEnabled)
						[self saveScreenshot:view.image];
				} else {
					if (!preferenceManager.isUnlimitedDismissTimeEnabled)
						[self performSelector:@selector(autoHide:) withObject:view afterDelay:preferenceManager.dismissTime];
				}
			}];
			if (preferenceManager.isSaveOnSwipeDismissEnabled)
				_activityViewController.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll];
			_activityViewController.showKeyboardAutomatically = YES;
			[window makeKeyWindow]; // blank keyboard fix

			[self presentViewController:_activityViewController animated:YES completion:nil];
		}
	}
}

-(void)displayEditor:(ESSContainerView *)view {
	SXIPreferences *preferenceManager = [SXIPreferences sharedInstance];

	if ([(SpringBoard *)[%c(SpringBoard) sharedApplication] isLocked] && preferenceManager.isLockscreenEditDisabled) {
		[view shake];
		if (!preferenceManager.isUnlimitedDismissTimeEnabled)
			[self performSelector:@selector(autoHide:) withObject:view afterDelay:preferenceManager.dismissTime];
	} else {
		if (%c(ANEMSettingsManager)) {
			ANEMSettingsManager *anemoneSettingsManager = [%c(ANEMSettingsManager) sharedManager];
			if (anemoneSettingsManager != nil && [anemoneSettingsManager respondsToSelector:@selector(setCGImageHookEnabled:)])
				[anemoneSettingsManager setCGImageHookEnabled:NO];
		}
		SpringBoard *springBoardApplication = (SpringBoard *)[%c(SpringBoard) sharedApplication];
		if ([springBoardApplication _accessibilityFrontMostApplication] == nil) {
			didHideStatusBar = YES;
			[springBoardApplication setStatusBarHidden:YES];
			[self setNeedsStatusBarAppearanceUpdate];
			[springBoardApplication sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
		} else {
			[[%c(SBUIController) sharedInstance] _hideKeyboard];
		}

		if (resultEditedImage != nil)
			[resultEditedImage release];
		resultEditedImage = nil;

		[self forceHide:view];

		if  (_markUpEditor == nil) {
			_markUpEditor = [[MarkupViewController alloc] initWithNibName:nil bundle:nil];
			[_markUpEditor setImage:view.image];
			if ([_markUpEditor respondsToSelector:@selector(setAnnotationEditingEnabled:)])
				[_markUpEditor setAnnotationEditingEnabled:YES];
			[_markUpEditor setShapeDetectionEnabled:YES];
			[_markUpEditor setDelegate:self]; // really doesn't do anything as I don't implement any methods for delegate
			_markUpEditor.annotationController.overlayShouldPixelate = NO;
			[_markUpEditor.annotationController currentPageController].shouldPixelate = NO;

			NSBundle *bundle = [NSBundle bundleWithPath:kBundlePath];

			UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
			navigationBar.delegate = _markUpEditor;
			navigationBar.barStyle = UIBarStyleBlackTranslucent;
			_markUpEditor.navBar = navigationBar;

			UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@""];

			UIBarButtonItem *cancelButton = nil;
			if (bundle != nil) {
				cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(cancelMarkUp)];
				saveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"save" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(saveMarkUp)];
			} else {
				cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelMarkUp)];
				saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveMarkUp)];
			}
			[navigationItem setLeftBarButtonItems:@[cancelButton, saveButton]];

			if (bundle != nil) {
				shareButton =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(shareMarkUp:)];
				redoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"redo" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(redoMarkUp)];
				undoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"undo" inBundle:bundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(undoMarkUp)];
			} else {
				shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareMarkUp:)];
				redoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRedo target:self action:@selector(redoMarkUp)];
				undoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(undoMarkUp)];
			}
			[navigationItem setRightBarButtonItems:@[shareButton, redoButton, undoButton]];

			navigationBar.items = @[navigationItem];

			[_markUpEditor.view addSubview:navigationBar];
			
			[window makeKeyWindow]; // blank keyboard fix

			[self presentViewController:_markUpEditor animated:YES completion:nil];
			[self updateUndoAndRedoButtons];

			[navigationItem release];
			[cancelButton release];
		}
	}
}

-(void)saveMarkUp {
	if (_markUpEditor != nil) {
		if ([SXIPreferences sharedInstance].isSaveUneditedEnabled)
			[self saveScreenshot:_markUpEditor.sourceContent];

		if (resultEditedImage == nil) {
			[_markUpEditor.annotationController.modelController deselectAllAnnotations];
			UIImage *sourceImage = (UIImage *)(_markUpEditor.sourceContent);
			UIImageView *imageView = [[UIImageView alloc] initWithImage:sourceImage];
			imageView.frame = CGRectMake(0, 0, sourceImage.size.width, sourceImage.size.height);
			UIView *overlayView = [_markUpEditor.annotationController currentPageController].overlayView;
			resultEditedImage = [ESSController imageFromView:imageView andView:overlayView];
			
			[imageView release];
			overlayView = nil;
		}
		[self saveScreenshot:resultEditedImage];

		[self dismissMarkUpEditorAnimated:YES completion:nil];
	}
}

-(void)forceSaveMarkUpWithCompletion:(void (^)())completion {
	if (_markUpEditor != nil) {
		if ([SXIPreferences sharedInstance].isSaveUneditedEnabled)
			[self saveScreenshot:_markUpEditor.sourceContent];

		if (resultEditedImage == nil) {
			[_markUpEditor.annotationController.modelController deselectAllAnnotations];
			UIImage *sourceImage = (UIImage *)(_markUpEditor.sourceContent);
			UIImageView *imageView = [[UIImageView alloc] initWithImage:sourceImage];
			imageView.frame = CGRectMake(0, 0, sourceImage.size.width, sourceImage.size.height);
			UIView *overlayView = [_markUpEditor.annotationController currentPageController].overlayView;
			resultEditedImage = [ESSController imageFromView:imageView andView:overlayView];

			[imageView release];
			overlayView = nil;
		}
		[self saveScreenshot:resultEditedImage];

		[self dismissMarkUpEditorAnimated:NO completion:completion];
	}
}

-(void)shareMarkUp:(UIBarButtonItem *)sender {
	if (_markUpEditor != nil) {
		if (resultEditedImage == nil) {
			[_markUpEditor.annotationController.modelController deselectAllAnnotations];
			UIImage *sourceImage = (UIImage *)(_markUpEditor.sourceContent);
			UIImageView *imageView = [[UIImageView alloc] initWithImage:sourceImage];
			imageView.frame = CGRectMake(0, 0, sourceImage.size.width, sourceImage.size.height);
			UIView *overlayView = [_markUpEditor.annotationController currentPageController].overlayView;
			resultEditedImage = [ESSController imageFromView:imageView andView:overlayView];

			[imageView release];
			overlayView = nil;
		}

		UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[resultEditedImage] applicationActivities:nil];
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			activityViewController.popoverPresentationController.sourceView = [sender view];
		[activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activtyError) {
			if (completed) {
				SXIPreferences *preferenceManager = [SXIPreferences sharedInstance];
				if (preferenceManager.isSaveUneditedOnShareEnabled)
					[self saveScreenshot:_markUpEditor.sourceContent];
				if (activityType != UIActivityTypeSaveToCameraRoll && preferenceManager.isSaveOnShareEnabled)
					[self saveScreenshot:resultEditedImage];
				[self dismissMarkUpEditorAnimated:YES completion:nil];
			}
		}];
		activityViewController.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll];
		activityViewController.showKeyboardAutomatically = YES;
		[window makeKeyWindow]; // blank keyboard fix

		[_markUpEditor presentViewController:activityViewController animated:YES completion:nil];

		[activityViewController release];
	}
}

-(void)cancelMarkUp {
	if ([SXIPreferences sharedInstance].isSaveUneditedOnCancelEnabled)
		[self saveScreenshot:_markUpEditor.sourceContent];
	[self dismissMarkUpEditorAnimated:YES completion:nil];
}

-(void)dismissMarkUpEditorAnimated:(BOOL)animated completion:(void (^)())completion {
	if (_markUpEditor != nil) {
		void (^dismissMarkUp)() = ^{
			[_markUpEditor dismissViewControllerAnimated:animated completion:^{
				[_markUpEditor.navBar release];
				_markUpEditor.navBar = nil;
				[_markUpEditor release];
				_markUpEditor = nil;
				[redoButton release];
				redoButton = nil;
				[undoButton release];
				undoButton = nil;
				[saveButton release];
				saveButton = nil;
				[shareButton release];
				shareButton = nil;

				if (resultEditedImage != nil)
					[resultEditedImage release];
				resultEditedImage = nil;

				if (%c(ANEMSettingsManager)) {
					ANEMSettingsManager *anemoneSettingsManager = [%c(ANEMSettingsManager) sharedManager];
					if (anemoneSettingsManager != nil && [anemoneSettingsManager respondsToSelector:@selector(setCGImageHookEnabled:)])
						[anemoneSettingsManager setCGImageHookEnabled:YES];
				}
				
				if (didHideStatusBar) {
					didHideStatusBar = NO;
					[(SpringBoard *)[%c(SpringBoard) sharedApplication] setStatusBarHidden:NO];
					[self setNeedsStatusBarAppearanceUpdate];
				}

				if (completion != nil)
					completion();
			}];
		};

		if ([_markUpEditor presentedViewController] != nil)
			[[_markUpEditor presentedViewController] dismissViewControllerAnimated:animated completion:dismissMarkUp];
		else
			dismissMarkUp();
	}
}

-(void)dismissShareSheetAnimated:(BOOL)animated completion:(void (^)(void))completion {
	if (_activityViewController != nil)
		[_activityViewController dismissViewControllerAnimated:animated completion:^{
			[_activityViewController release];
			_activityViewController = nil;

			if (completion != nil)
				completion();
		}];
}

-(void)undoMarkUp {
	if (_markUpEditor != nil) {
		NSUndoManager *undoManager = _markUpEditor.akUndoManager;
		if (undoButton != nil && undoManager.canUndo)
			[undoManager undo];
		[self updateUndoAndRedoButtons];
	}
}

-(void)redoMarkUp {
	if (_markUpEditor != nil) {
		NSUndoManager *undoManager = _markUpEditor.akUndoManager;
		if (undoButton != nil && undoManager.canRedo)
			[undoManager redo];
		[self updateUndoAndRedoButtons];
	}
}

-(void)updateUndoAndRedoButtons {
	if (_markUpEditor != nil) {
		NSUndoManager *undoManager = _markUpEditor.akUndoManager;
		[UIView animateWithDuration:[SXIPreferences sharedInstance].dismissAnimationSpeed animations:^{
			if (redoButton != nil)
				redoButton.enabled = undoManager.canRedo;
			if (undoButton != nil)
				undoButton.enabled = undoManager.canUndo;
			if (saveButton != nil)
				saveButton.enabled = undoButton.enabled;
		} completion: ^(BOOL finished) {
			if (finished)
				if (resultEditedImage != nil) {
					[resultEditedImage release];
					resultEditedImage = nil;
				}
		}];

		if (shareButton != nil) {
			if ([(SpringBoard *)[%c(SpringBoard) sharedApplication] isLocked])
				shareButton.enabled = ![SXIPreferences sharedInstance].isLockscreenShareDisabled;
			else
				shareButton.enabled = YES;
		}
	}
}

-(BOOL)isEqualToUndoController:(id)undoController {
	return _markUpEditor != nil && [_markUpEditor.annotationController.undoController isEqual:undoController];
}

-(BOOL)isEqualToMarkUpEditor:(id)editor {
	return _markUpEditor != nil && [_markUpEditor isEqual:editor];
}

-(BOOL)isEqualToImageContentViewController:(id)imageContentViewController {
	return _markUpEditor != nil && [_markUpEditor.contentViewController isEqual:imageContentViewController];
}

-(BOOL)isEqualToSourceContent:(id)sourceContent {
	return _markUpEditor != nil && [_markUpEditor.sourceContent isEqual:sourceContent];
}

-(BOOL)isPresentingEditor {
	return [self isEqualToMarkUpEditor:[self presentedViewController]];
}

-(DisplayedControllerType)currentlyHostingViewControllerType {
	if (_activityViewController != nil)
		return kShareSheet;
	else if (_markUpEditor != nil)
		return kEditor;
	else
		return kNone;
}

-(void)autoHide:(UIView *)view {
	if (view != nil && [view isKindOfClass:%c(ESSContainerView)] && [SXIPreferences sharedInstance].isSaveOnAutoDismissEnabled) {
		ESSContainerView *containerView = (ESSContainerView *)view;
		[self saveScreenshot:containerView.image];
	}
	[self forceHide:view];
}

-(void)forceHide:(UIView *)view {
	if (view != nil && [self.containerViews containsObject:view]) {
		SXIPreferences *preferenceManager = [SXIPreferences sharedInstance];
		if (![view isKindOfClass:%c(ESSContainerView)])
			[self forceHideWithoutAnimations:view];
		else
			[UIView animateWithDuration:preferenceManager.dismissAnimationSpeed animations:^{
				[view setTransform:CGAffineTransformMakeTranslation(-(2 * preferenceManager.miniImageMargin + view.frame.size.width), 0)];
				view.alpha = 0;
			} completion:^(BOOL finished) {
				[self forceHideWithoutAnimations:view];
			}];
	}
}

-(void)forceHideRight:(UIView *)view {
	if (view != nil && [self.containerViews containsObject:view]) {
		if (![view isKindOfClass:%c(ESSContainerView)])
			[self forceHideWithoutAnimations:view];
		else
			[UIView animateWithDuration:[SXIPreferences sharedInstance].dismissAnimationSpeed animations:^{
				[view setTransform:CGAffineTransformMakeTranslation(self.view.frame.size.width, 0)];
				view.alpha = 0;
			} completion:^(BOOL finished) {
				[self forceHideWithoutAnimations:view];
			}];
	}
}

-(void)forceHideWithoutAnimations:(UIView *)view {
	if (view != nil && [self.containerViews containsObject:view]) {
		[self.containerViews removeObject:view];
		[view removeFromSuperview];
		[view release];
	}

	if ([(SpringBoard *)[%c(SpringBoard) sharedApplication] isLocked])
		[[%c(SBBacklightController) sharedInstance] resetLockScreenIdleTimer];
}


-(void)imagePanned:(UIPanGestureRecognizer *)recognizer {
	if (![recognizer.view isKindOfClass:%c(ESSContainerView)])
		return;

	if ([(SpringBoard *)[%c(SpringBoard) sharedApplication] isLocked])
		[[%c(SBBacklightController) sharedInstance] resetLockScreenIdleTimer];

	ESSContainerView *containerView = (ESSContainerView *)(recognizer.view);
	CGPoint translationPoint = [recognizer translationInView:self.view];
	CGPoint velocityPoint = [recognizer velocityInView:self.view];

	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(displayShareSheetTimerTriggered:) object:containerView];

	SXIPreferences *preferenceManager = [SXIPreferences sharedInstance];

	switch (recognizer.state) {
		case UIGestureRecognizerStateBegan:
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoHide:) object:containerView];
		case UIGestureRecognizerStateChanged:
			if (translationPoint.x > 0 && !preferenceManager.isRightSwipeEnabled)
				translationPoint.x = 0;
			[containerView setTransform:CGAffineTransformMakeTranslation(translationPoint.x, 0)];
			break;
		case UIGestureRecognizerStateEnded:
			if (containerView.frame.origin.x + translationPoint.x + velocityPoint.x < -containerView.frame.size.width) {
				[self forceHide:containerView];

				if (preferenceManager.isSaveOnSwipeDismissEnabled)
					[self saveScreenshot:containerView.image];
			} else if (containerView.frame.origin.x + translationPoint.x + velocityPoint.x > self.view.frame.size.width && preferenceManager.isRightSwipeEnabled) {
				[self forceHideRight:containerView];

				if (preferenceManager.isSaveOnRightSwipeDismissEnabled)
					[self saveScreenshot:containerView.image];
			} else {
				[UIView animateWithDuration:preferenceManager.dismissAnimationSpeed animations:^{
					[containerView setTransform:CGAffineTransformMakeTranslation(0, 0)];
				} completion:^(BOOL finished) {
					if (!preferenceManager.isUnlimitedDismissTimeEnabled)
						[self performSelector:@selector(autoHide:) withObject:containerView afterDelay:preferenceManager.dismissTime];
				}];
			}
			break;
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateFailed:
			break;
		default:
			break;
	}
}

-(void)imageLongPressed:(UILongPressGestureRecognizer *)recognizer {
	if (![recognizer.view isKindOfClass:%c(ESSContainerView)])
		return;

	if ([(SpringBoard *)[%c(SpringBoard) sharedApplication] isLocked])
		[[%c(SBBacklightController) sharedInstance] resetLockScreenIdleTimer];

	ESSContainerView *containerView = (ESSContainerView *)(recognizer.view);
	CGPoint location = [recognizer locationInView:self.view];
	CGFloat differenceX = location.x - pressStartLocation.x;

	SXIPreferences *preferenceManager = [SXIPreferences sharedInstance];

	switch (recognizer.state) {
		case UIGestureRecognizerStateBegan:
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoHide:) object:containerView];
			[containerView highlightViewWithCompletion:nil];
			pressStartTime = [NSDate timeIntervalSinceReferenceDate];
			pressStartLocation = location;
			useLongPressAsPan = NO;
			timerDidTrigger = NO;
			[self performSelector:@selector(displayShareSheetTimerTriggered:) withObject:containerView afterDelay:kLongPressEndDuration];
			break;
		case UIGestureRecognizerStateChanged:
			if (timerDidTrigger) {
				break;
			} else if (useLongPressAsPan) {
				if (differenceX > 0 && !preferenceManager.isRightSwipeEnabled)
					differenceX = 0;
				[containerView setTransform:CGAffineTransformMakeTranslation(differenceX, 0)];
			} else if (fabs(differenceX) > kLongPressRange) {
				[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(displayShareSheetTimerTriggered:) object:containerView];
				useLongPressAsPan = YES;
				[containerView unhighlightViewWithCompletion:nil];
			} else if ([NSDate timeIntervalSinceReferenceDate] - pressStartTime >= kLongPressEndDuration) {
				[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(displayShareSheetTimerTriggered:) object:containerView];

				if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
					[self displayShareSheet:containerView];
				else
					[containerView unhighlightViewWithCompletion:^{
						[self displayShareSheet:containerView];
					}];
			}
			break;
		case UIGestureRecognizerStateEnded:
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(displayShareSheetTimerTriggered:) object:containerView];

			if (timerDidTrigger) {
				[containerView unhighlightViewWithCompletion:nil];
			} else if (useLongPressAsPan) {
				if (containerView.frame.origin.x + differenceX < -containerView.frame.size.width) {
					[self forceHide:containerView];

					if (preferenceManager.isSaveOnSwipeDismissEnabled)
						[self saveScreenshot:containerView.image];
				} else if (containerView.frame.origin.x + differenceX > self.view.frame.size.width && preferenceManager.isRightSwipeEnabled) {
					[self forceHideRight:containerView];

					if (preferenceManager.isSaveOnRightSwipeDismissEnabled)
						[self saveScreenshot:containerView.image];
				} else {
					[UIView animateWithDuration:preferenceManager.dismissAnimationSpeed animations:^{
						[containerView setTransform:CGAffineTransformMakeTranslation(0, 0)];
					} completion:^(BOOL finished) {
						if (!preferenceManager.isUnlimitedDismissTimeEnabled)
							[self performSelector:@selector(autoHide:) withObject:containerView afterDelay:preferenceManager.dismissTime];
					}];
				}
			} else {
				[containerView unhighlightViewWithCompletion:^{
					if ([NSDate timeIntervalSinceReferenceDate] - pressStartTime >= kLongPressEndDuration && fabs(differenceX) <= kLongPressRange)
						[self displayShareSheet:containerView];
					else if (!preferenceManager.isUnlimitedDismissTimeEnabled)
						[self performSelector:@selector(autoHide:) withObject:containerView afterDelay:preferenceManager.dismissTime];
				}];
			}
			break;
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateFailed:
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(displayShareSheetTimerTriggered:) object:containerView];

			[containerView unhighlightViewWithCompletion:nil];
			break;
		default:
			break;
	}
}

-(void)imageTapped:(UITapGestureRecognizer *)recognizer {
	if (![recognizer.view isKindOfClass:%c(ESSContainerView)])
		return;

	if ([(SpringBoard *)[%c(SpringBoard) sharedApplication] isLocked])
		[[%c(SBBacklightController) sharedInstance] resetLockScreenIdleTimer];

	ESSContainerView *containerView = (ESSContainerView *)(recognizer.view);
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoHide:) object:containerView];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(displayShareSheetTimerTriggered:) object:containerView];

	[self displayEditor:containerView];
}

-(void)displayShareSheetTimerTriggered:(UIView *)view {
	timerDidTrigger = YES;
	if (!useLongPressAsPan) {
		if (![view isKindOfClass:%c(ESSContainerView)])
			return;
			
		ESSContainerView *containerView = (ESSContainerView *)view;
		if (containerView != nil)
			[self displayShareSheet:containerView];
	}
}
@end