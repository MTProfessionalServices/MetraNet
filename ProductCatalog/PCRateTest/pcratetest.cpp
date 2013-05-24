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
#include <DBRSLoader.h>


#import <MTProductCatalog.tlb> rename("EOF", "EOFX") 
#import <PCConfig.tlb>

#include <autosessiontest.h>
#import <PipelineControl.tlb> rename ("EOF", "RowsetEOF") 
#include <mtcomerr.h>
#include <MSIX.h>
#include <mtprogids.h>
#include <SetIterate.h>
#include <getopt.h>
#include <propids.h>
#include <stdutils.h>

#define CONFIG_DIR L"queries\\ProductCatalog"

ComInitialize gComInit;

using MTPRODUCTCATALOGLib::IMTProductCatalogPtr;
using MTPRODUCTCATALOGLib::IMTRuleSetPtr;
using MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr;

using namespace std;

class PCRateTest : public PipelineAutoTest
{
public:
	BOOL Init();

	BOOL SetupRateTest();

	BOOL RSResolution();

	BOOL RateTest();
	BOOL ChainTest(int aRateSchedule1, int aRateSchedule2, int aRateSchedule3);

	BOOL Test();

	void Usage(const char * apProgName);
	int ParseArgs(int argc, char * * argv);

protected:
	virtual BOOL RunSession(PipelineAutoTest & arTest,
													MTPipelineLib::IMTSessionSetPtr aSet);


private:
	BOOL DumpAllProps(MTPipelineLib::IMTSessionPtr aSession);

	// given a param table name, return its ID
	int LookupParamTableID(const char * apName);
private:

	PCRater mRater;

	FileRSLoader mFileLoader;
	DBRSLoader mDBLoader;

	MTPipelineLib::IMTConfigPtr mConfig;
	MTPipelineLib::IMTSessionServerPtr mSessionServer;
	MTPipelineLib::IMTNameIDPtr mNameID;

	int mAccountID;
	int mPriceableItemID;

	//
	// arguments
	//

	RateInputs mInputs;

	// if TRUE, convert the rate schedule to xml and print it out
	BOOL mToXML;

	std::string mTestFilename;


	// a set of test sessions used to test
	TestSessions mTestSessions;
};

BOOL PCRateTest::RunSession(PipelineAutoTest & arTest,
														MTPipelineLib::IMTSessionSetPtr aSet)
{
	// do something...
	return TRUE;
}


int PCRateTest::LookupParamTableID(const char * apName)
{
	IMTProductCatalogPtr catalog("MetraTech.MTProductCatalog");
	IMTParamTableDefinitionPtr def = catalog->GetParamTableDefinitionByName(apName);

	return def->GetID();
}



BOOL PCRateTest::Init()
{
	PipelinePropIDs::Init();

	mFileLoader.SetRootDirectory("c:\\scratch\\rscache");

	if (!mDBLoader.Init())
	{
		cout << "Unable to initialize DB loader" << endl;
		return FALSE;
	}

	mRater.SetLoader(&mDBLoader);

	PIPELINECONTROLLib::IMTPipelinePtr control(MTPROGID_PIPELINE);
	HRESULT hr = mNameID.CreateInstance(MTPROGID_NAMEID);
	if (FAILED(hr))
	{
		cout << "Unable to create name ID" << endl;
		return FALSE;
	}

	PIPELINECONTROLLib::IMTSessionServerPtr sessionServer = control->GetSessionServer();
	mSessionServer = (MTPipelineLib::IMTSessionServer *) sessionServer.GetInterfacePtr();


	hr = mConfig.CreateInstance(MTPROGID_CONFIG);
	if (FAILED(hr))
	{
		cout << "Unable to create propset object" << endl;
		return FALSE;
	}

	return TRUE;
}


BOOL PCRateTest::DumpAllProps(MTPipelineLib::IMTSessionPtr aSession)
{
	SetIterator<MTPipelineLib::IMTSessionPtr, MTPipelineLib::IMTSessionPropPtr> it;
	HRESULT hr = it.Init(aSession);
	if (FAILED(hr))
		return hr;

	while (TRUE)
	{
		MTPipelineLib::IMTSessionPropPtr prop = it.GetNext();
		if (prop == NULL)
			break;

		_bstr_t bstrName = prop->GetName();

		std::string name = (const char *) bstrName;
		StrToLower(name);

		MTPipelineLib::MTSessionPropType type = prop->Gettype();
		long nameid = prop->GetNameID();

		time_t timeVal;
		long longVal;
		__int64 longlongVal;
		_bstr_t stringVal;
		double doubleVal;
		MTDecimal decimalVal;
		BOOL booleanVal;

		std::string printableValue;

		cout << name.c_str() << " = ";

		switch (type)
		{
		case MTPipelineLib::SESS_PROP_TYPE_DATE:
			timeVal = aSession->GetDateTimeProperty(nameid);
			::MTFormatISOTime(timeVal, printableValue);
			cout << printableValue.c_str();
			break;

		case MTPipelineLib::SESS_PROP_TYPE_STRING:
			stringVal = aSession->GetStringProperty(nameid);
			cout << (const char *) stringVal;
			break;

		case MTPipelineLib::SESS_PROP_TYPE_LONG:
			longVal = aSession->GetLongProperty(nameid);
			cout << longVal;
			break;

		case MTPipelineLib::SESS_PROP_TYPE_LONGLONG:
			longlongVal = aSession->GetLongLongProperty(nameid);
			cout << longlongVal;
			break;

		case MTPipelineLib::SESS_PROP_TYPE_DOUBLE:
			doubleVal = aSession->GetDoubleProperty(nameid);
			cout << doubleVal;
			break;

		case MTPipelineLib::SESS_PROP_TYPE_DECIMAL:
			decimalVal = aSession->GetDecimalProperty(nameid);
			cout << decimalVal.Format().c_str();
			break;

		case MTPipelineLib::SESS_PROP_TYPE_ENUM:
		{
			// TODO: it would be nice to get the string, not the number here,
			// but the string will work fine for now.  Also, have to watch the overhead
			// of the enum config object
			MTPipelineLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);
			_bstr_t value =
				enumConfig->GetEnumeratorValueByID(aSession->GetEnumProperty(nameid));
			cout << (const char *) value;
			break;
		}

		case MTPipelineLib::SESS_PROP_TYPE_BOOL:
			booleanVal = (aSession->GetBoolProperty(nameid) == VARIANT_TRUE) ? TRUE : FALSE;
			cout << (booleanVal ? "true" : "false");
			break;

		case MTPipelineLib::SESS_PROP_TYPE_TIME:
			longVal = aSession->GetTimeProperty(nameid);
			::MTFormatTime(longVal, printableValue);
			cout << printableValue.c_str();
			break;

		default:
			ASSERT(0);
			break;
		}

		cout << endl;
	}

	return TRUE;
}


BOOL PCRateTest::RSResolution()
{
	int cycleID = 30;
	int defaultPL = 110;

	time_t nowTimet = time(NULL);
	DATE now;
	::OleDateFromTimet(&now, nowTimet);
	_variant_t recordDate(now, VT_DATE);
	_bstr_t recordDateStr = recordDate;


	MTPipelineLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
	rs->Init(CONFIG_DIR);
	rs->SetQueryTag("GET_RATE_SCHEDULES_ON_ACC");
	rs->AddParam("%%ID_ACC%%", (long) mAccountID);
	rs->AddParam("%%ID_CYCLE%%", (long) cycleID);
	rs->AddParam("%%DEFAULT_PL%%", (long) defaultPL);
	rs->AddParam("%%RECORDDATE%%", recordDateStr);
	rs->AddParam("%%PI_TYPE%%", (long) mPriceableItemID);
	rs->Execute();

	while(rs->GetRowsetEOF().boolVal == VARIANT_FALSE)
	{
		long sched, pt, pl, sub, po;

		_variant_t val;
		_variant_t modified;

		val = rs->GetValue("id_sched");
		sched = val;

		modified = rs->GetValue("dt_modified");

		val = rs->GetValue("id_paramtable");
		pt = val;

		val = rs->GetValue("id_pricelist");
		pl = val;

		val = rs->GetValue("id_sub");
		sub = (V_VT(&val) == VT_NULL) ? -1 : (long) val;

		val = rs->GetValue("id_po");
		po = (V_VT(&val) == VT_NULL) ? -1 : (long) val;


		if (pt == mInputs.mParamTableID)
		{
			// this is our parameter table!

			if (sub == -1 && po == -1)
				mInputs.mDefaultAccountScheduleID = sched;
			else if (sub == -1 && po != -1)
				mInputs.mPOScheduleID = sched;
			else // sub != -1 && po == -1
				mInputs.mICBScheduleID = sched;
		}


		rs->MoveNext();
	}

	cout << "Rate schedule resolution:" << endl;
	cout << "  ICB rate schedule:" << mInputs.mICBScheduleID << endl;
	cout << "  Product offering rate schedule:" << mInputs.mPOScheduleID << endl;
	cout << "  Default account rate schedule:" << mInputs.mDefaultAccountScheduleID << endl;
	return TRUE;
}

BOOL PCRateTest::RateTest()
{
	int testCount = 0;
	BOOL testOk = TRUE;
	
  list<TestSession *>& lst = mTestSessions.GetTestSessions();
  list<TestSession *>::iterator sessit;
  for ( sessit = lst.begin(); sessit != lst.end(); sessit++ )
  {
		testCount++;
		TestSession * test = *sessit;

		MTPipelineLib::IMTSessionPtr session =
			CreateTestSession(mNameID, mSessionServer, *test, NULL);
		if (session == NULL)
		{
			cout << "Unable to create test session" << endl;
			return FALSE;
		}

//		DumpAllProps(session);

//		time_t modifiedAt = mLoader.GetLastModified(mRateSchedule);
		time_t modifiedAt = 0;


#if 0
		DumpAllProps(session);
#endif

		PCRater::RateUsed rateUsed = PCRater::RATE_USED_DEFAULT_ACCOUNT; // set as default
    //BP TODO: fix the test
		if (false)//!mRater.Rate(session, mInputs, rateUsed))
		{
			cout << "UNABLE TO GET ANY RATES" << endl;
		}
		else
		{
			switch (rateUsed)
			{
			case PCRater::RATE_USED_ICB:
				cout << "ICB/Subscription rate schedule used: " << mInputs.mICBScheduleID << endl;
				break;
			case PCRater::RATE_USED_PO:
				cout << "Product offering rate schedule used: " << mInputs.mPOScheduleID << endl;
				break;
			case PCRater::RATE_USED_DEFAULT_ACCOUNT:
				cout << "Default account rate schedule used: "
						 << mInputs.mDefaultAccountScheduleID << endl;
				break;
			default:
				cout << "ERROR: Unknown rate schedule used!" << endl;
				return FALSE;
			}
		}
		cout << "-- Session properties --" << endl;
		DumpAllProps(session);

//		::Sleep(3 * 1000);

	}

	return TRUE;
}


#if 0
//
// test price list chaining.
// this test assumes that test rate schedules exist.
// each rate schedule has
//   one condition called "condition" equal to the schedule ID.
//   one action called "result2" equal to the schedule ID
//

BOOL PCRateTest::ChainTest(int aRateSchedule1, int aRateSchedule2, int aRateSchedule3)
{
	// doesn't matter
	int serviceID = 123;

	// generate a UID for this session.
	string uidString;
	unsigned char uid[16];
	MSIXUidGenerator::Generate(uidString);
	MSIXUidGenerator::Decode(uid, uidString);

	// create a parent or child session as appropriate
	MTPipelineLib::IMTSessionPtr session;
	session = mSessionServer->CreateSession(uid, serviceID);

	RateInputs inputs;


	typedef PCRater::ChainRule ChainRule;
	typedef PCRater::RateUsed RateUsed;

	enum ScheduleChoice
	{
		NO_RS, HAVE_RS
	};

	enum WillMatch
	{
		ONE, TWO, THREE, NONE
	};

	struct Test
	{
		PCRater::ChainRule mChainRule;

		ScheduleChoice mICBSchedule;
		ScheduleChoice mPOSchedule;
		ScheduleChoice mDASchedule;

		WillMatch m
	};


	Test chainTests[] =
	{
		//
		// all chaining on
		//

		// all three match
		{ PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE_ALL,
			HAVE_RS,	HAVE_RS, HAVE_RS,
			ONE, RATE_USED_ICB },

		{ PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE_ALL,
			HAVE_RS,	HAVE_RS, HAVE_RS,
			TWO, RATE_USED_PO },

		{ PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE_ALL,
			HAVE_RS,	HAVE_RS, HAVE_RS,
			THREE, RATE_USED_DEFAULT_ACCOUNT },

		// ICB and PO match
		{ PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE_ALL,
			HAVE_RS,	HAVE_RS, NO_RS,
			ONE, RATE_USED_ICB },

		{ PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE_ALL,
			HAVE_RS,	HAVE_RS, NO_RS,
			TWO, RATE_USED_PO },

		{ PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE_ALL,
			HAVE_RS,	HAVE_RS, NO_RS,
			THREE, RATE_USED_NONE },

	};

	//      rates  chain
	// icb:  1
	// po:   2      Y
	// da:   3      Y
 	//
	// 1, 2, or 3
	
	//      rates  chain
	// icb:  1
	// po:   2      Y
	// da:   3      N
	//
	// 1 or 2

	//      rates  chain
	// icb:  1
	// po:   2      N
	// da:   3      N
	//
	// 1 only








	return TRUE;
}

BOOL PCRateTest::TestChainConfiguration(MTPipelineLib::IMTSessionPtr aSession,
																				int aParamTableID,
																				int aRateSchedule1, int aRateSchedule2,
																				int aRateSchedule3,
																				int aExpected)
{
	RateInputs inputs;
	inputs.mPI = -1;
	inputs.mParamTableID = aParamTableID;

	inputs.mICBScheduleID = aRateSchedule1;
	inputs.mICBScheduleModified = 0;
	inputs.mPOScheduleID = aRateSchedule2;
	inputs.mPOScheduleModified = 0;
	inputs.mDefaultAccountScheduleID = aRateSchedule3;
	inputs.mDefaultAccountScheduleModified = 0;

	PCRater::RateUsed rateUsed;
	BOOL foundRates = mRater.Rate(aSession, inputs, rateUsed);
	switch (rateUsed)
	{
	case PCRater::RATE_USED_ICB:
		cout << "ICB/Subscription rate schedule used: " << mInputs.mICBScheduleID << endl;
		break;
	case PCRater::RATE_USED_PO:
		cout << "Product offering rate schedule used: " << mInputs.mPOScheduleID << endl;
		break;
	case PCRater::RATE_USED_DEFAULT_ACCOUNT:
		cout << "Default account rate schedule used: "
				 << mInputs.mDefaultAccountScheduleID << endl;
		break;
	default:
		cout << "ERROR: Unknown rate schedule used!" << endl;
		return FALSE;
	}


}
#endif


BOOL PCRateTest::SetupRateTest()
{
	if (!ReadTestSetup(mConfig, mTestSessions, mTestFilename.c_str()))
		return FALSE;

	return TRUE;
}

void PCRateTest::Usage(const char * apProgName)
{
	cout << "Usage: " << apProgName << " [options] FILE" << endl
			 << "Options:" << endl
			 << "--scheduleid=NUM       rate schedule ID (when using only 1)" << endl
			 << "--icbrs=NUM            ICB rate schedule ID" << endl
			 << "--pors=NUM             product offering rate schedule ID" << endl
			 << "--dars=NUM             default account rate schedule ID" << endl
			 << "--accountid=NUM        account ID" << endl
			 << "--piid=NUM             priceable item ID" << endl
			 << "--paramtable=name      parameter table ID" << endl
			 << "--disablechain=defaultaccount|all  disable some or all pricelist chaining" << endl
			 << "--toxml                convert the given rate schedule to XML" << endl
			 << "--usage                print usage" << endl
			 << "FILE                   autosdk format file to use to test rating" << endl;
}

int PCRateTest::ParseArgs(int argc, char * * argv)
{
	mInputs.mICBScheduleID = -1;
	mInputs.mPOScheduleID = -1;
	mInputs.mDefaultAccountScheduleID = -1;
	mInputs.mParamTableID = -1;

	mAccountID = -1;
	mPriceableItemID = -1;

	mTestFilename.resize(0);
	mToXML = FALSE;

	// --icbrs=100 --pors=101 --dars=102 --paramtableid=1 myfile.xml

  // the program name
  const char *progname = argv[0];
  // the default return value is initially 0 (success)
  int retval = 0;

	// use this while trying to parse a numeric argument
	char ignored;

  // short options string
  char *shortopts = "s:i:p:d:t:ux";
  // long options list
  struct option longopts[] =
  {
    // name,						has_arg,								flag,		val    // longind
    { "scheduleid",			required_argument,			0,			's' }, //       0
    { "icbrs",					required_argument,			0,			'i' }, //       1
    { "pors",						required_argument,			0,			'p' }, //       2
    { "dars",						required_argument,			0,			'd' }, //       3
    { "paramtable",			required_argument,			0,			't' }, //       4
    { "toxml",					no_argument,						0,			'x' }, //       5
    { "disablechain",		required_argument,			0,			0   }, //       6
    { "usage",					no_argument,						0,			'u' }, //       7
    { "accountid",			required_argument,			0,			'a' }, //       8
    { "piid",						required_argument,			0,			0   }, //       9
    // end-of-list marker
    { 0, 0, 0, 0 }
  };

  // long option list index
  int longind = 0;


  // during argument parsing, opt contains the return value from getopt()
  int opt;
	while ((opt = getopt_long_only(argc, argv, shortopts, longopts, &longind)) != EOF)
	{
		BOOL badArg = FALSE;
		switch (opt)
		{
		case 0:											// long option without equivalent short option
			// switch on longind here
			switch (longind)
			{

				// --disablechain
			case 6:
				if (0 == strcmp(optarg, "defaultaccount"))
				{
					cout << "disabling chaining between product offering and default account" << endl;
					mRater.SetChainRule(PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE_PO_ONLY);
				}
				else if (0 == strcmp(optarg, "all"))
				{
					cout << "disabling chaining between all levels" << endl;
					mRater.SetChainRule(PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE_NONE);
				}
				else
				{
					cerr << progname
							 << " disablechain argument " << optarg
							 << " is not 'defaultaccount' or 'all'" << endl;
					badArg = TRUE;
				}
				break;

				// --piid
			case 9:
				ASSERT(optarg);
				if (sscanf(optarg, "%d%c", &mPriceableItemID, &ignored) != 1)
				{
					cerr << progname
							 << " priceable item ID " << optarg << " is not a number" << endl;
					badArg = TRUE;
				}
				break;

			default: // something unexpected has happened
				cerr << progname
						 << " getopt_long_only unexpectedly returned " << opt
						 << "for `--" << longopts[longind].name << "'" << endl;
				badArg = TRUE;
				break;
			}
			break;
		case 'a':										// --accountid=100
			ASSERT(optarg);
			if (sscanf(optarg, "%d%c", &mAccountID, &ignored) != 1)
			{
				cerr << progname
						 << " account ID " << optarg << " is not a number" << endl;
				badArg = TRUE;
			}
			break;
		case 's':										// --scheduleid=100
			ASSERT(optarg);
			if (sscanf(optarg, "%d%c", &mInputs.mDefaultAccountScheduleID, &ignored) != 1)
			{
				cerr << progname
						 << " rate schedule ID " << optarg << " is not a number" << endl;
				badArg = TRUE;
			}
			break;
		case 'i':										// --icbrs=100
			ASSERT(optarg);
			if (sscanf(optarg, "%d%c", &mInputs.mICBScheduleID, &ignored) != 1)
			{
				cerr << progname
						 << " icb rate schedule ID " << optarg << " is not a number" << endl;
				badArg = TRUE;
			}
			break;
		case 'p':										// --pors=100
			ASSERT(optarg);
			if (sscanf(optarg, "%d%c", &mInputs.mPOScheduleID, &ignored) != 1)
			{
				cerr << progname
						 << " product offering rate schedule ID " << optarg << " is not a number"
						 << endl;
				badArg = TRUE;
			}
			break;
		case 'd':										// --dars=100
			ASSERT(optarg);
			if (sscanf(optarg, "%d%c", &mInputs.mDefaultAccountScheduleID, &ignored) != 1)
			{
				cerr << progname
						 << " default account rate schedule ID " << optarg << " is not a number"
						 << endl;
				badArg = TRUE;
			}
			break;
		case 't':										// --paramtable=100
			ASSERT(optarg);
			mInputs.mParamTableID = LookupParamTableID(optarg);
			if (mInputs.mParamTableID == -1)
			{
				cerr << progname
						 << " parameter table " << optarg << " not found"
						 << endl;
				badArg = TRUE;
			}
#if 0
			if (sscanf(optarg, "%d%c", &mInputs.mParamTableID, &ignored) != 1)
			{
				cerr << progname
						 << " parameter table ID " << optarg << " is not a number"
						 << endl;
				badArg = TRUE;
			}
#endif
			break;

		case 'x':
			mToXML = TRUE;
			break;

		case 'u':
			Usage(progname);
			return 1;
		default:
//			cerr << progname
//					 << " getopt_long_only unexpectedly returned " << opt << endl;
			return 1;
		}

		if (badArg)
		{
			Usage(progname);
			return 1;
		}

	}

#if 0
	if (optind != (argc - 1))
	{
		Usage(progname);
		return 1;
	}
#endif

	if (optind == (argc - 1))
		mTestFilename = argv[optind];

	return 0;
}

BOOL PCRateTest::Test()
{
	if (mToXML)
	{
		MTPRODUCTCATALOGLib::IMTRuleSetPtr ruleset("MTRuleSet.MTRuleSet.1");

		// populate the CachedRateSchedule object
		CachedRateSchedulePropGenerator * rawSchedule =
			mDBLoader.CreateRateSchedule(mInputs.mParamTableID,
																	 0);

		_variant_t vtNull;
    vtNull.ChangeType(vtNull);

    mDBLoader.LoadRateScheduleToRuleSet(ruleset, mInputs.mParamTableID,
																				mInputs.mDefaultAccountScheduleID,
																				rawSchedule, vtNull);
		MTPipelineLib::IMTConfigPropSetPtr propset = ruleset->WriteToSet();
		_bstr_t buffer = propset->WriteToBuffer();
		cout << (const char *) buffer << endl;

		if (rawSchedule->IsIndexed())
		{
			const CachedRateSchedule::IndexedRulesVector & index = rawSchedule->GetIndex();

			for (int i = 0; i < (int) index.size(); i++)
			{
				MTautoptr<IndexedRules> indexEntry = index[i];
				MTDecimal start = indexEntry->mStart;
				MTDecimal end = indexEntry->mEnd;

        /*

				MTPipelineLib::IMTRuleSetPtr rs = indexEntry.mRules;

				MTPipelineLib::IMTConfigPropSetPtr propset = rs->WriteToSet();
				_bstr_t buffer = propset->WriteToBuffer();
				cout << "Range: " << start.Format().c_str() << " to "
						 << end.Format().c_str() << endl;
				cout << (const char *) buffer << endl;				
        */

			}
		}
	}
	else if (mAccountID != -1)
	{
		if (!SetupRateTest())
		{
			cout << "Unable to initialize" << endl;
			return FALSE;
		}

		if (!RSResolution())
		{
			cout << "Unable to do rate schedule resolution" << endl;
			return FALSE;
		}

		if (!RateTest())
		{
			cout << "Test failed" << endl;
			return FALSE;
		}
	}
	else
	{
		if (!SetupRateTest())
		{
			cout << "Unable to initialize" << endl;
			return FALSE;
		}

		if (!RateTest())
		{
			cout << "Test failed" << endl;
			return FALSE;
		}
	}
	return TRUE;
}

int main(int argc, char * * argv)
{
	try
	{
		PCRateTest test;
		int retval = test.ParseArgs(argc, argv);
		if (retval != 0)
			return retval;

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

