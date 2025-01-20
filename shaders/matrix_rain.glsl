void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord/iResolution.xy;
    vec4 originalColor = texture(iChannel0, uv);
    
    // Digital rain effect
    float rain = fract(uv.y * 20.0 - mod(iTime + sin(uv.x * 10.0), 1.0));
    vec3 rainColor = vec3(0.0, rain * 0.8 + 0.2, 0.0);
    
    // Scanline effect
    float scanline = sin(uv.y * 800.0 + iTime * 5.0) * 0.1 + 0.9;
    
    // Preserve text readability
    float textMask = max(max(originalColor.r, originalColor.g), originalColor.b);
    vec4 finalColor = mix(
        vec4(rainColor * scanline, 1.0),
        originalColor,
        textMask
    );
    
    fragColor = finalColor;
}
