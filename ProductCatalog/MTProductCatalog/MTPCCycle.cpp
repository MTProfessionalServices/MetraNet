/**************************************************************************
* Copyright 1997-2001 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header$
* 
***************************************************************************/

#include "StdAfx.h"

#include <metra.h>
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>
#include <UsageServerConstants.h>
#include <mtparamnames.h>
#include <loggerconfig.h>
#include <GenericCollection.h>
#include <MTObjectCollection.h>
#include <MTDate.h>

#include "MTProductCatalog.h"
#include "MTPCCycle.h"


/////////////////////////////////////////////////////////////////////////////
// CMTPCCycle

STDMETHODIMP CMTPCCycle::InterfaceSupportsErrorInfo(REFIID riid)
{
  static const IID* arr[] = 
  {
    &IID_IMTPCCycle,
    &IID_IMTPCBase
  };
  for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
  {
    if (InlineIsEqualGUID(*arr[i],riid))
      return S_OK;
  }
  return S_FALSE;
}

HRESULT CMTPCCycle::FinalConstruct() {
  try {
    LoadPropertiesMetaData(PCENTITY_TYPE_CYCLE);

    LoggerConfigReader configReader;
    mLogger.Init(configReader.ReadConfiguration("UsageServer"), "[CMTPCCycle]");

    return CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &m_pUnkMarshaler.p);
  } catch (_com_error & err) {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }
}

STDMETHODIMP CMTPCCycle::get_CycleID(long *pVal) {
  return GetPropertyValue("CycleID", pVal);
}

STDMETHODIMP CMTPCCycle::put_CycleID(long newVal) {
  return PutPropertyValue("CycleID", newVal);
}

STDMETHODIMP CMTPCCycle::get_CycleTypeID(long *pVal) {
  return GetPropertyValue("CycleTypeID", pVal);
}

STDMETHODIMP CMTPCCycle::put_CycleTypeID(long newVal) 
{
	if (mRelativeAmbiguity)
	{

		// set the mode based on what we know now - this may change
		if (newVal == 0)
			PutPropertyValue("Mode", (long) CYCLE_MODE_BCR);
		else
			PutPropertyValue("Mode", (long) CYCLE_MODE_BCR_CONSTRAINED);
	}

  return PutPropertyValue("CycleTypeID", newVal);
}

// OBSOLETE - use the Mode property instead
STDMETHODIMP CMTPCCycle::get_Relative(VARIANT_BOOL *pVal) {
  return GetPropertyValue("Relative", pVal);
}

// OBSOLETE - use the Mode property instead
STDMETHODIMP CMTPCCycle::put_Relative(VARIANT_BOOL newVal) 
{
	// keeps the Mode property in sync
	// NOTE: a distinction between BCR and BCR constrained
	//       cannot safely be made at this point.
	//       The ultimate distinction is made later in get_Mode.
	// NOTE: we need to be careful with lazily evaluating the mode here.
	//       MDM uses some type of property reflection that bypasses
	//       our accessors. therefore, a best guess effort will
	//       be made at determining the Mode based on current properties. 
	//       the original API did not specificy whether Relative must be set
	//       before CycleTypeID or vice versa so we will set the Mode in each
	//       case when these properties are updated.
	if (newVal == VARIANT_TRUE) 
	{
		mRelativeAmbiguity = true;

		// set the mode based on what we know now
		// this may change later if they modify CycleTypeID
		MTPRODUCTCATALOGLib::IMTPCCyclePtr thisPtr(this);
		if (thisPtr->CycleTypeID == 0)
			PutPropertyValue("Mode", (long) CYCLE_MODE_BCR);
		else
			PutPropertyValue("Mode", (long) CYCLE_MODE_BCR_CONSTRAINED);

		// the case is still ambiguous 
	}
	else
	{
		PutPropertyValue("Mode", (long) CYCLE_MODE_FIXED);
		mRelativeAmbiguity = false;
	}

  return PutPropertyValue("Relative", newVal);
}

STDMETHODIMP CMTPCCycle::get_Mode(MTCycleMode* pVal)
{
	// if the Relative property was used determines exactly what it means
	MTPRODUCTCATALOGLib::IMTPCCyclePtr thisPtr(this);
	if (mRelativeAmbiguity) 
	{
		if (thisPtr->CycleTypeID == 0)
			PutPropertyValue("Mode", (long) CYCLE_MODE_BCR);
		else
			PutPropertyValue("Mode", (long) CYCLE_MODE_BCR_CONSTRAINED);

		mRelativeAmbiguity = false;
	}		

  return GetPropertyValue("Mode", (long *) pVal);
}

STDMETHODIMP CMTPCCycle::put_Mode(MTCycleMode mode) {

	// keeps the obsolete Relative property in sync for backward compatability
	if ((mode == CYCLE_MODE_BCR) || (mode == CYCLE_MODE_BCR_CONSTRAINED))
		PutPropertyValue("Relative", VARIANT_TRUE);
	else
		PutPropertyValue("Relative", VARIANT_FALSE);
	
	mRelativeAmbiguity = false;

  return PutPropertyValue("Mode", (long) mode);
}

STDMETHODIMP CMTPCCycle::get_EndDayOfWeek(long *pVal) {
  return GetPropertyValue("EndDayOfWeek", pVal);
}

STDMETHODIMP CMTPCCycle::put_EndDayOfWeek(long newVal) {
  return PutPropertyValue("EndDayOFWeek", newVal);
}

STDMETHODIMP CMTPCCycle::get_EndDayOfMonth(long *pVal) {
  return GetPropertyValue("EndDayOfMonth", pVal);
}

STDMETHODIMP CMTPCCycle::put_EndDayOfMonth(long newVal) {
  return PutPropertyValue("EndDayOfMonth", newVal);
}

STDMETHODIMP CMTPCCycle::get_EndDayOfMonth2(long *pVal) {
  return GetPropertyValue("EndDayOfMonth2", pVal);
}

STDMETHODIMP CMTPCCycle::put_EndDayOfMonth2(long newVal) {
  return PutPropertyValue("EndDayOfMonth2", newVal);
}

STDMETHODIMP CMTPCCycle::get_StartDay(long *pVal) {
  return GetPropertyValue("StartDay", pVal);
}

STDMETHODIMP CMTPCCycle::put_StartDay(long newVal) {
  return PutPropertyValue("StartDay", newVal);
}

STDMETHODIMP CMTPCCycle::get_StartMonth(long *pVal) {
  return GetPropertyValue("StartMonth", pVal);
}

STDMETHODIMP CMTPCCycle::put_StartMonth(long newVal) {
  return PutPropertyValue("StartMonth", newVal);
}

STDMETHODIMP CMTPCCycle::get_StartYear(long *pVal) {
  return GetPropertyValue("StartYear", pVal);
}

STDMETHODIMP CMTPCCycle::put_StartYear(long newVal) {
  return PutPropertyValue("StartYear", newVal);
}

STDMETHODIMP CMTPCCycle::get_AdapterProgID(BSTR *pVal) {
  return GetPropertyValue("AdapterProgID", pVal);
}

STDMETHODIMP CMTPCCycle::get_CycleTypeDescription(BSTR *pVal) {
  return GetPropertyValue("CycleTypeDescription", pVal);
}



STDMETHODIMP CMTPCCycle::ComputeCycleIDFromProperties() {
  const char* methodName = "CMTPCCycle::ComputeCycleIDFromProperties";
  HRESULT nRetVal = S_OK;

  try {

    MTPRODUCTCATALOGLib::IMTPCCyclePtr thisPtr(this);
    if(thisPtr->Mode == MTPRODUCTCATALOGLib::CYCLE_MODE_FIXED)
    {
      ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
      rowset->Init(USAGE_SERVER_QUERY_DIR);

      //gets the cycle adapter's name and description based on the cycle type id
      long cycleTypeId;
      GetPropertyValue("CycleTypeID", &cycleTypeId);
      rowset->SetQueryTag("__GET_USAGE_CYCLE_TYPE__");
      rowset->AddParam("%%CYCLE_TYPE%%", cycleTypeId);
      rowset->Execute();

      if((bool) rowset->GetRowsetEOF()) {
        mLogger.LogVarArgs(LOG_ERROR, "The cycle type ID = %d was not found in the t_usage_cycle_type table.", cycleTypeId);
        return E_FAIL;
      }

      _variant_t val;

      //gets the prog id of the cycle's adapter o 
      val = rowset->GetValue("tx_cycle_type_method");
      PutPropertyValue("AdapterProgID", val);
      _bstr_t adapterProgId(val);

      //gets the prog id of the cycle's adapter
      val = rowset->GetValue("tx_desc");
      PutPropertyValue("CycleTypeDescription", val);

      rowset->Clear();

      //populates the "old-school" usage cycle property collection used by cycle adapters
      MTUSAGESERVERLib::ICOMUsageCyclePropertyCollPtr legacyProps = NULL;
      nRetVal = ExportToLegacyPropColl(legacyProps);
      if (!SUCCEEDED(nRetVal)) {
        mLogger.LogVarArgs(LOG_ERROR, "Could not populate legacy cycle property collection! Error code: %ld", nRetVal);
        return nRetVal;
      }
    
      //creates the cycle adapter
      CLSID adapterCLSID;
      CLSIDFromProgID(adapterProgId, &adapterCLSID);
      MTUSAGECYCLELib::IMTUsageCyclePtr adapter = NULL;
      nRetVal = CoCreateInstance(adapterCLSID, NULL, CLSCTX_INPROC_SERVER,
                                 __uuidof(MTUSAGECYCLELib::IMTUsageCycle), reinterpret_cast<void **>(&adapter));
      if (!SUCCEEDED(nRetVal)) {
        mLogger.LogVarArgs(LOG_ERROR, "Failed to create an instance of %s!", (char*)adapterProgId);
        return nRetVal;
      }

      //translates the cycle properties into a normalized form
      MTDate dummyDate(1, 1, 2030); //this date should always be in the future
      DATE dtReference, dtStart, dtEnd;
      dummyDate.GetOLEDate(&dtReference);
      adapter->ComputeStartAndEndDate(dtReference, 
                                      (MTUSAGECYCLELib::ICOMUsageCyclePropertyCollPtr) legacyProps,
                                      &dtStart,
                                      &dtEnd);

      //gets the normalized properties back from the legacy collection and stores them in "this"
      nRetVal = ImportFromLegacyPropColl(legacyProps);
      if (!SUCCEEDED(nRetVal)) {
        mLogger.LogVarArgs(LOG_ERROR, "Could not populate legacy cycle property collection! Error code: %ld", nRetVal);
        return nRetVal;
      }
    
      //builds part of the where clause for the query
      _bstr_t partialWhereClause;
      switch (cycleTypeId) {
      case DAILY:
        break;

      case WEEKLY:
        partialWhereClause  = " and day_of_week = ";
        partialWhereClause += _bstr_t(legacyProps->GetProperty(UCP_DAY_OF_WEEK));
        break;

      case BIWEEKLY:
        partialWhereClause  = " and start_day = ";
        partialWhereClause += _bstr_t(legacyProps->GetProperty(UCP_START_DAY));
        partialWhereClause += " and start_month = ";
        partialWhereClause += _bstr_t(legacyProps->GetProperty(UCP_START_MONTH));
        partialWhereClause += " and start_year = ";
        partialWhereClause += _bstr_t(legacyProps->GetProperty(UCP_START_YEAR));
        break;

      case MONTHLY:
        partialWhereClause  = " and day_of_month = ";
        partialWhereClause += _bstr_t(legacyProps->GetProperty(UCP_DAY_OF_MONTH));
        break;
      
      case SEMIMONTHLY:
        partialWhereClause += " and first_day_of_month = ";
        partialWhereClause += _bstr_t(legacyProps->GetProperty(UCP_FIRST_DAY_OF_MONTH));
        partialWhereClause += " and second_day_of_month = ";
        partialWhereClause += _bstr_t(legacyProps->GetProperty(UCP_SECOND_DAY_OF_MONTH));
        break;

      case QUARTERLY:
      case ANNUALLY:
      case SEMIANNUALLY:
        partialWhereClause =  " and start_day = ";
        partialWhereClause += _bstr_t(legacyProps->GetProperty(UCP_START_DAY));
        partialWhereClause += " and start_month = ";
        partialWhereClause += _bstr_t(legacyProps->GetProperty(UCP_START_MONTH));
        break;
      }
    
      //executes the query
      rowset->SetQueryTag("__FIND_USAGE_CYCLE__");
      rowset->AddParam(MTPARAM_CYCLETYPE, cycleTypeId);
      rowset->AddParam(MTPARAM_EXT, partialWhereClause);
      rowset->Execute();
      if((bool) rowset->GetRowsetEOF()) {
        mLogger.LogVarArgs(LOG_ERROR, "The cycle ID could not be found in the t_usage_cycle table from the given properties.");
        return E_FAIL;
      }

      //retrieves the cycle ID back from the rowset
      val = rowset->GetValue("CycleID");
      PutPropertyValue("CycleID", val);
    }
    else
    { 
      // BCR, BCR Constrainted and EBCR don't use the cycle ID
      thisPtr->CycleID = 0;
    }

  } catch (_com_error & err) {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }
  
  return S_OK;
}


HRESULT CMTPCCycle::ExportToLegacyPropColl(MTUSAGESERVERLib::ICOMUsageCyclePropertyCollPtr& legacyProps) {
  HRESULT nRetVal;

  //creates the usage cycle property collection
  nRetVal = CoCreateInstance(__uuidof(MTUSAGESERVERLib::COMUsageCyclePropertyColl), NULL, CLSCTX_INPROC_SERVER,
                             __uuidof(MTUSAGESERVERLib::ICOMUsageCyclePropertyColl), reinterpret_cast<void **>(&legacyProps));
  if (!SUCCEEDED(nRetVal)) {
    mLogger.LogVarArgs(LOG_ERROR, "Failed to create instance of COMUsageCyclePropertyColl object!");
    return nRetVal;
  }

  long cycleTypeId;
  nRetVal = GetPropertyValue("CycleTypeID", &cycleTypeId);
  if(!SUCCEEDED(nRetVal))
    return nRetVal;
  long nVal;

  switch (cycleTypeId) {
  case DAILY:
    break;

  case WEEKLY:
    nRetVal = GetPropertyValue("EndDayOfWeek", &nVal);
    if(!SUCCEEDED(nRetVal))
      return nRetVal;
    if (nVal)
      legacyProps->AddProperty(UCP_DAY_OF_WEEK, _variant_t(nVal));
    break;

  case BIWEEKLY:
    nRetVal = GetPropertyValue("StartDay", &nVal);
    if(!SUCCEEDED(nRetVal))
      return nRetVal;
    if (nVal)
      legacyProps->AddProperty(UCP_START_DAY, _variant_t(nVal));

    nRetVal = GetPropertyValue("StartMonth", &nVal);
    if (!SUCCEEDED(nRetVal))
      return nRetVal;
    if (nVal)
      legacyProps->AddProperty(UCP_START_MONTH, _variant_t(nVal));

    nRetVal = GetPropertyValue("StartYear", &nVal);
    if (!SUCCEEDED(nRetVal))
      return nRetVal;
    if (nVal)
      legacyProps->AddProperty(UCP_START_YEAR, _variant_t(nVal));
    break;

  case MONTHLY:
    nRetVal = GetPropertyValue("EndDayOfMonth", &nVal);
    if (!SUCCEEDED(nRetVal))
      return nRetVal;
    if (nVal)
      legacyProps->AddProperty(UCP_DAY_OF_MONTH, _variant_t(nVal));
    break;

  case SEMIMONTHLY:
    nRetVal = GetPropertyValue("EndDayOfMonth", &nVal);
    if (!SUCCEEDED(nRetVal))
      return nRetVal;
    if (nVal)
      legacyProps->AddProperty(UCP_FIRST_DAY_OF_MONTH, _variant_t(nVal));


    nRetVal = GetPropertyValue("EndDayOfMonth2", &nVal);
    if (!SUCCEEDED(nRetVal))
      return nRetVal;
    if (nVal)
      legacyProps->AddProperty(UCP_SECOND_DAY_OF_MONTH, _variant_t(nVal));
    break;

  case QUARTERLY:
  case ANNUALLY:
  case SEMIANNUALLY:
    nRetVal = GetPropertyValue("StartDay", &nVal);
    if (!SUCCEEDED(nRetVal))
      return nRetVal;
    if (nVal)
      legacyProps->AddProperty(UCP_START_DAY, _variant_t(nVal));

    nRetVal = GetPropertyValue("StartMonth", &nVal);
    if (!SUCCEEDED(nRetVal))
      return nRetVal;
    if (nVal)
      legacyProps->AddProperty(UCP_START_MONTH, _variant_t(nVal));
    break;

  default:
    mLogger.LogVarArgs(LOG_ERROR, "Cycle type %d is not supported!", cycleTypeId);
    return E_FAIL; 
  }

  return S_OK;
}   


HRESULT CMTPCCycle::ImportFromLegacyPropColl(MTUSAGESERVERLib::ICOMUsageCyclePropertyCollPtr& legacyProps) {
  HRESULT nRetVal;

  long cycleTypeId;
  GetPropertyValue("CycleTypeID", &cycleTypeId);

  switch (cycleTypeId) {
  case DAILY:
    break;

  case WEEKLY:
    nRetVal = PutPropertyValue("EndDayOfWeek", legacyProps->GetProperty(UCP_DAY_OF_WEEK));
    if(!SUCCEEDED(nRetVal))
      return nRetVal;
    break;

  case BIWEEKLY:
    nRetVal = PutPropertyValue("StartDay", legacyProps->GetProperty(UCP_START_DAY));
    if(!SUCCEEDED(nRetVal))
      return nRetVal;

    nRetVal = PutPropertyValue("StartMonth", legacyProps->GetProperty(UCP_START_MONTH));
    if(!SUCCEEDED(nRetVal))
      return nRetVal;

    nRetVal = PutPropertyValue("StartYear", legacyProps->GetProperty(UCP_START_YEAR));
    if(!SUCCEEDED(nRetVal))
      return nRetVal;
    break;

  case MONTHLY:
    nRetVal = PutPropertyValue("EndDayOfMonth", legacyProps->GetProperty(UCP_DAY_OF_MONTH));
    if(!SUCCEEDED(nRetVal))
      return nRetVal;
    break;

  case SEMIMONTHLY:
    nRetVal = PutPropertyValue("EndDayOfMonth", legacyProps->GetProperty(UCP_FIRST_DAY_OF_MONTH));
    if(!SUCCEEDED(nRetVal))
      return nRetVal;

    nRetVal = PutPropertyValue("EndDayOfMonth2", legacyProps->GetProperty(UCP_SECOND_DAY_OF_MONTH));
    if(!SUCCEEDED(nRetVal))
      return nRetVal;
    break;

  case QUARTERLY:
  case ANNUALLY:
  case SEMIANNUALLY:
    nRetVal = PutPropertyValue("StartDay", legacyProps->GetProperty(UCP_START_DAY));
    if(!SUCCEEDED(nRetVal))
      return nRetVal;

    nRetVal = PutPropertyValue("StartMonth", legacyProps->GetProperty(UCP_START_MONTH));
    if(!SUCCEEDED(nRetVal))
      return nRetVal;
    break;

  default:
    mLogger.LogVarArgs(LOG_ERROR, "Cycle type %d is not supported!", cycleTypeId);
    return E_FAIL; 
  }

  return S_OK;
}   



STDMETHODIMP CMTPCCycle::ComputePropertiesFromCycleID() {
  const char* methodName = "CMTPCCycle::ComputePropertiesFromCycleID";
  HRESULT nRetVal = S_OK;

  try {

    MTPRODUCTCATALOGLib::IMTPCCyclePtr thisPtr(this);
    //loads cycle properties for the given cycle id
    long cycleId = thisPtr->CycleID;

		// this supports older callers that did not explicitly set Relative
    if ((cycleId == 0) && (thisPtr->Mode == MTPRODUCTCATALOGLib::CYCLE_MODE_FIXED))
			thisPtr->Relative = VARIANT_TRUE;
    
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(USAGE_SERVER_QUERY_DIR);

    rowset->SetQueryTag("__GET_CYCLE_PROPERTIES__");
    rowset->AddParam(MTPARAM_CYCLEID, cycleId);
    rowset->Execute();

    if((bool) rowset->GetRowsetEOF()) {
      mLogger.LogVarArgs(LOG_ERROR, "The cycle ID = %d was not found in the t_usage_cycle table.", cycleId);
      return E_FAIL;
    }

    _variant_t val;

    //gets the prog id of the cycle's adapter
    val = rowset->GetValue("tx_cycle_type_method");
    PutPropertyValue("AdapterProgID", val);

    //gets the english description of the cycle type
    val = rowset->GetValue("tx_desc");
    PutPropertyValue("CycleTypeDescription", val);

    //gets the cycle type of the cycle and adds it to the collection
    val = rowset->GetValue("id_cycle_type");
    PutPropertyValue("CycleTypeID", val);
    CycleType cycleTypeId = (CycleType)((long) val);
    
    //based on the cycle type, retrieve and store various usage cycle 
    //properties into the property collection
    switch (cycleTypeId) {
      
    case MONTHLY:
      //gets the day of month the cycle will close on
      val = rowset->GetValue("day_of_month");
      PutPropertyValue("EndDayOfMonth", val);
      break;
      
    case DAILY:
      //the daily cycle has no properties
      break;
      
    case WEEKLY:
      //gets the day of week the cycle will close on
      val = rowset->GetValue("day_of_week");
      PutPropertyValue("EndDayOfWeek", val);
      break;
      
    case BIWEEKLY:
      //gets the day the cycle will start on
      val = rowset->GetValue("start_day");
      PutPropertyValue("StartDay", val);
      
      //gets the month the cycle will start in
      val = rowset->GetValue("start_month");
      PutPropertyValue("StartMonth", val);

      //gets the year the cycle will start in
      val = rowset->GetValue("start_year");
      PutPropertyValue("StartYear", val);

      break;
      
    case SEMIMONTHLY:
      //gets the first day of the month the cycle closes on
      val = rowset->GetValue("first_day_of_month");
      PutPropertyValue("EndDayOfMonth", val);

      //gets the second day of the month the cycle closes on
      val = rowset->GetValue("second_day_of_month");
      PutPropertyValue("EndDayOfMonth2", val);

      break;
      
    case QUARTERLY:
    case ANNUALLY:
    case SEMIANNUALLY:
      //gets the day of the month the cycle starts on
      val = rowset->GetValue("start_day");
      PutPropertyValue("StartDay", val);
      
      //gets the month that the cycle will start in
      val = rowset->GetValue("start_month");
      PutPropertyValue("StartMonth", val);
      break;
      
    default:
      mLogger.LogVarArgs(LOG_ERROR, "Cycle %d is of cycle type %d, which is not supported by %s.", cycleId, cycleTypeId, methodName);
      return E_FAIL;
    }
  } catch (_com_error & err) {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }
  
  return S_OK;
}

STDMETHODIMP CMTPCCycle::CreateAbsoluteCycle(DATE aReference, IMTPCCycle ** aAbsoluteCycle)
{
  VARIANT_BOOL relative;
  GetPropertyValue("Relative", &relative);
  if (!relative) {
    mLogger.LogVarArgs(LOG_ERROR, "Cycle must be relative! Cannot create absolute cycle based on non-relative cycle.");
    return E_FAIL;
  }

  try {

    //creates the new absolute cycle
    MTPRODUCTCATALOGLib::IMTPCCyclePtr absoluteCycle(__uuidof(MTPRODUCTCATALOGLib::MTPCCycle));

    //pass the session context on to objects created from this one
    MTPRODUCTCATALOGLib::IMTPCCyclePtr thisPtr = this;
    MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
    absoluteCycle->SetSessionContext(ctxt);

    //the cycle type is the same as the relative cycle
    long cycleTypeId;
    GetPropertyValue("CycleTypeID", &cycleTypeId);
    absoluteCycle->PutCycleTypeID(cycleTypeId);

    MTDate referenceDate(aReference);

    //sets the cycle properties of the absolute cycle based on the reference date
    switch (cycleTypeId) {
    case MONTHLY:
      absoluteCycle->PutEndDayOfMonth(referenceDate.GetDay());
      break;
      
    case DAILY:
      //the daily cycle has no properties
      break;
      
    case WEEKLY:
      absoluteCycle->PutEndDayOfWeek(referenceDate.GetWeekday());
      break;
      
    case BIWEEKLY:
      absoluteCycle->PutStartDay(referenceDate.GetDay());
      absoluteCycle->PutStartMonth(referenceDate.GetMonth());
      absoluteCycle->PutStartYear(referenceDate.GetYear());
      break;
      
    case SEMIMONTHLY:
      //EndDayOfMonth2 cannot be determined from the reference date alone
      //for now we assume that the two days are 14 days apart. We must not
      //violate cycle adapter constraint that EndDayOfMonth < EndDayOfMonth2
      int day1, day2;
      if (referenceDate.GetDay() <= 15) {
        day1 = referenceDate.GetDay();
        day2 = day1 + 14;
      } else {
        day2 = referenceDate.GetDay();
        day1 = day2 - 14;
      }
      
      absoluteCycle->PutEndDayOfMonth(day1);
      absoluteCycle->PutEndDayOfMonth2(day2);
      break;
      
    case QUARTERLY:
    case ANNUALLY:
    case SEMIANNUALLY:
      absoluteCycle->PutStartDay(referenceDate.GetDay());
      absoluteCycle->PutStartMonth(referenceDate.GetMonth());
      break;
      
    default:
      mLogger.LogVarArgs(LOG_ERROR, "Cycle %d is not supported!", cycleTypeId);
      return E_FAIL;
    }
    
    //computes the cycle id and normalizes the properties
    absoluteCycle->ComputeCycleIDFromProperties();

    //returns cycle to the caller
    *aAbsoluteCycle = (IMTPCCycle*) absoluteCycle.Detach();

  } catch (_com_error & err) {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}

STDMETHODIMP CMTPCCycle::GetTimeSpans(DATE aStartDate, DATE aEndDate, IMTCollection** apColl) {
  HRESULT nRetVal = S_OK;

  try {

    //populates the "old-school" usage cycle property collection used by cycle adapters
    MTUSAGESERVERLib::ICOMUsageCyclePropertyCollPtr legacyProps = NULL;
    nRetVal = ExportToLegacyPropColl(legacyProps);
    if (!SUCCEEDED(nRetVal)) {
      mLogger.LogVarArgs(LOG_ERROR, "Could not populate legacy cycle property collection! Error code: %ld", nRetVal);
      return nRetVal;
    }
    
    //creates the cycle adapter
    BSTR bstr;
    nRetVal = GetPropertyValue("AdapterProgID", &bstr);
    if (!SUCCEEDED(nRetVal))
      return nRetVal;
    _bstr_t adapterProgId = _bstr_t(bstr, FALSE);
    if (adapterProgId.length() == 0) {
      mLogger.LogVarArgs(LOG_ERROR, "The adapter prog ID is blank!");
      return E_FAIL;
    }
    CLSID adapterCLSID;
    CLSIDFromProgID(adapterProgId, &adapterCLSID);
    MTUSAGECYCLELib::IMTUsageCyclePtr adapter = NULL;
    nRetVal = CoCreateInstance(adapterCLSID, NULL, CLSCTX_INPROC_SERVER,
                               __uuidof(MTUSAGECYCLELib::IMTUsageCycle), reinterpret_cast<void **>(&adapter));
    if (!SUCCEEDED(nRetVal)) {
      mLogger.LogVarArgs(LOG_ERROR, "Failed to create an instance of \'%s\'!", (char*) adapterProgId);
      return nRetVal;
    }

    //creates the collection that will hold the time spans
    MTObjectCollection<IMTPCTimeSpan> timeSpans;


    DATE dtStartSpan, dtEndSpan;
    DATE dtReference = aStartDate; //initial reference is the given start date
    while(dtReference <= aEndDate) {

      //gets the time span's start and end dates given the reference date
      adapter->ComputeStartAndEndDate(dtReference, 
                                      (MTUSAGECYCLELib::ICOMUsageCyclePropertyCollPtr) legacyProps,
                                      &dtStartSpan,
                                      &dtEndSpan);


      //creates a new time span object and adds it to the collection
      MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr timeSpan(__uuidof(MTPRODUCTCATALOGLib::MTPCTimeSpan));
      
      //pass the session context on to objects created from this one
      MTPRODUCTCATALOGLib::IMTPCCyclePtr thisPtr = this;
      MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
      timeSpan->SetSessionContext(ctxt);

      timeSpan->PutStartDateType(MTPRODUCTCATALOGLib::PCDATE_TYPE_ABSOLUTE);
      timeSpan->PutStartDate(dtStartSpan);
      timeSpan->PutEndDateType(MTPRODUCTCATALOGLib::PCDATE_TYPE_ABSOLUTE);
      timeSpan->PutEndDate(dtEndSpan);
      timeSpans.Add((IMTPCTimeSpan*) timeSpan.GetInterfacePtr());

      //seeds the next calculation by sliding the ref date ahead of the last time span's end date
      MTDate dayAfterEndSpan(dtEndSpan);
      dayAfterEndSpan++;
      dayAfterEndSpan.GetOLEDate(&dtReference);
    }

    timeSpans.CopyTo(apColl);

  } catch (_com_error & err) {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}


STDMETHODIMP CMTPCCycle::GetTimeSpan(DATE aReference, IMTPCTimeSpan** apTimeSpan) {
  HRESULT nRetVal = S_OK;

  try {

    //populates the "old-school" usage cycle property collection used by cycle adapters
    MTUSAGESERVERLib::ICOMUsageCyclePropertyCollPtr legacyProps = NULL;
    nRetVal = ExportToLegacyPropColl(legacyProps);
    if (!SUCCEEDED(nRetVal)) {
      mLogger.LogVarArgs(LOG_ERROR, "Could not populate legacy cycle property collection! Error code: %ld", nRetVal);
      return nRetVal;
    }
    
    //creates the cycle adapter
    BSTR bstr;
    nRetVal = GetPropertyValue("AdapterProgID", &bstr);
    if (!SUCCEEDED(nRetVal))
      return nRetVal;
    _bstr_t adapterProgId = _bstr_t(bstr, FALSE);
    if (adapterProgId.length() == 0) {
      mLogger.LogVarArgs(LOG_ERROR, "The adapter prog ID is blank!");
      return E_FAIL;
    }
    CLSID adapterCLSID;
    CLSIDFromProgID(adapterProgId, &adapterCLSID);
    MTUSAGECYCLELib::IMTUsageCyclePtr adapter = NULL;
    nRetVal = CoCreateInstance(adapterCLSID, NULL, CLSCTX_INPROC_SERVER,
                               __uuidof(MTUSAGECYCLELib::IMTUsageCycle), reinterpret_cast<void **>(&adapter));
    if (!SUCCEEDED(nRetVal)) {
      mLogger.LogVarArgs(LOG_ERROR, "Failed to create an instance of \'%s\'!", (char*) adapterProgId);
      return nRetVal;
    }


    //gets the time span's start and end dates given the reference date
    DATE dtStartSpan, dtEndSpan;
    adapter->ComputeStartAndEndDate(aReference, 
                                    (MTUSAGECYCLELib::ICOMUsageCyclePropertyCollPtr) legacyProps,
                                    &dtStartSpan,
                                    &dtEndSpan);

    //creates a new time span object and adds it to the collection
    MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr timeSpan(__uuidof(MTPRODUCTCATALOGLib::MTPCTimeSpan));

    //pass the session context on to objects created from this one
    MTPRODUCTCATALOGLib::IMTPCCyclePtr thisPtr = this;
    MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
    timeSpan->SetSessionContext(ctxt);

    timeSpan->PutStartDateType(MTPRODUCTCATALOGLib::PCDATE_TYPE_ABSOLUTE);
    timeSpan->PutStartDate(dtStartSpan);
    timeSpan->PutEndDateType(MTPRODUCTCATALOGLib::PCDATE_TYPE_ABSOLUTE);
    timeSpan->PutEndDate(dtEndSpan);

    *apTimeSpan = (IMTPCTimeSpan*) timeSpan.Detach();

  } catch (_com_error & err) {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}

STDMETHODIMP CMTPCCycle::Clone(IMTPCCycle** apClone) {

  try {
    MTPRODUCTCATALOGLib::IMTPCCyclePtr clone(__uuidof(MTPRODUCTCATALOGLib::MTPCCycle));

    //pass the session context on to objects created from this one
    MTPRODUCTCATALOGLib::IMTPCCyclePtr thisPtr = this;
    MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
    clone->SetSessionContext(ctxt);

    MTPRODUCTCATALOGLib::IMTPCCyclePtr This(this);
    This->CopyTo(clone);

    *apClone = (IMTPCCycle*) clone.Detach();
  } catch (_com_error & err) {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;

}

STDMETHODIMP CMTPCCycle::CopyTo(IMTPCCycle *pTarget)
{
  try {
    MTPRODUCTCATALOGLib::IMTPCCyclePtr clone(pTarget);

    long nVal;
    get_StartYear(&nVal);
    clone->PutStartYear(nVal);

    get_StartMonth(&nVal);
    clone->PutStartMonth(nVal);

    get_StartDay(&nVal);
    clone->PutStartDay(nVal);

    get_EndDayOfMonth(&nVal);
    clone->PutEndDayOfMonth(nVal);

    get_EndDayOfMonth2(&nVal);
    clone->PutEndDayOfMonth2(nVal);

    get_EndDayOfWeek(&nVal);
    clone->PutEndDayOfWeek(nVal);

    get_CycleTypeID(&nVal);
    clone->PutCycleTypeID(nVal);

    get_CycleID(&nVal);
    clone->PutCycleID(nVal);

    VARIANT_BOOL bVal;
    get_Relative(&bVal);
    clone->PutRelative(bVal);

		MTCycleMode mode;
    get_Mode(&mode);
    clone->Mode = (MTPRODUCTCATALOGLib::MTCycleMode) mode;

  } catch (_com_error & err) {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}


STDMETHODIMP CMTPCCycle::Equals(IMTPCCycle* pOtherCycle, VARIANT_BOOL* apResult)
{
  if (!apResult)
    return E_POINTER;

  try
  {
    MTPRODUCTCATALOGLib::IMTPCCyclePtr thisPtr(this);
    MTPRODUCTCATALOGLib::IMTPCCyclePtr other(pOtherCycle);

    // cycles are the same if CycleTypeID, CycleID, and Mode match
    if ((thisPtr->CycleTypeID == other->CycleTypeID) &&
        (thisPtr->CycleID == other->CycleID) &&
				(thisPtr->Mode == other->Mode))
    {
      *apResult = VARIANT_TRUE;
    }
    else
    {
      *apResult = VARIANT_FALSE;
    }
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}

STDMETHODIMP CMTPCCycle::GetDescriptionFromCycleType(MTUsageCycleType aCycleType, BSTR *pCycleTypeDesc)
{
  _bstr_t desc;
  switch(aCycleType) {
  case MONTHLY_CYCLE:
    desc = "Monthly";
    break;
  case ONDEMAND_CYCLE:
    desc = "On-demand";
    break;
  case DAILY_CYCLE:
    desc = "Daily";
    break;
  case WEEKLY_CYCLE:
    desc = "Weekly";
    break;
  case BIWEEKLY_CYCLE:
    desc = "Bi-weekly";
    break;
  case SEMIMONTHLY_CYCLE:
    desc = "Semi-monthly";
    break;
  case QUARTERLY_CYCLE:
    desc = "Quarterly";
    break;
  case ANNUALLY_CYCLE:
    desc = "Annually";
    break;
  case SEMIANNUALLY_CYCLE:
    desc = "Semi-annually";
    break;

  default:
    desc = "";
  }
  *pCycleTypeDesc = desc.copy();
  return S_OK;
}

STDMETHODIMP CMTPCCycle::IsMutuallyExclusive(IMTPCCycle* pOtherCycle, VARIANT_BOOL* apResult)
{
  if (!apResult)
    return E_POINTER;

  try
  {
    MTPRODUCTCATALOGLib::IMTPCCyclePtr thisPtr(this);
    MTPRODUCTCATALOGLib::IMTPCCyclePtr other(pOtherCycle);

		// two BCR Constrainted cycle types must match exactly
		if ((thisPtr->Mode == CYCLE_MODE_BCR_CONSTRAINED) && 
				(other->Mode == CYCLE_MODE_BCR_CONSTRAINED))
		{
			// mismatch?
			if (thisPtr->CycleTypeID != other->CycleTypeID)
			{
				*apResult = VARIANT_TRUE; // mutually exclusive 
				return S_OK;
			}
		}

		// checks for all possible EBCR/BCR constrained combinations 
		if (((thisPtr->Mode == CYCLE_MODE_BCR_CONSTRAINED) || ((thisPtr->Mode == CYCLE_MODE_EBCR))) &&
				((other->Mode == CYCLE_MODE_BCR_CONSTRAINED) || (other->Mode == CYCLE_MODE_EBCR)))
		{
			// there are two groups of interchangable EBCR cycle types:
			// 1) the week based cycle types (Weekly, Biweekly)
			// 2) the month based cycle types (Monthly, Quarterly, SemiAnnual, Annual)

			// checks the weekly based cycle types for mismatches
			if (((thisPtr->CycleTypeID == WEEKLY_CYCLE) || (thisPtr->CycleTypeID == BIWEEKLY_CYCLE)) && 
					((other->CycleTypeID != WEEKLY_CYCLE) && (other->CycleTypeID != BIWEEKLY_CYCLE)))
			{
				*apResult = VARIANT_TRUE; // mutually exclusive 
				return S_OK;
			}

			// checks the monthly based cycle types for mismatches
			if (((thisPtr->CycleTypeID == MONTHLY_CYCLE) || 
					 (thisPtr->CycleTypeID == QUARTERLY_CYCLE) ||
           (thisPtr->CycleTypeID == SEMIANNUALLY_CYCLE) ||
					 (thisPtr->CycleTypeID == ANNUALLY_CYCLE))
					&&
					((other->CycleTypeID != MONTHLY_CYCLE) &&
					 (other->CycleTypeID != QUARTERLY_CYCLE) &&
           (thisPtr->CycleTypeID != SEMIANNUALLY_CYCLE) &&
					 (other->CycleTypeID != ANNUALLY_CYCLE)))
			{
				*apResult = VARIANT_TRUE; // mutually exclusive 
				return S_OK;
			}
		}

		// otherwise, the cycles are NOT mutually exclusive
		*apResult = VARIANT_FALSE; 
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }
	
	return S_OK;
}

