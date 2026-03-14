#!/bin/bash
# send-image.sh - Display image on Flaschen Taschen display
# Usage: ./send-image.sh [options] <image-file>
# Default: localhost, 45x35 geometry, layer 5

set -e

# Build directory
BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.build/debug"
SEND_IMAGE="$BUILD_DIR/send-image"

# Check if executable exists
if [ ! -f "$SEND_IMAGE" ]; then
    echo "Error: send-image executable not found at $SEND_IMAGE"
    echo "Run 'swift build' first"
    exit 1
fi

# Default parameters
GEOMETRY="45x35"
HOSTNAME="localhost"
LAYER="5"
TIMEOUT="60"

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
        -t*)
            # User specified timeout, don't override
            TIMEOUT=""
            ARGS+=("$arg")
            ;;
        *)
            ARGS+=("$arg")
            ;;
    esac
done

# Build final command
CMD="$SEND_IMAGE"
if [ -n "$GEOMETRY" ]; then
    CMD="$CMD -g $GEOMETRY"
fi
if [ -n "$HOSTNAME" ]; then
    CMD="$CMD -h $HOSTNAME"
fi
if [ -n "$LAYER" ]; then
    CMD="$CMD -l $LAYER"
fi
if [ -n "$TIMEOUT" ]; then
    CMD="$CMD -t $TIMEOUT"
fi
CMD="$CMD ${ARGS[@]}"

echo $CMD
exec $CMD && echo "Sent image"
