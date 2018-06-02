#import <UIKit/UIKit.h>
#import "CCUIFSCompatibilityLayer.h"

static void setupFlipswitchHack();

%hook CCUIRecordScreenShortcut

+ (BOOL)isInternalButton {
    return NO;
}

- (UIImage *)glyphImageForState:(UIControlState)state {
    return [UIImage imageWithContentsOfFile:@"/Applications/Camera.app/RecordVideo-OrbHW"];
}

%end

%hook CCUIControlCenterSettingsSectionSettings

+ (NSArray<Class> *)buttonModuleClasses {
    setupFlipswitchHack();
    
    NSArray<NSString *> *disk = [NSArray arrayWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ipadkid.ccxsupport.plist"];
    NSInteger diskCount = disk.count;
    NSMutableArray<Class> *classes = [NSMutableArray arrayWithCapacity:diskCount];
    for (int i = 0; i < diskCount; i++) {
        Class adding = NSClassFromString(disk[i]);
        if (adding) {
            classes[i] = adding;
        }
    }
    
    return [NSArray arrayWithArray:classes];
}

%end

static void setupFlipswitchHack() {
    void *flipswitchHandle = dlopen("/Library/MobileSubstrate/DynamicLibraries/Flipswitch.dylib", RTLD_NOW);
    if (flipswitchHandle) {
        FSSwitchPanel *flipswitch = [objc_getClass("FSSwitchPanel") sharedPanel];
        for (NSString *switchIdentifier in flipswitch.switchIdentifiers) {
            NSString *patchClassName = [switchIdentifier stringByReplacingOccurrencesOfString:@"." withString:@"_"];
            patchClassName = [NSString stringWithFormat:@"CCUI_FS_%@_Setting", patchClassName];
            
            Class flipswitchHackedClass = objc_allocateClassPair(CCUIFSCompatibilityLayer.class, patchClassName.UTF8String, 0);
            if (flipswitchHackedClass) {
                objc_registerClassPair(flipswitchHackedClass);
                
                Class flipswitchHackedMetaClass = object_getClass(flipswitchHackedClass);
                
                MSHookMessageEx(flipswitchHackedMetaClass, @selector(identifier), imp_implementationWithBlock((NSString *) ^(id self) {
                    return switchIdentifier;
                }), NULL);
            }
        }
        
        dlclose(flipswitchHandle);
    }
}
