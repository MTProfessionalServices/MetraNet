/**************************************************************************
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
***************************************************************************/

#ifndef _USERCONFIG_H_
#define _USERCONFIG_H_

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
#include <KioskDefs.h>
#include <SharedDefs.h>
#include <NTThreadLock.h>
#include <errobj.h>
#include <DBAccess.h>
#include <KioskLogging.h>
#include <autologger.h>
#include <DBInMemRowset.h>
#include <DBConstants.h>
#include <MTUtil.h>
#include <mtprogids.h>
#include <mtparamnames.h>

#include <map>
using std::map;

// import the query adapter tlb ...
#import <Rowset.tlb> rename ("EOF", "RowsetEOF")

// forward declaration
struct IMTQueryAdapter;

// Need to change this to _declspec every member rather than the whole
// class
class CUserConfig :
	public virtual ObjectWithError,
	public DBAccess
{
	public:

		typedef map<wstring, _variant_t> Profile;

		// @cmember Constructor
		DLL_EXPORT CUserConfig();

		// @cmember Destructor
		DLL_EXPORT virtual ~CUserConfig();

    	// @cmember Initialize the CUserConfig object
    	DLL_EXPORT  BOOL Initialize() ;

    	// @cmember Load default user configuration
    	DLL_EXPORT  BOOL LoadDefaultUserConfiguration(const wstring& arExtensionName) ;

    	// @cmember Get the user config info
		DLL_EXPORT  BOOL GetConfigInfo (const wstring &arLoginName,
									 const wstring &arNameSpace);

		// @cmember Add a new user 
		DLL_EXPORT  BOOL Add (const wstring &arLoginName,
							  const wstring &arNameSpace, const wstring &arLangCode,
							  const long &arAccID, const long &arTimeZoneID, LPDISPATCH pRowset);

		// @cmember Delete a new user 
		DLL_EXPORT  BOOL Delete (const wstring &arLoginName,
							     const wstring &arNameSpace, 
							     const wstring &arLangCode,
							     const long &arAccID, 
							     const long &arTimeZoneID, 
							     LPDISPATCH pRowset);

    	DLL_EXPORT  BOOL UpdateUserLanguage(const wstring &arLoginName,
							  				const wstring &arNameSpace, 
											const wstring &arLangCode);
		
		DLL_EXPORT BOOL GetUserConfigValue (const wstring &arTagName,
										    _variant_t& value);

		DLL_EXPORT BOOL SetUserConfigValue (const wstring &arTagName,
      										const wstring &arTagValue);

		// Record set to get user account information back
		DLL_EXPORT ROWSETLib::IMTInMemRowsetPtr GetUserAccountInfo();

    	// Accessors ...
    	DLL_EXPORT const wstring & GetLangCode () const { return mLangCode;}
    	DLL_EXPORT const long GetAccountID() const { return mAcctID;}
    	DLL_EXPORT const long GetProfileID() const { return mProfileID;}

	protected:

	private:
		// Copy Constructor
    	CUserConfig (const CUserConfig& C);	

		// Assignment operator
		const CUserConfig& CUserConfig::operator=(const CUserConfig& rhs);

    	void TearDown() ;

 		// @cmember Get the new ID
      BOOL GetCurrentID (const wchar_t* pFieldName, long& ID, ROWSETLib::IMTSQLRowsetPtr &arRowset);

		// @cmember Insert User Profile information
		void CreateInsertOrUpdateUserProfileInfo (const wstring &arQueryType,
      const wstring &arName, const wstring &arValue, 
      const wstring &arDescription, const long &arProfileID, 
      wstring &langRequest);

    void CreateUpdateUserLanguageQuery (const wstring &arLoginName, 
      const long &arCurrentSiteID, const long &arNewSiteID,
      wstring& langRequest) ;

    void CreateGetCurrentSiteIDQuery (const wstring &arLoginName, 
      const wstring &arNameSpace, wstring& langRequest) ;

    // method to create query for init with provider id
		void CreateQueryToSelectUserAccountInfo (wstring& langRequest);

    // method to create query for init with provider id
    void CreateInitQuery (const wstring &arLoginName,
      const wstring &arNameSpace, wstring& langRequest);

    // method to create query to get non profile info 
    void CreateQueryToGetNonProfileInfo (const wstring &arLoginName,
      const wstring &arNameSpace, wstring& langRequest);

    // method to create query to see if profile exists
    void CreateQueryToSeeIfProfileExists (const wstring &arTagName,
      wstring& langRequest);

    BOOL CreateAndExecuteGetLocalizedSiteInfoQuery(const wstring &arNameSpace,
      const wstring &arLangCode, ROWSETLib::IMTSQLRowsetPtr &arRowset) ;

    BOOL CreateAndExecuteInsertOrUpdateUserProfileInfo (const wstring &arQueryType,
      const wstring &arName, const wstring &arValue, 
      const wstring &arDescription, const long &arProfileID, 
      ROWSETLib::IMTSQLRowsetPtr &arRowset);

    BOOL CreateAndExecuteInsertSiteUserInfo(const long &arProfileID, 
      const wstring &arLoginName, const long &arSiteID, 
      ROWSETLib::IMTSQLRowsetPtr &arRowset);

    BOOL CreateAndExecuteDeleteSiteUserInfo(const wstring &arLoginName, 
        const long &arSiteID, ROWSETLib::IMTSQLRowsetPtr &arRowset);

    _bstr_t mConfigPath ;
    long mAcctID ;
    wstring mLangCode;
		long mProfileID;

		MTAutoInstance<MTAutoLoggerImpl<szKioskUserConfig,szKioskLoggingDir> >	mLogger;
    Profile mUserProfileMap;
    Profile mDefaultProfileMap;
    
    IMTQueryAdapter* mpQueryAdapter;

    BOOL mInitialized ;
};

#endif //_USERCONFIG_H_

