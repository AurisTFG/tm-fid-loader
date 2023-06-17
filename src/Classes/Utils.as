namespace Utils
{     
    void Clear()
    {
        foundFids.RemoveRange(0, foundFids.Length);
        filePaths.RemoveRange(0, filePaths.Length);
        textInput = defaultText;
        textFadeAlpha = 0.0f;
    }

    void SearchForFids()
    {
        foundFids.RemoveRange(0, foundFids.Length);
        filePaths.RemoveRange(0, filePaths.Length);
        textFadeAlpha = 1.0f;

        array<string> lines = textInput.Split("\n");
        for (uint i = 0; i < lines.Length; i++)
        {
            string trimmed = lines[i].Trim().Replace("\"", "").Replace(",", "");
            if (filePaths.Find(trimmed) == -1)
            {
                filePaths.InsertLast(trimmed);
            }
        }  

        for (uint i = 0; i < filePaths.Length; i++)
        {
            if (filePaths[i].Length == 0) 
                return;

            TryFidLoad("GetFake",        "Titles/Trackmania/" + filePaths[i]);
            TryFidLoad("GetFake",        filePaths[i]);
            TryFidLoad("GetGame", 		 "GameData/" + filePaths[i]);
            TryFidLoad("GetGame",        filePaths[i]);
            TryFidLoad("GetResource",    filePaths[i]);
            TryFidLoad("GetUser",        filePaths[i]);
            TryFidLoad("GetProgramData", filePaths[i]);
        }
    }

    void TryFidLoad(const string &in method, const string &in filePath)
    {
        CSystemFidFile@ fid = null;

        if      (method == "GetFake" && useGetFake)               @fid = Fids::GetFake(filePath);
        else if (method == "GetGame" && useGetGame)               @fid = Fids::GetGame(filePath);
        else if (method == "GetResource" && useGetResource)       @fid = Fids::GetResource(filePath);
        else if (method == "GetUser" && useGetUser)               @fid = Fids::GetUser(filePath);
        else if (method == "GetProgramData" && useGetProgramData) @fid = Fids::GetProgramData(filePath);
        
        if (@fid != null && fid.ByteSize > 0)
        {
            foundFids.InsertLast(FidData(fid, filePath, method));
        }
    }   

    void AddTooltipOfWidth(const string &in msg, int width = 400) {
        UI::SameLine();
		UI::TextDisabled("(?)");
        if (UI::IsItemHovered()) {
            UI::SetNextWindowSize(width, -1, UI::Cond::Always);
            UI::BeginTooltip();
            UI::TextWrapped(msg);
            UI::EndTooltip();
        }
    }

    void UI_TableHeader(const int &in column, const string &in text)
    {
        UI::TableSetColumnIndex(column); 
        UI::TableHeader(text); 
        UI::Separator();
    }

    void UI_TextFade()
    {
        if (textFadeAlpha > 0.0f)
        {
            UI::SameLine();
            
            vec4 color = vec4(0.0f, 0.0f, 0.0f, textFadeAlpha);
            textFadeAlpha -= textFadeAmount;
            if (foundFids.Length != 0)
            {
                color.y = 1.0f;
                UI::PushStyleColor(UI::Col::Text, color);
                int fileCount = foundFids.Length;
                string fileString = (fileCount == 1) ? " file!" : " files!";
                UI::Text("Found " + fileCount + fileString);
            }
            else
            {
                color.x = 1.0f;
                UI::PushStyleColor(UI::Col::Text, color);
                UI::Text("No files were found.");
            }

            UI::PopStyleColor();
        }

        UI::Dummy(vec2(0, 20));
    }
}