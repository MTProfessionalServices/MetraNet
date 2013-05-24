/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#include "StdAfx.h"
#include "MTHierarchyReports.h"
#include "SliceFactory.h"

#include <string>
#include <SliceToken.h>

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.OnlineBill.tlb> inject_statement("using namespace mscorlib;")

/////////////////////////////////////////////////////////////////////////////
// CSliceFactory

STDMETHODIMP CSliceFactory::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ISliceFactory
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CSliceFactory::FromString(BSTR aStr, IViewSlice* *apSlice)
{
	try
	{
		AutoCriticalSection critical(&mCacheLock);
		_bstr_t bstrStr(aStr);

    //Decrypt string
    try
    {
      MetraTech_OnlineBill::IQueryStringEncryptPtr qsEncrypt;
      qsEncrypt = new MetraTech_OnlineBill::IQueryStringEncryptPtr(__uuidof(MetraTech_OnlineBill::QueryStringEncrypt));
      bstrStr = qsEncrypt->DecryptString(bstrStr);  // There is no need to UrlDecode since IIS is doing this for us.
    }
	  catch(_com_error & e)
	  {
	  	  // continue on our way if failed to decrypt
		  e = NULL; // GET Rid of Warning
	  }

		std::map<_bstr_t, MTHIERARCHYREPORTSLib::IViewSlicePtr>::iterator it = mCache.find(bstrStr);
		if (it != mCache.end())
		{
			MTHIERARCHYREPORTSLib::IViewSlicePtr slice = (*it).second;

			// Make the current slice most recently used
			if(bstrStr != mLRU.front()) 
			{
				mLRU.remove(bstrStr);
				mLRU.push_front(bstrStr);
			}

			*apSlice = reinterpret_cast<IViewSlice*>(slice.Detach());
		}
		else
		{
			MTHIERARCHYREPORTSLib::ISliceFactoryPtr This(this);
			MTHIERARCHYREPORTSLib::ISliceLexerPtr lexer(__uuidof(MTHIERARCHYREPORTSLib::SliceLexer));
			lexer->Init(bstrStr);
			MTHIERARCHYREPORTSLib::IViewSlicePtr slice = This->GetSlice(lexer);		

			// Make the current slice most recently used and pop
			// the least recently used if we exceed cache size
			// (which I have hard coded to be 5 for no particular reason).
			mCache[bstrStr] = slice;
			if (mLRU.size() > 5) 
			{
				mCache.erase(mLRU.back());
				mLRU.pop_back();
			}
			mLRU.push_front(bstrStr);

			*apSlice = reinterpret_cast<IViewSlice*>(slice.Detach());
		}
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}

	return S_OK;
}

STDMETHODIMP CSliceFactory::GetSlice(ISliceLexer* apLexer, IViewSlice* *apSlice)
{
	if (!apLexer)
		return E_POINTER;
	try
	{
		MTHIERARCHYREPORTSLib::ISliceLexerPtr pLexer(apLexer);
		
		if(SliceToken::PAYERPAYEE == pLexer->LookAhead())
		{
			MTHIERARCHYREPORTSLib::IPayerAndPayeeSlicePtr slice(__uuidof(MTHIERARCHYREPORTSLib::PayerAndPayeeSlice));
      slice->FromString(pLexer);
			*apSlice = reinterpret_cast<IViewSlice*> (slice.Detach());
		}
		else if(SliceToken::PAYEE == pLexer->LookAhead())
		{
			MTHIERARCHYREPORTSLib::IPayeeSlicePtr slice(__uuidof(MTHIERARCHYREPORTSLib::PayeeSlice));
      slice->FromString(pLexer);
			*apSlice = reinterpret_cast<IViewSlice*> (slice.Detach());
		}
		else if(SliceToken::PAYER == pLexer->LookAhead())
		{
			MTHIERARCHYREPORTSLib::IPayerSlicePtr slice(__uuidof(MTHIERARCHYREPORTSLib::PayerSlice));
      slice->FromString(pLexer);
			*apSlice = reinterpret_cast<IViewSlice*> (slice.Detach());
		}
		else if(SliceToken::PAYERPAYEEENDPOINT == pLexer->LookAhead())
		{
			MTHIERARCHYREPORTSLib::IPayerAndPayeeAndEndpointSlicePtr slice(__uuidof(MTHIERARCHYREPORTSLib::PayerAndPayeeAndEndpointSlice));
      slice->FromString(pLexer);
			*apSlice = reinterpret_cast<IViewSlice*> (slice.Detach());
		}
		else if(SliceToken::PAYEEENDPOINT == pLexer->LookAhead())
		{
			MTHIERARCHYREPORTSLib::IPayeeAndEndpointSlicePtr slice(__uuidof(MTHIERARCHYREPORTSLib::PayeeAndEndpointSlice));
      slice->FromString(pLexer);
			*apSlice = reinterpret_cast<IViewSlice*> (slice.Detach());
		}
		else if(SliceToken::DESCENDENT == pLexer->LookAhead())
		{
			MTHIERARCHYREPORTSLib::IDescendentPayeeSlicePtr slice(__uuidof(MTHIERARCHYREPORTSLib::DescendentPayeeSlice));
      slice->FromString(pLexer);
			*apSlice = reinterpret_cast<IViewSlice*> (slice.Detach());
		}
		else if(SliceToken::PITEMPLATE == pLexer->LookAhead())
		{
			MTHIERARCHYREPORTSLib::IPriceableItemTemplateSlicePtr slice(__uuidof(MTHIERARCHYREPORTSLib::PriceableItemTemplateSlice));
      slice->FromString(pLexer);
			*apSlice = reinterpret_cast<IViewSlice*> (slice.Detach());
		}
		else if(SliceToken::PIINSTANCE == pLexer->LookAhead())
		{
			MTHIERARCHYREPORTSLib::IPriceableItemInstanceSlicePtr slice(__uuidof(MTHIERARCHYREPORTSLib::PriceableItemInstanceSlice));
      slice->FromString(pLexer);
			*apSlice = reinterpret_cast<IViewSlice*> (slice.Detach());
		}
		else if(SliceToken::PRODUCTVIEW == pLexer->LookAhead())
		{
			MTHIERARCHYREPORTSLib::IProductViewSlicePtr slice(__uuidof(MTHIERARCHYREPORTSLib::ProductViewSlice));
      slice->FromString(pLexer);
			*apSlice = reinterpret_cast<IViewSlice*> (slice.Detach());
		}
		else if(SliceToken::SESSIONCHILDREN == pLexer->LookAhead())
		{
			MTHIERARCHYREPORTSLib::ISessionChildrenSlicePtr slice(__uuidof(MTHIERARCHYREPORTSLib::SessionChildrenSlice));
      slice->FromString(pLexer);
			*apSlice = reinterpret_cast<IViewSlice*> (slice.Detach());
		}
		else if(SliceToken::SESSION == pLexer->LookAhead())
		{
			MTHIERARCHYREPORTSLib::ISessionSlicePtr slice(__uuidof(MTHIERARCHYREPORTSLib::SessionSlice));
      slice->FromString(pLexer);
			*apSlice = reinterpret_cast<IViewSlice*> (slice.Detach());
		}
		else if(SliceToken::ROOT == pLexer->LookAhead())
		{
			MTHIERARCHYREPORTSLib::IRootSessionSlicePtr slice(__uuidof(MTHIERARCHYREPORTSLib::RootSessionSlice));
      slice->FromString(pLexer);
			*apSlice = reinterpret_cast<IViewSlice*> (slice.Detach());
		}
		else if(SliceToken::ALLSESSION == pLexer->LookAhead())
		{
			MTHIERARCHYREPORTSLib::IAllSessionSlicePtr slice(__uuidof(MTHIERARCHYREPORTSLib::AllSessionSlice));
      slice->FromString(pLexer);
			*apSlice = reinterpret_cast<IViewSlice*> (slice.Detach());
		}
		else if(SliceToken::DATERANGE == pLexer->LookAhead())
		{
			MTHIERARCHYREPORTSLib::IDateRangeSlicePtr slice(__uuidof(MTHIERARCHYREPORTSLib::DateRangeSlice));
      slice->FromString(pLexer);
			*apSlice = reinterpret_cast<IViewSlice*> (slice.Detach());
		}
		else if(SliceToken::USAGEINTERVAL == pLexer->LookAhead())
		{
			MTHIERARCHYREPORTSLib::IUsageIntervalSlicePtr slice(__uuidof(MTHIERARCHYREPORTSLib::UsageIntervalSlice));
      slice->FromString(pLexer);
			*apSlice = reinterpret_cast<IViewSlice*> (slice.Detach());
		}
		else if(SliceToken::INTERSECTION == pLexer->LookAhead())
		{
			MTHIERARCHYREPORTSLib::IIntersectionTimeSlicePtr slice(__uuidof(MTHIERARCHYREPORTSLib::IntersectionTimeSlice));
      slice->FromString(pLexer);
			*apSlice = reinterpret_cast<IViewSlice*> (slice.Detach());
		}
		else
		{
			return Error("Parse Error");
		}
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
}
