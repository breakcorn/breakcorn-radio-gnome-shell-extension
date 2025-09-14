# Breakcorn Radio GNOME Extension

🎵 A feature-rich internet radio player for GNOME Shell that brings high-quality audio streaming directly to your desktop.

![GNOME Shell](https://img.shields.io/badge/GNOME%20Shell-45%20%7C%2046%20%7C%2047-4A90E2)
![License](https://img.shields.io/badge/License-GPL%20v3-blue.svg)
![Version](https://img.shields.io/badge/Version-0.0.5-green)

## ✨ Key Features

### 🔄 **Intelligent Auto-Reconnection System**
- **Automatic stream recovery** when connections are interrupted
- **Exponential backoff strategy** (1s → 2s → 4s → 8s → 15s) to prevent server overload
- **Configurable retry attempts** (default: 5 attempts)
- **Visual reconnection progress** with user-cancellable interface
- **Smart error detection** - distinguishes user stops from connection failures

### 🎚️ **Advanced Audio Control**
- **Volume slider** with real-time adjustment
- **PulseAudio integration** for system-wide audio management
- **Mute functionality** with visual feedback
- **High-quality audio streaming** via GStreamer 1.0

### 📻 **Station Management**
- **8 pre-configured radio stations** featuring:
  - Breakcorn Radio (Main & Mezzo channels)
  - Breakcore Mashcore Radio
  - Nautic Radio Groningen
  - Radio Schizoid (4 specialized channels: PsyTrance, Chillout, Dub Techno, Progressive)
- **Favorites system** for quick access to preferred stations
- **Next/Previous controls** for easy station switching
- **Visual station indicators** with custom artwork

### 📱 **User Interface**
- **Compact panel integration** - appears in GNOME Shell top bar
- **Dropdown popup menu** with all controls accessible
- **Real-time metadata display** - shows current track information
- **Loading animations** and connection status indicators
- **Responsive design** that adapts to different screen sizes

### ⚙️ **Configuration & Persistence**
- **Automatic settings persistence** - remembers last station, volume, and favorites
- **User configuration directory** (`~/.breakcorn-radio/`)
- **Configurable reconnection parameters**
- **Export/import capability** for settings backup

## 🏗️ Architecture Overview

### Core Components

The extension is built with a modular architecture totaling **1,067 lines of code** across multiple specialized modules:

#### 📁 **File Structure**
```
breakcorn-radio@breakcorny@gmail.com/
├── extension.js        (427 lines) - Main extension logic & UI
├── radio.js           (339 lines) - Audio player & reconnection system
├── channels.js        (161 lines) - Station definitions & management
├── data.js           (117 lines) - Configuration & persistence
├── metadata.json      (12 lines) - Extension metadata
├── prefs.json         (11 lines) - Default preferences
├── stylesheet.css     - UI styling
├── radio-symbolic.svg - Extension icon
└── images/
    └── breakcorn.png  - Station artwork
```

#### 🔧 **Technical Components**

**1. RadioPlayer Class** (`radio.js`)
- **GStreamer Integration**: Handles audio streaming via `playbin` element
- **Connection State Management**: Tracks STOPPED, CONNECTING, PLAYING, RECONNECTING, ERROR states  
- **Retry Logic**: Implements exponential backoff with configurable parameters
- **Event Handling**: Processes GStreamer messages (TAG, STREAM_START, EOS, ERROR)
- **Audio Pipeline**: `playbin` → `pulsesink` → PulseAudio

**2. BreakcornRadioPopup Class** (`extension.js`)
- **UI Rendering**: Creates popup interface with controls and displays
- **Event Management**: Handles user interactions and state updates
- **Visual Feedback**: Manages loading animations, error messages, reconnection status
- **Integration Layer**: Bridges RadioPlayer with GNOME Shell UI

**3. Channel Management** (`channels.js`)
- **Station Registry**: Maintains list of 8 available radio stations
- **Channel Objects**: Encapsulates station metadata (name, URL, artwork, ID)
- **Favorites Integration**: Provides starred/unstarred functionality
- **UI Generation**: Creates menu items for station selection

**4. Data Persistence** (`data.js`)
- **Settings Storage**: JSON-based configuration in user home directory
- **State Management**: Persists last station, volume level, favorites list
- **Configuration API**: Provides getter/setter methods for preferences
- **Migration Support**: Handles settings format upgrades

### 🔗 **Integration Points**

- **GNOME Shell**: Extends `PanelMenu.Button` for top bar integration
- **GStreamer**: Native audio streaming with codec support
- **PulseAudio**: System audio integration via `pulsesink`
- **GLib**: Main loop integration for timers and async operations
- **GTK4/libadwaita**: Modern UI components and styling

## 📋 Requirements

### System Dependencies
- **GNOME Shell**: 45, 46, or 47
- **GStreamer**: 1.0 with multimedia codecs
  ```bash
  # Ubuntu/Debian
  sudo apt install gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly
  
  # Fedora
  sudo dnf install gstreamer1-plugins-base gstreamer1-plugins-good gstreamer1-plugins-bad-free gstreamer1-plugins-ugly
  
  # Arch Linux
  sudo pacman -S gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly
  ```
- **PulseAudio/PipeWire**: For audio output
- **GNOME Extensions**: System must support extensions

### Optional Tools
- **GNOME Tweaks**: For extension management GUI
- **Extension Manager**: Modern extension management application

## 🚀 Installation

### Method 1: Manual Installation (Recommended)

```bash
# Clone the repository
git clone https://github.com/breakcorn/breakcorn-radio-gnome-shell-extension.git
cd breakcorn-radio-gnome-shell-extension

# Install extension
cp -r 'breakcorn-radio@breakcorny@gmail.com' ~/.local/share/gnome-shell/extensions/

# Enable extension
gnome-extensions enable breakcorn-radio@breakcorny@gmail.com

# Restart GNOME Shell
# X11: Alt+F2 → type 'r' → Enter
# Wayland: Log out and log back in
```

### Method 2: Development Setup

```bash
# For development/testing
git clone https://github.com/breakcorn/breakcorn-radio-gnome-shell-extension.git
cd breakcorn-radio-gnome-shell-extension

# Create symlink for easier development
ln -sf "$(pwd)/breakcorn-radio@breakcorny@gmail.com" ~/.local/share/gnome-shell/extensions/

# Enable extension
gnome-extensions enable breakcorn-radio@breakcorny@gmail.com
```

### Verification

```bash
# Check installation
gnome-extensions list | grep breakcorn-radio

# View logs (helpful for troubleshooting)
journalctl -f -o cat /usr/bin/gnome-shell
```

## 🎵 Usage

### Basic Operations

1. **Access**: Click the radio icon in the top panel
2. **Play/Pause**: Click the play button in the popup
3. **Station Selection**: Use next/previous arrows or channel dropdown
4. **Volume Control**: Adjust the slider in the popup
5. **Favorites**: Click the star icon to bookmark stations

### Advanced Features

#### Reconnection Management
- **Automatic**: Extension handles connection drops transparently
- **Manual Cancel**: Click "Отменить" during reconnection attempts
- **Status Monitoring**: Watch the "Переподключение... (2/5)" counter

#### Metadata Display
- **Current Track**: Displayed in the main text area
- **Click to Copy**: Click track name to copy to clipboard
- **Station Info**: Shows current station name and artwork

## ⚙️ Configuration

### Settings Location
Settings are stored in: `~/.breakcorn-radio/prefs.json`

### Configurable Parameters

```json
{
  "lastChannel": 0,
  "favs": [],
  "lastVol": 0.5,
  "reconnection": {
    "enabled": true,
    "maxAttempts": 5,
    "baseDelay": 1000,
    "maxDelay": 15000
  }
}
```

#### Reconnection Settings
- `enabled`: Enable/disable auto-reconnection
- `maxAttempts`: Maximum retry attempts (1-10 recommended)
- `baseDelay`: Initial delay in milliseconds
- `maxDelay`: Maximum delay cap in milliseconds

### Adding Custom Stations

Edit `channels.js` to add new stations:

```javascript
{
  name: "Your Station Name",
  link: "https://your-stream-url.com/stream",
  pic: "/images/your-image.png",
  num: 8, // Next available number
}
```

## 🐛 Troubleshooting

### Common Issues

**Extension not appearing**
```bash
# Check if extension is enabled
gnome-extensions list --enabled | grep breakcorn

# Restart GNOME Shell
killall -3 gnome-shell  # X11 only
```

**Audio not playing**
```bash
# Check GStreamer installation
gst-inspect-1.0 playbin
gst-inspect-1.0 pulsesink

# Test audio pipeline
gst-launch-1.0 audiotestsrc ! pulsesink
```

**Connection issues**
- Verify internet connectivity
- Check if stream URLs are accessible: `curl -I [stream-url]`
- Review logs: `journalctl -f -o cat /usr/bin/gnome-shell`

### Debug Mode

Enable detailed logging:
```bash
# Add to environment
export GST_DEBUG=3
# Restart GNOME Shell
```

## 🔧 Development

### Building from Source

```bash
git clone https://github.com/breakcorn/breakcorn-radio-gnome-shell-extension.git
cd breakcorn-radio-gnome-shell-extension

# No build process required - pure JavaScript
# Install directly from source
cp -r 'breakcorn-radio@breakcorny@gmail.com' ~/.local/share/gnome-shell/extensions/
```

### Code Structure

- **Modern ES6+ JavaScript**: Uses import/export modules
- **GNOME Shell APIs**: Leverages native GNOME Shell components
- **GObject Introspection**: Direct access to GTK, GStreamer, GLib
- **Modular Design**: Clean separation of concerns

### Testing

```bash
# Install in development mode
ln -sf "$(pwd)/breakcorn-radio@breakcorny@gmail.com" ~/.local/share/gnome-shell/extensions/

# Watch logs
journalctl -f -o cat /usr/bin/gnome-shell | grep -i breakcorn

# Reload extension (X11)
gnome-extensions disable breakcorn-radio@breakcorny@gmail.com
gnome-extensions enable breakcorn-radio@breakcorny@gmail.com
```

### Contributing

1. **Fork** the repository
2. **Create** feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** changes: `git commit -m 'Add amazing feature'`
4. **Push** to branch: `git push origin feature/amazing-feature`
5. **Open** Pull Request

#### Code Style
- **4-space indentation**
- **Semicolons required**
- **camelCase** for variables and methods
- **PascalCase** for classes
- **Descriptive naming** for clarity

## 📝 Changelog

### Version 0.0.5 (Current)
- ✅ **Added**: Intelligent auto-reconnection system with exponential backoff
- ✅ **Added**: Configurable reconnection parameters
- ✅ **Added**: Visual reconnection progress indicators
- ✅ **Added**: Connection state management
- ✅ **Improved**: Error handling and user feedback
- ✅ **Enhanced**: Settings persistence system

### Previous Versions
- **0.0.4**: Basic radio streaming functionality
- **0.0.3**: Favorites system implementation  
- **0.0.2**: Volume control and station switching
- **0.0.1**: Initial release with basic playback

## 🔗 Links

- **Repository**: [GitHub](https://github.com/breakcorn/breakcorn-radio-gnome-shell-extension)
- **Issues**: [Bug Reports](https://github.com/breakcorn/breakcorn-radio-gnome-shell-extension/issues)
- **GNOME Extensions**: [Extension Page](https://extensions.gnome.org/) *(if published)*
- **Breakcorn Radio**: [Main Site](https://breakcorn.ru/)

## 📜 License

This program is free software: you can redistribute it and/or modify it under the terms of the **GNU General Public License version 3** as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the [LICENSE](LICENSE) file for more details.

---

**Made with ❤️ for the GNOME community**