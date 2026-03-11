# Flaschen Taschen Clients

Swift implementations of Flaschen Taschen display clients for sending text, images, and video to a Flaschen Taschen LED matrix display.

## Building

```bash
swift build
```

Executables will be located in `.build/debug/`:
- `send-text` - Display scrolling or static text
- `send-image` - Display still images or animated GIFs
- `send-video` - Display video files with looping support

## Display Setup

By default, clients connect to `localhost:1337`. To connect to a different display, set the hostname:

```bash
# Via -h flag
./send-text -h display.local "Hello World"

# Via environment variable (default)
export FT_DISPLAY=display.local
./send-text "Hello World"
```

## send-text

Display text on the display with optional scrolling and styling.

### Basic Usage

```bash
# Static text
.build/debug/send-text "Hello World"

# Scrolling text (default scroll speed: 50ms)
.build/debug/send-text -s "Scrolling text"

# Scrolling with custom speed (milliseconds per frame)
.build/debug/send-text -s100 "Slow scroll"
.build/debug/send-text -s20 "Fast scroll"

# No scroll (static)
.build/debug/send-text -s0 "Static text"

# Vertical scrolling
.build/debug/send-text -v "Vertical text"

# Centered on display
.build/debug/send-text -c "Centered"

# With custom font
.build/debug/send-text -f fonts/5x7.bdf "Custom font"

# With outline
.build/debug/send-text -O FF0000 "Red outline"
```

### Command-Line Options

```
-g WxH[+X+Y[+Z]]    Output geometry (default: 45x35+0+0+0)
-h <host>           Display hostname
-f <font>           BDF font file path
-i <color>          Text color as hex RRGGBB (default: FFFFFF)
-s[ms]              Scroll speed in milliseconds (0=static, default=50)
-S <speed>          Letter spacing in pixels
-c                  Center text in available space
-b<brightness>      Brightness 0-100% (default: 100)
-o <color>          Outline color as hex RRGGBB
-l <layer>          Layer 0-15 (default: 0)
-O <color>          Outline color (alternate flag)
-v                  Vertical scrolling mode
-t<timeout>         Display timeout in seconds
```

### Examples

```bash
# Display name with custom color
.build/debug/send-text -i00FF00 "Flaschen Taschen"

# Red text with yellow outline
.build/debug/send-text -i FF0000 -o FFFF00 "Alert"

# Scrolling at 2 layers with 75% brightness
.build/debug/send-text -l 2 -b75 -s "Important"

# Display for 10 seconds then exit
.build/debug/send-text -t10 "Temporary"
```

## send-image

Display images and animated GIFs on the display.

### Basic Usage

```bash
# Display static image
.build/debug/send-image image.png

# Display animated GIF
.build/debug/send-image animation.gif

# Scrolling image (default: 50ms per frame)
.build/debug/send-image -s image.png

# Static display (no scroll)
.build/debug/send-image -s0 image.png

# Centered with reduced brightness
.build/debug/send-image -c -b50 image.png
```

### Command-Line Options

```
-g WxH[+X+Y[+Z]]    Output geometry (default: 45x35+0+0+0)
-h <host>           Display hostname
-l <layer>          Layer 0-15 (default: 0)
-c                  Center image in available space
-s[ms]              Scroll speed in milliseconds (0=static, default=50)
-b<brightness>      Brightness 0-100% (default: 100)
-t<timeout>         Display timeout in seconds
-C                  Clear display and exit (no image)
```

### Examples

```bash
# Display with 75% brightness at offset position
.build/debug/send-image -g 45x35+5+10 -b75 photo.jpg

# Scrolling GIF with custom layer
.build/debug/send-image -l 1 -s80 animation.gif

# Display for 30 seconds then clear
.build/debug/send-image -t30 image.png
```

## send-video

Display video files with automatic looping support.

### Basic Usage

```bash
# Display video (loops until timeout)
.build/debug/send-video video.mp4

# Display for 30 seconds (video loops during this time)
.build/debug/send-video -t30 video.mp4

# Centered with 80% brightness
.build/debug/send-video -c -b80 video.mp4
```

### Command-Line Options

```
-g WxH[+X+Y[+Z]]    Output geometry (default: 45x35+0+0+0)
-h <host>           Display hostname
-l <layer>          Layer 0-15 (default: 0)
-c                  Center video in available space
-b<brightness>      Brightness 0-100% (default: 100)
-t<timeout>         Playback timeout in seconds (loops until timeout)
```

### Examples

```bash
# Display video with custom size and layer
.build/debug/send-video -g 90x70+0+0+1 video.mp4

# Loop for 2 minutes at 60% brightness
.build/debug/send-video -t120 -b60 video.mp4

# Display at specific offset
.build/debug/send-video -g 45x35+10+5 -b100 clip.mp4
```

### Looping Behavior

Videos automatically loop until the timeout is reached. Looping is logged to stderr:

```
End of stream reached at loop 1 after 120 frames
Completed loop 1 with 120 frames, starting loop 2
```

## Geometry Format

All clients use the same geometry format for sizing and positioning:

```
WxH[+X+Y[+Z]]

W, H    Output width and height in pixels
X, Y    Offset position (default: 0, 0)
Z       Layer 0-15 (default: 0, note: -l flag overrides this)

Examples:
45x35         45×35 at position 0,0
45x35+10+5    45×35 at position 10,5
45x35+0+0+2   45×35 at position 0,0 on layer 2
```

## Color Format

Colors are specified as hexadecimal RGB values:

```
RRGGBB

RR, GG, BB    Hex values 00-FF (0-255)

Examples:
FF0000        Red
00FF00        Green
0000FF        Blue
FFFF00        Yellow
FFFFFF        White
000000        Black
```

## Font Files

The `send-text` client uses BDF (Bitmap Distribution Format) font files. Supply your own with the `-f` flag:

```bash
.build/debug/send-text -f /path/to/font.bdf "Text"
```

## Troubleshooting

### Video displays as random colors

Ensure the display is connected and the hostname is correct:
```bash
.build/debug/send-video -h <display_hostname> video.mp4
```

### Text is cut off

Increase the output geometry width:
```bash
.build/debug/send-text -g 90x35 "Long text"
```

### Image quality looks pixelated

Images are scaled to fit the display size. Use centered display with aspect ratio preservation (default):
```bash
.build/debug/send-image -c image.png
```

### Display shows nothing

Check the hostname and port (default localhost:1337):
```bash
export FT_DISPLAY=<your_display_ip>
.build/debug/send-text "Test"
```

## Architecture

- **FlaschenTaschenClientKit**: Core library with UDP communication, image/video processing, and display utilities
- **send-text**: Text rendering with BDF font support
- **send-image**: Image loading and scaling with GIF animation support
- **send-video**: Video decoding with frame-by-frame playback and automatic looping

All clients support:
- Brightness adjustment
- Layer-based rendering
- Custom geometry/positioning
- Signal handling for clean shutdown (SIGINT/SIGTERM)
