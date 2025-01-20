void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord/iResolution.xy;
    vec4 originalColor = texture(iChannel0, uv);
    
    // Create cityscape effect
    float time = iTime * 0.5;
    
    // Generate buildings
    vec2 buildingUV = uv * vec2(8.0, 4.0);
    buildingUV.y += time * 0.2;
    vec2 buildingCell = fract(buildingUV);
    float buildings = step(0.8, buildingCell.x) + step(0.8, buildingCell.y);
    
    // Create neon signs
    vec2 neonUV = uv * vec2(5.0, 3.0);
    float neon = sin(neonUV.x * 10.0 + time) * sin(neonUV.y * 8.0 - time);
    
    // Cyberpunk colors
    vec3 cityColor;
    cityColor.r = 0.8 + 0.2 * sin(time + uv.x * 5.0);
    cityColor.g = 0.2 + 0.2 * sin(time * 1.1 + uv.y * 4.0);
    cityColor.b = 0.6 + 0.4 * sin(time * 0.9 + neon);
    
    // Add scanlines and glitch
    float scanline = sin(uv.y * 100.0 + time * 5.0) * 0.1 + 0.9;
    float glitch = step(0.98, sin(time * 50.0)) * step(0.5, sin(uv.y * 100.0));
    vec2 glitchOffset = vec2(glitch * 0.02 * sin(time * 100.0), 0.0);
    
    // Sample with effects
    vec4 distortedColor = texture(iChannel0, uv + glitchOffset);
    
    // Add building lights and neon glow
    float lights = buildings * 0.2 + abs(neon) * 0.3;
    
    // Preserve text readability
    float textMask = max(max(originalColor.r, originalColor.g), originalColor.b);
    vec4 finalColor = mix(
        vec4(cityColor * (0.6 + lights) * scanline + distortedColor.rgb * 0.4, 1.0),
        originalColor,
        textMask
    );
    
    fragColor = finalColor;
}
