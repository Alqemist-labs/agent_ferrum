// Spoof navigator.vendor and navigator.platform
overrideGetter(navigator, 'vendor', 'Google Inc.');
overrideGetter(navigator, 'platform', 'Win32');
overrideGetter(navigator, 'maxTouchPoints', 0);
