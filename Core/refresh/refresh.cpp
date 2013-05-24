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
#include <ConfigChange.h>

#include <iostream>
using namespace std;

void SignalChange()
{
	cout << "Signalling change of configuration." << endl;
	ConfigChangeEvent event;
	if (!event.Init())
	{
		cout << "Could not initialize change event." << endl;
		return;
	}

	if (!event.Signal())
	{
		cout << "Could not signal event." << endl;
		return;
	}

	cout << "Successfully sent signal." << endl;
}

class MyObserver : public ConfigChangeObserver
{
public:
	MyObserver(const char * apName) : mName(apName)
	{ }

	virtual void ConfigurationHasChanged();
private:
	std::string mName;
};

void MyObserver::ConfigurationHasChanged()
{
	cout << "Configuration has changed for " << mName.c_str() << endl;
}

void AwaitChange()
{
	cout << "Awaiting changes..." << endl;

	ConfigChangeObservable observable;
	if (!observable.Init())
	{
		cout << "Could not initialize observable" << endl;
		return;
	}

	MyObserver obs1("observer1");
	MyObserver obs2("observer2");

	observable.AddObserver(obs1);
	observable.AddObserver(obs2);

	cout << "Starting thread..." << endl;
	if (!observable.StartThread())
	{
		cout << "Could not start thread" << endl;
		return;
	}

	cout << "Sleeping..." << endl;

	::Sleep(1000 * 20);
}


int main(int argc, char * argv[])
{
	if (argc == 2 && 0 == strcmp(argv[1], "-wait"))
	{
		AwaitChange();
	}
	else
	{
		SignalChange();
	}

	return 0;
}

