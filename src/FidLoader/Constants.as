float TABLE_HEADER_HEIGHT = 25.0f;
float TABLE_ROW_HEIGHT = 34.0f;
float APPROX_TABLE_LABEL_TEXT_WIDTH = 75.0f;

array<string> ROWS_OPTIONS = {"5", "10", "15", "20", "25", "30"};

const string GetFunctionName(FidsGetFunction method) { return FIDS_GET_FUNCTIONS[method]; }
const array<string> FIDS_GET_FUNCTIONS = { 
    "Fake", 
    "Game", 
    "ProgramData", 
    "Resource", 
    "User",
    "None",
};

#if TMNEXT
const string EXAMPLE_TEXT = """
// GetFake:
Libs/Nadeo/Trackmania/MainMenu/Constants.Script.txt
Maps/Campaigns/CurrentQuarterly/Trackmania.Campaign.Gbx
Scripts/Modes/TrackMania/TM_Laps_Online.Script.txt
// GetGame:
Trackmania.exe
MaterialLib_Stadium.txt
Packs/Translations.zip
// GetUser:
Config/GfxDevicePerfs.txt
Config/Default.json
Config/User.FidCache.Gbx
// GetProgramData:
Anzu/anzu.db
checksum.txt
Leagues/LeaguesManager.Manager.Gbx
// GetResource:
Media/Texture/HotGrid.Texture.gbx
Media/Text/PHlsl/ShadowBufferSoft.PHlsl.txt
Media/Texture/Image/Arial.dds
""";
#elif TURBO
const string EXAMPLE_TEXT = """
// TODO: Add example text for Turbo
""";
#elif MP4
const string EXAMPLE_TEXT = """
// TODO: Add example text for MP4
""";
#else
const string EXAMPLE_TEXT = "WARNING: This game is not supported.";
#endif
