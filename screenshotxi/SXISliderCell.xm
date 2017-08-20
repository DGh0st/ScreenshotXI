#import "SXISliderCell.h"

@implementation SXISliderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
	if (self != nil) {
		CGRect frame = [self frame];
		UIButton *alertButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		alertButton.frame = CGRectMake(frame.size.width - 50, 0, 50, frame.size.height);
		alertButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[alertButton setTitle:@"" forState:UIControlStateNormal];
		[alertButton addTarget:self action:@selector(presentAlert) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:alertButton];
	}
	return self;
}

- (void)presentAlert {
	NSString *rangeString = [NSString stringWithFormat:@"Please enter a value between %.2f and %.2f", [[self.specifier propertyForKey:@"min"] floatValue], [[self.specifier propertyForKey:@"max"] floatValue]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.specifier.name message:rangeString delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter", nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	alert.tag = 342879;
	[alert show];

	[[alert textFieldAtIndex:0] setDelegate:self];
	[[alert textFieldAtIndex:0] resignFirstResponder];
	[[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDecimalPad];
	[[alert textFieldAtIndex:0] becomeFirstResponder];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 342879 && buttonIndex == 1) {
		CGFloat value = [[alertView textFieldAtIndex:0].text floatValue];
		[[alertView textFieldAtIndex:0] resignFirstResponder];

		if (value <= [[self.specifier propertyForKey:@"max"] floatValue] && value >= [[self.specifier propertyForKey:@"min"] floatValue]) {
			[self setValue:[NSNumber numberWithFloat:value]];
			[PSRootController setPreferenceValue:[NSNumber numberWithFloat:value] specifier:self.specifier];
		} else {
			UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The value entered is not valid. Try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			errorAlert.tag = 85230234;
			[errorAlert show];
			[errorAlert release];
		}
	} else if (alertView.tag == 85230234) {
		[self presentAlert];
	}
}

@end