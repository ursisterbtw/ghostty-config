void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord/iResolution.xy;
    vec4 originalColor = texture(iChannel0, uv);
    
    // Center and scale UV coordinates
    vec2 p = (uv * 2.0 - 1.0) * 1.1;
    float a = atan(p.y, p.x);
    float r = length(p);
    
    // Kaleidoscope effect
    float sides = 8.0;
    float angle = a - iTime * 0.2;
    angle = mod(angle, 2.0 * 3.14159 / sides);
    angle = abs(angle - 3.14159 / sides);
    
    // Transform back to UV space
    vec2 kaleidoUV = vec2(cos(angle), sin(angle)) * r;
    kaleidoUV = (kaleidoUV * 0.5 + 0.5);
    
    // Add some color rotation
    vec3 rainbow;
    rainbow.r = 0.5 + 0.5 * sin(iTime + r * 3.0);
    rainbow.g = 0.5 + 0.5 * sin(iTime * 1.1 + r * 3.0 + 2.1);
    rainbow.b = 0.5 + 0.5 * sin(iTime * 0.9 + r * 3.0 + 4.2);
    
    vec4 kaleidoColor = texture(iChannel0, kaleidoUV);
    
    // Preserve text readability
    float textMask = max(max(originalColor.r, originalColor.g), originalColor.b);
    vec4 finalColor = mix(
        vec4(rainbow * 0.3 + kaleidoColor.rgb * 0.7, 1.0),
        originalColor,
        textMask
    );
    
    fragColor = finalColor;
}
