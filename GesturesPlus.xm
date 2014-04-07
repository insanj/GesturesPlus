/*

GesturesPlus
-----------------

Fix the weird-as-hell pinch-to-close animation on iOS 7.0

Copyright (c) Bensge 2014
Fork Copyright (c) insanj 2014
MIT License

*/

#import "GesturesPlus.h"

static BOOL blockALLDemCalls = NO, ignoreUnscatterBecauseRepeat = NO;

%hook SBAnimationStepper

// Prevents graphical / gesture mishaps when other views are step-animating, such as
// apps zooms (when opening or closing to homescreen without gesture).
- (void)stepAnimationsInView:(UIView *)view animatingSubviews:(NSArray *)subviews duration:(double)duration {
	if ([view isKindOfClass:objc_getClass("SBAppWindow")]) {
		if (subviews.count > 0) {
			view = subviews[0];
		}
	}

	%orig();
}


// Doesn't appear to be called when gesturing (at least on iPhone):
// -(void)setPercentage

// Completes (final swooshes) the scatter animation (backwards, away from home screen).
- (void)finishBackwardToStart {
	%orig();
	[[objc_getClass("SBIconController") sharedInstance] unscatterAnimated:YES afterDelay:0 withCompletion:nil];
}

// Same as above, but for the app-to-homescreen forwards zoom (when first pinching).
- (void)finishForwardToEnd {
	%orig();
	[[objc_getClass("SBIconController") sharedInstance] unscatterAnimated:YES afterDelay:0 withCompletion:nil];

	ignoreUnscatterBecauseRepeat = YES;
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_gesturesplus_stopIngoringUnscatter) object:nil];
	[self performSelector:@selector(_gesturesplus_stopIngoringUnscatter) withObject:nil afterDelay:1.f];
}

// Swaps value at the end of a delay to prevent repeat gesture animations.
%new - (void)_gesturesplus_stopIngoringUnscatter {
	ignoreUnscatterBecauseRepeat = NO;
}

%end

%hook SBIconController

// Scatters in the icons during or completing an animation (the mother of homescreen
// animators). If prevented from calling, will freeze the icons, then rescatter when
// the gesture is completed:
// -(void)scatterAnimated:(BOOL)arg1 withCompletion:(id)arg2

// Keystone. If the gesture began (_suspendGestureBegan), then NEVER finish scattering until
// the gesture completed (the method finished executing). Also has safeguard against misfires.
- (void)unscatterAnimated:(BOOL)animated afterDelay:(double)delay withCompletion:(id)completion {
	if (!blockALLDemCalls && !ignoreUnscatterBecauseRepeat) {
		%orig;
	}
}

%end

%hook SBUIController

// Similar to the -finishXXXtoXXX functions, but for cancelled gestures.
- (void)restoreContentAndUnscatterIconsAnimated:(BOOL)animated withCompletion:(id)completion {
	if (!blockALLDemCalls) {
		%orig();
	}
}

// The pinch-gesture began. Probably runs in main loop, and finishes executing when
// the gesture has finally been completed or cancelled.
- (void)_suspendGestureBegan {
	blockALLDemCalls = YES;
	%orig();
	blockALLDemCalls = NO;
}

%end
