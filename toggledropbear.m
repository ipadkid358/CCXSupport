#import <Foundation/Foundation.h>
#import <sys/stat.h>
#import <spawn.h>

#import "SharedStringsSSH.h"

/// load command sent to launchctl, should be one of "load", "unload"
static void toggleDropbear(char *load) {
    pid_t pid;
    char *argv[] = { "launchctl", load, kDropbearPath, NULL };
    
    posix_spawn(&pid, "/bin/launchctl", NULL, NULL, argv, NULL);
    waitpid(pid, NULL, 0);
}

int main(int argc, char *argv[]) {
    uid_t root = 0;
    gid_t wheel = 0;
    
    setuid(root);
    setgid(wheel);
    
    // root required for setting permissions on the plist, and to load and unload the process
    if ((getuid() != root) || (getgid() != wheel)) {
        return 1;
    }
    
    @autoreleasepool {
        NSMutableDictionary *dropbearPrefs = [NSMutableDictionary dictionaryWithContentsOfFile:@kDropbearPath];
        if (!dropbearPrefs) {
            return 1;
        }
        
        NSMutableArray *progArgs = [NSMutableArray arrayWithArray:dropbearPrefs[@kProgramArgumentsKey]];
        if (progArgs.count != 7) {
            progArgs[4] = @"127.0.0.1:51022";
            progArgs[5] = @"-p";
            progArgs[6] = @kSSHPortString;
        }
        
        const char *coreArg = argv[1];
        if (!coreArg) {
            return 1;
        }
        
        // problem with this is if the device is not on the VPN, the server needs to be restarted again, once it is
        progArgs[6] = [[NSString stringWithUTF8String:coreArg] boolValue] ? @kSSHPortString : @ "10.8.0.2:" kSSHPortString;
        
        dropbearPrefs[@kProgramArgumentsKey] = progArgs;
        
        if (![dropbearPrefs writeToFile:@kDropbearPath atomically:YES]) {
            return 1;
        }
        
        chown(kDropbearPath, 0, 0);
        chmod(kDropbearPath, 0644);
        toggleDropbear("unload");
        toggleDropbear("load");
    }
    
    return 0;
}
