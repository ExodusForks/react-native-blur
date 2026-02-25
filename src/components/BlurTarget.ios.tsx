import React, { forwardRef } from 'react';
import { View } from 'react-native';
import type { ViewProps } from 'react-native';

const BlurTarget = forwardRef<View, ViewProps>((props, ref) => (
  <View ref={ref} {...props} />
));

export default BlurTarget;
