/**************************************************************************
 * @doc MTCONFIGFILE
 *
 * Copyright 1999 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Chen He
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

	
// MTConfigFile.h : Declaration of the CMTConfigFile

#ifndef __MTCONFIGFILE_H_
#define __MTCONFIGFILE_H_

#import <MTConfigLib.tlb> 
#include <MTConfigFile.h>
#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTConfigFile
class ATL_NO_VTABLE CMTConfigFile : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTConfigFile, &CLSID_MTConfigFile>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTConfigFile, &IID_IMTConfigFile, &LIBID_MTConfigLOADERLib>
{
public:
	CMTConfigFile();

	~CMTConfigFile();

DECLARE_REGISTRY_RESOURCEID(IDR_MTCONFIGFILE)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTConfigFile)
	COM_INTERFACE_ENTRY(IMTConfigFile)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTConfigFile
public:
	STDMETHOD(get_MainConfigData)(/*[out, retval]*/ ::IMTConfigPropSet* *apVal);
	STDMETHOD(put_MainConfigData)(/*[in]*/ ::IMTConfigPropSet* newVal);

	STDMETHOD(get_LingerDate)(/*[out, retval]*/ long *apVal);
	STDMETHOD(put_LingerDate)(/*[in]*/ long aNewVal);

	STDMETHOD(get_DismissDate)(/*[out, retval]*/ long *apVal);
	STDMETHOD(put_DismissDate)(/*[in]*/ long aNewVal);

	STDMETHOD(get_ExpireDate)(/*[out, retval]*/ long *apVal);
	STDMETHOD(put_ExpireDate)(/*[in]*/ long aNewVal);

	STDMETHOD(get_EffectDate)(/*[out, retval]*/ long *apVal);
	STDMETHOD(put_EffectDate)(/*[in]*/ long aNewVal);

	STDMETHOD(get_ConfigData)(/*[out, retval]*/ ::IMTConfigPropSet* *apVal);
	STDMETHOD(put_ConfigData)(/*[in]*/ ::IMTConfigPropSet* aNewVal);

	STDMETHOD(get_ConfigFilename)(/*[out, retval]*/ BSTR* apFilename);
	STDMETHOD(put_ConfigFilename)(/*[in]*/ BSTR aFilename);

	STDMETHOD(get_EffectDateAsVbDate)(/*[out, retval]*/ VARIANT* vtDate);
	STDMETHOD(get_ExpireDateAsVbDate)(/*[out, retval]*/ VARIANT* vtDate);
	STDMETHOD(get_DismissDateAsVbDate)(/*[out, retval]*/ VARIANT* vtDate);
	STDMETHOD(get_LingerDateAsVbDate)(/*[out, retval]*/ VARIANT* vtDate);


private:
	long mLingerDate;

	// Config data pointer
	MTConfigLib::IMTConfigPropSetPtr mConfigData;

	// Config data pointer
	MTConfigLib::IMTConfigPropSetPtr mMainConfigData;

	// dismiss date
	long mDismissDate;

	// expiration date
	long mExpireDate;

	// effective date
	long mEffectDate;

	// filename
	_bstr_t	mFilename;
};

#endif //__MTCONFIGFILE_H_
