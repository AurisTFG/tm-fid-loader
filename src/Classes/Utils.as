const array<string> methods = { "GetFake", "GetGame", "GetResource", "GetUser", "GetProgramData" };

namespace Utils
{
    void SearchForFidsCoro()
    {
        print("Searching for fids...");

        array<FidData>@ fids = SearchForFids();
        @foundFids = fids;

		if (fids.Length != 0)
		{
			string text = "Found " + foundFids.Length + ((foundFids.Length == 1) ? " file!" : " files!");
			MyUI::TextFadeStart(text, LogLevel::Success);
		}
		else
		{
			MyUI::TextFadeStart("Did not find any files.", LogLevel::Error);
		}
    }

    void ExtractAllFilesCoro()
    {
        print("Extracting all files...");

        float filesCount = foundFids.Length;
        float extractedCount = 0;
        for (uint i = 0; i < foundFids.Length; i++)
        {
            bool success = Fids::Extract(foundFids[i].fid, Setting_HookMethod);
            if (success)
            {
                extractedCount++;
            }
        }
        if (extractedCount == 0)
        {
            MyUI::TextFadeStart("Did not manage to extract any files.", LogLevel::Error);
            return;
        }

        float percent = extractedCount / filesCount * 100.0;
        MyUI::TextFadeStart("Successfully extracted " + extractedCount + "/" + filesCount + "! (" + Text::Format("%.2f", percent) + "%)", LogLevel::Success);
    }

    array<FidData>@ SearchForFids()
    {
        array<FidData>@ fids = array<FidData>();
        array<string>@ filePaths = GetFilePaths();
        array<bool> methodSettings = GetSettings();

        for (uint i = 0; i < filePaths.Length; i++)
        {
            if (i % 100 == 0)
            {
                print(i);
                yield();
            }

            for (uint j = 0; j < methods.Length; j++)
            {
                if (!methodSettings[j])
                    continue;

                array<string> pathsToTry = { filePaths[i] };

                if (methods[j] == "GetFake")
                {
                    pathsToTry.InsertLast("Titles/Trackmania/" + filePaths[i]);
                    if (filePaths[i].EndsWith(".Script.txt"))
                    {
                        pathsToTry.InsertLast("Titles/Trackmania/Scripts/" + filePaths[i]);
                    }
                }
                else if (methods[j] == "GetGame")
                {
                    pathsToTry.InsertLast("GameData/" + filePaths[i]);
                }

                for (uint k = 0; k < pathsToTry.Length; k++)
                {
                    CSystemFidFile@ fid = LoadFid(methods[j], pathsToTry[k]);
#if TMNEXT
                    bool fidIsValid = @fid != null && fid.TimeWrite != "?";
#else
                    bool fidIsValid = @fid != null && fid.ByteSize != 0;
#endif
                    if (fidIsValid)
                    {
                        fids.InsertLast(FidData(fid, pathsToTry[k], methods[j]));
                        break;
                    }
                }
            }
        }

        return fids;
    }

    array<string>@ GetFilePaths()
    {
        array<string>@ filePaths = array<string>();

        array<string> lines = textInput.Split("\n");
        for (uint i = 0; i < lines.Length; i++)
        {
            if (i % 1000 == 0)
                yield();

            if (lines[i] == "" || lines[i].StartsWith("//"))
                continue;

            string trimmed = lines[i].Trim();
#if TURBO
            trimmed = trimmed.Replace("\\", "/"); // backslashes dont work in Turbo
#endif
            // if (Setting_GetGame && !trimmed.StartsWith("GameData/"))
            //     filePaths.InsertLast("GameData/" + trimmed);
            // if (Setting_GetFake && !trimmed.StartsWith("GameData/"))
            //     trimmed = trimmed.Substr(9);
            // else if (trimmed.StartsWith("Titles/Trackmania/"))
            //     trimmed = trimmed.Substr(18);
            // else if (trimmed.StartsWith("Titles/Trackmania/Scripts/"))
            //     trimmed = trimmed.Substr(27);
            filePaths.InsertLast(trimmed);
        }

        return filePaths;
    }

    CSystemFidFile@ LoadFid(const string &in method, const string &in filePath)
    {
        if (method == "GetFake")
            return Fids::GetFake(filePath);
        else if (method == "GetGame")
            return Fids::GetGame(filePath);
        else if (method == "GetResource")
            return Fids::GetResource(filePath);
        else if (method == "GetUser")
            return Fids::GetUser(filePath);
        else if (method == "GetProgramData")
            return Fids::GetProgramData(filePath);

        error("[Utils::LoadFid] Invalid method: " + method);
        return null;
    }

    array<bool> GetSettings()
    {
        array<bool> methodSettings = { Setting_GetFake, Setting_GetGame, Setting_GetResource, Setting_GetUser, Setting_GetProgramData };
        return methodSettings;
    }
}