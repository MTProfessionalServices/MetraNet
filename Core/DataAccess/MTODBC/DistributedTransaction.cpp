// DistributedTransaction.cpp: implementation of the CDistributedTransaction class.
//
//////////////////////////////////////////////////////////////////////

//#include "StdAfx.h"
//#include "bcp.h"
#include <metra.h>
#include "DistributedTransaction.h"

#include "OdbcConnection.h"
#include "OdbcException.h"

/*
#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif
*/

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CDistributedTransaction::CDistributedTransaction(bool bUseDTC)
{
	m_bUseDTC = bUseDTC;
}

CDistributedTransaction::~CDistributedTransaction()
{

}

bool CDistributedTransaction::Subscribe(COdbcConnection *pConnection)
{
	m_lSubscribers.push_back(pConnection);
	return TRUE;
}

bool CDistributedTransaction::Unsubscribe(COdbcConnection *pConnection)
{
	m_lSubscribers.remove(pConnection);
	return TRUE;
}

bool CDistributedTransaction::BeginTransaction()
{
	HRESULT hr;
	//ITransactionDispenser* pTransactionDispenser;
	//ITransaction* pTransaction;
	if(m_bUseDTC)
	{
		//hr = ::DtcGetTransactionManager(0, 0, IID_ITransactionDispenser, 0, 0, 0,(void **)&m_pTransactionDispenser);
		//hr = m_pTransactionDispenser->BeginTransaction(
		hr = GetFactory()->BeginTransaction(
			NULL,                                  // [in] IUnknown __RPC_FAR *punkOuter,
		  ISOLATIONLEVEL_READCOMMITTED,          // [in] ISOLEVEL isoLevel,
			ISOFLAG_RETAIN_DONTCARE,               // [in] ULONG isoFlags,
			NULL,                                  // [in] ITransactionOptions  *pOptions,
			&m_pTransaction                        // [out] ITransaction__RPC_FAR
			//        *__RPC_FAR *ppTransaction
			) ;

		if (!SUCCEEDED(hr)) throw COdbcException("Failed to begin distributed transaction");

		// Have all subscribers join the new transaction
		std::list<COdbcConnection*>::iterator it = m_lSubscribers.begin();
		while(it != m_lSubscribers.end())
		{
			(*it++)->JoinTransaction(m_pTransaction);
		}
		
	} else {
	}
	return TRUE;
}

bool CDistributedTransaction::EndTransaction()
{
	if(m_bUseDTC)
	{
		m_pTransaction->Commit(FALSE,XACTTC_SYNC_PHASEONE,0);
		// Have all subscribers join the new transaction
		std::list<COdbcConnection*>::iterator it = m_lSubscribers.begin();
		while(it != m_lSubscribers.end())
		{
			(*it++)->LeaveTransaction();
		}
		m_pTransaction->Release();
		m_pTransaction = NULL;
	} else {
		std::list<COdbcConnection*>::iterator it = m_lSubscribers.begin();
		while (it != m_lSubscribers.end())
		{
			SQLRETURN sqlReturn = ::SQLEndTran(SQL_HANDLE_DBC, (*it++)->GetHandle(), SQL_COMMIT);
		}
	}
	return TRUE;
}

ITransactionDispenser* CDistributedTransaction::GetFactory()
{
	static ITransactionDispenser* pTransactionDispenser=NULL;
	if(pTransactionDispenser == NULL)
	{
		HRESULT hr;
		hr = ::DtcGetTransactionManagerEx(0, 0, IID_ITransactionDispenser, 
			0, 0,(void **)&pTransactionDispenser);
		ASSERT(SUCCEEDED(hr));
	}
	return pTransactionDispenser;
}

bool CDistributedTransaction::FailTransaction()
{
	if(m_bUseDTC)
	{
		m_pTransaction->Abort(NULL,FALSE,FALSE);
		// Have all subscribers join the new transaction
		std::list<COdbcConnection*>::iterator it = m_lSubscribers.begin();
		while(it != m_lSubscribers.end())
		{
			(*it++)->LeaveTransaction();
		}
		m_pTransaction->Release();
		m_pTransaction = NULL;
	} else {
		std::list<COdbcConnection*>::iterator it = m_lSubscribers.begin();
		while (it != m_lSubscribers.end())
		{
			SQLRETURN sqlReturn = ::SQLEndTran(SQL_HANDLE_DBC, (*it++)->GetHandle(), SQL_ROLLBACK);
		}
	}
	return TRUE;
}
