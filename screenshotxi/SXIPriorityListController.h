#import <Preferences/PSViewController.h>
#import <Preferences/PSSpecifier.h>

@interface SXIPriorityListController : PSViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *currentPriority;
@end