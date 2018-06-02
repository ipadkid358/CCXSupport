#import "CCUISSHSetting.h"
#import "SharedStringsSSH.h"

#import <spawn.h>

@interface UIColor (UISystemColors)
+ (instancetype)systemGreenColor;
@end

@implementation CCUISSHSetting

- (void)_updateState {
    NSDictionary *prefsCheck = [NSDictionary dictionaryWithContentsOfFile:@kDropbearPath];
    if (!prefsCheck) {
        self.enabled = NO;
        return;
    }
    
    NSArray *progArgs = prefsCheck[@kProgramArgumentsKey];
    self.enabled = (progArgs && [progArgs.lastObject isEqualToString:@kSSHPortString]);
}

- (BOOL)_toggleState {
    pid_t pid;
    char *argv[] = { "toggledropbear", ((self.enabled = !self.enabled) ? "1" : "0"), NULL };
    posix_spawn(&pid, "/usr/bin/toggledropbear", NULL, NULL, argv, NULL);
    // don't really need to wait, but we don't want the switch to be spammed or anything
    waitpid(pid, NULL, 0);
    
    return YES;
}

- (UIImage *)glyphImageForState:(UIControlState)state {
    return [UIImage imageWithContentsOfFile:@"/Library/Application Support/CCXSupport/ssh.png"];
}

+ (NSString *)identifier {
    return @"ssh";
}

+ (NSString *)displayName {
    return @"SSH";
}

+ (BOOL)isSupported:(int)arg {
    return YES;
}

+ (BOOL)isInternalButton {
    return NO;
}

- (NSString *)aggdKey {
    return @"ssh";
}

+ (NSString *)statusOnString {
    return @"SSH: Enabled on all addresses";
}

+ (NSString *)statusOffString {
    return @"SSH: Restricted to VPN and localhost";
}

- (UIColor *)selectedStateColor {
    return [UIColor systemGreenColor];
}

@end
