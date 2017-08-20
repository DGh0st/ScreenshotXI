#import <Preferences/PSSpecifier.h>
#import <Preferences/PSSliderTableCell.h>

@interface PSRootController
+(void)setPreferenceValue:(id)value specifier:(id)specifier;
@end

@interface SXISliderCell : PSSliderTableCell <UIAlertViewDelegate, UITextFieldDelegate>
-(void)presentAlert;
@end