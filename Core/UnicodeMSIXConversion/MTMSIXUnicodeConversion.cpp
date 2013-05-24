/**************************************************************************
* Copyright 1997-2001 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header$
* 
***************************************************************************/

#include <metra.h>
#include "MTMSIXUnicodeConversion.h"


const char* MTMSIXUnicodeConversion::ConvertToASCII()
{
	// move past marker information if present
	if(HasUnicodeMarker()) {
		// move past unicode marker
		mOriginalStr += 2;
	}

	// check if the buffer looks like UNICODE
	if(IsUnicodeBuffer()) {

		if(mOriginalSize == 0) {
			mOriginalSize = wcslen((const wchar_t*)mOriginalStr);
		}

		// delete any allocated memory
		if(mAllocatedBuffer) {
			delete[] mAllocatedBuffer;
		}

		mAllocatedBuffer = new char[GetOriginalSize()+1];

		mBufferSize = ::WideCharToMultiByte(CP_ACP, // ANSI code page
			0, // no flags
			(wchar_t*)mOriginalStr,
			GetOriginalSize(), // run till we find the end of string terminator
			mAllocatedBuffer,
			GetOriginalSize(), // length of new buffer
			NULL, // default char
			NULL);

		// OK... lets be realistic.  This is not going to fail and if it
		// does it will be really bad.  We could derive from ErrObject here and
		// get the detailed error msg but why do this when I can have some poor
		// lackey clean up this mess long after I am gone (insert evil chuckle)

		if(mBufferSize == 0) {
			long Error = ::GetLastError();
			ASSERT("Conversion failure!!");
			delete[] mAllocatedBuffer;
			mAllocatedBuffer = NULL;
			return NULL;
		}

		mAllocatedBuffer[mBufferSize] ='\0';
		return mAllocatedBuffer;
	}
	else {

		if(mOriginalSize == 0) {
			mOriginalSize = strlen(mOriginalStr);
		}
		return mOriginalStr;
	}
}
