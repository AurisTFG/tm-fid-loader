namespace FidsManager
{
	array<FidData> fids;
	bool fidsDirty = false;

	void Init()
    {
		fids = array<FidData>();
    }

	void MenuItem()
	{
		if (UI::MenuItem(windowLabel, "", Setting_WindowOpen))
			Setting_WindowOpen = !Setting_WindowOpen;
	}

	void Render()
	{
		if (!Setting_WindowOpen) 
			return;

		UI::Begin(windowLabel, Setting_WindowOpen, UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize);

		_UI::PushBorderStyle();
		Setting_TextInput = UI::InputTextMultiline("##textInput", Setting_TextInput, vec2(574, 200));
		_UI::PopBorderStyle();

		if (UI::Button(Icons::Search + " Search"))
			startnew(SearchForFidsCoro);
		UI::SameLine();

		if (UI::Button(Icons::Kenney::Fill + " Load Example"))
			LoadExample();
		UI::SameLine();

		if (!OPExtractPermission) 
			_UI::PushRedButtonColor();
		if (UI::Button(Icons::FilesO + " Extract All Files"))
			startnew(ExtractAllFilesCoro);
		_UI::PopButtonColors();
		UI::SameLine();

		if (UI::Button(Icons::History + " Preload All Nods"))
			startnew(PreloadAllNodsCoro);
		UI::SameLine();

		if (UI::Button(Icons::TrashO + " Clear"))
			Clear();

		TextFade::Render();

		if (fids.Length == 0 || Setting_DisableTableRender)
		{
			UI::End();
			return;
		}
		
		int tableFlags = 
			UI::TableFlags::Borders | 
			UI::TableFlags::RowBg |
			UI::TableFlags::SizingFixedFit | 
			UI::TableFlags::ScrollY | 
			UI::TableFlags::Sortable | 
			UI::TableFlags::SortMulti;

		UI::PushStyleColor(UI::Col::TableBorderStrong, Colors::Button);
		if (UI::BeginTable("Fids", 4, tableFlags, vec2(0, 244)))
		{
			UI::TableSetupScrollFreeze(0, 1);

			UI::TableSetupColumn("Method", UI::TableColumnFlags::DefaultSort);
			UI::TableSetupColumn("File path", UI::TableColumnFlags::WidthStretch | UI::TableColumnFlags::DefaultSort);
			UI::TableSetupColumn("Size", UI::TableColumnFlags::DefaultSort);
			UI::TableSetupColumn("Actions", UI::TableColumnFlags::NoSort);
			UI::TableHeadersRow();

			auto sortSpecs = UI::TableGetSortSpecs();
			if (sortSpecs !is null && (sortSpecs.Dirty || fidsDirty))
				SortItems(sortSpecs);

			for (uint i = 0; i < fids.Length; i++)
			{
				UI::PushID(fids[i]);
				UI::TableNextRow();
				
				UI::TableNextColumn();
				UI::Text(fids[i].method);
				UI::TableNextColumn();
				UI::Text(fids[i].filePath);
				UI::TableNextColumn();
				UI::Text(fids[i].fid.ByteSize + " B");
				UI::TableNextColumn();

				if (!OPExtractPermission) 
					_UI::PushRedButtonColor();
				if (UI::Button("Extract"))
					fids[i].Extract();
				_UI::PopButtonColors();
				UI::SameLine();
				
				if(!OPDevMode)
					_UI::PushOrangeButtonColor();
				if (!OPExtractPermission || @fids[i].fid.Nod == null) 
					_UI::PushRedButtonColor();
				if (UI::Button("Nod"))
					fids[i].OpenNodExplorer();
				_UI::PopButtonColors();
				UI::SameLine();

				if (!IO::FolderExists(fids[i].folderPath)) 
					_UI::PushRedButtonColor();
				if (UI::Button("Open Folder"))
					fids[i].OpenFolder();
				_UI::PopButtonColors();

				UI::PopID();
			}
			UI::EndTable();
		}
		UI::PopStyleColor();

		UI::End();
	}

	void SearchForFidsCoro() 
	{ 
		fids = array<FidData>();
        array<string> filePaths = GetFilePaths(Setting_TextInput);
        array<bool> methodSettings = { Setting_GetFake, Setting_GetGame, Setting_GetResource, Setting_GetUser, Setting_GetProgramData };

        for (uint i = 0; i < filePaths.Length; i++)
        {
			string filePath = filePaths[i];

            if (i % 100 == 0) 
				yield();

            for (uint j = 0; j < methods.Length; j++)
            {
                if (!methodSettings[j])
                    continue;


				CSystemFidFile@ fid = LoadFid(methods[j], filePath);

#if TMNEXT
				bool fidIsValid = @fid != null && fid.TimeWrite != "?";
#else
				bool fidIsValid = @fid != null && fid.ByteSize != 0;
#endif

				if (fidIsValid)
				{
					fids.InsertLast(FidData(fid, filePath, methods[j]));
					break;
				}
                
            }
        }

		if (fids.Length >= 2)
			fidsDirty = true;

		Fids::UpdateTree(Fids::GetGameFolder("")); // Cool "fix" to get rid of fake files that get added to fid explorer after search
		
		if (fids.Length == 0)
		{
			TextFade::Start("Did not find any files.", LogLevel::Error);
			return;
		}
	
		TextFade::Start("Found " + fids.Length + ((fids.Length == 1) ? " file!" : " files!"), LogLevel::Success);
	}

	void LoadExample()
	{
		Setting_TextInput = exampleText;
		TextFade::Start("Loaded an example.");
	}

	void ExtractAllFilesCoro() 
	{ 
		if (!OPExtractPermission)
		{
			TextFade::Start("Club access is required to extract files.", LogLevel::Error);
			return;
		}

        uint count = 0;

        for (uint i = 0; i < fids.Length; i++)
        {
            if (Fids::Extract(fids[i].fid, Setting_HookMethod))
            	count++;
        }

		if (count == 0)
		{
			TextFade::Start("Did not manage to extract any files.", LogLevel::Error);
			return;
		}

		float percent = float(count) / fids.Length * 100;
        TextFade::Start("Successfully extracted " + count + "/" + fids.Length + "! (" + Text::Format("%.2f", percent) + "%)", LogLevel::Success);
	}

	void PreloadAllNodsCoro()
	{
		int count = 0;

		for (uint i = 0; i < fids.Length; i++)
		{
			fids[i].PreloadNod();

			if (@fids[i].fid.Nod != null)
				count++;
		}

		if (count == 0)
		{
			TextFade::Start("Did not manage to preload any nods.", LogLevel::Error);
			return;
		}

		float percent = float(count) / fids.Length * 100;
		TextFade::Start("Successfully preloaded " + count + "/" + fids.Length + " nods! (" + Text::Format("%.2f", percent) + "%)", LogLevel::Success);
	}

	void Clear()
	{
		fids = array<FidData>();

		TextFade::Stop();
	}

	array<string> GetFilePaths(const string &in multilineInput)
	{
		array<string> filePaths = array<string>();
		array<string> lines = multilineInput.Split("\n");

		for (uint i = 0; i < lines.Length; i++)
		{
			string line = lines[i].Trim();

			if (i % 1000 == 0)
				yield();

			if (line == "" || line.StartsWith("//"))
				continue;

#if TURBO
			line = line.Replace("\\", "/"); // backslashes dont work in Turbo
#endif

			filePaths.InsertLast(line);

			if (Setting_GetGame)
			{
				if (!line.StartsWith("GameData/"))
				{
			    	filePaths.InsertLast("GameData/" + line);
				}
			}

			if (Setting_GetFake)
			{
				if (line.EndsWith(".Script.txt") && !line.StartsWith("Titles/Trackmania/Scripts/"))
				{
			    	filePaths.InsertLast("Titles/Trackmania/Scripts/" + line);
				}
				
				if (!line.StartsWith("Titles/Trackmania/"))
				{
			    	filePaths.InsertLast("Titles/Trackmania/" + line);
				}
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

		error("Invalid fid get method: " + method);
		return null;
	}

	void SortItems(UI::TableSortSpecs@ sortSpecs)
	{
		trace("Sorting items");
		if (fids.Length < 2)
		{
			sortSpecs.Dirty = false;
			fidsDirty = false;
			return;
		}

		auto specs = sortSpecs.Specs;
		for (int i = specs.Length - 1; i >= 0; i--) { // Reverse loop to sort by the last column first
			auto spec = specs[i];

			if (spec.SortDirection == UI::SortDirection::None)
				continue;

			if (spec.SortDirection == UI::SortDirection::Ascending) {
				switch (spec.ColumnIndex) {
				case 0: fids.Sort(function(a, b) { return a.method < b.method; }); break;
				case 1: fids.Sort(function(a, b) { return a.filePath < b.filePath; }); break;
				case 2: fids.Sort(function(a, b) { return a.fid.ByteSize < b.fid.ByteSize; }); break;
				}

			} else if (spec.SortDirection == UI::SortDirection::Descending) {
				switch (spec.ColumnIndex) {
				case 0: fids.Sort(function(a, b) { return a.method > b.method; }); break;
				case 1: fids.Sort(function(a, b) { return a.filePath > b.filePath; }); break;
				case 2: fids.Sort(function(a, b) { return a.fid.ByteSize > b.fid.ByteSize; }); break;
				}
			}
		}

		sortSpecs.Dirty = false;
		fidsDirty = false;
	}
}
