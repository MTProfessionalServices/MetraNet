#ifndef __LCHECK_H_
#define __LCHECK_H_

#include <iostream>
#include <fstream>

#include <metra.h>
#include <mtprogids.h>
#include <mtcom.h>

#import <MTLocaleConfig.tlb>
#import <MTConfigLib.tlb>

#include <vector>
using namespace std;

ComInitialize gComInitialize;

typedef vector<_bstr_t> FQNCollection;

class MTLocalizationCheck
{

public:
	MTLocalizationCheck(const char *charLangCode, const char *charPVFName, const char *charLFName);
	~MTLocalizationCheck() { /* Do nothing. */ };

	// Scan the specified localization information for missing entries.
	bool   Check();
	// Output the missing entries to stdout.
	bool   Output();
	
private:
	bool   IsLeaf(MTConfigLib::IMTConfigPropSetPtr& aPropSet);
	bool   RecurseAndPopulate(_bstr_t& aPath, FQNCollection& FQNList);
	
	FQNCollection mMissingEntries;
	_bstr_t lang_code;
	_bstr_t productview_fname;
	_bstr_t locale_fname;
	_bstr_t host_name;
	_bstr_t mRelativePath;
};

#endif
