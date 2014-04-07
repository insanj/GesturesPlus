#include <UIKit/UIKit.h>

@interface SBAnimationStepper : UIView
@property(retain, nonatomic) UIView *view;
@end

@interface SBIconController
+ (id)sharedInstance;
- (void)unscatterAnimated:(BOOL)animated afterDelay:(double)delay withCompletion:(id)completion;
@end

@interface SBUIController
+ (id)sharedInstance;
- (void)restoreContentAndUnscatterIconsAnimated:(BOOL)animated withCompletion:(id)completion;
@end
