#include <CalendarLib.h>
#include <map>

using namespace std;

typedef map<long, Calendar *>	CCalendarMap ;
typedef map<long, Calendar *>::iterator CCalendarMapIter;

class ConfiguredCalendarCache
{
public:
	Calendar* Find(long idCalendar);
	BOOL Insert(long idCalendar, Calendar* pCalendar);
  virtual ~ConfiguredCalendarCache();

protected:
  CCalendarMap mCalendarMap;

};
