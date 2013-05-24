#ifndef _ODBCDBCONTEXT_H_
#define _ODBCDBCONTEXT_H_

#include <string>
using namespace std;

#include <metra.h>
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF")

//OBSOLETE NOW - REMOVE COdbcDbContext!!
// Context shared among all odbc util classes.
// Allows using common connections and transactions per SessionSet write.
// Context is owned by COdbcSessionManager and referenced by all
// classes owned by COdbcSessionManager.
class COdbcDbContext
{
private:

public:
	COdbcDbContext();
	~COdbcDbContext();

};

#endif

