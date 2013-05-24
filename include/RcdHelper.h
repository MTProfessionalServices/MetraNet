/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by: 
* $Header$
* 
***************************************************************************/

#ifndef __RCDHELPER_H__
#define __RCDHELPER_H__

// must be inline to avoid link errors

 template<> inline
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


#endif //__RCDHELPER_H__