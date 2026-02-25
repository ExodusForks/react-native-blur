package com.reactnativecommunity.blurview;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.ViewManagerDelegate;
import com.facebook.react.viewmanagers.AndroidBlurTargetViewManagerDelegate;
import com.facebook.react.viewmanagers.AndroidBlurTargetViewManagerInterface;

import eightbitlab.com.blurview.BlurTarget;

@ReactModule(name = BlurTargetManagerImpl.REACT_CLASS)
class BlurTargetManager extends ViewGroupManager<BlurTarget>
    implements AndroidBlurTargetViewManagerInterface<BlurTarget> {

  private final ViewManagerDelegate<BlurTarget> mDelegate;

  public BlurTargetManager(ReactApplicationContext context) {
    mDelegate = new AndroidBlurTargetViewManagerDelegate<>(this);
  }

  @Nullable
  @Override
  protected ViewManagerDelegate<BlurTarget> getDelegate() {
    return mDelegate;
  }

  @NonNull
  @Override
  public String getName() {
    return BlurTargetManagerImpl.REACT_CLASS;
  }

  @NonNull
  @Override
  protected BlurTarget createViewInstance(@NonNull ThemedReactContext context) {
    return BlurTargetManagerImpl.createViewInstance(context);
  }
}
