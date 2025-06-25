namespace Utils
{
	void YieldIfNeeded()
	{
		if (Time::Now - g_lastYield >= YIELD_AFTER_MS)
		{
			g_lastYield = Time::Now;
			yield();
		}
	}
}

