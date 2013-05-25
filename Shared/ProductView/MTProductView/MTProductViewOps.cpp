// MTProductViewOps.cpp : Implementation of CMTProductViewOps
#include "StdAfx.h"
#include "MTProductView.h"
#include "MTProductViewOps.h"
#include <ProductViewOps.h>
#include <comutil.h>
#include <mtprogids.h>
#include <vector>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
#import <MTProductView.tlb> rename ("EOF", "EOFX")
#import <MTEnumConfigLib.tlb>

/////////////////////////////////////////////////////////////////////////////
// CMTProductViewOps

STDMETHODIMP CMTProductViewOps::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTProductViewOps
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTProductViewOps::AddProductView
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTProductViewOps::AddProductView(BSTR xmlFile)
{
	ASSERT(xmlFile);
	ProductViewOps aPVOps;
	HRESULT hr = S_OK;

	if(aPVOps.Initialize()) {
		if(!aPVOps.AddTable(_bstr_t(xmlFile))) {
			hr = Error(aPVOps.GetLastError()->GetProgrammerDetail().c_str());
		}
	}
	return hr;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTProductViewOps::AddAllProductViews
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTProductViewOps::AddAllProductViews()
{
	ProductViewOps aPVOps;
	HRESULT hr = S_OK;

	if(aPVOps.Initialize()) {
		if(!aPVOps.AddTable(NULL)) {
			hr = Error(aPVOps.GetLastError()->GetProgrammerDetail().c_str());
		}
	}
	return hr;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTProductViewOps::DropProductView
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTProductViewOps::DropProductView(BSTR xmlFile)
{
	ASSERT(xmlFile);
	ProductViewOps aPVOps;
	HRESULT hr = S_OK;

	if(aPVOps.Initialize()) {
		if(!aPVOps.DropTable(_bstr_t(xmlFile))) {
			hr = Error(aPVOps.GetLastError()->GetProgrammerDetail().c_str());
		}
	}
	return hr;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTProductViewOps::DropAllProductViews
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTProductViewOps::DropAllProductViews()
{
	ProductViewOps aPVOps;
	HRESULT hr = S_OK;

	if(aPVOps.Initialize()) {
		if(!aPVOps.DropTable(NULL)) {
			hr = Error(aPVOps.GetLastError()->GetProgrammerDetail().c_str());
		}
	}
	return hr;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTProductViewOps::UpgradeProductViews30To35()
// Description	  : Finds all product views that have been installed into the
//                  database and populates the t_prod_view table for them.
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTProductViewOps::UpgradeProductViews30To35()
{
	HRESULT hr = S_OK;

	try
	{
		// Try caching the enum config object since it seems to
		// be getting loaded each time a ProductView is created.
		MTENUMCONFIGLib::IEnumConfigPtr pEnumConfig(MTPROGID_ENUM_CONFIG);		
		
		// Find all product views that exist in the db.
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init("Queries\\Database");
		rowset->SetQueryTag("__GET_INSTALLED_PRODUCT_VIEWS__");
		rowset->Execute();
		
		std::vector<MTPRODUCTVIEWLib::IProductViewPtr> pvs;

		while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			_bstr_t prodViewName = _bstr_t(rowset->GetValue(L"nm_product_view"));
			
			// Find their corresponding .msixdef files and load up the object
			MTPRODUCTVIEWLib::IProductViewPtr pv(__uuidof(MTPRODUCTVIEWLib::ProductView));
			try
			{
				pv->Init(prodViewName, FALSE);
			}
			catch(_com_error & e)
			{
				e; // not used

				// This is a bad thing!  There a product view in the database,
				// but its .msixdef cannot be found.  This probably will happen
				// if we have "deprecated" a product view, so lets just move on.
				rowset->MoveNext();
				continue;
			}

			// Add the pv to the collection that we will create.
			pvs.push_back(pv);

			rowset->MoveNext();
		}

		rowset->Clear();
		
		// Save into the db.
		for(std::vector<MTPRODUCTVIEWLib::IProductViewPtr>::iterator it = pvs.begin(); it != pvs.end(); it++)
		{
			(*it)->Save();
		}
	}
	catch(_com_error & err)
	{
		return returnProductViewError(err);
	}

	return hr;
}
