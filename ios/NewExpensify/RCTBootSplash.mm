#import "RCTBootSplash.h"
#import <React/RCTUtils.h>

static RCTRootView *_rootView = nil;
static bool _nativeHidden = false;
static bool _fade = false;
static NSMutableArray<RCTPromiseResolveBlock> *_resolverQueue = [[NSMutableArray alloc] init];

@implementation RCTBootSplash

RCT_EXPORT_MODULE();

+ (BOOL)requiresMainQueueSetup {
  return NO;
}

+ (void)initWithStoryboard:(NSString * _Nonnull)storyboardName
                  rootView:(RCTRootView * _Nullable)rootView {
  if (rootView == nil || _rootView != nil) return;

  _rootView = rootView;

  [[NSNotificationCenter defaultCenter] removeObserver:rootView
                                                  name:RCTContentDidAppearNotification
                                                object:rootView];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(onContentDidAppear)
                                                name:RCTContentDidAppearNotification
                                              object:rootView];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(onJavaScriptDidLoad)
                                                name:RCTJavaScriptDidLoadNotification
                                              object:nil];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
  UIView *loadingView = [[storyboard instantiateInitialViewController] view];

  loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  loadingView.frame = rootView.bounds;

  [rootView setLoadingView:loadingView];
}

+ (void)onContentDidAppear {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:RCTContentDidAppearNotification
                                                object:_rootView];

  // Reduced initial delay from 0.35s to 0.1s for faster transition
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    if (!_nativeHidden) {
      if (_fade) {
        // Use no-transition animation instead of cross-dissolve to prevent color blending
        // Reduced duration from 0.25s to 0.1s for smoother experience
        [UIView transitionWithView:_rootView
                          duration:0.1
                           options:UIViewAnimationOptionTransitionNone
                        animations:^{
                          [_rootView setLoadingView:nil];
                        }
                        completion:^(__unused BOOL finished) {
                          for (RCTPromiseResolveBlock resolve in _resolverQueue) {
                            resolve(@(true));
                          }

                          [_resolverQueue removeAllObjects];
                        }];
      } else {
        [_rootView setLoadingView:nil];

        for (RCTPromiseResolveBlock resolve in _resolverQueue) {
          resolve(@(true));
        }

        [_resolverQueue removeAllObjects];
      }

      _nativeHidden = true;
    }
  });
}

+ (void)onJavaScriptDidLoad {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:RCTJavaScriptDidLoadNotification
                                                object:nil];
}

RCT_EXPORT_METHOD(hide:(NSDictionary * _Nullable)config
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  if (_nativeHidden) {
    resolve(@(false));
    return;
  }

  if (config && [config objectForKey:@"fade"]) {
    _fade = [[config objectForKey:@"fade"] boolValue];
  }

  if (_rootView == nil || RCTRunningInAppExtension()) {
    _nativeHidden = true;
    resolve(@(true));
  } else {
    [_resolverQueue addObject:resolve];
  }
}

RCT_EXPORT_METHOD(getVisibilityStatus:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(_nativeHidden ? @"hidden" : @"visible");
}

@end
