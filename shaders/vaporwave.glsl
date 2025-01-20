void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord/iResolution.xy;
    vec4 originalColor = texture(iChannel0, uv);
    
    // Grid effect
    vec2 gridUV = uv * vec2(30.0, 15.0);
    gridUV.y += iTime * 0.5;
    vec2 gv = fract(gridUV) - 0.5;
    float grid = smoothstep(0.45, 0.55, abs(gv.x)) + smoothstep(0.45, 0.55, abs(gv.y));
    grid *= 0.5;
    
    // Chromatic aberration
    float offset = sin(iTime * 0.5) * 0.003;
    vec4 rChannel = texture(iChannel0, uv + vec2(offset, 0.0));
    vec4 bChannel = texture(iChannel0, uv - vec2(offset, 0.0));
    
    // Vaporwave colors
    vec3 vaporColor = mix(
        vec3(0.8, 0.2, 0.8),  // Hot pink
        vec3(0.2, 0.8, 0.8),  // Cyan
        sin(uv.x * 3.14159 + iTime) * 0.5 + 0.5
    );
    
    // Combine effects
    vec4 distortedColor = vec4(
        rChannel.r,
        originalColor.g,
        bChannel.b,
        1.0
    );
    
    // Add scanlines
    float scanline = sin(uv.y * 200.0) * 0.1 + 0.9;
    
    // Preserve text readability
    float textMask = max(max(originalColor.r, originalColor.g), originalColor.b);
    vec4 finalColor = mix(
        vec4(mix(vaporColor, distortedColor.rgb, 0.7) * (1.0 - grid) * scanline, 1.0),
        originalColor,
        textMask
    );
    
    fragColor = finalColor;
}
