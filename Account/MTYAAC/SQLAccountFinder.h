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

#ifndef __SQLACCOUNTFINDER_H_
#define __SQLACCOUNTFINDER_H_

#include <MTSQLFinder.h>
#include "AccountMetaData.h"

class CSQLAccountFinder : public CMTSQLFinder
{
private:
  //CAccountMetaData* mpMetaData;
  //MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
  MTYAACLib::IMTSessionContextPtr mSessionContext;

public:
  CSQLAccountFinder(CAccountMetaData* apMetaData,
                    MTENUMCONFIGLib::IEnumConfigPtr aEnumConfig,
                    MTYAACLib::IMTSessionContextPtr& aCtx);

  void Search( IMTCollection* apCorporateAccountIDs,
               bool aIncludeNonHierarchalAccounts,
               DATE aRefDate,
               IMTCollection* apColumnProps,
               IMTDataFilter *apFilter,
               IMTDataFilter *apJoinFilter,
               IMTCollection *apOrderProps,
               long aMaxRows,
               bool& aMoreRows,
               IMTSQLRowset **apRowset);

  void Search( IMTCollection* apCorporateAccountIDs,
               bool aIncludeNonHierarchalAccounts,
               DATE aRefDate,
               IMTCollection* apColumnProps,
               IMTDataFilter *apFilter,
               IMTDataFilter *apJoinFilter,
               IMTCollection *apOrderProps,
               long aMaxRows,
               bool& aMoreRows,
               VARIANT transaction, 
               IMTSQLRowset **apRowset);


  ROWSETLib::IMTSQLRowsetPtr InternalSearch
                  ( IMTCollection* apCorporateAccountIDs, //HIERARCHY_ROOT means allow all
                  bool aIncludeNonHierarchalAccounts,
                  DATE aRefDate,
                  IMTCollection *apColumnProps,
                  IMTDataFilter *apFilter,
                  IMTDataFilter *apJoinFilter,
                  IMTCollection *apOrderProps,
                  long aMaxRows,
                  bool& aMoreRows,
                  VARIANT transaction = _variant_t(VT_NULL));

  wstring GenerateQuery(IMTCollection* apCorporateAccountIDs,
                       bool aIncludeNonHierarchalAccounts,
                       DATE aRefDate,
                       IMTCollection *apColumnProps,
                       IMTDataFilter *apFilter,
                       IMTDataFilter *apJoinFilter,
                       IMTCollection *apOrderProps,
                       long aMaxRows,
                       bool isOracle,
                        bool isParameterized);
protected:
  void AddCorpFilterToQuery( MTQueryBuilder& aQuery,     
                             IMTCollection* apCorporateAccountIDs, //can be NULL
                             bool aIncludeNonHierarchalAccounts,
                             IMTDataFilter* apFilter, //can be NULL
                             DATE aRefDate,
                             bool isOracle);
  void AddOwnershipFilterToQuery(MTQueryBuilder& aQuery, long actorAccountID, long score, DATE aRefDate, bool isOracle, IMTCollection* apCorporateAccountIDs);
  wstring GetCorporateFilter(GENERICCOLLECTIONLib::IMTCollectionPtr corpAccounts);
  void InitFromFilter(IMTDataFilter* apJoinFilter, bool* bReturnOnlyCoreProperties);

  virtual void AddColumns(MTQueryBuilder& aQuery,
                              GENERICCOLLECTIONLib::IMTCollection *apColumnProps,
                              DATE aRefDate, 
                              bool isOracle);



private:
  vector<wstring> mSearchAccountTypes;
  set<wstring> mRelevantAccountViewTables;
  void CSQLAccountFinder::ParseSearchAccountTypes(wstring& filter);

};

#endif
