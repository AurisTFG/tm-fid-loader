bool mainWindowOpen = true;
bool settingsWindowOpen = false;

vec4 customBorderColor = vec4(UI::GetStyleColor(UI::Col::Button).xyz, 1.0f);
float customBorderWidth = 1.75f;
float customBorderRounding = 2.0f;
float textFadeAlpha = 0.0f;
float textFadeAmount = 0.0035f;

bool extractHookMethod = false;
bool useGetFake = true;
bool useGetGame = true;
bool useGetResource = true;
bool useGetUser = true;
bool useGetProgramData = true;

string mainWindowLabel;
string defaultText;
string textInput;
array<string> filePaths;
array<FidData> foundFids;

void Main()
{
	string pluginName = Meta::ExecutingPlugin().Name;
	if (pluginName.EndsWith("(dev)"))
	{
		defaultText = "Maps/Campaigns/Training/Training - 18.Map.Gbx\nMedia/Musics/Stadium/Race/Race 1 - Chassis.ogg ";
		mainWindowLabel = "\\$b1f" + Icons::FolderOpen + "\\$z\\$d00 " + pluginName;
	}
	else
	{
		defaultText = "*Type file paths here*";
		mainWindowLabel = "\\$b1f" + Icons::FolderOpen + "\\$z " + pluginName;
	}
	textInput = defaultText;
}

void RenderMenu()
{
	if (UI::MenuItem(mainWindowLabel, "", mainWindowOpen))
	{
		if (mainWindowOpen) 
		{
			mainWindowOpen = false;
			settingsWindowOpen = false;
			Utils::Clear();
		}
		else 
		{
			mainWindowOpen = true;
		}
	}
}

void RenderInterface()
{
	if (mainWindowOpen) RenderMainWindow();
	if (settingsWindowOpen) RenderSettingsWindow();
}

void RenderSettingsWindow()
{
	if (UI::Begin("Settings", settingsWindowOpen, UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoCollapse)) 
	{
		extractHookMethod = UI::Checkbox("Extract with hook method", extractHookMethod);
		Utils::AddTooltipOfWidth("Hook method can help to successfully extract files that would usually get corrupted when extracting from .pak's (.Title.Pack.Gbx always works fine)\nHowever, this method will not always work and may even cause a game crash.", 500.0f);

		UI::Text("");
		UI::Text("Functions to use:");

		useGetFake = UI::Checkbox("GetFake", useGetFake);
		Utils::AddTooltipOfWidth("Gets a file from \n" + "\"" + IO::FromAppFolder("Packs\\Trackmania.Title.Pack.gbx") + "\"", 700.0f);

		useGetGame = UI::Checkbox("GetGame", useGetGame);
		Utils::AddTooltipOfWidth("Gets a file from from majority of the .pak and .zip files from \n" + "\"" + IO::FromAppFolder("Packs") + "\"", 700.0f);

		useGetResource = UI::Checkbox("GetResource", useGetResource);
		Utils::AddTooltipOfWidth("Gets a file from \n" + "\"" + IO::FromAppFolder("Packs\\Resource.pak") + "\"", 700.0f);

		useGetUser = UI::Checkbox("GetUser", useGetUser);
		Utils::AddTooltipOfWidth("Gets a file from \n" + "\"" + IO::FromUserGameFolder("") + "\"", 700.0f);

		useGetProgramData = UI::Checkbox("GetProgramData", useGetProgramData);
		Utils::AddTooltipOfWidth("Gets a file from \n\"C:\\ProgramData\\Trackmania2020\\\"", 700.0f);
	}

	UI::End();
}

void RenderMainWindow()
{
	if (UI::Begin(mainWindowLabel, mainWindowOpen, UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoCollapse | UI::WindowFlags::MenuBar)) 
	{
		if (UI::BeginMenuBar()) 
		{
			if (UI::BeginMenu("Options")) 
			{
				if (UI::MenuItem("Clear")) 
				{
					Utils::Clear();
				}

				if (UI::MenuItem("Settings")) 
				{
					settingsWindowOpen = !settingsWindowOpen;
				}

				UI::EndMenu();
			}

			UI::EndMenuBar();
		}

		UI::PushStyleVar(UI::StyleVar::FrameBorderSize, 1.5f);
		UI::PushStyleColor(UI::Col::Border, customBorderColor);
		textInput = UI::InputTextMultiline("##textInput", textInput, vec2 (800, 150));
		UI::PopStyleColor();
		UI::PopStyleVar();

		if (UI::Button(Icons::Search + " Search"))
		{
			Utils::SearchForFids();
		}

		Utils::UI_TextFade(); // the green or red text next to the button

		if (foundFids.Length == 0)
		{
			UI::End();
			return;
		}

		UI::BeginGroup();
		if (UI::BeginTable("table1", 4, UI::TableFlags::Resizable | UI::TableFlags::Borders))
		{
			UI::TableHeadersRow();
			
			UI::PushStyleColor(UI::Col::Separator, customBorderColor);
			Utils::UI_TableHeader(0, "Method");
			Utils::UI_TableHeader(1, "Full file path");
			Utils::UI_TableHeader(2, "Size");
			Utils::UI_TableHeader(3, "Actions");
			UI::PopStyleColor();

			for (uint i = 0; i < foundFids.Length; i++)
			{
				uint size = foundFids[i].fid.ByteSize;

				if (size > 0) 
				{
					UI::TableNextRow();

					UI::TableSetColumnIndex(0);
					UI::Text(foundFids[i].method);

					UI::TableSetColumnIndex(1);
					UI::Text(foundFids[i].filePath);

					UI::TableSetColumnIndex(2);
					UI::Text(size + " B");

					UI::TableSetColumnIndex(3);
					if (UI::Button("Extract##" + i))
					{
						if (Fids::Extract(foundFids[i].fid, extractHookMethod))
						{
							string temp = "Extracted ";
							if (extractHookMethod)
								temp = "Extracted with hook method ";

							print(temp + "\"" + foundFids[i].filePath + "\"");

						}
						else
						{
							print("Failed to extract " + "\"" + foundFids[i].filePath + "\"");
						}
					}
					UI::SameLine();
					if (UI::Button("Nod##" + i))
					{
						print("Loading nod for " + "\"" + foundFids[i].filePath + "\"");
						CMwNod@ nod = null;
						@nod = Fids::Preload(foundFids[i].fid);

						if (@nod != null)
						{
							print("CMwNod.IdName: " + tostring(nod.IdName));
							print("CMwNod.Id: " + tostring(nod.Id.Value));
							ExploreNod(foundFids[i].fid.FileName, nod);
						}
						else
						{
							print("Failed to load nod for " + "\"" + foundFids[i].filePath + "\"");
						}
					}
					UI::SameLine();
					if (UI::Button("Open Folder##" + i))
					{
						string folder = "Extract/" + foundFids[i].filePath.Replace(foundFids[i].fid.FileName, "");
						string fullPath = IO::FromDataFolder(folder);
						print("Opening folder " + "\"" + fullPath + "\"");
						OpenExplorerPath(fullPath);
					}
				}
			}
		}
		UI::EndTable();
	}
	UI::EndGroup();
	UI::GetWindowDrawList().AddRect(UI::GetItemRect(), customBorderColor, customBorderRounding, customBorderWidth);

	UI::End();
}