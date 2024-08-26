enum LogLevel 
{
    Info = 0, 
    Success = 1, 
    Warning = 2, 
    Error = 3
}

namespace TextFade
{ 
    namespace _
    {
        float Duration = 3000.0f; // 3 seconds
        vec4 Color = Colors::White;
        string Text = "";
    }

    void Start(const string &in text, LogLevel level = LogLevel::Info, bool printToLog = true)
    {
        _::Text = text;
        _::Color = Colors::LogLevels[level];

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
        _::Text = "";
        _::Color.w = 1.0f;
    }

    void Render()
    {
        UI::PushStyleColor(UI::Col::Text, _::Color);
        UI::Text(_::Text);
        UI::PopStyleColor();
    }

    void Update(float dt)
    {
        if (_::Text == "")
            return;
        
        _::Color.w -= dt / _::Duration;
        if (_::Color.w <= 0.0f)
            Stop();
    }
}