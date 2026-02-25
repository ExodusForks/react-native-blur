package com.reactnativecommunity.blurview;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;

import eightbitlab.com.blurview.BlurTarget;

class BlurTargetManager extends ViewGroupManager<BlurTarget> {

  public BlurTargetManager(ReactApplicationContext reactContext) {}

  @Override
  public BlurTarget createViewInstance(ThemedReactContext context) {
    return BlurTargetManagerImpl.createViewInstance(context);
  }

  @NonNull
  @Override
  public String getName() {
    return BlurTargetManagerImpl.REACT_CLASS;
  }
}
