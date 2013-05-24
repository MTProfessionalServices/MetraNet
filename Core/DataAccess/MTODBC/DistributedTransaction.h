// DistributedTransaction.h: interface for the CDistributedTransaction class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_DISTRIBUTEDTRANSACTION_H__6807FB77_9C9F_4BE8_A210_16215D498CD8__INCLUDED_)
#define AFX_DISTRIBUTEDTRANSACTION_H__6807FB77_9C9F_4BE8_A210_16215D498CD8__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <list>

class COdbcConnection;

#include <transact.h>
#include <xoleHlp.h>

class CDistributedTransaction  
{
public:
	bool FailTransaction();
	bool EndTransaction();
	bool BeginTransaction();
	bool Unsubscribe(COdbcConnection *pConnection);
	bool Subscribe(COdbcConnection* pConnection);
	CDistributedTransaction(bool bUseDTC);
	virtual ~CDistributedTransaction();

private:
	static ITransactionDispenser* GetFactory();
	ITransaction* m_pTransaction;
	std::list<COdbcConnection*> m_lSubscribers;

	bool m_bUseDTC;
};

#endif // !defined(AFX_DISTRIBUTEDTRANSACTION_H__6807FB77_9C9F_4BE8_A210_16215D498CD8__INCLUDED_)
