namespace Settings
{
    // --- General ---

    [Setting category="General" name="Extract with Hook Method" description="Hook method can help you to extract .gbx files that would usually get corrupted when extracting from .paks. However, this method will not always work and may even cause a game crash"]
    bool HookMethod = false;

    // --- Performance ---

    [Setting category="Performance" name="Disable Table Rendering" description="Enable this option if you don't want to render the table when loading huge amount of files"]
    bool DisableTableRender = false;

    // --- Functions ---

    [Setting category="Functions" name="GetFake" description="Gets a file from the main TitlePack, e.g.: Trackmania.Title.Pack.gbx"]
    bool GetFake = true;

    [Setting category="Functions" name="GetGame" description="Gets a file from the install directory of the game, e.g.: \"C:/Program Files (x86)/Steam/steamapps/common/Trackmania\", also includes files from majority of the .paks"]
    bool GetGame = true;

    [Setting category="Functions" name="GetResource" description="Gets a file from \"Packs/Resource.pak\""]
    bool GetResource = true;

    [Setting category="Functions" name="GetUser" description="Gets a file from the User directory of the game, e.g.: \"C:/Users/{Username}/Documents/Trackmania2020\""]
    bool GetUser = true;

    [Setting category="Functions" name="GetProgramData" description="Gets a file from the ProgramData directory of the game, e.g.: \"C:/ProgramData/Trackmania2020/\""]
    bool GetProgramData = true;

    // --- Hidden Settings ---

    [Setting hidden]
    bool WindowOpen = false;

    [Setting hidden]
    string TextInput = "*Type file paths here*";

    [Setting hidden]
    uint TableRowCount = 5;
}
