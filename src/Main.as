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
