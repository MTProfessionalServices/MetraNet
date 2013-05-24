/**************************************************************************
 * SHAREDMEMORYSESSIONBUILDER
 *
 * Copyright 1997-2004 by MetraTech Corp.
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
 * Created by: Travis Gebhardt
 *
 * $Date$
 * $Author$s
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <sessionbuilder.h>
#include <mtprogids.h>

#import <MTPipelineLib.tlb> rename("EOF", "RowsetEOF")

SharedMemorySessionBuilder::SharedMemorySessionBuilder() 
	: mpSessionServer(NULL), mpSession(NULL), mpProduct(NULL)
{ }

void SharedMemorySessionBuilder::Initialize(const PipelineInfo & configInfo, CMTCryptoAPI * apCrypto)
{
	ASSERT(apCrypto);
	mpCrypto = apCrypto;

	// initializes the "wrapped" shared memory session server
	mpSessionServer = CMTSessionServerBase::CreateInstance();
	mpSessionServer->Init(_bstr_t(configInfo.GetSharedSessionFile().c_str()),
												_bstr_t(configInfo.GetShareName().c_str()),
												configInfo.GetSharedFileSize());


	// TODO: this is a hack, we should be able to use the wrapped server
	// initializes the COM session server
	HRESULT hr = mCOMSessionServer.CreateInstance(MTPROGID_SESSION_SERVER);
	if (FAILED(hr))
		throw MTException("Could not create raw session server", hr);

	mCOMSessionServer->Init(configInfo.GetSharedSessionFile().c_str(),
													configInfo.GetShareName().c_str(),
													configInfo.GetSharedFileSize());

}

SharedMemorySessionBuilder::~SharedMemorySessionBuilder()
{
	Clear();

	if (mpSessionServer)
	{
		mpSessionServer->Release();
		mpSessionServer = NULL;
	}
}

void SharedMemorySessionBuilder::Clear()
{
	ClearProperties();

	if (mpSession) 
	{
		delete mpSession;
		mpSession = NULL;
	}

	if (mpProduct)
	{
		delete mpProduct;
		mpProduct = NULL;
	}
}

void SharedMemorySessionBuilder::StartProduction()
{
	ASSERT(!mpProduct);
	mpProduct = new SharedMemorySessionProduct(this);
}

ISessionProduct * SharedMemorySessionBuilder::CompleteProduction()
{
	// there should be no session state left
	// all sessions are now stored in the product
  ASSERT(!mpSession);

	// the client now owns the product
	// they are responsible for freeing it
	ISessionProduct * product = mpProduct;
	mpProduct = NULL;
	return product;
}

void SharedMemorySessionBuilder::AbortProduction()
{
	Clear();
}


inline void SharedMemorySessionBuilder::CreateSession(const unsigned char * uid, int serviceDefID)
{
	ASSERT(!mpSession);
	mpSession = mpSessionServer->CreateSession(uid, serviceDefID);
}

inline void SharedMemorySessionBuilder::CreateChildSession(const unsigned char * uid,
																													 int serviceDefID,
																													 const unsigned char * parentUID)
{
	ASSERT(!mpSession);
	mpSession = mpSessionServer->CreateChildSession(uid, serviceDefID, parentUID);
}

inline void SharedMemorySessionBuilder::AddLongSessionProperty(long propertyID, long value)
{	
	mpSession->SetLongProperty(propertyID, value);	
	RecordProperty(propertyID);
}

inline void SharedMemorySessionBuilder::AddDoubleSessionProperty(long propertyID, double value)
{	
	mpSession->SetDoubleProperty(propertyID, value);	
	RecordProperty(propertyID);
}

inline void SharedMemorySessionBuilder::AddTimestampSessionProperty(long propertyID, time_t value)
{	
	mpSession->SetDateTimeProperty(propertyID, value);	
	RecordProperty(propertyID);
}

inline void SharedMemorySessionBuilder::AddBoolSessionProperty(long propertyID, bool value)
{	
	mpSession->SetBoolProperty(propertyID, value);	
	RecordProperty(propertyID);
}

inline void SharedMemorySessionBuilder::AddEnumSessionProperty(long propertyID, long value)
{	
	mpSession->SetEnumProperty(propertyID, value);	
	RecordProperty(propertyID);
}

inline void SharedMemorySessionBuilder::AddStringSessionProperty(long propertyID, const wchar_t* value)
{	
	mpSession->SetStringProperty(propertyID, value);	
	RecordProperty(propertyID);
}

inline void SharedMemorySessionBuilder::AddEncryptedStringSessionProperty(long propertyID, const wchar_t* value)
{	
	std::string cipherText;
  if(!::WideStringToUTF8(value, cipherText))
  {
    ASSERT(0);
		throw MTException("Failed to convert wide string to UTF8!");
  }

	// encrypts and uuencodes string
	int result;
	result = mpCrypto->Encrypt(cipherText);
	if (result != 0)
	{
		ASSERT(0);
		std::string msg = "Failed to encrypt property! propid=" + propertyID;
		throw MTException(msg.c_str());
	}

	_bstr_t wideCipherText(cipherText.c_str());
	mpSession->SetStringProperty(propertyID, (const wchar_t *) wideCipherText);	

	RecordProperty(propertyID);
}

inline void SharedMemorySessionBuilder::AddDecimalSessionProperty(long propertyID, DECIMAL value)
{	
	mpSession->SetDecimalProperty(propertyID, value);	
	RecordProperty(propertyID);
}

inline void SharedMemorySessionBuilder::AddLongLongSessionProperty(long propertyID, __int64 value)
{	
	mpSession->SetLongLongProperty(propertyID, value);	
	RecordProperty(propertyID);
}

inline bool SharedMemorySessionBuilder::SessionPropertyExists(long propertyID)
{
	return PropertyExists(propertyID);
}

inline void SharedMemorySessionBuilder::CompleteSession()
{
	ASSERT(mpSession);

	mpProduct->AddSession(mpSession);

	// the product now owns the session
	mpSession = NULL;
	
	// resets property tracking for the next session
	ClearProperties();
}



//
// SharedMemorySessionProduct
//

SharedMemorySessionProduct::~SharedMemorySessionProduct()
{
	for(int i = 0; i < (int) mSessions.size(); i++)
		delete mSessions[i];

	mSessions.clear();
}

// returns sessions as a vector of COM-wrapped sessions
// ownership of sessions is given to caller
void SharedMemorySessionProduct::GetSessions(std::vector<MTPipelineLib::IMTSessionPtr> & arSessions)
{
	ASSERT(mHasOwnership); 	// this method can only be called once!
	
	for (int i = 0; i < (int) mSessions.size(); i++)
	{
		CMTSessionBase * session = mSessions[i];
		MTPipelineLib::IMTSessionPtr sessionObj = mBuilder->GetCOMSessionServer()->GetSession(session->get_SessionID());
		arSessions.push_back(sessionObj);
	}

	mHasOwnership = false;
}
