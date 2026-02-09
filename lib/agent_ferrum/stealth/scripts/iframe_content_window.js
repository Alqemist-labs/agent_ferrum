// Fix iframe contentWindow detection
try {
  const originalContentWindow = Object.getOwnPropertyDescriptor(HTMLIFrameElement.prototype, 'contentWindow');
  Object.defineProperty(HTMLIFrameElement.prototype, 'contentWindow', {
    get: function() {
      const result = originalContentWindow.get.call(this);
      if (result === null) {
        return result;
      }
      // Ensure the contentWindow has the expected chrome property
      try {
        if (!result.chrome) {
          result.chrome = window.chrome;
        }
      } catch (e) {
        // Cross-origin frame, ignore
      }
      return result;
    },
    configurable: true
  });
} catch (e) {}
