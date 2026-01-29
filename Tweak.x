#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
// Se precisar de hooks de função manual:
#include <substrate.h>

// Importamos a função do arquivo externo de Bypass
extern void ExecutarLimpezaBypass();

// Variáveis de ativação
static bool recoil_on = false;
static bool hs_on = false;

// Função corrigida para calcular endereços de memória (Offsets)
uintptr_t get_real_offset(long offset) {
    return (uintptr_t)_dyld_get_image_header(0) + offset;
}

// --- INTERFACE DO PAINEL ---
@interface VIPPanel : UIView
@end

@implementation VIPPanel
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        self.layer.cornerRadius = 20;
        self.layer.borderColor = [UIColor cyanColor].CGColor;
        self.layer.borderWidth = 2.0;

        UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 200, 30)];
        t.text = @"CAU VIP v3.0"; t.textColor = [UIColor cyanColor];
        t.textAlignment = NSTextAlignmentCenter; [self addSubview:t];

        [self addSw:@"SEM RECUO" y:60 act:@selector(swR:)];
        [self addSw:@"HS PESCOÇO" y:110 act:@selector(swH:)];
    }
    return self;
}
- (void)addSw:(NSString *)name y:(int)y act:(SEL)act {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 100, 30)];
    l.text = name; l.textColor = [UIColor whiteColor]; [self addSubview:l];
    UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectMake(130, y, 0, 0)];
    [s addTarget:self action:act forControlEvents:UIControlEventValueChanged];
    [self addSubview:s];
}
- (void)swR:(UISwitch *)s { recoil_on = s.isOn; }
- (void)swH:(UISwitch *)s { hs_on = s.isOn; }
@end

// --- GERENCIADOR DO MENU ---
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
    menuBtn.frame = CGRectMake(40, 140, 50, 50);
    menuBtn.backgroundColor = [UIColor cyanColor];
    menuBtn.layer.cornerRadius = 25;
    [menuBtn setTitle:@"VIP" forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
    [mainWin addSubview:menuBtn];

    menuPnl = [[VIPPanel alloc] initWithFrame:CGRectMake(0,0,200,180)];
    menuPnl.center = mainWin.center;
    menuPnl.hidden = YES;
    [mainWin addSubview:menuPnl];
}
+ (void)toggle { menuPnl.hidden = !menuPnl.hidden; }
@end

// --- BYPASS DE IDENTIDADE ---
%hook NSBundle
- (NSString *)bundleIdentifier {
    return @"com.dts.freefiremax";
}
%end

// --- CONSTRUTOR ---
%ctor {
    %init;
    // Executa a limpeza da pasta Bypass
    ExecutarLimpezaBypass();

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MenuManager iniciar];
    });
}
