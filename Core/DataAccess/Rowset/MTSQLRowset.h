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
* $Header: C:\builds\v3.5\development\Core\DataAccess\Rowset\MTSQLRowset.h, 26, 7/9/2002 3:56:58 PM, Alon Becker$
* 
***************************************************************************/
	
// MTSQLRowset.h : Declaration of the CMTSQLRowset

#ifndef __MTSQLROWSET_H_
#define __MTSQLROWSET_H_

#include "resource.h"       // main symbols
#include <DBAccess.h>
#include <RowSetExecute.h>


/////////////////////////////////////////////////////////////////////////////
// CMTSQLRowset
class ATL_NO_VTABLE CMTSQLRowset : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public ISupportErrorInfo,
	public MTRowSetExecute<IMTSQLRowset,CMTSQLRowset,&CLSID_MTSQLRowset,&IID_IMTSQLRowset, &LIBID_ROWSETLib>
{
public:
	CMTSQLRowset() ;
  virtual ~CMTSQLRowset() ;

DECLARE_REGISTRY_RESOURCEID(IDR_MTSQLROWSET)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTSQLRowset)
	COM_INTERFACE_ENTRY(IMTSQLRowset)
	COM_INTERFACE_ENTRY(IMTRowSet)
	COM_INTERFACE_ENTRY(IMTRowSetExecute)
	COM_INTERFACE_ENTRY2(IDispatch,IMTSQLRowset)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, mpUnkMarshaler.p)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTSQLRowset
public:
// ----------------------------------------------------------------
// The Init method initializes the rowset with the configuration path passed.
// ----------------------------------------------------------------
	STDMETHOD(Init)(/*[in]*/ BSTR apConfigPath);

// ----------------------------------------------------------------
// The InitDisconnected method
// ----------------------------------------------------------------
	STDMETHOD(InitDisconnected)();

// ----------------------------------------------------------------
// The OpenDisconnected
// ----------------------------------------------------------------
	STDMETHOD(OpenDisconnected)();

// The Execute method executes the current query.
// WARNING: despite its name, this uses disconnected recordsets
// see ExecuteConnected instead.
// ----------------------------------------------------------------
	STDMETHOD(Execute)();

// ----------------------------------------------------------------
// Execute and disconnect rowset
// ----------------------------------------------------------------
  STDMETHOD(ExecuteDisconnected)();
// ----------------------------------------------------------------
// The GetDBType gets the database type.
// ----------------------------------------------------------------
  STDMETHOD(GetDBType)(/*[out,retval]*/ BSTR *apDBType);
// ----------------------------------------------------------------
// The GetParameterFromStoredProc gets an output parameter from a stored procedure.
// ----------------------------------------------------------------
  STDMETHOD(GetParameterFromStoredProc)(/*[in]*/ BSTR apParamName, VARIANT *apValue);
// ----------------------------------------------------------------
// The ExecuteStoredProc executes the stored procedure.
// ----------------------------------------------------------------
  STDMETHOD(ExecuteStoredProc)();
// ----------------------------------------------------------------
// The AddInputToStoredProc adds an input parameter to a stored procedure.
// ----------------------------------------------------------------
  STDMETHOD(AddInputParameterToStoredProc)(/*[in]*/ BSTR apParamName, long aType, long aDirection, VARIANT aValue);
// ----------------------------------------------------------------
// The AddOutputToStoredProc adds an output parameter to a stored procedure.
// ----------------------------------------------------------------
  STDMETHOD(AddOutputParameterToStoredProc)(/*[in]*/ BSTR apParamName, long aType, long aDirection);
// ----------------------------------------------------------------
// The InitializeForStoredProc method initializes the object for a stored procedure.
// ----------------------------------------------------------------
  STDMETHOD(InitializeForStoredProc)(/*[in]*/ BSTR apStoredProcName);
// ----------------------------------------------------------------
// The UpdateConfigPath updates the config path to use for queries.
// ----------------------------------------------------------------
  STDMETHOD(UpdateConfigPath)(/*[in]*/ BSTR apConfigPath);
// ----------------------------------------------------------------
// The RollbackTransaction method rolls back a local transaction.
// ----------------------------------------------------------------
	STDMETHOD(RollbackTransaction)();
// ----------------------------------------------------------------
// The CommitTransaction method commits a local transaction.
// ----------------------------------------------------------------
	STDMETHOD(CommitTransaction)();
// ----------------------------------------------------------------
// The BeginTransaction method begins a local transaction.
// ----------------------------------------------------------------
	STDMETHOD(BeginTransaction)();
// ----------------------------------------------------------------
// The JoinDistributedTransaction method joins a distributed transaction.
// ----------------------------------------------------------------
	STDMETHOD(JoinDistributedTransaction)(/*[in]*/ IMTTransaction * apTransaction);
// ----------------------------------------------------------------
// The GetDistributedTransaction method joins a distributed transaction.
// ----------------------------------------------------------------
	STDMETHOD(GetDistributedTransaction)(/*[out, retval]*/ IMTTransaction * * apTransaction);

// ----------------------------------------------------------------
// The AddRow method adds a row to the rowset.
// ----------------------------------------------------------------
	STDMETHOD(AddRow)();
// ----------------------------------------------------------------
// The AddColumnData adds the data in the specified column.
// ----------------------------------------------------------------
	STDMETHOD(AddColumnData)(/*[in]*/ BSTR apName, /*[in]*/ VARIANT aValue);
// ----------------------------------------------------------------
// The ModifyColumnData modifies the data in the specified column.
// ----------------------------------------------------------------
	STDMETHOD(ModifyColumnData)(/*[in]*/ BSTR apName, /*[in]*/ VARIANT aValue);
// ----------------------------------------------------------------
// The AddColumnDefinition method adds a new column to the rowset definition.
// ----------------------------------------------------------------
	STDMETHOD(AddColumnDefinition)(/*[in]*/ BSTR apName, /*[in]*/ BSTR apType, int aLen);
  
	STDMETHOD(AddColumnDefinitionByType)(BSTR apName,long apType,int aLen);

// Save the record set to a file as XML
	STDMETHOD(SaveToFile)(BSTR aFileName,VARIANT StyleSheet);

// Save the record set to an XML string, optionally transforming it using a style sheet (passed in as IXMLDOMNode*)
  STDMETHOD(SaveToXml)(VARIANT apStyleSheetNode, BSTR* apXmlString);

// Executes the query using a connected recordset
	STDMETHOD(ExecuteConnected)();
// ----------------------------------------------------------------
// Changes DB catalog for current connection
// ----------------------------------------------------------------
	STDMETHOD(ChangeDbName)(/*[in]*/ BSTR newDbName);
// ----------------------------------------------------------------
// Constructars
// ----------------------------------------------------------------
	HRESULT FinalConstruct();
 
	void FinalRelease();
	

  // this method is here only to force a dependency on RSParameterDirection 
  // and RSParameterType.
  // Otherwise the enum is ignored when using #import on the tlb
  STDMETHOD(larry)(RSParameterDirection mo, RSParameterType curly)
  {
    return E_NOTIMPL;
  };


private:
  DBAccess                mDBAccess ;
	MTAutoInstance<MTAutoLoggerImpl<szMTSqlRowSetTag,szDbObjectsDir> >	mLogger;
	CComPtr<IUnknown> mpUnkMarshaler;

    BSTR mStoredProcName;
};

#endif //__MTSQLROWSET_H_
