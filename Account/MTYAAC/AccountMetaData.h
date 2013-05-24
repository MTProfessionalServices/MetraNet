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

#ifndef __ACCOUNTMETADATA_H_
#define __ACCOUNTMETADATA_H_

#include <NTThreadLock.h>
#include <MTQueryBuilder.h>
#include <map>
#include <vector>
#include <set>
#include <SQLFinderMetaData.h>

class MSIXDefCollection;

using namespace std;

// meta data describing all account properties
// singleton, destroyed when dll unloads
class CAccountMetaData : public CSQLFinderMetaData
{
public:
  wstring GetMAMStateFilterClause();
  MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr GetPropertyMetaDataSet(const wstring& aPropertyGroup = L"");
  MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr GetPropertyMetaData(const wstring& aPropertyName,
                                                                  CSQLFinderMetaDataTable** apTable);

  static CAccountMetaData* GetInstance(); //only way to get the metadata
	static void DeleteInstance();           //only DllMain() should call this

  const vector<wstring>& GetAccountViewTablesForType(const wstring& aTypeName) const;
  const vector<wstring>& GetAllAccountViewTables() const;
  const map<wstring, vector<wstring> >& GetAccountTypeMappings() const;
  const vector<wstring>& GetCommonAccountViewTables(const wstring& aAccountViewTableName);
  

private:
  CAccountMetaData();
  ~CAccountMetaData();
    
  void AddProperties();
  void AddTables();
  void LoadMetaData();
  void LoadAccountExtensions();
  bool LoadAccountExtension(MSIXDefCollection& coll, const _bstr_t& configFile);
  

  //Data
  static CAccountMetaData* mpInstance;
  static NTThreadLock mAccessLock;

  map<wstring, vector<wstring> > mAccountTypeMappings;
  vector<wstring> mAccountViewList;
  map<wstring, vector<wstring> > mCommonAccountViewTables;

};
#endif