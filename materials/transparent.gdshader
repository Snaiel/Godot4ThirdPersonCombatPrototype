shader_type spatial;

render_mode unshaded;

uniform sampler2D texture_albedo : source_color;
uniform float alpha : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	
    vec2 uv = SCREEN_UV;
    vec4 albedo_tex = texture(texture_albedo,uv);
    ALBEDO = mix(vec3(0.0), albedo_tex.rgb, 0.65);
    ALPHA = albedo_tex.a * alpha;
}