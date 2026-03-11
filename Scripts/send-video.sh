#!/bin/bash
# send-video.sh - Play video on Flaschen Taschen display
# Usage: ./send-video.sh [options] <video-file>
# Default: localhost, 45x35 geometry, layer 5

set -e

# Build directory
BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.build/debug"
SEND_VIDEO="$BUILD_DIR/send-video"

# Check if executable exists
if [ ! -f "$SEND_VIDEO" ]; then
    echo "Error: send-video executable not found at $SEND_VIDEO"
    echo "Run 'swift build' first"
    exit 1
fi

# Default parameters
GEOMETRY="45x35"
HOSTNAME="localhost"
LAYER="5"

# Parse arguments to find -g, -h, -l flags
ARGS=()
for arg in "$@"; do
    case "$arg" in
        -g*)
            # User specified geometry, don't override
            GEOMETRY=""
            ARGS+=("$arg")
            ;;
        -h*)
            # User specified hostname
            HOSTNAME=""
            ARGS+=("$arg")
            ;;
        -l*)
            # User specified layer, don't override
            LAYER=""
            ARGS+=("$arg")
            ;;
        *)
            ARGS+=("$arg")
            ;;
    esac
done

# Build final command
CMD="$SEND_VIDEO"
if [ -n "$GEOMETRY" ]; then
    CMD="$CMD -g $GEOMETRY"
fi
if [ -n "$HOSTNAME" ]; then
    CMD="$CMD -h $HOSTNAME"
fi
if [ -n "$LAYER" ]; then
    CMD="$CMD -l $LAYER"
fi
CMD="$CMD ${ARGS[@]}"

exec $CMD
