// Session.cpp : Implementation of CSession
#include "StdAfx.h"
#include "COMMeter.h"
#include "Session.h"
#include "mtsdk.h"
#include "mtsdkex.h"
#include "mtdefs.h"
#include "xmlparser.h"
#include <MTUtil.h>
#include <MTDec.h>
#include <mtcomerr.h>


#define Debugger() __asm { __asm int 3 }

// Macro to make sure someone has created session properly
#define VALIDATE_SESSION() if (! m_Session) { Error("Attempting operation on invalid session"); return E_FAIL; }


////
//// CSession
////

CSession::CSession()
{
	// Generated Code
}

CSession::~CSession()
{
	// Clean up SDK Session if it was assigned
	if (m_Session)
		delete(m_Session);
	
	long sess_count;
	mChildSessions.Count( &sess_count);
	for (long i = 1; i<=sess_count; i++)
	{
		ISession *sess_pointer;		
		mChildSessions.Item(i, &sess_pointer);
		CSession *pCSess;
		pCSess = static_cast<CSession *>(sess_pointer);
		pCSess->SetSDKSession(NULL);
      pCSess->Release();
	}
}

// ----------------------------------------------------------------
// Description: Adds the child session to the parent
// ----------------------------------------------------------------
void CSession::AddChild(ISession *pSession)
{
	mChildSessions.Add( pSession );
}

STDMETHODIMP CSession::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = { &IID_ISession };
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CSession::Save()
{
	VALIDATE_SESSION()

	// Call SDK Save Function
	if (!m_Session->Save())
	{
		return HandleMeterError();
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Description: After each property has been initialized to the correct value,
//              Close sends the session and its parents and children, when
//              appropriate, to the metering server.  The session is marked
//              complete by a call to Close and further modification is not
//              allowed on the session object.  The metering server is allowed
//              to begin processing a session after it has been closed.  When a
//              session is closed, any parents of the session are saved but
//              will still be modifiable.  Any children of the session will be
//              closed and will not allow further modification.
// ----------------------------------------------------------------
STDMETHODIMP CSession::Close()
{
	VALIDATE_SESSION()

	// Call SDK Close Function
	if (!m_Session->Close())
	{
		return HandleMeterError();
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Description: This method will convert the session into
// its XML representation.
// Return Value: MSIX/XML representation of the session
// ----------------------------------------------------------------
HRESULT CSession::ToXML(/*[out, retval]*/ BSTR *pVal)
{
	int bufferSize = 0;
	(void) m_Session->ToXML(NULL, bufferSize);
	char * buffer = new char[bufferSize];
	(void) m_Session->ToXML(buffer, bufferSize);

	// NOTE: we have to construct the BSTR manually.  if we rely
	// on the _bstr_t constructor and pass in a large string the
	// program will crash with a stach exception.
	// See CMTConfigPropSet::WriteToBuffer for more info
	USES_CONVERSION;
	*pVal = A2BSTR(buffer);
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Create a child of this session.  Any number of children
//              can be created for a parent session.  Once Close
//              has been called on a session, no more children can be created.
//              Sessions that have been saved can still have more children
//              added to them.
//              When the child is deleted, it is removed from the parent.
//              When a parent session is deleted, it deletes any children
//              still connected to it.
// Arguments: ServiceName - service name of new child session.
// Return Value: New Session object.
// ----------------------------------------------------------------
STDMETHODIMP CSession::CreateChildSession(BSTR ServiceName, ISession **chldSess)
{
	

	HRESULT retval = S_OK;
	ISession * newCOMSession = NULL;
	CComObject<CSession> * newSession;
	MTMeterSession * newSDKSession;
	bstr_t	sn;

	VALIDATE_SESSION()
	
	// Create new instance
	sn = ServiceName;
	retval = CComObject<CSession>::CreateInstance(&newSession);
	if (FAILED(retval)) return retval;

	// Query Interface to increment reference count
	HRESULT hr = newSession->QueryInterface(IID_ISession, (void **)&newCOMSession);

	if (SUCCEEDED(hr))
	{
		// Create SDK Child Session and assign to new COM Session
		newSDKSession = m_Session->CreateChildSession((const char *)sn);

		// Make sure session was Created
		if (! newSDKSession)
		{
			return HandleMeterError();
		}
		else
		{
			// Finally made it -> Set IUnknown pointer and assign SDK object to new Interface
			newSession->SetSDKSession(newSDKSession);
			newSession->SetSessionName(ServiceName);
			*chldSess = newCOMSession;
			AddChild (newCOMSession);
		}
	}		
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Initializes a session's property.
// Arguments: Name - property name
//            Value - property value
// ----------------------------------------------------------------
STDMETHODIMP CSession::InitProperty(BSTR Name, VARIANT Value)
{

	// NOTE: Code is a little messy due to variant_t not converting to int so you have to go variant->long->int

	bstr_t convertedName;			// bstr_t for Property Name
	bstr_t convertedValue;			// bstr_t for Property Value
	const char * convertedMB;		// char * for Property Value
	long convertedLong;				// Need this to go from long to int...
	variant_t vToConvert;			// variant_t for Property Value
	BOOL success = FALSE;
	time_t convertedTime;
	MTDecimalValue * decValue;

	VALIDATE_SESSION()

	// Make sure there is a name
	if (!Name) {
		Error("Must provide property name");
		return E_INVALIDARG;
	}

	// Create bstr_t to convert to char* 
	convertedName = Name;
	const char * finalName = convertedName;
	
	// Handle nested Variant
	if (Value.vt == (VT_VARIANT|VT_BYREF))
		vToConvert = Value.pvarVal;
	else
		vToConvert = Value;   // This copies the value
	
	// Call appropriate InitProperty
	switch (vToConvert.vt & ~VT_BYREF)  // Treat BYREF the same as by value
		{
		case VT_I2:						// Short (VB will do this on its own)		
			vToConvert.ChangeType(VT_I4, NULL);
			convertedLong = (long)vToConvert;
			success = m_Session->InitProperty(finalName, (int)convertedLong);
			break;
		case VT_I4:						// Long (Int)
			convertedLong = (long)vToConvert;
			success = m_Session->InitProperty(finalName, (int)convertedLong);
			break;
		case VT_I8:						// LongLong 
			success = m_Session->InitProperty(finalName, (__int64)(vToConvert), MTMeterSession::SDK_PROPTYPE_BIGINTEGER);
			break;
		case VT_R4:						// Float
			success = m_Session->InitProperty(finalName, (float)(vToConvert));
			break;
		case VT_BSTR:					// BSTR (wide char - almost!)
			convertedValue = vToConvert;
			success = m_Session->InitProperty(finalName, (const wchar_t *)(convertedValue));
			break;
		case VT_BYREF|VT_I1:			// char *
			convertedValue = vToConvert;
			convertedMB = convertedValue;
			success = m_Session->InitProperty(finalName, convertedMB);
			break;
		case VT_R8:						//double
			success = m_Session->InitProperty(finalName, (double)(vToConvert));
			break;
		case VT_DATE:					// Datetime
			TimetFromOleDate(&convertedTime, (DATE)(vToConvert));
			success = m_Session->InitProperty(finalName, convertedTime, MTMeterSession::SDK_PROPTYPE_DATETIME);
			break;
		case VT_BOOL:					// boolean
			if (vToConvert.boolVal == VARIANT_TRUE)
				success = m_Session->InitProperty(finalName, TRUE, MTMeterSession::SDK_PROPTYPE_BOOLEAN);
			else
				success = m_Session->InitProperty(finalName, FALSE, MTMeterSession::SDK_PROPTYPE_BOOLEAN);
			break;
		case VT_DECIMAL:				// decimal		
			decValue = MTDecimalValue::Create();
			success = decValue->SetValue(MTDecimal((DECIMAL)(vToConvert)).Format().c_str());
			if (success) {
				success = m_Session->InitProperty(finalName, decValue);
			} else {
				Error("Failed to set MTDecimal value -- bad decimal?");
			}
			delete decValue;
			break;
		default:
			Error("The value provided is of an unsupported variant type.");
			return E_INVALIDARG;
	}

	if (!success)	return HandleMeterError();
	return S_OK;
}

STDMETHODIMP CSession::CreateSessionStream(/*[in]*/ SAFEARRAY* propertyDataArray)
{
   // Return an error if the underlying session set has not been initialized with properties (username or session context)
   MeteringSessionImp *pMeteringSessionImp = dynamic_cast<MeteringSessionImp *> (m_Session); //safe downcast
   if (pMeteringSessionImp == 0)
   {
     Error("Casting down from MTMeterSession to MeteringSessionImp failed.");
		 return HandleMeterError();
   }
   
   MeteringSessionSetImp* pMeteringSessionSetImp = pMeteringSessionImp->GetMeteringSessionSet();
   if (pMeteringSessionSetImp->PropertiesInitialized() == FALSE)
   {
     Error("In the FastSDK mode, the session set properties must be initialized before setting session properties.");
		 return HandleMeterError();
   }

   PropertyData HUGEP *pPropertyDataArray;
   string propertyValue;
   BOOL success = TRUE;

   // Make sure we don't have a multi-dimension array
   UINT numDimensions = SafeArrayGetDim(propertyDataArray);
   if (numDimensions != 1) 
   {
      Error("'propertyDataArray' VARIANTARRAY must have only one dimension.");
		return E_INVALIDARG;
   }

   long ubound = 0;
   SafeArrayGetUBound(propertyDataArray, 1, &ubound);

   if (FAILED(SafeArrayAccessData(propertyDataArray, (void HUGEP**)&pPropertyDataArray)))
   {
      Error("Could not access 'propertyDataArray' VARIANTARRAY.");
		return E_INVALIDARG;
   }

   m_Session->CreateHeader();
   m_Session->CreatePropertiesHeader();

   for (int i = 0; i <= ubound; i++)
   {
       propertyValue = "";

       if (pPropertyDataArray[i].type == 0) // -- DataType.MTC_DT_WCHAR)
       {
         XMLStringToUtf8(propertyValue, 
                         (const wchar_t*)_bstr_t(pPropertyDataArray[i].value)); 
       }
       else 
       {
         propertyValue = (const char*)_bstr_t(pPropertyDataArray[i].value);
       }

      success = 
         m_Session->CreatePropertyStream((const char*)_bstr_t(pPropertyDataArray[i].name), 
                                         propertyValue);

      if (!success) 
      {
        return HandleMeterError();
      }
   }

   m_Session->CreateExistingPropertyStream();

   SafeArrayUnaccessData(propertyDataArray);

   m_Session->CreatePropertiesFooter();
   m_Session->CreateFooter();

   m_Session->SetFastMode(TRUE);

   return S_OK;
}

// ----------------------------------------------------------------
// Description: Sets a previously initilized session property.
// Arguments: Name - property name
//            Value - property value
// ----------------------------------------------------------------
STDMETHODIMP CSession::SetProperty(BSTR Name, VARIANT Value)
{
	bstr_t convertedName;			// bstr_t for Property Name
	bstr_t convertedValue;			// bstr_t for Property Value
	const char * convertedMB;		// char * for Property Value
	long convertedLong;				// Used to convert variants to ints
	variant_t vToConvert;			// variant_t for Property Value
	BOOL success = FALSE;
	time_t convertedTime;
	MTDecimalValue * decValue;

	VALIDATE_SESSION()
	
	// Make sure there is a name
	if (!Name) {
		Error("Must provide property name");
		return E_INVALIDARG;
	}

	// Create bstr_t to convert to char* 
	convertedName = Name;
	const char * finalName = convertedName;
	
	// Call appropriate InitProperty
	vToConvert = Value;       // copy the variant
	switch (vToConvert.vt)
	{
	case VT_I2:						// Short (VB will do this on its own)		
		vToConvert.ChangeType(VT_I4, NULL);
		convertedLong = (long)vToConvert;
		success = m_Session->SetProperty(finalName, (int)convertedLong);
		break;
	case VT_I4:						// Long (Int)
		convertedLong = (long)vToConvert;
		success = m_Session->SetProperty(finalName, (int)convertedLong);
		break;
	case VT_I8:						// LongLong
		success = m_Session->SetProperty(finalName, (__int64)(vToConvert), MTMeterSession::SDK_PROPTYPE_BIGINTEGER);
		break;
	case VT_R4:						// Float
		success = m_Session->SetProperty(finalName, (float)(vToConvert));
		break;
	case VT_BSTR:					// BSTR (wide char - almost!)
		convertedValue = (bstr_t)vToConvert;
		success = m_Session->SetProperty(finalName, (const wchar_t *)(convertedValue));
		break;
	case VT_BYREF|VT_I1:			// char *
		convertedValue = (bstr_t)vToConvert;
		convertedMB = convertedValue;
		success = m_Session->SetProperty(finalName, convertedMB);
		break;
	case VT_R8:						//double
		success = m_Session->SetProperty(finalName, (double)(vToConvert));
		break;
	case VT_DATE:					// Datetime
		TimetFromOleDate(&convertedTime, (DATE)(vToConvert));
		success = m_Session->SetProperty(finalName, convertedTime, MTMeterSession::SDK_PROPTYPE_DATETIME);
		break;
		
	case VT_BOOL:			// boolean
		if (vToConvert.boolVal == VARIANT_TRUE)
			success = m_Session->SetProperty(finalName, TRUE,  MTMeterSession::SDK_PROPTYPE_BOOLEAN);
		else
			success = m_Session->SetProperty(finalName, FALSE, MTMeterSession::SDK_PROPTYPE_BOOLEAN);
		break;
	case VT_DECIMAL:		// decimal
		decValue = MTDecimalValue::Create();
		decValue->SetValue(MTDecimal((DECIMAL)(vToConvert)).Format().c_str());			
		success = m_Session->SetProperty(finalName, decValue);
		delete decValue;
		break;
	default:
		Error("The value provided is of an unsupported variant type.");
		return E_INVALIDARG;
	}

	if (!success)	return HandleMeterError();
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Gets a property for the session.
// Arguments: Name - property name
//            Value - property value
// ----------------------------------------------------------------
STDMETHODIMP CSession::GetProperty(BSTR name, DataType Type, VARIANT *value)
{

	BOOL		success = FALSE;

	bstr_t		convertedName;
	variant_t	variantValue;		// Variant used to wrap VARIANT

	wchar_t		*wideVal;
	char		*mbVal;
	int			intVal;
	__int64		int64Val;
	float		fltVal;
	double		dblVal;
	time_t		tmVal;
	DATE		dateVal;
	BOOL    boolVal;
	const MTDecimalValue * pDecVal;
	
	VALIDATE_SESSION()

	// Make sure there is a name
	if (!name) {
		Error("Must provide property name");
		return E_INVALIDARG;
	}

	convertedName = name;

	switch (Type)
	{
		case MTC_DT_WCHAR:
			success = m_Session->GetProperty((char *)convertedName, (const wchar_t **)(&wideVal));
			if (success)
				variantValue = wideVal;
			break;
		case MTC_DT_CHAR:
			success = m_Session->GetProperty((char *)convertedName, (const char **)(&mbVal));
			if (success)
				variantValue = mbVal;
			break;
		case MTC_DT_INT:
			success = m_Session->GetProperty((char *)convertedName, intVal);
      if (success)
			  variantValue = (long)intVal;
			break;
		case MTC_DT_BIGINT:
			success = m_Session->GetProperty((char *)convertedName, int64Val, MTMeterSession::SDK_PROPTYPE_BIGINTEGER);
			if (success)
        variantValue = (__int64)int64Val;
			break;
		case MTC_DT_FLOAT:
			success = m_Session->GetProperty((char *)convertedName, fltVal);
      if (success)
			  variantValue = fltVal;
			break;
		case MTC_DT_DOUBLE:
			success = m_Session->GetProperty((char *)convertedName, dblVal);
      if (success)
			  variantValue = dblVal;
			break;
		case MTC_DT_TIME:
			success = m_Session->GetProperty((char *)convertedName, tmVal, MTMeterSession::SDK_PROPTYPE_DATETIME);
			if (success)
			{
				OleDateFromTimet(&dateVal, tmVal);
				_variant_t vTemp (dateVal, VT_DATE);
				variantValue = vTemp;
			}
			break;
		case MTC_DT_BOOL:
			success = m_Session->GetProperty((char *)convertedName, boolVal, MTMeterSession::SDK_PROPTYPE_BOOLEAN);
			if (boolVal)
				variantValue = VARIANT_TRUE;
			else
				variantValue = VARIANT_FALSE;
			break;
		case MTC_DT_DECIMAL:
		{
			success = m_Session->GetProperty((char *)convertedName, &pDecVal);
      if (success)
      {
        char buffer[256];
			  int length = sizeof(buffer);
			  const_cast<MTDecimalValue *>(pDecVal)->Format(buffer, length);
			  variantValue = DECIMAL(MTDecimal(buffer));
      }
			break;
		}
		default:
			Error("The DataType provided is an unsupported variant type.");
			return E_INVALIDARG;
	}
	
	// Check for errors
	if (!success) return HandleMeterError();

	// Assign Value to Output Param
	*value = variantValue.Detach();

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Obtains the SessionID.
// Return Value: Session ID: base64 encoded Unique ID (UID)
// ----------------------------------------------------------------
STDMETHODIMP CSession::get_SessionID(BSTR *pVal)
{
	char lSessionID[SESSION_ID_LEN];

	VALIDATE_SESSION()

   m_Session->GetSessionID(lSessionID);
	m_SessionID = lSessionID;

   // _bstr_t sessionIdCopy = m_SessionID.copy();
	*pVal = m_SessionID.copy(); //sessionIdCopy;

   return S_OK;
}

// ----------------------------------------------------------------
// Description: Obtains the Session's name.
// Return Value: session's service name
// ----------------------------------------------------------------
STDMETHODIMP CSession::get_Name(BSTR *pVal)
{
	*pVal = m_Name.copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Obtains the Session's Reference ID.
// Return Value: Session's reference ID: a shortened, printable version of
//               the UID.
// ----------------------------------------------------------------
STDMETHODIMP CSession::get_ReferenceID(BSTR *pVal)
{
	char lRefID[REFERENCE_ID_LEN];

	VALIDATE_SESSION()

	m_Session->GetReferenceID(lRefID);
	m_ReferenceID = lRefID;

	*pVal = m_ReferenceID.copy();

	return S_OK;
}

void CSession::SetSDKSession(MTMeterSession *session)
{
	m_Session = session;
}


void CSession::SetSessionName(BSTR theName)
{
	m_Name = _bstr_t(theName);
}

// ----------------------------------------------------------------
// Description: If synchronous metering has been enabled on this session, return true
// Return Value: true if synchronous metering is enabled
// ----------------------------------------------------------------
STDMETHODIMP CSession::get_RequestResponse(VARIANT_BOOL *pVal)
{
	VALIDATE_SESSION()

  *pVal = m_Session->GetResultRequestFlag() ? VARIANT_TRUE : VARIANT_FALSE;

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Enable or disable the use of synchronous metering.
// Arguments: newVal - true to enable synchronous metering
// ----------------------------------------------------------------
STDMETHODIMP CSession::put_RequestResponse(VARIANT_BOOL newVal)
{
	VALIDATE_SESSION()
	m_Session->SetResultRequestFlag(newVal == VARIANT_TRUE? TRUE : FALSE);
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Obtains the session returned from the server when using
//              synchronous metering.  Set the RequestResponse flag to enable
//              synchronous metering.
// Return Value: Response session from a synchronous metering event
// ----------------------------------------------------------------
STDMETHODIMP CSession::get_ResultSession(ISession **pResultSess)
{

	HRESULT retval = S_OK;
	ISession *newCOMSession = NULL;
	CComObject<CSession> *newSession;
	MTMeterSession *newSDKSession;
	bstr_t sn;

	VALIDATE_SESSION()
	
	// Create new instance
	retval = CComObject<CSession>::CreateInstance(&newSession);
	if (FAILED(retval)) return retval;

	// Query Interface to increment reference count
	HRESULT hr = newSession->QueryInterface(IID_ISession, (void **)&newCOMSession);

	if (!SUCCEEDED(hr)) return E_NOINTERFACE;

	// Get SDK Result Session and assign to new COM Session
	newSDKSession = m_Session->GetSessionResults();

	// Make sure session was created
	if (! newSDKSession)
	{
		Error("Session results are unavailable");
		return HandleMeterError();
	}

	// Set IUnknown pointer and assign SDK object to new Interface
	newSession->SetSDKSession(newSDKSession);
	*pResultSess = newCOMSession;
	AddChild(newCOMSession);				

	return S_OK;
}

STDMETHODIMP CSession::put__ID(/*[in]*/ BSTR newVal)
{
	try
	{
		MTSetSessionIDEx(m_Session, _bstr_t(newVal));
		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}

STDMETHODIMP CSession::put__SetID(/*[in]*/ BSTR newVal)
{
	try
	{
		MTSetSessionSetIDEx(m_Session, _bstr_t(newVal));
		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

//
// Called only on error -- converts and returns an HRESULT
//
HRESULT CSession::HandleMeterError()
{
	HRESULT result = E_FAIL;

	MTMeterError *err = m_Session->GetLastErrorObject();

	if (err)
	{
		// Create buffer to store error message in
		TCHAR errorBuf[ERROR_BUFFER_LEN];
		int errorBufSize = sizeof(errorBuf);

		// Get Error Info from SDK
		err->GetErrorMessageEx(errorBuf, errorBufSize);
		if (wcslen(errorBuf) == 0)
		{
			errorBufSize = sizeof(errorBuf);
			err->GetErrorMessage(errorBuf, errorBufSize);
		}

		DWORD hrcode = err->GetErrorCode();
		if (!FAILED(hrcode))
			hrcode = HRESULT_FROM_WIN32(hrcode);

		Error(errorBuf, 0, NULL, GUID_NULL, hrcode);
		result = hrcode;
		delete err;
	}

	return result;

}

// ----------------------------------------------------------------
// Description: 
// Return Value: 
// ----------------------------------------------------------------
STDMETHODIMP CSession::get_ErrorCode(long *pVal)
{
	MTMeterError *err = m_Session->GetLastErrorObject();
	if (err)
		*pVal = err->GetErrorCode();

	delete err;
	return S_OK;
}

// ----------------------------------------------------------------
// Description: 
// Return Value: 
// ----------------------------------------------------------------
STDMETHODIMP CSession::get_ErrorMessage(BSTR *pVal)
{
	MTMeterError *err = m_Session->GetLastErrorObject();
	if (err)
	{
		// Create buffer to store error message in
		TCHAR errorBuf[ERROR_BUFFER_LEN];
		int errorBufSize = sizeof(errorBuf);
		
		// Get Error Info from SDK
		err->GetErrorMessageEx(errorBuf, errorBufSize);
		if (wcslen(errorBuf) == 0)
		{
			errorBufSize = sizeof(errorBuf);
			err->GetErrorMessage(errorBuf, errorBufSize);
		}
	
		_bstr_t bstrErrorBuf (errorBuf);
		*pVal = bstrErrorBuf.copy();
	}

	delete err;
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Returns the collection of child sessions for the parent
// ----------------------------------------------------------------
STDMETHODIMP CSession::GetChildSessions(IMTCollection** col)
{
	mChildSessions.CopyTo( col );
	return S_OK;
}




