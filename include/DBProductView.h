/**************************************************************************
 * @doc DBProductView
 * 
 * @module  Encapsulation of a single product view|
 * 
 * This class encapsulates the properties of a single product view.
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Kevin Fitzgerald
 * $Header$
 *
 * @index | DBProductView
 ***************************************************************************/

#ifndef __DBPRODUCTVIEW_H_
#define __DBPRODUCTVIEW_H_

#include <DBViewHierarchy.h>
#include <NTThreadLock.h>
#include <string>
#include <map>
#include <autologger.h>
#include <DbObjectsLogging.h>
#include <DBAccess.h>

#import <MTEnumConfigLib.tlb>
#import "MTNameIDLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping

// disable warning ...
#pragma warning( disable : 4275 4251)

// forward declarations ...
struct IMTQueryAdapter ;

class CMSIXDefinition ;

class DBProductViewProperty;
class CLanguageList;

// typedefs ...
typedef std::map<std::wstring, DBProductViewProperty *>	DBProductViewPropColl;
typedef std::map<std::wstring, DBProductViewProperty *>::iterator	DBProductViewPropCollIter ;
typedef std::map<std::wstring, int>	LangCodeColl;
typedef std::map<std::wstring, int>::iterator	LangCodeCollIter ;


class DBProductViewAbstract :
  public DBView,
  public DBAccess
{
// @access Public:
public:
  // @cmember Constructor
  DLL_EXPORT DBProductViewAbstract();
  // @cmember Destructor
  DLL_EXPORT virtual ~DBProductViewAbstract() ;

  // inheritted functions ...
  // @cmember Get the display items 
  DLL_EXPORT virtual BOOL GetDisplayItems (const int &arAcctID, const int &arIntervalID,
    const std::wstring &arLangCode, DBSQLRowset * & arpRowset,long instanceID = 0)=0 ;
  DLL_EXPORT virtual BOOL GetDisplayItems (const int &arAcctID, const int &arIntervalID,
    const std::wstring &arLangCode, const std::wstring &arExtension, DBSQLRowset * & arpRowset,long instanceID = 0)=0 ;
  // @cmember Summarize the contents of this view
  DLL_EXPORT virtual BOOL Summarize(const int &arAcctID, const int &arIntervalID,
    DBSQLRowset * & arpRowset)=0 ;
  DLL_EXPORT virtual BOOL Summarize(const int &arAcctID, const int &arIntervalID,
    DBSQLRowset * & arpRowset, const std::wstring &arExtension)=0 ;

  DLL_EXPORT DBProductViewPropColl & GetPropertyList() { return (mPropColl) ; };
  DLL_EXPORT DBProductViewPropColl & GetReservedPropertyList() { return (mResvdPropColl) ; };

  // @cmember Find the property 
  DLL_EXPORT BOOL FindProperty (const std::wstring &arName, DBProductViewProperty * & arpProperty) ;

  // @cmember Get the detail of a particular session
  DLL_EXPORT virtual BOOL GetDisplayItemDetail (const int &arAcctID, const int &arIntervalID,
    const int &arSessionID, const std::wstring &arLangCode, DBSQLRowset * & arpRowset)=0 ;

protected:
  std::wstring       mSelectClause;
  DBProductViewPropColl mPropColl;
  DBProductViewPropColl mResvdPropColl;

  // @cmember the query adapter 
  IMTQueryAdapter *               mpQueryAdapter;
  // @cmember the logging object 
	MTAutoInstance<MTAutoLoggerImpl<szDbObjectsTag,szDbObjectsDir> >	mLogger;  // @cmember the thread lock
  // @cmember the thread lock
  NTThreadLock    mLock;
  std::wstring       mFromClause;
  std::wstring       mWhereClause;
  long            mNumEnums;
  LangCodeColl    mLangCodeColl;
  CLanguageList* mpLanguageList;

  // @cmember Add to the select clause for the product view item query
  void AddToSelectClause(const std::wstring &arColumnName, const std::wstring &arName) ;
  void AddEnumToQuery (const std::wstring &arColumnName, const std::wstring &arName) ;
  std::wstring ReplaceLangCode (const int &arLangCode, const std::wstring &arWhereClause) ;
  BOOL PopulateLanguageCollection () ;
} ;

// @class DBProductView
class DBProductView :
  public DBProductViewAbstract
{
// @access Public:
public:
  // @cmember Constructor
  DLL_EXPORT DBProductView() ;
  // @cmember Destructor
  DLL_EXPORT virtual ~DBProductView() ;

  // @cmember Initialize the view
  DLL_EXPORT BOOL Init (const std::wstring &arViewType, const int &arViewID, const std::wstring &arName,
    const int &arDescriptionID, CMSIXDefinition *pProductView) ;

  // inheritted functions ...
  // @cmember Get the display items 
  DLL_EXPORT virtual BOOL GetDisplayItems (const int &arAcctID, const int &arIntervalID,
    const std::wstring &arLangCode, DBSQLRowset * & arpRowset,long instanceID = 0) ;
  DLL_EXPORT virtual BOOL GetDisplayItems (const int &arAcctID, const int &arIntervalID,
    const std::wstring &arLangCode, const std::wstring &arExtension, DBSQLRowset * & arpRowset,long instanceID = 0) ;
  // @cmember Summarize the contents of this view
  DLL_EXPORT virtual BOOL Summarize(const int &arAcctID, const int &arIntervalID,
    DBSQLRowset * & arpRowset) ;
  DLL_EXPORT virtual BOOL Summarize(const int &arAcctID, const int &arIntervalID,
    DBSQLRowset * & arpRowset, const std::wstring &arExtension) ;

  DLL_EXPORT BOOL GetDisplayItems (const int &arAcctID, const int &arIntervalID,
    const int &arSessionID, const std::wstring &arLangCode, DBSQLRowset * & arpRowset,long instanceID = 0) ;
  DLL_EXPORT BOOL GetDisplayItems (const int &arAcctID, const int &arIntervalID,
    const int &arSessionID, const std::wstring &arLangCode, const std::wstring &arExtension, 
    DBSQLRowset * & arpRowset,long instanceID = 0) ;
  DLL_EXPORT BOOL Summarize(const int &arAcctID, const int &arIntervalID,
    const int &arSessionID, DBSQLRowset * & DBSQLRowset) ;

  // @cmember Get the detail of a particular session
  DLL_EXPORT virtual BOOL GetDisplayItemDetail (const int &arAcctID, const int &arIntervalID,
    const int &arSessionID, const std::wstring &arLangCode, DBSQLRowset * & arpRowset) ;
  // @cmember Get the database table name
  DLL_EXPORT std::wstring GetTableName() const ;

protected:

// @access Private:
private:

  BOOL AddReservedProperty(const std::wstring &arName, const std::wstring &arColumn, 
    const std::wstring &arFQN, const std::wstring &arType, 
    const CMSIXProperties::PropertyType &arMSIXType, 
    const VARIANT_BOOL &arUserVisible, const VARIANT_BOOL &arFilterable, 
    const VARIANT_BOOL &arExportable,const _variant_t &arDefault, 
    const VARIANT_BOOL &arIsRequired) ;

	//converts the default value from the string found in the
	//product view def to the respective variant
	BOOL ConvertDefaultValue(_variant_t &arDefaultVal,
													 const CMSIXProperties &arMSIXProp);
  // @cmember Get the product view summarize query
  std::wstring CreateProductViewSummarizeQuery(const int &arAcctID, 
    const int &arIntervalID,
    const std::wstring &arPDTableName,const int &arViewID, 
    const std::wstring &arViewName, const std::wstring &arViewType, 
    const int &arDescriptionID, const std::wstring &arExtension) ;
  // @cmember Get the product view items query
  std::wstring CreateProductViewItemsQuery(const int &arAcctID, const int &arIntervalID,
    const std::wstring &arPDTableName,
    const int &arViewID, const std::wstring &arSessionType,
    const std::wstring &arExtension, const int &arLangCode,long instanceID) ;
  // @cmember Get the product view children summary query
  std::wstring CreateProductViewChildrenSummaryQuery(const int &arAcctID, const int &arIntervalID,
    const int &arSessionID, 
    const std::wstring &arPDTableName, const int &arViewID, 
    const std::wstring &arViewName, const std::wstring &arViewType, 
    const int &arDescriptionID) ;
  // @cmember Get the product view item children query
  std::wstring CreateProductViewItemChildrenQuery(const int &arAcctID, 
    const int &arIntervalID, const int &arSessionID,
    const std::wstring &arPDTableName,
    const int &arViewID, const std::wstring &arSessionType, const std::wstring &arExtension,
    const int &arLangCode) ;
  // @cmember Get the product view item detail query
  std::wstring CreateProductViewItemDetailQuery(const int &arAcctID, 
    const int &arIntervalID, const int &arSessionID,
    const std::wstring &arPDTableName,
    const int &arViewID, const std::wstring &arSessionType,
    const int &arLangCode) ;

  // @cmember the property collection
  // @cmember the database table name
  std::wstring       mTableName ;
  // @cmember the select clause for the product view item query 
  // @cmember the thread lock
  NTThreadLock    mLock ;
  _bstr_t         mConfigPath ;


	MTNAMEIDLib::IMTNameIDPtr mNameID;
	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
} ;

//
//	@mfunc
//	Get the table name.
//  @rdesc 
//  The database table name.
//
inline std::wstring DBProductView::GetTableName() const
{
  return mTableName ;
}

//
//	@mfunc
//	Create the product view summarize query. 
//  @rdesc 
//  The product view summarize query.
//
inline void DBProductViewAbstract::AddToSelectClause (const std::wstring &arColumnName, 
                                                      const std::wstring &arName) 
{
  // if we haven't started the select clause yet ... add the select ...
  if (!mSelectClause.empty())
  {
    mSelectClause += L", " ;
  }

  // add the column name and the property name to the select clause 
  mSelectClause += L"pv." ;
  mSelectClause += arColumnName ;
  mSelectClause += L" " ;
  mSelectClause += arName ;
}

//
//	@mfunc
//	Create the product view summarize query. 
//  @rdesc 
//  The product view summarize query.
//
inline void DBProductViewAbstract::AddEnumToQuery (const std::wstring &arColumnName,
                                                   const std::wstring &arName) 
{
  wchar_t wstrTempNum[64] ;
  std::wstring wstrTableName ;

  // create the description table name ...
  wstrTableName = L"d" ;
  wstrTableName += _itow (mNumEnums, wstrTempNum, 10) ;

  // if we haven't started the select clause yet ... add the select ...
  if (!mSelectClause.empty())
  {
    mSelectClause += L", " ;
  }

  // add the property name to the select clause 
  mSelectClause += wstrTableName ;
  mSelectClause += L".tx_desc " ;
  mSelectClause += arName ;

  // add the stuff to the from clause ...
  mFromClause += L", t_description d" ;
  mFromClause += wstrTempNum ;

  // add the stuff to the where clause ...
  mWhereClause += L" and " ;
  mWhereClause += wstrTableName ;
  mWhereClause += L".id_desc = pv." ;
  mWhereClause += arColumnName ;
  mWhereClause += L" and " ;
  mWhereClause += wstrTableName ;
  mWhereClause += L".id_lang_code = %%LANG_CODE%%" ;
  
  // increment the # of enums in the clauses ...
  mNumEnums++ ;
}

// reenable warning ...
#pragma warning( default : 4275 4251)

#endif 
