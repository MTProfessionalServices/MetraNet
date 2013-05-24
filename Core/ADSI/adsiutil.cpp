/**************************************************************************
 * @doc TEST
 *
 * Copyright 1999 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Carl Shimer
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <adsiutil.h>
#include <tchar.h>
#include <metra.h>
#include <iiis.h>
#include <domainname.h>
#include <string.h>
#include <iostream>
using std::cout;
using std::endl;

#define METABASE_VIRTUAL_DIR_ROOT				L"IIS://Localhost/W3svc/1/ROOT"
#define METABASE_VIRTUAL_ROOT_CLASS				_T("IIsWebVirtualDir")
#define METABASE_ALLOW_OUT_OF_PROC_COMPONENTS	_T( "AspAllowOutOfProcComponents" )
#define METABASE_DIRECTORY_BROWSING             _T("DirBrowseFlags")
#define METABASE_PATH							_T("Path")
#define METABASE_TRUE							_T("true")
#define METABASE_FALSE							_T("false")
#define METABASE_KEY_TYPE                       _T("KeyType")
#define METABASE_SECURITY_PERMS                 _T("AccessFlags")
#define METABASE_READ_ACCESS                    _T("AccessRead")
#define METABASE_WRITE_ACCESS                   _T("AccessWrite")
#define METABASE_EXECUTE_ACCESS                 _T("AccessExecute")
#define METABASE_SCRIPT_ACCESS                  _T("AccessScript")
#define METABASE_AUTHFLAGS											_T("AuthFlags")
const TCHAR* METABASE_DEFAULTDOMAIN = _T("DefaultLogonDomain");


#define GET_REAL_RESULT(x) ((HRESULT_FACILITY(x) == FACILITY_WIN32) ? HRESULT_CODE(x) : x)



bool MTVdir::InitADSI(LPCSTR pPath)
{
    if(m_bInitADSI) return true;
		IDispatchPtr dispatch;

    do {

		 if((UuidFromString((unsigned char*)"001677D0-FD16-11CE-ABC4-02608C9E7553",&m_IID_IADsContainer) != RPC_S_OK) ||
            (UuidFromString((unsigned char*)"46FBBB80-0192-11d1-9C39-00A0C922E703",&m_IId_IISApp) != RPC_S_OK)) {
            m_Hr = E_FAIL; break;
        }


      
	    // step 1: Get the virtual directory root
	    m_Hr = ADsGetObject(METABASE_VIRTUAL_DIR_ROOT, 
					    m_IID_IADsContainer,
					    (void**)&m_virtDirRoot);
	    if(FAILED(m_Hr)) break;

	    // Step 2: Create the new virtual directory
        // used to be create
        try {
            // Get the IADsContainer interface
			// Note: ADSGetObject is the same as GetObject, but has been renamed to avoid compilation warnings.					
	        dispatch = m_virtDirRoot->ADSGetObject(METABASE_VIRTUAL_ROOT_CLASS,	// Name of the virtual directory schema class
												   pPath);	    			    // Relative name of the object to create
					m_virtDir = dispatch;
            break;
        }
        catch(_com_error e) {
						cout << e.ErrorMessage() << endl;
            m_Hr = e.Error();
						HRESULT foo = GET_REAL_RESULT(m_Hr);
            if(foo != ERROR_PATH_NOT_FOUND) throw e;
        }

    }while(false);

    m_bInitADSI = SUCCEEDED(m_Hr);
    return SUCCEEDED(m_Hr);
}


//////////////////////////////////////////////////////////
// real_CreateIISVdir
//
// Goes through the following steps:
//
// 1) Creates an instance of IADsContainer and IaDS. 
// 2) Creates the virtual directory
// 3) sets path for vdir
// 4) set dir browsing feature
// 5) set the key type
//
// aVirtualDir points to the virtual directory to create
// aVirtualDirPath points to the real path
//////////////////////////////////////////////////////////

LONG MTVdir::CreateIISVdir(const std::string& aVirtualDir, std::string&  aVirtualDirPath)
{
  if(!InitADSI(aVirtualDir.c_str()) &&  GET_REAL_RESULT(m_Hr) != ERROR_PATH_NOT_FOUND) return m_Hr;

	try {
		// we need to create the vdir
		IDispatchPtr dispatch;			// Temp interface pointer
		dispatch = m_virtDirRoot->Create(METABASE_VIRTUAL_ROOT_CLASS,	// Name of the virtual directory schema class
													_bstr_t(aVirtualDir.c_str()) );	    				// Relative name of the object to create
		// Get the IADsContainer interface
		m_virtDir = dispatch;

		m_virtDir->QueryInterface(m_IId_IISApp,(void**)&m_pIISApp);

		if(m_pIISApp != NULL && SUCCEEDED((m_Hr = m_pIISApp->AppCreate(true)))) {
				m_Hr = m_pIISApp->AppEnable();
		}
		m_pIISApp->Release();


		// Set the AspAllowOutOfProcess switch
		m_variant = METABASE_FALSE;
		m_virtDir->Put( METABASE_ALLOW_OUT_OF_PROC_COMPONENTS, m_variant );

		// step 3: Set the physical path
		m_variant = aVirtualDirPath.c_str();
		m_virtDir->Put( METABASE_PATH, m_variant );

		// step 4: dir browsing feature
		m_variant = (long)(MD_DIRBROW_SHOW_TIME | MD_DIRBROW_SHOW_DATE | MD_DIRBROW_SHOW_SIZE 
		| MD_DIRBROW_SHOW_EXTENSION | MD_DIRBROW_LOADDEFAULT);
		m_virtDir->Put(METABASE_DIRECTORY_BROWSING,m_variant);

		// step 5: key type
		m_variant = METABASE_VIRTUAL_ROOT_CLASS;
		m_virtDir->Put(METABASE_KEY_TYPE,METABASE_VIRTUAL_ROOT_CLASS);

		// Set the info
		m_virtDir->SetInfo();
	}
	catch(_com_error e) {
		m_Hr = e.Error();
		cout << e.ErrorMessage() << endl;
	}

	return m_Hr;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: MTVdir::DeleteIISVdir
// Description	    : 
// Return type		: LONG 
// Argument         : const std::string& lpszVdir
/////////////////////////////////////////////////////////////////////////////

LONG MTVdir::DeleteIISVdir(const std::string& lpszVdir)
{
	if(!InitADSI(_bstr_t(lpszVdir.c_str()))) {
		if(GET_REAL_RESULT(m_Hr) != ERROR_PATH_NOT_FOUND)
			return m_Hr;
		else
			return S_OK;
	}

	m_Hr = m_virtDirRoot->Delete(METABASE_VIRTUAL_ROOT_CLASS,_bstr_t(lpszVdir.c_str()));
	return m_Hr;
}


//////////////////////////////////////////////////////////
// real_SetIISVdirPerms
//
// Sets the directory permissionsn for the virtual directory.  This 
// needs to be a seperate function because each virtual directory we create 
// may have a seperate security setting.
//////////////////////////////////////////////////////////

LONG MTVdir::SetIISVdirPerms(const std::string& aVirtualDir, LONG pSecParams)
{
  if(!InitADSI(aVirtualDir.c_str())) return m_Hr;

  // step 1: set the security permission
  TCHAR* pType;

  switch(pSecParams) {

    case MD_ACCESS_READ: 
        pType = METABASE_READ_ACCESS; break;
    case MD_ACCESS_WRITE: 
        pType = METABASE_WRITE_ACCESS; break;
    case MD_ACCESS_EXECUTE: 
        pType = METABASE_EXECUTE_ACCESS; break;
    case MD_ACCESS_SCRIPT:
        pType = METABASE_SCRIPT_ACCESS; break;
    default:
        ASSERT(!"Bad Type: Only single types are allowed.");
        pType = METABASE_READ_ACCESS;
  }

  m_variant = METABASE_TRUE;
  m_virtDir->Put(pType,m_variant);
  // Set the info
  m_virtDir->SetInfo();

  return m_Hr;
}

///////////////////////////////////////////////////////////
// real_CreateIISVdir
//
// Goes through the following steps:
//
// 1) Creates an instance of IADsContainer and IaDS. 
// 2) gets the path for the vdir
//
// aVirtualDir points to the virtual directory to create
// aVirtualDirPath points to the real path
//////////////////////////////////////////////////////////

LONG MTVdir::GetVdirPhysicalPath(const std::string& aVirtualDir, std::string&  aVirtualDirPath)
{
  _variant_t vtVirtualDirPath ;
  _bstr_t bstrVirtualDirPath ;

  // step 1: initialize adsi 
  if(!InitADSI(aVirtualDir.c_str())) return m_Hr;

  // step 2: get the physical path
	try {
		vtVirtualDirPath = m_virtDir->Get(METABASE_PATH);

		// get the path out of the _variant_t ...
		if (vtVirtualDirPath.vt == VT_BSTR)
		{
			bstrVirtualDirPath = vtVirtualDirPath.bstrVal ;
			aVirtualDirPath = (char *) bstrVirtualDirPath ;
		}
		else
		{
			m_Hr = ERROR_PATH_NOT_FOUND ;
		}
	}
	catch(_com_error e) {
		m_Hr = e.Error();

	}

  return m_Hr ;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: MTVdir::SetBasicAuth
// Description	    : 
// Return type		: LONG 
// Argument         : const std::string& lpszVdir
/////////////////////////////////////////////////////////////////////////////

LONG MTVdir::SetBasicAuth(const std::string& lpszVdir)
{
 if(!InitADSI(lpszVdir.c_str())) return m_Hr;

	try {
		_variant_t aVariant((long)MD_AUTH_BASIC);

		// step 1: set the basic auth flag

		m_Hr = m_virtDir->Put(METABASE_AUTHFLAGS,aVariant);
		if(SUCCEEDED(m_Hr)) {

			// step 2: get the domain name
			std::wstring aDomainName;
			if(GetNTDomainName(aDomainName)) {
				m_Hr = m_virtDir->Put(METABASE_DEFAULTDOMAIN,_variant_t(aDomainName.c_str()));
				
			}
			// step 3: set the domain name

			if(SUCCEEDED(m_Hr)) {
				m_Hr = m_virtDir->SetInfo();
			}
		}

	}
	catch(_com_error e) {
		m_Hr = e.Error();
	}
	return m_Hr;

}


