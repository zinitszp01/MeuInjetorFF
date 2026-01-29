#import <UIKit/UIKit.h>

// --- Interface do Painel ---
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
        self.layer.borderColor = [UIColor redColor].CGColor;

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 30)];
        title.text = @"SENSI EXTERNA";
        title.textColor = [UIColor whiteColor];
        title.font = [UIFont boldSystemFontOfSize:18];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];

        // Slider de Sensibilidade
        self.sensiSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 60, frame.size.width - 40, 20)];
        self.sensiSlider.minimumValue = 1.0;
        self.sensiSlider.maximumValue = 5.0;
        self.sensiSlider.tintColor = [UIColor redColor];
        [self.sensiSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.sensiSlider];

        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, frame.size.width, 20)];
        self.valueLabel.text = @"Valor: 1.0";
        self.valueLabel.textColor = [UIColor yellowColor];
        self.valueLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.valueLabel];
    }
    return self;
}

- (void)sliderChanged:(UISlider *)sender {
    self.valueLabel.text = [NSString stringWithFormat:@"Valor: %.1f", sender.value];
    // Aqui você enviará o valor para a memória do jogo futuramente
}
@end

// --- Lógica de Arrastar e Janela ---
UIWindow *externalWindow;
UIButton *floatingButton;
SensiPanel *panel;

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // Criando a Janela Invisível que cobre a tela
        externalWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        externalWindow.windowLevel = UIWindowLevelStatusBar + 100.0;
        externalWindow.backgroundColor = [UIColor clearColor];
        [externalWindow makeKeyAndVisible];
        externalWindow.userInteractionEnabled = YES;

        // Botão Flutuante Arrastável
        floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        floatingButton.frame = CGRectMake(50, 150, 60, 60);
        floatingButton.backgroundColor = [UIColor redColor];
        floatingButton.layer.cornerRadius = 30;
        [floatingButton setTitle:@"MENU" forState:UIControlStateNormal];
        
        // Adicionando gesto para arrastar
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [floatingButton addGestureRecognizer:pan];
        [floatingButton addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
        
        [externalWindow addSubview:floatingButton];

        // Inicializando o Painel
        panel = [[SensiPanel alloc] initWithFrame:CGRectMake(50, 220, 220, 140)];
        panel.hidden = YES;
        [externalWindow addSubview:panel];
    });
}

// Função para abrir/fechar
%hook UIViewController
%new
- (void)togglePanel {
    panel.hidden = !panel.hidden;
}

// Função para arrastar o botão
%new
- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:externalWindow];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:externalWindow];
}
%end
