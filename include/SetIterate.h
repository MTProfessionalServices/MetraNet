/**************************************************************************
 * @doc SETITERATE
 *
 * @module |
 *
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
 *
 * @index | SETITERATE
 ***************************************************************************/

#ifndef _SETITERATE_H
#define _SETITERATE_H

#pragma warning( disable : 4786 )

#define NUM_VARIANTS 5

template<class SET, class OBJ>
class SetIterator
{
public:
	SetIterator();
	virtual ~SetIterator();

	virtual OBJ GetNext();

	HRESULT Init(SET apSet);
	HRESULT Init(IEnumVARIANT * apVar);


	void Clear();

private:
	HRESULT NextChunk();

	void ClearVariants();

private:
	IEnumVARIANT * mpEnum;
	VARIANT mVarArray[NUM_VARIANTS];

	ULONG mFetched;
	unsigned int mIndex;
	BOOL mFinal;
};

/*********************************************** SetIterator ***/

template<class SET, class OBJ>
SetIterator<SET, OBJ>::SetIterator()
	: mpEnum(NULL), mFetched(0), mIndex(0),	mFinal(FALSE)
{
  // before a variant can be used, it must be
  // initialized.  See the VariantInit docs for more info
	for (int i = 0; i < sizeof(mVarArray) / sizeof(mVarArray[0]); i++)
		::VariantInit(&mVarArray[i]);
}

template<class SET, class OBJ>
SetIterator<SET, OBJ>::~SetIterator()
{
	Clear();
}


template<class SET, class OBJ>
HRESULT SetIterator<SET, OBJ>::Init(SET apSet)
{
	Clear();

	IUnknown * unk = NULL;
	HRESULT hr = apSet->get__NewEnum(&unk);
	if (FAILED(hr))
		return hr;
	ASSERT(unk);

	hr = unk->QueryInterface(__uuidof(IEnumVARIANT), (void**)&mpEnum);

	// no long need this one any more
	unk->Release();
	if (FAILED(hr))
		return hr;
	return S_OK;
}

template<class SET, class OBJ>
HRESULT SetIterator<SET, OBJ>::Init(IEnumVARIANT * apVar)
{
	Clear();
	mpEnum = apVar;
	return S_OK;
}

template<class SET, class OBJ>
void SetIterator<SET, OBJ>::Clear()
{
	ClearVariants();

	if (mpEnum)
	{
		mpEnum->Release();
		mpEnum = NULL;
	}

	mFetched = 0;
	mIndex = 0;
	mFinal = FALSE;
}


template<class SET, class OBJ>
void SetIterator<SET, OBJ>::ClearVariants()
{
  HRESULT hr;
	// clear any variants that were fetched
  for (int i = 0; i < (int) mFetched; i++) {
		hr = ::VariantClear(&mVarArray[i]);
    ASSERT(hr == S_OK);
  }
}



template<class SET, class OBJ>
HRESULT SetIterator<SET, OBJ>::NextChunk()
{
	ClearVariants();
	ASSERT(mpEnum);
	HRESULT hr = mpEnum->Next(sizeof(mVarArray) / sizeof(mVarArray[0]),
														mVarArray, &mFetched);
	return hr;
}


template<class SET, class OBJ>
OBJ SetIterator<SET, OBJ>::GetNext()
{
	if (!mpEnum)
		return NULL;

	HRESULT hr;
	// NOTE: at start of iteration, mIndex = mFetched = 0
	if (mIndex == (int) mFetched)
	{
		if (mFinal)
			return NULL;							// no more chunks to get

		hr = NextChunk();
		// NOTE: don't use FAILED(hr) because S_FALSE means end of list
		if (hr != S_OK)
			mFinal = TRUE;

		mIndex = 0;

		if (mFetched == 0)					// no more were fetched
			return NULL;
	}

	ASSERT(mIndex < mFetched);
	_variant_t var (mVarArray[mIndex++]);
	return OBJ(var);
}

#endif /* _SETITERATE_H */
