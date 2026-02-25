package com.reactnativecommunity.blurview;

import com.facebook.react.uimanager.ThemedReactContext;

import javax.annotation.Nonnull;

@SuppressWarnings("unused")
class BlurViewManagerImpl {

  public static final String REACT_CLASS = "AndroidBlurView";

  public static final int defaultRadius = 10;
  public static final int defaultSampling = 10;

  public static @Nonnull ReactBlurView createViewInstance(@Nonnull ThemedReactContext ctx) {
    return new ReactBlurView(ctx);
  }

  public static void setBlurTargetRef(ReactBlurView view, int tag) {
    if (tag <= 0) return;
    view.blurTargetTag = tag;
    view.attemptSetup();
  }

  public static void setRadius(ReactBlurView view, int radius) {
    // Store so attemptSetup() can re-apply after setupWith(), and also
    // update the running renderer if setup has already happened.
    view.blurRadius = (float) radius;
    view.setBlurRadius((float) radius);
    view.invalidate();
  }

  public static void setColor(ReactBlurView view, int color) {
    // Store for re-apply in attemptSetup(); also push to renderer directly.
    view.overlayColor = color;
    view.setOverlayColor(color);
    view.invalidate();
  }

  public static void setDownsampleFactor(ReactBlurView view, int factor) {}

  public static void setAutoUpdate(ReactBlurView view, boolean autoUpdate) {
    view.setBlurAutoUpdate(autoUpdate);
    view.invalidate();
  }

  public static void setBlurEnabled(ReactBlurView view, boolean enabled) {
    view.setBlurEnabled(enabled);
  }
}
