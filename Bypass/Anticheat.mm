#import <Foundation/Foundation.h>
#import <substrate.h>
#import <mach-o/dyld.h>

// Hooks para Anti-Blacklist
static BOOL (*old_fileExistsAtPath)(id self, SEL _cmd, NSString *path);
BOOL new_fileExistsAtPath(id self, SEL _cmd, NSString *path) {
    if ([path containsString:@"Cydia"] || [path containsString:@"Sileo"] || [path containsString:@"libsubstitute"]) {
        return NO;
    }
    return old_fileExistsAtPath(self, _cmd, path);
}

// O extern "C" garante que o Tweak.x consiga encontrar esta função
extern "C" void ExecutarLimpezaBypass() {
    // 1. LIMPEZA DE LOGS (ANTI-BAN)
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSArray *blacklistFiles = @[
        @"Logs", @"GarenaSdk", @"Firebase", @"crash_log.txt", 
        @"client_report_log", @"Pandora", @"il2cpp", @"backtrace"
    ];
    
    for (NSString *file in blacklistFiles) {
        NSString *path = [docPath stringByAppendingPathComponent:file];
        if ([fm fileExistsAtPath:path]) {
            [fm removeItemAtPath:path error:nil];
            [@"" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }

    // 2. APLICAÇÃO DE HOOKS (ANTI-BLACKLIST / ANTI-KICK)
    MSHookMessageEx([NSFileManager class], @selector(fileExistsAtPath:), (IMP)new_fileExistsAtPath, (IMP *)&old_fileExistsAtPath);
    
    NSLog(@"[CAU-BYPASS] Proteção Completa Ativada!");
}
