namespace Colors
{
    const vec4 White = vec4(1.0f, 1.0f, 1.0f, 1.0f);
    const vec4 Green = vec4(0.0f, 1.0f, 0.0f, 1.0f);
    const vec4 Yellow = vec4(1.0f, 1.0f, 0.0f, 1.0f);
    const vec4 Red = vec4(1.0f, 0.0f, 0.0f, 1.0f);
    const vec4 Orange = vec4(1.0f, 0.64f, 0.0f, 1.0f);
    
    const vec4 Button = vec4(UI::GetStyleColor(UI::Col::Button).xyz, 1.0f);

    const array<vec4> LogLevels = { White, Green, Yellow, Red };
}
