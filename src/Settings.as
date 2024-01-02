[Setting category="General" name="Window Open"]
bool Setting_WindowOpen = false;

[Setting category="General" name="Extract with Hook Method" description="Hook method can help you to extract .gbx files that would usually get corrupted when extracting from .paks. However, this method will not always work and may even cause a game crash"]
bool Setting_HookMethod = false;

[Setting category="General" name="Disable Table Rendering" description="Enable this option if you don't want to render the table when loading huge amount of files"]
bool Setting_DisableTableRender = false;


[Setting category="Functions" name="GetFake" description="Gets a file from the main TitlePack, e.g.: Trackmania.Title.Pack.gbx"]
bool Setting_GetFake = true;

[Setting category="Functions" name="GetGame" description="Gets a file from the install directory of the game, e.g.: \"C:/Program Files (x86)/Steam/steamapps/common/Trackmania\", also includes files from majority of the .paks"]
bool Setting_GetGame = true;

[Setting category="Functions" name="GetResource" description="Gets a file from \"Packs/Resource.pak\""]
bool Setting_GetResource = true;

[Setting category="Functions" name="GetUser" description="Gets a file from the User directory of the game, e.g.: \"C:/Users/{Username}/Documents/Trackmania2020\""]
bool Setting_GetUser = true;

[Setting category="Functions" name="GetProgramData" description="Gets a file from the ProgramData directory of the game, e.g.: \"C:/ProgramData/Trackmania2020/\""]
bool Setting_GetProgramData = true;
