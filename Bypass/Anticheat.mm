#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import <substrate.h>

// --- FUNÇÃO PARA LIMPEZA DE LOGS (ANTI-BAN) ---
void LimparRastros() {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Lista de pastas de telemetria e logs de detecção
    NSArray *blacklistFiles = @[
        @"Logs", @"GarenaSdk", @"Firebase", @"crash_log.txt", 
        @"client_report_log", @"Pandora", @"il2cpp", @"backtrace"
    ];
    
    for (NSString *file in blacklistFiles) {
        NSString *path = [docPath stringByAppendingPathComponent:file];
        if ([fm fileExistsAtPath:path]) {
            [fm removeItemAtPath:path error:nil];
            // Bloqueia a recriação criando um arquivo vazio no lugar
            [@"" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }
}

// --- ANTI-KICK & ANTI-BLACKLIST (HOOKS DE SISTEMA) ---
// Hook para esconder arquivos que o anti-cheat usa para marcar o aparelho
static BOOL (*old_fileExistsAtPath)(id self, SEL _cmd, NSString *path);
static BOOL new_fileExistsAtPath(id self, SEL _cmd, NSString *path) {
    if ([path containsString:@"Cydia"] || [path containsString:@"Sileo"] || [path containsString:@"libsubstitute"]) {
        return NO;
    }
    return old_fileExistsAtPath(self, _cmd, path);
}

// --- FUNÇÃO PRINCIPAL CHAMADA PELO TWEAK.X ---
void ExecutarLimpezaBypass() {
    // 1. Executa a limpeza de logs imediatamente
    LimparRastros();
    
    // 2. Aplica os Hooks de proteção (Anti-Blacklist)
    MSHookMessageEx([NSFileManager class], @selector(fileExistsAtPath:), (IMP)new_fileExistsAtPath, (IMP *)&old_fileExistsAtPath);
    
    NSLog(@"[CAU-BYPASS] Sistema de Proteção Ativado com Sucesso!");
}
