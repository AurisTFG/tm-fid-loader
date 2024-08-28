void Main()      { Init(); }
void OnEnabled() { Init(); }
void Init()
{
	FidLoader::Init();
}

void OnDisabled()  { CleanUp(); }
void OnDestroyed() { CleanUp(); }
void CleanUp() 
{
    FidLoader::CleanUp();
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
