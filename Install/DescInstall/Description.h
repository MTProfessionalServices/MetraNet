// Description.h: interface for the Description class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_DESCRIPTION_H__F197E6F7_E088_11D3_B31F_00C04F465BA9__INCLUDED_)
#define AFX_DESCRIPTION_H__F197E6F7_E088_11D3_B31F_00C04F465BA9__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "LangDescription.h"

class Description  
{
public:
	Description();
	virtual ~Description();

	BOOL Init();
	BOOL TruncateDescriptionTable();
	BOOL LoadDescription();

private:
	IMTConfigPtr mpConfig;
	ROWSETLib::IMTSQLRowsetPtr mpRowset;

	NTLogger			mLogger;
};

#endif // !defined(AFX_DESCRIPTION_H__F197E6F7_E088_11D3_B31F_00C04F465BA9__INCLUDED_)
