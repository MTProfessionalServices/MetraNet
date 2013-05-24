/**************************************************************************
 * @doc OLEDBContext
 * 
 * @module  Encapsulation for ADO Database Context |
 * 
 * This class encapsulates the ADO database connection.
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Kevin Fitzgerald
 * $Header$
 *
 * @index | OLEDBContext
 ***************************************************************************/

#ifndef __OLEDBContext_H
#define __OLEDBContext_H

#include <DBContext.h>
#include <oledb.h>
#include <vector> // STL

#import <rowsetinterfaceslib.tlb> rename("EOF", "RowsetEOF")

// @class CParameterToStoredProc
class CParameterToStoredProc
{
public:
  CParameterToStoredProc();
  CParameterToStoredProc(const std::wstring &arParamName, 
    const MTParameterType &arType, const MTParameterDirection &arDirection, 
    const _variant_t &arValue, _bstr_t& aDBType);
  virtual ~CParameterToStoredProc();
  BOOL InitParamInfo( DBPARAMBINDINFO * pParamInfo );
  BOOL AppendParamToCommand( std::wstring &arCmd , unsigned long index,
    const std::wstring &arDBType);
  BOOL InitBindingInfo( DBBINDING * pBinding , unsigned long index,
                                             unsigned long * pOffsetBytesValue);
  unsigned long  GetByteAlignedSize( );
  BOOL InitData(unsigned char ** ppBuffer, unsigned long status);  // write INPUT values into param buffer
  BOOL UpdateData(unsigned char ** ppBuffer, _bstr_t& aDBType);  // read OUTPUT values from param buffer
	BOOL GetParamByName( _bstr_t & arParamName, _variant_t &arValue, _bstr_t & aDBType);

//protected:
  unsigned long  GetSize();
  DBTYPE GetDBType();
  MTParameterType GetType() const {return m_arType; } 
  MTParameterDirection GetDirection() const {return m_arDirection; } 
  DBPARAMIO GetParamIO();
  _bstr_t GetName() const {return m_arParamName; }
  _variant_t GetValue() const {return m_arValue; }
protected:
  _bstr_t m_arParamName;
  MTParameterType m_arType;
  MTParameterDirection m_arDirection;
  _variant_t m_arValue;
  unsigned long m_stringlength;
	MTAutoInstance<MTAutoLoggerImpl<szOleDBContextTag,szDbObjectsDir> >	mLogger; 
};

// @class OLEDBContext
class OLEDBContext : public DBContext
{
// @access Public:
public:
  // @cmember Constructor
  DLL_EXPORT OLEDBContext() ;
  // @cmember Destructor
  DLL_EXPORT virtual ~OLEDBContext() ;

  // @cmember Initialize the Database Context
  DLL_EXPORT virtual BOOL Init (const DBInitParameters &arParams) ; 

  // @cmember Connect to the Database
  DLL_EXPORT virtual BOOL Connect() ;
  // @cmember Disconnect from the Database
  DLL_EXPORT virtual BOOL Disconnect() ;
  // @cmember Execute the SQL command 
  DLL_EXPORT virtual BOOL Execute (const std::wstring &arCmd, int aTimeout=DEFAULT_TIMEOUT_VALUE) ;
  // @cmember Execute the SQL command 
  DLL_EXPORT virtual BOOL Execute (const std::wstring &arCmd, DBSQLRowset &arRowset ) ;
  // @cmember Execute the SQL command with a disconnected Recordset
  DLL_EXPORT virtual BOOL ExecuteDisconnected (const std::wstring &arCmd, 
    DBSQLRowset &arRowset, LockTypeEnum lockType=adLockReadOnly) ;
  // @cmember Begin a transaction
  DLL_EXPORT virtual BOOL BeginTransaction() ;
  // @cmember Begin a transaction
  DLL_EXPORT virtual BOOL CommitTransaction() ;
  // @cmember Begin a transaction
  DLL_EXPORT virtual BOOL RollbackTransaction() ;

  // @cmember Initialize a command object to issue a stored procedure
  DLL_EXPORT virtual BOOL InitializeForStoredProc (const std::wstring &arStoredProcName) ;
  // @cmember Add parameter to the stored procedure 
  DLL_EXPORT virtual BOOL AddParameterToStoredProc (const std::wstring &arParamName, 
    const MTParameterType &arType, const MTParameterDirection &arDirection, 
    const _variant_t &arValue) ;
  DLL_EXPORT virtual BOOL AddParameterToStoredProc (const std::wstring &arParamName, 
    const MTParameterType &arType, const MTParameterDirection &arDirection) ;
  // @cmember Execute the stored procedure
  DLL_EXPORT virtual BOOL ExecuteStoredProc() ;
  // @cmember Execute the stored procedure with resulting rowset
  DLL_EXPORT virtual BOOL ExecuteStoredProc(DBSQLRowset &arRowset) ;
  // @cmember Get the specified parameter back from the stored procedure
  DLL_EXPORT virtual BOOL GetParameterFromStoredProc (const std::wstring &arParamName, 
    _variant_t &arValue) ;

  // @cmember Join a Distributed Transaction that someone else Began.
  // This method is specific to OLEDB 
  // Only join if we have no already joined our session to a transaction.
  // A session can be joined to only one transaction.
  DLL_EXPORT BOOL JoinDistributedTransaction(RowSetInterfacesLib::IMTTransactionPtr aTransaction);

// @access Protected:
protected:
  BOOL ExportDistributedTransaction(
                 /*[in]*/ ULONG cbWhereabouts, 
                 /*[in]*/ BYTE * rgbWhereabouts, 
                 /*[out]*/ ULONG * cbCookie,
                 /*[out]*/ BYTE ** rgbCookie);
  

  BOOL InitializeCommand (/*[in]*/ const std::wstring &arCmd, 
                          /*[out]*/ ICommandText **  ppICommandText );

  BOOL InternalExecute (/*[in]*/ const std::wstring &arCmd, 
                        /*[in]*/ int aTimeout,
                        /*[in]*/ ICommandText *  pICommandText,
                        /*[in]*/ _RecordsetPtr &arpRecordset);

  BOOL ImportTransaction(/*[in]*/ const char * strEncodedTransactionCookie);

  BOOL ImportTransaction(/*[in]*/  ULONG   cbTransactionCookie,
                         /*[in]*/  BYTE *  rgbTransactionCookie);

  BOOL JoinDistributedTransaction( );

  HRESULT Rowset2Recordset(IRowset *pRowset,  _RecordsetPtr & pRs);
  HRESULT Recordset2Rowset( _RecordsetPtr & pRs, IRowset **ppRowset);
  void LogErrorList (HRESULT aError, const char *pString, ErrorList &arErrorList);

	DLL_EXPORT virtual std::wstring GetTransactionContext();

// @access Private:
private:
  // @cmember the initialized flag
  BOOL            mInitialized ;
  // @cmember the stored procedure initialized flag
  BOOL            mProcInitialized ;
  IDBInitialize *	    mpIDBInit ;
  IDBCreateSession *  mpIDBCreateSession;
  IDBCreateCommand *  mpICreateCmd;

	BOOL mJoinedDistributed;
  RowSetInterfacesLib::IMTTransactionPtr mDistributedTransaction;

  ITransaction *      mpITransaction ;

  std::wstring mStoredProcName;
	typedef std::vector<CParameterToStoredProc *> STORED_PROC_PARAM_LIST;
	STORED_PROC_PARAM_LIST m_StoredProcParamList;
  inline HRESULT FreeStoredProcParamList();
	MTAutoInstance<MTAutoLoggerImpl<szOleDBContextTag,szDbObjectsDir> >	mLogger; 
	MTAutoInstance<MTAutoLoggerImpl<szQueryLogTag,szQueryLogDir> >	mQueryLog; 
} ;

//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////
inline HRESULT OLEDBContext::FreeStoredProcParamList()
{
	HRESULT hr = S_OK;

  // free memory for each object
  //
  STORED_PROC_PARAM_LIST::iterator iter;
	for (iter = m_StoredProcParamList.begin(); iter != m_StoredProcParamList.end(); iter++)
	{
		delete (*iter);
	}

	// empty the list
	//
	m_StoredProcParamList.clear();

	return hr;
}

// @class OLEDBContext
class CGetWhereAbouts  : public virtual ObjectWithError
{
// @access Public:
public:
  // @cmember Constructor
  DLL_EXPORT CGetWhereAbouts() ;
  // @cmember Destructor
  DLL_EXPORT virtual ~CGetWhereAbouts();

  // @cmember Get the WhereAbouts info needed to call
  // This gets the whereabouts and then 
  // encodes the WhereAbouts binary cookie into a string.
  // This method is specific to OLEDB 
  DLL_EXPORT BOOL GetEncodedWhereAboutsDistributedTransaction(
                 /*[out]*/  _bstr_t * strWhereAbouts );

// @access Protected:
protected:
  // @cmember Get the WhereAbouts info needed to call
  // ExportDistributedTransaction.
  // This method is specific to OLEDB 
  BOOL GetWhereAboutsDistributedTransaction(
                 /*[out]*/ ULONG * cbWhereAbouts,
                 /*[out]*/ BYTE ** rgbWhereAbouts  );


  // @cmember the logging object 
	MTAutoInstance<MTAutoLoggerImpl<szGetWhereAboutsTag,szDbObjectsDir> >	mLogger; 
  unsigned long     m_lWhereAboutsSize;
  BYTE *            m_pWhereAboutsBinary;
  _bstr_t         m_strCookie;
};


#endif // __OLEDBContext_H

