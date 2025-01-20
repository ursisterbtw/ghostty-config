void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord/iResolution.xy;
    
    // Glitch effect
    float glitchTime = floor(iTime * 2.0) * 0.5;
    float glitch = step(0.98, sin(glitchTime * 50.0));
    vec2 glitchOffset = vec2(
        sin(uv.y * 50.0 + glitchTime) * 0.01,
        cos(uv.x * 40.0 + glitchTime) * 0.01
    ) * glitch;
    
    // RGB split
    vec2 rOffset = glitchOffset + vec2(0.002, 0.0);
    vec2 gOffset = glitchOffset;
    vec2 bOffset = glitchOffset - vec2(0.002, 0.0);
    
    vec4 originalR = texture(iChannel0, uv + rOffset);
    vec4 originalG = texture(iChannel0, uv + gOffset);
    vec4 originalB = texture(iChannel0, uv + bOffset);
    
    // CRT scanlines
    float scanline = sin(uv.y * 400.0) * 0.1 + 0.9;
    float vignette = pow(16.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y), 0.3);
    
    vec4 finalColor = vec4(
        originalR.r,
        originalG.g,
        originalB.b,
        1.0
    );
    
    fragColor = finalColor * scanline * vignette;
}
