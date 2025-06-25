namespace Utils
{
	void YieldIfNeeded()
	{
		if (Time::Now - Globals::LastYield >= Constants::YIELD_AFTER_MS)
		{
			Globals::LastYield = Time::Now;
			trace("Yielding to prevent UI freeze...");
			yield();
		}
	}
}

