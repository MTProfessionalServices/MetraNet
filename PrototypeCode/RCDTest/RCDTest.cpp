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

#include <mtcom.h>
#include <adsiutil.h>
#include <adsiuser.h>
#include <metra.h>
#include <iostream>
#include <mtprogids.h>
#include <SetIterate.h>

using std::cout;
using std::endl;

static ComInitialize GComInitialize;

#import <RCD.tlb>

template<>
_variant_t SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t>::GetNext()
{
	if (!mpEnum)
		return _variant_t("");

	HRESULT hr;
	// NOTE: at start of iteration, mIndex = mFetched = 0
	if (mIndex == (int) mFetched)
	{
		if (mFinal)
			return _variant_t("");							// no more chunks to get

		hr = NextChunk();
		// NOTE: don't use FAILED(hr) because S_FALSE means end of list
		if (hr != S_OK)
			mFinal = TRUE;

		mIndex = 0;

		if (mFetched == 0)					// no more were fetched
			return _variant_t("");	
	}

	ASSERT(mIndex < mFetched);
	_variant_t var (mVarArray[mIndex++]);
	return _variant_t(var);
}



int main (int argc, char ** argv)
{
	RCDLib::IMTRcdFileListPtr aFileListObj("MetraTech.RcdFileList.1");
	
	aFileListObj->AddFile("foo");
	aFileListObj->AddFile("bar");


	SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;

	
  if(FAILED(it.Init(aFileListObj))) return FALSE;
  while (TRUE)
	{
		_variant_t aVariant= it.GetNext();
		_bstr_t afile = aVariant;
		if(afile == _bstr_t("")) break;

		cout << (const char*)afile << endl;
	}

 return TRUE;
}



