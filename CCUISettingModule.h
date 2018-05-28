#import <UIKit/UIKit.h>

@interface CCUIButtonModule : NSObject

// sets the toggle as highlighted or not
@property (assign, getter=isEnabled, nonatomic) BOOL enabled;

// unique name
+ (NSString *)identifier;
// User friendly name
+ (NSString *)displayName;
// return YES to this
+ (BOOL)isSupported:(int)arg;
// return NO to this
+ (BOOL)isInternalButton;

// use as init
- (void)activate;
// use as dealloc
- (void)deactivate;

// same as the class method
- (NSString *)identifier;
// lowercase only version of the identifier
- (NSString *)aggdKey;

// called when the contol center is about to be presented
// set `self.enabled` if needed
- (void)_updateState;

// called when the user clicks on the toggle
// `self.enabled` should be read and set here
- (BOOL)_toggleState;

// image for selected and normal states
- (UIImage *)glyphImageForState:(UIControlState)state;

@end

@interface CCUISettingModule : CCUIButtonModule

// string presented at the top of control center when the switch is disabled
+ (NSString *)statusOnString;
// string presented at the top of control center when the switch is enabled
+ (NSString *)statusOffString;

// the highlight color of the toggle in control center
- (UIColor *)selectedStateColor;

@end
