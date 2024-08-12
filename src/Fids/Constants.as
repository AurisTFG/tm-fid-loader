const array<string> methods = { "GetFake", "GetGame", "GetResource", "GetUser", "GetProgramData" };

const string windowLabel = "\\$0ff" + Icons::Exchange + "\\$z Fid Loader";
const string windowLabelDev = "\\$b1f" + Icons::FolderOpen + "\\$d00 Fid Loader (Dev)";

const string defaultText = "*Type file paths here*";
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