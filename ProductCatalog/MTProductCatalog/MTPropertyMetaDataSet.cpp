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

#include <OdbcConnMan.h>
#include <OdbcConnection.h>

#include <metra.h>
#include <comdef.h>
#include <mtcomerr.h>
#include <stdutils.h>
#include <MTUtil.h>
#include <mtprogids.h>
#include <formatdbvalue.h>

#include "MTProductCatalog.h"
#include "MTPropertyMetaDataSet.h"

#import "MTProductCatalog.tlb" rename ("EOF", "RowsetEOF")
//#import "MTProductCatalogExec.tlb" rename ("EOF", "RowsetEOF")

#include <set>
using namespace MTPropertyMetaDataSetNamespace;
using namespace std;


/////////////////////////////////////////////////////////////////////////////
// CMTPropertyMetaDataSet

/******************************************* error interface ***/
STDMETHODIMP CMTPropertyMetaDataSet::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPropertyMetaDataSet
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

/********************************** construction/destruction ***/
CMTPropertyMetaDataSet::CMTPropertyMetaDataSet()
{
	mUnkMarshalerPtr = NULL;
}

HRESULT CMTPropertyMetaDataSet::FinalConstruct()
{
	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &mUnkMarshalerPtr.p);
}

void CMTPropertyMetaDataSet::FinalRelease()
{
	mUnkMarshalerPtr.Release();
}

/********************************** IMTPropertyMetaDataSet***/
STDMETHODIMP CMTPropertyMetaDataSet::get_Item(VARIANT aKey, VARIANT *pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	try
	{
		switch(aKey.vt)
		{
		case VT_I4:
			return CollImpl::get_Item(aKey.lVal, pVal);

		case VT_I2:
			return CollImpl::get_Item((long)aKey.iVal, pVal);

		case VT_BSTR:
			{
				// make name uppercase, so case won't matter
				mtwstring wName(aKey.bstrVal);
				wName.toupper();

				//indexed by name
				PropMap::iterator it;
				it = m_coll.find(wName.c_str());
				
				if(it == m_coll.end())
				{ _bstr_t name = aKey.bstrVal;
					MT_THROW_COM_ERROR( MTPC_PROPERTY_NOT_FOUND, (const char*)name);
				}

				pVal->vt = VT_DISPATCH;
				IMTPropertyMetaData * pProp = (*it).second;

				//copy the item's IDispatch into pItem (also implicit AddRef))
				return pProp->QueryInterface(IID_IDispatch, (void**) & (pVal->pdispVal));
			}

		default:	
			//unrecognized index type
			return E_INVALIDARG;
		}
	}	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaDataSet::Exist(/*[in]*/ VARIANT aKey, /*[out, retval]*/ VARIANT_BOOL* apExist)
{
	if (apExist == NULL)
		return E_POINTER;

	*apExist = VARIANT_FALSE; //init

	HRESULT hr = S_OK;
	CComVariant varKey;

	if (aKey.vt != VT_BSTR)
	{
		// If the index isn't a string, but can be converted to a long value interpret as string

		hr = varKey.ChangeType(VT_I4, &aKey);
		if (SUCCEEDED(hr))
		{
			unsigned long idx = varKey.ulVal;
			if (idx >= 1 && idx <= m_coll.size())
			{  //idx is within bounds
				*apExist = VARIANT_TRUE;
			}
			return S_OK;
		}
	}

	// Otherwise, we assume index is a string key into the map
	hr = varKey.ChangeType(VT_BSTR, &aKey);

	// If we can't convert to a string, just return
	if (FAILED(hr))
		return hr;

	mtwstring wName(varKey.bstrVal);
	wName.toupper();

	PropMap::iterator it = m_coll.find(CComBSTR(wName));

	if (it != m_coll.end())
	{	// item found
		*apExist = VARIANT_TRUE;
	}
		
	return S_OK;
}


STDMETHODIMP CMTPropertyMetaDataSet::CreateMetaData(/*[in]*/ BSTR aPropertyName, /*[out, retval]*/ IMTPropertyMetaData** apMetaData)
{
	if (!apMetaData)
		return E_POINTER;
	
	//create a metaData instance
	CComPtr<IMTPropertyMetaData> metaData;
	HRESULT hr = metaData.CoCreateInstance(__uuidof(MTPropertyMetaData));
	if (!SUCCEEDED(hr))
	{	Error("CoCreateInstance failed for MTPropertyMetaData");
		return hr;
	}

	// set its name
	metaData->put_Name(aPropertyName);

	//add it to collection
	
	// make name uppercase, so case won't matter
	mtwstring wName(aPropertyName); 
	wName.toupper();
	m_coll[CComBSTR(wName)] = metaData;
	
	*apMetaData = metaData.Detach();

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTPropertyMetaDataSet::TranslateFilter(VARIANT aInFilter,
																										 IMTDataFilter** pFilter)
{
	ASSERT(pFilter);
	if(!pFilter) return E_POINTER;

		// step 1: create smart pointer
	try {
		_variant_t vtFilter(aInFilter);


		if (vtFilter!= vtMissing)
		{	
			MTPRODUCTCATALOGLib::IMTDataFilterPtr aDataFilter;
		
			// get the propertymetadataset
			MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr aSet(this);
			// translate the filter
			if(vtFilter.vt == (VT_BYREF|VT_VARIANT)) {
				variant_t refVariant = vtFilter.pvarVal;
				aDataFilter = refVariant; // QI
			}
			else {
				aDataFilter = vtFilter; // QI
			}

			// step 2: iterate through filter
			for(int i=0;i<aDataFilter->GetCount();i++) {
				MTPRODUCTCATALOGLib::IMTFilterItemPtr aItem = aDataFilter->GetItem(i);
				// step 3: translate names
				MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr aMetaData = 
					aSet->GetItem(aItem->GetPropertyName());

				// XXX error handling!
				aItem->PutPropertyName(aMetaData->GetDBColumnName());
			}
			*pFilter = reinterpret_cast<IMTDataFilter*>(aDataFilter.Detach());
		}
		else {
			*pFilter = NULL;
		}
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTPropertyMetaDataSet::GetPropertySQL(VARIANT aID, BSTR aBaseTableName,  VARIANT_BOOL aSummaryViewOnly, BSTR *pSelectList, BSTR *pJoinList)
{
	ASSERT(pSelectList && pJoinList);
	if(!(pSelectList && pJoinList)) return E_POINTER;

	// check the variant.  We only support an INT or BSTR
	_variant_t vtID(aID);
	if(!(vtID.vt == VT_I4 || vtID.vt == VT_BSTR)) {
		const char* pErrorMsg = "only long and BSTR support for ID argument";
		ASSERT(pErrorMsg);
		return Error(pErrorMsg);
	}
	
	try {
		_bstr_t selectlist,joinlist;
		set<string> mTableNameSet;

		MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr aSet(this);
		char buff[1024];
		
		for(long i=1;i<= aSet->GetCount();i++) {
			MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr metadata = aSet->GetItem(i);
			if(metadata->GetExtended() == VARIANT_TRUE &&
				 (aSummaryViewOnly == VARIANT_FALSE || metadata->GetSummaryView() == VARIANT_TRUE)) {

				// only process properties that are marked as extended
				// if aSummaryViewOnly: only process extended properties that are marked as SummaryView

				sprintf(buff,",%s.%s %s",
				        (const char*)metadata->GetDBTableName(),
				        (const char*)metadata->GetDBColumnName(),
				        (const char*)metadata->GetDBAliasName());

				selectlist += buff;

				string dbtablename = metadata->GetDBTableName();
				mTableNameSet.insert(dbtablename);
			}
		}
		
		_bstr_t baseTableName(aBaseTableName);
		// XXX using the set is not very effecient

		if (mTableNameSet.size() == 0)
		{
			//if no property was found, the join list needs to contain the base table name
			joinlist = baseTableName;
		}
		else
		{
			//construct the join list

			// NOTE: this used to use the ODBC escape sequence for outer joins.
			// however, with Oracle 9i this is no longer necessary and causes problems
			// when using more than one outer join or mixing outer and inner joins
			set<string>::iterator it = mTableNameSet.begin();
			while(it != mTableNameSet.end()) {
				switch(vtID.vt) {
					case VT_I4:
						sprintf(buff," %s LEFT OUTER JOIN %s on %s.id_prop = %d",
										(const char *) baseTableName,
										(*it).c_str(), (*it).c_str(),(long)vtID);
						break;
					case VT_BSTR: 
						{
						_bstr_t aTemp = vtID;
						sprintf(buff,"%s LEFT OUTER JOIN %s on %s.id_prop = %s",
										(const char *) baseTableName,
										(*it).c_str(),(*it).c_str(),(const char*)aTemp);
						break;
						}
					default:
						ASSERT(!"variant type not supported");
				}
				joinlist += buff;
				it++;
			}	
		}

		// step : set the return values
		*pSelectList = selectlist.copy();
		*pJoinList = joinlist.copy();
		return S_OK;
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaDataSet::PopulateProperties(IMTProperties *pProperties, IMTRowSet *pRowset)
{
	ASSERT(pProperties && pRowset);
	if(!(pProperties && pRowset)) return E_POINTER;

	try {
		MTPRODUCTCATALOGLib::IMTPropertiesPtr proplist(pProperties);
		MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr aSet(this);
		MTPRODUCTCATALOGLib::IMTRowSetPtr aRowset(pRowset);
		char buff[1024];

		long count = aSet->GetCount();
		for(long i = 1; i <= count; i++) {
			MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr aPropMeta = aSet->GetItem(i);
			if(aPropMeta->GetExtended() == VARIANT_TRUE) 
			{

				if (aPropMeta->GetDBTableName().length() + 1 +
						aPropMeta->GetDBColumnName().length() >= 30) {
					std::string truncatedName(aPropMeta->GetDBTableName(), 30 - 
																		aPropMeta->GetDBColumnName().length() - 1);
					sprintf(buff,"%s_%s", truncatedName.c_str(),
									(const char*)aPropMeta->GetDBColumnName());
				}
				else
				{
					sprintf(buff,"%s_%s",(const char*)aPropMeta->GetDBTableName(),
									(const char*)aPropMeta->GetDBColumnName());
				}

				MTPRODUCTCATALOGLib::IMTPropertyPtr aProp = proplist->GetItem(aPropMeta->GetName());
				aProp->PutValue(aRowset->GetValue(buff));
			}
		}
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------



STDMETHODIMP CMTPropertyMetaDataSet::UpsertExtendedProperties(IMTSessionContext* apCtxt,
																															IMTProperties* apProperties,VARIANT_BOOL aOverrideableOnly)
{
	ASSERT(apProperties);
	if(!apProperties) return E_POINTER;

	try {
		// create a map of table names to the update list
		map<string,MTMapItem> tableMap;

		//load map with extended properties
                int aFlags = PROPSET_EXTENDED | PROPSET_NON_OVERRIDEABLE | PROPSET_OVERRIDEABLE;

		if (aOverrideableOnly == VARIANT_TRUE) {
			aFlags =  PROPSET_EXTENDED | PROPSET_OVERRIDEABLE;
		}


		LoadTableMap( tableMap, apProperties, aFlags);

		
		MTPRODUCTCATALOGLib::IMTPropertiesPtr proplist(apProperties);

		long aID = proplist->GetItem("ID");
		map<string,MTMapItem>::iterator it = tableMap.begin();

		// create instance of Extended property executant
		MTPRODUCTCATALOGEXECLib::IMTExtendedPropWriterPtr aExWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTExtendedPropWriter));
		while(it != tableMap.end()) {
			
			// update each extended property table
			aExWriter->UpsertExtendedPropertyTable(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt),
				it->first.c_str(),it->second.first.c_str(),
				it->second.second.c_str(),it->second.third.c_str(),aID);
			it++;
		}	
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}



// ----------------------------------------------------------------
// Name:     	
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   updtaes all properties properties in table aTableName
//                to all instance
// ----------------------------------------------------------------
STDMETHODIMP CMTPropertyMetaDataSet::UpdateProperties(IMTSessionContext* apCtxt,
													  IMTProperties *pProperties,
													  VARIANT_BOOL aOverrideableOnly,
													  BSTR aTableName,
													  BSTR aExtraUpdates
													  )
{
	ASSERT(pProperties);
	if(!pProperties) return E_POINTER;

	try {
		// create a map of table names to the update list
		map<string,MTMapItem> tableMap;

		//load map with extended properties
		int aFlags = PROPSET_CORE|PROPSET_EXTENDED|PROPSET_OVERRIDEABLE;

		if (aOverrideableOnly == VARIANT_FALSE)
			aFlags |= PROPSET_NON_OVERRIDEABLE;

		LoadTableMap( tableMap, pProperties, aFlags, &aTableName);

		
		MTPRODUCTCATALOGLib::IMTPropertiesPtr proplist(pProperties);

		long aID = proplist->GetItem("ID");
		map<string,MTMapItem>::iterator it = tableMap.begin();

		// create instance of Extended property executant
		MTPRODUCTCATALOGEXECLib::IMTExtendedPropWriterPtr aExWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTExtendedPropWriter));

		//handles updates of properties that are of type object
		if(_bstr_t(aTableName).length() && _bstr_t(aExtraUpdates).length())
			aExWriter->UpsertExtendedPropertyTable(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt),
																						aTableName, aExtraUpdates, "", "", aID);

		while(it != tableMap.end()) {
			// update each extended property table
			aExWriter->UpsertExtendedPropertyTable(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt),
																						 it->first.c_str(), it->second.first.c_str(),
																						 it->second.second.c_str(),it->second.third.c_str(),aID);
			it++;
		}	
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   propagate changes of non-overridable properties in table aTableName
//                to all instance
// ----------------------------------------------------------------
STDMETHODIMP CMTPropertyMetaDataSet::PropagateProperties(IMTSessionContext* apCtxt,
																												 IMTProperties *apProperties, BSTR aTableName, BSTR aExtraUpdateString)
{
	if(!apProperties)
		return E_POINTER;
	
	try
	{
		map<string,MTMapItem> tableMap;
		
		//load all, non-overridable properties, of table
		LoadTableMap( tableMap, apProperties, PROPSET_CORE|PROPSET_EXTENDED|PROPSET_NON_OVERRIDEABLE, &aTableName);

		//call sproc to propagateProperties for table
		MTPRODUCTCATALOGLib::IMTPropertiesPtr properties(apProperties);

		long id = properties->GetItem("ID");
		map<string,MTMapItem>::iterator it = tableMap.begin();

		// create instance of Extended property executant
		MTPRODUCTCATALOGEXECLib::IMTExtendedPropWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTExtendedPropWriter));
		
		//TODO: ASSERT: there should only be one table!!
		if( it != tableMap.end() )
		{
			// glue together generated and supplied update strings, inserting comma if necessary
			_bstr_t strTableUpdate = it->second.first.c_str();
			_bstr_t strExtraUpdate = aExtraUpdateString;
			_bstr_t strUpdate = strTableUpdate + (strTableUpdate.length() && strExtraUpdate.length() ? ", " : "") + strExtraUpdate; 

			// update each extended property table
			writer->PropagateProperties(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt),
																	it->first.c_str(),
																	strUpdate,
																	it->second.second.c_str(),
																	it->second.third.c_str(),
																	id);
		}
	}
	catch(_com_error& err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   propagate changes of non-overridable extended properties to all instance 
// ----------------------------------------------------------------
STDMETHODIMP CMTPropertyMetaDataSet::PropagateExtendedProperties(IMTSessionContext* apCtxt,
																																 IMTProperties *apProperties)
{
	if(!apProperties)
		return E_POINTER;
	
	try
	{
		map<string,MTMapItem> tableMap;
		
		//load extended, non-overridable properties
		LoadTableMap( tableMap, apProperties, PROPSET_EXTENDED|PROPSET_NON_OVERRIDEABLE);

		//call sproc to propagateProperties for each table
		MTPRODUCTCATALOGLib::IMTPropertiesPtr properties(apProperties);

		long id = properties->GetItem("ID");
		map<string,MTMapItem>::iterator it = tableMap.begin();

		// create instance of Extended property executant
		MTPRODUCTCATALOGEXECLib::IMTExtendedPropWriterPtr aExWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTExtendedPropWriter));
		while(it != tableMap.end())
		{
			// update each extended property table
			aExWriter->PropagateProperties(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt),
																			it->first.c_str(),
																			it->second.first.c_str(),
																			it->second.second.c_str(),
																			it->second.third.c_str(),
																			id);
			it++;
		}	
	}
	catch(_com_error& err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

//load up map (core, extended, include overrideable, include non overrideable, table) 

//helper to convert a DATE to the correct database format
// TODO: move this!
_variant_t DateToDBParam(DATE aDate, bool isOracle)
{
	_bstr_t dbParam;

	if (aDate == 0.0)
		dbParam = "NULL";
	else
	{	struct tm tmDest;
		wchar_t buffer[256];
		StructTmFromOleDate(&tmDest, aDate);
		
		if(!isOracle)
		{
			// NOTE: use the ODBC escape sequence to work with SQL Server
			// {ts 'yyyy-mm-dd hh:mm:ss'}
			wcsftime(buffer, 255, L"{ts \'%Y-%m-%d %H:%M:%S\'}", &tmDest);
		}
		else
		{
			// NOTE: use Oracle specific syntax
			wcsftime(buffer, 255, L"to_timestamp(\'%Y-%m-%d %H:%M:%S\', \'YYYY/MM/DD HH24:MI:SS\')", &tmDest);
		}

		dbParam = buffer;
	}

	return dbParam;
}

// ----------------------------------------------------------------
// Name:     	
// Arguments:     
//                
// Return Value:  
// Errors Raised: _com_error
// Description:   propagate changes of non-overridable extended properties to all instance 
// ----------------------------------------------------------------
void CMTPropertyMetaDataSet::LoadTableMap( map<string,MTMapItem>& arTableMap,
																					IMTProperties *apProperties, 
																					int aFlags,
																					BSTR* apTableName /*= NULL*/)
{
	char buf[1024];
	
	MTPRODUCTCATALOGLib::IMTPropertiesPtr proplist(apProperties);

	MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr aSet(this);
		
	long count = proplist->GetCount();

	COdbcConnectionInfo info = COdbcConnectionManager::GetConnectionInfo("NetMeter");
	// Is this Oracle?
	bool	mIsOracle = (info.GetDatabaseType() == COdbcConnectionInfo::DBTYPE_ORACLE);


	// collections are 1 based
	for(long i=1;i<=count;i++)
	{
		MTPRODUCTCATALOGLib::IMTPropertyPtr aprop = proplist->GetItem(i);
		MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr metadata = aprop->GetMetaData();

		//figure out whether ore not to include thos property based on the flags passed in
		bool includeThisProperty = false;
		bool extended = (metadata->GetExtended() == VARIANT_TRUE);
		bool overrideable = (metadata->GetOverrideable() == VARIANT_TRUE);
		
		if( (((aFlags & PROPSET_CORE) && !extended) ||
				 ((aFlags & PROPSET_EXTENDED) && extended)) &&
				(((aFlags & PROPSET_OVERRIDEABLE) && overrideable) ||
				 ((aFlags & PROPSET_NON_OVERRIDEABLE) && !overrideable))
			)
		{
			includeThisProperty = true;
		}

		//if table name is passed in, only return properties in that table
		if( includeThisProperty &&
				apTableName &&
				(_bstr_t(*apTableName) != metadata->GetDBTableName()))
		{
			includeThisProperty = false;
		}

		if(includeThisProperty)
		{
			string tableName = metadata->GetDBTableName();

			if(arTableMap.size() > 0)
			{
				arTableMap[tableName].first += ",";
				arTableMap[tableName].second += ",";
				arTableMap[tableName].third += ",";
			}

			sprintf(buf,"%s.%s = ",
				(const char*)metadata->GetDBTableName(),(const char*)metadata->GetDBColumnName());
			arTableMap[tableName].first += buf;
			arTableMap[tableName].third += (const char*)metadata->GetDBColumnName();

			MTPRODUCTCATALOGLib::PropValType proptype;
			aprop->get_DataType(&proptype);

			switch(proptype)
      {
				case MTPRODUCTCATALOGLib::PROP_TYPE_DATETIME:
				{
          _variant_t val = aprop->GetValue();
          if (V_VT(&val) == VT_NULL)
              val = 0.0;

          strcpy(buf,_bstr_t(DateToDBParam(val, mIsOracle)));
					break;
				}
				case MTPRODUCTCATALOGLib::PROP_TYPE_STRING: 
				{
					_variant_t val(aprop->GetValue());
					if (V_VT(&val) == VT_NULL)
					  strcpy(buf,"NULL");
					else
          {
						std::wstring widebuf;
						_bstr_t bstrTemp = (_bstr_t)val;
#if 0
						FormatValueForDB(bstrTemp, false, widebuf);
#else
						FormatValueForDB(bstrTemp, true, widebuf);
#endif
						string tempstr = ascii(widebuf);
						sprintf(buf,"%s",tempstr.c_str());
					}
					break;
				}
				case MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN:
					{
						_variant_t aResult = aprop->GetValue();
						if(aResult.vt == VT_BSTR)
            {
							sprintf(buf,"'%s'",(const char*)_bstr_t(aResult));
						}
						else
            {
							// if the variant is not something that convert to a bool,
							// the variant_t will throw an error
							sprintf(buf,"'%s'",(bool)aResult == true ? "Y" : "N");
						}
						break;
					}
				case MTPRODUCTCATALOGLib::PROP_TYPE_ENUM:
				{
						//Convert Enums back to description ids
						//for database inserts
						try
            {
               _variant_t val = aprop->GetValue();
               if ((V_VT(&val) == VT_NULL) || ((V_VT(&val) == VT_EMPTY)))
               {
                 strcpy(buf, "NULL");
               }
               else
               {
							    MTENUMCONFIGLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);
							    long lVal = enumConfig->GetID(aprop->GetEnumSpace(),
									    													aprop->GetEnumType(),
											    											(_bstr_t) aprop->GetValue());
    						  strcpy(buf, _bstr_t(lVal));
               }
						}
						catch(_com_error& e)
            {
							MT_THROW_COM_ERROR(e.Error());
						}
            break;
				}

				case MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER:
				case MTPRODUCTCATALOGLib::PROP_TYPE_BIGINTEGER:
				case MTPRODUCTCATALOGLib::PROP_TYPE_DOUBLE: 
				case MTPRODUCTCATALOGLib::PROP_TYPE_DECIMAL:
        {
 					_variant_t val(aprop->GetValue());
					if (V_VT(&val) == VT_NULL)
              strcpy(buf,"NULL");
          else
    					strcpy(buf,_bstr_t(val));

          break;
        }

				case MTPRODUCTCATALOGLib::PROP_TYPE_TIME: 
				
				//	ASSERT(!"Not implemented."); break;
				default:
					ASSERT(!"Unknown or unhandled type");
			}

			arTableMap[tableName].first += buf; 
			arTableMap[tableName].second += buf;
		}
	}
}


STDMETHODIMP CMTPropertyMetaDataSet::RemoveExtendedProperties(IMTSessionContext* apCtxt, IMTProperties *apProperties)
{
	if(!apProperties)
		return E_POINTER;
	
	try
	{
		//load map with ALL extended properties
		int aFlags = PROPSET_EXTENDED|PROPSET_NON_OVERRIDEABLE|PROPSET_OVERRIDEABLE;

		//create tablemap 
		map<string,MTMapItem> tableMap;
		LoadTableMap( tableMap, apProperties, aFlags);

		//call sproc to propagateProperties for each table
		MTPRODUCTCATALOGLib::IMTPropertiesPtr properties(apProperties);
		long id = properties->GetItem("ID");

		// create instance of Extended property executant
		MTPRODUCTCATALOGEXECLib::IMTExtendedPropWriterPtr ExWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTExtendedPropWriter));

		// iterate over all tables
		map<string,MTMapItem>::iterator it = tableMap.begin();
		while(it != tableMap.end())
		{
			ExWriter->RemoveFromExtendedPropertyTable(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), it->first.c_str(), id);
			it++;
		}	
	}
	catch(_com_error& err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   translates alias name (in rowset) to display name
// ----------------------------------------------------------------
STDMETHODIMP CMTPropertyMetaDataSet::DBAliasNameToDisplayName(BSTR aDBAliasName, BSTR *apDisplayName)
{
	if (!apDisplayName)
		return E_POINTER;

	*apDisplayName = NULL;

	try
	{
		_bstr_t aliasName = aDBAliasName;
		
		//loop over all meta data, looking for aDBAliasName
		MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr metaDataSet = this;
		long count = metaDataSet->GetCount();

		bool found = false;
		for (long i=1; i<=count; i++) // collections are 1 based
		{
			MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr metadata = metaDataSet->GetItem(i);
			if (metadata->DBAliasName == aliasName)
			{	*apDisplayName = metadata->DisplayName.copy();
				found = true;
				break;
			}
		}
		
		if (!found)
			MT_THROW_COM_ERROR( IID_IMTPropertyMetaDataSet, "Alias name '%s' not found", static_cast<const char*>(aliasName));
	}
	catch(_com_error& err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}



STDMETHODIMP CMTPropertyMetaDataSet::get_Name(/*[out, retval]*/ BSTR *pVal)
{
	*pVal = mName.copy();
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaDataSet::put_Name(/*[in]*/ BSTR val)
{
	mName = val;
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaDataSet::get_TableName(/*[out, retval]*/ BSTR *pVal)
{
	*pVal = mTableName.copy();
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaDataSet::put_TableName(/*[in]*/ BSTR val)
{
	mTableName = val;
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaDataSet::get_Description(/*[out, retval]*/ BSTR *pVal)
{
	*pVal = mDescription.copy();
	return S_OK;
}

STDMETHODIMP CMTPropertyMetaDataSet::put_Description(/*[in]*/ BSTR val)
{
	mDescription = val;
	return S_OK;
}
