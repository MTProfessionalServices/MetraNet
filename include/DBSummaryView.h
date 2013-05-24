/**************************************************************************
 * @doc DBSummaryView
 * 
 * @module  Encapsulation of a summary view|
 * 
 * This class encapsulates a summary view
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
 * @index | DBSummaryView
 ***************************************************************************/

#ifndef __DBSummaryView_H
#define __DBSummaryView_H

#include <DBViewHierarchy.h>
#include <DBInMemRowset.h>
#include <DBConstants.h>
#include <DBUsageCycle.h>
#include <string>
#include <autologger.h>


// disable warning ...
#pragma warning( disable : 4251 )

// forward declarations ...
struct IMTQueryAdapter ;

// @class DBSummaryView
class DBSummaryView : 
  public DBView
{
  // @access Public:
public:
  // @cmember Constructor
  DLL_EXPORT DBSummaryView() ;
  // @cmember Destructor
  DLL_EXPORT virtual ~DBSummaryView() ;
  
  // @cmember Initialize the view
  DLL_EXPORT BOOL Init(const std::wstring &arViewType, const int &arViewID, const std::wstring &arName,
    const int &arDescriptionID) ;

  // inheritted functions ...
  // @cmember Get the display items 
  DLL_EXPORT virtual BOOL GetDisplayItems (const int &arAcctID, const int &arIntervalID,
    const std::wstring &arLangCode, DBSQLRowset * & arpRowse,long instanceID = 0) ;
  DLL_EXPORT virtual BOOL GetDisplayItems (const int &arAcctID, const int &arIntervalID,
    const std::wstring &arLangCode, const std::wstring &arExtension, DBSQLRowset * & arpRowset,long instanceID = 0) ;
  // @cmember Summarize the contents of this view
  DLL_EXPORT virtual BOOL Summarize(const int &arAcctID, const int &arIntervalID,
    DBSQLRowset * & arpRowset) ;
  DLL_EXPORT virtual BOOL Summarize(const int &arAcctID, const int &arIntervalID,
    DBSQLRowset * & arpRowset, const std::wstring &arExtension) ;
  
  // @access Private:
private:
  // @cmember the logging object 
  MTAutoInstance<MTAutoLoggerImpl<szDbObjectsTag,szDbObjectsDir> >	mLogger;  // @cmember the thread lock

  // @cmember Get the product view summarize query
  std::wstring CreateProductViewSummarizeOptimizedQuery(const int &arAcctID, 
													 const int &arIntervalID,
													 const std::wstring &arIDsForSQLQuery,
													 const int aLanguageCode);

protected:
  // @cmember the query adapter 
  IMTQueryAdapter* mpQueryAdapter;

  // @cmember the query adapter 
  DBUsageCycleCollection* mpUsageCycle;
} ;

// reenable warning ...
#pragma warning( default : 4251 )

#endif 
