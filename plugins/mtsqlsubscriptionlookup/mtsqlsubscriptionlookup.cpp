/**************************************************************************
 * MTSQL
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
 * Created by: David Blair
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <BatchPlugInSkeleton.h>
using std::string;
#include <strstream>
using std::istrstream;
#include <map>
using std::map;

#include "MTSQLInterpreter.h" 
#include "MTSQLInterpreterSessionInterface.h" 
#include "BatchQuery.h"
#include "perflog.h"


// generate using uuidgen
CLSID CLSID_MTSQLSubscriptionLookup = { /* 317e7a0e-ab7c-454b-90c2-52a70d2d181d */
    0x9ab49de0,
    0x7250,
    0x46ab,
    {0xa2, 0x39, 0xab, 0x8e, 0x96, 0xa0, 0xc1, 0xbc}
  };

class SubscriptionOption
{
public:
  _bstr_t Name;
  _bstr_t DestinationProperty;
  SubscriptionOption(_bstr_t name, _bstr_t dest) : Name(name), DestinationProperty(dest) {}
};

class ATL_NO_VTABLE MTSQLSubscriptionLookupPlugIn
	: public MTBatchPipelinePlugIn<MTSQLSubscriptionLookupPlugIn, &CLSID_MTSQLSubscriptionLookup>
{
public:
	MTSQLSubscriptionLookupPlugIn() :
		mInterpreter(NULL),
		mEnv(NULL)
	{ }

protected:
	// Initialize the processor, looking up any necessary property IDs.
	// The processor can also use this time to do any other necessary initialization.
	// NOTE: This method can be called any number of times in order to
	//  refresh the initialization of the processor.
	virtual HRESULT BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																			MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																			MTPipelineLib::IMTNameIDPtr aNameID,
																			MTPipelineLib::IMTSystemContextPtr aSysContext);
	virtual HRESULT BatchPlugInInitializeDatabase();
	virtual HRESULT BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSessionSet);
	virtual HRESULT BatchPlugInShutdownDatabase();

private:
	MTSQLInterpreter* mInterpreter;
	MTSQLExecutable* mExe;
  BatchQuery * mQuery;
	MTSQLSessionCompileEnvironment* mEnv;
	MTPipelineLib::IMTLogPtr mLogger;	
  MTPipelineLib::IMTNameIDPtr mNameID;
  _bstr_t mProgram;
  _bstr_t mTempTableName;
  _bstr_t mTagName;

  _bstr_t mAccountId;
  _bstr_t mTimestamp;

  _bstr_t GenerateProgram();

  std::vector<SubscriptionOption*> mSubscriptionOptions;
};


PLUGIN_INFO(CLSID_MTSQLSubscriptionLookup, MTSQLSubscriptionLookupPlugIn,
						"MetraPipeline.SubscriptionLookup.1", "MetraPipeline.SubscriptionLookup", "Free")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTSQLSubscriptionLookupPlugIn::BatchPlugInConfigure"
HRESULT MTSQLSubscriptionLookupPlugIn::BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																								MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																								MTPipelineLib::IMTNameIDPtr aNameID,
																								MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	try {
    mInterpreter = NULL;
    mExe = NULL;
    mQuery = NULL;
    mEnv = NULL;
		mLogger = aLogger;
    mNameID = aNameID;
    mAccountId = aPropSet->NextStringWithName("AccountID");
    mTimestamp = aPropSet->NextStringWithName("Timestamp");

    MTPipelineLib::IMTConfigPropSetPtr pos = aPropSet->NextSetWithName(L"ProductOfferings");
    if (pos != NULL)
		{
      MTPipelineLib::IMTConfigPropSetPtr po = NULL;
			while((po = pos->NextSetWithName(L"ProductOffering")) != NULL)
      {
        _bstr_t name = po->NextStringWithName("Name");
        _bstr_t destprop = po->NextStringWithName("DestinationProperty");
        mSubscriptionOptions.push_back(new SubscriptionOption(name, destprop));
      }
    }
    
    //read in productr offerings wubscription to which we want to lookup
		mProgram = GenerateProgram();
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_INFO, mProgram);
    // TODO: set the table name for arguments.  Really doesn't have
    // to be a temp table; in fact it shouldn't be because of some DTC
    // strangeness we have seen.
    mTempTableName = "tmp_subscriptionlookup";
    mTagName = GetTagName(aSysContext);
	} catch (MTSQLException& ex) {
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,_bstr_t(ex.toString().c_str()));
		return E_FAIL;
	}

	return S_OK;
}

class RuntimeVector : public std::vector<MTSQLSessionRuntimeEnvironment<> * >
{
public:
  ~RuntimeVector()
  {
    for(unsigned int i=0; i<this->size(); i++)
    {
      delete this->operator[](i);
    }
  }
};


/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

HRESULT MTSQLSubscriptionLookupPlugIn::BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)
{
	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(aSet);
	if (FAILED(hr))
		return hr;

	HRESULT errHr = S_OK;

  // Create a runtime environment wrapper for each session.
  // Place the activation record for the runtime environment 
  // into a vector.
  RuntimeVector runtimes;
  std::vector<ActivationRecord* > activations;
  bool first = true;
  MTPipelineLib::IMTSessionPtr firstSession;
	MTPipelineLib::IMTTransactionPtr transaction;
	while (TRUE)
	{
		MTPipelineLib::IMTSessionPtr session = it.GetNext();
		if (session == NULL)
			break;

		if (first)
		{
			first = false;

			// Get the txn from the first session in the set.
			// don't begin a new transaction unless 
			transaction = GetTransaction(session);

      firstSession = session;
		}

    MTSQLSessionRuntimeEnvironment<> * renv = new MTSQLSessionRuntimeEnvironment<>(mLogger, session, firstSession);
    runtimes.push_back(renv);
    activations.push_back(renv->getActivationRecord());
	}

  // Know just execute the query; it knows how to put the
  // results back into the sessions.
  try
  {
    ITransactionPtr mTransaction;
    if (transaction != NULL)
    {
      ITransactionPtr itrans = transaction->GetTransaction();
      ASSERT(itrans != NULL);
      mTransaction = itrans;
    }
    mQuery->ExecuteQuery(activations, mTransaction);
  }
  catch (MTSQLUserException& uex) 
  {
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(uex.toString().c_str()));
    return uex.GetHRESULT();
  } 
  catch (MTSQLException& ex) 
  {
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,_bstr_t(ex.toString().c_str()));
    return E_FAIL;
  }

	return S_OK;
}

HRESULT MTSQLSubscriptionLookupPlugIn::BatchPlugInInitializeDatabase()
{
  try {
    // this is a read-only plugin, so retry is safe
    AllowRetryOnDatabaseFailure(TRUE);

    // The only piece of database state we maintain is in the
    // BatchQuery object.  For paranoia sake (and simplicity of code), we recompile everything
    // though.
		mEnv = new MTSQLSessionCompileEnvironment(mLogger, mNameID);
		mInterpreter = new MTSQLInterpreter(mEnv);
    mInterpreter->setTempTable((const char *) mTempTableName, (const char *)mTagName);
		mExe = mInterpreter->analyze((const wchar_t *)mProgram);
		if (NULL == mExe) 
		{
			string err("Error compiling program");
			return Error(err.c_str());
		}
    mQuery = mInterpreter->analyzeQuery();
		if (NULL == mQuery) 
		{
			string err("Error transforming query");
			return Error(err.c_str());
		}
	} catch (MTSQLException& ex) {
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,_bstr_t(ex.toString().c_str()));
		return E_FAIL;
	}
  return S_OK;
}

HRESULT MTSQLSubscriptionLookupPlugIn::BatchPlugInShutdownDatabase()
{
	if (!mInterpreter)
	{
		delete mInterpreter;
		mInterpreter = NULL;
	}

  mExe = NULL;

	if (!mQuery)
	{
		delete mQuery;
		mQuery = NULL;
	}

	if (!mEnv)
	{
		delete mEnv;
		mEnv = NULL;
	}

  while(mSubscriptionOptions.size() > 0)
	{
		delete mSubscriptionOptions.back();
		mSubscriptionOptions.pop_back();
	}


	return S_OK;
}

_bstr_t MTSQLSubscriptionLookupPlugIn::GenerateProgram()
{
  _bstr_t expandedsubview =
   "/* Inline t_vw_expanded_sub view in here to avoid optimizer hickups */" \
   "\n(SELECT " \
   "\nsub.id_sub, " \
   "\nCASE WHEN sub.id_group IS NULL THEN sub.id_acc ELSE mem.id_acc END id_acc, " \
   "\nsub.id_po, " \
   "\nCASE WHEN sub.id_group IS NULL THEN sub.vt_start ELSE mem.vt_start END vt_start, " \
   "\nCASE WHEN sub.id_group IS NULL THEN sub.vt_end ELSE mem.vt_end END vt_end, " \
   "\nsub.dt_crt, " \
   "\nsub.id_group, " \
   "\ngsub.id_usage_cycle as id_group_cycle, " \
   "\nCASE WHEN sub.id_group IS NULL THEN 'N' ELSE gsub.b_supportgroupops END b_supportgroupops " \
   "\nFROM  " \
   "\nt_sub sub  " \
   "\nLEFT OUTER JOIN t_group_sub gsub ON gsub.id_group = sub.id_group " \
   "\nLEFT OUTER JOIN t_gsubmember mem ON mem.id_group = gsub.id_group) ";

  /*
  CREATE PROCEDURE SubscriptionOptions
				  @_AccountID INTEGER,
				  @_Timestamp TIME,
				  @SubscribedToSimpleProductOffering BOOLEAN OUTPUT,
				  @SubscribedToStarmap BOOLEAN OUTPUT,
				  @SubscribedToSomethingElse BOOLEAN OUTPUT,
				AS
select
CAST(COUNT(in.name0) AS CHAR(1))
,CAST(COUNT(in.name1) AS CHAR(1))
,CAST(COUNT(in.name2) AS CHAR(1))
INTO @SubscribedToSimpleProductOffering, @SubscribedToStarmap, @SubscribedToSomethingElse
FROM 
(
SELECT
mem.id_acc
,bp0.nm_name name0
,bp1.nm_name name1
,bp2.nm_name name2
FROM t_gsubmember mem
INNER JOIN t_group_sub gsub ON gsub.id_group = mem.id_group 
INNER JOIN t_sub sub ON sub.id_group = gsub.id_group
INNER JOIN t_po po on sub.id_po = po.id_po
LEFT OUTER JOIN t_base_props bp0 on po.id_po = bp0.id_prop AND bp0.nm_name = 'OptionMobile'
LEFT OUTER JOIN t_base_props bp1 on po.id_po = bp1.id_prop AND bp1.nm_name = 'OptionCity'
LEFT OUTER JOIN t_base_props bp2 on po.id_po = bp2.id_prop AND bp2.nm_name = 'OptionLocal'
WHERE mem.id_acc = @_AccountID
AND @_Timestamp BETWEEN mem.vt_Start and mem.vt_end
UNION ALL
SELECT
sub.id_acc
,bp0.nm_name name0
,bp1.nm_name name1
,bp2.nm_name name2
FROM 
t_sub sub 
INNER JOIN t_po po on sub.id_po = po.id_po
LEFT OUTER JOIN t_base_props bp0 on po.id_po = bp0.id_prop AND bp0.nm_name = 'OptionMobile'
LEFT OUTER JOIN t_base_props bp1 on po.id_po = bp1.id_prop AND bp1.nm_name = 'OptionCity'
LEFT OUTER JOIN t_base_props bp2 on po.id_po = bp2.id_prop AND bp2.nm_name = 'OptionLocal'
WHERE sub.id_group IS NULL AND sub.id_acc = @_AccountID
AND @_Timestamp BETWEEN sub.vt_Start and sub.vt_end
) in

  */
  char buf[2048];
  _bstr_t proplist;
  _bstr_t setlist = "\nAS";
  _bstr_t intolist = "\nINTO";
  _bstr_t outerselectlist = "\nSELECT";
  _bstr_t openinnerquery = "\nFROM\n(";
  _bstr_t unionall = "\nUNION ALL";
  _bstr_t closeinnerquery = "\n) foo";
  _bstr_t selectlist1 = "\nSELECT\nmem.id_acc";
  _bstr_t selectlist2 = "\nSELECT\nsub.id_acc";
  _bstr_t fromlist1 = "\nFROM t_gsubmember mem"
    "\nINNER JOIN t_group_sub gsub ON gsub.id_group = mem.id_group "
    "\nINNER JOIN t_sub sub ON sub.id_group = gsub.id_group"
    "\nINNER JOIN t_po po on sub.id_po = po.id_po";
  _bstr_t fromlist2 = "\nFROM t_sub sub"
    "\nINNER JOIN t_po po on sub.id_po = po.id_po";
  _bstr_t program = ""; 
  _bstr_t where1;
  _bstr_t where2;
	_bstr_t groupby = "\nGROUP BY foo.id_acc";
  sprintf(buf, "CREATE PROCEDURE SubscriptionOptions \n @%s INTEGER\n, @%s DATETIME\n", 
    (char*)mAccountId, (char*)mTimestamp);
  program += buf;
  bool first = true;

  for (unsigned int i = 0; i < mSubscriptionOptions.size(); i++)
  {
    _bstr_t name = mSubscriptionOptions[i]->Name;
    _bstr_t dest = mSubscriptionOptions[i]->DestinationProperty;
    sprintf(buf, ",@%s BOOLEAN OUTPUT\n", (char*)dest);
    proplist += buf;
		
		sprintf(buf, "\n%sCAST(CASE WHEN COUNT(name%d) > 0 THEN 1 ELSE 0 END AS VARCHAR(1))", first ? "" : ",", i);
    outerselectlist += buf;
		sprintf(buf, "\n,bp%d.nm_name name%d", i, i);
		selectlist1 += buf;
		selectlist2 += buf;
    sprintf(buf, "\n%s@%s", first ? "" : ",", (char*)dest);
    intolist += buf;
    sprintf(buf, 
      "\nleft outer join t_base_props bp%d on po.id_po = bp%d.id_prop AND bp%d.nm_name = '%s'", i, i, i, (char*)name);
    fromlist1 += buf;
    fromlist2 += buf;

    first = false;
  }
  sprintf(buf, "\nWHERE mem.id_acc = @%s AND @%s BETWEEN mem.vt_Start and mem.vt_end", (char*)mAccountId, (char*)mTimestamp);
  where1 = buf;
  sprintf(buf, "\nWHERE sub.id_group IS NULL AND sub.id_acc = @%s AND @%s BETWEEN sub.vt_Start and sub.vt_end", (char*)mAccountId, (char*)mTimestamp);
  where2 = buf;
  program = program + proplist + setlist + outerselectlist + intolist + openinnerquery + selectlist1 + fromlist1 + where1 + unionall + selectlist2 + fromlist2 + where2 + closeinnerquery + groupby;
  return program;
}
