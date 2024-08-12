const bool DEV = Meta::ExecutingPlugin().Name.ToLower().EndsWith("(dev)");
const bool OPDevMode = Meta::IsDeveloperMode();
#if TMNEXT
const bool OPExtractPermission = OpenplanetHasFullPermissions();
#else
const bool OPExtractPermission = true;
#endif

void Main()      { Init(); }
void OnEnabled() { Init(); }
void Init()
{
	FidsManager::Init();
}

void RenderMenu()
{
	FidsManager::MenuItem();
}

void RenderInterface()
{
	FidsManager::Render();
}

void Update(float dt)
{
	TextFade::Update(dt);
}
