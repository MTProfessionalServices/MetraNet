/**************************************************************************
 * @doc DBDataAnalysisView
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
 * @index | DBDataAnalysisView
 ***************************************************************************/

#ifndef __DBDataAnalysisView_H
#define __DBDataAnalysisView_H

#include <DBViewHierarchy.h>
#include <DBProductViewProperty.h>
#include <DBConstants.h>
#include <NTThreadLock.h>
#include <string>
#include <NTLogger.h>
#include <DBAccess.h>
#include <DBProductView.h>
#include <autologger.h>
#include <DbObjectsLogging.h>

// disnable warning ...
#pragma warning( disable : 4275 4251)

// forward declarations ...
struct IMTQueryAdapter ;
class MTDataAnalysisView ;

// @class DBDataAnalysisView
class DBDataAnalysisView :
  public DBProductViewAbstract
{
// @access Public:
public:
  // @cmember Constructor
  DLL_EXPORT DBDataAnalysisView() ;
  // @cmember Destructor
  DLL_EXPORT virtual ~DBDataAnalysisView() ;

  // @cmember Initialize the view
  DLL_EXPORT BOOL Init (const std::wstring &arViewType, const int &arViewID, const std::wstring &arName,
    const int &arDescriptionID, MTDataAnalysisView *pDataAnalysisView) ;

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
// @access Private:
private:
  std::wstring CreateDataAnalyisViewItemsQuery(const std::wstring &arQueryTag,
    const int &arAcctID, const int &arIntervalID, const std::wstring &arExtension,
    const int &arLangID) ;
  _bstr_t         mConfigPath ;
  std::wstring       mQueryTag ;
} ;

#endif 
