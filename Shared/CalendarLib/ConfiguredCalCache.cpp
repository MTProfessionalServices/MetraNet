#include <metra.h>
#include <ConfiguredCalCache.h>

ConfiguredCalendarCache::~ConfiguredCalendarCache()
{
  // iterate thru the export account collection and release each one ...
  CCalendarMapIter iterCalendar;
  Calendar *pCalendar=NULL ;
  for (iterCalendar = mCalendarMap.begin(); iterCalendar != mCalendarMap.end(); iterCalendar++)
  {
    // get calendar ...
    pCalendar = (*iterCalendar).second;

    // delete the calendar ...
    delete pCalendar ;
    pCalendar = NULL;    
  }

}

Calendar* ConfiguredCalendarCache::Find(long idCalendar)
{
  CCalendarMapIter iterCalendar = mCalendarMap.find(idCalendar);
	if (iterCalendar != mCalendarMap.end())
	{
		// get the glcode
		return (*iterCalendar).second;
	}
  else
  {
    return NULL;
  }
}

BOOL ConfiguredCalendarCache::Insert(long idCalendar, Calendar* pCalendar)
{
  mCalendarMap.insert (CCalendarMap::value_type(idCalendar, pCalendar)) ;

  return false;
}

