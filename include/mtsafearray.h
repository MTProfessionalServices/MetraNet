/**************************************************************************
 * @doc MTSAFEARRAY
 *
 * @module |
 *
 *
 * Copyright 2002 by MetraTech Corporation
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | MTSAFEARRAY
 ***************************************************************************/

#ifndef _MTSAFEARRAY_H
#define _MTSAFEARRAY_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

class MTSafeByteArray
{
public:
	HRESULT Init(const unsigned char * apBytes, int aLen)
	{
		SAFEARRAY * safeArray;
		safeArray = ::SafeArrayCreateVector(VT_UI1, 0, aLen);
		if (!safeArray)
			return E_FAIL;

		BYTE HUGEP * bytes;
		HRESULT hr = SafeArrayAccessData(safeArray,
																		 (void HUGEP **) &bytes);
		if (FAILED(hr))
			return hr;

		memcpy(bytes, apBytes, aLen);
		SafeArrayUnaccessData(safeArray);

		VARIANT rawVariant;
		VariantInit(&rawVariant);

    rawVariant.vt = VT_UI1|VT_ARRAY;
    rawVariant.parray = safeArray;

		mVariant.Attach(rawVariant);
		return S_OK;
	}

	operator _variant_t ()
	{
		return mVariant;
	}

private:
	_variant_t mVariant;
};


#endif /* _MTSAFEARRAY_H */
