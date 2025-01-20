void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Get the original pixel color from the terminal
    vec2 uv = fragCoord/iResolution.xy;
    vec4 originalColor = texture(iChannel0, uv);
    
    // Create wave distortion
    float wave = sin(uv.y * 10.0 + iTime) * 0.005;
    wave += cos(uv.x * 8.0 + iTime * 0.7) * 0.005;
    
    // Sample the terminal with the wave distortion
    vec2 distortedUV = uv + vec2(wave);
    vec4 distortedColor = texture(iChannel0, distortedUV);
    
    // Create rainbow effect
    vec3 rainbow;
    rainbow.r = 0.5 + 0.5 * sin(iTime + uv.x * 6.28);
    rainbow.g = 0.5 + 0.5 * sin(iTime * 1.2 + uv.x * 6.28);
    rainbow.b = 0.5 + 0.5 * sin(iTime * 0.8 + uv.x * 6.28);
    
    // Mix the distorted color with the rainbow effect
    // Keep text readable by preserving original color where there's text
    float textMask = max(max(originalColor.r, originalColor.g), originalColor.b);
    vec4 finalColor = mix(
        vec4(rainbow * 0.3 + distortedColor.rgb * 0.7, 1.0),
        originalColor,
        textMask
    );
    
    fragColor = finalColor;
}
