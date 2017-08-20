#import "headers.h"

@implementation ESSWindow
-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self != nil) {
		self.windowLevel = [SXIPreferences sharedInstance].currentTweakLevel;
		[self _setSecure:YES]; // make it work on lockscreen as well
		self.rootViewController = [[ESSController alloc] init];
		self.rootViewController.view.frame = frame;
		self.opaque = NO;
		self.hidden = NO;
		self.clipsToBounds = YES;
		self.layer.masksToBounds = YES;
	}
	return self;
}

-(void)dealloc {
	[self.rootViewController release];
	[super dealloc];
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event { // to make touches pass through
	ESSController *viewController = (ESSController *)(self.rootViewController);
	UIView *result = [super hitTest:point withEvent:event];
	if ([viewController presentedViewController] == nil) {
		for (ESSContainerView *view in viewController.containerViews)
			if (CGRectContainsPoint(view.frame, point))
				return result;
		return nil;
	} else {
		if ([(SpringBoard *)[%c(SpringBoard) sharedApplication] isLocked])
			[[%c(SBBacklightController) sharedInstance] resetLockScreenIdleTimer];
		return result;
	}
}
@end