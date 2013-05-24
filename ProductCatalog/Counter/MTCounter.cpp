/**************************************************************************
*
* Copyright 2001 by MetraTech Corporation
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
* Created by: Boris Partensky
* $Header: c:\development35\ProductCatalog\Counter\MTCounter.cpp, 48, 10/9/2002 5:36:17 PM, Derek Young$
*
***************************************************************************/

#include "StdAfx.h"
#include "Counter.h"

#include "MTCounter.h"
#include <DataAccessDefs.h>

/////////////////////////////////////////////////////////////////////////////
// CMTCounter

STDMETHODIMP CMTCounter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCounter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTCounter::FinalConstruct()
{
	mpType = NULL;
	mpPC = NULL;
	mpParams = NULL;
	mlID = -1;
	mlTypeID = -1;
	mlNewTypeID = -1;
	mlNumSetParams = 0;
	mbTypeChanged = FALSE;
	mbAllHardcodedParametersSet = FALSE;
  mPIID = -1;

	try
	{
		HRESULT hr = CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &mUnkMarshalerPtr.p);
		if (FAILED(hr))
			throw _com_error(hr);
		hr = mpFormulaAdapter->Init();
		if (FAILED(hr))
			throw _com_error(hr);

		LoadPropertiesMetaData( PCENTITY_TYPE_COUNTER);
	}	
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return mpPC.CreateInstance("Metratech.MTProductCatalog");
}

void CMTCounter::FinalRelease()
{
	mUnkMarshalerPtr.Release();
	mpType = NULL;

	if(mpParams)
	{
		delete mpParams;
		mpParams = NULL;
	}

}

//Init internal state based on passed in DB id


STDMETHODIMP CMTCounter::get_Formula(MTViewPreference aView, BSTR *pVal)
{
	HRESULT hr(S_OK);
	try
	{
		MTCOUNTERLib::IMTCounterPtr thisPtr = this;
		MTCOUNTERLib::IMTCounterTypePtr typePtr;
		if(mFormula.length() == 0)
		{
			typePtr = thisPtr->Type;
			mFormula = typePtr->FormulaTemplate;
			mpFormulaAdapter->SetFormula(mFormula);
		}

		switch(aView)
		{
		case VIEW_FINAL:
			{
				if(mExpandedFormula.length() == 0)
				{
					ConstructExpandedFormula();
				}

				if(pVal)
					(*pVal) = mExpandedFormula.copy();

				break;
			}
		case VIEW_NORMAL:
			{
				if(pVal)
					(*pVal) = mFormula.copy();
				break;
			}
		case VIEW_SQL:
			{
				//Since we needed to modify the SQL for
				//CR 6069 fix, it was a good idea to leave aggregate
				//charge query intact. There probably would be NO EFFECT
				//to construct the formula in the same way for discounts
				//and aggregate charges, we should change it in the future,
				//but due to release date proximity I am going to separate it into
				//2 calls - ConstructSQLFormula (for aggregate charges) and ConstructDiscountQueryStatement
				hr = ConstructSQLFormula();
				if(FAILED(hr))
					return hr;
				if(pVal)
					(*pVal) = mSQLFormula.copy();
				break;
			}
		case VIEW_USER:
			{
				hr = ConstructUserFormula();
				if(FAILED(hr))
					return hr;
				if(pVal)
					(*pVal) = mUserFormula.copy();
				break;
			}
		case VIEW_DISCOUNTS:
			{
				//Since we needed to modify the SQL for
				//CR 6069 fix, it was a good idea to leave aggregate
				//charge query intact. There probably would be NO EFFECT
				//to construct the formula in the same way for discounts
				//and aggregate charges, we should change it in the future,
				//but due to release date proximity I am going to separate it into
				//2 calls - ConstructSQLFormula (for aggregate charges) and ConstructDiscountQueryStatement
				hr = ConstructDiscountQueryStatement();
				if(FAILED(hr))
					return hr;
				if(pVal)
					(*pVal) = mDiscountQueryStatement.copy();
				break;
			}
		}
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	return S_OK;
}


//as of 3.5 this method is deprecated

STDMETHODIMP CMTCounter::SetParameter(BSTR aParamName, BSTR aParam, VARIANT aDontValidateString)
{
	PCCache::GetLogger().LogThis
    (LOG_DEBUG, "SetParameter method has been deprecated in Version 3.5. Use GetParameter(\"Name\").Value = \"Val\" instead");
  return S_OK;
}

STDMETHODIMP CMTCounter::Execute(long aStrategy, DATE aStartDate, DATE aEndDate, IMTCollection* apAccountList, IMTSQLRowset** aCounterValue)
{
	return E_NOTIMPL;

}

/*

STDMETHODIMP CMTCounter::Execute(long aStrategy, DATE aStartDate, DATE aEndDate, IMTCollection* apAccountList, IMTSQLRowset** aCounterValue)
{
//for each param p.GetPVName()
// viewname CreateView()
//aggr + ( + viewname + . + p.GetPropertyName() (or * if kind is PV)
//Check following basic rules: 
//1.Do we need to check validity of SQL aggregate?
//	If someone specified CRAP(%%A%%) should be still construct SQL statement 
//	and execute it?
//	Probably Yes, because creating a new counter type is SI job
//2. The same probably goes for parameter kind - aggr function mismatch


HRESULT hr(S_OK);
map<_bstr_t, _bstr_t> viewNames;
map<_bstr_t, _bstr_t>::iterator it;

hr = ConstructSQLFormula(&viewNames);

if(FAILED(hr))
return hr;


CMTAccountSummaryCounterStrategy strategy;
strategy.Init();
strategy.AddSelectField(_bstr_t("id_acc"));

for (it = viewNames.begin(); it != viewNames.end(); ++it)
{
strategy.AddSelectFromTable((*it).first, (*it).second);
}

strategy.AddSelectFromTable(L"t_acc_usage", L"t_acc_usage");

strategy.AddCounter(mSQLFormula);

strategy.AddWhereClauseCondition(L"dt_crt", aStartDate, DATATYPE_DATE, OPERATOR_GREATER);
strategy.AddWhereClauseCondition(L"dt_crt", aEndDate, DATATYPE_DATE, OPERATOR_LESS);
strategy.AddWhereClauseCondition(L"id_acc", apAccountList, DATATYPE_NUMERIC);

_bstr_t bstrStatement = strategy.CreateStatement();
//log statement
return strategy.Execute(aCounterValue);
}
*/

STDMETHODIMP CMTCounter::Save(long *aDBID)
{
	try
	{
		HRESULT hr(S_OK);
		MTCOUNTERLib::IMTCounterPtr thisPtr = this;
		MTCOUNTERLib::IMTCounterTypePtr typePtr = thisPtr->Type;

		MTPRODUCTCATALOGEXECLib::IMTCounterWriterPtr writer("Metratech.MTCounterWriter");

		// TODO: this is NOT the right way to construct the session context.
		// We should really retrieve the credentials and login as the user invoking the script
		MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr
			context(MTPROGID_MTSESSIONCONTEXT);
		context->PutAccountID(0);

		if(HasID())
		{
			writer->Update(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(context.GetInterfacePtr()),
				reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCounter*>(thisPtr.GetInterfacePtr()));
			(*aDBID) = mlID;
			mbTypeChanged = FALSE;
			return hr;
		}
		//check for incomplete info
		if(mlTypeID < 0)
			return MTPC_ITEM_CANNOT_BE_SAVED;

		thisPtr->Parameters;

		long count;
		MTCOUNTERLib::IMTCollectionPtr params = typePtr->Parameters;
		count = params->Count;
		//if (count > mlNumSetParams)
		//	return MTPC_NOT_ALL_PARAMS_SPECIFIED;
		if(mName.length() == 0)
			return MTPC_ITEM_CANNOT_BE_SAVED;

		mlID = writer->Create(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(context.GetInterfacePtr()), 
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCounter*>(thisPtr.GetInterfacePtr()));
		(*aDBID) = mlID;
		return hr;
	}
	catch (_com_error & err)
	{ 
		return ReturnComError(err); 
	}
}

STDMETHODIMP CMTCounter::get_Parameters(IMTCollection** pVal)
{
	//On demand load internal collection and return it out
	HRESULT hr(S_OK);

	if(mpParams)
	{
		if(pVal)
			hr = mpParams->CopyTo(pVal);
		return hr;
	}
	if(pVal)
		return LoadParams(pVal);
	else
		return LoadParams(NULL);
}


STDMETHODIMP CMTCounter::Load(long aDBID)
{
	//load this state from database
	HRESULT hr(S_OK);

	return hr;

}


STDMETHODIMP CMTCounter::get_Name(BSTR *pVal)
{
	if(!pVal)
		return E_POINTER;
	(*pVal) = mName.copy();
	return S_OK;
}

STDMETHODIMP CMTCounter::put_Name(BSTR newVal)
{
	mName = newVal;
	return PutPropertyValue("Name", newVal);
}



STDMETHODIMP CMTCounter::get_Description(BSTR *pVal)
{
	if(!pVal)
		return E_POINTER;
	(*pVal) = mDescription.copy();
	return S_OK;
}

STDMETHODIMP CMTCounter::put_Description(BSTR newVal)
{
	mDescription = newVal;
	return PutPropertyValue("Description", newVal);
}

STDMETHODIMP CMTCounter::get_ID(long *pVal)
{
	if(!pVal)
		return E_POINTER;
	(*pVal) = mlID;
	return S_OK;
}

STDMETHODIMP CMTCounter::put_ID(long newVal)
{
	mlID = newVal;	
	return PutPropertyValue("ID", newVal);
}

STDMETHODIMP CMTCounter::get_TypeID(long *pVal)
{
	if(!pVal)
		return E_POINTER;
	(*pVal) = mlTypeID;
	return S_OK;
}

STDMETHODIMP CMTCounter::put_TypeID(long newVal)
{
	mlTypeID = newVal;
	return PutPropertyValue("TypeID", newVal);
}

STDMETHODIMP CMTCounter::get_Type(IMTCounterType** apVal)
{
	//init mpType on-demand
	HRESULT hr(S_OK);
	try
	{
		if(apVal == NULL)
			return E_POINTER;
		(*apVal) = NULL;

		if(mpType == NULL)
		{
			mpType = mpPC->GetCounterType(mlTypeID);
		}
		MTCOUNTERLib::IMTCounterTypePtr outPtr = mpType;
		(*apVal) = reinterpret_cast<IMTCounterType*>(outPtr.Detach());
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;
}

//Put type method should be called only internally by MTCounterType object
//when it creates an instances of itself
STDMETHODIMP CMTCounter::put_Type(IMTCounterType* newVal)
{
	HRESULT hr(S_OK);
	mbTypeChanged = FALSE;

	mpType = newVal;
	mlNewTypeID = mpType->ID;
	if(mlTypeID != mlNewTypeID)
	{
		mbTypeChanged = TRUE;
		mlTypeID = mlNewTypeID;
	}

	//null out parameters
	if(mpParams)
	{
		delete mpParams;
		mpParams = NULL;
	}
	//invalidate formula and formula template
	mFormula = _bstr_t("");
	mExpandedFormula = _bstr_t("");
	mUserFormula =  _bstr_t("");
	mSQLFormula = _bstr_t("");
	mlNumSetParams = 0;

	return PutPropertyObject("type", (IDispatch*) newVal);
}

STDMETHODIMP CMTCounter::LoadParams(IMTCollection** pVal)
{
	try
	{
		// TODO: this is NOT the right way to construct the session context.
		// We should really retrieve the credentials and login as the user invoking the script
		MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr
			context(MTPROGID_MTSESSIONCONTEXT);

		context->PutAccountID(0);
		MTCOUNTERLib::IMTCounterPtr thisPtr = this;

		HRESULT hr(S_OK);
		MTPRODUCTCATALOGEXECLib::IMTCounterParamReaderPtr reader("Metratech.MTCounterParamReader");

		ASSERT(mpParams == NULL);
		mpParams = new MTObjectCollection<IMTCounterParameter>;
		_ASSERTE(mpParams != NULL);

		//read in counter parameters, return them and init mpParams
		//TODO: Do we need to invalidate mpParams if DB changes??

		MTCOUNTERLib::IMTCollectionPtr params = NULL;
		if(mlID > 0 && !mbTypeChanged)
			params = reader->FindParameters(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(context.GetInterfacePtr()), 
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCounter*>(thisPtr.GetInterfacePtr()));
		else
			params = reader->FindParameterTypes
			(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(context.GetInterfacePtr()),
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCounter*>(thisPtr.GetInterfacePtr()));

		(*mpParams) = (IMTCollection*)params.GetInterfacePtr();

		//no params have been saved yet for this instance
		//load params from type
		/*
		if(mpParams->Count == 0)
		{
		reader->FindParameterTypes((IMTSessionContext *) context.GetInterfacePtr(), mlTypeID);
		}
		*/

		//try and find hardcoded parameters, like in
		//"TotalUsageCounter", part of CR 5954 fix
		//Add harcoded parameters to mpParams collection
		hr = AddHardcodedParameters();
		if(FAILED(hr))
			return hr;

		if(pVal)
		{
			hr = mpParams->CopyTo(pVal);
			return hr;
		}
		return hr;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}

HRESULT CMTCounter::GetHardcodedParameterValues(vector<_bstr_t>& aValues, unsigned int aPos)
{
	HRESULT hr(S_OK);
	wchar_t open =	L'(';
	wchar_t close	= L')';
	wchar_t delim = L'%';

	if(mFormula.length() == 0)
	{
		hr = get_Formula(VIEW_NORMAL);
		if(FAILED(hr))
			return hr;
	}
	wstring wsValue = (const wchar_t*) mFormula;
	wstring wsTemp;

	//find first (
	//find first )
	//if any % between them, then continue
	//else add string between them to aValues;
	//recursive with substring
	if(wsValue.length() < aPos)
		return S_OK;

	wsValue = wsValue.substr(aPos);

	int nOpenPos = wsValue.find_first_of(open);

	if (nOpenPos ==  (int) basic_string<wchar_t>::npos)
		return S_OK;
	else
	{
		int nClosePos = wsValue.find_first_of(close, nOpenPos);

		if (nClosePos ==  (int) basic_string<wchar_t>::npos)
			//couldn't find matching close parentesis
			return MTPC_UNABLE_TO_PARSE_COUNTER_FORMULA;

		wsTemp = wsValue.substr( (nOpenPos+1), (nClosePos-nOpenPos-1) ).c_str();

		int nDelimPos = wsTemp.find_first_of(delim);

		int offset = (aPos + nOpenPos + nClosePos - 1);
		if (nDelimPos !=  (int) basic_string<wchar_t>::npos)
		{
			//found delimiter, make recursive call
			hr = GetHardcodedParameterValues(aValues, offset);
			if(FAILED(hr))
				return hr;
		}
		else
		{
			//didn't find delimiter, add substring to values and make recursive call
			aValues.push_back(_bstr_t(wsTemp.c_str()));
			hr = GetHardcodedParameterValues(aValues, offset);
			if(FAILED(hr))
				return hr;
		}

	}

	return hr;
}

STDMETHODIMP CMTCounter::get_Alias(BSTR *pVal)
{
	if(!pVal)
		return E_POINTER;

	(*pVal) = mAlias.copy();

	return S_OK;
}

STDMETHODIMP CMTCounter::put_Alias(BSTR newVal)
{
	mAlias = newVal;
	return PutPropertyValue("Alias", newVal);
}

HRESULT CMTCounter::ConstructSQLFormula(map<_bstr_t, _bstr_t>* apViewNames)
{
	HRESULT hr(S_OK);
	if(mSQLFormula.length() && apViewNames == NULL) return hr;
	return ConstructAggrQueryStatement(mSQLFormula, apViewNames);
}

HRESULT CMTCounter::ConstructUserFormula()
{
	HRESULT hr(S_OK);

	if(mUserFormula.length())
		return hr;


	if(mpParams == NULL)
	{
		hr = LoadParams();
		if(FAILED(hr))
			return hr;
	}


	if(mFormula.length() == 0)
	{
		hr = get_Formula(VIEW_NORMAL);
		if(FAILED(hr))
			return hr;
	}
	CMTFormulaAdapter adapter;

	hr = adapter.Init();

	if(FAILED(hr))
		return hr;

	hr = adapter.SetFormula(mFormula);

	if(FAILED(hr))
		return hr;

	long lNumParams;
	mpParams->Count(&lNumParams);

	for(int i = 1; i <= lNumParams; ++i)
	{
		MTCOUNTERLib::IMTCounterParameterPtr paramPtr;

		hr = mpParams->Item(i, (IMTCounterParameter**)&paramPtr);

		_bstr_t bstrName = paramPtr->Name;

		//replace %%A%% with A (user-friendly version)
		if(bstrName.length() > 0)
			hr = adapter.SetParameter(bstrName, bstrName);

		if(FAILED(hr))
			return hr;
	}

	BSTR userFormula;
	hr = adapter.GetFormula(&userFormula);
	if(FAILED(hr))
		return hr;

	_bstr_t bstrUserFormula = _bstr_t(userFormula, false);

	mUserFormula = bstrUserFormula.copy();

	return hr;
}


HRESULT CMTCounter::Reset()
{
	HRESULT hr(S_OK);

	mpType = NULL;
	mpParams = NULL;
	mName = "";
	mDescription = "";
	mFormula = "";
	mAlias = "";
	mExpandedFormula = "";
	mSQLFormula = "";
	mUserFormula = "";
	mlTypeID = -1;
	mlNewTypeID = -1;
	mlNumSetParams = 0;

	PutPropertyValue("Name", L"");
	PutPropertyValue("Description", L"");
	PutPropertyValue("ID", (long)-1);
	PutPropertyValue("TypeID", (long)-1);
	PutPropertyObject("type", NULL);
	PutPropertyValue("Alias", L"");

	return hr;

}

STDMETHODIMP CMTCounter::Remove()
{
	try
	{
		// TODO: this is NOT the right way to construct the session context.
		// We should really retrieve the credentials and login as the user invoking the script
		MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr
			context(MTPROGID_MTSESSIONCONTEXT);
		context->PutAccountID(0);

		HRESULT hr(S_OK);
		MTPRODUCTCATALOGEXECLib::IMTCounterWriterPtr writer("Metratech.MTCounterWriter");

		if(!HasID())
			return hr;
		long lID = mlID;

		hr = Reset();
		if(FAILED(hr))
			return hr;

		mlID = -1;
		return writer->Remove(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(context.GetInterfacePtr()), lID);
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}

HRESULT CMTCounter::AddHardcodedParameters()
{
	HRESULT hr(S_OK);
	vector<_bstr_t> HardcodedValues;
	try
	{

		if(mbAllHardcodedParametersSet) return hr;

		hr = GetHardcodedParameterValues(HardcodedValues);

		if(FAILED(hr))
			return hr;

		vector<_bstr_t>::iterator it = HardcodedValues.begin();
		while(it != HardcodedValues.end())
		{
			wstring wsFormula;
			wstring wsValueToReplace;
			wstring wsValueReplaceWith;
			wstring wsColumn;

			_bstr_t temp = *it++;
			MTCOUNTERLib::IMTCounterParameterPtr param(__uuidof(MTCounterParameter));
			//TODO: do the best to actually try and determine parameter kind
			param->PutKind("ProductViewProperty");
			param->Value = temp;
			//Set this parameter as Read Only, so that no one will see
			//any screens to edit it - it's not possible
			param->ReadOnly = VARIANT_TRUE;
			//CR 5954 fix: Add harcoded parameters to the parameter collection
			mpParams->Add(reinterpret_cast<IMTCounterParameter*>(param.GetInterfacePtr()));
		}
		mbAllHardcodedParametersSet = TRUE;
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	return hr;
}


HRESULT CMTCounter::ConstructAggrQueryStatement(_bstr_t& aStr, map<_bstr_t, _bstr_t>* apViewNames)
{
	HRESULT hr(S_OK);
	try
	{
		_bstr_t bstrPVName;
		_bstr_t bstrName;
		_bstr_t bstrValue;
		_bstr_t bstrView;

		if(mpParams == NULL)
		{
			hr = LoadParams();
			if(FAILED(hr))
				return hr;
		}

		if(mFormula.length() == 0)
		{
			hr = get_Formula(VIEW_NORMAL);
			if(FAILED(hr))
				return hr;
		}

		hr = AddHardcodedParameters();

		if(FAILED(hr))
			return hr;


		CMTFormulaAdapter adapter;

		hr = adapter.Init();

		if(FAILED(hr))
			return hr;

		hr = adapter.SetFormula(mFormula);

		if(FAILED(hr))
			return hr;

		long lNumParams;
		mpParams->Count(&lNumParams);


		//prepare counter part
		for(int i = 1; i <= lNumParams; ++i)
		{
			BSTR pvname;
			VARIANT_BOOL bReadOnly = VARIANT_FALSE;

			MTCOUNTERLib::IMTCounterParameterPtr paramPtr;

			hr = mpParams->Item(i, (IMTCounterParameter**)&paramPtr);

			MTCOUNTERLib::MTCounterParamKind kind = paramPtr->GetKind();
			bReadOnly = paramPtr->ReadOnly;
			hr = paramPtr->get_ProductViewName(&pvname);

			if(SUCCEEDED(hr))
			{

				bstrPVName = _bstr_t(pvname, false);

				bstrView = paramPtr->TableName;

				if(apViewNames)
				{
					//If Parameter hardcoded, then alias it
					/*
					if(bReadOnly)
					{
					bstrView += _bstr_t(L" ");
					bstrView += _bstr_t(RESERVED_USAGE_ALIAS);
					}
					*/
					apViewNames->insert(map<_bstr_t, _bstr_t>::value_type(bstrView, bstrPVName));
				}
			}
			else
			{
				if(hr != MTPC_PROPERTY_IRRELEVANT_FOR_THIS_PARAM_KIND)
					return hr;
			}

			bstrName = paramPtr->Name;
			bstrValue = paramPtr->FinalValue;

			//determines which database vendor (SQLServer or Oracle) is being used
			ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
			rowset->Init(CONFIG_DIR);
			_bstr_t dbType = rowset->GetDBType();
			bool isOracle = (mtwcscasecmp(dbType, ORACLE_DATABASE_TYPE) == 0);

			//handles values that come back as NULL by converting them to 0
			//this is crucial for the counts on the first transaction of an aggregate charge

			//Only do this if if parameter type is PARAM_PRODUCT_VIEW_PROPERTY
			if(kind == MTCOUNTERLib::PARAM_PRODUCT_VIEW_PROPERTY)
			{
				if (isOracle) 
					aStr = "NVL(";
				else
					aStr = "ISNULL(";
				aStr += bstrValue;
				aStr += ", 0)";
			}
			else
				aStr = bstrValue;

			if(bstrName.length() > 0)
				hr = adapter.SetParameter(bstrName, aStr);
			if(FAILED(hr))
				return hr;
		}

		BSTR finalCounter;
		hr = adapter.GetFormula(&finalCounter);

		if(FAILED(hr))
			return hr;

		aStr = "(";
		aStr += _bstr_t(finalCounter, false);
		aStr += ")";
		aStr += " AS ";
		if(mAlias.length() == 0)
			aStr += _bstr_t(DEFAULT_ALIAS);
		else
			aStr += mAlias;
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	return hr;
}

HRESULT CMTCounter::ConstructDiscountQueryStatement()
{
	HRESULT hr(S_OK);
	_bstr_t bstrProductViewTableName;
	_bstr_t bstrName;
	_bstr_t bstrValue;
	VARIANT_BOOL bIsReadOnly = VARIANT_FALSE;

	if(mDiscountQueryStatement.length())
		return hr;

	if(mpParams == NULL)
	{
		hr = LoadParams();
		if(FAILED(hr))
			return hr;
	}

	if(mFormula.length() == 0)
	{
		hr = get_Formula(VIEW_NORMAL);
		if(FAILED(hr))
			return hr;
	}

	hr = AddHardcodedParameters();

	if(FAILED(hr))
		return hr;


	CMTFormulaAdapter adapter;

	hr = adapter.Init();

	if(FAILED(hr))
		return hr;

	hr = adapter.SetFormula(mFormula);

	if(FAILED(hr))
		return hr;

	long lNumParams;
	mpParams->Count(&lNumParams);


	//prepare counter part
	for(int i = 1; i <= lNumParams; ++i)
	{
		BSTR pvname;
		
		MTCOUNTERLib::IMTCounterParameterPtr paramPtr;

		hr = mpParams->Item(i, (IMTCounterParameter**)&paramPtr);

		MTCOUNTERLib::MTCounterParamKind kind;

		kind = paramPtr->GetKind();
		bIsReadOnly = paramPtr->ReadOnly;
		hr = paramPtr->get_ProductViewName(&pvname);

		if(!SUCCEEDED(hr) && hr != MTPC_PROPERTY_IRRELEVANT_FOR_THIS_PARAM_KIND)
			return hr;

		bstrName = paramPtr->Name;
		bstrProductViewTableName = paramPtr->ProductViewTable;
		bstrValue = paramPtr->FinalValue;

		//determines which database vendor (SQLServer or Oracle) is being used
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		_bstr_t dbType = rowset->GetDBType();
		bool isOracle = (mtwcscasecmp(dbType, ORACLE_DATABASE_TYPE) == 0);

		std::wstring wsNULL = isOracle ? L"NVL(" : L"ISNULL(";
		std::wstring wsPrefix = L"( CASE WHEN ";
		std::wstring wsMiddle = L".id_sess IS NULL THEN 0 ELSE ";
		std::wstring wsRealParameterValue(L"");


		//handles values that come back as NULL by converting them to 0
		//this is crucial for the counts on the first transaction of an aggregate charge

		//Only do this if if parameter type is PARAM_PRODUCT_VIEW_PROPERTY
		if(kind == MTCOUNTERLib::PARAM_PRODUCT_VIEW_PROPERTY)
		{
			wsRealParameterValue = wsPrefix;
			wsRealParameterValue += (wchar_t*)bstrProductViewTableName;
			wsRealParameterValue += wsMiddle;
			wsRealParameterValue += wsNULL;
			wsRealParameterValue += (wchar_t*)bstrValue;
			wsRealParameterValue += L", 0) END )";
		}
		else
			wsRealParameterValue = bstrProductViewTableName + bstrValue;

    //figure out adjustment table and add adjustments to the charge
    // +
    // SUM(( CASE WHEN t_adjustment_transaction.id_sess IS NULL THEN 0 ELSE ISNULL(t_adjustment_transaction.AdjustmentAmount, 0) END ))

    long lChargeID = paramPtr->ChargeID;
    if(lChargeID > 0)
    {
      //if counter param is based on a charge, then
      //it's column name equals to MTCharge AmountName
      _bstr_t bstrChargeColumn = paramPtr->ColumnName;
      
      //get adjustment table from pv table
      //AJ* tables don't need to be alised, because they
      //are not shared across product views
      char ajtablename [256];
      char ajcolumn [256];
      sprintf(ajtablename, "t_aj_%s", string((char*)bstrProductViewTableName, 5, bstrProductViewTableName.length()).c_str() );
      sprintf(ajcolumn, "c_aj_%s", string((char*)bstrChargeColumn, 2, bstrChargeColumn.length()).c_str() );
      char buf[1024];
      sprintf(buf, " + ( CASE WHEN %s.id_adjustment IS NULL THEN 0 ELSE %s(%s.%s, 0) END )", 
        ajtablename, isOracle ? "NVL" : "ISNULL", ajtablename, ajcolumn);
      wsRealParameterValue += _bstr_t(buf);
      paramPtr->AdjustmentTable = ajtablename;
    }
    else
    {
      MTCOUNTERLib::IMTCounterPtr ThisPtr = this;
      MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr pitypePtr;
      //PI ID should be set at this point
      //it's set in Discount->LoadCounters method
      long pitypeid = paramPtr->PriceableItemTypeID;
      long lViewID = 0;
      //we still support product views that are not based on PI types
      //in this case get product view object directly
      if(pitypeid < 0)
      {
        // TODO: this is NOT the right way to construct the session context.
		    // We should really retrieve the credentials and login as the user invoking the script
		    MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr
			    context(MTPROGID_MTSESSIONCONTEXT);
		    context->PutAccountID(0);
        MTPRODUCTVIEWEXECLib::IMTProductViewReaderPtr pvreader("Metratech.MTProductViewReader");
        MTPRODUCTVIEWEXECLib::IProductViewPtr pvPtr = pvreader->FindByName
          (
          reinterpret_cast<MTPRODUCTVIEWEXECLib::IMTSessionContext*>(context.GetInterfacePtr()), 
          paramPtr->ProductViewName
          );
        lViewID = pvPtr->ViewID;
      }
      else
      {
        pitypePtr = mpPC->GetPriceableItemType(pitypeid);
        lViewID = pitypePtr->GetProductViewObject()->ViewID;
      }

      //in this case adjustment table is t_adjustment_transaction
      //Those need to be aliased because multiple product views
      //access the same table;
      //append view id to the name. This should do the trick
      char ajtablename[256];
      sprintf(ajtablename, "vw_aj_info_%d", lViewID);
      char buf[1024];
      sprintf(buf, " + ( CASE WHEN %s.id_sess IS NULL THEN 0 ELSE %s(%s.CompoundPrebillAdjAmt, 0) END )", 
        ajtablename, isOracle ? "NVL" : "ISNULL", ajtablename);
      wsRealParameterValue += _bstr_t(buf);
      paramPtr->AdjustmentTable = "vw_aj_info";
    }

    // if this parameter is based on charge, then
    // figure out charge column name, and AJ table name



		if(bstrName.length() > 0)
			hr = adapter.SetParameter(bstrName, _bstr_t(wsRealParameterValue.c_str()));
		if(FAILED(hr))
			return hr;

    

		
	}

	BSTR finalCounter;
	hr = adapter.GetFormula(&finalCounter);

	if(FAILED(hr))
		return hr;

	mDiscountQueryStatement = "(";
	mDiscountQueryStatement += _bstr_t(finalCounter, false);
	mDiscountQueryStatement += ")";
	mDiscountQueryStatement += " AS ";
	if(mAlias.length() == 0)
		mDiscountQueryStatement += _bstr_t(DEFAULT_ALIAS);
	else
		mDiscountQueryStatement += mAlias;

	return hr;
}


STDMETHODIMP CMTCounter::GetParameter(BSTR aParamName, IMTCounterParameter **apParam)
{
	HRESULT hr(S_OK);
	try
	{
		MTCOUNTERLib::IMTCounterPtr thisPtr = this;
		long lNumParams;

		if(mpParams == NULL)
			LoadParams();

		mpParams->Count(&lNumParams);

		if(apParam == NULL)
			return E_POINTER;
		(*apParam) = NULL;

		_bstr_t bstrName = aParamName;

		//index is 1-based
		for (int i=1; i <= lNumParams; ++i)
		{
			MTCOUNTERLib::IMTCounterParameterPtr ptr;
			hr = mpParams->Item(i, (IMTCounterParameter**)&ptr);
			if(FAILED(hr))
				return hr;

			_bstr_t ParamName = ptr->Name;

			if(_wcsicmp((const wchar_t*)bstrName, (const wchar_t*)ParamName) == 0)
			{
				//ptr->Counter = thisPtr;
				(*apParam) = reinterpret_cast<IMTCounterParameter*>(ptr.GetInterfacePtr());

				(*apParam)->AddRef();
			}
		}

	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	return hr;
}

STDMETHODIMP CMTCounter::ConstructExpandedFormula()
{
	try
	{
		HRESULT hr(S_OK);
		mExpandedFormula = mFormula;
		mpFormulaAdapter->SetFormula(mFormula);
		MTCOUNTERLib::IMTCounterPtr thisPtr = this;
		long lNumParams;

		if(mpParams == NULL)
			LoadParams();

		mpParams->Count(&lNumParams);

		//index is 1-based

		/*
		if(lNumParams < mlNumSetParams)
		{
			MT_THROW_COM_ERROR(MTPC_NOT_ALL_PARAMS_SPECIFIED);
		}
		*/

		for (int i=1; i <= lNumParams; ++i)
		{
			MTCOUNTERLib::IMTCounterParameterPtr ptr;
			hr = mpParams->Item(i, (IMTCounterParameter**)&ptr);
			if(FAILED(hr))
				MT_THROW_COM_ERROR(hr);
			mpFormulaAdapter->SetParameter(ptr->Name, ptr->Value);
		}

		BSTR formula;
		hr = mpFormulaAdapter->GetFormula(&formula);
		if(FAILED(hr))
			MT_THROW_COM_ERROR(hr);
		mExpandedFormula = formula;
		SysFreeString(formula);
	}
	catch(_com_error& e)
	{
		MT_THROW_COM_ERROR(e.Error());
	}
	return S_OK;
}


//iterate through parameter collection, replace the item with the shared parameter
STDMETHODIMP CMTCounter::SetSharedParameter(BSTR aParamName, IMTCounterParameter *apParam)
{
	HRESULT hr(S_OK);
	try
	{
		MTCOUNTERLib::IMTCounterPtr thisPtr = this;

		long lNumParams;

		if(mpParams == NULL)
			LoadParams();

		mpParams->Count(&lNumParams);

		if(apParam == NULL)
			return E_POINTER;

		_bstr_t bstrName = aParamName;
		MTCOUNTERLib::IMTCounterParameterPtr paramPtr = apParam;

		//index is 1-based
		for (int i=1; i <= lNumParams; ++i)
		{
			MTCOUNTERLib::IMTCounterParameterPtr ptr;
			hr = mpParams->Item(i, (IMTCounterParameter**)&ptr);
			if(FAILED(hr))
				return hr;

			_bstr_t ParamName = ptr->Name;

			if(_wcsicmp((const wchar_t*)bstrName, (const wchar_t*)ParamName) == 0)
			{
				mpParams->Remove(i);
				paramPtr->Name = bstrName;
				//set id for parameter meta data
				paramPtr->TypeID = ptr->TypeID;
				mpParams->Add(reinterpret_cast<IMTCounterParameter*>(paramPtr.GetInterfacePtr()));
				mlNumSetParams++;
				return S_OK;
			}
		}

	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	return hr;
}

STDMETHODIMP CMTCounter::get_PriceableItemID(long *pVal)
{
	(*pVal) = mPIID;
  return S_OK;
}

STDMETHODIMP CMTCounter::put_PriceableItemID(long newVal)
{
	mPIID = newVal;
	return S_OK;
}

