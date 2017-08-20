#import "SXIRootListController.h"
#import "../headers.h"

@implementation SXIRootListController

- (id)initForContentSize:(CGSize)size {
	self = [super initForContentSize:size];

	if (self != nil) {
		UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon" inBundle:[self bundle] compatibleWithTraitCollection:nil]];
		iconView.contentMode = UIViewContentModeScaleAspectFit;
		iconView.frame = CGRectMake(0, 0, 29, 29);

		[self.navigationItem setTitleView:iconView];
		[iconView release];
	}

	return self;
}

- (NSArray *)specifiers {
	if (_specifiers == nil) {
		PSSpecifier *enableGroup = [PSSpecifier emptyGroupSpecifier];
		PSSpecifier *enableSwitch = [PSSpecifier preferenceSpecifierNamed:@"Enable" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[enableSwitch setProperty:@YES forKey:@"default"];
		[enableSwitch setProperty:kTweakIdentifier forKey:@"defaults"];
		[enableSwitch setProperty:@"isEnabled" forKey:@"key"];
		[enableSwitch setProperty:@"Enable" forKey:@"label"];
		[enableSwitch setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];

		PSSpecifier *optionsGroup = [PSSpecifier emptyGroupSpecifier];
		PSSpecifier *configuration = [PSSpecifier preferenceSpecifierNamed:@"Configuration" target:self set:NULL get:NULL detail:%c(SXIConfigurationListController) cell:PSLinkCell edit:nil];
		[configuration setProperty:@YES forKey:@"isController"];
		[configuration setProperty:@"Configuration" forKey:@"label"];
		PSSpecifier *priority = [PSSpecifier preferenceSpecifierNamed:@"Priority" target:self set:NULL get:NULL detail:%c(SXIPriorityListController) cell:PSLinkCell edit:nil];
		[priority setProperty:@YES forKey:@"isController"];
		[priority setProperty:@"Priority" forKey:@"label"];
		PSSpecifier *appearance = [PSSpecifier preferenceSpecifierNamed:@"Appearance" target:self set:NULL get:NULL detail:%c(SXIAppearanceListController) cell:PSLinkCell edit:nil];
		[appearance setProperty:@YES forKey:@"isController"];
		[appearance setProperty:@"Appearance" forKey:@"label"];

		PSSpecifier *creditGroup = [PSSpecifier emptyGroupSpecifier];
		[creditGroup setProperty:@"Credits" forKey:@"label"];
		[creditGroup setProperty:@"Enjoy the tweak :)" forKey:@"footerText"];
		PSSpecifier *email = [PSSpecifier preferenceSpecifierNamed:@"Email Support" target:self set:NULL get:NULL detail:nil cell:PSButtonCell edit:nil];
		email->action = @selector(emailSupport);
		[email setProperty:@"Email Support" forKey:@"label"];
		[email setProperty:[UIImage _applicationIconImageForBundleIdentifier:@"com.apple.mobilemail" format:0 scale:[UIScreen mainScreen].scale] forKey:@"iconImage"];
		[email setProperty:@YES forKey:@"hasIcon"];
		PSSpecifier *twitter = [PSSpecifier preferenceSpecifierNamed:@"Follow on twitter (@D_Gh0st)" target:self set:NULL get:NULL detail:nil cell:PSButtonCell edit:nil];
		twitter->action = @selector(follow);
		[twitter setProperty:@"Follow on twitter" forKey:@"label"];
		[twitter setProperty:[UIImage _applicationIconImageForBundleIdentifier:@"com.atebits.Tweetie2" format:0 scale:[UIScreen mainScreen].scale] forKey:@"iconImage"];
		[twitter setProperty:@YES forKey:@"hasIcon"];

		PSSpecifier *copyrightGroup = [PSSpecifier emptyGroupSpecifier];
		[copyrightGroup setProperty:@1 forKey:@"footerAlignment"];
		[copyrightGroup setProperty:@"ScreenshotXI © 2017 DGh0st" forKey:@"footerText"];

		_specifiers = [@[enableGroup, enableSwitch, optionsGroup, configuration, priority, appearance, creditGroup, email, twitter, copyrightGroup] retain];
	}

	return _specifiers;
}

- (void)emailSupport {
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
		[emailController setSubject:@"ScreenshotXI Support"];
		[emailController setToRecipients:[NSArray arrayWithObjects:@"deeppwnage@yahoo.com", nil]];
		[emailController addAttachmentData:[NSData dataWithContentsOfFile:kSettingsPath] mimeType:@"application/xml" fileName:@"Prefs.plist"];
		[emailController addAttachmentData:[NSData dataWithContentsOfFile:kColorPath] mimeType:@"application/xml" fileName:@"Color.plist"];
		#pragma GCC diagnostic push
		#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
		system("/usr/bin/dpkg -l > /tmp/dpkgl.log");
		#pragma GCC diagnostic pop
		[emailController addAttachmentData:[NSData dataWithContentsOfFile:@"/tmp/dpkgl.log"] mimeType:@"text/plain" fileName:@"dpkgl.txt"];
		[self.navigationController presentViewController:emailController animated:YES completion:nil];
		[emailController setMailComposeDelegate:self];
		[emailController release];
	}
}

- (void)mailComposeController:(id)controller didFinishWithResult:(MFMailComposeResult)result error:(id)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)follow {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/D_Gh0st"]];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.table.bounds.size.width, 100)];
	[headerView setBackgroundColor:[UIColor clearColor]];
	[headerView setContentMode:UIViewContentModeCenter];
	[headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

	CGRect frame = CGRectMake(0, 16, self.table.bounds.size.width, 32);
	CGRect underFrame = CGRectMake(0, 56, self.table.bounds.size.width, 24);

	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	[label setNumberOfLines:1];
	label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:42];
	[label setText:@"ScreenshotXI"];
	[label setBackgroundColor:[UIColor clearColor]];
	label.textColor = [UIColor blackColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	label.contentMode = UIViewContentModeScaleToFill;

	UILabel *underLabel = [[UILabel alloc] initWithFrame:underFrame];
	[underLabel setNumberOfLines:1];
	underLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
	[underLabel setText:@"Bring iOS 11 screenshotting to iOS 9 and 10"];
	[underLabel setBackgroundColor:[UIColor clearColor]];
	underLabel.textColor = [UIColor blackColor];
	underLabel.textAlignment = NSTextAlignmentCenter;
	underLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	underLabel.contentMode = UIViewContentModeScaleToFill;

	[headerView addSubview:label];
	[headerView addSubview:underLabel];

	self.table.tableHeaderView = headerView;

	[label release];
	[underLabel release];
	[headerView release];
}

@end