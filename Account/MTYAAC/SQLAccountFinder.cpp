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
#include <mtprogids.h>
#include <stdutils.h>
#include "MTYAAC.h"
#include "SQLAccountFinder.h"
#include "RowsetDefs.h"
#include <DataAccessDefs.h>
#include <boost/format.hpp>

//formatting helpers
#define NEWLINE           L"\n"
#define NEWLINE_1_INDENT  L"\n  "
#define NEWLINE_2_INDENT  L"\n    "
#define NEWLINE_3_INDENT  L"\n      "

CSQLAccountFinder::CSQLAccountFinder(CAccountMetaData* apMetaData,
                                     MTENUMCONFIGLib::IEnumConfigPtr aEnumConfig, 
                                     MTYAACLib::IMTSessionContextPtr& aCtx) /*:
  mpMetaData(apMetaData),
  mEnumConfig(aEnumConfig) */
{
  mEnumConfig = aEnumConfig;
  mpMetaData = apMetaData;
  ASSERT(mpMetaData);
  mSessionContext = aCtx;
}

void CSQLAccountFinder::Search( IMTCollection* apCorporateAccountIDs, //HIERARCHY_ROOT means allow all
               bool aIncludeNonHierarchalAccounts,
               DATE aRefDate,
               IMTCollection *apColumnProps,
               IMTDataFilter *apFilter,
               IMTDataFilter *apJoinFilter,
               IMTCollection *apOrderProps,
               long aMaxRows,
               bool& aMoreRows,
               IMTSQLRowset **apRowset)
{

  ROWSETLib::IMTSQLRowsetPtr rowset = InternalSearch(
               apCorporateAccountIDs, //HIERARCHY_ROOT means allow all
               aIncludeNonHierarchalAccounts,
               aRefDate,
               apColumnProps,
               apFilter,
               apJoinFilter,
               apOrderProps,
               aMaxRows,
               aMoreRows
               );
  *apRowset = reinterpret_cast<IMTSQLRowset*> (rowset.Detach());
}

void CSQLAccountFinder::Search( IMTCollection* apCorporateAccountIDs, //HIERARCHY_ROOT means allow all
               bool aIncludeNonHierarchalAccounts,
               DATE aRefDate,
               IMTCollection *apColumnProps,
               IMTDataFilter *apFilter,
               IMTDataFilter *apJoinFilter,
               IMTCollection *apOrderProps,
               long aMaxRows,
               bool& aMoreRows,
               VARIANT transaction,
               IMTSQLRowset **apRowset)
{

  ROWSETLib::IMTSQLRowsetPtr rowset = InternalSearch(
               apCorporateAccountIDs, //HIERARCHY_ROOT means allow all
               aIncludeNonHierarchalAccounts,
               aRefDate,
               apColumnProps,
               apFilter,
               apJoinFilter,
               apOrderProps,
               aMaxRows,
               aMoreRows,
               transaction
               );
  *apRowset = reinterpret_cast<IMTSQLRowset*> (rowset.Detach());
}

ROWSETLib::IMTSQLRowsetPtr CSQLAccountFinder::InternalSearch
                ( IMTCollection* apCorporateAccountIDs, //HIERARCHY_ROOT means allow all
                bool aIncludeNonHierarchalAccounts,
                DATE aRefDate,
                IMTCollection *apColumnProps,
                IMTDataFilter *apFilter,
                IMTDataFilter *apJoinFilter,
                IMTCollection *apOrderProps,
                long aMaxRows,
                bool& aMoreRows,
                VARIANT transaction)
{
  MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
	GUID guid = __uuidof(MTYAACEXECLib::MTGenDBReader);
   _variant_t trans;
  
  if(V_VT(&transaction) != VT_NULL && OptionalVariantConversion(transaction,VT_UNKNOWN,trans))
  {
    PIPELINETRANSACTIONLib::IMTTransactionPtr pTrans(__uuidof(PIPELINETRANSACTIONLib::CMTTransaction));
    pTrans->SetTransaction(trans,VARIANT_FALSE);
    IDispatchPtr pDisp = pTrans->CreateObjectWithTransactionByCLSID(&guid);
    reader = pDisp; // QI
  }
  else
  {
    reader.CreateInstance(guid);
  }


  ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
  ROWSETLib::IMTSQLRowsetPtr outrs = NULL;
  rowset->Init(DATABASE_CONFIGDIR);

  _bstr_t dbType = rowset->GetDBType();
  bool isOracle = (mtwcscasecmp(dbType, ORACLE_DATABASE_TYPE) == 0);

  if (!isOracle && trans.vt == VT_EMPTY)
  {
    // SQL Server fast path with sp_executesql and parameterization.
    ROWSETLib::IMTDataFilterPtr pFilter(apFilter);
    //copy filter since we are modifying it
    ROWSETLib::IMTDataFilterPtr pSQLFilter = CopyFilter(pFilter);
    // adjust filter for use in SQL (this does type conversion of values so that they
    // work properly with the databse; e.g. enum string to int conversion).
    AdjustFilter(pSQLFilter, isOracle);

    int cnt = pFilter->GetCount();
    _variant_t nullValue;
    nullValue.vt = VT_NULL;
    _bstr_t paramsString=L"@RefDate DATETIME";

    // We need a disconnected rowset because we modify it.
    // However, ExecuteStoredProcedure doesn't disconnect rowsets
    // so we use a synthesized query tag to create a SQL batch and an MTSQLRowset::ExecuteDisconnected
    _bstr_t queryTags = L"execute sp_executesql N'%%STMT%% \noption(maxdop 1)', N'%%PARAMS%%', %%REFDATE%%";
    for(int i = 0; i< cnt; i++)
    {
      ROWSETLib::IMTFilterItemPtr pFilterItem = pFilter->GetItem(i);
      ROWSETLib::IMTFilterItemPtr pSQLFilterItem = pSQLFilter->GetItem(i);
      // Skip accounttypename since this is examined to determine what table
      // joins are needed.
      // TODO: Fix this so that the join determination doesn't look at filters.
      if (pFilterItem->Operator == ROWSETLib::OPERATOR_TYPE_IN) continue;
      paramsString += (boost::wformat(L", @p_%1%%2%") % pFilterItem->PropertyName % i).str().c_str();
      switch(pSQLFilterItem->Value.vt)
      {
      case VT_I2:
      case VT_I4:
      case VT_UI2:
      case VT_UI4:
      case VT_INT:
      case VT_UINT:
        paramsString += L" INT";
        break;
      case VT_I8:
        paramsString += L" BIGINT";
        break;
      case VT_DATE:
        paramsString += L" DATETIME";
        break;
      case VT_DECIMAL:
      case VT_R8:
        paramsString += L" ";
        paramsString += METRANET_DECIMAL_PRECISION_AND_SCALE_MAX_WSTR;
        break;
      case VT_BSTR:
        paramsString += L" NVARCHAR(max)";
        break;
      case VT_BOOL:
        paramsString += L" CHAR(1)";
        break;
      default:
        MT_THROW_COM_ERROR("Type not yet implemented");
      }

      // This is a bit confusing.  We really want to use the SQLFilterItem
      // in the switch statement but the FilterItem in the query tag.  The 
      // SQLFilterItem has the correct datatype for the value, but has the
      // qualified column name for its PropertyName (which we don't want).
      switch(pSQLFilterItem->Value.vt)
      {
      case VT_I2:
      case VT_I4:
      case VT_I8:
      case VT_UI2:
      case VT_UI4:
      case VT_INT:
      case VT_UINT:
      case VT_DATE:
      case VT_DECIMAL:
      case VT_R8:
        queryTags += (boost::wformat(L", %%%%%1%%2%%%%%") % pFilterItem->PropertyName % i).str().c_str();
        break;
      case VT_BOOL:
        queryTags += (boost::wformat(L", '%%%%%1%%2%%%%%'") % pFilterItem->PropertyName % i).str().c_str();
        break;
      case VT_BSTR:
        queryTags += (boost::wformat(L", N'%%%%%1%%2%%%%%'") % pFilterItem->PropertyName % i).str().c_str();
        break;
      default:
        MT_THROW_COM_ERROR("Type not yet implemented");
      }
    }

    wstring query;
    query = GenerateQuery(apCorporateAccountIDs,
                          aIncludeNonHierarchalAccounts,
                          0.0,
                          apColumnProps,
                          apFilter,
                          apJoinFilter,
                          apOrderProps,
                          aMaxRows,
                          isOracle,
                          true);

    rowset->SetQueryString(queryTags);
    rowset->AddParam(L"%%STMT%%", query.c_str(), VARIANT_FALSE);
    rowset->AddParam(L"%%PARAMS%%", paramsString, VARIANT_FALSE);
    rowset->AddParam(L"%%REFDATE%%", _variant_t(aRefDate, VT_DATE), VARIANT_FALSE);
    for(int i = 0; i< cnt; i++)
    {
      ROWSETLib::IMTFilterItemPtr pFilterItem = pFilter->GetItem(i);
      ROWSETLib::IMTFilterItemPtr pSQLFilterItem = pSQLFilter->GetItem(i);
      // Temporary and grotesque hack because I need to deal properly with IN clauses
      if (pFilterItem->Operator == ROWSETLib::OPERATOR_TYPE_IN) continue;
      _bstr_t param=(boost::wformat(L"%%%%%1%%2%%%%%") % pFilterItem->PropertyName % i).str().c_str();
      if (pSQLFilterItem->Value.vt == VT_BOOL)
      {
        rowset->AddParam(param, bool(pSQLFilterItem->Value) ? 1 : 0);
      }
      else
      {
        rowset->AddParam(param, pSQLFilterItem->Value, VARIANT_FALSE);
      }
    }
    rowset->ExecuteDisconnected();
    // Call using sp_executesql
// 		rowset->InitializeForStoredProc("sp_executesql");
// 		rowset->AddInputParameterToStoredProc (	"stmt", MTTYPE_W_VARCHAR, INPUT_PARAM, query.c_str());
// 		rowset->AddInputParameterToStoredProc (	"params", MTTYPE_W_VARCHAR, INPUT_PARAM, paramsString);
//     rowset->AddInputParameterToStoredProc ( "RefDate", MTTYPE_DATE, INPUT_PARAM, aRefDate);
//     for(int i = 0; i< cnt; i++)
//     {
//       ROWSETLib::IMTFilterItemPtr pFilterItem = pFilter->GetItem(i);
//       // Temporary and grotesque hack because I need to deal properly with IN clauses
//       if (pFilterItem->Operator == ROWSETLib::OPERATOR_TYPE_IN) continue;
//       long inputType=MTTYPE_W_VARCHAR;
//       switch(pFilterItem->Value.vt)
//       {
//       case VT_I2:
//       case VT_I4:
//       case VT_I8:
//       case VT_UI2:
//       case VT_UI4:
//       case VT_INT:
//       case VT_UINT:
//         inputType = MTTYPE_INTEGER;
//         break;
//       case VT_DATE:
//         inputType = MTTYPE_DATE;
//         break;
//       case VT_DECIMAL:
//       case VT_R8:
//         inputType = MTTYPE_DECIMAL;
//         break;
//       case VT_BSTR:
//         inputType = MTTYPE_W_VARCHAR;
//         break;
//      default:
//         MT_THROW_COM_ERROR("Type not yet implemented");
//       }
//       rowset->AddInputParameterToStoredProc (pFilterItem->PropertyName, inputType, INPUT_PARAM, pFilterItem->Value);
//     }
    
//     rowset->ExecuteStoredProc();
    outrs = rowset;
  }
  else
  {
    // construct Query
    wstring query;
    query = GenerateQuery(apCorporateAccountIDs,
                          aIncludeNonHierarchalAccounts,
                          aRefDate,
                          apColumnProps,
                          apFilter,
                          apJoinFilter,
                          apOrderProps,
                          aMaxRows,
                          isOracle,
                          false);
  
    // execute Query
    outrs = reader->ExecuteStatement(query.c_str());
  }
    
  // set aMoreRows
  // if MaxRows was provided and we are getting MaxRows+1 rows back:
  // there are MoreRows (TODO: remove extra row!!)
  if( aMaxRows > 0 && outrs->RecordCount > aMaxRows )
    aMoreRows = true;
  else
    aMoreRows = false;


  // replace enum values
  ReplaceEnums(outrs);
  
  return outrs;
}


//generates query based on passed in params
wstring CSQLAccountFinder::GenerateQuery( IMTCollection* apCorporateAccountIDs, //can be NULL
                                         bool aIncludeNonHierarchalAccounts,
                                         DATE aRefDate,
                                         IMTCollection* apColumnProps, //can be NULL
                                         IMTDataFilter* apFilter, //can be NULL
                                         IMTDataFilter* apJoinFilter, //can be NULL
                                         IMTCollection* apOrderProps, //can be NULL
                                         long aMaxRows,
                                         bool isOracle,
                                          bool isParameterized)
{

  //Check whether the actor can manage owned accounts. Get a "score" based on the
  //hierarchy depth level he can manage. If he can't manage anything: score 0,
  //if he can manage only directly owned accounts - score 1, 
  //if he can manage directly owned accounts and accounts owned by direct descendents - score 2
  //if he can manage anything - score 1000000.
  //This score is used in the finder EXIST predicate for num_generation field in order to limit
  //finding capabilities for this particular actor.
  //For example: If he can manage only directly owned accounts, then the predicate will be "WHERE num_generations < 1"
  MetraTech_Accounts_Ownership::IOwnershipReaderPtr reader(__uuidof(MetraTech_Accounts_Ownership::OwnershipReader));
  long actorAccountID = mSessionContext->AccountID;
  long score = reader->GetAuthScore(reinterpret_cast<MTAUTHLib::IMTSessionContext *>(mSessionContext.GetInterfacePtr()));
  bool canManageAll = false;
  
  // if user has access to all corporations (corporateAccounts includes HIERARCHY_ROOT)
  // do not add either corp or ownership filters
  GENERICCOLLECTIONLib::IMTCollectionPtr corpAccounts = apCorporateAccountIDs;
  if (corpAccounts != NULL)
  { for (int i=1; i <= corpAccounts->Count; i++)
    {
      long id = corpAccounts->GetItem(i);
      if (id == HIERARCHY_ROOT)
      { 
        canManageAll = true; break;
      }
    }
  }

  MTQueryBuilder query(isOracle);

  // Do I want account type info? Examine filter
  bool bReturnOnlyCoreProperties = false;
  InitFromFilter(apFilter, &bReturnOnlyCoreProperties);

  // 1) Add base table
  AddBaseTable(query, isOracle);

  // 2) Add columns
  if(bReturnOnlyCoreProperties && apColumnProps == NULL)
  {
    GENERICCOLLECTIONLib::IMTCollectionPtr coll("MetraTech.MTCollection");
    coll->Add("[CORE_ACCOUNT_PROPERTIES]");
    AddColumns(query, (GENERICCOLLECTIONLib::IMTCollection *)coll.GetInterfacePtr(), aRefDate, isOracle);
  }
  else
   AddColumns(query, (GENERICCOLLECTIONLib::IMTCollection *)apColumnProps, aRefDate, isOracle);
  
  // 3) Add filter to limit corporate accounts
  if(score == 0)
  {
    if(canManageAll == false)
      AddCorpFilterToQuery(query, apCorporateAccountIDs, aIncludeNonHierarchalAccounts, apFilter, aRefDate, isOracle);
  }
  else 
  {
    if(canManageAll == false)
      AddOwnershipFilterToQuery(query, actorAccountID, score, aRefDate, isOracle, apCorporateAccountIDs);
  }
  
  // 4) Add filters
  if (isParameterized)
    AddParameterizedFilterToQuery(query, (ROWSETLib::IMTDataFilter *)apFilter, aRefDate, isOracle);
  else
    AddFilterToQuery(query, (ROWSETLib::IMTDataFilter *)apFilter, aRefDate, isOracle);

  // 5) Add join filters
  AddJoinFilters(query, (ROWSETLib::IMTDataFilter *)apJoinFilter, aRefDate, isOracle);

  // 6) Add order
  AddOrder(query, (GENERICCOLLECTIONLib::IMTCollection *)apOrderProps);

  // 7) Set max MaxRows if provided
  if (aMaxRows > 0)
    query.SetMaxRows(aMaxRows+1);

  return query.GenerateString();
}

////////////////////////////////////////////////////////////////////////////
//  Function    : AddOwnershipFilterToQuery(...)                          //
//  Description : Add filter to only include accounts that the actor      //
//  (and possibly actor's descendents) own                                //
//  Inputs      : aQuery                          --                      //
//              : aCorporateAccountIDs            --                      //
//              : aIncludeNonHierarchicalAccounts --                      //
//              : apFilter                        --                      //
//              : aRefDate                        --                      //
//              : isOracle                        --                      //
//  Outputs     : none                            --                      //
////////////////////////////////////////////////////////////////////////////
void CSQLAccountFinder::AddOwnershipFilterToQuery(MTQueryBuilder& aQuery, 
                                                  long actorAccountID, 
                                                  long score, 
                                                  DATE aRefDate, 
                                                  bool isOracle, 
                                                  IMTCollection* apCorporateAccountIDs)
{
  ROWSETLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
  rs->Init(ACC_HIERARCHIES_QUERIES);
  rs->SetQueryTag("__ACCOUNT_FINDER_OWNERSHIP_FILTER__");
  rs->AddParam("%%ID_ACTOR%%",actorAccountID);
  rs->AddParam("%%AUTH_LIMITATION%%",score);
  wstring refDateStr;
  if (!isOracle && aRefDate == 0.0)
  {
    // Special case to support generation of parameterized SQL.
    refDateStr = L"@RefDate";
  }
  else
  {
    FormatValueForDB(variant_t(aRefDate,VT_DATE), isOracle, refDateStr);
  } 
  rs->AddParam("%%REFDATE%%",refDateStr.c_str(), VARIANT_TRUE);
  GENERICCOLLECTIONLib::IMTCollectionPtr corpAccounts = apCorporateAccountIDs;
  wstring corpfilter = GetCorporateFilter(corpAccounts);
  rs->AddParam("%%CORPORATE_ACCOUNTS%%",corpfilter.c_str(), VARIANT_TRUE);
  
  // add the filter to query
  wstring filter = (wchar_t*)rs->GetQueryString();
  aQuery.AddWhereCondition(filter);
}

////////////////////////////////////////////////////////////////////////////
//  Function    : AddCorpFilterTOQuery(...)                               //
//  Description : Add filter to only include accounts that are in the     //
//              :  list of corporate accounts or non-hierarchical         //
//              :  namespaces.                                            //
//  Inputs      : aQuery                          --                      //
//              : aCorporateAccountIDs            --                      //
//              : aIncludeNonHierarchicalAccounts --                      //
//              : apFilter                        --                      //
//              : aRefDate                        --                      //
//              : isOracle                        --                      //
//  Outputs     : none                            --                      //
////////////////////////////////////////////////////////////////////////////
void CSQLAccountFinder::AddCorpFilterToQuery(MTQueryBuilder& aQuery,     
                                             IMTCollection* apCorporateAccountIDs, //can be NULL
                                             bool aIncludeNonHierarchalAccounts,
                                             IMTDataFilter* apFilter, //can be NULL
                                             DATE aRefDate,
                                             bool isOracle)
{
  // special case 1:
  // if Filter includes "system_user", do not add clause
  // to allow looking up csr's (that are not in any corporate account)
  ROWSETLib::IMTDataFilterPtr filter = apFilter;

  for(int idx = 0;idx < filter->GetCount(); idx++)
  {
    ROWSETLib::IMTFilterItemPtr filterItem = filter->GetItem(idx);
    wstring property = (const wchar_t *) filterItem->PropertyName;
    wstring value = (_bstr_t)filterItem->Value;
    StrToLower(property);
    StrToLower(value);

#if 0
    if (property == L"_namespacetype" && 
        value == L"system_user")
    {
      //found a system_user filter, do not add corporation filter
      return;
    }
#endif
  }

  
  // join with anccorpfilter
  // and add a clause like this:
  // (anccorpfilter.id_ancestor IN (137,193,219)
  //  or (anccorpfilter.id_ancestor = 1 and anccorpfilter.num_generations = 1 and t_av_internal.c_folder = 'N'))

  // add join
  CSQLFinderMetaDataTable* table = mpMetaData->GetTable(L"anccorpfilter");
  AddNeededJoinToQuery(aQuery, table, aRefDate, isOracle);
 
  // construct filter1 for hierachical accounts
  // "anccorpfilter.id_ancestor IN/OR (137,193,219)"
  GENERICCOLLECTIONLib::IMTCollectionPtr corpAccounts = apCorporateAccountIDs;
  wstring filter1 = GetCorporateFilter(corpAccounts);
  
  // construct filter2 for NonHierarchalAccounts
  wstring filter2;
  if (aIncludeNonHierarchalAccounts)
      filter2 += L"(anccorpfilter.id_ancestor = 1 and anccorpfilter.num_generations = 1 and t_av_internal.c_folder = '0')";

  // user should have access to either a corporation or residential accounts
  // throw an error if not
  if (filter1.empty() && filter2.empty())
  { 
    LogYAACError("Actor account lacks capabilities to access any corporate or non-hierarchical account.", LOG_DEBUG );
    MT_THROW_COM_ERROR( MTAUTH_ACCESS_DENIED, "" );
  }

  // combine filter1 and filter2
  wstring fullFilter = L"(";
  if (!filter1.empty())
  { fullFilter += filter1;
    if( !filter2.empty())
    {  fullFilter += NEWLINE_2_INDENT;
       fullFilter += L" OR ";
    }
  }
  if(!filter2.empty())
    fullFilter += filter2;

  fullFilter += L")";

  // add the filter to query
  aQuery.AddWhereCondition(fullFilter);
}
wstring CSQLAccountFinder::GetCorporateFilter(GENERICCOLLECTIONLib::IMTCollectionPtr corpAccounts)
{
  wstring filter1 = L"";
  if (corpAccounts != NULL)
  {
    filter1 = L"";
    wstring idString;
    wchar_t buf[20];
    for (int i=1; i <= corpAccounts->Count; i++)
		{
      long id = corpAccounts->GetItem(i);

      if (i > 1)
        idString += L",";
      
      _ltow( id, buf, 10);
      idString += buf;
    } 

    if (corpAccounts->Count == 0)  
    { // no filterString
    }
    else if (corpAccounts->Count == 1)  
    { //use =
      filter1 = L"anccorpfilter.id_ancestor =";
      filter1 += idString;
    }
    else
    { //use in
      filter1 = L"anccorpfilter.id_ancestor IN (";
      filter1 += idString;
      filter1 += L")";
    }
  }

  return filter1;
}

void CSQLAccountFinder::InitFromFilter(IMTDataFilter* apFilter, bool* bReturnOnlyCoreProperties )
{
  mRelevantAccountViewTables.clear();
  if(apFilter)
  {
    ROWSETLib::IMTDataFilterPtr df = apFilter;
    wstring val;
    bool AccountTypePredicateFound = false;
    bool OnlyCoreFound = true;
    
    // add join condition for all filter items
    for(int idx = 0;idx < df->GetCount(); idx++)
    {
      ROWSETLib::IMTFilterItemPtr propertyItem = df->GetItem(idx);
      wstring propName = (const wchar_t *)propertyItem->PropertyName;
      if(_wcsicmp(propName.c_str(), L"AccountTypeName") == 0)
      {
        AccountTypePredicateFound = true;
        val = (const wchar_t *) (_bstr_t)propertyItem->Value;
        ParseSearchAccountTypes(val);
        //for each type get relevant account views. Return properties only from them
        vector<wstring>::iterator it;
        for(it=mSearchAccountTypes.begin(); it != mSearchAccountTypes.end(); it++)
        {
          wstring at = *it;
          vector<wstring> accountviews = ((CAccountMetaData*)mpMetaData)->GetAccountViewTablesForType(at);
          vector<wstring>::iterator it1;
          for(it1 = accountviews.begin(); it1 != accountviews.end(); it1++)
          {
            wstring av = *it1;
            if(mRelevantAccountViewTables.find(av) == mRelevantAccountViewTables.end())
            {
              mRelevantAccountViewTables.insert(av);
            }
          }
        }
        break;
      }
      CSQLFinderMetaDataTable* table = NULL;
      MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr propMeta = 
        mpMetaData->GetPropertyMetaData(propName, &table);
      _bstr_t propgroup = propMeta->PropertyGroup;
      bool IsCoreProperty = _wcsicmp((wchar_t *)propMeta->PropertyGroup, (wchar_t *)(L"[CORE_ACCOUNT_PROPERTIES]")) == 0;
      if(IsCoreProperty == false)
      {
        //1. find the view where this property resides
        //2. Find account type(s) which are associated with this view
        //3. Get a set of all views belonging to these types

        wstring tableName = table->Name;
        vector<wstring>::iterator it1;
        vector<wstring> commontables = ((CAccountMetaData*)mpMetaData)->GetCommonAccountViewTables(tableName);
        for(it1 = commontables.begin(); it1 != commontables.end(); it1++)
        {
          wstring av = *it1;
          if(mRelevantAccountViewTables.find(av) == mRelevantAccountViewTables.end())
          {
            mRelevantAccountViewTables.insert(av);
          }
        }
        OnlyCoreFound = false;
      }
      
    }
    (*bReturnOnlyCoreProperties) = AccountTypePredicateFound ? false : OnlyCoreFound;
  }
  else
    (*bReturnOnlyCoreProperties) = true;

}

void CSQLAccountFinder::ParseSearchAccountTypes(wstring& filter)
{
  mSearchAccountTypes.clear();
  wchar_t seps[] = L", \t\n'";
  wchar_t* token = wcstok((wchar_t*)filter.c_str(), seps);
  while( token != NULL )
  {
    mSearchAccountTypes.push_back(_wcsupr(token)); 
    token = wcstok( NULL, seps );
  }
}
void CSQLAccountFinder::AddColumns(MTQueryBuilder& aQuery,
                              GENERICCOLLECTIONLib::IMTCollection *apColumnProps,
                              DATE aRefDate, 
                              bool isOracle)
{
  if(apColumnProps)
  {
    return CMTSQLFinder::AddColumns(aQuery, apColumnProps, aRefDate, isOracle);
  }
  else
  {
    // no column specified, use all MetaData columns (that are not filter only)
    // for accounts
    MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr propMetaSet;
    propMetaSet = mpMetaData->GetPropertyMetaDataSet();
    for(long idx = 1; idx <= propMetaSet->Count; idx++ )
    {
      MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr propMeta = propMetaSet->Item[idx];
      
      //check table to see if this property is for filter_only
      wstring alias = (const wchar_t*) propMeta->DBTableName;
      CSQLFinderMetaDataTable* table = mpMetaData->GetTable(alias);
      wstring tableName = table->Name;
      bool IsCoreProperty = _wcsicmp((wchar_t *)propMeta->PropertyGroup, (wchar_t *)(L"[CORE_ACCOUNT_PROPERTIES]")) == 0;
      if(IsCoreProperty == false)
      {
        if(mRelevantAccountViewTables.find(tableName) == mRelevantAccountViewTables.end())
          continue;
      }
      //add if not a filter only property
      if( !(table->Flags & CSQLFinderMetaDataTable::FILTER_ONLY))
      {
        AddColumnToQuery(aQuery, propMeta, table, aRefDate, isOracle);  
      }
    }  
  }
}
