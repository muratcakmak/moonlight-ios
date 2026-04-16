# OpenBench iOS

Open-source Mac-to-iPhone screen sharing client. Control your Mac from your iPhone with low-latency streaming.

Built on [Moonlight iOS](https://github.com/moonlight-stream/moonlight-ios), customized for screen sharing instead of game streaming.

## Features

- Stream your Mac desktop to iPhone over Wi-Fi
- Full touch control (tap to click, drag to move, two-finger scroll)
- On-screen keyboard with modifier toolbar (3-finger tap)
- Quick shortcuts: ⌘Tab, ⌘C, ⌘V, ⌘A, clipboard paste
- Auto-connect to Desktop on paired Mac
- Stats overlay (FPS, latency, codec)
- 1080p default, HEVC hardware decoding

## Requirements

- iPhone running iOS 18+
- Mac running [OpenBench Server (Lumen)](https://github.com/muratcakmak/Lumen)
- Both devices on the same Wi-Fi network

## Building

1. Clone: `git clone --recursive https://github.com/muratcakmak/moonlight-ios.git`
2. Open `Moonlight.xcodeproj` in Xcode
3. Set your signing team in Signing & Capabilities
4. Build and run on your iPhone

## Usage

1. Start OpenBench Server on your Mac
2. Open OpenBench on your iPhone
3. Tap your Mac to connect (first time requires PIN pairing)
4. 3-finger tap to toggle keyboard
5. Swipe from left edge to disconnect

## Server

Pair with [OpenBench Server (Lumen fork)](https://github.com/muratcakmak/Lumen) — a macOS streaming server with ScreenCaptureKit, VideoToolbox HEVC encoding, and system audio.

## License

BSD-3-Clause (inherited from Moonlight)
