enum LogLevel 
{
    Info = 0, 
    Success = 1, 
    Warning = 2, 
    Error = 3
}

namespace TextFade
{ 
    const float durationMs = 3000.0f;
    vec4 currentColor = Colors::White;
    string currentText = "";
    bool keepEmptySpace = true;

    void Start(const string &in text, LogLevel level = LogLevel::Info, bool printToLog = true)
    {
        currentText = text;
        currentColor = Colors::LogLevels[level];

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
    
    void Stop()
    {
        currentText = "";
        currentColor.w = 0.0f;
    }

    void Render()
    {
        if (currentColor.w <= 0.0f && !keepEmptySpace)
            return;
            
        UI::PushStyleColor(UI::Col::Text, currentColor);
        UI::Text(currentText);
        UI::PopStyleColor();
    }

    void Update(float dt)
    {
        if (currentText == "" || currentColor.w <= 0.0f)
            return;
        
        currentColor.w -= dt / durationMs;
    }
}
