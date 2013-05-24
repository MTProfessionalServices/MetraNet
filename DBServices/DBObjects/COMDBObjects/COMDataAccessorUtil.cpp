// COMDataAccessorUtil.cpp : Implementation of CCCOMDataAccessorUtil
#include "StdAfx.h"
#include "COMDBObjects.h"
#include "COMDataAccessorUtil.h"

#include <string>

#include <ProductViewCollection.h>
#include <MSIXDefinition.h>

/////////////////////////////////////////////////////////////////////////////
// CCOMDataAccessorUtil


STDMETHODIMP CCOMDataAccessorUtil::GetProductViewTableName(BSTR ProductViewName, BSTR *pTableName)
{


	HRESULT hr(S_OK);

	CProductViewCollection PVColl ;
	CMSIXDefinition *pProductView ;

	//Eventually need to cache the product view collection for better performance...
	if(!PVColl.Initialize())
	{
		return Error("Unable to initialize Product View Collection",IID_ICOMDataAccessorUtil, E_FAIL);;
	}
	
	_bstr_t sTableName;

	std::wstring rwwPVName = (const wchar_t*) ProductViewName;
		
	if(PVColl.FindProductView(rwwPVName, pProductView))
	{
		sTableName = pProductView->GetTableName().c_str();
		*pTableName = sTableName.copy();
	}
	else
	{
		string buffer = "Unable to find product view ";
		buffer += ascii(rwwPVName);
		buffer += " in product view collection.";

		return Error(buffer.c_str(),IID_ICOMDataAccessorUtil, E_FAIL);;
	}


	return hr;
}
