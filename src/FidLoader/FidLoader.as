namespace FidLoader
{
	array<FidWrapper> fids;
	bool fidsDirty = false;
	bool resetTableState = false;
	vec2 tableSize = vec2(1000.0f, TABLE_HEADER_HEIGHT + 5 * TABLE_ROW_HEIGHT);
	float dropdownWidth = 70.0f;

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
		if (UI::MenuItem(WINDOW_LABEL, "", Settings::WindowOpen))
			Settings::WindowOpen = !Settings::WindowOpen;
	}

	void Render()
	{
		if (!Settings::WindowOpen) 
			return;

		UI::Begin(WINDOW_LABEL, Settings::WindowOpen, UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize);

		_UI::PushBorderStyle();
		Settings::TextInput = UI::InputTextMultiline("##textInput", Settings::TextInput, vec2(574, 200));
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
		
		ProgressBar::Render();
		UI::AlignTextToFramePadding();
		TextFade::Render();

		if (fids.Length == 0 || Settings::DisableTableRender)
		{
			UI::End();
			return;
		}

		UI::SameLine();
		UI::AlignTextToFramePadding();
		UI::SetCursorPosX((tableSize.x - APPROX_TABLE_LABEL_TEXT_WIDTH) / 2.0f);
		UI::Text("Total files: " + fids.Length);

		UI::SameLine();
		UI::SetCursorPosX(tableSize.x - dropdownWidth);
		UI::SetNextItemWidth(dropdownWidth);
		_UI::PushBorderStyle();
		string tableRowCount = tostring(Settings::TableRowCount);
		if (UI::BeginCombo("##numberOfRows", tableRowCount))
		{
			for (uint i = 0; i < ROWS_OPTIONS.Length; i++)
			{
				auto rowOption = ROWS_OPTIONS[i];
				bool isSelected = (tableRowCount == rowOption);
				if (UI::Selectable(rowOption, isSelected))
				{
					ComputeTableHeight(rowOption);
				}
			}
			UI::EndCombo();	
		}
		_UI::PopBorderStyle();
		
		int columnCount = 4;
		int tableFlags = 
			UI::TableFlags::Borders | 
			UI::TableFlags::RowBg |
			UI::TableFlags::SizingFixedFit | 
			UI::TableFlags::ScrollY | 
			UI::TableFlags::Sortable | 
			UI::TableFlags::SortMulti |
			UI::TableFlags::SortTristate;
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
		ProgressBar::Start("Searching for files", filePaths.Length);

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

			ProgressBar::UpdateProgress(i + 1);
			Utils::YieldIfNeeded();
        }
		
		ProgressBar::Stop();
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

		ComputeTableHeight(tostring(Settings::TableRowCount));
	}

	void LoadExample()
	{
		Settings::TextInput = EXAMPLE_TEXT;
		TextFade::Start("Loaded an example.");
	}

	void ExtractAllFilesCoro() 
	{ 
		if (!OP_EXTRACT_PERMISSION)
		{
			TextFade::Start("Club access is required to extract files.", LogLevel::Error);
			return;
		}

		ProgressBar::Start("Extracting files", fids.Length);

        uint count = 0;
        for (uint i = 0; i < fids.Length; i++)
        {
            if (Fids::Extract(fids[i].fid, Settings::HookMethod))
            	count++;

			ProgressBar::UpdateProgress(i + 1);
			Utils::YieldIfNeeded();
		}

		ProgressBar::Stop();

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
		ProgressBar::Start("Preloading nods", fids.Length);

		int count = 0;
		for (uint i = 0; i < fids.Length; i++)
		{
			fids[i].PreloadNod();

			if (@fids[i].fid.Nod != null)
				count++;

			ProgressBar::UpdateProgress(i + 1);
			Utils::YieldIfNeeded();
		}

		ProgressBar::Stop();

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
		array<string> lines = Settings::TextInput.Split("\n");

		ProgressBar::Start("Parsing text input", lines.Length);

		for (uint i = 0; i < lines.Length; i++)
		{
			string line = lines[i].Trim();

			if (line == "" || line.StartsWith("//"))
				continue;

			line = line.Replace("\\", "/"); // backslashes dont work in Turbo, but for consistency lets force forward slashes everywhere

			filePaths.InsertLast(line);

			ProgressBar::UpdateProgress(i + 1);
			Utils::YieldIfNeeded();
		}

		ProgressBar::Stop();

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

		if (getFunction == FidsGetFunction::Fake && Settings::GetFake)
		{
			if (filePath.EndsWith(".Script.txt")  && !filePath.StartsWith("Titles/Trackmania/Scripts/"))
				@fileFid = Fids::GetFake("Titles/Trackmania/Scripts/" + filePath);

			if (!IsFidValid(fileFid) && !filePath.StartsWith("Titles/Trackmania/"))
				@fileFid = Fids::GetFake("Titles/Trackmania/" + filePath);

			if (!IsFidValid(fileFid))
				@fileFid = Fids::GetFake(filePath);
		}
		if (getFunction == FidsGetFunction::Game && Settings::GetGame)
		{
			if (!filePath.StartsWith("GameData/"))
				@fileFid = Fids::GetGame("GameData/" + filePath);

			if (!IsFidValid(fileFid))
				@fileFid = Fids::GetGame(filePath);
		}
		if (getFunction == FidsGetFunction::ProgramData && Settings::GetProgramData)
		{
			@fileFid = Fids::GetProgramData(filePath);
		}
		if (getFunction == FidsGetFunction::Resource && Settings::GetResource)
		{
			@fileFid = Fids::GetResource(filePath);
		}
		if (getFunction == FidsGetFunction::User && Settings::GetUser)
		{
			@fileFid = Fids::GetUser(filePath);
		}

		if (!IsFidValid(fileFid))
			return null;

		return FidWrapper(fileFid, filePath, getFunction);
	}

	void ComputeTableHeight(const string &in rowOption)
	{
		uint rowCount = Text::ParseUInt(rowOption);
		Settings::TableRowCount = rowCount;

		if (rowCount <= 0 || rowCount > fids.Length)
			rowCount = fids.Length;

		tableSize.y = TABLE_HEADER_HEIGHT + rowCount * TABLE_ROW_HEIGHT;

		resetTableState = true;
	}
}
