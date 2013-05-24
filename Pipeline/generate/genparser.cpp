/**************************************************************************
 * @doc GENPARSER
 *
 * Copyright 1998 by MetraTech Corporation
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
 * $Header: genparser.cpp, 21, 9/11/2002 9:45:56 AM, Alon Becker$
 ***************************************************************************/

#include <metra.h>

#define NO_SESSION_BUILDER_IMPL
#include <genparser.h>

#include <mtprogids.h>
#include <mtcomerr.h>
#include <reservedproperties.h>

#include <MSIX.h>
#include <mtglobal_msg.h>
#include <ctype.h>
#include <MTDec.h>
#include <ConfigDir.h>



ValidationData::ValidationData()
	: mAddDefaultValues(TRUE),
		mpPropCount(NULL),
		mpSessionContext(NULL)
{
	Clear();
}

ValidationData::~ValidationData()
{
	if (mpSessionContext)
	{
		delete [] mpSessionContext;
		mpSessionContext = NULL;
	}
}

void ValidationData::Clear()
{
	mHasServiceDefWithEncryptedProp = FALSE;

	mSDKVersion[0] = '\0';
	mIPAddress[0] = '\0';
	mMessageID[0] = '\0';

	// clears the transaction id buffer
	mTransactionID[0] = '\0';

	// clear session context variables
	mContextUsername[0] = '\0';
	mContextPassword[0] = '\0';
	mContextNamespace[0] = '\0';
	if (mpSessionContext)
	{
		delete [] mpSessionContext;
		mpSessionContext = NULL;
	}

	mRequiresFeedback = FALSE;
	mIsRetry = FALSE;
	mMeteredTime = 0;

	if (mpPropCount)
	{
		mpPropCount->total = 0;
		mpPropCount->smallStr = 0;
		mpPropCount->mediumStr = 0;
		mpPropCount->largeStr = 0;
	}

	mErrors.clear();
}



// return the length in wide characters of a UTF8 string
int UTF8StringLength(const char * apUTF8, int aLen)
{
	if (aLen == 0)
		return 0;

	ASSERT(aLen > 0);

	int len = MultiByteToWideChar(
		CP_UTF8,										// UTF8 code page
		0,													// character-type options
		apUTF8,										  // address of string to map
		aLen,												// number of bytes in string
		NULL,												// address of wide-character buffer
		0);													// size of buffer

	if (len == 0)
		return -1;

	ASSERT(len > 0);
	return len;
}

