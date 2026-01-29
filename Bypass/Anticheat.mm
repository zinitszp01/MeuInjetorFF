#import <Foundation/Foundation.h>
#import <substrate.h>
#import <mach-o/dyld.h>

// Proteção para ocultar o ambiente do jogo
static BOOL (*old_fileExistsAtPath)(id self, SEL _cmd, NSString *path);
BOOL new_fileExistsAtPath(id self, SEL _cmd, NSString *path) {
    if ([path containsString:@"Cydia"] || [path containsString:@"Sileo"] || [path containsString:@"libsubstitute"]) {
        return NO;
    }
    return old_fileExistsAtPath(self, _cmd, path);
}

extern "C" {
    void ExecutarLimpezaBypass() {
        // 1. LIMPEZA DE LOGS ANTI-BAN
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSArray *blacklistFiles = @[@"Logs", @"GarenaSdk", @"Firebase", @"Pandora", @"client_report_log"];
        
        for (NSString *file in blacklistFiles) {
            NSString *path = [docPath stringByAppendingPathComponent:file];
            if ([fm fileExistsAtPath:path]) {
                [fm removeItemAtPath:path error:nil];
                [@"" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
        }

        // 2. ANTI-BLACKLIST HOOK
        MSHookMessageEx([NSFileManager class], @selector(fileExistsAtPath:), (IMP)new_fileExistsAtPath, (IMP *)&old_fileExistsAtPath);
        
        NSLog(@"[CAU-BYPASS] Proteção Ativada Estilo Frida!");
    }
}
