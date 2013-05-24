#include <AdapterLogging.h>
#include <string.h>
#include <mtprogids.h>
#include <mtcomerr.h>
// import the vendor kiosk tlb...
#import <COMKiosk.tlb> 
using namespace COMKIOSKLib;

const char ACCOUNT_MAPPING_CONFIG_PATH[] = "\\AccountMapping";

class AccountMapping
{
public:
	AccountMapping();
	~AccountMapping();
	HRESULT ModifyAccountMapping(	int Action,
												_bstr_t LoginName, 
												_bstr_t NameSpace, 
												_bstr_t NewLoginName,
												_bstr_t NewNameSpace
											);
	NTLogger mLogger;
private:
	COMKIOSKLib::ICOMAccountMapperPtr m_comaccountmapper;
	HRESULT CreateRowset(LPDISPATCH& pDispatch);
	HRESULT InitAccountMapperPointer();
	BOOL bIsAccountMapperInitialized;
};
