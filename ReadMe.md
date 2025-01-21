# Alpha Utility - Advanced YouTube Downloader
[![Version](https://img.shields.io/badge/version-0.0.1-blue.svg)](https://github.com/yourusername/alpha-utility)
[![Windows](https://img.shields.io/badge/platform-Windows-brightgreen.svg)](https://github.com/yourusername/alpha-utility)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

> A powerful, optimized command-line utility for downloading YouTube content with hardware acceleration and concurrent download support.

## 📖 Overview

Alpha Utility combines the power of yt-dlp and ytarchive with hardware acceleration support for optimal download performance. It features:

- 🎮 Interactive CLI interface
- 🚄 Hardware-accelerated processing
- 🔄 Concurrent download support
- 📺 Advanced live stream handling
- 🎵 Multi-format audio extraction
- 📦 Batch processing capabilities

## 🙏 Acknowledgments

This project integrates and builds upon several free and open-source tools:

- [yt-dlp](https://github.com/yt-dlp/yt-dlp): Provides advanced YouTube downloading capabilities, including format selection, playlist downloads, and more.
- [ytarchive](https://github.com/Kethsar/ytarchive): Enables robust live stream recording and archiving functionalities.
- [FFmpeg](https://ffmpeg.org/): Powers all media processing tasks, such as transcoding and audio extraction, and special thanks to pre-built binaries from [BtbN](https://github.com/BtbN/FFmpeg-Builds).
- [aria2](https://aria2.github.io/): Accelerates downloads with multi-connection support.

Special thanks to the maintainers of these projects for their invaluable work.


## Table of Contents

- [Quick Start](#-quick-start)
- [Project Setup](#-project-setup)
- [Features](#features)
- [System Requirements](#-system-requirements)
- [Installation](#installation)
- [Usage Guide](#usage-guide)
- [Hardware Acceleration](#hardware-acceleration)
- [Performance Optimizations](#performance-optimizations)
- [Advanced Features](#advanced-features)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [Credits](#credits)
- [License](#-license)

## 🚀 Quick Start

```batch
# 1. Download `Alpha_util.bat`
# 2. download dependencies in same directory as ALpha_util.bat
# 3. Run the script: `Alpha_util.bat`
```
## 📂 Project Setup

### Directory Structure
```
Alpha-Utility/
├── Alpha_util.bat                        # Main script
├── downloads/                            # Created automatically for downloaded content
├── ffmpeg executables & dll files        # FFmpeg dependencies
├── ffmpeg lib and include directories    # FFmpeg dependencies
├── yt-dlp executable                     # yt-dlp dependencies
├── ytarchive executable                  # ytarchive dependencies
├── aria2c executable                     # aria2c dependencies
├── Testing QA.md                         # Testing plan
└── README.md                             # This file
```

### Required External Tools
The following tools need to be downloaded and placed in your system PATH or in the same directory as `Alpha_util.bat`:

1. **Core Tools** (Required)
   - `yt-dlp.exe` - [Download from GitHub](https://github.com/yt-dlp/yt-dlp/releases)
   - `ffmpeg.exe`, `ffplay.exe`, `ffprobe.exe`, `*.dll`, `\lib\*`,`\include\*` - [Download from BtbN](https://github.com/BtbN/FFmpeg-Builds/releases)
   - `aria2c.exe` - [Download from aria2 website](https://github.com/aria2/aria2/releases)
   - `ytarchive.exe` - [Download from GitHub](https://github.com/Kethsar/ytarchive/releases)

2. **FFmpeg DLLs** (Required, same directory as ffmpeg.exe)
   - avcodec-*.dll
   - avdevice-*.dll
   - avfilter-*.dll
   - avformat-*.dll
   - avutil-*.dll
   - postproc-*.dll
   - swresample-*.dll
   - swscale-*.dll

## Features

### Core Features
- Interactive menu interface with detailed progress information
- Concurrent download support (multiple instances)
- Hardware-accelerated processing (NVIDIA, AMD, Intel)
- Optimized download engines (aria2c integration)
- Advanced live stream handling with ytarchive
- Instance-specific temporary storage
- Automatic hardware detection and optimization

### Download Capabilities
- Single/Multiple video downloads
- Playlist and channel archiving
- Live stream recording and archiving
- Audio extraction with multiple formats
- Batch processing support
- Member-only content support (with cookies)

### Quality and Format Options
- Adaptive quality selection
- Hardware-accelerated encoding
- Multiple container formats
- Custom format strings
- Quality fallback chains

## 💻 Compatibility

| Feature              | NVIDIA | AMD   | Intel | CPU-Only |
|---------------------|--------|-------|-------|----------|
| Hardware Encoding   | ✅     | ✅    | ✅    | ✅       |
| Live Stream Support | ✅     | ✅    | ✅    | ✅       |
| Concurrent Downloads| ✅     | ✅    | ✅    | ✅       |
| Memory Optimization | ✅     | ✅    | ✅    | ✅       |

## 📋 System Requirements

### Minimum Requirements
- Windows 10/11
- 4GB RAM
- 2GB free disk space
- Internet connection

### Recommended
- Windows 10/11
- 8GB RAM
- SSD with 10GB+ free space
- NVIDIA/AMD GPU or modern AMD/Intel CPU
- Broadband internet connection

### Required Software
| Software  | Version | Purpose |
|-----------|---------|---------|
| yt-dlp    | Latest  | Core download engine |
| FFmpeg    | Latest  | Media processing |
| aria2c    | Latest  | Download acceleration |
| ytarchive | Latest  | Live stream handling |

## Installation

1. Download the latest `Alpha_util.bat`
2. Install required tools:
   ```text
   # Using winget
   winget install yt-dlp
   winget install ffmpeg
   winget install aria2
   ```
3. Download ytarchive from its GitHub releases
4. Place all executables in the same directory or add to PATH

## Usage Guide

### Basic Operations

1. **Single Video Download**
   ```text
   1. Launch Alpha_util.bat
   2. Select Option 1 (Single Video)
   3. Choose Quality:
      - 1: Best (max resolution + best audio)
      - 2: 1080p (Full HD)
      - 3: 720p (HD)
   4. Paste video URL
   5. Wait for download to complete
   ```

2. **Audio Extraction**
   ```text
   1. Select Option 4 (Audio Only)
   2. Choose Format:
      - 1: MP3
      - 2: M4A (better quality)
      - 3: WAV (lossless)
      - 4: OPUS (compact size)
   3. Paste video URL
   ```

3. **Playlist Download**
   ```text
   1. Select Option 2 (Playlist)
   2. Choose Quality
   3. Paste playlist URL
   4. Optional: Specify range
      - Start number (e.g., 1)
      - End number (e.g., 10)
   ```

### Advanced Operations

1. **Live Stream Recording**
   ```text
   Method 1 - YTArchive (For Active Streams):
   1. Select Option 5
   2. Choose Method 1 (ytarchive)
   3. Select Quality (e.g., 1080p60)
   4. Choose Time Options:
      - 1: From Start
      - 2: From Specific Time
      - 3: Until Specific Time
      - 4: Time Range
      - 5: From Now
      - 6: Wait for Start

   Method 2 - YT-DLP (For VODs):
   1. Select Option 5
   2. Choose Method 2 (yt-dlp)
   3. Follow quality selection
   ```

2. **Channel Downloads**
   ```text
   Full Channel:
   1. Select Option 3
   2. Choose Quality
   3. Paste Channel URL
   4. Press Enter for all videos

   Limited Videos:
   1. Select Option 3
   2. Choose Quality
   3. Paste Channel URL
   4. Enter number of latest videos
   ```

### Hardware Acceleration Usage

1. **Enable/Configure Hardware Acceleration**
   ```text
   1. Select Option 19 (Hardware Acceleration)
   2. Choose:
      - 1: Auto-detect (recommended)
      - 2: Force CPU encoding
      - 3: Show hardware info
   ```

2. **Monitor Hardware Usage**
   ```text
   During downloads:
   - Check Task Manager
   - Monitor GPU usage
   - Watch CPU utilization
   - Check encoding speed
   ```

### Concurrent Download Examples

1. **Multiple Video Downloads**
   ```text
   Method 1 - Different Videos:
   1. Open multiple CMD windows
   2. Run Alpha_util.bat in each
   3. Download different videos

   Method 2 - Playlist Parts:
   1. Open multiple instances
   2. Use different playlist ranges
   Example:
   Instance 1: videos 1-10
   Instance 2: videos 11-20
   ```

### Special Features Usage

1. **Cookie-Protected Content**
   ```text
   1. Prepare cookies.txt file
   2. Place in same directory as script
   3. When downloading member content:
      - Script auto-detects cookies.txt
      - Select Y when prompted
   ```

2. **Custom Format Selection**
   ```text
   1. Select Option 6 (Custom Format)
   2. Enter format string:
      Example 1: bestvideo[height<=1080][vcodec^=avc1]+bestaudio/best
      Example 2: bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best
   ```

## ❗ Troubleshooting

### Common Issues and Solutions

#### Hardware Acceleration Not Working
```text
1. Check GPU drivers are up to date
2. Verify GPU is detected in Device Manager
3. Try running with --verbose flag
4. Check Task Manager for GPU usage
```

#### Slow Download Speeds
```text
1. Verify aria2c is properly installed
2. Check internet connection speed
3. Reduce concurrent downloads
4. Try different quality settings
```

#### Live Stream Issues
```text
1. Verify stream is actually live
2. Check cookies.txt for member streams
3. Try different quality fallbacks
4. Monitor disk space during recording
```

## 📊 Performance Tips

### Optimal Settings for Different Scenarios

#### High-Speed Downloads
```text
- Enable hardware acceleration
- Use aria2c (default)
- Set concurrent fragments to 5
- Use instance-specific temp dirs
```

#### Quality Priority
```text
- Use "Best" quality preset
- Enable VP9 when available
- Use hardware acceleration
- Monitor available formats
```

#### Resource Conservation
```text
- Limit concurrent downloads
- Use lower quality presets
- Disable thumbnail embedding
- Use CPU-only mode if needed
```

### Common Command Sequences
```text
Best Quality Video:
> 1 > 1 > [URL]
1080p Playlist:
> 2 > 2 > [URL]
Channel Latest 10:
> 3 > 1 > [URL] > 10
MP3 Audio:
> 4 > 1 > [URL]
Live Stream Best:
> 5 > 1 > best > [URL]
```

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Credits

Special thanks to the contributers of this projects for their invaluable work.

For detailed information about custom format strings, refer to the [yt-dlp documentation](https://github.com/yt-dlp/yt-dlp#format-selection).
For ytarchive features, visit [ytarchive documentation](https://github.com/Kethsar/ytarchive).
