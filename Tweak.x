#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// Função para exibir o alerta ao abrir o jogo
void mostrarAlerta() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        
        // Lógica compatível com iOS 13, 14, 15+ e versões antigas
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
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
            window = [UIApplication sharedApplication].keyWindow;
        }

        if (window) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"SensiInjetor" 
                                        message:@"Sensibilidade Injetada com Sucesso!\nCriado por Cau" 
                                        preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}

// Hook que detecta quando o jogo inicia
%hook UnityAppController

- (void)applicationDidBecomeActive:(id)application {
    %orig;
    mostrarAlerta();
}

%end
