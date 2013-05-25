/**************************************************************************
 * @doc REFRESH
 *
 * Copyright 1999 by MetraTech Corporation
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <observedevent.h>
#include <namedpipe.h>

#include <iostream>
using namespace std;

const char* sPipeName = "\\\\.\\pipe\\rscachestats";

void Signal()
{
	ObservedEvent event;
	if (!event.Init("DUMP_LRUCACHE_STATS"))
	{
		cout << "Could not initialize event." << endl;
		return;
	}

	if (!event.Signal())
	{
		cout << "Could not signal event." << endl;
		return;
	}
}


bool ReadPipe()
{
  NamedPipeClient np(sPipeName);
  string buf;
  int tries = 0;

  while(np.Connect() == FALSE)
  {
    if(tries == 5)
      return false;
    Sleep(200);
    tries++;
  }
  
	while (np.ReadPipe(buf))
	{
		cout << buf.c_str() << endl;
	}
  return true;
}


int main(int argc, char * argv[])
{
  Signal();
  if(!ReadPipe())
  {
    cout << "Failed to get RS cache statistics." << endl;
    cout << "This could be because of insufficient permissions" <<endl;
    cout << "or because no instance of RS cache was found (is pipeline up?)." << endl;
  }
	return 0;
}