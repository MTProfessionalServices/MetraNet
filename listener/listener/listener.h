#ifndef AFX_LISTENER_H__7143DAD9_DFAE_11D1_8DC9_006008C0E24A__INCLUDED_
#define AFX_LISTENER_H__7143DAD9_DFAE_11D1_8DC9_006008C0E24A__INCLUDED_

// LISTENER.H - Header file for your Internet Server
//    MSIX listener Extension
//
// $Date$
// $Author$
// $Revision$

#include <comip.h>
#include <handler.h>
#include <asserthelper.h>
#include <vector>
using std::vector;

#define LISTENER_MSG_MODULE "listener_msg.dll"

//////////////////////////////////////////////////////////////////////
// MTListenerStrings
//
// this class encapsulates all of the resource strings located
// in the resource library, LISTENER_MSG_MODULE.  InitStrings
// must be called before you can access any of the strings.
//////////////////////////////////////////////////////////////////////

class MTListenerStrings {
public:
	MTListenerStrings() :m_bInited(false) {}
	~MTListenerStrings();

	BOOL InitStrings();
	const std::string& GetString(const unsigned int id);
	void GetModuleName(std::string&);
	const std::string& GetBadRequestHead();

	
protected:
	bool m_bInited; // guard against using GetString before initString
	vector<std::string> m_vector;
	std::string m_BadRequestHead;
};

#ifdef _DEBUG

// assert handling class

class ListenerAssertHelper : public MTAssertHelper {
private:
    ListenerAssertHelper(const ListenerAssertHelper&);
    ListenerAssertHelper& operator=(const ListenerAssertHelper&);
public:
	ListenerAssertHelper() : MTAssertHelper() {}

	// static method
	static int HandleAssert(std::string&,ErrorObject&);
};

#endif

void CompleteRequest(EXTENSION_CONTROL_BLOCK * apECB,
										 const char * apOutputMessage,
										 const char * apOutputStatus,
										 const char * apOutputContentType);

void CompletionHook(const char * apUID, const char * apMessage, void * apArg);


//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_LISTENER_H__7143DAD9_DFAE_11D1_8DC9_006008C0E24A__INCLUDED)
