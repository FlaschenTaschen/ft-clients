# Flaschen Taschen Clients - Project Requirements & Plan

## Overview
Port three command-line clients (send-text, send-image, send-video) from C++ to Swift, targeting macOS and iOS. Create a shared `FlaschenTaschenClientKit` framework that provides core display functionality for both clients and demos.

See `References.md` for detailed technical specifications and C++ reference implementations.

## Project Constraints
- **Platforms:** macOS 15+ and iOS (exact version TBD)
- **Dependencies:** Cross-platform Apple frameworks only (Foundation, Darwin, etc.)
  - ❌ NO AppKit (macOS-only)
  - ❌ NO UIKit (iOS requires SwiftUI)
  - ✅ Foundation, Darwin, Combine, async/await
- **Package Management:** Swift Package Manager (SPM)
- **Architecture:**
  - ft-clients: Contains clients and shared FlaschenTaschenClientKit
  - ft-demos: Will depend on ft-clients as an SPM dependency
  - Shared code: FlaschenTaschenClientKit (no duplication)

## Deliverables

### Phase 1: Core Framework (FlaschenTaschenClientKit)
**Status:** Not started

Migrate and consolidate code from ft-demos/FlaschenTaschenKit:

#### 1.1 UDP Communication Layer
- `Color` struct (RGB: UInt8 r, g, b)
- `UDPFlaschenTaschen` class with:
  - PPM format buffer management
  - Pixel manipulation (setPixel, getPixel)
  - Offset management (x, y, z layer)
  - UDP socket transmission
  - Buffer cloning for multi-frame scenarios
- `openFlaschenTaschenSocket(hostname: String?) -> Int32`
  - Host resolution with getaddrinfo
  - UDP socket creation and connection
  - Environment variable support (FT_DISPLAY)
  - Default: localhost:1337

**Files to create:**
- `Sources/FlaschenTaschenClientKit/FlaschenTaschenClientKit.swift` (core types)
- `Sources/FlaschenTaschenClientKit/Socket.swift` (connection handling)

#### 1.2 Image Processing Utilities
Migrate from ft-demos:
- Blur algorithms (blur3, blurFire)
- Pixel decay operations
- Color conversion utilities

**Files to create:**
- `Sources/FlaschenTaschenClientKit/ImageProcessing.swift`

#### 1.3 Logging Infrastructure
- Already exists: `Sources/FlaschenTaschenClientKit/Logging.swift`
- Uses `os.log` with consistent subsystem

### Phase 2: SendText Client
**Status:** Not started

Command-line tool for scrolling text on Flaschen Taschen display.

#### 2.1 BDF Font Parsing
- Research available Swift BDF parsers
- If unavailable, port BDF parser from C++ implementation
- Support glyph rendering and metrics

**Files to create:**
- `Sources/FlaschenTaschenClientKit/BDFFont.swift` (if custom parser needed)
- OR use existing package (TBD)

#### 2.2 Text Rendering
- Render text to bitmap with color support
- Support foreground, background, and outline colors
- Calculate text dimensions based on font metrics
- Letter spacing support

**Files to create:**
- `Sources/FlaschenTaschenClientKit/TextRenderer.swift`

#### 2.3 SendText Executable
- Command-line argument parsing:
  - `-g` geometry (WxH[+X+Y[+Z]])
  - `-h` hostname
  - `-f` font file path
  - `-i` text input (file or stdin)
  - `-s` scroll speed (ms/pixel)
  - `-O` single run (no loop)
  - `-S` letter spacing
  - `-c` text color (hex)
  - `-b` background color (hex)
  - `-o` outline color (hex)
  - `-v` vertical scrolling
  - `-l` layer (0-15, default 1)

- Display modes:
  - Horizontal scrolling (default)
  - Vertical scrolling (`-v`)
  - Static (scroll speed = 0)

- Signal handling:
  - SIGTERM, SIGINT → graceful shutdown

**Files to create:**
- `Sources/send-text/SendText.swift`
- `Sources/send-text/TextCommandLine.swift` (argument parsing)
- `Sources/send-text/TextDisplayController.swift` (display logic)

### Phase 3: SendImage Client
**Status:** Not started

Command-line tool for displaying images on Flaschen Taschen display.

#### 3.1 Image Loading & Processing
- Load image files (JPEG, PNG, GIF, HEIF, etc.)
- Decode animated GIFs frame-by-frame
- Scale images while maintaining aspect ratio
- Apply brightness adjustment
- Convert pixels to RGB with alpha channel handling

**Files to create:**
- `Sources/FlaschenTaschenClientKit/ImageLoader.swift`

#### 3.2 SendImage Executable
- Command-line argument parsing:
  - `-g` geometry (default: 45x35)
  - `-h` hostname
  - `-l` layer (0-15, default 0)
  - `-c` center image
  - `-s[ms]` horizontal scroll (optional delay, default 50ms)
  - `-b` brightness percent (0-100, default 100)
  - `-t` timeout (seconds)
  - `-C` clear screen only

- Display modes:
  - Animation (multi-frame GIFs)
  - Scrolling (single frame)
  - Static (single frame, no scroll)

- Signal handling:
  - SIGTERM, SIGINT → clear display and exit

**Files to create:**
- `Sources/send-image/SendImage.swift`
- `Sources/send-image/ImageCommandLine.swift` (argument parsing)
- `Sources/send-image/ImageDisplayController.swift` (display logic)

### Phase 4: SendVideo Client
**Status:** Not started

Command-line tool for playing video on Flaschen Taschen display.

#### 4.1 Video Frame Extraction
- Decode video files (MP4, MOV, AVI, etc.)
- Extract frames at video's native frame rate
- Scale frames to display dimensions
- Apply brightness adjustment

**Dependencies needed:** TBD (cross-platform video decoding)
- Evaluate options that support iOS and macOS
- Possible: AVFoundation (investigate iOS availability)
- Alternatives: ffmpeg bindings (if available cross-platform)

**Files to create:**
- `Sources/FlaschenTaschenClientKit/VideoDecoder.swift` (or similar)

#### 4.2 SendVideo Executable
- Command-line argument parsing:
  - `-g` geometry
  - `-h` hostname
  - `-l` layer
  - `-c` center
  - `-b` brightness
  - `-t` timeout

- Display:
  - Continuous frame playback at video's native frame rate
  - Respect timeout limit

**Files to create:**
- `Sources/send-video/SendVideo.swift`
- `Sources/send-video/VideoCommandLine.swift` (argument parsing)
- `Sources/send-video/VideoDisplayController.swift` (display logic)

## Implementation Strategy

### Code Organization
```
Sources/
├── FlaschenTaschenClientKit/
│   ├── FlaschenTaschenClientKit.swift     # Public exports
│   ├── Socket.swift                        # UDP socket handling
│   ├── ImageProcessing.swift               # Blur, decay, pixel ops
│   ├── TextRenderer.swift                  # Text rendering (Phase 2)
│   ├── BDFFont.swift                       # BDF parser (Phase 2)
│   ├── ImageLoader.swift                   # Image loading (Phase 3)
│   ├── VideoDecoder.swift                  # Video decoding (Phase 4)
│   └── Logging.swift                       # Logging (exists)
├── send-text/
│   ├── SendText.swift                      # @main entry point
│   ├── TextCommandLine.swift               # Arg parsing
│   └── TextDisplayController.swift         # Display logic
├── send-image/
│   ├── SendImage.swift                     # @main entry point
│   ├── ImageCommandLine.swift              # Arg parsing
│   └── ImageDisplayController.swift        # Display logic
└── send-video/
    ├── SendVideo.swift                     # @main entry point
    ├── VideoCommandLine.swift              # Arg parsing
    └── VideoDisplayController.swift        # Display logic
```

### Cross-Platform Compatibility Notes

#### Image Loading
- Cannot use AppKit.NSImage (macOS only)
- Options:
  - `ImageIO` framework - Available on both iOS and macOS
  - Decode manually with Foundation data APIs
  - Investigate Swift image libraries that support both platforms

#### Video Decoding
- Cannot use AVFoundation AVPlayer (UIKit-dependent on iOS)
- Options:
  - Investigate iOS compatibility of AVFoundation video decoding APIs
  - ffmpeg with proper Swift bindings
  - Alternative video decoding libraries

#### Font Rendering
- BDF font parsing - Platform independent
- Glyph rendering to bitmap - Manual pixel manipulation (platform independent)

## Testing Strategy
- Unit tests for core components (Color, UDPFlaschenTaschen, ImageProcessing)
- Integration tests with mock display server
- Manual testing with actual Flaschen Taschen hardware

## Migration Path for ft-demos
After FlaschenTaschenClientKit is complete:
1. Update ft-demos Package.swift to depend on ft-clients
2. Replace ft-demos/FlaschenTaschenKit imports with FlaschenTaschenClientKit
3. Remove duplicate code from ft-demos/Sources/FlaschenTaschenKit/
4. Keep demo-specific code (Demo classes, AnimationLoop, etc.)

## Success Criteria
- ✅ All three clients compile and run on macOS 15+
- ✅ iOS compatibility confirmed (builds without AppKit/UIKit)
- ✅ Command-line arguments match C++ behavior
- ✅ Display output matches original C++ clients
- ✅ Graceful shutdown on signals
- ✅ ft-demos depends on ft-clients successfully
- ✅ Code is maintainable and extensible
