#import <UIKit/UIKit.h>

// O %ctor inicia o código assim que o jogo abre
%ctor {
    // Espera 5 segundos para o jogo carregar a tela principal
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIWindow *window = nil;
        
        // Pega a janela ativa no iOS moderno (iOS 13 ou superior)
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    for (UIWindow *w in scene.windows) {
                        if (w.isKeyWindow) {
                            window = w;
                            break;
                        }
                    }
                }
            }
        } else {
            // Para versões mais antigas do iOS
            window = [UIApplication sharedApplication].keyWindow;
        }

        // Se encontrar a janela, exibe o alerta de confirmação
        if (window) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ZZMX SENSI" 
                                        message:@"Injetor Ativado com Sucesso!\nSensibilidade FF MAX Ajustada." 
                                        preferredStyle:UIAlertControllerStyleAlert];
                                        
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" 
                                       style:UIAlertActionStyleDefault 
                                       handler:nil];
                                       
            [alert addAction:okAction];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}
