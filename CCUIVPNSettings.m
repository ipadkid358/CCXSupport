#import "CCUIVPNSettings.h"
#import <objc/runtime.h>
#import <dlfcn.h>

@interface UIColor (UISystemColors)
+ (instancetype)systemGreenColor;
@end

@interface SBTelephonyManager : NSObject
+ (instancetype)sharedTelephonyManager;
- (BOOL)isUsingVPNConnection;
@end

@interface PSBundleController : NSObject
- (instancetype)initWithParentListController:(id)parentListController;
@end

@interface VPNBundleController : PSBundleController
- (void)setVPNActive:(BOOL)active;
@end

@implementation CCUIVPNSettings {
    VPNBundleController *_vpnController;
}

- (void)activate {
    void *vpnHandle = dlopen("/System/Library/PreferenceBundles/VPNPreferences.bundle/VPNPreferences", RTLD_LAZY);
    _vpnController = [[objc_getClass("VPNBundleController") alloc] initWithParentListController:NULL];
    dlclose(vpnHandle);
    
    SBTelephonyManager *telephoneInfo = [objc_getClass("SBTelephonyManager") sharedTelephonyManager];
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserverForName:@"SBVPNConnectionChangedNotification" object:NULL queue:NULL usingBlock:^(NSNotification *note) {
        self.enabled = telephoneInfo.isUsingVPNConnection;
    }];
}

- (void)deactivate {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)_toggleState {
    [_vpnController setVPNActive:(self.enabled = !self.enabled)];
    // not sure what the point of the return is here, same behavior seems to occur if YES or NO
    return YES;
}

- (UIImage *)glyphImageForState:(UIControlState)state {
    return [UIImage imageWithContentsOfFile:@"/Library/Application Support/CCXSupport/vpn.png"];
}

+ (NSString *)identifier {
    return @"vpn";
}

+ (NSString *)displayName {
    return @"VPN";
}

+ (BOOL)isSupported:(int)arg {
    return YES;
}

+ (BOOL)isInternalButton {
    return NO;
}

- (NSString *)aggdKey {
    return @"vpn";
}

+ (NSString *)statusOnString {
    return @"VPN: Enabled";
}

+ (NSString *)statusOffString {
    return @"VPN: Disabled";
}

- (UIColor *)selectedStateColor {
    return [UIColor systemGreenColor];
}

@end
