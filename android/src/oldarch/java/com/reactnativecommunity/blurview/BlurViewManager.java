package com.reactnativecommunity.blurview;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;

class BlurViewManager extends ViewGroupManager<ReactBlurView> {

  ReactApplicationContext mCallerContext;

  public BlurViewManager(ReactApplicationContext reactContext) {
    mCallerContext = reactContext;
  }

  @Override
  public ReactBlurView createViewInstance(ThemedReactContext context) {
    return BlurViewManagerImpl.createViewInstance(context);
  }

  @NonNull
  @Override
  public String getName() {
    return BlurViewManagerImpl.REACT_CLASS;
  }

  @ReactProp(name = "blurTargetRef")
  public void setBlurTargetRef(ReactBlurView view, int tag) {
    BlurViewManagerImpl.setBlurTargetRef(view, tag);
  }

  @ReactProp(name = "blurRadius", defaultInt = BlurViewManagerImpl.defaultRadius)
  public void setRadius(ReactBlurView view, int radius) {
    BlurViewManagerImpl.setRadius(view, radius);
  }

  @ReactProp(name = "overlayColor", customType = "Color")
  public void setColor(ReactBlurView view, int color) {
    BlurViewManagerImpl.setColor(view, color);
  }

  @ReactProp(name = "downsampleFactor", defaultInt = BlurViewManagerImpl.defaultSampling)
  public void setDownsampleFactor(ReactBlurView view, int factor) {}

  @ReactProp(name = "autoUpdate", defaultBoolean = true)
  public void setAutoUpdate(ReactBlurView view, boolean autoUpdate) {
    BlurViewManagerImpl.setAutoUpdate(view, autoUpdate);
  }

  @ReactProp(name = "enabled", defaultBoolean = true)
  public void setBlurEnabled(ReactBlurView view, boolean enabled) {
    BlurViewManagerImpl.setBlurEnabled(view, enabled);
  }
}
