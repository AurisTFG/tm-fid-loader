class FidData
{
	CSystemFidFile@ fid;
	string filePath;
	string method;
	CMwNod@ nod;
	string folderPath;

	FidData() { }
    FidData(CSystemFidFile@ &in _fid, const string &in _filePath, const string &in _method) 
	{ 
		@this.fid = _fid;
		this.filePath = _filePath;
		this.method = _method;

		@nod = Fids::Preload(fid);
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
        if (@nod != null)
            return;

        @nod = Fids::Preload(fid);
    }

    void ExploreNodForFid()
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

        if (@nod == null)
        {
            PreloadNod();
            if (@nod == null)
            {
                TextFade::Start("Failed to preload nod for " + "\"" + this.filePath + "\"", LogLevel::Error);
                return;
            }
        }

        ExploreNod(this.fid.FileName, this.nod); 
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
