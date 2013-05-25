	/**************************************************************************
 * @doc MTCONFIGFILELIST
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

// MTConfigFileList.h : Declaration of the CMTConfigFileList

#ifndef __MTCONFIGFILELIST_H_
#define __MTCONFIGFILELIST_H_

#include "metra.h"
#include "resource.h"       // main symbols

#include <MTConfigFileList.h>
#include "MTConfigFileImpl.h"
#include "NTLogger.h"

#include <vector>
using std::vector;

/////////////////////////////////////////////////////////////////////////////


// CMTConfigFileList
class ATL_NO_VTABLE CMTConfigFileList : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTConfigFileList, &CLSID_MTConfigFileList>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTConfigFileList, &IID_IMTConfigFileList, &LIBID_MTConfigLOADERLib>
{
public:
	CMTConfigFileList();
	~CMTConfigFileList();

DECLARE_REGISTRY_RESOURCEID(IDR_MTCONFIGFILELIST)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTConfigFileList)
	COM_INTERFACE_ENTRY(IMTConfigFileList)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTConfigFileList
public:
	STDMETHOD(RemoveItem)(/*[in]*/long aIndex);
	STDMETHOD(get_EffectConfig)(/*[in]*/long aCurDate, 
		/*[out, retval]*/ ::IMTConfigPropSet* * apVal);
	STDMETHOD(CalculateEffDate)();
	STDMETHOD(AddCFile)(/*[in]*/ ::IMTConfigPropSet* apMainVal, 
											/*[in]*/ ::IMTConfigPropSet* apVal, 
											/*[in]*/ long aEffDate, 
											/*[in]*/ long aLingerDate, 
											/*[in]*/ BSTR aFilename);
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *apVal);
	STDMETHOD(get_Item)(/*[in]*/ long aIndex, /*[out, retval]*/ VARIANT *apVal);
	STDMETHOD(get_Count)(/*[out, retval]*/ long *apVal);

	STDMETHOD(put_Count)(/*[in]*/ long aNewVal);

private:
	void LogConfigFilename(const string & aFilename);
	void ParseFilename(const string & aFilename, string & aNameString, long* aVersion);
	
	vector<CComVariant> mConfigFileList;
	
	long				mSize;

	NTLogger		mAuditLogger;
};

// DEREK CHANGE
inline bool operator ==(const CComVariant & arVar1, const CComVariant & arVar2)
{
	ASSERT(0);
	return FALSE;
}

#endif //__MTCONFIGFILELIST_H_
