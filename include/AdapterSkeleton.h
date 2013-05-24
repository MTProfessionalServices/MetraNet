#ifndef __ADAPTERSKELETON_H__
#define __ADAPTERSKELETON_H__
#pragma once

#define MT_SUPPORT_IDispatch
#include <MTDataExporter.h>
#include <MTDataExporter_i.c>
#include <IMTDataExporter_i.c>
#include <ComSkeleton.h>
#include <comdef.h>

template <class T, const CLSID* pclsid,
	class ThreadModel = CComMultiThreadModel>
class ATL_NO_VTABLE MTAdapterSkeleton : 
  public MTImplementedInterface<T,IMTDataExporter,pclsid,&IID_IMTDataExporter,&LIBID_MTDATAEXPORTERLib,ThreadModel>
{
public:

	// these should be redifined
	STDMETHOD(Initialize)(BSTR aConfigFilename) { return S_OK; }
	STDMETHOD(ExportComplete)() { return S_OK; }
};




#endif //__ADAPTERSKELETON_H__
