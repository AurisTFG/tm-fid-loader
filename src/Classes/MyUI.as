const vec4 WhiteColor = vec4(1.0f, 1.0f, 1.0f, 1.0f);
const vec4 GreenColor = vec4(0.0f, 1.0f, 0.0f, 1.0f);
const vec4 YellowColor = vec4(1.0f, 1.0f, 0.0f, 1.0f);
const vec4 RedColor = vec4(1.0f, 0.0f, 0.0f, 1.0f);
const array<vec4> Colors = { WhiteColor, GreenColor, YellowColor, RedColor };

const float TextFade_AlphaDecrease = 0.0025f;
vec4 TextFade_CurrentColor = -1.0f;
string TextFade_CurrentText = "";

enum LogLevel 
{
    Info = 0, 
    Success = 1, 
    Warning = 2, 
    Error = 3
}

namespace MyUI
{ 
    void TableHeader(const int &in column, const string &in text)
    {
        UI::TableSetColumnIndex(column); 
        UI::TableHeader(text); 
        UI::Separator();
    }

    void TextFadeInit(const string &in text, LogLevel level = LogLevel::Info, bool printToLog = true)
    {
        TextFade_CurrentText = text;
        TextFade_CurrentColor = Colors[level];

        if (printToLog)
        {
            switch (level)
            {
                case LogLevel::Info:
                    trace(text);
                    break;
                case LogLevel::Success:
                    print(text);
                    break;
                case LogLevel::Warning:
                    warn(text);
                    break;
                case LogLevel::Error:
                    error(text);
                    break;
            }
        }
    }
    
    void TextFadeStop()
    {
        TextFade_CurrentText = "";
        TextFade_CurrentColor.w = 0.0f;
    }

    void TextFade()
    {
        if (TextFade_CurrentText == "")
            return;

        if (TextFade_CurrentColor.w <= 0.0f)
        {
            UI::Text("");
            return;
        }
            
        TextFade_CurrentColor.w -= TextFade_AlphaDecrease;

        UI::PushStyleColor(UI::Col::Text, TextFade_CurrentColor);
        UI::Text(TextFade_CurrentText);
        UI::PopStyleColor();
    }
}