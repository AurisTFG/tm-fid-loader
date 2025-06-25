namespace FidLoader
{
	array<FidWrapper> fids;
	bool fidsDirty = false;
	bool resetTableState = false;

	void Init()
    {
		resetTableState = true;
    }

	void CleanUp()
	{
		TextFade::Stop();

		fids = array<FidWrapper>();
		fidsDirty = false;
		resetTableState = false;
		@g_currentSortSpecs = null;
		g_idCounter = 0;
	}

	void MenuItem()
	{
		if (UI::MenuItem(WINDOW_LABEL, "", Setting_WindowOpen))
			Setting_WindowOpen = !Setting_WindowOpen;
	}

	void Render()
	{
		if (!Setting_WindowOpen) 
			return;

		UI::Begin(WINDOW_LABEL, Setting_WindowOpen, UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize);

		_UI::PushBorderStyle();
		Setting_TextInput = UI::InputTextMultiline("##textInput", Setting_TextInput, vec2(574, 200));
		_UI::PopBorderStyle();

		if (UI::Button(Icons::Search + " Search"))
			startnew(SearchForFidsCoro);
		UI::SameLine();

		if (UI::Button(Icons::Kenney::Fill + " Load Example"))
			LoadExample();
		UI::SameLine();

		if (!OP_EXTRACT_PERMISSION) 
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
		
		int columnCount = 4;
		int tableFlags = 
			UI::TableFlags::Borders | 
			UI::TableFlags::RowBg |
			UI::TableFlags::SizingFixedFit | 
			UI::TableFlags::ScrollY | 
			UI::TableFlags::Sortable | 
			UI::TableFlags::SortMulti |
			UI::TableFlags::SortTristate;
		vec2 tableSize = vec2(1000, 298);

		UI::PushStyleColor(UI::Col::TableBorderStrong, Colors::Border);
		UI::PushStyleColor(UI::Col::TableBorderLight, Colors::Border);
		UI::PushStyleVar(UI::StyleVar::CellPadding, vec2(5, 5));
		if (UI::BeginTable("Fids", columnCount, tableFlags, tableSize))
		{
			UI::TableSetupScrollFreeze(0, 1);

			UI::TableSetupColumn("Get Function",    UI::TableColumnFlags::None, 0.0f, FidWrapperColumnID::GetFunction);
			UI::TableSetupColumn("File path", UI::TableColumnFlags::WidthStretch, 0.0f, FidWrapperColumnID::FilePath);
			UI::TableSetupColumn("Size, B",      UI::TableColumnFlags::WidthFixed, 70.0f, FidWrapperColumnID::FileSize);
			UI::TableSetupColumn("Actions",   UI::TableColumnFlags::NoSort, 0.0f, FidWrapperColumnID::Actions);

			UI::TableNextRow(UI::TableRowFlags::Headers);
            for (int i = 0; i < UI::TableGetColumnCount(); i++)
            {
                UI::TableSetColumnIndex(i);
				if (i == FidWrapperColumnID::Actions)
				{
					UI::BeginDisabled();
                	UI::TableHeader(UI::TableGetColumnName(i));
					UI::EndDisabled();
				}
				else
				{
					UI::TableHeader(UI::TableGetColumnName(i));
				}
            }

			if (resetTableState)
			{
				UI::SetScrollX(0.0f);
				UI::SetScrollY(0.0f);
				
				resetTableState = false;
			}

			auto sortSpecs = UI::TableGetSortSpecs();
			if (sortSpecs !is null && (sortSpecs.Dirty || fidsDirty))
			{
				@g_currentSortSpecs = sortSpecs;
				fids.Sort(function(a, b) { return a.CompareWithSortSpec(b) > 0; });
				sortSpecs.Dirty = false;
				fidsDirty = false;
				@g_currentSortSpecs = null;
			}

			UI::ListClipper clipper(fids.Length);
			while (clipper.Step())
			{
				for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++)
				{
					auto fid = fids[i];

					UI::PushID(fid);
					
					UI::TableNextColumn();
					UI::Text(GetFunctionName(fid.getFunction));
					UI::TableNextColumn();
					UI::Text(fid.filePath);
					UI::TableNextColumn();
					UI::Text(tostring(fid.fid.ByteSize));
					UI::TableNextColumn();

					if (!OP_EXTRACT_PERMISSION) 
						_UI::PushRedButtonColor();
					if (UI::Button("Extract"))
						fid.Extract();
					_UI::PopButtonColors();
					UI::SameLine();
					
					if(!OP_DEV_MODE)
						_UI::PushOrangeButtonColor();
					if (!OP_EXTRACT_PERMISSION || @fid.fid.Nod == null) 
						_UI::PushRedButtonColor();
					if (UI::Button("Nod"))
						fid.OpenNodExplorer();
					_UI::PopButtonColors();
					UI::SameLine();

					if (!IO::FolderExists(fid.folderPath)) 
						_UI::PushRedButtonColor();
					if (UI::Button("Open Folder"))
						fid.OpenFolder();
					_UI::PopButtonColors();

					UI::PopID();
				}
			}
			UI::EndTable();
		}
		UI::PopStyleVar();
		UI::PopStyleColor();
		UI::PopStyleColor();

		UI::End();
	}

	void SearchForFidsCoro() 
	{ 
        array<string> filePaths = GetFilePaths();
		fids = array<FidWrapper>();
		auto newFids = array<FidWrapper>();
		TextFade::Stop();

        for (uint i = 0; i < filePaths.Length; i++)
        {
			string filePath = filePaths[i];

            for (FidsGetFunction j = FidsGetFunction::Fake; j < FidsGetFunction::None; j++)
            {
				FidWrapper@ fid = GetFid(j, filePath);

				if (@fid != null)
				{
					newFids.InsertLast(fid);
					break;
				}
                
            }

			Utils::YieldIfNeeded();
        }

		Fids::UpdateTree(Fids::GetGameFolder("")); // Cool "fix" to get rid of fake files that get added to fid explorer after search
		
		if (newFids.Length == 0)
		{
			TextFade::Start("Did not find any files.", LogLevel::Error);
			return;
		}

		TextFade::Start("Found " + newFids.Length + ((newFids.Length == 1) ? " file!" : " files!"), LogLevel::Success);
		
		fids = newFids;
		
		if (fids.Length >= 2)
			fidsDirty = true;
	}

	void LoadExample()
	{
		Setting_TextInput = EXAMPLE_TEXT;
		TextFade::Start("Loaded an example.");
	}

	void ExtractAllFilesCoro() 
	{ 
		if (!OP_EXTRACT_PERMISSION)
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
		fids = array<FidWrapper>();

		TextFade::Stop();
	}

	array<string> GetFilePaths()
	{
		array<string> filePaths = array<string>();

		array<string> lines = Setting_TextInput.Split("\n");
		for (uint i = 0; i < lines.Length; i++)
		{
			string line = lines[i].Trim();

			if (line == "" || line.StartsWith("//"))
				continue;

			line = line.Replace("\\", "/"); // backslashes dont work in Turbo, but for consistency lets force forward slashes everywhere

			filePaths.InsertLast(line);

			Utils::YieldIfNeeded();
		}

		return filePaths;
	}

	bool IsFidValid(CSystemFidFile@ fid)
	{
#if TMNEXT
		return @fid != null && fid.TimeWrite != "?";
#else
		return @fid != null && fid.ByteSize != 0;
#endif
	}

	FidWrapper@ GetFid(FidsGetFunction getFunction, const string &in filePath)
	{
		CSystemFidFile@ fileFid = null;

		if (getFunction == FidsGetFunction::Fake && Setting_GetFake)
		{
			if (filePath.EndsWith(".Script.txt")  && !filePath.StartsWith("Titles/Trackmania/Scripts/"))
				@fileFid = Fids::GetFake("Titles/Trackmania/Scripts/" + filePath);

			if (!IsFidValid(fileFid) && !filePath.StartsWith("Titles/Trackmania/"))
				@fileFid = Fids::GetFake("Titles/Trackmania/" + filePath);

			if (!IsFidValid(fileFid))
				@fileFid = Fids::GetFake(filePath);
		}
		if (getFunction == FidsGetFunction::Game && Setting_GetGame)
		{
			if (!filePath.StartsWith("GameData/"))
				@fileFid = Fids::GetGame("GameData/" + filePath);

			if (!IsFidValid(fileFid))
				@fileFid = Fids::GetGame(filePath);
		}
		if (getFunction == FidsGetFunction::ProgramData && Setting_GetProgramData)
		{
			@fileFid = Fids::GetProgramData(filePath);
		}
		if (getFunction == FidsGetFunction::Resource && Setting_GetResource)
		{
			@fileFid = Fids::GetResource(filePath);
		}
		if (getFunction == FidsGetFunction::User && Setting_GetUser)
		{
			@fileFid = Fids::GetUser(filePath);
		}

		if (!IsFidValid(fileFid))
			return null;

		return FidWrapper(fileFid, filePath, getFunction);
	}
}
