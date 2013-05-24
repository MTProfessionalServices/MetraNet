/**************************************************************************
 * @doc CMDPROF
 *
 * Copyright 2000 by MetraTech Corporation
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
#include <mtcom.h>

#include <profile.h>
#include <MSIX.h>
#include <errutils.h>
#include <ConfigDir.h>
#include <mtprogids.h>
#include <multi.h>
#include <makeunique.h>

#import <MTConfigLib.tlb>
#include <pipelineconfig.h>
#include <mtcomerr.h>
using namespace MTConfigLib;

#include <iostream>

using namespace std;

ComInitialize gComInit;

void Reset()
{
	//
	// get the configuration directory
	//
	std::string configDir;
	if (!GetMTConfigDir(configDir))
	{
		cout << "Unable to read configuration directory" << endl;
		return;
	}

	IMTConfigPtr config(MTPROGID_CONFIG);

	PipelineInfoReader pipelineReader;
	PipelineInfo pipelineInfo;

	// TODO: have to convert from one namespace to another
	if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
	{
		string buffer;
		StringFromError(buffer, "Unable to read pipeline configuration file",
										pipelineReader.GetLastError());
		cout << buffer.c_str() << endl;
		return;
	}

	if (!pipelineInfo.ProfileEnabled())
		cout << "No profile enabled!" << endl;

	ProfileDataReference prof;
	if (!prof.Init(pipelineInfo.GetProfileFile().c_str(),
								 pipelineInfo.GetProfileShareName().c_str(),
								 pipelineInfo.GetProfileSessions(),
								 pipelineInfo.GetProfileMessages()))
	{
		string buffer;
		StringFromError(buffer, "Profile setup failed", prof.GetLastError());
		cout << buffer.c_str() << endl;
		return;
	}

	if (!prof->Reset(*prof.GetViewHandle()))
		cout << "Error resetting profile" << endl;
	else
		cout << "Profile reset" << endl;
}

enum OffsetType
{
	Delta,
	FromFirst,
	FromBeginning,
	Summary,
};


void DumpMessages(OffsetType aOffset, int aGrid = TRUE)
{
	const double UNITS_PER_SEC = 1e-3;
//	const double UNITS_PER_SEC = 1e-6;
	//const double MICROS_PER_SEC = 1e-6;

	long freq;
	GetPerformanceTickCountFrequency(freq);
	double countsPerSec = double(freq);

	//
	// initialize
	//

	//
	// get the configuration directory
	//
	std::string configDir;
	if (!GetMTConfigDir(configDir))
	{
		cout << "Unable to read configuration directory" << endl;
		return;
	}

	IMTConfigPtr config(MTPROGID_CONFIG);

	PipelineInfoReader pipelineReader;
	PipelineInfo pipelineInfo;

	// TODO: have to convert from one namespace to another
	if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
	{
		string buffer;
		StringFromError(buffer, "Unable to read pipeline configuration file",
										pipelineReader.GetLastError());
		cout << buffer.c_str() << endl;
		return;
	}

	if (!pipelineInfo.ProfileEnabled())
		cout << "No profile enabled!" << endl;

	ProfileDataReference prof;
	if (!prof.Init(pipelineInfo.GetProfileFile().c_str(),
								 pipelineInfo.GetProfileShareName().c_str(),
								 pipelineInfo.GetProfileSessions(),
								 pipelineInfo.GetProfileMessages()))
	{
		string buffer;
		StringFromError(buffer, "Profile setup failed", prof.GetLastError());
		cout << buffer.c_str() << endl;
		return;
	}


	list<MessageProfile *>::iterator it;

	//
	// calculate overall/summary stats
	//

	PerformanceTickCount firstCount;
	PerformanceTickCount lastCount;

	// retrieve all message profiles
	list<MessageProfile *> profiles;
	prof->AllMessageProfiles(profiles);

	// first the lowest/first count
	for (it = profiles.begin(); it != profiles.end(); it++)
	{
		MessageProfile * profile = *it;

		PerformanceTickCount count =
			profile->GetTime((MessageProfile::ProfileTag) 0);

		if (it == profiles.begin())
			firstCount = count;
		else
		{
			if (count.QuadPart < firstCount.QuadPart)
				firstCount = count;
		}
	}


	// find the highest/last count
	for (it = profiles.begin(); it != profiles.end(); it++)
	{
		MessageProfile * profile = *it;

		SessionProfile * session = NULL;
		prof->FindSessionProfile(profile->GetUID(), &session);
		if (!session)
		{
			lastCount = firstCount;
			break;
			//cout << "inconsistency in last session" << endl;
			//return;
		}

		PerformanceTickCount endingCount;
		for (int i = 0; i < SessionProfile::GetMaxPerformanceCounters(); i++)
		{
			const PerformanceTickCount & count =
				session->GetTime((SessionProfile::ProfileTag) i);

			if (count.QuadPart != -1)
				endingCount = count;
		}

		if (it == profiles.begin())
			lastCount = endingCount;
		else
		{
			if (endingCount.QuadPart > lastCount.QuadPart)
				lastCount = endingCount;
		}
	}

	if (aOffset == Summary)
	{
		cout << "Sessions\t" << profiles.size() << endl;

		double diff = (double) (lastCount.QuadPart - firstCount.QuadPart);
		double diffMicros = double(diff) / (UNITS_PER_SEC * countsPerSec);

		cout << "Total time\t" << diffMicros << endl;
		return;
	}


	//
	// print column headers
	//

	int messageMax = MessageProfile::GetMaxPerformanceCounters();
	for (int i = 0; i < messageMax; i++)
	{
		const char * name = MessageProfile::GetCounterName((MessageProfile::ProfileTag) i);
		if (i > 0)
			cout << '\t';
		cout << name;
	}

	int sessionMax = SessionProfile::GetMaxPerformanceCounters();
	for (int stage = 0; stage < 1; stage++)
	{
		int startIndex;
		if (stage == 0)
			startIndex = SessionProfile::OBJECT_GENERATED;
		else
			startIndex = SessionProfile::RECEIVED_AT_STAGE;

		for (int j = startIndex; j < sessionMax; j++)
		{
			const char * name = SessionProfile::GetCounterName((SessionProfile::ProfileTag) j);
			cout << '\t';
			cout << name;
		}
	}

	cout << "\tTotal";

	cout << "\tStart Offset";

	cout << endl;

	//
	// print all timing data in columns
	//

	// retrieve all message profiles
	profiles.clear();
	prof->AllMessageProfiles(profiles);

	for (it = profiles.begin(); it != profiles.end(); it++)
	{
		MessageProfile * profile = *it;

		PerformanceTickCount previous =
			profile->GetTime((MessageProfile::ProfileTag) 0);

		PerformanceTickCount entry = previous;

		double diff;
		switch (aOffset)
		{
		case Delta:
		case FromFirst:
			diff = 0;
			break;
		case FromBeginning:
			diff = (double) (entry.QuadPart - firstCount.QuadPart);
			break;
		}

		double diffMicros = diff / (UNITS_PER_SEC * countsPerSec);

//		if (aGrid)
		cout << diffMicros;
//		else
//			cout << name << " = " << diff << endl;

//		cout << 0;

		for (int i = 1; i < messageMax; i++)
		{
			const PerformanceTickCount & count =
				profile->GetTime((MessageProfile::ProfileTag) i);

			const char * name = MessageProfile::GetCounterName((MessageProfile::ProfileTag) i);

			if (count.QuadPart != -1)
			{
				double diff;
				switch (aOffset)
				{
				case Delta:
					diff = (double) (count.QuadPart - previous.QuadPart);
					break;
				case FromFirst:
					diff = (double) (count.QuadPart - entry.QuadPart);
					break;
				case FromBeginning:
					diff = (double) (count.QuadPart - firstCount.QuadPart);
					break;
				}

				double diffMicros = diff / (UNITS_PER_SEC * countsPerSec);

				//long diff = (long) (count.QuadPart - previous.QuadPart);
				//long diff = (long) (count.QuadPart - entry.QuadPart);
				//	long diff = (long) (count.QuadPart - firstCount.QuadPart);

				//double diffMicros = double(diff) / (UNITS_PER_SEC * countsPerSec);

				if (aGrid)
					cout << '\t' << diffMicros;
				else
					cout << name << " = " << diff << endl;
				previous = count;
			}
			else
			{
				if (aGrid)
					cout << '\t' << "N/A";
				else
					cout << name << " = " << "N/A" << endl;
			}
		}

		if (!aGrid)
			cout << "  --- session profile --- " << endl;

		SessionProfile * session = NULL;
		prof->FindSessionProfile(profile->GetUID(), &session);
		if (session)
		{
			for (int stage = 0; stage < session->GetTotalStages(); stage++)
			{
				int startIndex;
				if (stage == 0)
					startIndex = SessionProfile::OBJECT_GENERATED;
				else
					startIndex = SessionProfile::RECEIVED_AT_STAGE;

				for (int j = startIndex; j < sessionMax; j++)
				{
					const PerformanceTickCount & count =
						session->GetTime(stage, (SessionProfile::ProfileTag) j);

					const char * name = SessionProfile::GetCounterName((SessionProfile::ProfileTag) j);
					if (count.QuadPart != -1)
					{
						switch (aOffset)
						{
						case Delta:
							diff = (double) (count.QuadPart - previous.QuadPart);
							break;
						case FromFirst:
							diff = (double) (count.QuadPart - entry.QuadPart);
							break;
						case FromBeginning:
							diff = (double) (count.QuadPart - firstCount.QuadPart);
							break;
						}

						//long diff = (long) (count.QuadPart - previous.QuadPart);
						//long diff = (long) (count.QuadPart - entry.QuadPart);
						//long diff = (long) (count.QuadPart - firstCount.QuadPart);

						double diffMicros = diff / (UNITS_PER_SEC * countsPerSec);

						if (aGrid)
							cout << '\t' << diffMicros;
						else
							cout << name << " = " << diffMicros << endl;
						previous = count;
					}
					else
					{
						if (aGrid)
							cout << '\t' << "N/A";
						else
							cout << name << " = " << "N/A" << endl;
					}
				}
			}
		}
		else
		{
			if (!aGrid)
				cout << "Session Profile not found" << endl;
		}

		diff = (double) (previous.QuadPart - entry.QuadPart);
		diffMicros = diff / (UNITS_PER_SEC * countsPerSec);
		if (!aGrid)
			cout << "Total = " << diffMicros << endl;
		else
			cout << '\t' << diffMicros;


		diff = (double) (entry.QuadPart - firstCount.QuadPart);
		diffMicros = diff / (UNITS_PER_SEC * countsPerSec);
		if (!aGrid)
			cout << "Start Offset = " << diffMicros << endl;
		else
			cout << '\t' << diffMicros;


		cout << endl;
		if (!aGrid)
			cout << " ============================== " << endl;
	}
}

void Debug()
{
	const double UNITS_PER_SEC = 1e-3;
//	const double UNITS_PER_SEC = 1e-6;
	//const double MICROS_PER_SEC = 1e-6;

	long freq;
	GetPerformanceTickCountFrequency(freq);

	cout << "Frequency: " << freq << endl;

	double countsPerSec = double(freq);

	long diff = freq;
	double diffMicros = double(diff) / (UNITS_PER_SEC * countsPerSec);

	cout << "Micros: " << diffMicros << endl;
}

int main(int argc, char * argv[])
{
	//
	// parse command line args
	//
	const char * login = NULL;
	const char * password = NULL;
	const char * domain = NULL;

	BOOL reset = FALSE;

	OffsetType offset = Delta;

	// negative means test forever
	int i = 1;
	while (i < argc)
	{
		if (0 == strcmp(argv[i], "-login"))
		{
			i++;
			if (i >= argc)
			{
				cout << "login name required after -login" << endl;
				return 1;
			}
			login = argv[i];
		}
		else if (0 == strcmp(argv[i], "-password"))
		{
			i++;
			if (i >= argc)
			{
				cout << "password required after -password" << endl;
				return 1;
			}
			password = argv[i];
		}
		else if (0 == strcmp(argv[i], "-domain"))
		{
			i++;
			if (i >= argc)
			{
				cout << "domain required after -domain" << endl;
				return 1;
			}
			domain = argv[i];
		}
		else if (0 == strcmp(argv[i], "-reset"))
		{
			reset = TRUE;
		}
		else if (0 == strcmp(argv[i], "-first"))
		{
			offset = FromFirst;
		}
		else if (0 == strcmp(argv[i], "-beginning"))
		{
			offset = FromBeginning;
		}
		else if (0 == strcmp(argv[i], "-delta"))
		{
			offset = Delta;
		}
		else if (0 == strcmp(argv[i], "-summary"))
		{
			offset = Summary;
		}
		else
		{
			// print usage
			cout << endl
			     << "usage: cmdprof [-reset] [-beginning] [-first] [-delta] [-summary]" << endl
			     << "  -beginning : all timings are offset from the earliest timing recorded." << endl
			     << "  -first : all timings are offset from the time the session entered the system." << endl
			     << "  -delta : all timings are offset from the previous timing." << endl
			     << "  -summary : the total number of sessions metered and total time (in ms) is output." << endl
			     << "             tps is (sessions / time) * 1000" << endl;
			
			return 1;
		}

		i++;
	}

	MultiInstanceSetup multiSetup;
	if (!multiSetup.SetupMultiInstance(login, password, domain))
	{
		string buffer;
		StringFromError(buffer, "Multi-instance setup failed", multiSetup.GetLastError());
		cout << buffer.c_str() << endl;
		return -1;
	}


	std::string configDir;
	if (!GetMTConfigDir(configDir))
	{
		cout << "Unable to read configuration directory" << endl;
		return -1;
	}

	try
	{
#if 0
		Debug();
#endif
		if (reset)
			Reset();
		else
			DumpMessages(offset);
	}
	catch (_com_error & err)
	{
		std::string buffer;
		StringFromComError(buffer, "Failure", err);

		cout << "_com_error thrown: " << endl;
		cout << " HRESULT: " << hex << err.Error() << dec << endl;
		cout << " Message: " << err.ErrorMessage() << endl;

		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
			cout << "  Description: " << (const char *) desc << endl;
		if (src.length() > 0)
			cout << "  Source: " << (const char *) src << endl;
		return -1;
	}

	return 0;
}

