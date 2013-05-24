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

#include "SQLFinderMetaData.h"

////////////////////////////////////////////////////////////////////////////

//TODO move to common place!!
static MTPRODUCTCATALOGLib::PropValType
PropertyTypeToPropValType(CMSIXProperties::PropertyType aType)
{
	switch(aType)
	{
	case CMSIXProperties::TYPE_STRING:
    return MTPRODUCTCATALOGLib::PROP_TYPE_ASCII_STRING;

	case CMSIXProperties::TYPE_WIDESTRING:
		return MTPRODUCTCATALOGLib::PROP_TYPE_UNICODE_STRING;

	case CMSIXProperties::TYPE_INT32:
		return MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER;

	case CMSIXProperties::TYPE_INT64:
		return MTPRODUCTCATALOGLib::PROP_TYPE_BIGINTEGER;

	case CMSIXProperties::TYPE_TIMESTAMP:
		return MTPRODUCTCATALOGLib::PROP_TYPE_DATETIME;

	case CMSIXProperties::TYPE_FLOAT:
	case CMSIXProperties::TYPE_DOUBLE:
		return MTPRODUCTCATALOGLib::PROP_TYPE_DOUBLE;

	case CMSIXProperties::TYPE_NUMERIC:
	case CMSIXProperties::TYPE_DECIMAL:
		return MTPRODUCTCATALOGLib::PROP_TYPE_DECIMAL;

	case CMSIXProperties::TYPE_ENUM:
		return MTPRODUCTCATALOGLib::PROP_TYPE_ENUM;

	case CMSIXProperties::TYPE_BOOLEAN:
		return MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN;

	default:
		ASSERT(0);
		return MTPRODUCTCATALOGLib::PROP_TYPE_UNKNOWN;
	}
}

////////////////////////////////////////////////////////////////////////////
// CSQLFinderMetaDataTable                                                //
////////////////////////////////////////////////////////////////////////////
CSQLFinderMetaDataTable::CSQLFinderMetaDataTable() :
    Flags(NO_FLAGS)
{
}
////////////////////////////////////////////////////////////////////////////
CSQLFinderMetaDataTable::CSQLFinderMetaDataTable(const wchar_t *aName,
                                                 const wchar_t *aAlias,
                                                 const wchar_t *aJoinCondition,
                                                 int        aFlags,
                                                 const wchar_t *aDependeeTables,
                                                 const wchar_t *aTableHint) :
  Name(aName),
  Alias(aAlias),
  JoinCondition(aJoinCondition),
  Flags(aFlags),
  TableHint(aTableHint)
{
  //Set the start/end properties to defaults
  StartDateProp = L"vt_start";
  EndDateProp   = L"vt_end";

  wstring sDependeeTables(aDependeeTables);

  //parse aDependeeTables wstring for ',' and add to DependeeTables vector
  wstring::size_type startPos = 0;
  while(true)
  { 
    wstring::size_type endPos = sDependeeTables.find(',', startPos);
    wstring table = sDependeeTables.substr(startPos, endPos);
    if (table.size() == 0)
      break; //no table, done

    DependeeTables.push_back(table);

    if (endPos == wstring::npos)
      break; //no more commas, done

    startPos = endPos + 1; //skip comma
  }
}
////////////////////////////////////////////////////////////////////////////
CSQLFinderMetaDataTable::CSQLFinderMetaDataTable(const CSQLFinderMetaDataTable& rhs)
{
  operator=(rhs); 
}
////////////////////////////////////////////////////////////////////////////
CSQLFinderMetaDataTable& CSQLFinderMetaDataTable::operator= (const CSQLFinderMetaDataTable& rhs)
{
  Name = rhs.Name;
  Alias = rhs.Alias;
  JoinCondition = rhs.JoinCondition;
  Flags = rhs.Flags;
  DependeeTables = rhs.DependeeTables; //copies vector
  TableHint = rhs.TableHint;
  StartDateProp = rhs.StartDateProp;
  EndDateProp   = rhs.EndDateProp;

  return (*this);
}
////////////////////////////////////////////////////////////////////////////
// CSQLFinderMetaData                                                     //
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
CSQLFinderMetaData::CSQLFinderMetaData(wchar_t* aBaseTable)
{
  mPropMetaDataSet.CreateInstance(MTPROGID_MTPROPERTY_METADATASET);
  mBaseTable = aBaseTable;
}
////////////////////////////////////////////////////////////////////////////
CSQLFinderMetaData::~CSQLFinderMetaData()
{
  mPropMetaDataSet = NULL;

  //delete tables in map
  for( std::map<wstring, CSQLFinderMetaDataTable*>::iterator itr = mTableMap.begin();
       itr != mTableMap.end();
       ++itr)
  {
    CSQLFinderMetaDataTable* tbl = itr->second;
    delete tbl;
  }
}
//TODO:  Implement LoadFromXML(...)
////////////////////////////////////////////////////////////////////////////
//  Function    : LoadFromXML(...)                                        //
//  Description : Load the find metadata from an XML file.                //
//  Inputs      :                                                         //
//  Outputs     :                                                         //
////////////////////////////////////////////////////////////////////////////
bool CSQLFinderMetaData::LoadFromXML(const wchar_t *aPath)
{
  return false;
}

////////////////////////////////////////////////////////////////////////////
//  Function    : AddProperty(...)                                        //
//  Description :                                                         //
//  Inputs      :                                                         //
//  Outputs     :                                                         //
////////////////////////////////////////////////////////////////////////////
bool CSQLFinderMetaData::AddProperty(const wchar_t *aPropertyName,
                                     const wchar_t *aTableAlias,
                                     const wchar_t *aColumnName,
                                     MTPRODUCTCATALOGLib::PropValType aDataType,
                                     const wchar_t *aPropertyGroup,
                                     const wchar_t *aEnumSpace,
                                     const wchar_t *aEnumType)
{
  MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr propMeta;
  
  propMeta = mPropMetaDataSet->CreateMetaData(aPropertyName);
  propMeta->DBTableName = aTableAlias;
  propMeta->DBColumnName = aColumnName;
  propMeta->DataType = aDataType;
  propMeta->PropertyGroup = aPropertyGroup;

  if(aEnumSpace != NULL)
    propMeta->EnumSpace = aEnumSpace;
 
  if(aEnumType != NULL)
    propMeta->EnumType = aEnumType;

  return true;
}
////////////////////////////////////////////////////////////////////////////
//  Function    : AddProperty(...)                                        //
//  Description :                                                         //
//  Inputs      :                                                         //
//  Outputs     :                                                         //
////////////////////////////////////////////////////////////////////////////
bool CSQLFinderMetaData::AddProperty(const wchar_t *aPropertyName,
                                     const wchar_t *aTableAlias,
                                     const wchar_t *aColumnName,
                                     MTPRODUCTCATALOGLib::PropValType aDataType,
                                     const wchar_t *aPropertyGroup)
{
  return AddProperty(aPropertyName, aTableAlias, aColumnName, aDataType, aPropertyGroup, NULL, NULL);
}
////////////////////////////////////////////////////////////////////////////
//  Function    : AddProperty(...)                                        //
//  Description :                                                         //
//  Inputs      :                                                         //
//  Outputs     :                                                         //
////////////////////////////////////////////////////////////////////////////
bool CSQLFinderMetaData::AddProperty(const wchar_t *aPropertyName,
                                     const wchar_t *aTableAlias,
                                     const wchar_t *aColumnName,
                                     MTPRODUCTCATALOGLib::PropValType aDataType)
{
  return AddProperty(aPropertyName, aTableAlias, aColumnName, aDataType, L"", NULL, NULL);
}
////////////////////////////////////////////////////////////////////////////
//  Function    : AddTable(...)                                           //
//  Description :                                                         //
//  Inputs      :                                                         //
//  Outputs     :                                                         //
////////////////////////////////////////////////////////////////////////////
bool CSQLFinderMetaData::AddTable(const wchar_t *aName, 
                                  const wchar_t *aAlias,
                                  const wchar_t *aJoinCondition,
                                  int        aFlags,
                                  const wchar_t *aDependeeTables,
                                  const wchar_t *aTableJoin)
{
  CSQLFinderMetaDataTable aTable(aName, aAlias, aJoinCondition, aFlags, aDependeeTables, aTableJoin);

  mTableMap[aTable.Alias] = new CSQLFinderMetaDataTable(aTable);

  return true;
}
////////////////////////////////////////////////////////////////////////////
//  Function    : AddTable(...)                                           //
//  Description :                                                         //
//  Inputs      :                                                         //
//  Outputs     :                                                         //
////////////////////////////////////////////////////////////////////////////
bool CSQLFinderMetaData::AddTable(const wchar_t *aName, 
                                  const wchar_t *aAlias,
                                  const wchar_t *aJoinCondition,
                                  int        aFlags,
                                  const wchar_t *aDependeeTables)
{
  CSQLFinderMetaDataTable aTable(aName, aAlias, aJoinCondition, aFlags, aDependeeTables);

  mTableMap[aTable.Alias] = new CSQLFinderMetaDataTable(aTable);

  return true;
}
////////////////////////////////////////////////////////////////////////////
//  Function    : AddTable(...)                                           //
//  Description :                                                         //
//  Inputs      :                                                         //
//  Outputs     :                                                         //
////////////////////////////////////////////////////////////////////////////
bool CSQLFinderMetaData::AddTable(const wchar_t *aName, 
                                  const wchar_t *aAlias)
{
  CSQLFinderMetaDataTable aTable(aName, aAlias, L"", CSQLFinderMetaDataTable::NO_FLAGS, L"");

  mTableMap[aTable.Alias] = new CSQLFinderMetaDataTable(aTable);

  return true;
}
////////////////////////////////////////////////////////////////////////////
//  Function    : AddTable(...)                                           //
//  Description :                                                         //
//  Inputs      :                                                         //
//  Outputs     :                                                         //
////////////////////////////////////////////////////////////////////////////
bool CSQLFinderMetaData::AddTable(const wchar_t *aName, 
                                  const wchar_t *aAlias,
                                  const wchar_t *aJoinCondition)
{
  CSQLFinderMetaDataTable aTable(aName, aAlias, aJoinCondition, CSQLFinderMetaDataTable::NO_FLAGS, L"");

  mTableMap[aTable.Alias] = new CSQLFinderMetaDataTable(aTable);

  return true;
}
////////////////////////////////////////////////////////////////////////////
//  Function    : AddTable(...)                                           //
//  Description :                                                         //
//  Inputs      :                                                         //
//  Outputs     :                                                         //
////////////////////////////////////////////////////////////////////////////
bool CSQLFinderMetaData::AddTable(const wchar_t *aName, 
                                  const wchar_t *aAlias,
                                  const wchar_t *aJoinCondition,
                                  int        aFlags)
{
  CSQLFinderMetaDataTable aTable(aName, aAlias, aJoinCondition, aFlags, L"");

  mTableMap[aTable.Alias] = new CSQLFinderMetaDataTable(aTable);

  return true;
}

////////////////////////////////////////////////////////////////////////////
//  Function    : AddTable(...)                                           //
//  Description :                                                         //
//  Inputs      :                                                         //
//  Outputs     :                                                         //
////////////////////////////////////////////////////////////////////////////
bool CSQLFinderMetaData::AddTable(const wchar_t *aAlias, 
                                  CSQLFinderMetaDataTable* aTable)
{
  mTableMap[aAlias] = aTable;
  return true;
}

////////////////////////////////////////////////////////////////////////////
MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr CSQLFinderMetaData::GetPropertyMetaDataSet(const wstring& aPropertyGroup)
{
  if(aPropertyGroup == L"")
  {
    //By default, return all properties
    return mPropMetaDataSet;

  //Property Group Specified
  } else {
    
    //Check if all properties requested
    if(_wcsicmp((wchar_t *)aPropertyGroup.c_str(), (wchar_t *)(L"[ALL_PROPERTIES]")) == 0)
      return mPropMetaDataSet;
    else
    {

      MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr propMetaDataSet;
      long i = 0;
      propMetaDataSet.CreateInstance(MTPROGID_MTPROPERTY_METADATASET);

      //Get the properties that match
      for(i = 1; i <= mPropMetaDataSet->Count; i++ )
      {
        MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr propMeta = mPropMetaDataSet->Item[i];
        
        //Fix for compare problem.
        _bstr_t strGroup = aPropertyGroup.c_str();

        if(_wcsicmp((wchar_t *)propMeta->PropertyGroup, (wchar_t *)strGroup) == 0)
        {
          MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr newPropMeta = propMetaDataSet->CreateMetaData(propMeta->Name);

          newPropMeta->DBTableName = propMeta->DBTableName;
          newPropMeta->DBColumnName = propMeta->DBColumnName;
          newPropMeta->PropertyGroup = propMeta->PropertyGroup;
          newPropMeta->DataType = propMeta->DataType;
          newPropMeta->EnumSpace = propMeta->EnumSpace;
          newPropMeta->EnumType = propMeta->EnumType;
        }
      }

      return propMetaDataSet;
    }
  }
}
////////////////////////////////////////////////////////////////////////////
MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr CSQLFinderMetaData::GetPropertyMetaData(const wstring&             aPropertyName,
                                                                                    CSQLFinderMetaDataTable** apTable)
{
  MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr propMeta = mPropMetaDataSet->GetItem(aPropertyName.c_str());

  //if table provided, look up table
  if (apTable)
  {
    (*apTable) = GetTable((const wchar_t*)propMeta->DBTableName);
  }

  return propMeta;
}
////////////////////////////////////////////////////////////////////////////
CSQLFinderMetaDataTable* CSQLFinderMetaData::GetTable(const wstring& tableAlias)
{
  CSQLFinderMetaDataTable* table = mTableMap[tableAlias];

  if(table == NULL)
    MT_THROW_COM_ERROR("table with alias %s not found in metadata", tableAlias.c_str());

  return table;
}
////////////////////////////////////////////////////////////////////////////
CSQLFinderMetaDataTable* CSQLFinderMetaData::GetBaseTable()
{
  //base table is acc 
  return GetTable(mBaseTable);
}

