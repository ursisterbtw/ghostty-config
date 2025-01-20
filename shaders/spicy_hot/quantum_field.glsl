void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord/iResolution.xy;
    vec4 originalColor = texture(iChannel0, uv);
    
    // Create quantum field effect
    float time = iTime * 0.3;
    vec2 p = (uv * 2.0 - 1.0) * 3.0;
    
    // Generate particle field
    float particles = 0.0;
    for(float i = 1.0; i < 6.0; i++) {
        particles += sin(p.x * i + time) * sin(p.y * i + time * 0.5);
        particles += cos(p.y * i * 1.5 - time) * cos(p.x * i * 1.5 + time * 0.7);
    }
    particles *= 0.1;
    
    // Create quantum colors
    vec3 quantumColor;
    quantumColor.r = 0.5 + 0.5 * sin(particles * 5.0 + time);
    quantumColor.g = 0.5 + 0.5 * sin(particles * 4.0 - time * 1.1);
    quantumColor.b = 0.5 + 0.5 * sin(particles * 3.0 + time * 1.2);
    
    // Add interference patterns
    vec2 interference = vec2(
        sin(particles * 10.0 + time) * 0.005,
        cos(particles * 8.0 - time) * 0.005
    );
    
    // Sample with interference
    vec4 distortedColor = texture(iChannel0, uv + interference);
    
    // Add particle glow
    float glow = exp(-abs(particles) * 5.0) * 0.5;
    
    // Preserve text readability
    float textMask = max(max(originalColor.r, originalColor.g), originalColor.b);
    vec4 finalColor = mix(
        vec4(quantumColor * 0.3 + distortedColor.rgb * 0.7 + glow, 1.0),
        originalColor,
        textMask
    );
    
    fragColor = finalColor;
}
