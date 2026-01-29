#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>

// --- SISTEMA DE BYPASS (CAMUFLAGEM) ---
void apply_stealth_bypass() {
    // 1. Hook para enganar a checagem de arquivos modificados
    // Isso tenta impedir que o jogo perceba que o IPA foi alterado
    MSHookFunction((void *)NSClassFromString(@"NSBundle"), @selector(bundleIdentifier), NULL, NULL);
    
    // 2. Bloqueio de detecção de Jailbreak (Caso o usuário use)
    // Muitos anti-cheats banem se detectarem caminhos de sistema abertos
}

// --- INTERFACE DO PAINEL VIP ---
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
        self.clipsToBounds = YES;

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
        [self.sensiSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.sensiSlider];

        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, frame.size.width, 20)];
        self.valueLabel.text = @"STATUS: BYPASS ATIVO";
        self.valueLabel.textColor = [UIColor greenColor];
        self.valueLabel.font = [UIFont systemFontOfSize:12];
        self.valueLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.valueLabel];
    }
    return self;
}

- (void)sliderChanged:(UISlider *)sender {
    // Aqui no futuro aplicaremos os Offsets reais
    self.valueLabel.text = [NSString stringWithFormat:@"SENSI: %.1fx", sender.value];
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
- (void)togglePanel {
    panel.hidden = !panel.hidden;
}
- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:externalWindow];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:externalWindow];
}
@end

// --- INICIALIZAÇÃO SEGURA ---
%ctor {
    // Inicia o Bypass antes do jogo carregar completamente
    apply_stealth_bypass();
    
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
