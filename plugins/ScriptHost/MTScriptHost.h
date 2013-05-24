/******************************************************************************
 * @doc MTScriptHost
 *
 * Copyright 1998 by MetraTech Corporation
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
 ****************************************************************************
 *   File:   MTScriptHost.h
 *
 *   Date:   September 14, 1998
 *
 *   Description:   This file contains the declaration of a generic class that
 *               implements the IDispatch interface, which allows the 
 *               methods of this class to be called by anyone who understands
 *               the IDispatch interface.
 *
 *
 * Modification History:
 *		Chen He - September 14, 1998 : Initial version
 *
 * $Header$
******************************************************************************/
#ifndef MTSCRIPT_HOST_H
#define MTSCRIPT_HOST_H

#include "ScriptHost.h"

#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping

#include "metra.h"
#include "NTLogger.h"
#include <loggerconfig.h>

class CMTScriptHost : public IMTObject, 
											public IProvideMultipleClassInfo, 
											public IConnectionPointContainer, 
											public IConnectionPoint
{
protected:
  int					mRefCount;
  ITypeInfo*	mpTypeInfo;
  IMTEvents*	mpTheConnection;

public:
  //Constructor
  CMTScriptHost();

  //Destructor
  ~CMTScriptHost();

  void OnFireEvent();
  HRESULT Configure(MTPipelineLib::IMTConfigPropSetPtr apPropSet);
  HRESULT ProcessSession(MTPipelineLib::IMTSessionPtr apSession);
  HRESULT ProcessSessionSet(MTPipelineLib::IMTSessionSetPtr apSessionSet);

  /***** Type Library Methods *****/
  STDMETHODIMP LoadTypeInfo(ITypeInfo** pptinfo, REFCLSID clsid, LCID lcid);

  /***** IUnknown Methods *****/
  STDMETHODIMP QueryInterface(REFIID riid, void**ppvObj);
  STDMETHODIMP_(ULONG) AddRef();
  STDMETHODIMP_(ULONG) Release();
 
  /***** IDispatch Methods *****/
  STDMETHODIMP GetTypeInfoCount(UINT* iTInfo);
  STDMETHODIMP GetTypeInfo(UINT iTInfo, LCID lcid, ITypeInfo** ppTInfo);

  STDMETHODIMP GetIDsOfNames(REFIID riid, OLECHAR** rgszNames,
														UINT cNames, LCID lcid, DISPID* rgDispId);

  STDMETHODIMP Invoke(DISPID dispIdMember, REFIID riid, LCID lcid,  
											WORD wFlags, DISPPARAMS* pDispParams, 
											VARIANT* pVarResult, EXCEPINFO* pExcepInfo,  
											UINT* puArgErr);

  /***** IProvideClassInfo Methods *****/
  STDMETHODIMP GetClassInfo( ITypeInfo** ppTI );

  /***** IProvideClassInfo2 Methods *****/
  STDMETHODIMP GetGUID( DWORD dwGuidKind, GUID* pGUID);

  /***** IProvideMultipleClassInfo Methods *****/
  STDMETHODIMP GetMultiTypeInfoCount( ULONG* pcti);
  STDMETHODIMP GetInfoOfIndex(ULONG iti, DWORD dwMCIFlags, 
															ITypeInfo **pptiCoClass, DWORD *pdwTIFlags, 
															ULONG *pcdispidReserved, IID *piidPrimary, 
															IID *piidSource);

  /***** IConnectionPointContainer Methods *****/
  STDMETHODIMP EnumConnectionPoints( IEnumConnectionPoints **ppEnum);
  STDMETHODIMP FindConnectionPoint( REFIID riid, IConnectionPoint **ppCP);

  /***** IConnectionPoint Methods *****/
  STDMETHODIMP GetConnectionInterface( IID *pIID);
  STDMETHODIMP GetConnectionPointContainer( IConnectionPointContainer **ppCPC);
  STDMETHODIMP Advise( IUnknown* pUnk, DWORD *pdwCookie);
  STDMETHODIMP Unadvise( DWORD dwCookie);
  STDMETHODIMP EnumConnections( IEnumConnections** ppEnum);

  /***** IMTObject Methods *****/
	void SaySomething(BSTR bstrSomething);
	HRESULT CreateObject(BSTR bstrProgId, LPDISPATCH *pDisp);

private:
	// member variables
	NTLogger						mLogger;

};
#endif
