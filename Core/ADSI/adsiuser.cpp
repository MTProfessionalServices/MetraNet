

#include <adsiuser.h>
#include <adshlp.h>
#include <domainname.h>
#include <string>
//#include <header.h>
#include <stdutils.h>

#pragma warning(disable: 4800)

template<class SmartPointer,class pInterface>
HRESULT CreateObject(SmartPointer& aPtr,const wchar_t* pObjStr,REFIID aId)
{
	pInterface* pInt;
	HRESULT hr = ADsGetObject(const_cast<wchar_t*>(pObjStr),aId,(void**)&pInt);
	if(SUCCEEDED(hr)) {
		aPtr.Attach(pInt,true);
	}
	return hr;
}



const wchar_t* pBaseNtURL = L"WinNT://";


/////////////////////////////////////////////////////////////////////////////
// Function name	: MTUser::MTUser
// Description	    : 
// Return type		: 
/////////////////////////////////////////////////////////////////////////////

MTDomain::MTDomain() : mDomainURL(pBaseNtURL) {}


/////////////////////////////////////////////////////////////////////////////
// Function name	: MTUser::Init
// Description	    : 
// Return type		: bool 
/////////////////////////////////////////////////////////////////////////////

bool MTDomain::Init()
{
	std::wstring aStr;

	// step 1: get the domain name
	if(GetNTDomainName(aStr)) {
		mDomainURL += aStr;

		// step 2: get the interfade
		HRESULT hr = CreateObject<ActiveDs::IADsDomainPtr,ActiveDs::IADsDomain>(mDomain,mDomainURL.c_str(),IID_IADsDomain);
		return SUCCEEDED(hr);
	}

	return S_OK;
}

void MTDomain::GetDomainName(std::string& aStr)
{ 
	aStr = ascii(mDomainURL);
}

/////////////////////////////////////////////////////////////////////////////
// Function name	: MTDomain::IsDomain
// Description	    : 
// Return type		: bool 
/////////////////////////////////////////////////////////////////////////////

bool MTDomain::IsDomain()
{
	return !mDomain->GetIsWorkgroup();
}
