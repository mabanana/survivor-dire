shader_type canvas_item;

//programatically change this if you want to, remove the progress based on time.
uniform float progress : hint_range(-1.0,2.0) = 0.1;
//the width of the burn area, higher values makes the burn wider, 1 makes the burn cover the whole sprite
uniform float width : hint_range(0.0,2.0) = 0.4;

//Noise to sample from for the burning
uniform sampler2D noise;
//colors to use for the burn color, the progress of the burn goes left to right
uniform sampler2D colorCurve;

//make this timed or not, if not timed, you must programatically set the burn (such as with a lerp)
uniform bool timed = false;
//speed of the burn
uniform float speed : hint_range(0.0,1.0) = 1.0;
//hacky way to make this angled, far from perfect. 1.0 is right to left. 0 is bottom to top. outside
//that range is wierd.
uniform float angle = 0.0;

float inverse_lerp(float a, float b, float v){
	return (v-a)/(b-a);
}

void fragment() {
	float burn_progress;
	if(timed){
		burn_progress = (fract(TIME * speed / 2.0) * 2.0);
	}else{
		burn_progress = progress;
	}
	float noise_value = texture(noise,UV).x;
	float mask = inverse_lerp(1.0 - burn_progress,(1.0 + width) - burn_progress, (UV.x * angle + UV.y * (1.0-angle)));
	float value = clamp(mask + noise_value,0.0,1.0);
	vec4 curve_value = texture(colorCurve,vec2(value));
	COLOR = mix(COLOR, curve_value, value);
	COLOR.a = min(texture(TEXTURE,UV).a,COLOR.a);

    // UV coordinates range from 0.0 to 1.0
    vec2 center = vec2(0.5, 0.5);

    // Compute the distance from the current pixel to the center
    float dist = distance(UV, center);
    float transparency = normalize(0.5 - dist);
    COLOR.a = COLOR.a * transparency;
	transparency = 1.0 - normalize(0.25 - dist);
	COLOR.a = COLOR.a * transparency;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
