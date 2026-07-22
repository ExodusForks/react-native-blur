#import <React/RCTComponent.h>
#import "BlurView.h"
#import "VibrancyView.h"

#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTConversions.h>
#import <React/RCTFabricComponentsPlugins.h>
#import <react/renderer/components/rnblurview/ComponentDescriptors.h>
#import <react/renderer/components/rnblurview/Props.h>
#import <react/renderer/components/rnblurview/RCTComponentViewHelpers.h>
#endif // RCT_NEW_ARCH_ENABLED

#ifdef RCT_NEW_ARCH_ENABLED
using namespace facebook::react;

@interface VibrancyView () <RCTVibrancyViewViewProtocol>
#else
@interface VibrancyView ()
#endif // RCT_NEW_ARCH_ENABLED

@property (nonatomic, strong) UIVibrancyEffect *vibrancyEffect;
@property (nonatomic, strong) UIVisualEffectView *vibrancyEffectView;

@end

@implementation VibrancyView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.vibrancyEffectView = [[UIVisualEffectView alloc] init];
        self.vibrancyEffectView.frame = frame;
        [self updateVibrancyEffect];

        [self.blurEffectView.contentView addSubview:self.vibrancyEffectView];
    }

    return self;
}

#ifdef RCT_NEW_ARCH_ENABLED
#pragma mark - RCTComponentViewProtocol

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<VibrancyViewComponentDescriptor>();
}

- (void)mountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
  [self attachToVisualEffectView:childComponentView];
}

- (void)unmountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
  // Override unmountChildComponentView to avoid an assertion on childComponentView.superview == self
  // childComponentView is not a direct subview of self, as it's inserted deeper in a UIVisualEffectView
  [childComponentView removeFromSuperview];
}
#endif // RCT_NEW_ARCH_ENABLED

- (void)layoutSubviews
{
    self.vibrancyEffectView.frame = self.bounds;
    [super layoutSubviews];
}

- (void)insertReactSubview:(id<RCTComponent>)subview atIndex:(NSInteger)atIndex
{
  [self attachToVisualEffectView:(UIView *)subview];
}

- (void)attachToVisualEffectView:(UIView *)subview
{
  if ([self useReduceTransparencyFallback]) {
    [self addSubview:subview];
  } else {
    [[self blurContentView] addSubview:subview];
  }
}

- (void)didUpdateBlurEffect
{
  [super didUpdateBlurEffect];
  [self updateVibrancyEffect];
}

- (void)updateVibrancyEffect
{
  self.vibrancyEffect = self.blurEffect ? [UIVibrancyEffect effectForBlurEffect:self.blurEffect] : nil;
  self.vibrancyEffectView.effect = self.vibrancyEffect;
}

- (UIView *)blurContentView
{
  return self.vibrancyEffectView ? self.vibrancyEffectView.contentView : [super blurContentView];
}

- (void)ensureBlurContentViewHierarchy
{
  [super ensureBlurContentViewHierarchy];

  if (self.vibrancyEffectView && self.vibrancyEffectView.superview != self.blurEffectView.contentView) {
    [self.blurEffectView.contentView addSubview:self.vibrancyEffectView];
  }
}

@end

#ifdef RCT_NEW_ARCH_ENABLED
Class<RCTComponentViewProtocol> VibrancyViewCls(void)
{
  return VibrancyView.class;
}
#endif // RCT_NEW_ARCH_ENABLED
