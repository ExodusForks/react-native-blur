package com.reactnativecommunity.blurview;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.ViewManagerDelegate;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.viewmanagers.AndroidBlurViewManagerDelegate;
import com.facebook.react.viewmanagers.AndroidBlurViewManagerInterface;

@ReactModule(name = BlurViewManagerImpl.REACT_CLASS)
class BlurViewManager extends ViewGroupManager<ReactBlurView>
    implements AndroidBlurViewManagerInterface<ReactBlurView> {

  private final ViewManagerDelegate<ReactBlurView> mDelegate;

  public BlurViewManager(ReactApplicationContext context) {
    mDelegate = new AndroidBlurViewManagerDelegate<>(this);
  }

  @Nullable
  @Override
  protected ViewManagerDelegate<ReactBlurView> getDelegate() {
    return mDelegate;
  }

  @NonNull
  @Override
  public String getName() {
    return BlurViewManagerImpl.REACT_CLASS;
  }

  @NonNull
  @Override
  protected ReactBlurView createViewInstance(@NonNull ThemedReactContext context) {
    return BlurViewManagerImpl.createViewInstance(context);
  }

  @Override
  @ReactProp(name = "blurTargetRef")
  public void setBlurTargetRef(ReactBlurView view, int tag) {
    BlurViewManagerImpl.setBlurTargetRef(view, tag);
  }

  @Override
  @ReactProp(name = "blurRadius", defaultInt = BlurViewManagerImpl.defaultRadius)
  public void setBlurRadius(ReactBlurView view, int radius) {
    BlurViewManagerImpl.setRadius(view, radius);
  }

  @Override
  @ReactProp(name = "overlayColor", customType = "Color")
  public void setOverlayColor(ReactBlurView view, Integer color) {
    BlurViewManagerImpl.setColor(view, color);
  }

  @Override
  @ReactProp(name = "downsampleFactor", defaultInt = BlurViewManagerImpl.defaultSampling)
  public void setDownsampleFactor(ReactBlurView view, int factor) {}

  @Override
  @ReactProp(name = "autoUpdate", defaultBoolean = true)
  public void setAutoUpdate(ReactBlurView view, boolean autoUpdate) {
    BlurViewManagerImpl.setAutoUpdate(view, autoUpdate);
  }

  @Override
  @ReactProp(name = "enabled", defaultBoolean = true)
  public void setEnabled(ReactBlurView view, boolean enabled) {
    BlurViewManagerImpl.setBlurEnabled(view, enabled);
  }

  @Override
  public void setBlurAmount(ReactBlurView view, int value) {}

  @Override
  public void setBlurType(ReactBlurView view, @Nullable String value) {}
}
