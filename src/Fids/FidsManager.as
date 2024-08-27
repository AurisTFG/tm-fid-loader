namespace FidsManager
{
	array<FidData> foundFids = array<FidData>();
	string textInput = defaultText;

	void Init()
    {
		foundFids = array<FidData>();
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
		textInput = UI::InputTextMultiline("##textInput", textInput, vec2(425, 200));
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

		if (foundFids.Length == 0 || Setting_DisableTableRender)
		{
			UI::End();
			return;
		}
		
		UI::PushStyleColor(UI::Col::TableBorderStrong, Colors::Button);
		if (UI::BeginTable("FidsTable", 4, UI::TableFlags::SizingFixedFit | UI::TableFlags::Borders | UI::TableFlags::ScrollY | UI::TableFlags::RowBg, vec2(0, 244)))
		{
			UI::TableSetupScrollFreeze(0, 1);

			UI::TableSetupColumn("Method");
			UI::TableSetupColumn("File path");
			UI::TableSetupColumn("Size");
			UI::TableSetupColumn("Actions");
			UI::TableHeadersRow();

			for (uint i = 0; i < foundFids.Length; i++)
			{
				UI::PushID(i + "");
				UI::TableNextRow();
				
				UI::TableNextColumn();
				UI::Text(foundFids[i].method);
				UI::TableNextColumn();
				UI::Text(foundFids[i].filePath);
				UI::TableNextColumn();
				UI::Text(foundFids[i].fid.ByteSize + " B");
				UI::TableNextColumn();

				if (!OPExtractPermission) 
					_UI::PushRedButtonColor();
				if (UI::Button("Extract"))
					foundFids[i].Extract();
				_UI::PopButtonColors();
				UI::SameLine();
				
				if(!OPDevMode)
					_UI::PushOrangeButtonColor();
				if (!OPExtractPermission || @foundFids[i].fid.Nod == null) 
					_UI::PushRedButtonColor();
				if (UI::Button("Nod"))
					foundFids[i].OpenNodExplorer();
				_UI::PopButtonColors();
				UI::SameLine();

				if (!IO::FolderExists(foundFids[i].folderPath)) 
					_UI::PushRedButtonColor();
				if (UI::Button("Open Folder"))
					foundFids[i].OpenFolder();
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
		foundFids = array<FidData>();
        array<string> filePaths = GetFilePaths(textInput);
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
					foundFids.InsertLast(FidData(fid, filePath, methods[j]));
					break;
				}
                
            }
        }

		Fids::UpdateTree(Fids::GetGameFolder(""));
		
		if (foundFids.Length == 0)
		{
			TextFade::Start("Did not find any files.", LogLevel::Error);
			return;
		}
	
		TextFade::Start("Found " + foundFids.Length + ((foundFids.Length == 1) ? " file!" : " files!"), LogLevel::Success);
	}

	void LoadExample()
	{
		textInput = exampleText;
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

        for (uint i = 0; i < foundFids.Length; i++)
        {
            if (Fids::Extract(foundFids[i].fid, Setting_HookMethod))
            	count++;
        }

		if (count == 0)
		{
			TextFade::Start("Did not manage to extract any files.", LogLevel::Error);
			return;
		}

		float percent = float(count) / foundFids.Length * 100;
        TextFade::Start("Successfully extracted " + count + "/" + foundFids.Length + "! (" + Text::Format("%.2f", percent) + "%)", LogLevel::Success);
	}

	void PreloadAllNodsCoro()
	{
		int count = 0;

		for (uint i = 0; i < foundFids.Length; i++)
		{
			foundFids[i].PreloadNod();

			if (@foundFids[i].fid.Nod != null)
				count++;
		}

		if (count == 0)
		{
			TextFade::Start("Did not manage to preload any nods.", LogLevel::Error);
			return;
		}

		float percent = float(count) / foundFids.Length * 100;
		TextFade::Start("Successfully preloaded " + count + "/" + foundFids.Length + " nods! (" + Text::Format("%.2f", percent) + "%)", LogLevel::Success);
	}

	void Clear()
	{
		textInput = "";
		foundFids = array<FidData>();
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
}
