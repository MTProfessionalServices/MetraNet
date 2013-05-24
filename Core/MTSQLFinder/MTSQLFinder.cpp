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

#include "MTSQLFinder.h"
#include <boost/format.hpp>

//formatting helpers
#define NEWLINE           "\n"
#define NEWLINE_1_INDENT  "\n  "
#define NEWLINE_2_INDENT  "\n    "
#define NEWLINE_3_INDENT  "\n      "

//using namespace GENERICCOLLECTIONLib;
////////////////////////////////////////////////////////////////////////////
//  Function    : CMTSQLFinder(...)                                       //
//  Description : Class constructor                                       //
//  Inputs      : apMetaData  -- Search metadata.                         //
//              : aEnumConfig -- Enumtype configuration object            //
//  Outputs     :                                                         //
////////////////////////////////////////////////////////////////////////////
CMTSQLFinder::CMTSQLFinder(CSQLFinderMetaData* apMetaData,
                           MTENUMCONFIGLib::IEnumConfigPtr aEnumConfig)
{
  mEnumConfig = aEnumConfig;
  mpMetaData = apMetaData;
  ASSERT(mpMetaData);
}
////////////////////////////////////////////////////////////////////////////
//  Function    : Search(...)                                             //
//  Description : Perform the search.                                     //
//  Inputs      : aRefDate      --  Reference date for the query          //
//              : apColumnProps --  Columns                               //
//              : apFilter      --  Data filter                           //
//              : apJoinFilter  --  Join filter                           //
//              : apOrderProps  --  Order specifying properties           //
//              : aMaxRows      --  Maximum number of rows to return      //
//  Outputs     : aMoreRows     --  More rows indicator                   //
////////////////////////////////////////////////////////////////////////////
void CMTSQLFinder::Search(DATE aRefDate,
                          GENERICCOLLECTIONLib::IMTCollection *apColumnProps,
                          ROWSETLib::IMTDataFilter *apFilter,
                          ROWSETLib::IMTDataFilter *apJoinFilter,
                          GENERICCOLLECTIONLib::IMTCollection *apOrderProps,
                          long aMaxRows,
                          bool& aMoreRows,
                          ROWSETLib::IMTSQLRowset **apRowset)
{

  ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
  rowset->Init("queries\\Acchierarchies");

  _bstr_t dbType = rowset->GetDBType();
  bool isOracle = (mtwcscasecmp(dbType, ORACLE_DATABASE_TYPE) == 0);

  // construct Query
  wstring query;
  query = GenerateQuery(aRefDate,
                        apColumnProps,
                        apFilter,
                        apJoinFilter,
                        apOrderProps,
                        aMaxRows,
                        isOracle);
  
  // execute Query
  rowset->SetQueryString(query.c_str());
  rowset->ExecuteDisconnected();
    
  // set aMoreRows
  // if MaxRows was provided and we are getting MaxRows+1 rows back:
  // there are MoreRows (TODO: remove extra row!!)
  if( aMaxRows > 0 && rowset->RecordCount > aMaxRows )
    aMoreRows = true;
  else
    aMoreRows = false;


  // replace enum values
  ReplaceEnums(rowset);
  
  *apRowset = reinterpret_cast<ROWSETLib::IMTSQLRowset*> (rowset.Detach());
}

////////////////////////////////////////////////////////////////////////////
//  Function    : GenerateQuery(...)                                      //
//  Description :                                                         //
//  Inputs      :                                                         //
//  Outputs     :                                                         //
////////////////////////////////////////////////////////////////////////////
wstring CMTSQLFinder::GenerateQuery(DATE aRefDate,
                                   GENERICCOLLECTIONLib::IMTCollection* apColumnProps, //can be NULL
                                   ROWSETLib::IMTDataFilter* apFilter, //can be NULL
                                   ROWSETLib::IMTDataFilter* apJoinFilter, //can be NULL
                                   GENERICCOLLECTIONLib::IMTCollection* apOrderProps, //can be NULL
                                   long aMaxRows,
                                   bool isOracle)
{
  MTQueryBuilder query(isOracle);

  //step 1: add base table
  AddBaseTable(query, isOracle);
  
  //step 2: add columns
  AddColumns(query, apColumnProps, aRefDate, isOracle);

  //step 3: add filters
  AddFilterToQuery(query, apFilter, aRefDate, isOracle);

  //step 4: add join filters
  AddJoinFilters(query, apJoinFilter, aRefDate, isOracle);

  //step 5: add order
  AddOrder(query, apOrderProps);


  //step 6: set max rows
  SetMaxRows(query, aMaxRows);


  return query.GenerateString();
}
////////////////////////////////////////////////////////////////////////////
//  Function    : AddBaseTable(...)                                       //
//  Description : Add the base table to the query.                        //
//  Inputs      : query -- Query builder object.                          //
//  Outputs     : none                                                    //
////////////////////////////////////////////////////////////////////////////
void CMTSQLFinder::AddBaseTable(MTQueryBuilder& aQuery, bool isOracle)
{
  CSQLFinderMetaDataTable* baseTbl = mpMetaData->GetBaseTable();
  if (isOracle)
    aQuery.AddTable(baseTbl->Name, baseTbl->Alias);
  else
    aQuery.AddTable(std::wstring(L"%%%NETMETER%%%.dbo.") + baseTbl->Name, baseTbl->Alias);
}
////////////////////////////////////////////////////////////////////////////
//  Function    : SetMaxRows(...)                                         //
//  Description :                                                         //
//  Inputs      :                                                         //
//  Outputs     :                                                         //
////////////////////////////////////////////////////////////////////////////
void CMTSQLFinder::SetMaxRows(MTQueryBuilder &aQuery, long aMaxRows)
{
  if (aMaxRows > 0)
    aQuery.SetMaxRows(aMaxRows+1);
}
////////////////////////////////////////////////////////////////////////////
//  Function    : AddColumns(...)                                         //
//  Description : Add columns to the query.                               //
//  Inputs      : query         -- Query builder object.                  //
//              : aRefDate      --                                        //
//              : apColumnProps --                                        //
//              : isOracle      --                                        //
//  Outputs     : none                                                    //
////////////////////////////////////////////////////////////////////////////
void CMTSQLFinder::AddColumns(MTQueryBuilder& aQuery,
                              GENERICCOLLECTIONLib::IMTCollection *apColumnProps,
                              DATE aRefDate, 
                              bool isOracle)
{
  if(apColumnProps)
  {
    //for all column properties
    GENERICCOLLECTIONLib::IMTCollectionPtr columns = apColumnProps;
    for(int idx = 1;idx <= columns->GetCount(); idx++)
    {
      _bstr_t propName = columns->GetItem(idx);
      
      //Check if this is a group property, which actually refers to a 
      // set of properties.
      if(IsGroupProperty(propName))
      {
        MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr propMetaSet;
        propMetaSet = mpMetaData->GetPropertyMetaDataSet((const wchar_t *)propName);

        for(long idx2 = 1; idx2 <= propMetaSet->Count; idx2++ )
        {
          MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr propMeta = propMetaSet->Item[idx2];
      
          //check table to see if this property is for filter_only
          wstring tableName = (const wchar_t*) propMeta->DBTableName;
          CSQLFinderMetaDataTable* table = mpMetaData->GetTable(tableName);

          //add if not a filter only property
          if( !(table->Flags & CSQLFinderMetaDataTable::FILTER_ONLY))
          {
            AddColumnToQuery(aQuery, propMeta, table, aRefDate, isOracle);  
          }
        }

        //Remove the bogus column

      //Add a single property
      } else {

        // get propertyMetadata
        CSQLFinderMetaDataTable* table = NULL;
        MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr propMeta;
        propMeta = mpMetaData->GetPropertyMetaData((const wchar_t*)propName, &table);
      
        AddColumnToQuery(aQuery, propMeta, table, aRefDate, isOracle);
      }
    }
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
      wstring tableName = (const wchar_t*) propMeta->DBTableName;
      CSQLFinderMetaDataTable* table = mpMetaData->GetTable(tableName);

      //add if not a filter only property
      if( !(table->Flags & CSQLFinderMetaDataTable::FILTER_ONLY))
      {
        AddColumnToQuery(aQuery, propMeta, table, aRefDate, isOracle);  
      }
    }  
  }
}
////////////////////////////////////////////////////////////////////////////
//  Function    : AddJoinFilters(...)                                     //
//  Description : Add join filters to the query.                          //
//  Inputs      :                                                         //
//  Outputs     :                                                         //
////////////////////////////////////////////////////////////////////////////
void CMTSQLFinder::AddJoinFilters(MTQueryBuilder& query, 
                                 ROWSETLib::IMTDataFilter* apJoinFilter,
                                 DATE aRefDate,
                                 bool isOracle)
{
  if(apJoinFilter)
  {
    ROWSETLib::IMTDataFilterPtr propertyJoinFilter = apJoinFilter;

    //copy filter since we are modifying it
    ROWSETLib::IMTDataFilterPtr sqlJoinFilter = CopyFilter(propertyJoinFilter);

    //adjust filter for use in SQL
    AdjustFilter(sqlJoinFilter, isOracle);

    // add join condition for all filter items
    for(int idx = 0;idx < sqlJoinFilter->GetCount(); idx++)
    {
      ROWSETLib::IMTFilterItemPtr sqlItem = sqlJoinFilter->GetItem(idx);

      // use the original filter to look up table
      // (originalFilter has property name, adjustedFilter has mangled columnName)
      ROWSETLib::IMTFilterItemPtr propertyItem = propertyJoinFilter->GetItem(idx);
      wstring propName = (const wchar_t *)propertyItem->PropertyName;
      CSQLFinderMetaDataTable* table = NULL;
      mpMetaData->GetPropertyMetaData(propName, &table);

      // make sure join exists
      AddNeededJoinToQuery(query, table, aRefDate, isOracle);
      
      // add join condition
      query.AddJoinCondition(table->Alias, (const wchar_t*)sqlItem->FilterString);
    }
  }
}
////////////////////////////////////////////////////////////////////////////
//  Function    : AddOrder(...)                                           //
//  Description :                                                         //
//  Inputs      :                                                         //
//  Outputs     :                                                         //
////////////////////////////////////////////////////////////////////////////
void CMTSQLFinder::AddOrder(MTQueryBuilder& query, GENERICCOLLECTIONLib::IMTCollection *apOrderProps)
{
  if(apOrderProps)
  {
    //for all order properties
    GENERICCOLLECTIONLib::IMTCollectionPtr orderProps = apOrderProps;
    for(int idx = 1;idx <= orderProps->GetCount(); idx++)
    {
      _bstr_t propNameAndDir = orderProps->GetItem(idx);
      wstring propName;
      wstring direction;

      //there may be either just the column name or the column name with direction, e.g. ASC or DESC
      wstring nameAndDir = (const wchar_t*) propNameAndDir;
      string::size_type blankPos = nameAndDir.find(L" ");
      if((int)blankPos < 0)
      {
        propName = (const wchar_t*) propNameAndDir;
        direction = L"";
      }
      else
      {
        //treat everything after the blank as direction
        propName = nameAndDir.substr(0, (int)blankPos);
        direction = nameAndDir.substr((int)blankPos, nameAndDir.length() - (int)blankPos);
      }

      // get propertyMetadata
      CSQLFinderMetaDataTable* table = NULL;
      MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr propMeta;
      propMeta = mpMetaData->GetPropertyMetaData(propName, &table);

      query.AddOrderBy(table->Alias, (const wchar_t*)propMeta->DBColumnName + direction);
    }
  }
}
////////////////////////////////////////////////////////////////////////////
//  Function    : AddFilterToQuery(...)                                   //
//  Description :                                                         //
//  Inputs      : aQuery    --                                            //
//              : apFilter  --                                            //
//              : aRefDate  --                                            //
//              : isOracle  --                                            //
//  Outputs     : none                                                    //
////////////////////////////////////////////////////////////////////////////
void CMTSQLFinder::AddFilterToQuery(MTQueryBuilder& aQuery,     
                                    ROWSETLib::IMTDataFilter* apFilter, //can be NULL
                                    DATE aRefDate,
                                    bool isOracle)
{
  ROWSETLib::IMTDataFilterPtr propertyFilter = apFilter;
  
  //add filter to query
  if (propertyFilter != NULL)
  {
    //copy property filter as base for sqlFilter
    ROWSETLib::IMTDataFilterPtr sqlFilter = CopyFilter(propertyFilter);

    //adjust filter for use in SQL
    AdjustFilter(sqlFilter, isOracle);

     // add where condition for all filter items
    for(int idx = 0;idx < sqlFilter->GetCount(); idx++)
    {
      ROWSETLib::IMTFilterItemPtr sqlItem = sqlFilter->GetItem(idx);

      // use the propertyFilter to look up table
      // (propertyFilter has property name, sqlFilter has mangled columnName)
      ROWSETLib::IMTFilterItemPtr propertyItem = propertyFilter->GetItem(idx);
      wstring propName = (const wchar_t *)propertyItem->PropertyName;
      CSQLFinderMetaDataTable* table = NULL;
      mpMetaData->GetPropertyMetaData(propName, &table);

      // make sure join exists
      AddNeededJoinToQuery(aQuery, table, aRefDate, isOracle);

      // add where condition
      wstring condition = (const wchar_t *)sqlItem->FilterString;

      // if we have an EXISTS_JOIN we'll need to beef up the filter condition
      if (table->Flags & CSQLFinderMetaDataTable::EXISTS_JOIN)
      { condition = MakeExistFilter(table, condition);
      }  

      // add where condition
      aQuery.AddWhereCondition(condition);
    }
  }
}
////////////////////////////////////////////////////////////////////////////
//  Function    : AddParameterizedFilterToQuery(...)                      //
//  Description :                                                         //
//  Inputs      : aQuery    --                                            //
//              : apFilter  --                                            //
//              : aRefDate  --                                            //
//              : isOracle  --                                            //
//  Outputs     : none                                                    //
////////////////////////////////////////////////////////////////////////////
void CMTSQLFinder::AddParameterizedFilterToQuery(MTQueryBuilder& aQuery,     
                                                 ROWSETLib::IMTDataFilter* apFilter, //can be NULL
                                                 DATE aRefDate,
                                                 bool isOracle)
{
  ROWSETLib::IMTDataFilterPtr propertyFilter = apFilter;
  
  //add filter to query
  if (propertyFilter != NULL)
  {
    //copy property filter as base for sqlFilter
    ROWSETLib::IMTDataFilterPtr sqlFilter = CopyFilter(propertyFilter);

    //adjust filter for use in SQL
    AdjustFilter(sqlFilter, isOracle);

     // add where condition for all filter items
    for(int idx = 0;idx < sqlFilter->GetCount(); idx++)
    {
      ROWSETLib::IMTFilterItemPtr sqlItem = sqlFilter->GetItem(idx);

      // use the propertyFilter to look up table
      // (propertyFilter has property name, sqlFilter has mangled columnName)
      ROWSETLib::IMTFilterItemPtr propertyItem = propertyFilter->GetItem(idx);
      wstring propName = (const wchar_t *)propertyItem->PropertyName;
      CSQLFinderMetaDataTable* table = NULL;
      mpMetaData->GetPropertyMetaData(propName, &table);

      // make sure join exists
      AddNeededJoinToQuery(aQuery, table, aRefDate, isOracle);

      // add where condition with parameter NOT literal value
      // TODO: Properly support IN.  Todo this, we should
      // pass lists using SAFEARRAYs and create a parameter marker for each
      // element of the array.
      wstring condition;
      if (sqlItem->Operator == ROWSETLib::OPERATOR_TYPE_IN)
      {
        condition = (const wchar_t *)sqlItem->FilterString;
      }
      else
      {
        condition = (const wchar_t *)sqlItem->PropertyName;
        switch(sqlItem->Operator) {
        case ROWSETLib::OPERATOR_TYPE_LIKE:
          condition += (boost::wformat(L" LIKE @p_%1%%2%") % (const wchar_t *)propertyItem->PropertyName % idx).str().c_str();
          break;
        case ROWSETLib::OPERATOR_TYPE_LIKE_W:
          condition += (boost::wformat(L" LIKE @p_%1%%2%") % (const wchar_t *)propertyItem->PropertyName % idx).str().c_str();
          break;
        case ROWSETLib::OPERATOR_TYPE_EQUAL:
          condition += (boost::wformat(L" = @p_%1%%2%") % (const wchar_t *)propertyItem->PropertyName % idx).str().c_str();
          break;
        case ROWSETLib::OPERATOR_TYPE_NOT_EQUAL:
          condition += (boost::wformat(L" <> @p_%1%%2%") % (const wchar_t *)propertyItem->PropertyName % idx).str().c_str();
          break;
        case ROWSETLib::OPERATOR_TYPE_GREATER:
          condition += (boost::wformat(L" > @p_%1%%2%") % (const wchar_t *)propertyItem->PropertyName % idx).str().c_str();
          break;
        case ROWSETLib::OPERATOR_TYPE_GREATER_EQUAL:
          condition += (boost::wformat(L" >= @p_%1%%2%") % (const wchar_t *)propertyItem->PropertyName % idx).str().c_str();
          break;
        case ROWSETLib::OPERATOR_TYPE_LESS:
          condition += (boost::wformat(L" < @p_%1%%2%") % (const wchar_t *)propertyItem->PropertyName % idx).str().c_str();
          break;
        case ROWSETLib::OPERATOR_TYPE_LESS_EQUAL:
          condition += (boost::wformat(L" <= @p_%1%%2%") % (const wchar_t *)propertyItem->PropertyName % idx).str().c_str();
          break;
        case ROWSETLib::OPERATOR_TYPE_IN:
          condition += L"IN (";
          condition += L")";
          break;
        case ROWSETLib::OPERATOR_TYPE_IS_NULL:
          ASSERT(sqlItem->Value.vt == VT_NULL); //in only supported with NULL value
          condition += L" IS NULL ";
          break;
        case ROWSETLib::OPERATOR_TYPE_IS_NOT_NULL:
          ASSERT(sqlItem->Value.vt == VT_NULL); //in only supported with NULL value
          condition += L" IS NOT NULL ";
          break;
        }
      }

      // if we have an EXISTS_JOIN we'll need to beef up the filter condition
      if (table->Flags & CSQLFinderMetaDataTable::EXISTS_JOIN)
      { condition = MakeExistFilter(table, condition);
      }  

      // add where condition
      aQuery.AddWhereCondition(condition);
    }
  }
}
////////////////////////////////////////////////////////////////////////////
//  Function    : AddColumnToQuery(...)                                   //
//  Description : Add the column to the query along with a join if        //
//              : needed.                                                 //
//  Inputs      : aQuery    --                                            //
//              : aPropMeta --                                            //
//              : aRefDate  --                                            //
//              : isOracle  --                                            //
//  Outputs     : none                                                    //
////////////////////////////////////////////////////////////////////////////
void CMTSQLFinder::AddColumnToQuery(MTQueryBuilder& aQuery,     
                                  const MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr& aPropMeta,
                                  CSQLFinderMetaDataTable* aTable,
                                  DATE aRefDate,
                                  bool isOracle)              
{
  // add column
  aQuery.AddSelectColumn(aTable->Alias, (const wchar_t*)aPropMeta->DBColumnName, (const wchar_t*)aPropMeta->Name);
  
  //make sure join exists
  AddNeededJoinToQuery(aQuery, aTable, aRefDate, isOracle);
}
////////////////////////////////////////////////////////////////////////////
//  Function    : AddNeededJoinToQuery(...)                               //
//  Description : Make sure appropriate join is in query and add if       //
//              : needed.
//  Inputs      : aQuery    --                                            //
//              : aTable    --                                            //
//              : aRefDate  --                                            //
//              : isOracle  --                                            //
//  Outputs     : none                                                    //
////////////////////////////////////////////////////////////////////////////
void CMTSQLFinder::AddNeededJoinToQuery(MTQueryBuilder& aQuery,
                                      CSQLFinderMetaDataTable* aTable,
                                      DATE aRefDate,
                                      bool isOracle)
{
  if (!aQuery.HasTable(aTable->Alias) &&                     // add table Join if not yet in Query
      !(aTable->Flags & CSQLFinderMetaDataTable::EXISTS_JOIN)) // EXISTS_JOINs are only added in where clause
  {
    
    // add any join that this one depends on
    std::vector<wstring>& tables = aTable->DependeeTables;
    for( std::vector<wstring>::iterator itr = tables.begin(); itr != tables.end(); itr++)
    {
      wstring dependeeTableAlias = *itr;
      CSQLFinderMetaDataTable* dependeeTable;
      dependeeTable = mpMetaData->GetTable(dependeeTableAlias);

      //recurse
      AddNeededJoinToQuery(aQuery, dependeeTable, aRefDate, isOracle);
    }
    
    //figure out join type
    MTQueryBuilder::JoinType joinType = MTQueryBuilder::INNER_JOIN;
    if (aTable->Flags & CSQLFinderMetaDataTable::OUTER_JOIN)
      joinType = MTQueryBuilder::LEFT_OUTER_JOIN;

    if (isOracle)
      aQuery.AddJoinTable(aTable->Name, aTable->Alias, joinType, aTable->JoinCondition, aTable->TableHint);
    else
      aQuery.AddJoinTable(std::wstring(L"%%%NETMETER%%%.dbo.") + aTable->Name, aTable->Alias, joinType, aTable->JoinCondition, aTable->TableHint);
    
    //add date condition if join requires it
    if (aTable->Flags & CSQLFinderMetaDataTable::DATE_JOIN)
    {
      if (aTable->Flags & CSQLFinderMetaDataTable::OUTER_JOIN)
      {
        // for outer joins, add this (where clause) filter:
        //   "(parent.vt_start is null or 'REFDATE' between ALIAS.vt_start and ALIAS.vt_end")
        // we have to prevent duplicate result rows if there are entries for multiple dates
        // and allow returning of rows if there is no entriy
        wstring dateFilter = MakeDateFilter(aRefDate, aTable->Alias, true, isOracle, aTable->StartDateProp, aTable->EndDateProp);
        aQuery.AddWhereCondition(dateFilter);
      }
      else
      {
        // for inner joins, add this join filter:
        //   "'REFDATE' between ALIAS.vt_start and ALIAS.vt_end"
        wstring dateFilter = MakeDateFilter(aRefDate, aTable->Alias, false, isOracle, aTable->StartDateProp, aTable->EndDateProp);
        aQuery.AddJoinCondition(aTable->Alias, dateFilter);
      }
    }

    //Former join location
  } 
}
////////////////////////////////////////////////////////////////////////////
//  Function    : MakeExistFilter(...)                                    //
//  Description : Construct an exists filter clause for an EXISTS_JOIN    //
//  Inputs      : aTable        --                                        //
//              : aFilterString --                                        //
//  Outputs     : String with filter clause                               //
////////////////////////////////////////////////////////////////////////////
wstring CMTSQLFinder::MakeExistFilter(CSQLFinderMetaDataTable* aTable, const wstring& aFilterString)
{
  //clause looks like this:
  //"exists (select null from t_invoice inv where inv.id_acc = acc.id_acc and upper(inv.invoice_string) like 'r%')"
  wchar_t buff[1024];
  swprintf(buff, L"exists (select null from %s %s where %s and %s)",
          aTable->Name.c_str(),
          aTable->Alias.c_str(),
          aTable->JoinCondition.c_str(),
          aFilterString.c_str());

  return buff;
}
////////////////////////////////////////////////////////////////////////////
//  Function    : MakeDateFilter(...)                                     //
//  Description : Construct a date filter clause.                         //
//  Inputs      : aRefDate    --                                          //
//              : aAlias      --                                          //
//              : aAllowNull  --                                          //
//              : isOracle    --                                          //
//  Outputs     : String with date filter clause.                         //
////////////////////////////////////////////////////////////////////////////
wstring CMTSQLFinder::MakeDateFilter(DATE aRefDate, const wstring& aAlias, bool aAllowNull, bool isOracle, const wstring &aStartDateProp, const wstring &aEndDateProp)
{
  wchar_t dateFilterBuf[256];
  wstring refDateStr;

  if (!isOracle)
  {
    // Special case to support generation of parameterized SQL.
    refDateStr = L"@RefDate";
  }
  else
  {
    FormatValueForDB(variant_t(aRefDate,VT_DATE), isOracle, refDateStr);
  } 
  if (aAllowNull)
  {
    // for outer joins, allow nulls:
    //   "(ALIAS.vt_start is null or 'REFDATE' between ALIAS.vt_start and ALIAS.vt_end")
    swprintf(dateFilterBuf,
           L"(%s.%s IS NULL OR %s BETWEEN %s.%s AND %s.vt_end)", 
             aAlias.c_str(),
             aStartDateProp.c_str(),
             refDateStr.c_str(),
             aAlias.c_str(),
             aStartDateProp.c_str(),
             aAlias.c_str(),
             aEndDateProp.c_str());
  }
  else
  {
    // for inner joins, no NULLs:
    //   "'REFDATE' between ALIAS.vt_start and ALIAS.vt_end"
    swprintf(dateFilterBuf,
            L"%s BETWEEN %s.%s AND %s.%s", 
            refDateStr.c_str(),
            aAlias.c_str(),
            aStartDateProp.c_str(),
            aAlias.c_str(),
            aEndDateProp.c_str());
  }

  return dateFilterBuf; //implicit conversion to string which will be returned
}
////////////////////////////////////////////////////////////////////////////
//  Function    : ReplaceEnums(...)                                       //
//  Description : Replace enum values in aRowset with their enumerator    //
//              : value.  Can throw a COM error.                          //
//  Inputs      : aRowset -- Rowset to replace values in.                 //
//  Outputs     : none                                                    //
////////////////////////////////////////////////////////////////////////////
void CMTSQLFinder::ReplaceEnums(ROWSETLib::IMTSQLRowsetPtr& aRowset)
{
  //TODO: optimize by skipping this if no column has enum data!!
  
  while(aRowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
	{
    long numColumns = aRowset->Count;
    for( long col = 0; col < numColumns; col++)
    {
      //rowset's column name is property name
      _bstr_t propName = aRowset->Name[col];
      
      MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr propMeta;
      propMeta = mpMetaData->GetPropertyMetaData((const wchar_t *)propName);

      if (propMeta->DataType == MTPRODUCTCATALOGLib::PROP_TYPE_ENUM)
      {
        variant_t enumID = aRowset->Value[col];
        if(enumID.vt != VT_NULL)
        { 
          variant_t enumValue;
          try
          {
            enumValue = mEnumConfig->GetEnumeratorValueByID(enumID.lVal);
          }
          catch( _com_error& err)
          {
            //log error and return NULL
            char buf[256];
            sprintf(buf, "failed to look up enumValue for ID: '%i', column: '%s': %s",
                          enumID.lVal,
                          (const char*) propName,
                          (const char*) err.Description());
            
            //LogYAACError(buf, LOG_ERROR);
            
            enumValue = 0L;
            enumValue.vt = VT_NULL;
          }
          aRowset->ModifyColumnData(propName, enumValue);
        }
      }
    }
    
    aRowset->MoveNext();
  }

  //position to beginning again, so that client gets a ready-to-use rowset
  if( aRowset->RecordCount > 0)
    aRowset->MoveFirst();
}
////////////////////////////////////////////////////////////////////////////
//  Function    : CopyFilter(...)                                         //
//  Description : Copies filter.   If passed-in filter is NULL, an empty  //
//              : filter object will be returned.                         //
//  Inputs      : aFilter                                                 //
//  Outputs     : Dupliate filter.                                        //
////////////////////////////////////////////////////////////////////////////
ROWSETLib::IMTDataFilterPtr CMTSQLFinder::CopyFilter(const ROWSETLib::IMTDataFilterPtr& aFilter)
{
  ROWSETLib::IMTDataFilterPtr returnFilter(MTPROGID_FILTER);

  if(aFilter != NULL)
  {
	// ESR-3281 and ESR-3315,(Revert CORE-1778) if using a data access method that supports UniCode,(i.e ADO.NET record sets) 
	// then "Escape" the string with ("N"), (ADO disconnected record sets DO NOT support unicode)
	VARIANT_BOOL b_EscapeString; 
	aFilter->get_EscapeString(&b_EscapeString);
	returnFilter->put_EscapeString(b_EscapeString); 
   
    // for all filter items
    for(int idx = 0;idx < aFilter->GetCount(); idx++)
    {
	  ROWSETLib::IMTFilterItemPtr filterItem = aFilter->GetItem(idx);
	  returnFilter->Add(filterItem->PropertyName,
                        _variant_t((long)filterItem->Operator, VT_I4),
                        filterItem->Value);
    }
  }

  return returnFilter;
}
////////////////////////////////////////////////////////////////////////////
//  Function    : AdjustFilter(...)                                       //
//  Description : Adjust filter for use in SQL query by making values,    //
//              : etc. "SQL-able".                                        //
//  Inputs      : aFilter   --                                            //
//              : isOracle  --                                            //
////////////////////////////////////////////////////////////////////////////
void CMTSQLFinder::AdjustFilter(ROWSETLib::IMTDataFilterPtr& aFilter, bool isOracle)
{
  // for all filter items
  for(int idx = 0;idx < aFilter->GetCount(); idx++)
  {
    ROWSETLib::IMTFilterItemPtr filterItem = aFilter->GetItem(idx);

    wstring propName = (const wchar_t *)filterItem->PropertyName;
    
    // get propertyMetadata
    CSQLFinderMetaDataTable* table = NULL;
    MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr propMeta;
    propMeta = mpMetaData->GetPropertyMetaData(propName, &table);

    // set type information on filter object
    ROWSETLib::PropValType propType;
    propType = (ROWSETLib::PropValType)propMeta->GetDataType();
    filterItem->PutPropertyType(propType);

    // replace property name with column name
    wstring colName = table->Alias;
    colName += L".";
    colName += (const wchar_t*)propMeta->DBColumnName;
    filterItem->PropertyName = colName.c_str();

    // replace "colName" with "UPPER(colName)" and make value uppercase
    // for string columns on Oracle
    if( isOracle && 
        (propMeta->DataType == MTPRODUCTCATALOGLib::PROP_TYPE_STRING ||
        propMeta->DataType == MTPRODUCTCATALOGLib::PROP_TYPE_UNICODE_STRING ||
        propMeta->DataType == MTPRODUCTCATALOGLib::PROP_TYPE_ASCII_STRING) )
    {
      colName = (const wchar_t*)filterItem->PropertyName;
 
      // special case:
      // "accstate.status" should not be compared case insensitively (performance)
      // it really is an enum stored as string (this fact should be stored in the meta data but it currently can't easily)
      if (colName != L"accstate.status")
      {
        colName = L"UPPER(" + colName + L")";
        filterItem->PropertyName = colName.c_str();
      
        _bstr_t bstrValue = filterItem->Value;
        wstring strVal = bstrValue;
        StrToUpper(strVal); 
        filterItem->Value = strVal.c_str();
      }
    }

    // replace enumvalues
    if( propMeta->DataType == MTPRODUCTCATALOGLib::PROP_TYPE_ENUM )
    {
      _bstr_t enumVal = filterItem->Value;
      long enumID = mEnumConfig->GetID(propMeta->EnumSpace, propMeta->EnumType, enumVal);
      filterItem->Value = enumID;
    }
    
    // resolve default operator
    if( filterItem->Operator == ROWSETLib::OPERATOR_TYPE_DEFAULT )
    {
      if (propMeta->DataType == MTPRODUCTCATALOGLib::PROP_TYPE_STRING ||
          propMeta->DataType == MTPRODUCTCATALOGLib::PROP_TYPE_UNICODE_STRING ||
          propMeta->DataType == MTPRODUCTCATALOGLib::PROP_TYPE_ASCII_STRING )
        filterItem->Operator = ROWSETLib::OPERATOR_TYPE_LIKE_W;
      else
        filterItem->Operator = ROWSETLib::OPERATOR_TYPE_EQUAL;
    }

    // replace '*' with '%' for strings compared with like
    if( (propMeta->DataType == MTPRODUCTCATALOGLib::PROP_TYPE_STRING ||
          propMeta->DataType == MTPRODUCTCATALOGLib::PROP_TYPE_UNICODE_STRING ||
          propMeta->DataType == MTPRODUCTCATALOGLib::PROP_TYPE_ASCII_STRING ) && 
        (filterItem->Operator == ROWSETLib::OPERATOR_TYPE_LIKE ||
         filterItem->Operator == ROWSETLib::OPERATOR_TYPE_LIKE_W ))
    {
      _bstr_t bstrValue = filterItem->Value;
      wstring strVal = bstrValue;
      for(unsigned int i=0; i < strVal.size(); i++)
      {
		  if (strVal[i] == L'*')
	          strVal[i] = L'%';
      }
      filterItem->Value = strVal.c_str();
    }

    // for strings compared with LIKE_W that have a trailing '%' use LIKE (to avoid duplicate %%)
    if( (propMeta->DataType == MTPRODUCTCATALOGLib::PROP_TYPE_STRING ||
         propMeta->DataType == MTPRODUCTCATALOGLib::PROP_TYPE_UNICODE_STRING ||
         propMeta->DataType == MTPRODUCTCATALOGLib::PROP_TYPE_ASCII_STRING ) && 
        (filterItem->Operator == ROWSETLib::OPERATOR_TYPE_LIKE_W ))
    {
      _bstr_t bstrValue = filterItem->Value;
      wstring strVal = bstrValue;
      if (strVal.size() > 0 && strVal[strVal.size()-1] == L'%')
		  filterItem->Operator = ROWSETLib::OPERATOR_TYPE_LIKE;
	  else if (strVal.size() == 0)
	  {
		  filterItem->Value = L"%";
		  filterItem->Operator = ROWSETLib::OPERATOR_TYPE_LIKE;
	  }
    }
  }
}
////////////////////////////////////////////////////////////////////////////
//  Function    : IsGroupProperty(...)                                    //
//  Description : Return true if property name specifies a property group // 
//              : rather than an individual property.                     //
//  Inputs      : aPropName -- The name of the property.                  //
//  Outputs     : boolean                                                 //
////////////////////////////////////////////////////////////////////////////
bool CMTSQLFinder::IsGroupProperty(BSTR aPropName)
{
  //TODO:  Allow any property starting with a '[' and ending with a ']' to be 
  //       a "group" property.
  //Check for valid values
  _bstr_t strPropName = aPropName;
  
  if(strPropName == _bstr_t(L"[ALL_PROPERTIES]"))
    return true;

  if(strPropName == _bstr_t(L"[CORE_ACCOUNT_PROPERTIES]"))
    return true;

  if(strPropName == _bstr_t(L"[ACCOUNT_EXTENSION_PROPERTIES]"))
    return true;

  if(strPropName == _bstr_t(L"[CORE_SERVICE_ENDPOINT_PROPERTIES]"))
    return true;

  if(strPropName == _bstr_t(L"[SERVICE_ENDPOINT_EXTENDED_PROPERTIES]"))
    return true;

  return false;
}


