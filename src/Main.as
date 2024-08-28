void Main()      { Init(); }
void OnEnabled() { Init(); }
void Init()
{
	FidLoader::Init();
}

void RenderMenu()
{
	FidLoader::MenuItem();
}

void RenderInterface()
{
	FidLoader::Render();
}

void Update(float dt)
{
	TextFade::Update(dt);
}
