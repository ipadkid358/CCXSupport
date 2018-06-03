#import <objc/runtime.h>
#import "CCUIFSCompatibilityLayer.h"

static FSSwitchPanel *flipswitch = NULL;
static __attribute__((constructor)) void setFlipswitchReference() {
    void *flipswitchHandle = dlopen("/Library/MobileSubstrate/DynamicLibraries/Flipswitch.dylib", RTLD_NOW);
    if (flipswitchHandle) {
        flipswitch = [objc_getClass("FSSwitchPanel") sharedPanel];
        dlclose(flipswitchHandle);
    }
}

@implementation CCUIFSCompatibilityLayer {
    id<NSObject> _flipswitchNotifToken;
}

- (void)activate {
    [NSNotificationCenter.defaultCenter addObserverForName:@"FSSwitchPanelSwitchStateChangedNotification" object:NULL queue:NULL usingBlock:^(NSNotification *note) {
        NSString *switchIdentifier = self.aggdKey;
        if ([note.userInfo[@"switchIdentifier"] isEqualToString:switchIdentifier]) {
            self.enabled = ([flipswitch stateForSwitchIdentifier:switchIdentifier] == FSSwitchStateOn);
        }
    }];
    
    [self _updateState];
}

- (void)deactivate {
    [NSNotificationCenter.defaultCenter removeObserver:_flipswitchNotifToken];
}

- (void)_updateState {
    self.enabled = ([flipswitch stateForSwitchIdentifier:self.aggdKey] == FSSwitchStateOn);
}

- (BOOL)_toggleState {
    [flipswitch setState:(self.enabled = !self.enabled) forSwitchIdentifier:self.aggdKey];
    return YES;
}

+ (NSString *)displayName {
    return [flipswitch titleForSwitchIdentifier:self.identifier];
}

+ (BOOL)isSupported:(int)arg {
    return YES;
}

+ (BOOL)isInternalButton {
    return NO;
}

+ (NSString *)statusOnString {
    return [self.displayName stringByAppendingString:@": Enabled"];
}

+ (NSString *)statusOffString {
    return [self.displayName stringByAppendingString:@": Disabled"];
}

- (NSString *)aggdKey {
    return self.class.identifier;
}

- (UIImage *)glyphImageForState:(UIControlState)state {
    NSBundle *template = [NSBundle bundleWithPath:@"/Library/Application Support/CCXSupport/FlipSwitchTemplate.bundle"];
    return [flipswitch imageOfSwitchState:state controlState:state forSwitchIdentifier:self.aggdKey usingTemplate:template];
}

- (UIColor *)selectedStateColor {
    // TODO: Set color based on Preferences
    return [UIColor orangeColor];
}

@end
