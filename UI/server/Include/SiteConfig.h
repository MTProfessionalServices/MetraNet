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
*	SiteConfig.h :
*	------------
*	This is the header file of the SiteConfig class.
*
***************************************************************************/

#ifndef _SITECONFIG_H_
#define _SITECONFIG_H_

#ifdef WIN32
// NOTE: this is necessary for the MS compiler because
// using templates that expand to huge strings makes their
// names > 255 characters.
#pragma warning( disable : 4786 )
// NOTE: compiler complains because even though the class is
// dll exported, the map cannot be dll exported.	hence the
// warning
#pragma warning( disable : 4251 )
#endif //  WIN32

//	All the includes
#include <KioskDefs.h>
#include <SharedDefs.h>
#include <NTThreadLock.h>
#include <errobj.h>
#include <KioskLogging.h>
#include <autologger.h>
#include <MTUtil.h>
#include <mtparamnames.h>
#include <mtprogids.h>

#include <NTThreadLock.h>
#include <ConfigChange.h>
#include <map>
using namespace std;

// class
class CSiteConfig :
public virtual ObjectWithError,
public ConfigChangeObserver
{
public:
  typedef map<wstring, wstring> Profile;
  
  // @cmember Constructor
  DLL_EXPORT CSiteConfig();
  
  // @cmember Destructor
  DLL_EXPORT virtual ~CSiteConfig();
  
  // @cmember get the configuration info
  DLL_EXPORT BOOL GetConfigInfo (const wstring &arProviderName, 
    const wstring &arLangCode);
  
  DLL_EXPORT BOOL GetSiteConfigValue(const wstring &arTagName,
    wstring& value);
  
  DLL_EXPORT BOOL SetSiteConfigValue (const wstring &arTagName,
    const wstring &arTagValue );
  
protected:
  virtual void ConfigurationHasChanged() ;
  
private:
  void TearDown() ;

		// Copy Constructor
  CSiteConfig (const CSiteConfig& C);
  
  // Assignment operator
	const CSiteConfig& CSiteConfig::operator=(const CSiteConfig& rhs);
    
	MTAutoInstance<MTAutoLoggerImpl<szKioskSiteConfig,szKioskLoggingDir> >	mLogger;
  Profile mSiteProfileMap;
  ConfigChangeObservable mObservable;
  BOOL            mObserverInitialized ;
  NTThreadLock mLock ;
  wstring mProviderName ;
  wstring mLangCode ;
};

#endif //_SITECONFIG_H_

