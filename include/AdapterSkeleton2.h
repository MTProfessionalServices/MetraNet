#ifndef __ADAPTERSKELETON2_H__
#define __ADAPTERSKELETON2_H__
#pragma once

#define MT_SUPPORT_IDispatch
#include <MTDataExporter.h>
#include <MTDataExporter_i.c>
#include <IMTDataExporter_i.c>
#include <ComSkeleton.h>
#include <comdef.h>

template <class T, const CLSID* pclsid,
	class ThreadModel = CComMultiThreadModel>
class ATL_NO_VTABLE MTAdapterSkeleton2 : 
  public MTImplementedInterface<T,IMTDataExporter2,pclsid,&IID_IMTDataExporter2,&LIBID_MTDATAEXPORTERLib,ThreadModel>
  
{
public:
	BEGIN_COM_MAP(T)
  MT_INTERFACE_ENTRY(&IID_IMTDataExporter2,IMTDataExporter2)
	#ifdef MT_SUPPORT_IDispatch
	COM_INTERFACE_ENTRY(IDispatch)
	#endif
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	END_COM_MAP()

	// these should be redifined
	STDMETHOD(Initialize)(BSTR aConfigFilename) { return S_OK; }
	STDMETHOD(ExportComplete)() { return S_OK; }
	STDMETHOD(Execute)(long aIntervalID){ return S_OK; }
  STDMETHOD(get_PerInterval)(VARIANT_BOOL* pVal)
  { 
  	(*pVal) = VARIANT_TRUE;
  	return S_OK; 
  }
  STDMETHOD(ExportData)(LPDISPATCH pDispatch){ return E_FAIL; }
  
};




#endif //__ADAPTERSKELETON_H__
