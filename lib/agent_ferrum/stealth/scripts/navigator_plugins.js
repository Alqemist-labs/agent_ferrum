// Simulate realistic browser plugins
const mockPlugins = [
  {
    name: 'Chrome PDF Plugin',
    description: 'Portable Document Format',
    filename: 'internal-pdf-viewer',
    mimeTypes: [{ type: 'application/x-google-chrome-pdf', suffixes: 'pdf', description: 'Portable Document Format' }]
  },
  {
    name: 'Chrome PDF Viewer',
    description: '',
    filename: 'mhjfbmdgcfjbbpaeojofohoefgiehjai',
    mimeTypes: [{ type: 'application/pdf', suffixes: 'pdf', description: '' }]
  },
  {
    name: 'Native Client',
    description: '',
    filename: 'internal-nacl-plugin',
    mimeTypes: [
      { type: 'application/x-nacl', suffixes: '', description: 'Native Client Executable' },
      { type: 'application/x-pnacl', suffixes: '', description: 'Portable Native Client Executable' }
    ]
  }
];

const createMimeType = (mt, plugin) => {
  const mimeType = Object.create(MimeType.prototype);
  overrideGetter(mimeType, 'type', mt.type);
  overrideGetter(mimeType, 'suffixes', mt.suffixes);
  overrideGetter(mimeType, 'description', mt.description);
  overrideGetter(mimeType, 'enabledPlugin', plugin);
  return mimeType;
};

const createPlugin = (p) => {
  const plugin = Object.create(Plugin.prototype);
  overrideGetter(plugin, 'name', p.name);
  overrideGetter(plugin, 'description', p.description);
  overrideGetter(plugin, 'filename', p.filename);
  overrideGetter(plugin, 'length', p.mimeTypes.length);
  p.mimeTypes.forEach((mt, i) => {
    const mimeType = createMimeType(mt, plugin);
    plugin[i] = mimeType;
    plugin[mt.type] = mimeType;
  });
  plugin[Symbol.iterator] = function* () {
    for (let i = 0; i < this.length; i++) yield this[i];
  };
  return plugin;
};

try {
  const plugins = mockPlugins.map(createPlugin);
  const pluginArray = Object.create(PluginArray.prototype);
  plugins.forEach((p, i) => {
    pluginArray[i] = p;
    pluginArray[p.name] = p;
  });
  overrideGetter(pluginArray, 'length', plugins.length);
  pluginArray[Symbol.iterator] = function* () {
    for (let i = 0; i < this.length; i++) yield this[i];
  };
  overrideGetter(navigator, 'plugins', pluginArray);
} catch (e) {}
