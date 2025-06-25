const bool DEV = Meta::ExecutingPlugin().Name.ToLower().EndsWith("(dev)");
const bool OPDevMode = Meta::IsDeveloperMode();
#if TMNEXT
const bool OPExtractPermission = OpenplanetHasFullPermissions();
#else
const bool OPExtractPermission = true;
#endif
const string windowLabel = "\\$b1f" + Icons::FolderOpen + (DEV ? "\\$d00" : "\\$z") + " Fid Loader" + (DEV ? " (Dev)" : "");

#if TMNEXT
const string exampleText = """
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
const string exampleText = """
// TODO: Add example text for Turbo
""";
#elif MP4
const string exampleText = """
// TODO: Add example text for MP4
""";
#else
const string exampleText = "[WARNING] This game is not supported.";
#endif
