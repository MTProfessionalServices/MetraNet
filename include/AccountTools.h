#ifndef __ACCOUNTTOOLS_H__
#define __ACCOUNTTOOLS_H__

#include <metra.h>
#include <string>

class MTAccountTools {

public:
	MTAccountTools(const std::string& aAccountName) : mAccountName(aAccountName) {}

  BOOL AddDefaultAccount(const std::string& aPassword,const std::string& aNamespace,
    const std::string& aLanguage,const int aDayOfMonth,const _bstr_t aUCT="Monthly",
    const long aDayOfWeek=0,const long aFirstDayOfMonth=0,const long aSecondDayOfMonth=0,
    const long aStartDay=0,const long aStartMonth=0,const long aStartYear=0, const wchar_t* aAccountType=L"CORESUBSCRIBER", const wchar_t* aLoginApp=L"MPS");
  BOOL AddAccountMapping(const std::string& aNamespace,const long aAccountId);
  BOOL CreateInternalAccountSchemaAndData(const std::string& aAdapterName);

  const char* GetErrorString() { return mErrorString; }

protected:
  std::string mAccountName;
  char mErrorString[1024];

};


#endif //__ACCOUNTTOOLS_H__
