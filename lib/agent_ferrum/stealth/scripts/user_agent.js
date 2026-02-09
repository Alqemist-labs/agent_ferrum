// Clean HeadlessChrome from user agent string
const ua = navigator.userAgent;
if (ua.includes('HeadlessChrome')) {
  const cleanUA = ua.replace('HeadlessChrome', 'Chrome');
  overrideGetter(navigator, 'userAgent', cleanUA);

  // Also fix appVersion
  const appVersion = navigator.appVersion;
  if (appVersion.includes('HeadlessChrome')) {
    overrideGetter(navigator, 'appVersion', appVersion.replace('HeadlessChrome', 'Chrome'));
  }
}
