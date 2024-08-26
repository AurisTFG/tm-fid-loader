namespace _UI
{
    void TableHeader(const int &in column, const string &in text)
    {
        UI::TableSetColumnIndex(column); 
        UI::TableHeader(text); 
        PushSeparatorColor();
        UI::Separator();
        PopSeparatorColor();
    }

    void Tooltip(const string &in msg, int width = 400, bool questionMark = true) 
    {
        if (questionMark)
        {
            UI::SameLine();
            UI::TextDisabled("(?)");
        }
            
        if (UI::IsItemHovered()) 
        {
            UI::SetNextWindowSize(width, -1, UI::Cond::Always);
            UI::BeginTooltip();
            UI::TextWrapped(msg);
            UI::EndTooltip();
        }
    }

    void PushBorderStyle(float size = 1.0f, vec4 color = Colors::Button)
    {
        UI::PushStyleVar(UI::StyleVar::FrameBorderSize, size);
        UI::PushStyleColor(UI::Col::Border, color);
    }
    void PopBorderStyle()
    {
        UI::PopStyleColor();
        UI::PopStyleVar();
    }

    void PushSeparatorColor()
    {
        UI::PushStyleColor(UI::Col::Separator, Colors::Button);
    }
    void PopSeparatorColor()
    {
        UI::PopStyleColor();
    }
    
    int buttonColorStackCount = 0;
    void PushRedButtonColor()
    {
        UI::PushStyleColor(UI::Col::Button, Colors::Red);
        UI::PushStyleColor(UI::Col::ButtonActive, vec4(Colors::Red.x, 0.7f, 0.7f, 1.0f));
        UI::PushStyleColor(UI::Col::ButtonHovered, vec4(Colors::Red.x, 0.5f, 0.5f, 1.0f));
        buttonColorStackCount += 3;
    }
    void PushOrangeButtonColor()
    {
        UI::PushStyleColor(UI::Col::Button, Colors::Orange);
        UI::PushStyleColor(UI::Col::ButtonActive, vec4(Colors::Orange.x, 0.5f, 0.0f, 1.0f));
        UI::PushStyleColor(UI::Col::ButtonHovered, vec4(Colors::Orange.x, 0.4f, 0.0f, 1.0f));
        buttonColorStackCount += 3;
    }
    void PopButtonColors()
    {
        for (int i = 0; i < buttonColorStackCount; i++)
            UI::PopStyleColor();
            
        buttonColorStackCount = 0;
    }
}