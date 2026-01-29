#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>
#include <vector> // Agora o compilador vai aceitar!

// Declaração do Bypass Externo
#ifdef __cplusplus
extern "C" {
#endif
    void ExecutarLimpezaBypass();
#ifdef __cplusplus
}
#endif

// Variáveis de controle
static bool recoil_on = false;
static bool precision_on = false;

// BUSCA DE ENDEREÇO DINÂMICA
uintptr_t get_real_offset(long offset) {
    uintptr_t addr = 0;
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, "UnityFramework")) {
            addr = (uintptr_t)_dyld_get_image_header(i);
            break;
        }
    }
    if (addr == 0) addr = (uintptr_t)_dyld_get_image_header(0);
    return addr + offset;
}

// Função de Patch (Objective-C++)
void patch_memory(uintptr_t address, std::vector<uint8_t> data) {
    if (address < 0x1000000) return; 
    mprotect((void *)(address & ~0xFFF), 0x1000, PROT_READ | PROT_WRITE | PROT_EXEC);
    memcpy((void *)address, data.data(), data.size());
    mprotect((void *)(address & ~0xFFF), 0x1000, PROT_READ | PROT_EXEC);
}

// --- INTERFACE ---
@interface VIPPanel : UIView
@end
@implementation VIPPanel
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
        self.layer.cornerRadius = 20;
        self.layer.borderColor = [UIColor cyanColor].CGColor;
        self.layer.borderWidth = 2.0;

        UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 200, 30)];
        t.text = @"CAU VIP v6.0"; t.textColor = [UIColor cyanColor];
        t.textAlignment = NSTextAlignmentCenter; [self addSubview:t];

        [self addSw:@"SEM RECUO" y:60 act:@selector(swR:)];
        [self addSw:@"PRECISÃO" y:110 act:@selector(swP:)];
    }
    return self;
}
- (void)addSw:(NSString *)name y:(int)y act:(SEL)act {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 120, 30)];
    l.text = name; l.textColor = [UIColor whiteColor]; [self addSubview:l];
    UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectMake(140, y, 0, 0)];
    [s addTarget:self action:act forControlEvents:UIControlEventValueChanged];
    [self addSubview:s];
}
- (void)swR:(UISwitch *)s { recoil_on = s.isOn; }
- (void)swP:(UISwitch *)s { precision_on = s.isOn; }
@end

UIWindow *mainWin;
VIPPanel *menuPnl;
UIButton *menuBtn;

@interface MenuManager : NSObject
@end
@implementation MenuManager
+ (void)iniciar {
    mainWin = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    mainWin.windowLevel = UIWindowLevelStatusBar + 100;
    mainWin.backgroundColor = [UIColor clearColor];
    [mainWin makeKeyAndVisible];

    menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(30, 150, 55, 55);
    menuBtn.backgroundColor = [UIColor blackColor];
    menuBtn.layer.cornerRadius = 27.5;
    menuBtn.layer.borderColor = [UIColor cyanColor].CGColor;
    menuBtn.layer.borderWidth = 2;
    [menuBtn setTitle:@"CAU" forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
    [mainWin addSubview:menuBtn];

    menuPnl = [[VIPPanel alloc] initWithFrame:CGRectMake(0,0,220,180)];
    menuPnl.center = mainWin.center;
    menuPnl.hidden = YES;
    [mainWin addSubview:menuPnl];
}
+ (void)toggle { menuPnl.hidden = !menuPnl.hidden; }
@end

// --- LOOP ATUALIZADO ---
void cheat_loop() {
    std::vector<uint8_t> patchBytes = {0x00, 0x00, 0x80, 0xD2, 0xC0, 0x03, 0x5F, 0xD6};
    while(true) {
        if (recoil_on) {
            patch_memory(get_real_offset(0x19B3E4C), patchBytes);
        }
        if (precision_on) {
            patch_memory(get_real_offset(0x19B42A8), patchBytes);
        }
        [NSThread sleepForTimeInterval:2.0];
    }
}

%ctor {
    %init;
    ExecutarLimpezaBypass();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MenuManager iniciar];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            cheat_loop();
        });
    });
}
