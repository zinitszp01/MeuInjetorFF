#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>
#include <vector>

// --- OFFSETS BACKUP ---
#define OFF_RECOIL 0x19B3E4C
#define OFF_SPREAD 0x19B42A8
#define OFF_AIMBOT 0x2C4A110

// --- VARIÁVEIS DE CONTROLE ---
static bool aimbot_full = false, aimbot_legit = false, norecoil = false, precision = false, esp_on = false;

// --- BYPASS DE LOGIN ---
%hook UIApplication
- (BOOL)openURL:(NSURL*)url options:(NSDictionary<UIApplicationOpenExternalURLOptionsKey, id>*)options completionHandler:(void (^)(BOOL success))completion {
    return %orig(url, options, completion);
}
%end

%hook UnityAppController
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<id, id>*)options {
    return %orig;
}
%end

// --- SISTEMA DE DESENHO (ESP) ---
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
    [[UIColor cyanColor] setStroke];
    CGContextSetLineWidth(ctx, 1.5);
    CGContextMoveToPoint(ctx, rect.size.width / 2, 0);
    CGContextAddLineToPoint(ctx, rect.size.width / 2, rect.size.height / 2);
    CGContextStrokePath(ctx);
    [@"CAU VIP: ATIVO" drawAtPoint:CGPointMake(20, 50) withAttributes:@{NSForegroundColorAttributeName:[UIColor greenColor]}];
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

// --- INTERFACE MÓVEL ---
@interface VIPMenu : UIView
@end
@implementation VIPMenu
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        self.layer.cornerRadius = 20; self.layer.borderWidth = 2; self.layer.borderColor = [UIColor redColor].CGColor;
        UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 220, 30)];
        t.text = @"CAU VIP V7.0"; t.textColor = [UIColor redColor]; t.textAlignment = NSTextAlignmentCenter;
        [self addSubview:t];
        [self addOpt:@"AIMBOT FULL" y:50 s:@selector(sw1:)];
        [self addOpt:@"AIMBOT LEGIT" y:95 s:@selector(sw2:)];
        [self addOpt:@"NO RECOIL" y:140 s:@selector(sw3:)];
        [self addOpt:@"PRECISAO" y:185 s:@selector(sw4:)];
        [self addOpt:@"ESP WALL" y:230 s:@selector(sw5:)];
        UIPanGestureRecognizer *p = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(d:)];
        [self addGestureRecognizer:p];
    }
    return self;
}
- (void)addOpt:(NSString *)n y:(int)y s:(SEL)s {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 120, 30)];
    l.text = n; l.textColor = [UIColor whiteColor]; [self addSubview:l];
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(150, y, 0, 0)];
    [sw addTarget:self action:s forControlEvents:UIControlEventValueChanged]; [self addSubview:sw];
}
- (void)d:(UIPanGestureRecognizer *)p {
    CGPoint t = [p translationInView:self]; self.center = CGPointMake(self.center.x + t.x, self.center.y + t.y);
    [p setTranslation:CGPointZero inView:self];
}
- (void)sw1:(UISwitch *)s { aimbot_full = s.isOn; }
- (void)sw2:(UISwitch *)s { aimbot_legit = s.isOn; }
- (void)sw3:(UISwitch *)s { norecoil = s.isOn; }
- (void)sw4:(UISwitch *)s { precision = s.isOn; }
- (void)sw5:(UISwitch *)s { esp_on = s.isOn; }
@end

// --- LOOP ---
void cheat_loop() {
    std::vector<uint8_t> p_z = {0x00, 0x00, 0x80, 0xD2, 0xC0, 0x03, 0x5F, 0xD6};
    std::vector<uint8_t> p_o = {0x20, 0x00, 0x80, 0xD2, 0xC0, 0x03, 0x5F, 0xD6};
    while(true) {
        if (aimbot_full) patch_mem(get_unity_addr(OFF_AIMBOT), p_o);
        if (norecoil)    patch_mem(get_unity_addr(OFF_RECOIL), p_z);
        if (precision)   patch_mem(get_unity_addr(OFF_SPREAD), p_z);
        if (esp_on)      dispatch_async(dispatch_get_main_queue(), ^{ [espView setNeedsDisplay]; });
        [NSThread sleepForTimeInterval:1.0];
    }
}

// --- INICIALIZADOR CORRIGIDO (iOS 13+ COMPATIBLE) ---
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = nil;
        // Nova forma de buscar a janela ativa para evitar o erro de 'deprecated'
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    for (UIWindow *w in scene.windows) { if (w.isKeyWindow) { win = w; break; } }
                }
            }
        }
        if (!win) win = [[UIApplication sharedApplication] keyWindow];

        if (win) {
            espView = [[ESPCanvas alloc] initWithFrame:win.bounds];
            [win addSubview:espView];
            VIPMenu *m = [[VIPMenu alloc] initWithFrame:CGRectMake(50, 150, 220, 280)];
            [win addSubview:m];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ cheat_loop(); });
    });
}
