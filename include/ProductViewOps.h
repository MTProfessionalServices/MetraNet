#ifndef __PRODUCTVIEWOPS_H__
#define __PRODUCTVIEWOPS_H__
#import <rowsetinterfaceslib.tlb> rename ("EOF", "RowsetEOF")  no_function_mapping

#include <errobj.h>

class ProductViewOps : public ObjectWithError
{
public:
	ProductViewOps();
	bool Initialize();
	bool DropTable(const wchar_t* pTable);
	bool AddTable(const wchar_t* pTable);

protected:
	bool PerformAction(bool bDropTable,const wchar_t* pTableName);

protected:
  RowSetInterfacesLib::IMTSQLRowsetPtr mRS;
};


#endif //__PRODUCTVIEWOPS_H__