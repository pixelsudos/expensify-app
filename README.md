# iOS Splash Screen Color Fix

This repository contains fixes for the iOS splash screen color shift issue where the background color slightly changes during app launch.

## Problem
The iOS splash screen uses a cross-dissolve animation that blends colors, creating a perceived color shift from #60D184 to #03D47C during the transition.

## Solution
- Replace cross-dissolve animation with no-transition animation
- Reduce timing from 0.35s + 0.25s to 0.1s + 0.1s
- Ensure consistent #03D47C color across all platforms
- Add comprehensive Jest tests

## Files Modified
- `ios/RCTBootSplash.mm` - Animation and timing changes
- `ios/BootSplash.storyboard` - Background color correction
- `android/app/src/main/res/values/colors.xml` - Color consistency
- `android/app/src/main/res/values-night/colors.xml` - Night mode colors
- `__tests__/SplashScreen.test.tsx` - Comprehensive test suite

## Testing
Tested across iOS 18.5, Android, mWeb, Windows, MacOS, and Desktop platforms.
