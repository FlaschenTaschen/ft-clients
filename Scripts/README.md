# Flaschen Taschen Client Scripts

Convenience wrapper scripts for the Flaschen Taschen Swift clients with sensible defaults.

## Default Configuration

All scripts use the following defaults:
- **Host**: `localhost` (can be overridden with `-h <host>`)
- **Geometry**: `45x35+0+0+6` (45×35 pixels on layer 6)
- **Location**: Layer 6 (allows layers 0-5 for background content)

## Usage

### send-text.sh

Display scrolling text on the display.

```bash
# With font file and text input
./send-text.sh -f /path/to/font.bdf "Hello World"

# From a file
./send-text.sh -f /path/to/font.bdf -i message.txt

# From stdin
echo "Dynamic text" | ./send-text.sh -f /path/to/font.bdf -i -

# Custom options (override defaults)
./send-text.sh -g 100x50+10+10+3 -f font.bdf "Custom"

# Different host
./send-text.sh -h 192.168.1.100 -f font.bdf "Remote display"

# Static display (no scrolling)
./send-text.sh -s0 -f font.bdf "Static text"

# Vertical scrolling
./send-text.sh -v -f font.bdf "Vertical"

# With outline
./send-text.sh -f font.bdf -o FF0000 "Red outline"
```

### send-image.sh

Display images on the display.

```bash
# Simple image display
./send-image.sh image.jpg

# With scrolling
./send-image.sh -s50 image.png

# Centered in available space
./send-image.sh -c photo.jpg

# Custom brightness
./send-image.sh -b50 dark-image.jpg

# With timeout (display for 10 seconds)
./send-image.sh -t10 image.jpg

# Animated GIF
./send-image.sh animation.gif

# Custom geometry
./send-image.sh -g 100x100+0+0+2 large-image.png

# Different host
./send-image.sh -h 192.168.1.100 image.jpg
```

### send-video.sh

Play videos on the display.

```bash
# Simple video playback
./send-video.sh video.mp4

# Centered video
./send-video.sh -c video.mov

# With brightness adjustment
./send-video.sh -b80 video.mp4

# Limited playback (30 seconds)
./send-video.sh -t30 video.mp4

# Custom dimensions
./send-video.sh -g 90x70+0+0+4 video.mp4

# Different host
./send-video.sh -h 192.168.1.100 video.mp4
```

## Building

Before using the scripts, build the project:

```bash
cd /Users/brennan/Developer/FlaschenTaschen/ft-clients
swift build
```

The scripts will automatically find the built executables in `.build/debug/`.

## Overriding Defaults

Each script detects if you've specified `-g` or `-h` flags and skips the defaults for those options:

```bash
# Geometry override (uses your -g, ignores default 45x35+0+0+6)
./send-text.sh -g 100x50+10+10+10 -f font.bdf "Custom geometry"

# Host override (uses your -h, ignores default localhost)
./send-image.sh -h 192.168.1.50 image.jpg

# Multiple overrides
./send-video.sh -h remote-host -g 60x60+5+5+8 video.mp4
```

## Font Files

For send-text.sh, you'll need a BDF font file. Some example fonts are available in the C++ reference:

```bash
/Users/brennan/Developer/FT/flaschen-taschen/client/fonts/
```

Available fonts:
- `5x5.bdf` - Very small (5×5 pixels)
- `5x7.bdf` - Small (5×7 pixels)
- `7x13.bdf` - Medium (7×13 pixels)
- `8x13B.bdf` - Medium bold (8×13 pixels)

## Examples

### Text Examples

```bash
# Simple text message
./send-text.sh -f /Users/brennan/Developer/FT/flaschen-taschen/client/fonts/7x13.bdf "Hello!"

# Status message with outline
./send-text.sh -f /path/to/font.bdf \
  -c FFFFFF -b 000000 -o FF0000 \
  "Status: OK"

# Temperature display
echo "23°C" | ./send-text.sh -f /path/to/font.bdf -i -
```

### Image Examples

```bash
# Display JPEG with scaling
./send-image.sh -c photo.jpg

# Animated GIF
./send-image.sh animation.gif

# Brightness-adjusted image
./send-image.sh -b75 sunset.png
```

### Video Examples

```bash
# Display video clip
./send-video.sh clip.mp4

# Short video with brightness
./send-video.sh -b90 -t5 intro.mp4
```

## Troubleshooting

### "executable not found" error

Make sure you've built the project:
```bash
swift build
```

### Connection refused

Verify the Flaschen Taschen display is running:
```bash
# Default localhost
./send-text.sh -f font.bdf "Test"

# Or specify a different host
./send-text.sh -h display-hostname -f font.bdf "Test"
```

### Display appears frozen or unresponsive

- Check the layer number (default is 6) - make sure it's not blocked
- Try a different layer: `-g 45x35+0+0+0`
- Verify connection with a simple test image

## Script Architecture

Each script:
1. Locates the compiled executable in `.build/debug/`
2. Applies default parameters (geometry and hostname)
3. Allows user parameters to override defaults
4. Executes the client with combined parameters

This approach keeps the scripts lightweight and easy to understand.
