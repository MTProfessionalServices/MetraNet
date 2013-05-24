	
// MTUserProfile.h : Declaration of the CMTUserProfile

#ifndef __MTUSERPROFILE_H_
#define __MTUSERPROFILE_H_

#include "resource.h"       // main symbols

// RogueWave includes
#include <comdef.h>
#include <errobj.h>
#include <NTLogger.h>
#include <string>
#include <map>
#import <MTConfigLib.tlb> 
using namespace MTConfigLib ;

/////////////////////////////////////////////////////////////////////////////
// CMTUserProfile
class ATL_NO_VTABLE CMTUserProfile : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTUserProfile, &CLSID_MTUserProfile>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTUserProfile, &IID_IMTUserProfile, &LIBID_MTSITECONFIGLib>,
  public virtual ObjectWithError
{
public:

  typedef std::map<std::wstring, std::wstring> UserProfileColl;
  typedef std::map<std::wstring, std::wstring>::iterator UserProfileCollIter;

	CMTUserProfile() ;
  virtual ~CMTUserProfile() ;

DECLARE_REGISTRY_RESOURCEID(IDR_MTUSERPROFILE)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTUserProfile)
	COM_INTERFACE_ENTRY(IMTUserProfile)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTUserProfile
public:
  STDMETHOD(CommitChanges)();
	STDMETHOD(SetValue)(/*[in]*/ BSTR aTagName, /*[in]*/ BSTR aTagValue);
	STDMETHOD(GetValue)(/*[in]*/ BSTR apTagName, /*[out, retval]*/ BSTR *apTagValue);
	STDMETHOD(Initialize)(/*[in]*/ BSTR aHostName, /*[in]*/ BSTR aRelativePath, 
    /*[in]*/ BSTR aRelativeFile);
private:
  BOOL SetMTSysHeader (MTConfigLib::IMTConfigPropSetPtr aPropSet) ;
  BOOL SetUserProfileData (MTConfigLib::IMTConfigPropSetPtr aPropSet) ;
  void TearDown() ;

  UserProfileColl  mUserProfileMap ;
  BOOL            mInitialized ;
  NTLogger        mLogger ;
  std::wstring       mHostName ;
  std::wstring       mRelativePath ;
  std::wstring       mRelativeFile ;
};

#endif //__MTUSERPROFILE_H_
