#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>
#include <vector>

// Variáveis de Controle
static bool aimbot_full = false;
static bool aimbot_legit = false;
static bool norecoil = false;
static bool precision = false;
static bool esp_on = false;
static int legit_counter = 0;

// --- BUSCA DE MEMÓRIA ---
uintptr_t get_real_offset(long offset) {
    uintptr_t addr = 0;
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        if (strstr(_dyld_get_image_name(i), "UnityFramework")) {
            addr = (uintptr_t)_dyld_get_image_header(i);
            break;
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

// --- INTERFACE MÓVEL (Drag and Drop) ---
@interface VIPMenu : UIView
@property (nonatomic, assign) CGPoint lastPoint;
@end

@implementation VIPMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
        self.layer.cornerRadius = 15;
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor redColor].CGColor;

        // Título
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 220, 30)];
        title.text = @"CAU VIP ULTIMATE";
        title.textColor = [UIColor redColor];
        title.font = [UIFont boldSystemFontOfSize:14];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];

        // Opções
        [self addOpt:@"AIMBOT FULL" y:40 s:@selector(sw1:)];
        [self addOpt:@"AIMBOT LEGIT" y:80 s:@selector(sw2:)];
        [self addOpt:@"NO RECOIL" y:120 s:@selector(sw3:)];
        [self addOpt:@"PRECISÃO" y:160 s:@selector(sw4:)];
        [self addOpt:@"ESP WALLHACK" y:200 s:@selector(sw5:)];

        // Gesto para mover
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)addOpt:(NSString *)txt y:(int)y s:(SEL)s {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 130, 30)];
    l.text = txt; l.textColor = [UIColor whiteColor]; l.font = [UIFont systemFontOfSize:11];
    [self addSubview:l];
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(155, y, 0, 0)];
    sw.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [sw addTarget:self action:s forControlEvents:UIControlEventValueChanged];
    [self addSubview:sw];
}

// Lógica de Movimento
- (void)dragged:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:self];
    self.center = CGPointMake(self.center.x + point.x, self.center.y + point.y);
    [pan setTranslation:CGPointZero inView:self];
}

// Switches
- (void)sw1:(UISwitch *)s { aimbot_full = s.isOn; }
- (void)sw2:(UISwitch *)s { aimbot_legit = s.isOn; }
- (void)sw3:(UISwitch *)s { norecoil = s.isOn; }
- (void)sw4:(UISwitch *)s { precision = s.isOn; }
- (void)sw5:(UISwitch *)s { esp_on = s.isOn; }
@end

// --- LOOP DE CHEATS ---
void cheat_thread() {
    while(true) {
        if (aimbot_full) {
            patch_mem(get_real_offset(0x2C4A110), {0x20, 0x00, 0x80, 0xD2, 0xC0, 0x03, 0x5F, 0xD6});
        }
        if (norecoil) {
            patch_mem(get_real_offset(0x19B3E4C), {0x00, 0x00, 0x80, 0xD2, 0xC0, 0x03, 0x5F, 0xD6});
        }
        if (precision) {
            patch_mem(get_real_offset(0x19B42A8), {0x00, 0x00, 0x80, 0xD2, 0xC0, 0x03, 0x5F, 0xD6});
        }
        [NSThread sleepForTimeInterval:2.0];
    }
}

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        VIPMenu *menu = [[VIPMenu alloc] initWithFrame:CGRectMake(100, 100, 220, 250)];
        [win addSubview:menu];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            cheat_thread();
        });
    });
}
