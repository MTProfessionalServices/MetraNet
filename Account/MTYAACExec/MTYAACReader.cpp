/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#include "StdAfx.h"
#include "MTYAACExec.h"
#include "MTYAACReader.h"
#include <mtprogids.h>
#include <optionalvariant.h>
#include <MTDate.h>
#include <stdutils.h>
#include <DBMiscUtils.h>
#include <boost/regex.hpp>
#include <sstream>

#import <MTYAAC.tlb>  rename ("EOF", "RowsetEOF") no_function_mapping



/////////////////////////////////////////////////////////////////////////////
// CMTYAACReader
STDMETHODIMP CMTYAACReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTYAACReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTYAACReader::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTYAACReader::CanBePooled()
{
	return TRUE;
} 

void CMTYAACReader::Deactivate()
{
	m_spObjectContext.Release();
} 

STDMETHODIMP CMTYAACReader::GetYAACByName(IMTSessionContext* apCtx, BSTR aName, BSTR aNamespace, VARIANT RefDate, IMTYAAC** ppYaac)
{
  MTAutoContext ctx(m_spObjectContext);
  _bstr_t bstrYes = "1";
  try 
  {
    ROWSETLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
    rs->Init(ACC_HIERARCHIES_QUERIES);
    BOOL isOracle = (mtwcscasecmp(rs->GetDBType(), ORACLE_DATABASE_TYPE) == 0);

    // Escape quotes in name and namespace
    _bstr_t nameBstr(ValidateString(aName).c_str()), spaceBstr(ValidateString(aNamespace).c_str());

    _bstr_t nameSpaceBstr = isOracle ?
      "%%%UPPER%%%(mapper.nm_login) = %%%UPPER%%%(N'" + nameBstr + "') "
      "AND %%%UPPER%%%(mapper.nm_space) = %%%UPPER%%%(N'" + spaceBstr + "')"
      :
      "%%%UPPER%%%(mapper.nm_login) = %%%UPPER%%%(@nm_login) "
      "AND %%%UPPER%%%(mapper.nm_space) = %%%UPPER%%%(@nm_space)";

    MTYAACLib::IMTYAACPtr acc("MetraTech.MTYAAC");
    rs->SetQueryTag("__LOAD_YAAC_PROPERTIES__");
    rs->AddParam("%%NAMESPACE_CRITERIA%%", nameSpaceBstr, VARIANT_TRUE);

    _variant_t vtDateVal;
    if(!OptionalVariantConversion(RefDate,VT_DATE,vtDateVal)) {
      vtDateVal = GetMTOLETime();
    }

    wstring val;
    FormatValueForDB(vtDateVal,false,val);
    rs->AddParam("%%REFDATE%%", isOracle ? val.c_str() : L"@refdate",VARIANT_TRUE);

    if (!isOracle)
    {
      boost::regex e1;
      e1.assign("'");
      std::string utf8Query((const char *) rs->GetQueryString());
      utf8Query = boost::regex_replace(utf8Query, e1, "''", boost::match_default | boost::format_all);
      _bstr_t queryTags = 
        L"execute sp_executesql N'" + 
        _bstr_t(utf8Query.c_str()) + 
        "', N'@nm_login NVARCHAR(max), @nm_space NVARCHAR(max), @refdate DATETIME', N'" + 
        nameBstr + 
        "', N'" + 
        spaceBstr + 
        "', " + 
        val.c_str();
      rs->SetQueryString(queryTags);
    }

    rs->Execute();
    if(rs->GetRecordCount() == 0) 
    {
      // note: MTDATE does not support date time; only the date.
      MTDate conversionDate((DATE)vtDateVal);
      string tempBuf;
      conversionDate.ToString("%m/%d/%Y",tempBuf);
      MT_THROW_COM_ERROR(MT_YAAC_ACCOUNT_NOT_FOUND_STR,(char*)nameBstr,tempBuf.c_str());
    }
    else 
    {
      acc->Billable = (_bstr_t(rs->GetValue("billable")) == bstrYes) ? VARIANT_TRUE : VARIANT_FALSE;
      acc->Folder = (_bstr_t(rs->GetValue("IsFolder")) == bstrYes) ? VARIANT_TRUE : VARIANT_FALSE;
      acc->LoginName = (_bstr_t)rs->GetValue("nm_login");
      acc->HierarchyPath = (_bstr_t)rs->GetValue("tx_path");
      acc->CorporateAccountID = rs->GetValue("corporate_acc");
      acc->AccountType = (_bstr_t)rs->GetValue("acc_type");
      acc->AccountTypeID = rs->GetValue("AccountTypeID");
      acc->AccStatus = (_bstr_t)rs->GetValue("status");
      // necessary if resolving by user name and namespace
      acc->AccountID = rs->GetValue("id_acc");
      acc->Namespace = (_bstr_t)rs->GetValue("namespace");
      acc->AccountName = (_bstr_t)rs->GetValue("accountname");
      // lookup the account external identifier and convert the value to a string
      MTMiscUtil::GuidToString(rs->GetValue("id_acc_ext"),acc->AccountExternalIdentifier);

      _variant_t vtCurrentOwner = rs->GetValue("owner");
      if(vtCurrentOwner.vt != VT_NULL) {
        acc->CurrentFolderOwner = vtCurrentOwner;
      }
      acc->Loaded = VARIANT_TRUE;
      acc->SessionContext = reinterpret_cast<MTYAACLib::IMTSessionContext*>(apCtx);
      (*ppYaac) = reinterpret_cast<IMTYAAC*>(acc.Detach());
    }
  }
  catch(_com_error& err) 
  {
    return ReturnComError(err);
  }
  ctx.Complete();
  return S_OK;

}

STDMETHODIMP CMTYAACReader::GetYAAC(IMTSessionContext* apCtx, long aAccountID, VARIANT RefDate, IMTYAAC** ppYaac)
{
  MTAutoContext ctx(m_spObjectContext);
  _bstr_t bstrYes = "1";
  try 
  {
    ROWSETLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
    rs->Init(ACC_HIERARCHIES_QUERIES);
    BOOL isOracle = (mtwcscasecmp(rs->GetDBType(), ORACLE_DATABASE_TYPE) == 0);

    char buff[100];
    sprintf(buff,"mapper.id_acc = %d",aAccountID);

    MTYAACLib::IMTYAACPtr acc("MetraTech.MTYAAC");
    rs->SetQueryTag("__LOAD_YAAC_PROPERTIES__");
    rs->AddParam("%%NAMESPACE_CRITERIA%%",_bstr_t(isOracle ? buff : "mapper.id_acc=@id_acc"),VARIANT_TRUE);

    _variant_t vtDateVal;
    if(!OptionalVariantConversion(RefDate,VT_DATE,vtDateVal)) {
      vtDateVal = GetMTOLETime();
    }

    wstring val;
    FormatValueForDB(vtDateVal,false,val);
    rs->AddParam("%%REFDATE%%",isOracle ? val.c_str() : L"@refdate",VARIANT_TRUE);
    if (!isOracle)
    {
      boost::regex e1;
      e1.assign("'");
      std::string utf8Query((const char *) rs->GetQueryString());
      utf8Query = boost::regex_replace(utf8Query, e1, "''", boost::match_default | boost::format_all);
      sprintf(buff, "%d%", aAccountID);
      _bstr_t queryTags = 
        L"execute sp_executesql N'" + 
        _bstr_t(utf8Query.c_str()) + 
        "', N'@id_acc int, @refdate DATETIME', " + 
        buff + 
        ", " + 
        val.c_str();
      rs->SetQueryString(queryTags);
    }
    rs->Execute();
    if(rs->GetRecordCount() == 0) 
    {
      // note: MTDATE does not support date time; only the date.
      MTDate conversionDate((DATE)vtDateVal);
      string tempBuf;
      conversionDate.ToString("%m/%d/%Y",tempBuf);
      MT_THROW_COM_ERROR(MT_YAAC_ACCOUNT_NOT_FOUND,aAccountID,tempBuf.c_str());
    }
    else 
    {
      acc->Billable = (_bstr_t(rs->GetValue("billable")) == bstrYes) ? VARIANT_TRUE : VARIANT_FALSE;
      acc->Folder = (_bstr_t(rs->GetValue("IsFolder")) == bstrYes) ? VARIANT_TRUE : VARIANT_FALSE;
      acc->LoginName = (_bstr_t)rs->GetValue("nm_login");
      acc->HierarchyPath = (_bstr_t)rs->GetValue("tx_path");
      acc->CorporateAccountID = rs->GetValue("corporate_acc");
      acc->AccountType = (_bstr_t)rs->GetValue("acc_type");
      acc->AccountTypeID = rs->GetValue("AccountTypeID");
      acc->AccStatus = (_bstr_t)rs->GetValue("status");
      // necessary if resolving by user name and namespace
      acc->AccountID = rs->GetValue("id_acc");
      acc->Namespace = (_bstr_t)rs->GetValue("namespace");
      acc->AccountName = (_bstr_t)rs->GetValue("accountname");
      // lookup the account external identifier and convert the value to a string
      MTMiscUtil::GuidToString(rs->GetValue("id_acc_ext"),acc->AccountExternalIdentifier);

      _variant_t vtCurrentOwner = rs->GetValue("owner");
      if(vtCurrentOwner.vt != VT_NULL) {
        acc->CurrentFolderOwner = vtCurrentOwner;
      }
      acc->Loaded = VARIANT_TRUE;
      acc->SessionContext = reinterpret_cast<MTYAACLib::IMTSessionContext*>(apCtx);
      (*ppYaac) = reinterpret_cast<IMTYAAC*>(acc.Detach());
    }
  }
  catch(_com_error& err) {
    return ReturnComError(err);
  }
  ctx.Complete();
  return S_OK;

}

STDMETHODIMP CMTYAACReader::GetAvailableGroupSubscriptionsAsRowset
                                                                ( IMTSessionContext* apCtxt,
                                                                  IMTYAAC* apYAAC,
                                                                  DATE RefDate,
                                                                  VARIANT aFilter,
                                                                  IMTSQLRowset **ppRowset)
{
  MTAutoContext context(m_spObjectContext);

  try 
  {
    MTYAACLib::IMTYAACPtr yaac = apYAAC;
    MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr SubReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));
    int AccountID = yaac->AccountID;
    int CorpAccountID = yaac->CorporateAccountID;
    bool restricted  = PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == VARIANT_TRUE;
    if(restricted == true)
    {
      ROWSETLib::IMTSQLRowsetPtr tmp = SubReader->GetAvailableGroupSubscriptionByCorporateAccount
                                              (
                                              reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt),
                                              reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTYAAC*>(yaac.GetInterfacePtr()));
      (*ppRowset) =  reinterpret_cast<IMTSQLRowset*>(tmp.Detach());
      return S_OK;
    }
		
		MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc(__uuidof(MTProductCatalog));
		MTPRODUCTCATALOGLib::IMTDataFilterPtr aDataFilter = 
      pc->GetMetaData(MTPRODUCTCATALOGLib::PCENTITY_TYPE_GROUPSUBSCRIPTION)->TranslateFilter(aFilter);
    _bstr_t filter;
    if (aDataFilter != NULL)
    {
      filter = aDataFilter->FilterString;
      if (filter.length() > 0) 
      {
        filter = _bstr_t(L" AND ") + filter;
      }
    }

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(ACC_HIERARCHIES_QUERIES);
    rowset->SetQueryTag("__FIND_AVAILABLE_GROUP_SUBS_BY_DATE_RANGE__");

    wstring aValue;
    FormatValueForDB(_variant_t(RefDate,VT_DATE),FALSE,aValue);
    rowset->AddParam("%%TIMESTAMP%%",aValue.c_str(),VARIANT_TRUE);
    rowset->AddParam("%%FILTERS%%",filter,VARIANT_TRUE);
    rowset->AddParam("%%ID_ACCOUNT_TYPE%%",yaac->AccountTypeID);
    rowset->Execute();
    *ppRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
  }
  catch (_com_error& err) {
    return ReturnComError(err);
  }

  return S_OK;
}
