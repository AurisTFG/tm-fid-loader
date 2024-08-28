UI::TableSortSpecs@ g_currentSortSpecs = null;

enum FidWrapperColumnID
{
    Method = 0,
    FilePath = 1,
    FileSize = 2,
    Actions = 3,
}

class FidWrapper
{
    uint id;
	string method;
	string filePath;
	string folderPath;
	CSystemFidFile@ fid;

	FidWrapper() { }
    FidWrapper(uint _id, CSystemFidFile@ &in _fid, const string &in _filePath, const string &in _method) 
	{ 
        this.id = _id;
		@this.fid = _fid;
		this.filePath = _filePath;
		this.method = _method;

		folderPath = IO::FromDataFolder("Extract/" + filePath.Replace(fid.FileName, ""));
	}

    int CompareWithSortSpec(const FidWrapper &in other) const
    {
        for (uint i = 0; i < g_currentSortSpecs.Specs.Length; i++)
        {
            auto spec = g_currentSortSpecs.Specs[i];

            int delta = 0;
            switch (spec.ColumnIndex)
            {
                case FidWrapperColumnID::Method:   delta = (this.method < other.method) ? -1 : (this.method > other.method) ? +1 : 0; break;
                case FidWrapperColumnID::FilePath: delta = (this.filePath < other.filePath) ? -1 : (this.filePath > other.filePath) ? +1 : 0; break;
				case FidWrapperColumnID::FileSize: delta = this.fid.ByteSize - other.fid.ByteSize; break;
				default: throw("Sorting not implemented for column " + spec.ColumnIndex); break;
            }

            if (delta != 0)
                return (spec.SortDirection == UI::SortDirection::Ascending) ? delta : -delta;
        }

        return other.id - this.id; // Fall back to original order when no sort specs are specified, useful when UI::TableFlags::SortTristate is enabled
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
