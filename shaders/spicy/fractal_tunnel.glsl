void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord/iResolution.xy;
    vec4 originalColor = texture(iChannel0, uv);
    
    // Center and scale coordinates
    vec2 p = (uv * 2.0 - 1.0);
    p.x *= iResolution.x/iResolution.y;
    
    // Create fractal tunnel effect
    float a = atan(p.y, p.x);
    float r = length(p);
    float t = iTime * 0.2;
    
    // Spiral coordinates
    float spiral = 1.0 / r + t;
    vec2 spiralUV = vec2(
        0.5 + (cos(a * 3.0 + spiral * 3.0) / (r * 2.0)),
        0.5 + (sin(a * 2.0 + spiral * 2.0) / (r * 2.0))
    );
    
    // Create fractal coloring
    vec3 fractalColor;
    fractalColor.r = 0.5 + 0.5 * sin(spiral * 3.0 + t);
    fractalColor.g = 0.5 + 0.5 * sin(spiral * 4.0 + t * 1.1);
    fractalColor.b = 0.5 + 0.5 * sin(spiral * 5.0 + t * 1.2);
    
    // Sample terminal with spiral distortion
    vec4 distortedColor = texture(iChannel0, spiralUV);
    
    // Add some glow
    float glow = exp(-r * 2.0) * 0.3;
    
    // Preserve text readability
    float textMask = max(max(originalColor.r, originalColor.g), originalColor.b);
    vec4 finalColor = mix(
        vec4(fractalColor * 0.3 + distortedColor.rgb * 0.7 + glow, 1.0),
        originalColor,
        textMask
    );
    
    fragColor = finalColor;
}
