/**************************************************************************
 * @doc
 * 
 * Copyright 1997-2000 by MetraTech
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
 * Created by: Raju Matta
 * $Header$
 * 
 * 	LanguageList.h : 
 *	--------------
 *	This is the header file of the LanguageList class.
 *
 ***************************************************************************/

#ifndef _LANGUAGELIST_H_
#define _LANGUAGELIST_H_

#ifdef WIN32
// NOTE: this is necessary for the MS compiler because
// using templates that expand to huge strings makes their
// names > 255 characters.
#pragma warning( disable : 4786 )
// NOTE: compiler complains because even though the class is
// dll exported, the map cannot be dll exported.  hence the 
// warning
#pragma warning( disable : 4251 )
#endif //  WIN32

//	All the includes
#include "MTSingleton.h"
#include "errobj.h"
#include "DBAccess.h"
#include "NTLogger.h"

// STL includes
# include <string>
# include <map>

// forward declaration
struct IMTQueryAdapter;

typedef std::map<int, _bstr_t> LanguageList;
typedef std::map<int, _bstr_t>::iterator LanguageListIterator; 

typedef std::map<_bstr_t,int> ReverseLanguageList;
typedef std::map<_bstr_t,int>::const_iterator ReverseLanguageListIterator; 


// Need to change this to _declspec every member rather than the whole
// class
class CLanguageList :
	public virtual ObjectWithError,
	public DBAccess,
	private MTSingleton<CLanguageList>
{
public:
	DLL_EXPORT static CLanguageList * GetInstance();
	DLL_EXPORT static void ReleaseInstance();

	// @cmember Initialize the CLanguageList object
	DLL_EXPORT  BOOL Init ();

	// @cmember Constructor
	DLL_EXPORT CLanguageList();

	// @cmember Destructor
	DLL_EXPORT virtual ~CLanguageList();

	// @cmember Get Iterator
	DLL_EXPORT LanguageListIterator GetLanguageListIterator();

	// @cmember Get Map
	DLL_EXPORT const LanguageList& GetLanguageList();

	DLL_EXPORT const ReverseLanguageList& GetReverseLanguageList();

	DLL_EXPORT ReverseLanguageListIterator GetReverseLanguageListIterator();
  
protected:

private:
	// method to build the associations between the IDs and values
    BOOL BuildLanguageList ();
  
	LanguageList mLanguageList;
	ReverseLanguageList mReverseList;
	LanguageListIterator mLanguageListIterator;
	ReverseLanguageListIterator mReverseListIterator;

  IMTQueryAdapter* mpQueryAdapter;
  NTLogger mLogger;
};
  
#endif //_LANGUAGELIST_H_

