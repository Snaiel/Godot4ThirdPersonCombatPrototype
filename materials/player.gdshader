shader_type spatial;

uniform float dist;

uniform float fade_distance = 1;

void fragment() {
	// Calculate the alpha value based on the distance
	float alpha = smoothstep(0.0, fade_distance, dist);
	ALPHA = alpha;
	// Discard the fragment if the alpha is zero
	if (alpha <= 0.0) {
		discard;
	}
}
