void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord/iResolution.xy;
    vec4 originalColor = texture(iChannel0, uv);
    
    // Liquid distortion
    float time = iTime * 0.5;
    vec2 p = uv * 2.0 - 1.0;
    float a = atan(p.y, p.x);
    float r = length(p) * 0.75;
    vec2 uvDistort = uv + vec2(
        cos(a * 3.0 + time + r * 2.0) * 0.01,
        sin(a * 2.0 - time + r * 3.0) * 0.01
    );
    
    // Neon glow effect
    vec3 neon;
    float t = time * 0.5;
    neon.r = 0.5 + 0.5 * sin(r * 5.0 + t * 1.1);
    neon.g = 0.5 + 0.5 * sin(r * 4.0 - t * 1.3);
    neon.b = 0.5 + 0.5 * sin(r * 3.0 + t * 1.7);
    
    vec4 distortedColor = texture(iChannel0, uvDistort);
    
    // Blend with original preserving text
    float textMask = max(max(originalColor.r, originalColor.g), originalColor.b);
    vec4 finalColor = mix(
        vec4(neon * 0.4 + distortedColor.rgb * 0.6, 1.0),
        originalColor,
        textMask
    );
    
    fragColor = finalColor;
}
