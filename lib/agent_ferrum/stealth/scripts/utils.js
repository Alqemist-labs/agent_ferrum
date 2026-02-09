// Stealth utility helpers
const makeNativeToString = (fn, name = '') => {
  const handler = {
    apply: function(target, ctx, args) {
      if (ctx === Function.prototype.toString) {
        return `function toString() { [native code] }`;
      }
      return `function ${name || fn.name || ''}() { [native code] }`;
    }
  };
  const proxy = new Proxy(Function.prototype.toString, handler);
  try {
    Function.prototype.toString = proxy;
  } catch (e) {}
};

const overrideGetter = (obj, prop, value) => {
  try {
    Object.defineProperty(obj, prop, {
      get: () => value,
      configurable: true
    });
  } catch (e) {}
};
