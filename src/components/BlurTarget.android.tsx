import React, { forwardRef } from 'react';
import type { View, ViewProps } from 'react-native';
import NativeBlurTargetView from '../fabric/BlurTargetNativeComponentAndroid';

const BlurTarget = forwardRef<View, ViewProps>((props, ref) => (
  <NativeBlurTargetView ref={ref} {...props} />
));

export default BlurTarget;
