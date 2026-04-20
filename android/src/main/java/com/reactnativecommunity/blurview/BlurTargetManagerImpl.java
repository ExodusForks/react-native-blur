package com.reactnativecommunity.blurview;

import com.facebook.react.uimanager.ThemedReactContext;

import eightbitlab.com.blurview.BlurTarget;

import javax.annotation.Nonnull;

@SuppressWarnings("unused")
class BlurTargetManagerImpl {

  public static final String REACT_CLASS = "AndroidBlurTargetView";

  public static @Nonnull BlurTarget createViewInstance(@Nonnull ThemedReactContext ctx) {
    return new BlurTarget(ctx) {
      @Override
      protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        // No-op: React Native handles child layout via Yoga.
        // FrameLayout.onLayout() must not run here because it repositions children
        // using gravity (default: top-left), overriding Yoga-computed positions.
        // This matches ReactViewGroup's behavior.
      }
    };
  }
}
