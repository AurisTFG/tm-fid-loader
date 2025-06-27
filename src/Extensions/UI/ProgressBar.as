namespace ProgressBar
{ 
    namespace _
    {
        bool IsLoading = false;
        float LoadProgress = 0.0f;
        uint TotalCount = 0;
        uint CurrentCount = 0;
        string Label = "";
        string Text = "";
    }

    void Start(const string &in label, uint totalCount)
    {
        _::Label = label;
        _::TotalCount = totalCount;
       
        _::IsLoading = true;
        _::LoadProgress = 0.0f;
        _::CurrentCount = 0;
        _::Text = "";
    }

    void UpdateProgress(uint currentCount)
    {
        _::CurrentCount = currentCount;
        _::LoadProgress = float(_::CurrentCount) / float(_::TotalCount);

        _::Text = _::Label + " (" + _::CurrentCount + "/" + _::TotalCount + ")";
    }
    
    void Stop()
    {
        _::IsLoading = false;
    }

    void Render()
    {
        if (!_::IsLoading)
            return;

        string progressBarText = Text::Format("%.2f%%", _::LoadProgress * 100.0f);

        UI::Text(_::Text);
        UI::ProgressBar(_::LoadProgress, vec2(500, 20), progressBarText);
    }
}
