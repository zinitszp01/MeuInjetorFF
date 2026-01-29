#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>
#include <vector>

// --- VARIÁVEIS ---
static bool aimbot_full = false, aimbot_legit = false, norecoil = false, precision = false, esp_on = false;
static UIView *menuContainer;
static UIButton *floatingButton;

// --- BYPASS DE ARQUIVOS (ANTIBAN) ---
// Esconde arquivos do tweak para o jogo não detectar o Jailbreak/Mod
%hook NSFileManager
- (BOOL)fileExistsAtPath:(NSString *)path {
    if ([path containsString:@"SensiInjetor"] || [path containsString:@"Cydia"] || [path containsString:@"libsubstrate"]) {
        return NO;
    }
    return %orig;
}
%end

// --- ESP OVERLAY ---
@interface ESPCanvas : UIView
@end
@implementation ESPCanvas
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) { self.backgroundColor = [UIColor clearColor]; self.userInteractionEnabled = NO; }
    return self;
}
- (void)drawRect:(CGRect)rect {
    if (!esp_on) return;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor redColor] setStroke];
    CGContextSetLineWidth(ctx, 1.5);
    CGContextMoveToPoint(ctx, rect.size.width / 2, 0);
    CGContextAddLineToPoint(ctx, rect.size.width / 2, 100);
    CGContextStrokePath(ctx);
}
@end
static ESPCanvas *espView;

// --- MOTOR DE MEMÓRIA ---
uintptr_t get_unity_addr(long offset) {
    uintptr_t addr = 0;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        if (strstr(_dyld_get_image_name(i), "UnityFramework")) {
            addr = (uintptr_t)_dyld_get_image_header(i); break;
        }
    }
    return (addr ?: (uintptr_t)_dyld_get_image_header(0)) + offset;
}

void patch_mem(uintptr_t addr, std::vector<uint8_t> data) {
    if (addr < 0x1000000) return;
    mprotect((void *)(addr & ~0xFFF), 0x1000, PROT_READ | PROT_WRITE | PROT_EXEC);
    memcpy((void *)addr, data.data(), data.size());
    mprotect((void *)(addr & ~0xFFF), 0x1000, PROT_READ | PROT_EXEC);
}

// --- INTERFACE VIP COM MINIMIZAR ---
@interface VIPMenu : UIView
@end
@implementation VIPMenu
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.95];
        self.layer.cornerRadius = 15; self.layer.borderWidth = 2; self.layer.borderColor = [UIColor redColor].CGColor;

        UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 200, 25)];
        t.text = @"CAU VIP V7"; t.textColor = [UIColor redColor]; t.textAlignment = NSTextAlignmentCenter;
        [self addSubview:t];

        // Botão para Minimizar
        UIButton *miniBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        miniBtn.frame = CGRectMake(170, 5, 25, 25);
        [miniBtn setTitle:@"X" forState:UIControlStateNormal];
        [miniBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [miniBtn addTarget:self action:@selector(minimizeMenu) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:miniBtn];

        [self addOpt:@"AIM FULL" y:50 s:@selector(sw1:)];
        [self addOpt:@"NO RECOIL" y:95 s:@selector(sw3:)];
        [self addOpt:@"PRECISAO" y:140 s:@selector(sw4:)];
        [self addOpt:@"ESP WALL" y:185 s:@selector(sw5:)];

        UIPanGestureRecognizer *p = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
        [self addGestureRecognizer:p];
    }
    return self;
}

- (void)addOpt:(NSString *)n y:(int)y s:(SEL)s {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 100, 30)];
    l.text = n; l.textColor = [UIColor whiteColor]; l.font = [UIFont systemFontOfSize:12];
    [self addSubview:l];
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(130, y, 0, 0)];
    sw.transform = CGAffineTransformMakeScale(0.7, 0.7);
    [sw addTarget:self action:s forControlEvents:UIControlEventValueChanged]; [self addSubview:sw];
}

- (void)minimizeMenu {
    menuContainer.hidden = YES;
    floatingButton.hidden = NO;
}

- (void)drag:(UIPanGestureRecognizer *)p {
    CGPoint t = [p translationInView:self]; self.center = CGPointMake(self.center.x + t.x, self.center.y + t.y);
    [p setTranslation:CGPointZero inView:self];
}

- (void)sw1:(UISwitch *)s { aimbot_full = s.isOn; }
- (void)sw3:(UISwitch *)s { norecoil = s.isOn; }
- (void)sw4:(UISwitch *)s { precision = s.isOn; }
- (void)sw5:(UISwitch *)s { esp_on = s.isOn; }
@end

// --- LOOP DE CHEATS ---
void cheat_loop() {
    while(true) {
        if (aimbot_full) patch_mem(get_unity_addr(0x2C4A110), {0x20, 0x00, 0x80, 0xD2, 0xC0, 0x03, 0x5F, 0xD6});
        if (norecoil)    patch_mem(get_unity_addr(0x19B3E4C), {0x00, 0x00, 0x80, 0xD2, 0xC0, 0x03, 0x5F, 0xD6});
        if (precision)   patch_mem(get_unity_addr(0x19B42A8), {0x00, 0x00, 0x80, 0xD2, 0xC0, 0x03, 0x5F, 0xD6});
        
        if (esp_on) dispatch_async(dispatch_get_main_queue(), ^{ [espView setNeedsDisplay]; });
        [NSThread sleepForTimeInterval:1.5];
    }
}

// --- INICIALIZAÇÃO ---
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* s in [UIApplication sharedApplication].connectedScenes) {
                if (s.activationState == UISceneActivationStateForegroundActive) { win = s.windows.firstObject; break; }
            }
        }
        if (!win) win = [UIApplication sharedApplication].keyWindow;

        // Ícone Flutuante
        floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        floatingButton.frame = CGRectMake(20, 150, 45, 45);
        floatingButton.backgroundColor = [UIColor redColor];
        floatingButton.layer.cornerRadius = 22.5;
        floatingButton.layer.borderWidth = 1.5;
        floatingButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [floatingButton setTitle:@"VIP" forState:UIControlStateNormal];
        floatingButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        floatingButton.hidden = YES; // Começa escondido (menu aberto)
        
        // Ação para reabrir
        [floatingButton addTarget:nil action:@selector(maximizeMenu) forControlEvents:UIControlEventTouchUpInside];
        
        // Gesto para mover o ícone VIP
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:nil action:@selector(dragIcon:)];
        [floatingButton addGestureRecognizer:pan];
        
        [win addSubview:floatingButton];

        menuContainer = [[VIPMenu alloc] initWithFrame:CGRectMake(50, 150, 200, 240)];
        [win addSubview:menuContainer];
        
        espView = [[ESPCanvas alloc] initWithFrame:win.bounds];
        [win addSubview:espView];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ cheat_loop(); });
    });
}

// Funções Auxiliares de Interface
void maximizeMenu() { menuContainer.hidden = NO; floatingButton.hidden = YES; }
void dragIcon(UIPanGestureRecognizer *p) {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}
