void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord/iResolution.xy;
    vec4 originalColor = texture(iChannel0, uv);
    
    // Create plasma effect
    float time = iTime * 0.5;
    vec2 p = (uv * 2.0 - 1.0) * 2.0;
    float plasma = sin(p.x * 10.0 + time) + 
                  sin(p.y * 10.0 + time) +
                  sin(sqrt(p.x * p.x + p.y * p.y) * 10.0) +
                  sin(sqrt(p.x * p.x * p.y * p.y) * 5.0);
    
    // Create color waves
    vec3 plasmaColor;
    plasmaColor.r = sin(plasma * 1.1 + time) * 0.5 + 0.5;
    plasmaColor.g = sin(plasma * 1.2 + time * 1.1) * 0.5 + 0.5;
    plasmaColor.b = sin(plasma * 1.3 + time * 1.2) * 0.5 + 0.5;
    
    // Add some movement
    vec2 distortion = vec2(
        sin(uv.y * 4.0 + time) * 0.01,
        cos(uv.x * 4.0 + time) * 0.01
    );
    vec4 distortedColor = texture(iChannel0, uv + distortion);
    
    // Preserve text readability
    float textMask = max(max(originalColor.r, originalColor.g), originalColor.b);
    vec4 finalColor = mix(
        vec4(plasmaColor * 0.4 + distortedColor.rgb * 0.6, 1.0),
        originalColor,
        textMask
    );
    
    fragColor = finalColor;
}
