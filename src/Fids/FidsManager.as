namespace FidsManager
{
	array<FidData>@ foundFids = array<FidData>();
	string label = windowLabel;
	string textInput = defaultText;

	void Init()
    {
		if (DEV)
		{
			textInput = exampleText;
			label = windowLabelDev;
			Setting_WindowOpen = true;
		}
    }

	void MenuItem()
	{
		if (UI::MenuItem(label, "", Setting_WindowOpen))
			Setting_WindowOpen = !Setting_WindowOpen;
	}

	void Render()
	{
		if (!Setting_WindowOpen) 
			return;
			
		UI::SetNextWindowSize(920, 600);
		UI::Begin(label, Setting_WindowOpen, UI::WindowFlags::NoCollapse);

		_UI::PushBorderStyle(1.5f);
		textInput = UI::InputTextMultiline("##textInput", textInput, vec2(900, 200));
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

		if (UI::Button(Icons::TrashO + " Clear"))
			Clear();

		TextFade::Render();

		if (foundFids.Length == 0 || Setting_DisableTableRender)
		{
			UI::End();
			return;
		}

		if (UI::BeginTable("FidsTable", 4, UI::TableFlags::Resizable | UI::TableFlags::Borders))
		{
			UI::TableHeadersRow();
			
			UI::PushStyleColor(UI::Col::Separator, Colors::Button);
			_UI::TableHeader(0, "Method");
			_UI::TableHeader(1, "Full file path");
			_UI::TableHeader(2, "Size");
			_UI::TableHeader(3, "Actions");
			UI::PopStyleColor();

			for (uint i = 0; i < foundFids.Length; i++)
			{
				UI::TableNextRow();
				UI::TableSetColumnIndex(0); UI::Text(foundFids[i].method);
				UI::TableSetColumnIndex(1); UI::Text(foundFids[i].filePath);
				UI::TableSetColumnIndex(2); UI::Text(foundFids[i].fid.ByteSize + " B");
				UI::TableSetColumnIndex(3);

				if (!OPExtractPermission) 
					_UI::PushRedButtonColor();
				if (UI::Button("Extract##" + i))
					foundFids[i].Extract();
				_UI::PopButtonColors();
				UI::SameLine();
				
				if(!OPDevMode)
					_UI::PushOrangeButtonColor();
				if (!OPExtractPermission || @foundFids[i].nod == null) 
					_UI::PushRedButtonColor();
				if (UI::Button("Nod##" + i))
					foundFids[i].ExploreNodForFid();
				_UI::PopButtonColors();
				UI::SameLine();

				if (!IO::FolderExists(foundFids[i].folderPath)) 
					_UI::PushRedButtonColor();
				if (UI::Button("Open Folder##" + i))
					foundFids[i].OpenFolder();
				_UI::PopButtonColors();

			}
			UI::EndTable();
		}

		UI::GetWindowDrawList().AddRect(UI::GetItemRect(), Colors::Button, 2.0f, 1.75f);
		UI::End();
	}

	void SearchForFidsCoro() 
	{ 
		foundFids = SearchForFids(); 
		
		if (foundFids.Length == 0)
		{
			TextFade::Start("Did not find any files.", LogLevel::Error);
			return;
		}
	
		TextFade::Start("Found " + foundFids.Length + ((foundFids.Length == 1) ? " file!" : " files!"), LogLevel::Success);
	}

	array<FidData> SearchForFids()
    {
        array<FidData> fids = array<FidData>();
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
					fids.InsertLast(FidData(fid, filePath, methods[j]));
					break;
				}
                
            }
        }

		return fids;
    }

	void LoadExample()
	{
		textInput = exampleText;
		TextFade::Start("Loaded an example.");
	}

	void ExtractAllFilesCoro() 
	{ 
		uint count = ExtractAllFiles(); 

		if (count == 0)
		{
			TextFade::Start("Did not manage to extract any files.", LogLevel::Error);
			return;
		}

		float percent = count / foundFids.Length * 100.0;
        TextFade::Start("Successfully extracted " + count + "/" + foundFids.Length + "! (" + Text::Format("%.2f", percent) + "%)", LogLevel::Success);
	}

	uint ExtractAllFiles()
    {
		if (!OPExtractPermission)
		{
			TextFade::Start("Club access is required to extract files.", LogLevel::Error);
			return 0;
		}

        uint extractedCount = 0;

        for (uint i = 0; i < foundFids.Length; i++)
        {
            if (Fids::Extract(foundFids[i].fid, Setting_HookMethod))
            	extractedCount++;
        }

		return extractedCount;
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
