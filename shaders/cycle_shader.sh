#!/bin/bash

CONFIG_FILE="$HOME/.config/ghostty/config"
SHADER_DIR="$HOME/.config/ghostty/shaders"

# Get list of all .glsl shaders, excluding the current script
mapfile -t SHADERS < <(find "$SHADER_DIR" -name "*.glsl" -type f -exec basename {} \; | sort)

if [ ${#SHADERS[@]} -eq 0 ]; then
    echo "No shaders found in $SHADER_DIR"
    exit 1
fi

# Get current shader
current_shader=$(grep -v '^#' "$CONFIG_FILE" | grep 'custom-shader.*glsl' | sed 's/.*\/\([^/]*\)$/\1/')

# Find current index
current_index=-1
for i in "${!SHADERS[@]}"; do
    if [[ "${SHADERS[$i]}" == "$current_shader" ]]; then
        current_index=$i
        break
    fi
done

# If no shader is currently active, start with index -1
if [[ $current_index -eq -1 ]]; then
    current_index=$(( ${#SHADERS[@]} - 1 ))
fi

# Calculate next index based on direction
if [[ "$1" == "next" ]]; then
    next_index=$(( (current_index + 1) % ${#SHADERS[@]} ))
elif [[ "$1" == "prev" ]]; then
    next_index=$(( (current_index - 1 + ${#SHADERS[@]}) % ${#SHADERS[@]} ))
elif [[ "$1" == "list" ]]; then
    echo "Available shaders:"
    for i in "${!SHADERS[@]}"; do
        if [[ "${SHADERS[$i]}" == "$current_shader" ]]; then
            echo "* ${SHADERS[$i]} (active)"
        else
            echo "  ${SHADERS[$i]}"
        fi
    done
    exit 0
else
    echo "Usage: $0 [next|prev|list]"
    exit 1
fi

# Update config file
sed -i 's/^custom-shader.*$/#&/' "$CONFIG_FILE"  # Comment out all shader lines
sed -i "s|#custom-shader = ~/.config/ghostty/shaders/${SHADERS[$next_index]}|custom-shader = ~/.config/ghostty/shaders/${SHADERS[$next_index]}|" "$CONFIG_FILE"

# Print the new active shader and hint about restarting
echo "Activated shader: ${SHADERS[$next_index]}"
echo "Restart Ghostty to apply the new shader"
