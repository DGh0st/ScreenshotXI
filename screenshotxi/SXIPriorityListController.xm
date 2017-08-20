#import "SXIPriorityListController.h"
#import "../headers.h"

@implementation SXIPriorityListController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Window Priority";
		default:
			return @"";
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return [self.currentPriority count];
		default:
			return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScreenshotXICell" forIndexPath:indexPath];
	
	if (self.currentPriority == nil || [self.currentPriority count] <= indexPath.row)
		return nil;

	if (cell == nil)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ScreenshotXICell"];

	cell.textLabel.text = [self.currentPriority objectAtIndex:indexPath.row];

	return cell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	if (self.tableView == nil)
		return;

	if (self.currentPriority == nil)
		[self updatePriority];

	if (sourceIndexPath == nil || destinationIndexPath == nil || sourceIndexPath.row >= [self.currentPriority count] || destinationIndexPath.row <= 0) {
		[self.tableView reloadData];
		return;
	}

	NSString *objectToMove = [self.currentPriority objectAtIndex:sourceIndexPath.row];
	[self.currentPriority removeObjectAtIndex:sourceIndexPath.row];
	[self.currentPriority insertObject:objectToMove atIndex:destinationIndexPath.row];

	[self writeToFile];
	[self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[self.currentPriority objectAtIndex:indexPath.row] isEqualToString:@"ScreenshotXI"];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (void)writeToFile {
	DisplayWindowLevel currentTweakLevel = kAboveHomeAppsLockScreens;

	for (NSInteger i = 1; i < [self.currentPriority count]; i++) { // can never be 0 (below lockscreen/homescreen/application)
		if ([[self.currentPriority objectAtIndex:i] isEqualToString:@"ScreenshotXI"]) {
			currentTweakLevel = (DisplayWindowLevel)i;
			break;
		}
	}

	PSSpecifier *screenshotxiWindowLevel = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSLinkListCell edit:nil];
	[screenshotxiWindowLevel setProperty:[NSNumber numberWithInt:kAboveHomeAppsLockScreens] forKey:@"default"];
	[screenshotxiWindowLevel setProperty:kTweakIdentifier forKey:@"defaults"];
	[screenshotxiWindowLevel setProperty:@"windowPriority" forKey:@"key"];
	[screenshotxiWindowLevel setProperty:@"" forKey:@"label"];
	[screenshotxiWindowLevel setProperty:kSettingsChangedIdentifier forKey:@"PostNotification"];
	[self setPreferenceValue:[NSNumber numberWithInt:currentTweakLevel] specifier:screenshotxiWindowLevel];
}

- (void)updatePriority {
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kSettingsPath] ?: [NSMutableDictionary dictionary];
	DisplayWindowLevel currentTweakLevel = [prefs objectForKey:@"windowPriority"] ? (DisplayWindowLevel)[[prefs objectForKey:@"windowPriority"] intValue] : kAboveHomeAppsLockScreens;
	NSArray *defaultWindowLevels = @[@"Lockscreen, HomeScreen and Applications", @"Control Center", @"Notification Center", @"Notification Banners", @"SpringBoard Alerts", @"Screenshot Flash"];

	self.currentPriority = [NSMutableArray array];
	
	for (NSInteger i = 0; i < currentTweakLevel; i++)
		[self.currentPriority addObject:[defaultWindowLevels objectAtIndex:i]];

	[self.currentPriority addObject:@"ScreenshotXI"];

	for (NSInteger i = currentTweakLevel; i < [defaultWindowLevels count]; i++)
		[self.currentPriority addObject:[defaultWindowLevels objectAtIndex:i]];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self writeToFile];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self updatePriority];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ScreenshotXICell"];
	[self.tableView setEditing:YES];
	[self.tableView setAllowsSelection:NO];

	((UIViewController *)self).title = @"Priority";
	self.view = self.tableView;
}

- (void)dealloc {
	[self.tableView release];
	[super dealloc];
}

@end