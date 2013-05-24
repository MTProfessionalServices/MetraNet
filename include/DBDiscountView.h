/**************************************************************************
 * @doc DBDiscountView
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
 * @index | DBDiscountView
 ***************************************************************************/

#ifndef __DBDiscountView_H
#define __DBDiscountView_H

#include <DBViewHierarchy.h>
#include <DBProductViewProperty.h>
#include <DBConstants.h>
#include <NTThreadLock.h>
#include <string>
#include <autologger.h>
#include <DbObjectsLogging.h>
#include <DBAccess.h>
#include <DBProductView.h>

// forward declarations ...
struct IMTQueryAdapter ;
class CMSIXDefinition ;

// @class DBDiscountView
class DBDiscountView :
  public DBProductViewAbstract
{
// @access Public:
public:
  // @cmember Constructor
  DLL_EXPORT DBDiscountView() ;
  // @cmember Destructor
  DLL_EXPORT virtual ~DBDiscountView() ;

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

  // @cmember Get the detail of a particular session
  DLL_EXPORT virtual BOOL GetDisplayItemDetail (const int &arAcctID, const int &arIntervalID,
    const int &arSessionID, const std::wstring &arLangCode, DBSQLRowset * & arpRowset) ;
  // @cmember Get the database table name
  DLL_EXPORT std::wstring GetTableName() const ;

// @access Private:
private:
  // @cmember Add to the select clause for the product view item query
  void AddToSelectClause(const std::wstring &arColumnName, const std::wstring &arName) ;
  // @cmember Get the product view summarize query
  std::wstring CreateDiscountViewSummarizeQuery(const int &arAcctID, 
    const int &arIntervalID, 
    const std::wstring &arPDTableName,const int &arViewID, 
    const std::wstring &arViewName, const std::wstring &arViewType, 
    const int &arDescriptionID, const std::wstring &arExtension) ;
  // @cmember Get the product view items query
  std::wstring CreateDiscountViewItemsQuery(const int &arAcctID, const int &arIntervalID,
		const std::wstring &arPDTableName,
    const std::wstring &arExtension) ;
  // @cmember Get the product view item detail query
  std::wstring CreateDiscountViewItemDetailQuery(const int &arAcctID, 
    const int &arIntervalID, const int &arSessionID,
     const std::wstring &arPDTableName) ;

  // @cmember the database table name
  std::wstring      mTableName ;
  _bstr_t         mConfigPath ;

} ;

//
//	@mfunc
//	Get the table name.
//  @rdesc 
//  The database table name.
//
inline std::wstring DBDiscountView::GetTableName() const
{
  return mTableName ;
}

//
//	@mfunc
//	Create the product view summarize query. 
//  @rdesc 
//  The product view summarize query.
//
inline void DBDiscountView::AddToSelectClause (const std::wstring &arColumnName, 
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

#endif 
