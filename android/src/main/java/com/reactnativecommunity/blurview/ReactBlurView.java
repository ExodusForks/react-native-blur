package com.reactnativecommunity.blurview;

import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.view.View;

import androidx.annotation.Nullable;

import com.facebook.react.uimanager.ThemedReactContext;

import eightbitlab.com.blurview.BlurTarget;
import eightbitlab.com.blurview.BlurView;
import eightbitlab.com.blurview.BlurViewFacade;

class ReactBlurView extends BlurView {

  int blurTargetTag = View.NO_ID;
  float blurRadius = BlurViewManagerImpl.defaultRadius;
  @Nullable Integer overlayColor = null;

  ReactBlurView(Context context) {
    super(context);
  }

  void attemptSetup() {
    if (blurTargetTag == View.NO_ID || !isAttachedToWindow()) return;
    View rootView = getRootView();
    if (rootView == null) return;
    View target = rootView.findViewById(blurTargetTag);
    if (!(target instanceof BlurTarget)) return;

    BlurViewFacade facade = setupWith((BlurTarget) target, 4f, false)
      .setBlurRadius(blurRadius);

    // Optional: set the window background so fully-transparent root views don't
    // produce semi-transparent blur artefacts — makes the background opaque.
    if (getContext() instanceof ThemedReactContext) {
      Activity activity = ((ThemedReactContext) getContext()).getCurrentActivity();
      if (activity != null) {
        Drawable windowBackground = activity.getWindow().getDecorView().getBackground();
        if (windowBackground != null) {
          facade.setFrameClearDrawable(windowBackground);
        }
      }
    }

    // Re-apply overlay colour — setupWith may reset it to a library default.
    // overlayColor == null means the prop was never set, so we leave the default alone.
    if (overlayColor != null) {
      facade.setOverlayColor(overlayColor);
    }
  }

  @Override
  protected void onAttachedToWindow() {
    super.onAttachedToWindow();
    attemptSetup();
  }
}
