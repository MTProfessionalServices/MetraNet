/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by: Travis Gebhardt
* $Header$
* 
***************************************************************************/


// CLASS OVERVIEW
// ==============
//
// The MTBillingCycleConfig class is the main object used to learn
// about which billing cycles are to be made available to a CSR to
// choose from. However, this does not represent which adapters are
// installed on the system, it should only be used for the CSR to
// restrict choices in certain combo boxes, etc... This object is
// a collection of MTBillingCycle objects, which in turn are
// collections of MTTimePoint objects. Before using the object as
// a collection, the method Init() must be called. This forces the
// object to read in the xmlconfig file and populate the collections.



#include "StdAfx.h"
#include "BillingCycleConfig.h"
#include "MTBillingCycleConfig.h"
#include <mtcomerr.h>

using namespace std;
using namespace MTConfigLib;


// ----------------------------------------------------------------
// Arguments:     
// Return Value:  
// Raised Errors:
// Description:  AUTO GENERATED
// ----------------------------------------------------------------
STDMETHODIMP CMTBillingCycleConfig::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTBillingCycleConfig
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Arguments:     
// Return Value:  
// Raised Errors:
// Description:  Constructor
// ----------------------------------------------------------------
CMTBillingCycleConfig::CMTBillingCycleConfig() 
{
  //initializes the logger
  LoggerConfigReader cfgRdr;
  mLogger.Init(cfgRdr.ReadConfiguration("BillingCycleConfig"), BILLCONFIG_LOGGER_TAG);
}


// ----------------------------------------------------------------
// Arguments:     
// Return Value:  
// Raised Errors:
// Description:  COM INTERNAL USE ONLY
// ----------------------------------------------------------------
STDMETHODIMP CMTBillingCycleConfig::get__NewEnum(LPUNKNOWN *pVal)
{
	HRESULT hr = S_OK;

	typedef CComObject<CComEnum<IEnumVARIANT, &IID_IEnumVARIANT, 
		VARIANT, _Copy<VARIANT> > > enumvar;

	enumvar* pEnumVar = new enumvar;
  ASSERT(pEnumVar);
	int size = mCollection.size();

	// Note: end pointer has to be one past the end of the list
	if (size == 0)
	{
		hr = pEnumVar->Init(NULL,
							NULL, 
							NULL, 
							AtlFlagCopy);
	}
	else
	{
		hr = pEnumVar->Init(&mCollection[0], 
							&mCollection[size - 1] + 1, 
							NULL, 
							AtlFlagCopy);
	}

	if (SUCCEEDED(hr))
		hr = pEnumVar->QueryInterface(IID_IEnumVARIANT, (void**)pVal);

	if (FAILED(hr))
		delete pEnumVar;

	return hr;
}


// ----------------------------------------------------------------
// Name:     			get_Count
// Arguments:     
// Return Value:  long* val - collection size
// Raised Errors:
// Description:   Returns the amount of billing cycles
//                in the collection
// ----------------------------------------------------------------
STDMETHODIMP CMTBillingCycleConfig::get_Count(long *pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = (long)mCollection.size();

	return S_OK;

}


// ----------------------------------------------------------------
// Name:     			get_Item
// Arguments:     long aIndex			-		index
// Return Value:  VARIANT* pVal		-		MTBillingCycle
// Raised Errors:
// Description:   returns an MTBillingCycle object at a specified index
// ----------------------------------------------------------------
STDMETHODIMP CMTBillingCycleConfig::get_Item(long aIndex, VARIANT *pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	pVal->vt = VT_UNKNOWN;
	pVal->punkVal = NULL;

	//is the index within limits?
	if ((aIndex < 1) || (BillingCycleColl::size_type(aIndex) > mCollection.size()))
		return E_INVALIDARG;

	::VariantClear(pVal);
	::VariantCopy(pVal, &mCollection.at(aIndex - 1));

	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			Add
// Arguments:     IMTBillingCycle *apBillingCycle 
// Return Value:  
// Raised Errors:
// Description:		Adds a MTBillingCycle object to the collection
//
//                *** FOR INTERNAL USE ONLY ***
// ----------------------------------------------------------------
STDMETHODIMP CMTBillingCycleConfig::Add(IMTBillingCycle *apBillingCycle)
{
	HRESULT hr = S_OK;
	LPDISPATCH lpDisp = NULL;

	
	hr = apBillingCycle->QueryInterface(IID_IDispatch, (void**)&lpDisp);
	
	if (FAILED(hr))
	{
		return hr;
	}
	
	// create a variant
	CComVariant var;
	var.vt = VT_DISPATCH;
	var.pdispVal = lpDisp;
	
	mCollection.push_back(var);
	return hr;
}


// ----------------------------------------------------------------
// Name:     			Init
// Arguments:     
// Return Value:  
// Raised Errors:
// Description:		Init reads the xml configuration file and populates
//                the collection with MTBillingCycle objects. In turn, a
//                MTBillingCycle object is a collection of TimePoint
//                objects. After Init is called the collection may be
//                successfully accessed.
STDMETHODIMP CMTBillingCycleConfig::Init()
{
	const char * functionName = "MTBillingCycleConfig::Init";
	
	//catch any com errors and return them correctly
	try{
	//gets the base directory path of the config files
	string rwConfigDir;  // TODO: remove rogue wave
	GetMTConfigDir(rwConfigDir);

	//builds the full file name
	string configFile(rwConfigDir.c_str());
	configFile += BILLCONFIG_CONFIG_SUBDIR;
	configFile += "\\";
	configFile += BILLCONFIG_XMLCONFIG_FILE;

	//creates an EnumConfig instance (for reverse lookup)
	MTENUMCONFIGLib::IEnumConfigPtr enumConfig;
	HRESULT hr = enumConfig.CreateInstance(MTPROGID_ENUM_CONFIG);
	if (FAILED(hr)) {
		string buffer = "Could not create EnumConfig instance";
		mLogger.LogVarArgs(LOG_ERROR, buffer.c_str());
		return Error (buffer.c_str(), IID_IMTBillingCycleConfig, hr);
	}
	//gets the top most propset from the config file
	VARIANT_BOOL flag;
	MTConfigLib::IMTConfigPtr reader(MTPROGID_CONFIG);
	mLogger.LogVarArgs(LOG_INFO, "Reading configuration from '%s'", configFile.c_str());
	IMTConfigPropSetPtr top = reader->ReadConfiguration(configFile.c_str(), &flag);

	//gets the version of the config file
	long version = top->NextLongWithName(BILLCONFIG_VERSION_TAG);
	if (version != 1) {
		string buffer = "Version '";
		buffer += char(version);
		buffer += "' of the config file is not supported.";
		mLogger.LogVarArgs(LOG_ERROR, buffer.c_str());
		return Error (buffer.c_str(), IID_IMTBillingCycleConfig, E_FAIL);
	}

	//reads the top level billing cycles set
	IMTConfigPropSetPtr billingCycleSet =top->NextSetWithName(BILLCONFIG_BILLINGCYCLES_TAG);
	if (billingCycleSet == NULL)
	{
		string buffer = "Required tag '";
		buffer += BILLCONFIG_BILLINGCYCLES_TAG;
		buffer += "' was not found.";

		mLogger.LogVarArgs(LOG_ERROR, buffer.c_str());
		return Error (buffer.c_str(), IID_IMTBillingCycleConfig, E_FAIL);
	}

	
	long id;
	_bstr_t cycleTypeBSTR;
	string cycleType;
	IMTConfigPropSetPtr billingCycleDataSet, timePointSet, timePointDataSet;

	//gets the first billingCycle set
	billingCycleDataSet = billingCycleSet->NextSetWithName(BILLCONFIG_BILLINGCYCLE_TAG);

	//loops until all billingCycle's have been read
	while (billingCycleDataSet != NULL) {

		//creates the new BillingCycle object
		CComObject<CMTBillingCycle>* billingCycleEntry;
		HRESULT hr = CComObject<CMTBillingCycle>::CreateInstance(&billingCycleEntry);
		if (FAILED(hr)) {
			string buffer = "Could not create MTBillingCycle instance";
			mLogger.LogVarArgs(LOG_ERROR, buffer.c_str());
			return Error (buffer.c_str(), IID_IMTBillingCycleConfig, hr);
		}
		
		//gets the cycle type and stores it in the entry
		id = billingCycleDataSet->NextLongWithName(BILLCONFIG_CYCLETYPE_TAG);
		cycleTypeBSTR = enumConfig->GetEnumeratorByID(id);
		billingCycleEntry->put_CycleType(cycleTypeBSTR);
		cycleType = _strlwr(cycleTypeBSTR);

		mLogger.LogVarArgs(LOG_INFO, "adding billing cycle \"%s\"", cycleType.c_str());

		//-------------------------------------
		// --- START CYCLE SPECIFIC PARSING ---
		//-------------------------------------
		if ((cycleType == BILLCONFIG_CYCLE_ONDEMAND) || 
				(cycleType == BILLCONFIG_CYCLE_DAILY))
		{
			//requires no configuration information
		} 
		
		//the following cycleType's all use closingPoints
		else if ((cycleType == BILLCONFIG_CYCLE_WEEKLY) ||
						 (cycleType == BILLCONFIG_CYCLE_MONTHLY) ||
						 (cycleType == BILLCONFIG_CYCLE_SEMIMONTHLY))
		{

			//gets the closingpoints block (contains closingpoints)
			timePointSet = billingCycleDataSet->NextSetWithName(BILLCONFIG_CLOSINGPOINTS_TAG);
			if (timePointSet == NULL) {
				string buffer = "Required tag '";
				buffer += BILLCONFIG_CLOSINGPOINTS_TAG;
				buffer += "' was not found.";
				mLogger.LogVarArgs(LOG_ERROR, buffer.c_str());
				return Error (buffer.c_str(), IID_IMTBillingCycleConfig, E_FAIL);
			}
			
			//gets the first closingpoint set
			timePointDataSet = timePointSet->NextSetWithName(BILLCONFIG_CLOSINGPOINT_TAG);
			while (timePointDataSet != NULL) {

				//creates the new TimePoint object
				CComObject<CMTTimePoint>* timePointEntry;
				HRESULT hr = CComObject<CMTTimePoint>::CreateInstance(&timePointEntry);
				if (FAILED(hr)) {
					string buffer = "Could not create MTTimePoint instance";
					mLogger.LogVarArgs(LOG_ERROR, buffer.c_str());
					return Error (buffer.c_str(), IID_IMTBillingCycleConfig, hr);
				}

				if (cycleType == BILLCONFIG_CYCLE_WEEKLY) {
	
				//gets the namedDay property
					id = timePointDataSet->NextLongWithName(BILLCONFIG_NAMEDDAY_TAG);
					_bstr_t namedDay = enumConfig->GetEnumeratorByID(id);
					timePointEntry->put_NamedDay(namedDay);
					
				} else if (cycleType == BILLCONFIG_CYCLE_MONTHLY) {

					//gets the day property
					long day = timePointDataSet->NextLongWithName(BILLCONFIG_DAY_TAG);
					timePointEntry->put_Day(day);

				} else if (cycleType == BILLCONFIG_CYCLE_SEMIMONTHLY) {

					//gets the two day property tags
					long day1 = timePointDataSet->NextLongWithName(BILLCONFIG_DAY_TAG);
					long day2 = timePointDataSet->NextLongWithName(BILLCONFIG_DAY_TAG);
					timePointEntry->put_Day(day1);
					timePointEntry->put_SecondDay(day2);
				}

				//adds the timepoint into the current billing cycle object
				billingCycleEntry->Add(timePointEntry);

				//gets the next closingpoint set
				timePointDataSet = timePointSet->NextSetWithName(BILLCONFIG_CLOSINGPOINT_TAG);
			}

			long count;
			billingCycleEntry->get_Count(&count);
			if (count == 0) {
				string buffer = "The cycle '";
				buffer += cycleType;
				buffer += "' requires at least one closingPoint.";
				mLogger.LogVarArgs(LOG_ERROR, buffer.c_str());
				return Error (buffer.c_str(), IID_IMTBillingCycleConfig, E_FAIL);
			}
		}

		//the following cycleType's all use startingPoints
		else if ((cycleType == BILLCONFIG_CYCLE_BIWEEKLY)  ||
						 (cycleType == BILLCONFIG_CYCLE_QUARTERLY) ||
             (cycleType == BILLCONFIG_CYCLE_SEMIANNUALLY) ||
						 (cycleType == BILLCONFIG_CYCLE_ANNUALLY)) 
		{

			//gets the startingpoints block (contains startingpoint objects)
			timePointSet = billingCycleDataSet->NextSetWithName(BILLCONFIG_STARTINGPOINTS_TAG);
			if (timePointSet == NULL)
			{
				string buffer = "Required tag '";
				buffer += BILLCONFIG_STARTINGPOINTS_TAG;
				buffer += "' was not found.";
				mLogger.LogVarArgs(LOG_ERROR, buffer.c_str());
				return Error (buffer.c_str(), IID_IMTBillingCycleConfig, E_FAIL);
			}
			
			//gets the first startingpoint set
			timePointDataSet = timePointSet->NextSetWithName(BILLCONFIG_STARTINGPOINT_TAG);
			while (timePointDataSet != NULL) {

				//creates the new TimePoint object
				CComObject<CMTTimePoint>* timePointEntry;
				HRESULT hr = CComObject<CMTTimePoint>::CreateInstance(&timePointEntry);
				if (FAILED(hr)) {
					string buffer = "Could not create MTTimePoint instance";
					mLogger.LogVarArgs(LOG_ERROR, buffer.c_str());
					return Error (buffer.c_str(), IID_IMTBillingCycleConfig, hr);
				}

				//gets the month property
				id = timePointDataSet->NextLongWithName(BILLCONFIG_MONTH_TAG);
				_bstr_t month = enumConfig->GetEnumeratorByID(id);
				_variant_t vtMonthIndex = enumConfig->GetEnumeratorValueByID(id);

				timePointEntry->put_Month(month);
				timePointEntry->put_MonthIndex((long) vtMonthIndex);

				//gets the day property
				long day = timePointDataSet->NextLongWithName(BILLCONFIG_DAY_TAG);
				timePointEntry->put_Day(day);

				//so far BIWEEKLY, QUARTERLY, and ANNUALLY all require both 
				//month and day properties. BIWEEKLY in addition requires
				//year and label properties
				if (cycleType == BILLCONFIG_CYCLE_BIWEEKLY) {

					//gets the year property
					long year = timePointDataSet->NextLongWithName(BILLCONFIG_YEAR_TAG);
					timePointEntry->put_Year(year);

					//gets the label property
					_bstr_t label = timePointDataSet->NextStringWithName(BILLCONFIG_LABEL_TAG);
					timePointEntry->put_Label(label);
				}

				//adds the timepoint into the current billing cycle object
				billingCycleEntry->Add(timePointEntry);

				//gets the next startingpoint set
				timePointDataSet = timePointSet->NextSetWithName(BILLCONFIG_STARTINGPOINT_TAG);
			}

			long count;
			billingCycleEntry->get_Count(&count);
			if (count == 0) {
				string buffer = "The cycle '";
				buffer += cycleType;
				buffer += "' requires at least one startingPoint.";
				mLogger.LogVarArgs(LOG_ERROR, buffer.c_str());
				return Error (buffer.c_str(), IID_IMTBillingCycleConfig, E_FAIL);
			}
		}
		//-----------------------------------
		// --- END CYCLE SPECIFIC PARSING ---
		//-----------------------------------

		//adds the billing cycle to the config collection
		Add(billingCycleEntry);
				
		//gets the next billingCycleData set
		billingCycleDataSet = billingCycleSet->NextSetWithName(BILLCONFIG_BILLINGCYCLE_TAG);
	}

	long count;
	get_Count(&count);
	mLogger.LogVarArgs(LOG_INFO, "Total billing cycles added: %d", count);


	} //end of try block
	catch (_com_error & err)
	{
		bstr_t desc = err.Description();
		mLogger.LogVarArgs(LOG_ERROR, "com error: '%s'", (const char *) desc);
		return ReturnComError(err);
	}

	return S_OK;
}
