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

#ifndef __SQLFINDERMETADATA_H_
#define __SQLFINDERMETADATA_H_

#include <comdef.h>
#include <metra.h>
#include <mtcomerr.h>
#include <MTQueryBuilder.h>
#include <map>
#include <vector>
#include <SetIterate.h>
#include <DynamicTable.h>
#include <mtprogids.h>

#import <MTProductCatalog.tlb> rename ("EOF", "RowsetEOF")

class MSIXDefCollection;

//info about an account table
class CSQLFinderMetaDataTable
{
  public:
  enum FlagTypes //flags to specify various creation attributes
  { 
    NO_FLAGS       = 0x0000,
    OUTER_JOIN     = 0x0002,  // left outer join (inner join is default)
    EXISTS_JOIN    = 0x0004,  // use an exists subquery
    DATE_JOIN      = 0x0008,  // check for DATE in join
    FILTER_ONLY    = 0x0010,  // only use this table in filters, not in columns
                              // (properties for this table do not occur in default account properties)
  };

  //data
  wstring      Name;
  wstring      Alias;
  wstring      JoinCondition;
  int         Flags;
  
  //property to use for start date / end date for date joins
  wstring      StartDateProp;
  wstring      EndDateProp;
  // Optional query hint for the table join
  wstring      TableHint;

  std::vector<wstring> DependeeTables;   //tables this join depends on

  //constructors
  CSQLFinderMetaDataTable();
  CSQLFinderMetaDataTable(const wchar_t *aName,
                          const wchar_t *aAlias,
                          const wchar_t *aJoinCondition = L"",
                          int         aFlags = NO_FLAGS,
                          const wchar_t *aDependeeTables = L"",
                          const wchar_t *aTableHint = L"");
  CSQLFinderMetaDataTable(const CSQLFinderMetaDataTable& rhs);
  CSQLFinderMetaDataTable& operator= (const CSQLFinderMetaDataTable& rhs);
};


class CSQLFinderMetaData
{
public:

  CSQLFinderMetaData(wchar_t* aBaseTable);
  virtual ~CSQLFinderMetaData();

  virtual MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr GetPropertyMetaDataSet(const wstring& aPropertyName = L"");
  virtual MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr GetPropertyMetaData(const wstring& aPropertyName,
                                                                  CSQLFinderMetaDataTable** apTable = NULL);  //optional

  //Add Property
  virtual bool AddProperty(const wchar_t *aPropertyName,
                   const wchar_t *aTableAlias,
                   const wchar_t *aColumnName,
                   MTPRODUCTCATALOGLib::PropValType aDataType,
                   const wchar_t *aPropertyGroup,
                   const wchar_t *aEnumSpace,
                   const wchar_t *aEnumType);
  
  //Overloaded with no enum information
  virtual bool AddProperty(const wchar_t *aPropertyName,
                   const wchar_t *aTableAlias,
                   const wchar_t *aColumnName,
                   MTPRODUCTCATALOGLib::PropValType aDataType,
                   const wchar_t *aPropertyGroup);
  
  virtual bool AddProperty(const wchar_t *aPropertyName,
                   const wchar_t *aTableAlias,
                   const wchar_t *aColumnName,
                   MTPRODUCTCATALOGLib::PropValType aDataType);
  

  //Add Table
  virtual bool AddTable(const wchar_t *aName, 
                const wchar_t *aAlias,
                const wchar_t *aJoinCondition,
                int        aFlags,
                const wchar_t *aDependeeTables,
                        const wchar_t * aTableHint);

  //Overloaded members
  virtual bool AddTable(const wchar_t *aName, 
                const wchar_t *aAlias,
                const wchar_t *aJoinCondition,
                int        aFlags,
                const wchar_t *aDependeeTables);
  virtual bool AddTable(const wchar_t *aName, 
                const wchar_t *aAlias);

  virtual bool AddTable(const wchar_t *aName, 
                const wchar_t *aAlias,
                const wchar_t *aJoinCondition);

  virtual bool AddTable(const wchar_t *aName, 
                const wchar_t *aAlias,
                const wchar_t *aJoinCondition,
                int        aFlags);

  virtual bool AddTable(const wchar_t *aAlias, 
                CSQLFinderMetaDataTable* aTable);

  virtual CSQLFinderMetaDataTable* GetTable(const wstring& tableAlias);
  virtual CSQLFinderMetaDataTable* GetBaseTable();

  //Load properties from an XML file
  virtual bool LoadFromXML(const wchar_t *aPath);

private:
  //copying not implemented to prevent uninteded use
  CSQLFinderMetaData(const CSQLFinderMetaData&);
  CSQLFinderMetaData& operator= (const CSQLFinderMetaData&);

protected:
  MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr GetPropMetaDataSet() {return mPropMetaDataSet;}

/*  void LoadMetaData();
  void LoadAccountExtensions();
  bool LoadAccountExtension(MSIXDefCollection& coll, const _bstr_t& configFile); */

//private:
  std::map<wstring, CSQLFinderMetaDataTable*>          mTableMap;                    //  Tables, indexed by Alias
  MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr      mPropMetaDataSet;             //  Properties
  wstring mBaseTable;

};

#endif
