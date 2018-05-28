#import <UIKit/UIKit.h>
#import "CCUIVPNSettings.h"
#import "CCUISSHSettings.h"

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
    NSArray<Class> *originalButtons = %orig;
    /* original array
     AirplaneMode
     WiFi
     Bluetooth
     DoNotDisturb
     Mute
     OrientationLock
     LowPowerMode
     CellularData
     PersonalHotspot
     */
    
    Class WifiToggle            = originalButtons[1];
    Class BluetoothToggle       = originalButtons[2];
    Class OrientationLockToggle = originalButtons[5];
    
    return @[WifiToggle, BluetoothToggle, [CCUISSHSettings class], [CCUIVPNSettings class], OrientationLockToggle];
}

%end
