#ifndef _COLUMNARRAYWRITER_H_
#define _COLUMNARRAYWRITER_H_

class COdbcPreparedArrayStatement;
class COdbcConnection;

class CColumnArrayWriter
{
private:
	int arraySize;
	COdbcPreparedArrayStatement* mStatement;
public:
	bool WriteBatch(int begin, int end);
	int SubmitBatch();
	int Finalize();
	bool Initialize(COdbcConnection* pConnection);
	CColumnArrayWriter(int aArraySize);
	virtual ~CColumnArrayWriter();
};

#endif
