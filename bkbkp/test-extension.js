#!/usr/bin/env gjs

// Simple test script to check if extension modules can be loaded
// Run with: gjs test-extension.js

const EXT_DIR = 'breakcorn-radio@breakcorny@gmail.com';

console.log('Testing Breakcorn Radio extension modules...');

try {
  console.log('1. Testing channels.js...');
  const Channels = await import(`./${EXT_DIR}/channels.js`);
  const channel = Channels.getChannel(0);
  console.log('   ✓ Channels loaded, first channel:', channel.name);

  console.log('2. Testing data.js...');
  const Data = await import(`./${EXT_DIR}/data.js`);
  const lastChannel = Data.getLastChannel();
  console.log('   ✓ Data loaded, last channel:', lastChannel.name);

  console.log('3. Testing radio.js (without GStreamer init)...');
  // We can't test RadioPlayer without a full GNOME environment
  console.log('   ⚠ Radio.js requires GStreamer and GNOME environment');

  console.log('4. Testing extension.js structure...');
  const Extension = await import(`./${EXT_DIR}/extension.js`);
  console.log('   ✓ Extension module loaded');

  console.log('\n✅ All basic module tests passed!');
  console.log('If the extension still doesn\'t work, the issue is likely with:');
  console.log('- GStreamer installation/initialization');
  console.log('- GNOME Shell environment');
  console.log('- Extension activation in GNOME');

} catch (error) {
  console.error('❌ Module loading failed:', error.message);
  console.error('Stack:', error.stack);
  process.exit(1);
}
