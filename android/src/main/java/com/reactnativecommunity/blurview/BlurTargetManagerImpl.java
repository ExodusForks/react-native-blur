package com.reactnativecommunity.blurview;

import com.facebook.react.uimanager.ThemedReactContext;

import eightbitlab.com.blurview.BlurTarget;

import javax.annotation.Nonnull;

@SuppressWarnings("unused")
class BlurTargetManagerImpl {

  public static final String REACT_CLASS = "AndroidBlurTargetView";

  public static @Nonnull BlurTarget createViewInstance(@Nonnull ThemedReactContext ctx) {
    return new BlurTarget(ctx);
  }
}
