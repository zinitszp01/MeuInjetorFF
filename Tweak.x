#import <UIKit/UIKit.h>

// --- Interface do Painel VIP ---
@interface SensiPanel : UIView
@property (nonatomic, strong) UISlider *sensiSlider;
@property (nonatomic, strong) UILabel *valueLabel;
@end

@implementation SensiPanel
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Estética do Painel
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        self.layer.cornerRadius = 20;
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = [UIColor cyanColor].CGColor; // Cor da borda
        self.clipsToBounds = YES;

        // Título do Painel
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 30)];
        title.text = @"SENSI INJETOR VIP";
        title.textColor = [UIColor cyanColor];
        title.font = [UIFont boldSystemFontOfSize:16];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];

        // Slider de Sensibilidade
        self.sensiSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 60, frame.size.width - 40, 30)];
        self.sensiSlider.minimumValue = 1.0;
        self.sensiSlider.maximumValue = 10.0;
        self.sensiSlider.tintColor = [UIColor cyanColor];
        [self.sensiSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.sensiSlider];

        // Label de Valor
        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 95, frame.size.width, 20)];
        self.valueLabel.text = @"SENSI: 1.0x";
        self.valueLabel.textColor = [UIColor whiteColor];
        self.valueLabel.font = [UIFont systemFontOfSize:14];
        self.valueLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.valueLabel];
        
        // Rodapé
        UILabel *footer = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, frame.size.width, 15)];
        footer.text = @"Criado por Cau";
        footer.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        footer.font = [UIFont systemFontOfSize:10];
        footer.textAlignment = NSTextAlignmentCenter;
        [self addSubview:footer];
    }
    return self;
}

- (void)sliderChanged:(UISlider *)sender {
    self.valueLabel.text = [NSString stringWithFormat:@"SENSI: %.1fx", sender.value];
    // O valor 'sender.value' é o que você usará nos offsets futuramente
}
@end

// --- Gerenciador de Movimento e Janela ---
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
    [UIView animateWithDuration:0.3 animations:^{
        panel.hidden = !panel.hidden;
        panel.alpha = panel.hidden ? 0 : 1;
    }];
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:externalWindow];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:externalWindow];
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // Janela Superior (Acima de tudo)
        externalWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        externalWindow.windowLevel = UIWindowLevelStatusBar + 100.0;
        externalWindow.backgroundColor = [UIColor clearColor];
        [externalWindow makeKeyAndVisible];
        externalWindow.userInteractionEnabled = YES;

        // Ícone Flutuante (Logo do Injetor)
        floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        floatingButton.frame = CGRectMake(50, 150, 55, 55);
        floatingButton.backgroundColor = [UIColor blackColor];
        floatingButton.layer.cornerRadius = 27.5;
        floatingButton.layer.borderWidth = 2;
        floatingButton.layer.borderColor = [UIColor cyanColor].CGColor;
        [floatingButton setTitle:@"CAU" forState:UIControlStateNormal];
        floatingButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [floatingButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        
        // Gestos
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:[MenuManager shared] action:@selector(handlePan:)];
        [floatingButton addGestureRecognizer:pan];
        [floatingButton addTarget:[MenuManager shared] action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
        
        [externalWindow addSubview:floatingButton];

        // Criar o Painel Principal
        panel = [[SensiPanel alloc] initWithFrame:CGRectMake(0, 0, 220, 160)];
        panel.center = externalWindow.center;
        panel.hidden = YES;
        panel.alpha = 0;
        [externalWindow addSubview:panel];
    });
}
