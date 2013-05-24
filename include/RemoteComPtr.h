#ifndef __REMOTECOMPTR_H__
#define __REMOTECOMPTR_H__

#include <comip.h>


template<class _Interface, const IID* _IID> class MTRemoteComPtr 
: public _com_ptr_t<_com_IIID<_Interface,_IID> > {

public:
  HRESULT CreateRemoteInstance(_bstr_t& clsidString,_bstr_t& aRemoteHost)
  {
    CLSID clsid;
		HRESULT hr;
    LPOLESTR pClsidSTR = clsidString;

		if (pClsidSTR[0] == '{') {
			hr = CLSIDFromString(pClsidSTR, &clsid);
		}
		else {
			hr = CLSIDFromProgID(pClsidSTR, &clsid);
		}

		if (FAILED(hr)) {
			return hr;
		}

    COSERVERINFO aServerInfo = {0,aRemoteHost,NULL,0};
    MULTI_QI aQI = {  &__uuidof(IUnknown),NULL,0 };

    hr = ::CoCreateInstanceEx(clsid,NULL,CLSCTX_LOCAL_SERVER,
      &aServerInfo,1,&aQI);

    if(SUCCEEDED(hr) && aQI.pItf != NULL) {
      _Interface* pInt;
      hr = aQI.pItf->QueryInterface(GetIID(),reinterpret_cast<void**>(&pInt));
      Attach(pInt);
    }
    return hr;
  }

};


#endif //__REMOTECOMPTR_H__