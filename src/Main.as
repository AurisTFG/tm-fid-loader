
const bool OPExtractPermission = OpenplanetHasFullPermissions();
// const bool OPExtractPermission = false;
const bool OPDevMode = Meta::IsDeveloperMode();
// const bool OPDevMode = false;

const vec4 customBorderColor = vec4(UI::GetStyleColor(UI::Col::Button).xyz, 1.0f);
const float customBorderWidth = 1.75f;
const float customBorderRounding = 2.0f;

const string pluginName = Meta::ExecutingPlugin().Name;
const string defaultText = "*Type file paths here*";
const string exampleText = "Maps/Campaigns/Training/Training - 18.Map.Gbx\nMedia/Musics/Stadium/Race/Race 1 - Chassis.ogg";
const string mainWindowLabelDefault = "\\$b1f" + Icons::FolderOpen + "\\$z " + pluginName;
const string mainWindowLabelDev = "\\$b1f" + Icons::FolderOpen + "\\$z\\$d00 " + pluginName;

string mainWindowLabel = mainWindowLabelDefault;
bool mainWindowOpen = false;

string textInput = defaultText;
array<FidData>@ foundFids = array<FidData>();

void Main()
{
	if (pluginName.EndsWith("(dev)"))
	{
		textInput = exampleText;
		mainWindowLabel = mainWindowLabelDev;
		mainWindowOpen = true;
	}
}

void RenderMenu()
{
	if (UI::MenuItem(mainWindowLabel, "", mainWindowOpen))
		mainWindowOpen = !mainWindowOpen;
}

void RenderInterface()
{
	if (mainWindowOpen) 
		RenderMainWindow();
}

void RenderMainWindow()
{
	UI::Begin(mainWindowLabel, mainWindowOpen, UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoCollapse);

	UI::PushStyleVar(UI::StyleVar::FrameBorderSize, 1.5f);
	UI::PushStyleColor(UI::Col::Border, customBorderColor);
	textInput = UI::InputTextMultiline("##textInput", textInput, vec2 (800, 150));
	UI::PopStyleColor();
	UI::PopStyleVar();

	if (UI::Button(Icons::Search + " Search"))
	{
		@foundFids = Utils::SearchForFids(textInput);

		if (foundFids.Length != 0)
		{
			string text = "Found " + foundFids.Length + ((foundFids.Length == 1) ? " file!" : " files!");
			MyUI::TextFadeInit(text, LogLevel::Success);
		}
		else
		{
			MyUI::TextFadeInit("Did not find any files.", LogLevel::Error);
		}
	}

	UI::SameLine();
	if (UI::Button(Icons::Kenney::Fill + " Load Example"))
	{
		textInput = exampleText;
		MyUI::TextFadeInit("Loaded an example.");
	}

	UI::SameLine();
	if (UI::Button(Icons::TrashO + " Clear"))
	{
		textInput = "";
		foundFids = array<FidData>();
		MyUI::TextFadeStop();
	}

	MyUI::TextFade();

	if (foundFids.Length == 0)
	{
		UI::End();
		return;
	}

	if (UI::BeginTable("table1", 4, UI::TableFlags::Resizable | UI::TableFlags::Borders))
	{
		UI::TableHeadersRow();
		
		UI::PushStyleColor(UI::Col::Separator, customBorderColor);
		MyUI::TableHeader(0, "Method");
		MyUI::TableHeader(1, "Full file path");
		MyUI::TableHeader(2, "Size");
		MyUI::TableHeader(3, "Actions");
		UI::PopStyleColor();

		for (uint i = 0; i < foundFids.Length; i++)
		{
			UI::TableNextRow();
			UI::TableSetColumnIndex(0); UI::Text(foundFids[i].method);
			UI::TableSetColumnIndex(1); UI::Text(foundFids[i].filePath);
			UI::TableSetColumnIndex(2); UI::Text(foundFids[i].fid.ByteSize + " B");

			UI::TableSetColumnIndex(3);

			if (!OPExtractPermission)
				UI::PushStyleColor(UI::Col::Button, RedColor);
			if (UI::Button("Extract##" + i))
			{
				if (OPExtractPermission)
				{
					if (Fids::Extract(foundFids[i].fid, Setting_HookMethod))
						MyUI::TextFadeInit("Successfully extracted file \"" + foundFids[i].filePath + "\"", LogLevel::Success);
					else
						MyUI::TextFadeInit("Failed to extract " + "\"" + foundFids[i].filePath + "\"", LogLevel::Error);
				}
				else
				{
					MyUI::TextFadeInit("Club access is required to extract files.", LogLevel::Error);
				}
			}
			if (!OPExtractPermission)
				UI::PopStyleColor();


			if (!OPDevMode || !OPExtractPermission)
				UI::PushStyleColor(UI::Col::Button, RedColor);
			UI::SameLine();
			if (UI::Button("Nod##" + i))
			{
				if (OPDevMode && OPExtractPermission)
				{
					auto nod = Fids::Preload(foundFids[i].fid);

					if (@nod != null)
					{
						ExploreNod(foundFids[i].fid.FileName, nod);
						MyUI::TextFadeInit("Preloaded nod for fid " + "\"" + foundFids[i].filePath + "\"", LogLevel::Success);
					}
					else
					{
						MyUI::TextFadeInit("Failed to preload nod for " + "\"" + foundFids[i].filePath + "\"", LogLevel::Error);
					}
				}
				else if (!OPExtractPermission)
				{
					MyUI::TextFadeInit("Club access is required to preload nods.", LogLevel::Error);
				}
				else if (!OPDevMode)
				{
					MyUI::TextFadeInit("Enable Developer Mode in Openplanet to preload nods.", LogLevel::Warning);
				}
			}
			if (!OPDevMode || !OPExtractPermission)
				UI::PopStyleColor();


			string folderPath = IO::FromDataFolder("Extract/" + foundFids[i].filePath.Replace(foundFids[i].fid.FileName, "")); // TODO: optimize this
			if (!IO::FolderExists(folderPath))
				UI::PushStyleColor(UI::Col::Button, RedColor);
			UI::SameLine();
			if (UI::Button("Open Folder##" + i))
			{
				if (IO::FolderExists(folderPath))
				{
					MyUI::TextFadeInit("Opening folder " + "\"" + folderPath + "\"");
					OpenExplorerPath(folderPath);
				}
				else
				{
					MyUI::TextFadeInit("Folder " + "\"" + folderPath + "\" does not exist.", LogLevel::Error);
				}	
			}
			if (!IO::FolderExists(folderPath))
				UI::PopStyleColor();
		}
		UI::EndTable();
	}

	UI::GetWindowDrawList().AddRect(UI::GetItemRect(), customBorderColor, customBorderRounding, customBorderWidth);
	UI::End();
}