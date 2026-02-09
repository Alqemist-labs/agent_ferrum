// Remove navigator.webdriver flag
Object.defineProperty(navigator, 'webdriver', {
  get: () => false,
  configurable: true
});

// Also handle the permissions API check
if (navigator.permissions) {
  const originalQuery = navigator.permissions.query;
  navigator.permissions.query = (parameters) => {
    if (parameters.name === 'notifications') {
      return Promise.resolve({ state: Notification.permission });
    }
    return originalQuery.call(navigator.permissions, parameters);
  };
}
