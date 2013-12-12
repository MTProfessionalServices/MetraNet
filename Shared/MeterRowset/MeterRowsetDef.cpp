// MeterRowsetDef.cpp : Implementation of CMeterRowset
#include "StdAfx.h"
#include "MeterRowset.h"
#include "MeterRowsetDef.h"

#include <mtcomerr.h>
#include <mtprogids.h>
#include <mtglobal_msg.h>

#include <loggerconfig.h>
#include <DBMiscUtils.h>
#include <MSIX.h>
#include <perflog.h>

#import <MTServerAccess.tlb>

/////////////////////////////////////////////////////////////////////////////
// CMeterRowset
STDMETHODIMP CMeterRowset::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMeterRowset
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}

	return S_FALSE;
}

STDMETHODIMP CMeterRowset::FinalConstruct()
{

	// the default SessionSet size is one (pre-performance semantics)
	mSessionSetSize = 1;

  mTransactionID = L"";
  mListenerTransactionID = L"";

  mbSync = false;
  mlSyncRetries = 0;
  mlSyncSleep = 0;

	//load services collection
	if (!mServices.Initialize())
		return Error(L"Unable to initialize services collection", IID_IMeterRowset,  mServices.GetLastError()->GetCode());

	HRESULT hr = mEnumConfig.CreateInstance(__uuidof(MTENUMCONFIGLib::EnumConfig));
	if(FAILED(hr))
		return Error(L"Unable to create EnumConfig object", IID_IMeterRowset,  hr);

	LoggerConfigReader configReader;

	if (!mLogger.Init(configReader.ReadConfiguration("logging"), "[MeterRowset]"))
		return Error("Unable to initialize logger");

	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &m_pUnkMarshaler.p);
}


CMeterRowset::~CMeterRowset() 
{
	//deletes column maps
	ServiceColumnMap::iterator it;
	for (it = mServiceColumnMap.begin(); it != mServiceColumnMap.end(); it++) {
		ColumnMap* pColumnMap = it->second;
		delete pColumnMap;
	}
} 

DataType MSIXToDataType(CMSIXProperties::PropertyType aType)
{
	switch (aType)
	{
	case CMSIXProperties::TYPE_STRING:
		return MTC_DT_CHAR;
	case CMSIXProperties::TYPE_WIDESTRING:
		return MTC_DT_WCHAR;
	case CMSIXProperties::TYPE_INT32:
		return MTC_DT_INT;
	case CMSIXProperties::TYPE_INT64:
		return MTC_DT_BIGINT;
	case CMSIXProperties::TYPE_TIMESTAMP:
		return MTC_DT_WCHAR;							// TODO:
	case CMSIXProperties::TYPE_FLOAT:
	case CMSIXProperties::TYPE_DOUBLE:
		return MTC_DT_DOUBLE;
	case CMSIXProperties::TYPE_NUMERIC:
		return MTC_DT_DECIMAL;
	case CMSIXProperties::TYPE_DECIMAL:
		return MTC_DT_DECIMAL;
	case CMSIXProperties::TYPE_ENUM:
		return MTC_DT_ENUM;
	case CMSIXProperties::TYPE_BOOLEAN:
		return MTC_DT_BOOL;
	default:
		ASSERT(0);
		return MTC_DT_WCHAR;
	}
}

HRESULT CMeterRowset::AddColumnMappingsFromService(const wstring& aServiceName)
{
	try {

		std::wstring serviceName(aServiceName);
		StrToLower(serviceName);

		//creates a new column map for the child rowset
		ColumnMap* pColumnMap = new ColumnMap;
		if(!pColumnMap)
			return E_OUTOFMEMORY;
	
		//maps the service name to the column map
		
		// TODO: leaks maps if service names are the same (i.e. multiple children rowsets) 
		mServiceColumnMap[serviceName] = pColumnMap;

		CMSIXDefinition * service = NULL;
		if (!mServices.FindService(serviceName.c_str(), service))
		{
			std::wstring buffer(L"Service name ");
			buffer += aServiceName;
			buffer += L" not found";
			return Error(buffer.c_str(), IID_IMeterRowset, MT_ERR_UNKNOWN_SERVICE);
		}

		//
		// create a mapping for each property
		//
		MSIXPropertiesList & props = service->GetMSIXPropertiesList();
		MSIXPropertiesList::iterator it;
		for (it = props.begin(); it != props.end(); ++it)
		{
			CMSIXProperties * prop = *it;
			CMSIXProperties::PropertyType type = prop->GetPropertyType();
			BOOL required = prop->GetIsRequired();

			DataType dataType = MSIXToDataType(type);

			std::wstring column(L"c_");
			column += prop->GetDN();

			_bstr_t columnBstr(column.c_str());
			_bstr_t propName(prop->GetDN().c_str());
			HRESULT hr = AddColumnMapping(columnBstr,
																		dataType,
																		propName,
																		required ? VARIANT_TRUE : VARIANT_FALSE,
																		serviceName);
			if (FAILED(hr))
				return hr;
		}
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }


	return S_OK;
}

STDMETHODIMP CMeterRowset::InitForService(BSTR serviceName)
{
	mServiceName = serviceName;
	return AddColumnMappingsFromService(mServiceName);
}

STDMETHODIMP CMeterRowset::AddCommonProperty(BSTR aName, DataType aType, VARIANT aValue)
{
	try
	{
		CommonProp prop;
		prop.Init(aName, aType, aValue);
		mCommonPropList.push_back(prop);
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

//adds a column mapping for the rowset (the parent rowset in the case of a compound)
STDMETHODIMP CMeterRowset::AddColumnMapping(BSTR aColumnName, DataType aPropType,
																						BSTR aPropName, VARIANT_BOOL aRequired) {
	return AddColumnMapping(aColumnName, aPropType,  aPropName, aRequired, mServiceName);
}

//adds a column mapping for the child rowset 
STDMETHODIMP CMeterRowset::AddChildColumnMapping(BSTR aColumnName, DataType aPropType,
																								 BSTR aPropName, VARIANT_BOOL aRequired, BSTR aServiceName) {
	return AddColumnMapping(aColumnName, aPropType,  aPropName, aRequired, aServiceName);
}

HRESULT CMeterRowset::AddColumnMapping(BSTR aColumnName, DataType aPropType,
																			 BSTR aPropName, VARIANT_BOOL aRequired, const std::wstring& aServiceName)
{
	try
	{
		ColumnMapping mapping;
		mapping.Init(aPropName, aPropType, aRequired == VARIANT_TRUE);

		std::wstring col(aColumnName);
		StrToLower(col);
		std::wstring serviceName(aServiceName);
		StrToLower(serviceName);

		//find the column map for the given service
		ServiceColumnMap::const_iterator findMapIt = mServiceColumnMap.find(serviceName);
		if (findMapIt == mServiceColumnMap.end())
			return Error("Could not find column map for service");
		ColumnMap* pColumnMap = findMapIt->second;
		
		pColumnMap->insert(ColumnMap::value_type(col, mapping));
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

STDMETHODIMP CMeterRowset::InitSDK(BSTR aServerAccess)
{
	try
	{
		HRESULT hr = mMeter.CreateInstance(MTPROGID_IMETER);
		if (FAILED(hr))
			return Error(L"Unable to initialize SDK", IID_IMeterRowset, hr);

		mMeter->Startup();

		_bstr_t serverAccessName(aServerAccess);

		MTSERVERACCESSLib::IMTServerAccessDataSetPtr serverAccess(MTPROGID_SERVERACCESS);
		serverAccess->Initialize();

		MTSERVERACCESSLib::IMTServerAccessDataPtr accessSet =
			serverAccess->FindAndReturnObject(serverAccessName);

		mMeter->AddServer(0,				// priority
											accessSet->GetServerName(),	// server name
											(COMMeterLib::PortNumber) accessSet->GetPortNumber(),	// port number
											accessSet->GetSecure() ? TRUE : FALSE, // secure
											accessSet->GetUserName(),	// username
											accessSet->GetPassword()); // password
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}


STDMETHODIMP CMeterRowset::PopulateSession(ISession * session, ::IMTSQLRowset *apRowset)
{
	try
	{
		::IMTSQLRowsetPtr parentRowset(apRowset);

		// premap all the parent columns
		long columns = parentRowset->GetCount();
		ColumnMappingVector parentColumnMappings;
		for (long i = 0; i < columns; i++)
		{
			_bstr_t name = parentRowset->GetName(i);

			const ColumnMapping * mapping = GetColumnMapping(name, mServiceName.c_str());
			// set it even if it's NULL - this means no mapping for that column
			parentColumnMappings.push_back(mapping);
		}

		// premap all the child columns for all child rowsets
		std::vector<const ColumnMappingVector*> childColumnMappingsColl;
		for (unsigned long j = 0; j < mChildRowsets.size(); j++) {
			ChildInfo& child = mChildRowsets[j];
			ColumnMappingVector* pChildColumnMappings = new ColumnMappingVector;
			long columns = child.rowset->GetCount();
			for (long i = 0; i < columns; i++)
			{
				_bstr_t name = child.rowset->GetName(i);
				
				const ColumnMapping * mapping = GetColumnMapping(name, child.serviceName.c_str());
				// set it even if it's NULL - this means no mapping for that column
				pChildColumnMappings->push_back(mapping);
			}
			childColumnMappingsColl.push_back(pChildColumnMappings);
		}

		PopulateSession(session, parentRowset, parentColumnMappings, childColumnMappingsColl);

		//deletes all child column mappings
		for (j = 0; j < childColumnMappingsColl.size(); j++)
			delete childColumnMappingsColl[j];
	}
	catch (_com_error & err)
	{ 
		std::string buffer;
		StringFromComError(buffer, "Unhandled exception", err);
		mLogger.LogThis(LOG_ERROR, buffer.c_str());

		//TODO: don't leak memory from child column mappings (autoptr?)

		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CMeterRowset::InitializeFromRowset(::IMTSQLRowset *apRowset, BSTR serviceName)
{
  try
	{
		mRowset = apRowset;
    mServiceName = serviceName;
	  return AddColumnMappingsFromService(mServiceName);
	}
	catch (_com_error & err)
	{ 
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CMeterRowset::MeterPopulatedRowset()
{
  try
  {
    if(mRowset == NULL)
    {
      std::string buffer;
      mLogger.LogThis(LOG_ERROR, buffer.c_str());
      MT_THROW_COM_ERROR(E_POINTER, buffer.c_str());
    }
    HRESULT hr = MeterRowset(reinterpret_cast<::IMTSQLRowset*>(mRowset.GetInterfacePtr()));
    if (FAILED(hr))
    {
      MT_THROW_COM_ERROR(hr);
    }
  }
  catch(_com_error &e)
  {
    return ReturnComError(e);
  }
  return S_OK;
}
		
STDMETHODIMP CMeterRowset::MeterRowset(::IMTSQLRowset *apRowset)
{
	MarkRegion region("MeterRowset");
	try
	{
		::IMTSQLRowsetPtr parentRowset(apRowset);


		// premap all the parent columns
		long columns = parentRowset->GetCount();
		ColumnMappingVector parentColumnMappings;
		for (long i = 0; i < columns; i++)
		{
			_bstr_t name = parentRowset->GetName(i);

			const ColumnMapping * mapping = GetColumnMapping(name, mServiceName.c_str());
			// set it even if it's NULL - this means no mapping for that column
			parentColumnMappings.push_back(mapping);
		}

		// premap all the child columns for all child rowsets
		std::vector<const ColumnMappingVector*> childColumnMappingsColl;
		for (unsigned long j = 0; j < mChildRowsets.size(); j++) {
			ChildInfo& child = mChildRowsets[j];
			ColumnMappingVector* pChildColumnMappings = new ColumnMappingVector;
			long columns = child.rowset->GetCount();
			for (long i = 0; i < columns; i++)
			{
				_bstr_t name = child.rowset->GetName(i);
				
				const ColumnMapping * mapping = GetColumnMapping(name, child.serviceName.c_str());
				// set it even if it's NULL - this means no mapping for that column
				pChildColumnMappings->push_back(mapping);
			}
			childColumnMappingsColl.push_back(pChildColumnMappings);
		}

		mLogger.LogVarArgs(LOG_DEBUG, "SessionSet size is: %d", mSessionSetSize);
		mLogger.LogVarArgs(LOG_DEBUG, "About to meter a rowset to '%S'", mServiceName.c_str());
 
		long row = 0;
		long sessionsInSet = 0;
		long parentSessionsInSet = 0;
		ISessionSetPtr sessionSet;

		// if user has called CreateAdapterBatch then this code 
		// should create the session set from the batch object.  
		// Otherwise the session sets aren't related to the batch.
		if (mpBatch)
			sessionSet = mpBatch->CreateSessionSet();
		else
			sessionSet = mMeter->CreateSessionSet();

    if (IsTransactionSet())
      sessionSet->TransactionID = mTransactionID;

    if (IsListenerTransactionSet())
      sessionSet->ListenerTransactionID = mListenerTransactionID;

		while (! (bool) parentRowset->GetRowsetEOF())
		{
			
			ISessionPtr parentSession = sessionSet->CreateSession(mServiceName.c_str());
      
      if(mbSync)
        parentSession->RequestResponse = VARIANT_TRUE;

			unsigned long childSessionCount =
				PopulateSession(parentSession, parentRowset, parentColumnMappings, childColumnMappingsColl);

			// counts the parent plus optional children
			sessionsInSet += 1 + childSessionCount;
			parentSessionsInSet++;

			// if the SessionSet is full
			if (sessionsInSet >= mSessionSetSize)
			{
				try
				{
					// meters it!
					AttemptSessionSetClose(sessionSet);
          mMeteredCount += parentSessionsInSet;
				}
				catch (_com_error & err)
				{
					std::string buffer;
					StringFromComError(buffer, "Unable to meter SessionSet", err);
					mLogger.LogThis(LOG_ERROR, buffer.c_str());
					mLogger.LogVarArgs(LOG_ERROR, "Unable to meter SessionSet ending at row %d", row);
					
					mMeterErrorCount+= parentSessionsInSet;
				}
				
				// creates the next SessionSet
				if (mpBatch)
					sessionSet = mpBatch->CreateSessionSet();
				else
					sessionSet = mMeter->CreateSessionSet();
        
        if (IsTransactionSet())
          sessionSet->TransactionID = mTransactionID;

				if (IsListenerTransactionSet())
					sessionSet->ListenerTransactionID = mListenerTransactionID;

				sessionsInSet = 0;
				parentSessionsInSet = 0;
			}
			
			row++;
			parentRowset->MoveNext();
		}

		
		// meters the final partial SessionSet
		if (sessionsInSet > 0)
		{
			try
			{
				// meter it!
				AttemptSessionSetClose(sessionSet);
				mMeteredCount += parentSessionsInSet;
			}
			catch (_com_error & err)
			{
				std::string buffer;
				StringFromComError(buffer, "Unable to meter final partial SessionSet", err);
				mLogger.LogThis(LOG_ERROR, buffer.c_str());
				mLogger.LogVarArgs(LOG_ERROR, "Unable to meter SessionSet ending at row %d", row);
				
				mMeterErrorCount+= parentSessionsInSet;
 			}
		}

		mLogger.LogVarArgs(LOG_DEBUG, "%d rows successfully metered. %d errors",
											 mMeteredCount, mMeterErrorCount);

		if (mpBatch != NULL && mMeteredCount > 0)
		{
			mLogger.LogVarArgs(LOG_DEBUG, "adding %d to batch metered count",
												 mMeteredCount);

			mpBatch->UpdateMeteredCount();
		}

		//deletes all child column mappings
		for (j = 0; j < childColumnMappingsColl.size(); j++)
			delete childColumnMappingsColl[j];
		
	}
	catch (_com_error & err)
	{ 
		std::string buffer;
		StringFromComError(buffer, "Unhandled exception", err);
		mLogger.LogThis(LOG_ERROR, buffer.c_str());

		//TODO: don't leak memory from child column mappings (autoptr?)

		return ReturnComError(err);
	}

	return S_OK;
}

//throws
unsigned long CMeterRowset::PopulateSession(ISessionPtr parentSession,
																						::IMTSQLRowsetPtr parentRowset,
																						ColumnMappingVector parentColumnMappings,
																						std::vector<const ColumnMappingVector*> childColumnMappingsColl)
{
	//adds properties to parent session
	AddRowToSession(parentSession, parentRowset, parentColumnMappings);

	//handles compound sessions
	unsigned long childSessionCount = 0; //count of all children sessions added for this parent
	unsigned long childRowsetCount = mChildRowsets.size();
	if (childRowsetCount > 0) {
		__int64 parentID = parentRowset->GetValue("id_sess");
		//iterates over child rowsets (each of which may contain multiple child sessions for this compound)
		for (unsigned long i = 0; i < childRowsetCount; i++) {
			ChildInfo& child = mChildRowsets[i];
					
			mLogger.LogVarArgs(LOG_DEBUG, "Searching for children from child rowset: '%S' for parent with id_sess = %d",
												 child.serviceName.c_str(), parentID);
					
			//finds all the rows in the child rowset that are descendants of the parent
			while(! (bool) child.rowset->GetRowsetEOF()) {
						
				//may be null if the child row is not really a child
				_variant_t parentIDfromChild = child.rowset->GetValue("id_parent_sess");
						
				//fast forwards to the section in the rowset where there are children for this parent
				if ((parentIDfromChild.vt == VT_NULL) || ((__int64(parentIDfromChild) < parentID))) {
					child.rowset->MoveNext();
					continue;
				}
						
				//we have passed this parent's ID so don't do anything
				if (__int64(parentIDfromChild) > parentID)
					break;
						
				//creates the child session and adds the properties
				ISessionPtr childSession = parentSession->CreateChildSession(child.serviceName.c_str());
				AddRowToSession(childSession, child.rowset, *childColumnMappingsColl[i]);
				AddCommonPropsToSession(childSession, true);
				childSessionCount++;

				child.rowset->MoveNext();
			}
		}
	}

	AddCommonPropsToSession(parentSession, false);
	return childSessionCount;
}


//throws
void CMeterRowset::AddRowToSession(ISessionPtr& arSession, const ::IMTSQLRowsetPtr& arRowset, const ColumnMappingVector& arColumnMappings) {

	long columns = arRowset->GetCount();
		
	for (long i = 0; i < columns; i++)
	{
		_variant_t val = arRowset->GetValue(i);
		
		//if the column is mapped and the column's value is non-null, then add it as a property
		const ColumnMapping * mapping = arColumnMappings[i];
		if (mapping && (V_VT(&val) != VT_NULL))
		{
			switch (mapping->GetType())
			{
			case MTC_DT_BOOL:
				{
					_bstr_t strVal = val;
					bool istrue = (strVal == _bstr_t(L"1") || strVal == _bstr_t(L"Y") || strVal == _bstr_t(L"y"));
					arSession->InitProperty(mapping->GetPropName(), istrue);
					break;
				}
			case MTC_DT_ENUM:
				{
						//convert localized id back to the enumerator string
						_bstr_t strVal = mEnumConfig->GetEnumeratorByID(val.lVal);

						if (strVal.length() != 0) //only init a property if this isn't the null enumerator
							arSession->InitProperty(mapping->GetPropName(), strVal);
					break;
				}
			case MTC_DT_INT:
				{
						//CR 6300
						//Look at the actual variant type, and if it's decimal, convert to
						//I4
					if(V_VT(&val) == VT_DECIMAL)
					{
						long lVal = (long)val;
						val.ChangeType(VT_I4);
						val = lVal;
					}
				}

			case MTC_DT_BIGINT:
				{
					if(V_VT(&val) == VT_DECIMAL)
					{
						__int64 lVal = (__int64)val;
						val.ChangeType(VT_I8);
						val = lVal;
					}
				}

			default:
				arSession->InitProperty(mapping->GetPropName(), val);
			}
		}
	}
} 


//adds common properties to the given session (throws)
void CMeterRowset::AddCommonPropsToSession(ISessionPtr& arSession, bool aIsChild) {

	CommonPropList::const_iterator commonit;
	for (commonit = mCommonPropList.begin();
			 commonit != mCommonPropList.end();
			 commonit++)
	{
		const CommonProp & common = *commonit;
		
		// HACK: collection ID is added to parents only!
		if (aIsChild)
		{
			if (0 != mtwcscasecmp(common.GetPropName(), L"_CollectionID"))
				arSession->InitProperty(common.GetPropName(), common.GetValue());
		}
		else
			arSession->InitProperty(common.GetPropName(), common.GetValue());
	}
} 



STDMETHODIMP CMeterRowset::put_BatchID(BSTR newVal)
{
	try
	{
		mBatchID = newVal;
		AddCommonProperty(L"_CollectionID", MTC_DT_CHAR, _variant_t(newVal));
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

STDMETHODIMP CMeterRowset::get_BatchID(BSTR* pVal)
{
	try
	{
		// return batch id 
		*pVal = mBatchID.copy();
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

STDMETHODIMP CMeterRowset::GenerateBatchID(BSTR* pVal)
{
	try
	{
		// generate a batch id
		std::string uidString;
		MSIXUidGenerator::Generate(uidString);

		_bstr_t bstrBatchID = uidString.c_str();

		HRESULT hr = put_BatchID(bstrBatchID);
		if(FAILED(hr))
			return hr;
		
		*pVal = mBatchID.copy();
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

STDMETHODIMP CMeterRowset::get_MeteredCount(long *pVal)
{
	*pVal = mMeteredCount;

	return S_OK;
}

STDMETHODIMP CMeterRowset::get_MeterErrorCount(long *pVal)
{
	*pVal = mMeterErrorCount;

	return S_OK;
}

STDMETHODIMP CMeterRowset::get_CommittedCount(long *pVal)
{
	try	{
		// convert batch id from base64 to hex-encoded
		unsigned char uid[16];
		MSIXUidGenerator::Decode(uid, (const char *) (mBatchID));
		_bstr_t strHexBatchID = ConvertSessionIDToString(uid).c_str();

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init("queries\\MeterRowset");
		
    if(IsTransactionSet())
    {
      RowSetInterfacesLib::IMTTransactionPtr tran("PipelineTransaction.MTTransaction");
      tran->Import(mTransactionID);
      rowset->JoinDistributedTransaction
        (reinterpret_cast<ROWSETLib::IMTTransaction*>(tran.GetInterfacePtr()));
    }

		rowset->SetQueryTag("__GET_COMMITTED_COUNT_BY_BATCH_ID__");	
		rowset->AddParam("%%VARBIN_BATCH_ID%%", strHexBatchID);
		rowset->AddParam("%%STRING_BATCH_ID%%",mBatchID);
		rowset->Execute();

		*pVal = rowset->GetValue("committed_count");

		mCommittedSuccessCount = rowset->GetValue("success_count");
		mCommittedErrorCount = rowset->GetValue("error_count");
    rowset = NULL;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

STDMETHODIMP CMeterRowset::get_CommittedErrorCount(long *pVal)
{
	*pVal = mCommittedErrorCount;
	return S_OK;
}

STDMETHODIMP CMeterRowset::get_CommittedSuccessCount(long *pVal)
{
	*pVal = mCommittedSuccessCount;
	return S_OK;
}

STDMETHODIMP CMeterRowset::WaitForCommitWithPause(/*[in]*/ long lExpectedCommitCount, long lTimeOutInSeconds, long lpause)
{
	MarkRegion waitRegion("WaitForCommit");

	time_t start = time(NULL);
	time_t timeout = start + time_t(lTimeOutInSeconds);
	long lSleep = lpause;	// wait for lpause mseconds between checks
	long lLastCommitted = 0;
	long lCommitted = 0;

	MetraTech_UsageServer::IClientPtr usmClient;
	usmClient.CreateInstance(_uuidof(MetraTech_UsageServer::Client));

	mLogger.LogVarArgs(LOG_DEBUG, "Waiting for %d sessions to commit", lExpectedCommitCount);

	while((lTimeOutInSeconds == 0) || (time(NULL) < timeout) )
	{
		lCommitted = 0;
		HRESULT hr = get_CommittedCount(&lCommitted);
		if(FAILED(hr))
		{
			return hr;
		}

		if(lCommitted == lExpectedCommitCount)
		{
			mLogger.LogVarArgs(LOG_DEBUG, "All Metered sessions are committed!");
			return S_OK;
		}

		// that could be that more sessions are committed, than there were metered,
		// e.g. if they were splitted...
		if(lCommitted > lExpectedCommitCount)
		{
			mLogger.LogVarArgs(LOG_DEBUG, "%d sessions were committed, though only %d were metered. That is OK.",
											 lCommitted, lExpectedCommitCount);
			return S_OK;
		}

		// reset the time out if processing continues
		if(lCommitted != lLastCommitted)
		{
			lLastCommitted = lCommitted;
			timeout = time(NULL) + time_t(lTimeOutInSeconds);
			mLogger.LogVarArgs(LOG_DEBUG, "Reset %d out of %d sessions committed in %d seconds. Waiting...",
												 lCommitted, lExpectedCommitCount, time(NULL) - start);

		}

		mLogger.LogVarArgs(LOG_DEBUG, "%d out of %d sessions committed in %d seconds. Waiting...",
											 lCommitted, lExpectedCommitCount, time(NULL) - start);

		// calls into managed code to sleep so that USM kills are responsive
		usmClient->ManagedSleep(lSleep);
	} 

	char msg[256];
	sprintf(msg, "Timeout of %d seconds expired while waiting for batch %s to be committed! committed = %d, expected = %d",
					lTimeOutInSeconds, LPCSTR(mBatchID), lCommitted, lExpectedCommitCount);
	 
	Error(msg);
	return PIPE_ERR_SESSION_COMMIT_TIMEOUT;
}

STDMETHODIMP CMeterRowset::WaitForCommit(/*[in]*/ long lExpectedCommitCount, long lTimeOutInSeconds)
{
	MarkRegion waitRegion("WaitForCommit");

	time_t start = time(NULL);
	time_t timeout = start + time_t(lTimeOutInSeconds);
	long lSleep = 5000;	// wait for 5 seconds between checks
	long lLastCommitted = 0;
	long lCommitted = 0;

	MetraTech_UsageServer::IClientPtr usmClient;
	usmClient.CreateInstance(_uuidof(MetraTech_UsageServer::Client));

	mLogger.LogVarArgs(LOG_DEBUG, "Waiting for %d sessions to commit", lExpectedCommitCount);

	while((lTimeOutInSeconds == 0) || (time(NULL) < timeout) )
	{
		lCommitted = 0;
		HRESULT hr = get_CommittedCount(&lCommitted);
		if(FAILED(hr))
		{
			return hr;
		}

		if(lCommitted == lExpectedCommitCount)
		{
			mLogger.LogVarArgs(LOG_DEBUG, "All Metered sessions are committed!");
			return S_OK;
		}

		// that could be that more sessions are committed, than there were metered,
		// e.g. if they were splitted...
		if(lCommitted > lExpectedCommitCount)
		{
			mLogger.LogVarArgs(LOG_DEBUG, "%d sessions were committed, though only %d were metered. That is OK.",
											 lCommitted, lExpectedCommitCount);
			return S_OK;
		}

		// reset the time out if processing continues
		if(lCommitted != lLastCommitted)
		{
			lLastCommitted = lCommitted;
			timeout = time(NULL) + time_t(lTimeOutInSeconds);
			mLogger.LogVarArgs(LOG_DEBUG, "Reset %d out of %d sessions committed in %d seconds. Waiting...",
												 lCommitted, lExpectedCommitCount, time(NULL) - start);

		}

		mLogger.LogVarArgs(LOG_DEBUG, "%d out of %d sessions committed in %d seconds. Waiting...",
											 lCommitted, lExpectedCommitCount, time(NULL) - start);

		// calls into managed code to sleep so that USM kills are responsive
		usmClient->ManagedSleep(lSleep);
	} 

	char msg[256];
	sprintf(msg, "Timeout of %d seconds expired while waiting for batch %s to be committed! committed = %d, expected = %d",
					lTimeOutInSeconds, LPCSTR(mBatchID), lCommitted, lExpectedCommitCount);
	 
	Error(msg);
	return PIPE_ERR_SESSION_COMMIT_TIMEOUT;
}

STDMETHODIMP CMeterRowset::WaitForCommitEx(/*[in]*/ long lExpectedCommitCount, long lTimeOutInSeconds, BSTR BatchName, BSTR BatchNamespace, BSTR BatchSeqNum)
{
	MarkRegion waitRegion("WaitForCommitEx");

	time_t start = time(NULL);
	time_t timeout = start + time_t(lTimeOutInSeconds);
	long lSleep = 10000;	// wait for 10 seconds between checks
	long lLastCommitted = 0;
	long lCommitted = 0;

	MetraTech_UsageServer::IClientPtr usmClient;
	usmClient.CreateInstance(_uuidof(MetraTech_UsageServer::Client));

	mLogger.LogVarArgs(LOG_DEBUG, "Waiting for %d sessions to commit", lExpectedCommitCount);

	_bstr_t bstrBatchName (BatchName);
	_bstr_t bstrBatchNamespace (BatchNamespace);
	_bstr_t bstrBatchSeqNum (BatchSeqNum);
	IBatchPtr ptrBatch = mMeter->OpenBatchByName(bstrBatchName,
																							 bstrBatchNamespace,
																							 bstrBatchSeqNum);
  mCommittedSuccessCount = 0;
  mCommittedErrorCount = 0;
	while((lTimeOutInSeconds == 0) || (time(NULL) < timeout) )
	{
		_bstr_t bstrBatchStatus = ptrBatch->GetStatus();
		mLogger.LogVarArgs(LOG_DEBUG, "WaitForCommitEx -- Batch Status = <%s>", (const char*)bstrBatchStatus);

    mCommittedSuccessCount = ptrBatch->GetCompletedCount();
		mLogger.LogVarArgs(LOG_DEBUG, "WaitForCommitEx -- Completed Count = <%d>", mCommittedSuccessCount);
		mLogger.LogVarArgs(LOG_DEBUG, "WaitForCommitEx -- Expected Commit Count = <%d>", lExpectedCommitCount);

		if ((bstrBatchStatus == _bstr_t("C")) ||
				(mCommittedSuccessCount == lExpectedCommitCount))
		{
      mCommittedErrorCount = lExpectedCommitCount - mCommittedSuccessCount;
      if (mCommittedErrorCount != 0)
      {
          mLogger.LogVarArgs(LOG_ERROR, "Batch <%s> has completed, but %d sessions failed to commit",
                             LPCSTR(mBatchID), mCommittedErrorCount);
          return PIPE_ERR_SUBSET_OF_BATCH_FAILED;
      }

      mLogger.LogVarArgs(LOG_DEBUG, "All Metered sessions are committed!");
			return S_OK;
		}

		if (bstrBatchStatus == _bstr_t("F"))
		{
			char msg[256];
			sprintf(msg, "Batch <%s> has a failed status", LPCSTR(mBatchID));
			Error(msg);
			return PIPE_ERR_SESSION_COMMIT_FAILED_DUE_TO_FAILED_BATCH;
		}

		// calls into managed code to sleep so that USM kills are responsive
		usmClient->ManagedSleep(lSleep);

		ptrBatch->Refresh();
	} 
  mCommittedErrorCount = lExpectedCommitCount - mCommittedSuccessCount;
  if (mCommittedErrorCount != 0)
  {
      mLogger.LogVarArgs(LOG_ERROR, "Batch <%s> has completed, but %d sessions failed to commit",
                          LPCSTR(mBatchID), mCommittedErrorCount);
      return PIPE_ERR_SUBSET_OF_BATCH_FAILED;
  }

	char msg[256];
	sprintf(msg, "Timeout of %d seconds expired while waiting for batch %s to reach Completed state",
					lTimeOutInSeconds, LPCSTR(mBatchID));
	Error(msg);
	return PIPE_ERR_SESSION_COMMIT_TIMEOUT;
}

STDMETHODIMP CMeterRowset::AddChildRowset(::IMTSQLRowset * apRowset, BSTR aServiceName) 
{
	HRESULT hr = AddColumnMappingsFromService(aServiceName);
	if (FAILED(hr))
		return hr;
	
	ChildInfo child;
	child.serviceName = aServiceName;
	child.rowset = apRowset;
	mChildRowsets.push_back(child);

	return S_OK;
}

STDMETHODIMP CMeterRowset::put_SessionSetSize(long newVal)
{
	mSessionSetSize = newVal;
	return S_OK;
}

STDMETHODIMP CMeterRowset::get_SessionSetSize(long* pVal)
{
	*pVal = mSessionSetSize;
	return S_OK;
}

STDMETHODIMP CMeterRowset::CreateAdapterBatch(long RunID, 
																							BSTR AdapterName, 
																							BSTR SequenceNumber,
																							IBatch** ppNewBatch)
{
	ASSERT(ppNewBatch);
	if (!ppNewBatch) return E_POINTER;

	HRESULT hr(S_OK);

	try
	{
		string strRunID;
		char runID[10];
		ltoa(RunID, runID, 10);
		_bstr_t bstrRunID = runID; 

		IBatchPtr ptrBatch = mMeter->CreateBatch();
	
		ptrBatch->PutName(bstrRunID); // name
		ptrBatch->PutNameSpace(AdapterName); // adapter name
		ptrBatch->PutSequenceNumber(SequenceNumber); // sequence number 
		ptrBatch->PutExpectedCount(0); // metered count
	
		ptrBatch->PutSourceCreationDate(GetMTOLETime());
		ptrBatch->PutSource(AdapterName); 
	
		ptrBatch->PutComment("N/A");
	
		ptrBatch->Save();
	
		mpBatch = ptrBatch;
		mBatchID = mpBatch->GetUID();
		*ppNewBatch = reinterpret_cast<IBatch*>(ptrBatch.Detach());
		
		// once this is successfull, insert a row into the mapping 
		// table
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init("queries\\database");
		rowset->SetQueryTag("__INSERT_INTO_RUN_BATCH_MAPPING_TABLE__");	
		rowset->AddParam("%%RUN_ID%%", RunID);
		rowset->AddParam("%%STRING_BATCH_ID%%", mpBatch->GetUID());
		rowset->Execute();
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}

	return hr;
}

STDMETHODIMP CMeterRowset::CreateAdapterBatchEx(long RunID, 
																								BSTR AdapterName, 
																								BSTR SequenceNumber,
																								IBatch** ppNewBatch)
{
	ASSERT(ppNewBatch);
	if (!ppNewBatch) return E_POINTER;

	HRESULT hr(S_OK);

	try
	{
		string strRunID;
		char runID[10];
		ltoa(RunID, runID, 10);
		_bstr_t bstrRunID = runID; 

		IBatchPtr ptrBatch = mMeter->CreateBatch();
	
		ptrBatch->PutName(bstrRunID); // name
		ptrBatch->PutNameSpace(AdapterName); // adapter name
		ptrBatch->PutSequenceNumber(SequenceNumber); // sequence number 
		ptrBatch->PutExpectedCount(0); // metered count
	
		ptrBatch->PutSourceCreationDate(GetMTOLETime());
		ptrBatch->PutSource(AdapterName); 
	
		ptrBatch->PutComment("N/A");
	
		ptrBatch->Save();
	
		mpBatch = ptrBatch;
		mBatchID = mpBatch->GetUID();
		*ppNewBatch = reinterpret_cast<IBatch*>(ptrBatch.Detach());
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}

	return hr;
}

// ---------------------------------------------------------------------------------
const ColumnMapping * CMeterRowset::GetColumnMapping(const wchar_t * apColumn, 
																										 const wchar_t * apService)
{
	std::wstring col(apColumn);
	std::wstring service(apService);
	StrToLower(col);
	StrToLower(service);

	//find the column map for the given service
	ServiceColumnMap::const_iterator findMapIt = mServiceColumnMap.find(service);
	if (findMapIt == mServiceColumnMap.end())
		return NULL;
	ColumnMap* pColumnMap = findMapIt->second;

	//find the mapping for the given column name
	ColumnMap::const_iterator findMappingIt = pColumnMap->find(col);
	if (findMappingIt == pColumnMap->end())
		return NULL;

	const ColumnMapping & val = findMappingIt->second;

	return &val;
}

void ColumnMapping::Init(const wchar_t * apPropName, DataType aType,
												 BOOL aRequired)
{
	mPropName = apPropName;
	mType = aType;
	mRequired = aRequired;
}

void CommonProp::Init(const wchar_t * apPropName, DataType aType,
											_variant_t aValue)
{
	mPropName = apPropName;
	mType = aType;
	mValue = aValue;
}



// TODO: rewrite this! 
wstring CMeterRowset::ConvertSessionIDToString(const unsigned char * apSessionID)
{
  wstring wstrString;
  wchar_t sessionID[DB_SESSIONID_SIZE+1];
  wchar_t * wchrFormat = L"%02X";

  // convert the session id to a string ...
  wstrString += L"0x"; 
  for (int i=0; i < DB_SESSIONID_SIZE; i++)
  {
    swprintf(sessionID, wchrFormat, (int)*(apSessionID+i));
    wstrString += sessionID ;
  }

  return wstrString ;
}

void CMeterRowset::AttemptSessionSetClose(ISessionSetPtr& arSessionSet) 
{
	long attempt = 1;         // the amount of times metering was tried
	long sleepTime = 5;       // amount of time in seconds to sleep 
	long sleepIncrement = 5;  // amount of time in seconds to increase the sleep time by
	bool metered = false;     
  long lSyncRetries = 0;
	
	while(true) 
	{

		try 
		{
			// attempts to meter it!
			arSessionSet->Close();
			metered = true;
		}
		catch (_com_error & err)
		{		

			// the server is overloaded so try again after a little bit
			if (err.Error() == MT_ERR_SERVER_BUSY) 
			{ 
				mLogger.LogVarArgs(LOG_WARNING,
													 "The server was busy, records were not metered. "
													 "Attempt %d - sleeping %d seconds before trying again...",
													 attempt, sleepTime);
				
				// sleeps for sleepTime seconds
				Sleep(sleepTime * 1000);
				
				// sleeps longer next time
				sleepTime += sleepIncrement;
				attempt++;

				// if we aren't successful at this point, bail out
				if (attempt == 30) 
				{
					mLogger.LogVarArgs(LOG_ERROR, "The server was busy for an extended period of time. Giving up!");
					throw err;
				}
			}
      //if we meter synchronously, also check for sync timeout and retry
			else if(mbSync && err.Error() == MT_ERR_SYN_TIMEOUT)
      {
        if(lSyncRetries == mlSyncRetries)
        {
          mLogger.LogVarArgs(LOG_ERROR,
													 "Sync metering timeout after"
													 " %d unsuccessful retries",
													 mlSyncRetries);
          throw err;
        }
        else
        {
          Sleep(mlSyncSleep*1000);
          lSyncRetries++;
        }
      }
      else
				// some other metering error, propagate it
				throw err;
		}

		if (metered)
			return;
	}
}

STDMETHODIMP CMeterRowset::get_ServiceDefinition(BSTR* pVal)
{
	try
	{
    _bstr_t bstrOut = mServiceName.c_str();
    *pVal = bstrOut;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

STDMETHODIMP CMeterRowset::put_TransactionID(BSTR newVal)
{
	try
	{
		// set transaction id
		mTransactionID = newVal;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

STDMETHODIMP CMeterRowset::put_ListenerTransactionID(BSTR newVal)
{
	try
	{
		mListenerTransactionID = newVal;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}


STDMETHODIMP CMeterRowset::put_MeterSynchronously(VARIANT_BOOL newVal)
{
  mbSync = newVal == VARIANT_TRUE ? true : false;
	return S_OK;
}

STDMETHODIMP CMeterRowset::get_MeterSynchronously(VARIANT_BOOL* apVal)
{
  if(apVal == NULL)
    return E_POINTER;
  (*apVal) = mbSync ? VARIANT_TRUE : VARIANT_FALSE;
	return S_OK;
}


STDMETHODIMP CMeterRowset::put_SyncMeteringRetries(long newVal)
{
  mlSyncRetries = newVal;
	return S_OK;
}

STDMETHODIMP CMeterRowset::get_SyncMeteringRetries(long* apVal)
{
  if(apVal == NULL)
    return E_POINTER;
  (*apVal) = mlSyncRetries;
	return S_OK;
}


STDMETHODIMP CMeterRowset::put_SyncMeteringRetrySleepInterval(long newVal)
{
  mlSyncSleep = newVal;
	return S_OK;
}

STDMETHODIMP CMeterRowset::get_SyncMeteringRetrySleepInterval(long* apVal)
{
  if(apVal == NULL)
    return E_POINTER;
  (*apVal) = mlSyncSleep;
	return S_OK;
}


