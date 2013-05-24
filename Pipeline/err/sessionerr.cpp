/**************************************************************************
 * @doc SESSIONERR
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>

#include <errobj.h>
#include <mtglobal_msg.h>
#include <pipemessages.h>
#include <string>

#include <sessionerr.h>

SessionErrorObject::SessionErrorObject()
{
	mpMessage = NULL, mMessageLength = 0;

	mIsCompound = FALSE;
	SetBatchID(NULL);
}

SessionErrorObject::~SessionErrorObject()
{
	if (mpMessage)
	{
		delete [] mpMessage;
		mpMessage = NULL;
	}
}

void SessionErrorObject::GetMessage(const char * * apMessage,
																		int & aMessageLength)
{
	*apMessage = mpMessage;
	aMessageLength = mMessageLength;
}

void SessionErrorObject::SetMessage(const char * apMessage,
																		int aMessageLength)
{
	if (mpMessage)
		delete [] mpMessage;

	// NOTE: we don't null terminate
	mpMessage = new char[aMessageLength];
	memcpy(mpMessage, apMessage, aMessageLength);
	mMessageLength = aMessageLength;
}

// takes a 4 byte binary string representing the IP address
void SessionErrorObject::SetIPAddress(const unsigned char * apAddress)
{
	memcpy(mIPAddress, apAddress, sizeof(mIPAddress));
}

void SessionErrorObject::SetIPAddressAsString(const char * apAddress)
{
	int bytes[4] = {0, 0, 0, 0};
	sscanf(apAddress, "%d.%d.%d.%d",
				 &bytes[0],
				 &bytes[1],
				 &bytes[2],
				 &bytes[3]);

	for (int i = 0; i < 4; i++)
		mIPAddress[i] = (unsigned char) bytes[i];
}

// IP address as a string
void SessionErrorObject::GetIPAddressAsString(std::string & arIP)
{
	char buffer[64];
	sprintf(buffer, "%d.%d.%d.%d",
					(int) mIPAddress[0],
					(int) mIPAddress[1],
					(int) mIPAddress[2],
					(int) mIPAddress[3]);
	arIP = buffer;
}


// MSIX UID of the root of the compound the
// session was part of.  All zeros if not part of a compound
const unsigned char * SessionErrorObject::GetRootID() const
{
	for (int i = 0; i < sizeof(mRootID) / sizeof(mRootID[0]); i++)
		if (mRootID[i] != 0)
			return mRootID;

	return NULL;
}

void SessionErrorObject::SetRootID(const unsigned char aUID[])
{
	if (aUID)
		memcpy(mRootID, aUID, sizeof(mRootID));
	else
		memset(mRootID, 0, sizeof(mRootID));
}

// MSIX UID of batch containing the failed session
const unsigned char * SessionErrorObject::GetSessionSetID() const
{
	for (int i = 0; i < sizeof(mSessionSetID) / sizeof(mSessionSetID[0]); i++)
		if (mSessionSetID[i] != 0)
			return mSessionSetID;

	return NULL;
}

void SessionErrorObject::SetSessionSetID(const unsigned char aUID[])
{
	if (aUID)
		memcpy(mSessionSetID, aUID, sizeof(mSessionSetID));
	else
		memset(mSessionSetID, 0, sizeof(mSessionSetID));
}

const unsigned char * SessionErrorObject::GetBatchID() const
{
	for (int i = 0; i < sizeof(mBatchID) / sizeof(mBatchID[0]); i++)
		if (mBatchID[i] != 0)
			return mBatchID;

	return NULL;
}

void SessionErrorObject::SetBatchID(const unsigned char aUID[])
{
	if (aUID)
		memcpy(mBatchID, aUID, sizeof(mBatchID));
	else
		memset(mBatchID, 0, sizeof(mBatchID));
}



// initialize this object from a buffer of bytes (normally an error message)
BOOL SessionErrorObject::Decode(const unsigned char * apBytes, int aBufferLen)
{
	const char * functionName = "SessionErrorObject::Decode";

	// copy the structure part back out
	const struct SessionError * structure = (struct SessionError *) apBytes;
	SessionError::operator =(*structure);

	// read the strings
	const char * strings = (const char *) (apBytes + sizeof(SessionError));
	mErrorMessage = strings;
	strings += strlen(strings) + 1;	// move past the terminator

	mStageName = strings;
	strings += strlen(strings) + 1;

	mPlugInName = strings;
	strings += strlen(strings) + 1;

	mModuleName = strings;
	strings += strlen(strings) + 1;

	mProcedureName = strings;
	strings += strlen(strings) + 1;

	// the rest of the data is the message
	mMessageLength = (apBytes + aBufferLen) - (const unsigned char *) strings;
	ASSERT(!mpMessage);
	mpMessage = new char [mMessageLength];
	memcpy(mpMessage, strings, mMessageLength);

	return TRUE;
}

// get the size of the buffer required to hold an encoded version of
// this object
int SessionErrorObject::GetEncodeBufferSize() const
{
	return sizeof(SessionError)
		+ mErrorMessage.length() + 1
		+ mStageName.length() + 1
		+ mPlugInName.length() + 1
		+ mModuleName.length() + 1
		+ mProcedureName.length() + 1
		+ mMessageLength;						// message itself is not null terminated
}

// encode this object into the buffer.  buffer size must be large enough
// to hold the byte stream or the method will fail
BOOL SessionErrorObject::Encode(unsigned char * apBytes, int aBufferLen)
{
	const char * functionName = "SessionErrorObject::Encode";

	int sizeNeeded = GetEncodeBufferSize();
	if (sizeNeeded > aBufferLen)
	{
		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
						 functionName, "buffer to small");
		return FALSE;
	}

	// copy the first part of the structure
	struct SessionError * structure = (struct SessionError *) apBytes;
	*structure = *this;

	// now append the strings to the end of the buffer
	char * buffer = (char *) (apBytes + sizeof(SessionError));
	strcpy(buffer, mErrorMessage.c_str());
	buffer += strlen(buffer) + 1; // move past the terminator
	strcpy(buffer, mStageName.c_str());
	buffer += strlen(buffer) + 1; // move past the terminator
	strcpy(buffer, mPlugInName.c_str());
	buffer += strlen(buffer) + 1; // move past the terminator
	strcpy(buffer, mModuleName.c_str());
	buffer += strlen(buffer) + 1; // move past the terminator
	strcpy(buffer, mProcedureName.c_str());
	buffer += strlen(buffer) + 1; // move past the terminator
	memcpy(buffer, mpMessage, mMessageLength);
	return TRUE;
}
