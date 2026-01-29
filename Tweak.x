#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>

// --- VARIÁVEIS DE CONTROLE ---
bool HS_Pescoco = false;
bool ESP_Box = false;
bool ESP_Line = false;

// --- BYPASS: LIMPEZA DE LOGS ANTI-BAN ---
void CleanAnticheatLogs() {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *blackList = @[@"Logs", @"GarenaSdk", @"Firebase", @"crash_log.txt", @"report_log.dat"];
    
    for (NSString *file in blackList) {
        NSString *path = [docPath stringByAppendingPathComponent:file];
        if ([fm fileExistsAtPath:path]) [fm removeItemAtPath:path error:nil];
    }
}

// --- INTERFACE DO PAINEL EXTERNO ---
@interface VIPPanel : UIView
@end

@implementation VIPPanel
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
        self.layer.cornerRadius = 12;
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = [UIColor cyanColor].CGColor;

        UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, frame.size.width, 25)];
        t.text = @"CAU MODS VIP"; t.textColor = [UIColor cyanColor];
        t.textAlignment = NSTextAlignmentCenter; t.font = [UIFont boldSystemFontOfSize:14];
        [self addSubview:t];

        [self addMenuSwitch:@"HS PESCOÇO" y:40 action:@selector(swHS:)];
        [self addMenuSwitch:@"ESP BOX" y:80 action:@selector(swBox:)];
        [self addMenuSwitch:@"ESP LINHA" y:120 action:@selector(swLine:)];
    }
    return self;
}

- (void)addMenuSwitch:(NSString *)title y:(int)y action:(SEL)sel {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(10, y, 100, 30)];
    l.text = title; l.textColor = [UIColor whiteColor]; l.font = [UIFont systemFontOfSize:11];
    [self addSubview:l];
    UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectMake(140, y, 0, 0)];
    s.transform = CGAffineTransformMakeScale(0.75, 0.75);
    [s addTarget:self action:sel forControlEvents:UIControlEventValueChanged];
    [self addSubview:s];
}

- (void)swHS:(UISwitch *)s { HS_Pescoco = s.isOn; }
- (void)swBox:(UISwitch *)s { ESP_Box = s.isOn; }
- (void)swLine:(UISwitch *)s { ESP_Line = s.isOn; }
@end

// --- GERENCIADOR DE MOVIMENTO ---
@interface MenuMgr : NSObject
+ (instancetype)s;
- (void)pan:(UIPanGestureRecognizer *)g;
- (void)tap;
@end

UIWindow *win;
UIButton *btn;
VIPPanel *pnl;

@implementation MenuMgr
+ (instancetype)s { static MenuMgr *s; static dispatch_once_t t; dispatch_once(&t, ^{s=[MenuMgr new];}); return s; }
- (void)tap { pnl.hidden = !pnl.hidden; }
- (void)pan:(UIPanGestureRecognizer *)g {
    CGPoint t = [g translationInView:win];
    g.view.center = CGPointMake(g.view.center.x + t.x, g.view.center.y + t.y);
    [g setTranslation:CGPointZero inView:win];
}
@end

// --- HOOKS DE BYPASS (ANTI-DETECÇÃO) ---
%hook NSBundle
- (NSString *)bundleIdentifier {
    // Retorna o ID original para o jogo não saber que é um IPA modificado
    return @"com.dts.freefiremax"; 
}
%end

// --- HOOKS DE FUNÇÃO (HS E ESP) ---
// Aqui é onde os Offsets são aplicados
%hook UnityPlayer // Exemplo de classe Unity
- (void)Update {
    %orig;
    if (HS_Pescoco) {
        // Exemplo de lógica: setAimBone(7); // 7 geralmente é pescoço
    }
}
%end

// --- CONSTRUTOR ---
%ctor {
    CleanAnticheatLogs(); // Limpa rastros ao abrir
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        win = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        win.windowLevel = UIWindowLevelStatusBar + 100.0;
        win.backgroundColor = [UIColor clearColor];
        [win makeKeyAndVisible];

        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 150, 45, 45);
        btn.backgroundColor = [UIColor blackColor];
        btn.layer.cornerRadius = 22.5;
        btn.layer.borderColor = [UIColor cyanColor].CGColor;
        btn.layer.borderWidth = 2;
        [btn setTitle:@"CAU" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        
        [btn addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[MenuMgr s] action:@selector(pan:)]];
        [btn addTarget:[MenuMgr s] action:@selector(tap) forControlEvents:UIControlEventTouchUpInside];
        
        [win addSubview:btn];

        pnl = [[VIPPanel alloc] initWithFrame:CGRectMake(0, 0, 200, 170)];
        pnl.center = win.center;
        pnl.hidden = YES;
        [win addSubview:pnl];
    });
}
