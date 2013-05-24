/**************************************************************************
 * TEST
 *
 * Copyright 1997-2001 by MetraTech Corp.
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
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#include <MTSessionBaseDef.h>
#include <RSCache.h>
#include <FileRSLoader.h>

#import <PipelineControl.tlb> rename ("EOF", "RowsetEOF")

#include <mtcomerr.h>
#include <MSIX.h>
#include <mttime.h>

#include <RateInterpreter.h>

#include <iostream>

using std::cout;
using std::endl;

ComInitialize gComInit;

class RuleSetTest
{
public:
  static void ReadBridgeRateMetadata();
  static void ReadSongSessionChild();
  static void ReadPremiereBridgeRate();
};

void RuleSetTest::ReadBridgeRateMetadata()
{
  try
  {
    MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc (__uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));
    MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr pt = pc->GetParamTableDefinitionByName(L"metratech.com/bridgerate");
    OptimizedRateScheduleLoader loader;
    RuleSetStaticExecution rsse(&loader);
    rsse.Init(pt);

    // Check the size of the buffer
    time_t currentTime = GetMTTime();
    rsse.LoadFromDatabase(currentTime);
    rsse.Print();
  }
  catch(_com_error & err)
  {
	  std::cerr << err.ErrorMessage() << std::endl;
  }
  catch(std::exception & stlErr)
  {
    std::cerr << stlErr.what() << std::endl;
  }
  catch(...)
  {
  }
}

void RuleSetTest::ReadSongSessionChild()
{
  try
  {
    MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc (__uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));
    MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr pt = pc->GetParamTableDefinitionByName(L"metratech.com/songsessionchild");
    OptimizedRateScheduleLoader loader;
    RuleSetStaticExecution rsse(&loader);
    rsse.Init(pt);

    // Check the size of the buffer
    time_t currentTime = GetMTTime();
    rsse.LoadFromDatabase(currentTime);
    rsse.Print();
  }
  catch(_com_error & err)
  {
	  std::cerr << err.ErrorMessage() << std::endl;
  }
  catch(std::exception & stlErr)
  {
    std::cerr << stlErr.what() << std::endl;
  }
  catch(...)
  {
  }
}

void RuleSetTest::ReadPremiereBridgeRate()
{
  try
  {
    MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc (__uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));
    MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr pt = pc->GetParamTableDefinitionByName(L"BridgeRate");
    OptimizedRateScheduleLoader loader;
    RuleSetStaticExecution rsse(&loader);
    rsse.Init(pt);
    // Check the size of the buffer
    time_t currentTime = GetMTTime();
    rsse.LoadFromDatabase(currentTime);

    MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr pt2 = pc->GetParamTableDefinitionByName(L"BaseTransportRate");
    RuleSetStaticExecution rsse2(&loader);
    rsse2.Init(pt);
    // Check the size of the buffer
    rsse2.LoadFromDatabase(currentTime);

    MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr pt3 = pc->GetParamTableDefinitionByName(L"IntlTransportRate");
    RuleSetStaticExecution rsse3(&loader);
    rsse3.Init(pt);
    // Check the size of the buffer
    rsse3.LoadFromDatabase(currentTime);
  }
  catch(_com_error & err)
  {
	  std::cerr << err.ErrorMessage() << std::endl;
  }
  catch(std::exception & stlErr)
  {
    std::cerr << stlErr.what() << std::endl;
  }
  catch(...)
  {
  }
}

class RSCacheTest
{
public:
	BOOL Init();
	BOOL Test();

private:
	RateScheduleCache mCache;

	FileRSLoader mLoader;

	MTPipelineLib::IMTSessionServerPtr mSessionServer;
	MTPipelineLib::IMTNameIDPtr mNameID;

	long mDurationID;
	long mRateID;
	long mSurchargeStepID;
	long mRuleSetID;
};


BOOL RSCacheTest::Init()
{
	mLoader.SetRootDirectory("c:\\scratch\\rscache");

	mCache.SetLoader(&mLoader);

	PIPELINECONTROLLib::IMTPipelinePtr control("MetraPipeline.MTPipeline.1");
	HRESULT hr = mNameID.CreateInstance("MetraPipeline.MTNameID.1");
	if (FAILED(hr))
	{
		cout << "Unable to create name ID" << endl;
		return FALSE;
	}

	PIPELINECONTROLLib::IMTSessionServerPtr sessionServer = control->GetSessionServer();
	mSessionServer = (MTPipelineLib::IMTSessionServer *) sessionServer.GetInterfacePtr();


	mDurationID = mNameID->GetNameID("Duration");
	mRateID = mNameID->GetNameID("Rate");
	mSurchargeStepID = mNameID->GetNameID("SurchargeStep");
	mRuleSetID = mNameID->GetNameID("RuleSetID");

	return TRUE;
}

BOOL RSCacheTest::Test()
{


	// create a session
	unsigned char sessionUID[16];
	std::string newUid;
	MSIXUidGenerator::Generate(newUid);
	if (!MSIXUidGenerator::Decode(sessionUID, newUid))
	{
		cout << "Unable to decode uid" << endl;
		return FALSE;
	}

	// 10 is service ID (ignored)
	MTPipelineLib::IMTSessionPtr session = mSessionServer->CreateSession(sessionUID, 10);


	int scheduleId = 20;


	while (TRUE)
	{

		// set the condition
		session->SetLongProperty(mDurationID, 100);

		time_t modifiedAt = mLoader.GetLastModified(scheduleId);

		CachedRateSchedule * schedule = NULL;

		// TODO: first arg is table ID
		if (!mCache.GetRateSchedule(9999, scheduleId, modifiedAt, &schedule))
		{
			cout << "Unable to get rate schedule " << scheduleId << endl;
			return FALSE;
		}

// 		BOOL matched = schedule->ProcessSession(session);    

		long duration = session->GetLongProperty(mDurationID);
		double rate = session->GetDoubleProperty(mRateID);
		long step = session->GetLongProperty(mSurchargeStepID);
		long ruleset = session->GetLongProperty(mRuleSetID);


		cout << "duration = " << duration
				 << "  rate = " << rate
				 << "  surcharge step = " << step
				 << "  ruleset ID = " << ruleset
				 << endl;

		::Sleep(3 * 1000);
	}

	return TRUE;
}

#if 0

my $duration;
my $rate;
my $surchargeStep;

#
# set some properties and retreive the results
#
$session->SetLongProperty($durationID, 100);

$eval->Match($session);

$duration = $session->GetLongProperty($durationID);

$rate = $session->GetDoubleProperty($rateID);
$surchargeStep = $session->GetLongProperty($surchargeStepID);


print "duration = $duration  rate = $rate  surcharge step = $surchargeStep\n";
#endif


int main(int argc, char * * argv)
{
	try
	{
//     RuleSetTest::ReadBridgeRateMetadata();
//     RuleSetTest::ReadSongSessionChild();
    RuleSetTest::ReadPremiereBridgeRate();
    return 0;

		RSCacheTest test;

		if (!test.Init())
		{
			cout << "Unable to initialize" << endl;
			return -1;
		}

		if (!test.Test())
		{
			cout << "Test failed" << endl;
			return -1;
		}
	}
	catch (_com_error & err)
	{
		std::string buffer;
		StringFromComError(buffer, "exception thrown", err);
		cout << buffer.c_str();
	}

	return 0;
}
