# Flaschen Taschen Clients - Swift Port References

## Project Architecture

### Multi-Project Structure
- **ft-clients** (this project) - Command-line clients: send-image, send-text, send-video
- **ft-demos** (`../ft-demos`) - Visual demos using Flaschen Taschen display
- **Shared dependency:** FlaschenTaschenClientKit (in ft-clients)

### Consolidation Plan
1. FlaschenTaschenClientKit in ft-clients should contain all shared code currently in ft-demos/FlaschenTaschenKit
2. ft-demos will be reconfigured to depend on ft-clients as a Swift Package dependency
3. This eliminates code duplication and provides a single source of truth
4. ft-demos retains its demo-specific implementations (demo classes, animation loops, etc.)

### Code Migration
**From:** `/Users/brennan/Developer/FlaschenTaschen/ft-demos/Sources/FlaschenTaschenKit/`
**To:** `/Users/brennan/Developer/FlaschenTaschen/ft-clients/Sources/FlaschenTaschenClientKit/`

Files to migrate:
- FlaschenTaschenKit.swift → (parts into main module)
- ImageProcessing.swift → ImageProcessing.swift
- DrawingPrimitives.swift → DrawingPrimitives.swift
- Utilities.swift → Utilities.swift
- ColorPalettes.swift → ColorPalettes.swift (if applicable to clients)
- Logging.swift → Already in ft-clients

---

## Core Infrastructure

### UDP Communication (FlaschenTaschenClientKit)
**Reference:** `/Users/brennan/Developer/FT/flaschen-taschen/client/udp-flaschen-taschen.h/cc`
**Currently in:** `/Users/brennan/Developer/FlaschenTaschen/ft-demos/Sources/FlaschenTaschenKit/FlaschenTaschenKit.swift`
**Will be in:** `Sources/FlaschenTaschenClientKit/` (this project)

**Key components:**
- `Color` struct: RGB (UInt8 r, g, b)
- `UDPFlaschenTaschen` class:
  - Constructor: `init(fileDescriptor: Int32, width: Int, height: Int)`
  - `setPixel(x: Int, y: Int, color: Color)`
  - `getPixel(x: Int, y: Int) -> Color`
  - `setOffset(x: Int, y: Int, z: Int)` - z is layer (0-15)
  - `clear()` - Fill with black
  - `fill(color: Color)` - Fill with color
  - `send()` - Send PPM buffer via UDP
  - `clone() -> UDPFlaschenTaschen` - Create copy with same FD/dimensions

**Connection:**
- `openFlaschenTaschenSocket(hostname: String?) -> Int32`
  - Default host: `FT_DISPLAY` env var or "localhost"
  - Default port: 1337
  - Returns file descriptor for UDP socket

**PPM Format:**
- Header: `P6\n<width> <height>\n255\n`
- Pixel data: Raw RGB bytes (3 bytes per pixel)
- Footer: `\n<off_x> <off_y> <off_z>\n` (4-digit zero-padded offsets)

---

## send-image.swift

**Reference:** `/Users/brennan/Developer/FT/flaschen-taschen/client/send-image.cc`

### Command-line Arguments
```
-g <width>x<height>[+<off_x>+<off_y>[+<layer>]]  Output geometry (default: 45x35+0+0+0)
-l <layer>      Layer 0..15 (default: 0)
-h <host>       Flaschen-Taschen display hostname
-c              Center image in available space
-s[<ms>]        Scroll horizontally (optionally: delay ms; default 50)
-b<brightness>  Brightness percent (default: 100, range: 0-100)
-t<timeout>     Display duration in seconds
-C              Clear given area and exit
```

### Functionality

**Image Loading & Scaling:**
- Load image from file using `AppKit.NSImage` or similar
- Support still images (JPEG, PNG, etc.) and animated GIFs
- For animations: Handle frame sequence with `animationDelay` per frame
- Scale to fit display: Maintain aspect ratio, fit within width x height
- If scrolling: Calculate target_width based on aspect ratio (fit height only)

**Color Conversion:**
- Convert image pixels to RGB bytes with brightness factor
- Handle alpha channel: Skip fully transparent pixels (alpha >= 255)
- Brightness adjustment: `scaled_value = brightness_factor * original_value`

**Display Modes:**

1. **Animation Mode** (multi-frame or single frame):
   - Preprocess all frames into display buffers
   - Loop through frames with animation delay (in 1/100s of second, minimum 10)
   - Continue until timeout or interrupt

2. **Scrolling Mode** (single frame):
   - Extract horizontal scrolling window through image
   - Scroll one pixel at a time with delay_ms per frame
   - Loop until timeout or interrupt
   - Only valid for single-frame images

**Signal Handling:**
- Trap SIGTERM and SIGINT to set interrupt flag
- On interrupt: Clear display and exit cleanly

**Image Dimensions:**
- Default: 45x35
- Supports custom geometry with optional x/y/z offsets

---

## send-text.swift

**Reference:** `/Users/brennan/Developer/FT/flaschen-taschen/client/send-text.cc`

### Command-line Arguments
```
-g <width>x<height>[+<off_x>+<off_y>[+<layer>]]  Output geometry (default: 45x<font-height>)
-l <layer>      Layer 0..15 (default: 1)
-h <host>       Flaschen-Taschen display hostname
-f <fontfile>   Path to *.bdf font file
-i <textfile>   Read text from file ('-' for stdin)
-s<ms>          Scroll milliseconds per pixel (default: 50, negative: opposite direction)
-O              Only run once, don't scroll forever
-S<px>          Letter spacing in pixels (default: 0)
-c<RRGGBB>      Text color as hex (default: FFFFFF)
-b<RRGGBB>      Background color as hex (default: 000000)
-o<RRGGBB>      Outline color as hex (optional, no outline by default)
-v              Scroll text vertically
```

### Functionality

**Text Rendering:**
- Load BDF font file for glyph rendering
- Render text to bitmap with foreground/background colors
- Support optional outline color
- Calculate width based on text and font metrics

**Display Modes:**

1. **Horizontal Scrolling** (default):
   - Scroll text left-to-right one pixel per frame
   - Configurable delay per pixel (default: 50ms)
   - Negative delay scrolls opposite direction
   - Loop forever unless `-O` flag set

2. **Vertical Scrolling** (`-v` flag):
   - Scroll text top-to-bottom
   - Same delay and loop behavior

3. **Static Display** (scroll delay = 0):
   - Display text without scrolling
   - Only run once

**Text Input:**
- Command-line argument
- File input via `-i <file>`
- Stdin via `-i -`

**Letter Spacing:**
- Configurable pixel spacing between glyphs (default: 0)

**Default Layer:**
- Layer 1 (not 0 like send-image)

---

## send-video.swift

**Reference:** `/Users/brennan/Developer/FT/flaschen-taschen/client/send-video.cc`

### Command-line Arguments
```
-g <width>x<height>[+<off_x>+<off_y>[+<layer>]]  Output geometry
-h <host>       Flaschen-Taschen display hostname
-c              Center image in available space
-l <layer>      Layer 0..15
-t<timeout>     Playback duration in seconds
-b<brightness>  Brightness percent (default: 100, range: 0-100)
```

### Functionality

**Video Processing:**
- Read video file (MP4, AVI, etc.)
- Extract frames at appropriate rate
- Scale frames to fit display dimensions
- Optionally center within available space
- Apply brightness adjustment

**Frame Display:**
- Continuous playback at video's native frame rate
- Send frames to display
- Continue until timeout or all frames consumed

**Key Differences from send-image:**
- No scrolling mode
- No GIF animation mode
- Source is video file instead of still/animated image
- Frame rate comes from video metadata

---

## Implementation Notes

### Async/Await Pattern
All executables use async main entry point:
```swift
@main
struct SendImage {
    static func main() async {
        // Implementation
    }
}
```

### Logging
- Use `os.log` with `Logger(subsystem: Logging.subsystem, category: "category")`
- Logging.subsystem = `Bundle.main.bundleIdentifier ?? "com.flaschen-taschen.clients"`

### Signal Handling
- Swift Concurrency doesn't provide built-in signal handling
- May need to use `Darwin.signal()` with C interop
- Alternative: Use DispatchSourceSignal or periodic checks with timeout

### Image/Video Processing
- macOS: Use `AppKit.NSImage`, `AVFoundation` for images and video
- Consider third-party Swift packages for broader format support
- BDF font parsing needed for send-text

### Memory Management
- FFmpeg or similar may be needed for video decoding
- Image processing should avoid excessive allocations in loops
- PPM buffer is relatively small (45x35x3 = ~4.7KB typical)

### Cross-platform Considerations
- Currently targeting macOS 15+
- Socket code uses Darwin APIs (should be portable to Linux with changes)
- File paths and environment variables are portable

### Dependencies Needed
- **Image processing:** AppKit.NSImage for image loading (macOS only, may need cross-platform alternative)
- **Video decoding:** AVFoundation for video frame extraction (macOS specific)
- **Font handling:** BDF font parser for send-text (may need custom implementation)
- **Concurrency:** Swift async/await with Darwin.signal for interrupt handling
- **Date/Time:** Foundation for timeout tracking
