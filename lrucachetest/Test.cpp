/**************************************************************************
 * CMTPathRegEx
 *
 * Copyright 1997-2000 by MetraTech Corp.
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Boris Partensky
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <StdAfx.h>
#include <iostream>
#include <lru.h>
#include <RSCache.h>
//#include <DBRSLoader.h>
#include <mtcom.h>

using std::cout;
using std::endl;




/*
void testrscache()
{
  DBRSLoader loader;
  int max = 5;
  //typedef std::map<int, CachedRateSchedule*> ScheduleMap;
  LRUCache<int, CachedRateSchedule*> lru(max);
  ComInitialize aInit;

  for(int i = 0;i<= 5000; i++)
  {
    CachedRateSchedule * rs = loader.CreateRateSchedule(i, 0L);
    lru.insert(i, rs);
  }

  for (int i = 5000, j = 0; j < lru.size(); i--, j++)
  {
    cout << lru.find(i) << endl;
  }
  //cout << lru.size() << endl;
}
*/

int main()
{
  //testrscache();
  
  LRUCache<int, CachedRateSchedule*> lru = LRUCache<int, CachedRateSchedule*>(1000);

  return 1;
  
 
}
