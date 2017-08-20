#import "headers.h"

extern ESSWindow *window;

@implementation ESSContainerView
-(id)initWithFrame:(CGRect)frame withColor:(UIColor *)color {
	self = [super initWithFrame:frame];
	if (self != nil) {
		SXIPreferences *preferenceManager = [SXIPreferences sharedInstance];

		self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
		self.layer.cornerRadius = 0.0;
		self.layer.borderColor = color.CGColor;
		self.layer.borderWidth = preferenceManager.miniImageWhitePadding;
		self.layer.masksToBounds = YES;
		self.backgroundColor = color;
		self.clipsToBounds = YES;
		self.center = CGPointMake(window.frame.size.width / 2, window.frame.size.height / 2);
		[self setTransform:CGAffineTransformMakeScale(1 / preferenceManager.miniImageScale, 1 / preferenceManager.miniImageScale)];

		// corner radius animation
		CABasicAnimation *cornerRadiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
		cornerRadiusAnimation.duration = preferenceManager.animationSpeed;
		cornerRadiusAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		cornerRadiusAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
		cornerRadiusAnimation.toValue = [NSNumber numberWithFloat:preferenceManager.miniImageRoundness];
		cornerRadiusAnimation.fillMode = kCAFillModeForwards;
		cornerRadiusAnimation.removedOnCompletion = NO;
		[self.layer addAnimation:cornerRadiusAnimation forKey:@"setCornerRadius"];

		self.image = nil;
		_color = color;
	}
	return self;
}

-(void)dealloc {
	[self.layer removeAnimationForKey:@"setCornerRadius"];
	[self.layer	removeAnimationForKey:@"setBorderColor"];
	self.image = nil;
	if (_color != nil)
		[_color release];
	_color = nil;
	[super dealloc];
}

-(void)highlightViewWithCompletion:(id)completion {
	SXIPreferences *preferenceManager = [SXIPreferences sharedInstance];

	[self.layer	removeAnimationForKey:@"setBorderColor"];

	// border color animation
	CABasicAnimation *borderColorAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
	borderColorAnimation.duration = preferenceManager.previewAnimationSpeed;
	borderColorAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	borderColorAnimation.fromValue = (id)_color.CGColor;
	borderColorAnimation.toValue = (id)[_color colorWithAlphaComponent:preferenceManager.previewAlpha].CGColor;
	borderColorAnimation.fillMode = kCAFillModeForwards;
	borderColorAnimation.removedOnCompletion = YES;
	[self.layer addAnimation:borderColorAnimation forKey:@"setBorderColor"];

	[UIView animateWithDuration:preferenceManager.previewAnimationSpeed animations:^{
		self.layer.borderColor = [_color colorWithAlphaComponent:preferenceManager.previewAlpha].CGColor; // I don't think this value matters because CABasicAnimation takes care of it
		self.backgroundColor = [_color colorWithAlphaComponent:preferenceManager.previewAlpha];
		[self setTransform:CGAffineTransformMakeScale(preferenceManager.previewScale, preferenceManager.previewScale)];
	} completion:completion];
}

-(void)unhighlightViewWithCompletion:(id)completion {
	SXIPreferences *preferenceManager = [SXIPreferences sharedInstance];

	[self.layer	removeAnimationForKey:@"setBorderColor"];

	// border color animation
	CABasicAnimation *borderColorAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
	borderColorAnimation.duration = preferenceManager.previewAnimationSpeed;
	borderColorAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	borderColorAnimation.fromValue = (id)[_color colorWithAlphaComponent:preferenceManager.previewAlpha].CGColor;
	borderColorAnimation.toValue = (id)_color.CGColor;
	borderColorAnimation.fillMode = kCAFillModeForwards;
	borderColorAnimation.removedOnCompletion = YES;
	[self.layer addAnimation:borderColorAnimation forKey:@"setBorderColor"];

	[UIView animateWithDuration:preferenceManager.previewAnimationSpeed animations:^{
		self.layer.borderColor = _color.CGColor; // I don't think this value matters because CABasicAnimation takes care of it
		self.backgroundColor = _color;
		[self setTransform:CGAffineTransformMakeScale(1, 1)];
	} completion:completion];
}

// Code stolen from one of the answers to https://stackoverflow.com/questions/3844557/uiview-shake-animation
-(void)shake {
	SXIPreferences *preferenceManager = [SXIPreferences sharedInstance];

	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	animation.duration = preferenceManager.previewAnimationSpeed;
	animation.values = @[ @(-15), @(15), @(-15), @(15), @(-7.5), @(7.5), @(-3), @(3), @(0) ];
	[self.layer addAnimation:animation forKey:@"shake"];
}
@end