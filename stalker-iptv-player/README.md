# Stalker MAC IPTV Player - Roku SGDEX

## Overview

This is a **complete, production-ready** Roku channel that streams IPTV channels from a Stalker MAC portal using SGDEX (Scene Graph Developer Extensions).

## Features

✅ Load channels from Stalker MAC portal  
✅ Display channels in a beautiful grid view  
✅ Stream playback with VideoView  
✅ Channel groups and logos  
✅ HLS stream support  
✅ Full debug console output  

## Prerequisites

- **Roku Device** (any model with Roku OS 9.0+)
- **Developer Mode** enabled on your Roku
- **Stalker MAC Portal** account with active server
- **Roku Studio** or **Eclipse** for deployment
- **Git** (for cloning SGDEX)

## Quick Setup (5 minutes)

### Step 1: Clone This Repo

```bash
git clone https://github.com/tomaszr215-netizen/mac-players.git
cd mac-players/stalker-iptv-player
```

### Step 2: Get SGDEX Framework

```bash
git clone https://github.com/rokudev/SceneGraphDeveloperExtensions.git
cp -r SceneGraphDeveloperExtensions/extensions/SGDEX components/
```

### Step 3: Configure Your Stalker Credentials

Open `components/MainScene.brs` and modify:

```brightscript
STALKER_SERVER = "http://your-stalker-server.com"    ' Your server URL
STALKER_MAC = "00:1a:2b:3c:4d:5e"                    ' Your MAC address
```

### Step 4: Deploy to Roku

#### Option A: Roku Studio (Recommended)

1. Open **Roku Studio**
2. **File** → **Load Project** → Select this folder
3. **Package & Deploy**
4. Enter your Roku IP and password
5. Click **Deploy**

#### Option B: Command Line

```bash
# Find your Roku IP in Settings → System → About
echo 'install stalker-iptv-player.zip' | telnet <ROKU_IP> 8085
```

## Project Structure

```
stalker-iptv-player/
├── manifest                          # Channel metadata
├── source/
│   ├── main.brs                      # Entry point
│   └── SGDEX.brs                     # Framework initialization
├── components/
│   ├── SGDEX/                        # SGDEX framework (copy from repo)
│   ├── MainScene.xml                 # Main scene definition
│   ├── MainScene.brs                 # ⭐ Main logic - EDIT THIS
│   ├── DeepLinkingLogic.brs          # Deep linking support
│   ├── StalkerParser.brs             # M3U parser
│   ├── StalkerContentHandler.xml     # Handler definition
│   └── StalkerContentHandler.brs     # Handler implementation
└── README.md                         # This file
```

## How It Works

1. **main.brs** - Defines entry point `MainScene`
2. **SGDEX.brs** - Initializes the framework
3. **MainScene.brs** - Creates GridView and loads channels
4. **StalkerContentHandler.brs** - Fetches M3U from Stalker server
5. **StalkerParser.brs** - Parses M3U format
6. **GridView** - Displays channels with logos
7. **VideoView** - Plays selected channel

## Configuration

### Stalker Server URL Format

```
http://stalker-server.com          ✓ Correct
http://stalker-server.com/         ✓ Works (slash removed)
http://stalker-server.com:8080     ✓ With port
https://stalker-server.com         ✓ HTTPS supported
```

### MAC Address Format

Your MAC address should be:

```
00:1a:2b:3c:4d:5e         ✓ Correct
001a2b3c4d5e              ✗ Wrong
AA:BB:CC:DD:EE:FF         ✓ Also correct
```

## Debugging

To see debug output, connect via telnet:

```bash
telnet <ROKU_IP> 8085
```

You'll see messages like:

```
==================================================
  FETCHING PLAYLIST FROM STALKER
==================================================
Server: http://your-server.com
MAC: 00:1a:2b:3c:4d:5e
URL: http://your-server.com/portal.php?type=m3u&mac=00:1a:2b:3c:4d:5e

Success! Playlist fetched
Size: 45230 bytes

Parsing M3U content...
Parsed 150 channels

Creating ContentNode for channels...
ContentNode created: 150 channels
```

## Troubleshooting

### ❌ No channels appear

1. **Check Stalker credentials:**
   ```bash
   # Test manually in browser:
   http://your-server.com/portal.php?type=m3u&mac=00:1a:2b:3c:4d:5e
   ```

2. **Verify network connection:**
   - Roku and server must be on same network (or connected via VPN)
   - Check firewall settings

3. **Check telnet debug output:**
   ```bash
   telnet <ROKU_IP> 8085
   # Look for ERROR messages
   ```

### ❌ Channels load but don't play

1. **Check stream format:**
   - Roku supports: HLS (.m3u8), MPEG-TS over HTTP
   - Roku does NOT support: UDP, RTMP, MPTS, custom protocols

2. **Increase timeout:**
   ```brightscript
   # In StalkerParser.brs:
   http.SetTimeout(60)  ' 60 seconds instead of 30
   ```

### ❌ Connection timeout

1. **Verify Roku can reach server:**
   ```bash
   ping <ROKU_IP>  # From your computer
   ```

2. **Check server is online:**
   ```bash
   curl http://your-server.com/portal.php?type=m3u&mac=00:1a:2b:3c:4d:5e
   ```

3. **Increase timeout in StalkerParser.brs:**
   ```brightscript
   http.SetTimeout(60)  # Instead of 30
   ```

## Advanced Customization

### Change Grid Layout

In `MainScene.brs`:

```brightscript
m.gridView.posterShape = "portrait"    ' or "landscape" or "square"
m.gridView.numColumns = 4              ' Number of columns
m.gridView.numRows = 3                 ' Number of rows
```

### Sort Channels

In `StalkerContentHandler.brs`, after parsing:

```brightscript
' Sort by title
items.Sort(function(a, b)
    if a.Title < b.Title
        return -1
    else if a.Title > b.Title
        return 1
    else
        return 0
    end if
end function)
```

### Filter by Group

In `StalkerContentHandler.brs`:

```brightscript
' Only add if group matches
if item.Group = "Polskie" or item.Group = "Sport"
    child.Title = item.Title
    ' ... rest of code
end if
```

### Custom Theme

In `MainScene.brs`:

```brightscript
m.gridView.theme = {
    TextColor: "0xFFFFFFFF",
    focusRingColor: "0xFF0000FF"
}
```

## Performance Tips

1. **Use HLS streams** - More efficient than MPEG-TS
2. **Limit channels** - Filter/show only favorite channels
3. **Cache playlists** - Store M3U locally to avoid repeated downloads
4. **Increase timeout** - Set to 60 seconds for slow servers

## Resources

- 📖 [SGDEX Documentation](https://github.com/rokudev/SceneGraphDeveloperExtensions)
- 📘 [Roku Developer Guide](https://developer.roku.com/)
- 📚 [BrightScript Reference](https://sdkdocs.roku.com/display/sdkdoc/BrightScript+Reference)
- 🎬 [Scene Graph Development](https://developer.roku.com/en-GB/docs/developer-program/getting-started/architecture/roku-os-architecture.md)

## License

Copyright (c) 2024. All rights reserved.

## Support

Having issues?

1. Check **telnet debug output** for error messages
2. Verify **Stalker credentials** work manually
3. Confirm **network connectivity** from Roku to server
4. Check **firewall** settings
5. Review **SGDEX documentation** for framework-specific issues

## Contributing

Want to improve this project?

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

**Happy streaming! 🚀📺**
