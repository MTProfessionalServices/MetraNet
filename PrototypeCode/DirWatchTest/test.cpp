/**************************************************************************
 * @doc TEST
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
 * Created by: Carl Shimer
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <mtcom.h>
#include <metra.h>
#include <iostream>
#include <dirwatch.h>

using std::cout;
using std::endl;

static ComInitialize GComInitialize;

class MTTestCallBack : public MTWatchCallBack
{

public:
	MTTestCallBack(mtstring& aStr) : MTWatchCallBack(aStr) {}
	void CallBackFunc(mtstring& aFullFile,long aActionType)
	{
		cout << "file " << aFullFile << " has changed, action type " << aActionType << endl;
	}

};


int main (int argc, char ** argv)
{
	if(argc < 2) {
		cout << "Usage: " << argv[0] << " " "directory_name" << endl;
	}
	
	MTDirWatch aDirWatch;
	aDirWatch.SetWatchDir(string("D:\\temp"));
	aDirWatch.WatchSubDirectories(true);
	aDirWatch.Init();
	aDirWatch.AddCallBack(new MTTestCallBack(mtstring("service\\metratech.com\\foo.xml")));


	for(int i=0;i<10;i++) {
		if(aDirWatch.RegisterNotification()) {
			::SleepEx(INFINITE,TRUE);
		}
		else break;
	}



  return TRUE;
}



