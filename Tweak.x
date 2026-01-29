#import <UIKit/UIKit.h>

%hook UnityAppController

- (void)applicationDidBecomeActive:(id)application {
    %orig;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *keyWin = nil;
        
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    keyWin = scene.windows.firstObject;
                    break;
                }
            }
        }
        
        if (!keyWin) {
            keyWin = [UIApplication sharedApplication].keyWindow;
        }

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"SensiInjetor" 
                                    message:@"Sensibilidade Ativada!" 
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        
        [keyWin.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

%end
