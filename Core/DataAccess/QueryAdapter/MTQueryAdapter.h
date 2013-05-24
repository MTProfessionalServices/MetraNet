/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by: 
* $Header$
* 
***************************************************************************/
	
// MTQueryAdapter.h : Declaration of the CMTQueryAdapter

#ifndef __MTQUERYADAPTER_H_
#define __MTQUERYADAPTER_H_

#include "resource.h"       // main symbols
#include <NTLogger.h>
#include <autologger.h>
#include <DbObjectsLogging.h>

#pragma warning(disable: 4278)  // disable warning..identifier in type library 'QueryAdapter.tlb' is already a macro;

// import the queryadapter dll ...
#import "QueryAdapter.tlb"


#import <mscorlib.tlb> rename ("ReportEvent", "ReportEventX") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.DataAccess.Hinter.tlb> inject_statement("using namespace mscorlib;")
#import <MetraTech.DataAccess.QueryManagement.tlb> inject_statement("using namespace mscorlib;")

/////////////////////////////////////////////////////////////////////////////
// CMTQueryAdapter
class ATL_NO_VTABLE CMTQueryAdapter : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTQueryAdapter, &CLSID_MTQueryAdapter>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTQueryAdapter, &IID_IMTQueryAdapter, &LIBID_QUERYADAPTERLib>,
  public virtual ObjectWithError
{
public:
	CMTQueryAdapter() ;
  virtual ~CMTQueryAdapter() ;
  

DECLARE_REGISTRY_RESOURCEID(IDR_MTQUERYADAPTER)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTQueryAdapter)
	COM_INTERFACE_ENTRY(IMTQueryAdapter)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTQueryAdapter
public:
  // Description: The GetDataSource method gets the datasource from the dbaccess.xml file.
  STDMETHOD(GetDataSource)(/*[out,retval]*/ BSTR *apDataSource);
  // Description: The GetTimeout method gets the timeout value from the dbaccess.xml file.
  STDMETHOD(GetTimeout)(/*[out,retval]*/ long *apTimeout);
  // Description: The GetAccessType method gets the database access type from the dbaccess.xml file.
  STDMETHOD(GetAccessType)(/*[out,retval]*/ BSTR *apAccessType);
  // Description: The GetDBType method gets the database type from the dbaccess.xml file.
  STDMETHOD(GetDBType)(/*[out,retval]*/ BSTR *apDBType);
  // Description: The GetProvider method gets the provider from the dbaccess.xml file.
  STDMETHOD(GetProvider)(/*[out,retval]*/ BSTR *apProvider);
  // Description: The GetLogicalServerName method gets the logical server name from the dbaccess.xml file.
	STDMETHOD(GetLogicalServerName)(/*[out,retval]*/ BSTR *apServerName);
  // Description: The GetServerName method gets the server name from the dbaccess.xml file.
	STDMETHOD(GetServerName)(/*[out,retval]*/ BSTR *apServerName);
  // Description: The GetDBName method gets the database name from the dbaccess.xml file.
	STDMETHOD(GetDBName)(/*[out,retval]*/ BSTR *apDBName);
  // Description: The GetPassword method gets the database password from the dbaccess.xml file.
	STDMETHOD(GetPassword)(/*[out,retval]*/ BSTR *apPassword);
  // Description: The GetUserName method gets the database username from the dbaccess.xml file.
	STDMETHOD(GetUserName)(/*[out,retval]*/ BSTR *apUserName);
// Description: The GetQuery method gets the generated query string.
	STDMETHOD(GetQuery)(/*[out,retval]*/ BSTR *apQuery);
// Description: The AddParam method adds a parameter to the currently set query tag.
	STDMETHOD(AddParam)(/*[in]*/ BSTR apParamTag, /*[in]*/ VARIANT aParam, 
    VARIANT aDontValidateString);
// Description: The ClearQuery method clears the query tag.
	STDMETHOD(ClearQuery)();
// Description: The SetQueryTag method sets the query tag to use for query generation
	STDMETHOD(SetQueryTag)(/*[in]*/ BSTR apQueryTag);
  // Description: The Init method initializes the query adapter with the relative configuration path to the query file.
	STDMETHOD(Init)(/*[in]*/ BSTR apConfigPath);
	STDMETHOD(SetRawSQLQuery)(/* [in] */ BSTR apQuery);
  STDMETHOD(GetDBDriver)(/*[out,retval]*/ BSTR *apDBDriver);

	STDMETHOD(GetRawSQLQuery)(VARIANT_BOOL FillInSystemDefaults, /*[out,retval]*/ BSTR * apQuery);

	STDMETHOD(GetHinter)(/*[out,retval]*/ IDispatch** apHinter);
	STDMETHOD(GetQueryTag)(/*[out,retval]*/ BSTR * apQueryTag);
	
  STDMETHOD(IsOracle)(/*[out,retval]*/ VARIANT_BOOL * isOracle);
  STDMETHOD(IsSqlServer)(/*[out,retval]*/ VARIANT_BOOL * isSqlServer);
	STDMETHOD(GetSchemaDots)(/*[out,retval]*/ BSTR * apSchemaDots);

	STDMETHOD(AddParamIfFound)(/*[in]*/ BSTR apParamTag, /*[in]*/ VARIANT aParam, 
    VARIANT aDontValidateString, VARIANT_BOOL* apFound);

private:
	MTAutoInstance<MTAutoLoggerImpl<szQueryAdapterTag,szDbObjectsDir> >	mLogger; 
	MTAutoInstance<MTAutoLoggerImpl<szQueryLogTag,szQueryLogDir> >	mQueryLog; 
	bool AddParamInternal(BSTR apParamTag, VARIANT aParam, VARIANT aDontValidateString);
	HRESULT ApplySystemParameters();


  _bstr_t                         mConfigPath ;
  _bstr_t                         mQueryTag ;
  wstring                         mQueryStr ;
  QUERYADAPTERLib::IMTQueryCachePtr mpQueryCache ;
	BOOL														mDBTypeIsOracle ;
	BOOL														mDBTypeIsSqlServer ;
	_bstr_t mNetMeterDBName;
	_bstr_t mNetMeterStageDBName;
};

#endif //__MTQUERYADAPTER_H_
