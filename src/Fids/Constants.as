const bool DEV = Meta::ExecutingPlugin().Name.ToLower().EndsWith("(dev)");
const bool OPDevMode = Meta::IsDeveloperMode();
#if TMNEXT
const bool OPExtractPermission = OpenplanetHasFullPermissions();
#else
const bool OPExtractPermission = true;
#endif

const array<string> methods = { "GetFake", "GetGame", "GetResource", "GetUser", "GetProgramData" };

const string windowLabel = "\\$b1f" + Icons::FolderOpen + (DEV ? "\\$d00" : "\\$z") + " Fid Loader" + (DEV ? " (Dev)" : "");

const string defaultText = "*Type file paths here*";

#if TMNEXT
const string exampleText = """
// GetFake:
Maps/Campaigns/Training/Training - 18.Map.Gbx
Scripts/Modes/TrackMania/TM_Laps_Online.Script.txt
Libs/Nadeo/Trackmania/MainMenu/Constants.Script.txt
// GetGame:
Trackmania.exe
MaterialLib_Stadium.txt
// GetUser:
Config/Default.json
// GetProgramData:
checksum.txt
// GetResource:
Media/Texture/HotGrid.Texture.gbx
""";
#elif TURBO
const string exampleText = """
// GetFake:
Maps/Campaigns/Training/Training - 18.Map.Gbx
Scripts/Modes/TrackMania/TM_Laps_Online.Script.txt
Libs/Nadeo/Trackmania/MainMenu/Constants.Script.txt
// GetGame:
Trackmania.exe
MaterialLib_Stadium.txt
// GetUser:
Config/Default.json
// GetProgramData:
checksum.txt
// GetResource:
Media/Texture/HotGrid.Texture.gbx
""";
#elif MP4
const string exampleText = """
// GetFake:
Maps/Campaigns/Training/Training - 18.Map.Gbx
Scripts/Modes/TrackMania/TM_Laps_Online.Script.txt
Libs/Nadeo/Trackmania/MainMenu/Constants.Script.txt
// GetGame:
Trackmania.exe
MaterialLib_Stadium.txt
// GetUser:
Config/Default.json
// GetProgramData:
checksum.txt
// GetResource:
Media/Texture/HotGrid.Texture.gbx
""";
#else
const string exampleText = "";
#endif
