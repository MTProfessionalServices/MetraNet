// PerfTimer.h
#include <Windows.h>
class PerfTimer
{
	//----- Constructor/Destructor pair.
	public:
		PerfTimer() : mlStartCounter(0)
		{
			QueryPerformanceFrequency(&mlFrequency);
		}

		void Start()
		{
			mlStartCounter = Counter();
		}

		double Time()
		{
			return ToMillis(Counter() - mlStartCounter);
		}

	protected:
		__int64 Counter()
		{
			LARGE_INTEGER lCount;
			QueryPerformanceCounter(&lCount);
			return lCount.QuadPart;
		}
		double ToMillis(__int64 lCount)
		{
			return (double) ((1000.0 * lCount)/mlFrequency.QuadPart);
		}
	private:
		LARGE_INTEGER mlFrequency;
		__int64 mlStartCounter;
};

//-- EOF --