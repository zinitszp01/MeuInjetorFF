#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>

// --- FUNÇÃO DE LIMPEZA DE LOGS (ANTI-BAN) ---
void limparLogsDoJogo() {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Lista de pastas que a Garena usa para salvar logs de detecção
    NSArray *logsParaApagar = @[@"Logs", @"crash_log.txt", @"GarenaSdk", @"Firebase"];
    
    for (NSString *item in logsParaApagar) {
        NSString *fullPath = [documentsPath stringByAppendingPathComponent:item];
        if ([fileManager fileExistsAtPath:fullPath]) {
            [fileManager removeItemAtPath:fullPath error:nil];
        }
    }
}

// --- INTERFACE DO PAINEL ---
@interface SensiPanel : UIView
@property (nonatomic, strong) UISlider *sensiSlider;
@property (nonatomic, strong) UILabel *valueLabel;
@end

@implementation SensiPanel
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
        self.layer.cornerRadius = 15;
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor cyanColor].CGColor;

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 30)];
        title.text = @"CAU VIP BYPASS";
        title.textColor = [UIColor cyanColor];
        title.font = [UIFont boldSystemFontOfSize:16];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];

        self.sensiSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 60, frame.size.width - 40, 30)];
        self.sensiSlider.minimumValue = 1.0;
        self.sensiSlider.maximumValue = 10.0;
        self.sensiSlider.tintColor = [UIColor cyanColor];
        [self addSubview:self.sensiSlider];

        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, frame.size.width, 20)];
        self.valueLabel.text = @"BYPASS: ATIVADO ✅";
        self.valueLabel.textColor = [UIColor greenColor];
        self.valueLabel.font = [UIFont systemFontOfSize:12];
        self.valueLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.valueLabel];
    }
    return self;
}
@end

// --- GERENCIADOR DO MENU ---
@interface MenuManager : NSObject
+ (instancetype)shared;
- (void)togglePanel;
- (void)handlePan:(UIPanGestureRecognizer *)sender;
@end

UIWindow *externalWindow;
UIButton *floatingButton;
SensiPanel *panel;

@implementation MenuManager
+ (instancetype)shared {
    static MenuManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ shared = [MenuManager new]; });
    return shared;
}
- (void)togglePanel { panel.hidden = !panel.hidden; }
- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:externalWindow];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:externalWindow];
}
@end

// --- BYPASS DE IDENTIFICAÇÃO ---
%hook NSBundle
- (NSString *)bundleIdentifier {
    // Engana o jogo fingindo que ele ainda é o original da App Store
    // se ele tentar checar se o ID do pacote mudou
    return @"com.dts.freefiremax"; 
}
%end

// --- INICIALIZAÇÃO ---
%ctor {
    // 1. Limpa rastros de bans anteriores
    limparLogsDoJogo();
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        externalWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        externalWindow.windowLevel = UIWindowLevelStatusBar + 100.0;
        externalWindow.backgroundColor = [UIColor clearColor];
        [externalWindow makeKeyAndVisible];

        floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        floatingButton.frame = CGRectMake(30, 200, 50, 50);
        floatingButton.backgroundColor = [UIColor blackColor];
        floatingButton.layer.cornerRadius = 25;
        floatingButton.layer.borderColor = [UIColor cyanColor].CGColor;
        floatingButton.layer.borderWidth = 1;
        [floatingButton setTitle:@"VIP" forState:UIControlStateNormal];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:[MenuManager shared] action:@selector(handlePan:)];
        [floatingButton addGestureRecognizer:pan];
        [floatingButton addTarget:[MenuManager shared] action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
        
        [externalWindow addSubview:floatingButton];

        panel = [[SensiPanel alloc] initWithFrame:CGRectMake(50, 260, 200, 150)];
        panel.hidden = YES;
        [externalWindow addSubview:panel];
    });
}
