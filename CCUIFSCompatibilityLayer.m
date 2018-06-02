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

@implementation CCUIFSCompatibilityLayer

- (void)activate {
    [self _updateState];
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
    return [flipswitch imageOfSwitchState:state controlState:state forSwitchIdentifier:self.aggdKey usingTemplate:[NSBundle bundleWithPath:@"/var/mobile/com.rpetrich.flipcontrolcenter.topshelf"]];
}

- (UIColor *)selectedStateColor {
    return [UIColor orangeColor];
}

@end
