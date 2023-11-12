const array<string> methods = { "GetFake", "GetGame", "GetResource", "GetUser", "GetProgramData" };

namespace Utils
{
    array<FidData>@ SearchForFids(const string &in text)
    {
        array<FidData>@ foundFids = array<FidData>();
        array<string>@ filePaths = ParseFilePaths(text);
        array<bool> methodSettings = GetSettings();

        for (uint i = 0; i < filePaths.Length; i++)
        {
            bool found = false;
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
                    if (@fid != null && fid.TimeWrite != "?")
                    {
                        foundFids.InsertLast(FidData(fid, pathsToTry[k], methods[j]));
                        found = true;
                        break;
                    }
                }
            }

            if (!found)
            {
                print("Could not find fid for file: " + filePaths[i]);
            }
        }

        return foundFids;
    }

    array<string>@ ParseFilePaths(const string &in text)
    {
        array<string>@ filePaths = array<string>();

        array<string> lines = textInput.Split("\n");
        for (uint i = 0; i < lines.Length; i++)
        {
            if (lines[i] == "" || lines[i].StartsWith("//") )
                continue;

            string trimmed = lines[i].Trim().Replace("\"", "").Replace(",", "");
            if (trimmed.Length > 0 && filePaths.Find(trimmed) == -1)
            {
                filePaths.InsertLast(trimmed);
            }
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