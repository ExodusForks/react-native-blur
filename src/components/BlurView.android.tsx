import React, { forwardRef, useEffect, useState } from 'react';
import {
  View,
  DeviceEventEmitter,
  StyleSheet,
  ViewProps,
  ViewStyle,
  findNodeHandle,
} from 'react-native';
import NativeBlurView from '../fabric/BlurViewNativeComponentAndroid';

const OVERLAY_COLORS = {
  light: 'rgba(255, 255, 255, 0.2)',
  xlight: 'rgba(255, 255, 255, 0.75)',
  dark: 'rgba(16, 12, 12, 0.64)',
};

export type BlurViewProps = ViewProps & {
  blurAmount?: number;
  blurType?: 'dark' | 'light' | 'xlight' | 'pure';
  blurRadius?: number;
  downsampleFactor?: number;
  overlayColor?: string;
  enabled?: boolean;
  autoUpdate?: boolean;
  blurTargetRef?: React.RefObject<View>;
};

const BlurView = forwardRef<View, BlurViewProps>(
  (
    {
      downsampleFactor,
      blurRadius,
      blurAmount = 10,
      blurType = 'dark',
      overlayColor,
      enabled,
      autoUpdate,
      children,
      style,
      blurTargetRef,
      ...rest
    },
    ref
  ) => {
    const [blurTargetTag, setBlurTargetTag] = useState<number | null>(null);

    useEffect(() => {
      DeviceEventEmitter.addListener('ReactNativeBlurError', (message) => {
        throw new Error(`[ReactNativeBlur]: ${message}`);
      });

      return () => {
        DeviceEventEmitter.removeAllListeners('ReactNativeBlurError');
      };
    }, []);

    useEffect(() => {
      if (blurTargetRef?.current) {
        setBlurTargetTag(findNodeHandle(blurTargetRef.current));
      }
    }, []); // eslint-disable-line react-hooks/exhaustive-deps

    const getOverlayColor = () => {
      if (overlayColor != null) {
        return overlayColor;
      }

      if (blurType === 'pure') {
        return 'rgba(0, 0, 0, 0)';
      }

      return OVERLAY_COLORS[blurType] || OVERLAY_COLORS.dark;
    };

    const getBlurRadius = () => {
      if (blurRadius != null) {
        if (blurRadius > 25) {
          throw new Error(
            `[ReactNativeBlur]: blurRadius cannot be greater than 25! (was: ${blurRadius})`
          );
        }
        return blurRadius;
      }

      // iOS seems to use a slightly different blurring algorithm (or scale?).
      // Android blurRadius + downsampleFactor is approximately 80% of blurAmount.
      const equivalentBlurRadius = Math.round(blurAmount * 0.8);

      if (equivalentBlurRadius > 25) {
        return 25;
      }
      return equivalentBlurRadius;
    };

    const getDownsampleFactor = () => {
      if (downsampleFactor != null) {
        return downsampleFactor;
      }

      return blurRadius;
    };

    return (
      <NativeBlurView
        {...rest}
        ref={ref}
        blurRadius={getBlurRadius()}
        downsampleFactor={getDownsampleFactor()}
        overlayColor={getOverlayColor()}
        blurAmount={blurAmount}
        blurType={blurType}
        enabled={enabled}
        autoUpdate={autoUpdate}
        blurTargetRef={blurTargetTag ?? undefined}
        pointerEvents="none"
        style={StyleSheet.compose(styles.transparent, style)}
      >
        {children}
      </NativeBlurView>
    );
  }
);

const styles = StyleSheet.create<{ transparent: ViewStyle }>({
  transparent: { backgroundColor: 'transparent' },
});

export default BlurView;
