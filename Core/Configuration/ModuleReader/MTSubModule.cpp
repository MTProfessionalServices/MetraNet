// MTSubModule.cpp : Implementation of CMTSubModule
#include "StdAfx.h"
#include <mtmodulereader.h>
#include "MTModule.h"
#include "MTSubModule.h"

#pragma warning(disable: 4297)  // disable warning "function assumed not to throw an exception but does"

/////////////////////////////////////////////////////////////////////////////
// CMTSubModule

// constants
const bstr_t SubDirName = L"SubDir";

STDMETHODIMP CMTModuleDescriptor::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTModuleDescriptor,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


STDMETHODIMP CMTModuleDescriptor::IsSubDir(VARIANT_BOOL * pBool)
{
  ASSERT(pBool);
  if(!pBool) return E_FAIL;
  if(mOrgType == SubDirName) 
    *pBool = VARIANT_TRUE;
  else *pBool = VARIANT_FALSE;
	return S_OK;
}

STDMETHODIMP CMTModuleDescriptor::get_Name(BSTR * pVal)
{
  ASSERT(pVal);
  if(!pVal) return E_POINTER;
  *pVal = mName.copy();
	return S_OK;
}

STDMETHODIMP CMTModuleDescriptor::put_Name(BSTR newVal)
{
  if(newVal == _bstr_t(""))
    return E_FAIL;
  mName = newVal;
	return S_OK;
}

STDMETHODIMP CMTModuleDescriptor::get_OrgType(BSTR * pVal)
{
  ASSERT(pVal);
  if(!pVal) return E_FAIL;
  *pVal = mOrgType.copy();
	return S_OK;
}

STDMETHODIMP CMTModuleDescriptor::put_OrgType(BSTR newVal)
{
  if(newVal == _bstr_t(""))
    return E_FAIL;
  mOrgType = newVal;
	return S_OK;
}

STDMETHODIMP CMTModuleDescriptor::get_ModConfigInfo(IMTModule** pVal)
{
  ASSERT(pVal);
  if(!pVal) return E_FAIL;

  if(mModPtr.GetInterfacePtr() == NULL) throw _com_error(E_FAIL);
	*pVal = (IMTModule*)mModPtr.GetInterfacePtr();
	(*pVal)->AddRef();

	return S_OK;
}

STDMETHODIMP CMTModuleDescriptor::put_ModConfigInfo(IMTModule* newVal)
{
  if(newVal == NULL) {
    mModPtr = NULL;
  }
  else {
    mModPtr = (MODULEREADERLib::IMTModule*)newVal;
  }
	return S_OK;
}
