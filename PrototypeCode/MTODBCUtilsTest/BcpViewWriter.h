// BcpViewWriter.h: interface for the CBcpViewWriter class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_BCPVIEWWRITER_H__FEC9BDF0_02FC_412F_9D68_BCFCB411446A__INCLUDED_)
#define AFX_BCPVIEWWRITER_H__FEC9BDF0_02FC_412F_9D68_BCFCB411446A__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <sql.h>
#include <sqlext.h>
#include <sqltypes.h>
#include <odbcss.h>

class COdbcPreparedBcpStatement;
class COdbcConnection;

class CBcpViewWriter  
{
private:
	DBINT numRows;
	COdbcPreparedBcpStatement* mStatement;

public:
	int WriteBatch(int begin, int end);
	int Finalize();
	BOOL Initialize(COdbcConnection* pConnection);
	CBcpViewWriter();
	virtual ~CBcpViewWriter();

};

#endif // !defined(AFX_BCPVIEWWRITER_H__FEC9BDF0_02FC_412F_9D68_BCFCB411446A__INCLUDED_)
