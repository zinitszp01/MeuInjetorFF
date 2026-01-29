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
            // Cria um arquivo dummy para impedir a recriação da pasta de log
            [@"" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }
}

// --- ANTI-KICK & ANTI-BLACKLIST (HOOKS DE SISTEMA) ---
// Essas funções tentam enganar o jogo quando ele pede informações do aparelho

// 1. Hook para ocultar arquivos de Jailbreak (Evita detecção de ambiente)
BOOL (*old_fileExistsAtPath)(id self, SEL _cmd, NSString *path);
BOOL new_fileExistsAtPath(id self, SEL _cmd, NSString *path) {
    if ([path containsString:@"bin/bash"] || [path containsString:@"Cydia"] || [path containsString:@"libsubstitute"]) {
        return NO; // Diz ao jogo que esses arquivos não existem
    }
    return old_fileExistsAtPath(self, _cmd, path);
}

// 2. Hook para bloquear envio de Reports (Anti-Ban/Anti-Blacklist)
// Bloqueia a URL de reporte da Garena no nível de sistema
void (*old_dataWithContentsOfURL)(id self, SEL _cmd, NSURL *url);
void new_dataWithContentsOfURL(id self, SEL _cmd, NSURL *url) {
    if ([url.absoluteString containsString:@"report"] || [url.absoluteString containsString:@"log-upload"]) {
        return; // Bloqueia o upload do log de denúncia
    }
    old_dataWithContentsOfURL(self, _cmd, url);
}

// --- FUNÇÃO PRINCIPAL CHAMADA PELO TWEAK ---
void ExecutarLimpezaBypass() {
    // Limpa logs imediatamente
    LimparRastros();
    
    // Inicia hooks de proteção de sistema
    MSHookMessageEx([NSFileManager class], @selector(fileExistsAtPath:), (IMP)new_fileExistsAtPath, (IMP *)&old_fileExistsAtPath);
    
    NSLog(@"[CAU BYPASS] Anti-Blacklist e Clean Logs Ativados!");
}
