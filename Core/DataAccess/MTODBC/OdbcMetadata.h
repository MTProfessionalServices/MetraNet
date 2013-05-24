// OdbcMetadata.h: interface for the COdbcMetadata class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_ODBCMETADATA_H__34A19399_0A5D_4997_B310_A30363352F4D__INCLUDED_)
#define AFX_ODBCMETADATA_H__34A19399_0A5D_4997_B310_A30363352F4D__INCLUDED_

#include "OdbcColumnMetadata.h"	// Added by ClassView
#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

// TODO: remove undefs
#if defined(MTODBC_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

class COdbcConnection;

class COdbcMetadata  
{
private:
	COdbcColumnMetadataVector mAllColumns;
	COdbcConnection* mConnection;
public:
	DllExport COdbcColumnMetadataVector GetColumnMetadata(const string& schema, const string& table);
	DllExport COdbcMetadata(COdbcConnection* aConnection);
	DllExport virtual ~COdbcMetadata();

};

#endif // !defined(AFX_ODBCMETADATA_H__34A19399_0A5D_4997_B310_A30363352F4D__INCLUDED_)
