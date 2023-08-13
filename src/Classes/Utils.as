const array<string> methods = { "GetFake", "GetGame", "GetResource", "GetUser", "GetProgramData" };
const array<bool> methodSettings = { Setting_GetFake, Setting_GetGame, Setting_GetResource, Setting_GetUser, Setting_GetProgramData };

namespace Utils
{
    array<FidData>@ SearchForFids(const string &in text)
    {
        array<FidData>@ foundFids = array<FidData>();
        array<string>@ filePaths = ParseFilePaths(text);

        for (uint i = 0; i < filePaths.Length; i++)
        {
            if (filePaths[i].Length == 0) 
                break;
            
            for (uint j = 0; j < methods.Length; j++)
            {
                if (!methodSettings[j])
                    continue;

                if (methods[j] == "GetFake" && !filePaths[i].StartsWith("Titles/Trackmania/"))
                    filePaths[i] = "Titles/Trackmania/" + filePaths[i];
                else if (methods[j] == "GetGame" && !filePaths[i].StartsWith("GameData/"))
                    filePaths[i] = "GameData/" + filePaths[i];

                CSystemFidFile@ fid = LoadFid(methods[j], filePaths[i]);
                if (@fid == null || fid.ByteSize == 0)
                    continue;

                foundFids.InsertLast(FidData(fid, filePaths[i], methods[j]));
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
            string trimmed = lines[i].Trim().Replace("\"", "").Replace(",", "");
            if (filePaths.Find(trimmed) == -1)
                filePaths.InsertLast(trimmed);
        }  

        return filePaths;
    }

    CSystemFidFile@ LoadFid(const string &in method, const string &in filePath)
    {
        if (method == "GetFake" && Setting_GetFake)
            return Fids::GetFake(filePath);
        else if (method == "GetGame" && Setting_GetGame)
            return Fids::GetGame(filePath);
        else if (method == "GetResource" && Setting_GetResource)
            return Fids::GetResource(filePath);
        else if (method == "GetUser" && Setting_GetUser)
            return Fids::GetUser(filePath);
        else if (method == "GetProgramData" && Setting_GetProgramData)
            return Fids::GetProgramData(filePath);

        error("[Utils::LoadFid] Invalid method: " + method);
        return null;
    }   
}