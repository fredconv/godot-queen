shader_type canvas_item;
// Vignette legere pixel — Compatibility, pas de flou texte.

uniform float intensity : hint_range(0.0, 1.0) = 0.42;
uniform float softness : hint_range(0.1, 1.5) = 0.72;
uniform vec4 tint : source_color = vec4(0.02, 0.06, 0.04, 1.0);

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float dist = length(uv);
	float vignette = smoothstep(softness, softness + 0.55, dist);
	COLOR = vec4(tint.rgb, vignette * intensity * tint.a);
}
