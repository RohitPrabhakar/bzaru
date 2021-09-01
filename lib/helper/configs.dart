import 'package:flutter_bzaru/helper/config.dart';
import 'package:flutter_bzaru/helper/constants.dart';

devConfig() => Config(
      appName: 'Bzaru [DEV]',
      apiBaseUrl: Constants.apiBaseUrl,
      appToken: '',
      apiLogging: true,
      diagnostic: true,
      dummyData: true,
    );
stableConfig() => Config(
      appName: 'Bzaru [Stable]',
      apiBaseUrl: Constants.apiBaseUrl,
      appToken: '',
      apiLogging: true,
      diagnostic: true,
      dummyData: false,
    );

releaseConfig() => Config(
      appName: 'Bzaru [Release]',
      apiBaseUrl: Constants.apiBaseUrl,
      appToken: '',
      apiLogging: false,
      diagnostic: false,
      dummyData: false,
    );
