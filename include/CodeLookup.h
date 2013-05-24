/**************************************************************************
 * @doc
 * 
 * Copyright 1998 by MetraTech
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
 * 	CodeLookup.h : 
 *	--------------
 *	This is the header file of the CodeLookup class.
 *
 ***************************************************************************/

#ifndef _CODELOOKUP_H_
#define _CODELOOKUP_H_

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
#include "CodeLookupDefs.h"
#include "errobj.h"
#include "DBAccess.h"
#include "NTLogger.h"
#include <mtcomerr.h>
#include <string>

#include <fastbuffer.h>

using std::map;

#define CODE_LOOKUP_MUTEX       _T("MT_CODE_LOOKUP_MUTEX")

// forward declaration
struct IMTQueryAdapter;

class EnumDataKey : public FastBuffer<wchar_t, 255>
{
public:
	EnumDataKey(const wchar_t * apKey) : FastBuffer<wchar_t, 255>(apKey)
	{ }

	BOOL operator == (const EnumDataKey & arOther) const
	{
		return (0 == wcsicmp(arOther.GetBuffer(), GetBuffer()));
	}

	bool operator < (const EnumDataKey & arOther) const
	{ return (wcsicmp(arOther.GetBuffer(), GetBuffer()) < 0); }
};

// Need to change this to _declspec every member rather than the whole
// class
class CCodeLookup :
	public virtual ObjectWithError,
	public DBAccess,
	private MTSingleton<CCodeLookup>
{
public:
	DLL_EXPORT static CCodeLookup * GetInstance();
  DLL_EXPORT static void ReleaseInstance();
  
  // @cmember Initialize the CCodeLookup object
  DLL_EXPORT  BOOL Init ();
  
  // @cmember Constructor
  DLL_EXPORT CCodeLookup();
  
  // @cmember Destructor
  DLL_EXPORT virtual ~CCodeLookup();
  
  
  typedef map<EnumDataKey, int> EnumDataTable;
  
  typedef map<int, wstring> IDToName;

  // Constructors
  
  // Copy Constructor
  DLL_EXPORT CCodeLookup (const CCodeLookup& C);	
  
  // Assignment operator
  DLL_EXPORT const CCodeLookup& CCodeLookup::operator=(const CCodeLookup& rhs);
  
  //	Accessors
  // @cmember Add the data to the table
  // TODO: make this private(?)
  DLL_EXPORT BOOL AddEnumData (const std::wstring& pNewValue, long& newCode);
  
  // @cmember Get the enum data code for a name
  DLL_EXPORT BOOL GetEnumDataCode (const wchar_t * apCodeName, int& code);
  
  DLL_EXPORT BOOL GetValue (const int iCode, std::wstring& value);

protected:

private:
		// method to build the associations between the IDs and values
  BOOL BuildEnumDataTable ();
  
  // method to create query for adding data
  BOOL CreateQueryToAddEnumData (const wchar_t* pNewValue, std::wstring& langRequest);
  BOOL CreateQueryToGetEnumData (std::wstring& langRequest);
		
  EnumDataTable mEnumDataTable;
  
	IDToName mIDToName;

  NTLogger mLogger;
  
  IMTQueryAdapter* mpQueryAdapter;
  _bstr_t mConfigPath ;
};
  
#endif //_CODELOOKUP_H_

