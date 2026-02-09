// Add window.chrome.runtime to pass detection checks
if (!window.chrome) {
  window.chrome = {};
}
if (!window.chrome.runtime) {
  window.chrome.runtime = {
    connect: function() {},
    sendMessage: function() {},
    id: undefined
  };
}
// Also ensure chrome.csi and chrome.loadTimes exist
if (!window.chrome.csi) {
  window.chrome.csi = function() { return {}; };
}
if (!window.chrome.loadTimes) {
  window.chrome.loadTimes = function() {
    return {
      commitLoadTime: Date.now() / 1000,
      connectionInfo: 'http/1.1',
      finishDocumentLoadTime: Date.now() / 1000 + 0.1,
      finishLoadTime: Date.now() / 1000 + 0.2,
      firstPaintAfterLoadTime: 0,
      firstPaintTime: Date.now() / 1000 + 0.05,
      navigationType: 'Other',
      npnNegotiatedProtocol: 'http/1.1',
      requestTime: Date.now() / 1000 - 0.5,
      startLoadTime: Date.now() / 1000 - 0.4,
      wasAlternateProtocolAvailable: false,
      wasFetchedViaSpdy: false,
      wasNpnNegotiated: false
    };
  };
}
