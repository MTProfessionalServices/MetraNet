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

#ifndef __SQLFINDER_H_
#define __SQLFINDER_H_

#include "SQLFinderMetaData.h"
#include <stdutils.h>
#include <mtprogids.h>
#include <MTQueryBuilder.h>
#include <DataAccessDefs.h>
#include <formatdbvalue.h>

#import <MTEnumConfigLib.tlb>
#import <GenericCollection.tlb>
#import <MTProductCatalog.tlb> rename ("EOF", "RowsetEOF")
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 

class CMTSQLFinder
{
public:
  CMTSQLFinder()
  {
    ;
  }

  CMTSQLFinder(CSQLFinderMetaData* apMetaData,
               MTENUMCONFIGLib::IEnumConfigPtr aEnumConfig);
  ~CMTSQLFinder()
  {
    ;
  }
  
  void Search(DATE aRefDate,
              GENERICCOLLECTIONLib::IMTCollection *apColumnProps,
              ROWSETLib::IMTDataFilter *apFilter,
              ROWSETLib::IMTDataFilter *apJoinFilter,
              GENERICCOLLECTIONLib::IMTCollection *apOrderProps,
              long aMaxRows,
              bool& aMoreRows,
              ROWSETLib::IMTSQLRowset **apRowset);

private:

protected:
  //Data
  CSQLFinderMetaData* mpMetaData;
  MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;

  //Methods
  wstring GenerateQuery(DATE aRefDate,
                       GENERICCOLLECTIONLib::IMTCollection *apColumnProps,
                       ROWSETLib::IMTDataFilter *apFilter,
                       ROWSETLib::IMTDataFilter *apJoinFilter,
                       GENERICCOLLECTIONLib::IMTCollection *apOrderProps,
                       long aMaxRows,
                       bool isOracle);

  void AddBaseTable(MTQueryBuilder& aQuery, bool isOracle);

  virtual void AddColumns(MTQueryBuilder& aQuery,
                  GENERICCOLLECTIONLib::IMTCollection *apColumnProps,
                  DATE aRefDate,
                  bool isOracle);
  
  void AddJoinFilters(MTQueryBuilder& query, 
                      ROWSETLib::IMTDataFilter* apJoinFilter,
                      DATE aRefDate,
                      bool isOracle);

  void AddOrder(MTQueryBuilder& query, 
                GENERICCOLLECTIONLib::IMTCollection *apOrderProps);

  void SetMaxRows(MTQueryBuilder& query,
                  long aMaxRows);

  void AddFilterToQuery(MTQueryBuilder& aQuery,     
                        ROWSETLib::IMTDataFilter* apFilter,
                        DATE aRefDate,
                        bool isOracle);
  
  void AddParameterizedFilterToQuery(MTQueryBuilder& aQuery,     
                                     ROWSETLib::IMTDataFilter* apFilter,
                                     DATE aRefDate,
                                     bool isOracle);
  
  void AddColumnToQuery(MTQueryBuilder& aQuery,     
                        const MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr& aPropMeta,
                        CSQLFinderMetaDataTable* aTable,
                        DATE aRefDate,
                        bool isOracle);

  void AddNeededJoinToQuery(MTQueryBuilder& aQuery,
                            CSQLFinderMetaDataTable* aTable,
                            DATE aRefDate,
                            bool isOracle);

  bool IsGroupProperty(BSTR aPropName);
  
  wstring MakeExistFilter(CSQLFinderMetaDataTable* aTable, const wstring& aFilterString);
  wstring MakeDateFilter(DATE aRefDate, const wstring& aAlias, bool aAllowNull, bool isOracle, const wstring& aStartDateProp, const wstring& aEndDateProp);

  void ReplaceEnums(ROWSETLib::IMTSQLRowsetPtr& aRowset);
  
  ROWSETLib::IMTDataFilterPtr CopyFilter(const ROWSETLib::IMTDataFilterPtr& aFilter);
  void AdjustFilter(ROWSETLib::IMTDataFilterPtr& aFilter, bool isOracle);
};

#endif// SQLFinder.h : Declaration of the CSQLFinder

