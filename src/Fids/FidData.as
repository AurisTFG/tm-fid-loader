class FidData
{
	CSystemFidFile@ fid;
	string filePath;
	string method;
	string folderPath;

	FidData() { }
    FidData(CSystemFidFile@ &in _fid, const string &in _filePath, const string &in _method) 
	{ 
		@this.fid = _fid;
		this.filePath = _filePath;
		this.method = _method;

		folderPath = IO::FromDataFolder("Extract/" + filePath.Replace(fid.FileName, ""));
	}

    void Extract()
    {	
        if (!OPExtractPermission)
        {
            TextFade::Start("Club access is required to extract files.", LogLevel::Error);
            return;
        }

        if (Fids::Extract(this.fid, Setting_HookMethod))
            TextFade::Start("Successfully extracted file \"" + this.filePath + "\"", LogLevel::Success);
        else
            TextFade::Start("Failed to extract " + "\"" + this.filePath + "\"", LogLevel::Error);
    }

    void PreloadNod()
    {
        if (@fid.Nod != null)
            return;

        Fids::Preload(fid);
    }

    void OpenNodExplorer()
    {
        if (!OPExtractPermission)
        {
            TextFade::Start("Club access is required to Explore Nods.", LogLevel::Error);
            return;
        }
        if (!OPDevMode)
        {
            TextFade::Start("Enable Developer Mode in Openplanet to Explore Nods.", LogLevel::Warning);
            return;
        }

        PreloadNod();
        if (@fid.Nod == null)
        {
            TextFade::Start("Failed to preload nod for " + "\"" + this.filePath + "\"", LogLevel::Error);
            return;
        }

        ExploreNod(this.fid.FileName, this.fid.Nod); 
        TextFade::Start("Opening Nod Explorer for fid " + "\"" + this.filePath + "\"", LogLevel::Success);
    }

    void OpenFolder()
    {
        if (!IO::FolderExists(this.folderPath))
        {
            TextFade::Start("Folder " + "\"" + this.folderPath + "\" does not exist. Extract the file to create it.", LogLevel::Error);
            return;
        }

        TextFade::Start("Opening folder " + "\"" + this.folderPath + "\"");
        OpenExplorerPath(this.folderPath);
    }
}
