// LangDescription.h: interface for the LangDescription class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_LANGDESCRIPTION_H__F197E6F8_E088_11D3_B31F_00C04F465BA9__INCLUDED_)
#define AFX_LANGDESCRIPTION_H__F197E6F8_E088_11D3_B31F_00C04F465BA9__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "metra.h"

#import <MTConfigLib.tlb>
#import <MTNameIDLib.tlb>

using namespace MTConfigLib;
using namespace MTNAMEIDLib;

#import <Rowset.tlb> rename( "EOF", "RowsetEOF" ) 

#include "errobj.h"
#include "mtglobal_msg.h"

#include "NTLogger.h"
#include <loggerconfig.h>


//this is important that the following value is not ""
//since Oracle will return VT_NULL for this, for now
//we will just use a lone space character
//these constants are related to CR4434
#define BLANK_LOCALIZATION " " 
#define BLANK_DESCRIPTION_ID 0


class LangDescription  
{
public:
	LangDescription();
	virtual ~LangDescription();

public:
	BOOL Init();
	long GetLanguageId(BSTR aCountryCode);
	BOOL RemoveDescriptions(BSTR FQN);
	BOOL LoadNameAndValue(BSTR FQN,BSTR value,BSTR CountryCode);
	BOOL LoadSubTable(BSTR aFilename);
	BOOL LoadBlankDescription();

private:
  ROWSETLib::IMTSQLRowsetPtr mpRowset;
	IMTNameIDPtr pNameId;
	NTLogger			mLogger;
};


#endif // !defined(AFX_LANGDESCRIPTION_H__F197E6F8_E088_11D3_B31F_00C04F465BA9__INCLUDED_)
