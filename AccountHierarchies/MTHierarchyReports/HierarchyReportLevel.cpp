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

#pragma warning(disable: 4800)  // disable warning 'MetraTech_DataAccess_Mforcing value to bool 'true' or 'false' (performance warning)

#include "MTHierarchyReports.h"
#include "HierarchyReportLevel.h"
#include <metra.h>
// The explicit include of fastbuffer.h seems necessary to avoid
// an internal compiler error [dblair 02/08/02]
#include <fastbuffer.h>
#include <mtprogids.h>
#include <mtcomerr.h>
#include <formatdbvalue.h>
#include <MTUtil.h>

#import "msxml4.dll"        //msxml 4.0 parser
using namespace MSXML2;


#import <rowsetinterfaceslib.tlb> rename("EOF", "RowsetEOF")
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" ) 

/////////////////////////////////////////////////////////////////////////////
// CHierarchyReportLevel

STDMETHODIMP CHierarchyReportLevel::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IHierarchyReportLevel,
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


CHierarchyReportLevel::CHierarchyReportLevel()
	:
	mHydrated(false),
	mPayerId(-1),
	mPayerReport(VARIANT_FALSE),
	mSecondPass(VARIANT_FALSE),
	mTimeSlice(NULL)
{
	mstrReportXML = "";
  LoggerConfigReader configReader;
  mLogger.Init(configReader.ReadConfiguration("logging"), "[HierarchyReportLevel]");

	MetraTech_DataAccess_MaterializedViews::IManagerPtr mgr = new MetraTech_DataAccess_MaterializedViews::IManagerPtr(__uuidof(MetraTech_DataAccess_MaterializedViews::Manager));
	ASSERT(mgr != NULL);
    mgr->Initialize();
	mMVMEnabled = (mgr->GetIsMetraViewSupportEnabled() == VARIANT_TRUE);
}

CHierarchyReportLevel::~CHierarchyReportLevel()
{
}

STDMETHODIMP CHierarchyReportLevel::GetPropertyName(int intIndex, VARIANT *pVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CHierarchyReportLevel::GetPropertyValue(VARIANT strPropName, VARIANT *pVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CHierarchyReportLevel::GetChildLevel(int intIndex, IHierarchyReportLevel **pChildLevel)
{
	if(!pChildLevel) 
		return E_POINTER;
	else
		*pChildLevel = NULL;

	try 
	{
    //Noah 3/19 -- Index now comes in zero based.
		HRESULT hr;
		if(FAILED(hr=mLevels.Item(intIndex + 1, pChildLevel))) return hr;

		//if(mServiceEndpointIds[intIndex] == -1)
		//{
			IDateRangeSlice* pAccountEffDate = NULL;
			if(FAILED(hr=mLevelEffDates.Item(intIndex + 1, &pAccountEffDate))) return hr;

			// Hydrate the child (note MTObjectCollection is 1-based, STL vector is 0-based).
			hr = (*pChildLevel)->InitByFolderReport(mChildIds[intIndex], mPayerId, 
																							pAccountEffDate,
																							reinterpret_cast<IDateRangeSlice*> (mTimeSlice.GetInterfacePtr()),
																							mLanguageCode, mPayerReport, mSecondPass);
		//}
		//else
		//{
			// Hydrate the child (note MTObjectCollection is 1-based, STL vector is 0-based).
		//	hr = (*pChildLevel)->InitByFolderServiceEndpointReport(mChildIds[intIndex], mServiceEndpointIds[intIndex], mPayerId, 
		//																												 reinterpret_cast<IDateRangeSlice*> (mTimeSlice.GetInterfacePtr()),
		//																												 mLanguageCode, mPayerReport, mSecondPass);
		//}
    if (FAILED(hr)) return hr;
	} 
	catch(_com_error & err)
	{
		return returnHierarchyReportError(err);
	}

	return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Function    : GetReportLevelAsXML(bRecurse)                             //
//  Description : Get the XML for the hierarchy report level.               //
//  Inputs      : bRecurse -- Specify whether the XML for child levels      //
//  Outputs     : XML for the level                                         //
//              : bRecurse = false                                          //
//              : <level>                                                   //
//              :   <id />                                                  //
//              :     .                                                     //
//              :   <children>                                              //
//              :     <level>                                               //
//              :        .                                                  //
//              :        .                                                  //
//              :     </level>                                              //
//              :   </children>                                             //
//              : </level>                                                  //
//              :                                                           //
//              : bRecurse = true                                           //
//              : <level>                                                   //
//              :   <id />                                                  //
//              :     .                                                     //
//              :   <level>                                                 //
//              :     <id />                                                //
//              :      .                                                    //
//              :      .                                                    //
//              :   </level>                                                //
//              : </level>                                                  //
//              :                                                           //
//              : Note: Some tags left out for clarity.                     //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CHierarchyReportLevel::GetReportLevelAsXML(VARIANT_BOOL bRecurse, BSTR *pVal)
{
  MSXML2::IXMLDOMDocumentPtr spOutputXML("MSXML2.DOMDocument.4.0");
  _bstr_t strXML;

  try
  {
    //If not recursing, just output this level
    if(!bRecurse) {
      *pVal = mstrReportXML.copy();
      return(S_OK);
    
    } else {
      MTHIERARCHYREPORTSLib::IHierarchyReportLevel *pReportLevel;
      MTHIERARCHYREPORTSLib::IHierarchyReportLevelPtr spReportLevel;
      
      MSXML2::IXMLDOMDocumentPtr spTempXML("MSXML2.DOMDocument.4.0");
      MSXML2::IXMLDOMParseErrorPtr spParseError = NULL;
      MSXML2::IXMLDOMNodePtr spChildrenNode;

      long lngErrorCode = 0;
      long lngCount = 0;
      long i = 0;
      
      HRESULT hr;

      //Get the XML for the current level
      strXML = mstrReportXML;

      //Check the length
      if(strXML.length() > 0) 
      {
        //Attempt to load
        if(!spOutputXML->loadXML(strXML))
          return E_FAIL;

        //Check for parse error
        spParseError = spOutputXML->parseError;

        lngErrorCode = spParseError->errorCode;

        if(lngErrorCode != 0)
          return E_FAIL;

        //Else, everything's okay
        //Remove the children node
        spChildrenNode = spOutputXML->selectSingleNode("children");

        if(spChildrenNode != NULL)
          spChildrenNode->parentNode->removeChild(spChildrenNode);

        //Add all the child levels
        if(FAILED(hr = mLevels.Count(&lngCount)))
          return(E_FAIL);

        for(i = 0; i < lngCount; i++) 
        {
          if(FAILED(hr = GetChildLevel(i, (IHierarchyReportLevel **)&pReportLevel)))
            return(E_FAIL);

          spReportLevel = pReportLevel;

          //Get the XML for the child level and load it
          strXML = spReportLevel->GetReportLevelAsXML(true);
          
          if(strXML.length() > 0) {
            if(!spTempXML->loadXML(strXML))
              return E_FAIL;

              //Check for parse error
              spParseError = spTempXML->parseError;

              lngErrorCode = spParseError->errorCode;
    
              if(lngErrorCode != 0)
                return E_FAIL;

            //Else, everything's okay
            //Remove the children node
            spChildrenNode = spTempXML->selectSingleNode("children");

            if(spChildrenNode != NULL)
              spChildrenNode->parentNode->removeChild(spChildrenNode);


            //Add the child levels to the outputs
            spOutputXML->documentElement->appendChild(spTempXML->documentElement);
          
          }  //if length > 0
        } //for
      } //if length > 0
    } //if !bRecurse

    //Write the output
    *pVal = spOutputXML->xml;

  } //try
  
  catch(_com_error &err)
  {
		return returnHierarchyReportError(err);
  }

	return S_OK;
}

STDMETHODIMP CHierarchyReportLevel::get_NumProperties(long *pVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CHierarchyReportLevel::get_NumChildren(long *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = (long) mChildIds.size();

	return S_OK;
}

STDMETHODIMP CHierarchyReportLevel::InitByProductReport(int intPayerId, 
																												ITimeSlice *apTimeSlice, 
																												int intLanguageCode,
																												VARIANT_BOOL bPayerReport,
																												VARIANT_BOOL bSecondPass)
{
	HRESULT hr = S_OK;

	// Make it safe to call init multiple times.
	if (mHydrated) 
	{
		return hr;
	}
	else
	{
		mHydrated = true;
	}

	try
	{
		// Record who the payer is
		mPayerId = intPayerId;
		mPayerReport = bPayerReport;
		mSecondPass = bSecondPass;
		mTimeSlice = apTimeSlice;
		mLanguageCode = intLanguageCode;

		mLogger.LogVarArgs(LOG_DEBUG, 
											 "HierarchyReportLevel::InitByProductReport(%d, %s, %d, %d, %d)",
											 intPayerId, 
											 (const char *)mTimeSlice->ToString(),
											 intLanguageCode,
											 bPayerReport,
											 bSecondPass);

		if(mPayerReport == VARIANT_TRUE)
		{
			mLogger.LogVarArgs(LOG_DEBUG, "Creating by product bill report for account id = %d", intPayerId);
		}
		else
		{
			mLogger.LogVarArgs(LOG_DEBUG, "Creating by product hierarchy report for account id = %d", intPayerId);
		}

		// We'll use the DOM objects to create the associated XML
		IXMLDOMDocument2Ptr pXMLDoc("MSXML2.DOMDocument.4.0");
		MSXML2::IXMLDOMElementPtr pLevelElement = pXMLDoc->createElement(L"level");
		pXMLDoc->documentElement = pLevelElement;


		// TODO: Do we want a charges element or do we put
		// all the product gook directly beneath the level element?
		// I am hacking the code to put stuff directly under <level>
    // NOAH -- 2/05/02 -- To be consistent, add the charges element
    MSXML2::IXMLDOMElementPtr pChargesElement = pXMLDoc->createElement(L"charges");
		//MSXML2::IXMLDOMElementPtr pChargesElement = pLevelElement;

		// The current product offering
		long id_prod = -1L;
		MSXML2::IXMLDOMElementPtr pProductOfferingElement;

		_variant_t vtPayerId((long)intPayerId, VT_I4);
		_variant_t vtAccountId(1L);

		if(VARIANT_TRUE == mPayerReport)
		{
			// This is the root of a payer report.  Fetch the corporate account.
			// TODO: The effective date logic here needs to be thought through.
			DATE dtBegin, dtEnd;
			mTimeSlice->GetTimeSpan(&dtBegin, &dtEnd);
			long corporateId;
			if(FAILED(hr=GetCorporateAccount(mPayerId, _variant_t(dtEnd, VT_DATE), &corporateId))) return hr;

			mLogger.LogVarArgs(LOG_DEBUG, "By product payer report for account id = %d is being "
												 "based on corporate account id = %d", mPayerId, corporateId);

			vtAccountId = corporateId;
		}
		else
		{
			vtAccountId = vtPayerId;
		}

		// For payer (i.e. bill) reports, we need to generate a total over
		// all accounts and all products.  These used to only be for bills (i.e. payerreport)
		// but in 3.5 we decided to put them on all by-folder reports.
		{
			ROWSETLib::IMTSQLRowsetPtr rowset2(MTPROGID_SQLROWSET);
			rowset2->Init(L"\\Queries\\PresServer");

      // In 3.5 we decided that we wanted a totals section on the by-folder
			// reports.
			if (VARIANT_TRUE == mPayerReport)
			{
				rowset2->SetQueryTag(mMVMEnabled ? L"__GET_ALLPRODUCTSALLACCOUNTSFORPAYER_DATAMART__"
						                             : L"__GET_ALLPRODUCTSALLACCOUNTSFORPAYER__");
				rowset2->AddParam(L"%%ID_PAYER%%", vtPayerId, VARIANT_TRUE);
			}
			else
			{
				rowset2->SetQueryTag(mMVMEnabled ? L"__GET_ALLPRODUCTSALLACCOUNTS_DATAMART__"
						                             : L"__GET_ALLPRODUCTSALLACCOUNTS__");
			}
			rowset2->AddParam(L"%%ID_ACC%%", vtAccountId, VARIANT_TRUE);
			rowset2->AddParam(L"%%TIME_PREDICATE%%", mTimeSlice->GenerateQueryPredicate(), VARIANT_TRUE);
			rowset2->AddParam(L"%%LIKE_OR_NOT_LIKE%%", mSecondPass == VARIANT_TRUE ? L" NOT LIKE " : L" LIKE ");

			DATE dtBegin, dtEnd;
			if(VARIANT_FALSE == mPayerReport)
			{
				mTimeSlice->GetTimeSpan(&dtBegin, &dtEnd);
			}
			else
			{
				dtBegin = 25569.00;
				dtEnd = 50406;
			}
			rowset2->AddParam(L"%%DT_BEGIN%%", _variant_t(dtBegin, VT_DATE));
			rowset2->AddParam(L"%%DT_END%%", _variant_t(dtEnd, VT_DATE));

			rowset2->Execute();

			// One row per currency.  We only know how to handle a single
			// currency per account though
			if(!bool(rowset2->RowsetEOF))
			{
					MSXML2::IXMLDOMElementPtr pAmount = pXMLDoc->createElement(L"amount");
  				pAmount->text = _bstr_t(rowset2->GetValue(L"TotalAmount"));

          MSXML2::IXMLDOMAttributePtr pUOMAttr = pXMLDoc->createAttribute(L"uom");
          
          _bstr_t bstrCurrency = _bstr_t(rowset2->GetValue(L"Currency"));

          pUOMAttr->value = bstrCurrency;
          
          pAmount->attributes->setNamedItem(pUOMAttr);
          
          pLevelElement->appendChild(pAmount);

          CreateAdjustmentTags(rowset2, pXMLDoc, pLevelElement);

					MSXML2::IXMLDOMElementPtr pTax = pXMLDoc->createElement(L"tax");
					pTax->text = _bstr_t(rowset2->GetValue(L"TotalTax"));

          MSXML2::IXMLDOMAttributePtr pUOMAttr2 = pXMLDoc->createAttribute(L"uom");
          pUOMAttr2->value = _bstr_t(rowset2->GetValue(L"Currency"));
          pTax->attributes->setNamedItem(pUOMAttr2);
					pLevelElement->appendChild(pTax);
			}
		}

		// Let's work up the kiddies.  Note that this query will also
		// do a summary for the parent we are dealing with.
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(L"\\Queries\\PresServer");
    
		if(VARIANT_FALSE == mPayerReport)
		{
			rowset->SetQueryTag(mMVMEnabled ? L"__GET_BYPRODUCTALLACCOUNTS_DATAMART__"
                                      : L"__GET_BYPRODUCTALLACCOUNTS__");
		}
		else
		{
			// Here we are doing a "By-Originator" report but only for charges payed
			// for by a single account.
			rowset->SetQueryTag(mMVMEnabled ? L"__GET_BYPRODUCTALLACCOUNTSFORPAYER_DATAMART__"
						                          : L"__GET_BYPRODUCTALLACCOUNTSFORPAYER__");
			rowset->AddParam(L"%%ID_PAYER%%", vtPayerId, VARIANT_TRUE);
		}

		// Do the common query parameters
		rowset->AddParam(L"%%ID_ACC%%", vtAccountId, VARIANT_TRUE);
		rowset->AddParam(L"%%ID_LANG%%", _variant_t((long)mLanguageCode));
		rowset->AddParam(L"%%TIME_PREDICATE%%", mTimeSlice->GenerateQueryPredicate(), VARIANT_TRUE);
		rowset->AddParam(L"%%LIKE_OR_NOT_LIKE%%", mSecondPass == VARIANT_TRUE ? L" NOT LIKE " : L" LIKE ");

		DATE dtBegin, dtEnd;
		if(VARIANT_FALSE == mPayerReport)
		{
			mTimeSlice->GetTimeSpan(&dtBegin, &dtEnd);
		}
		else
		{
			dtBegin = 25569.00;
			dtEnd = 50406;
		}
		std::wstring buffer;
		BOOL bSuccess = FormatValueForDB(_variant_t(dtBegin, VT_DATE), FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return Error("Failure formatting DATE for database write");
		}
		rowset->AddParam(L"%%DT_BEGIN%%", buffer.c_str(), VARIANT_TRUE);

    bSuccess = FormatValueForDB(_variant_t(dtEnd, VT_DATE), FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return Error("Failure formatting DATE for database write");
		}
		rowset->AddParam(L"%%DT_END%%", buffer.c_str(), VARIANT_TRUE);

		// Create an appropriate account slice for the report and stuff it in
		// the level element.
		if(VARIANT_FALSE == mPayerReport)
		{
			MTHIERARCHYREPORTSLib::IDescendentPayeeSlicePtr spHierarchySlice("MTHierarchyReports.DescendentPayeeSlice.1");
			spHierarchySlice->AncestorID = vtAccountId;
			spHierarchySlice->Begin = dtBegin;
			spHierarchySlice->End = dtEnd;
			MSXML2::IXMLDOMElementPtr internal_id = pXMLDoc->createElement(L"internal_id");
			internal_id->text = spHierarchySlice->ToString();
			pLevelElement->appendChild(internal_id);
			// Also record the account slice used for this report.  It happens to be
			// the same as the internal_id for by product reports, but it won't be for
			// by folder reports.
			MSXML2::IXMLDOMElementPtr summary_slice = pXMLDoc->createElement(L"account_summary_slice");
			summary_slice->text = spHierarchySlice->ToString();
			pLevelElement->appendChild(summary_slice);
		}
		else
		{
			MSXML2::IXMLDOMElementPtr internal_id = pXMLDoc->createElement(L"internal_id");
			MTHIERARCHYREPORTSLib::IPayerSlicePtr spPayerSlice("MTHierarchyReports.PayerSlice.1");
			spPayerSlice->PayerID = vtPayerId;
			internal_id->text = spPayerSlice->ToString();
			pLevelElement->appendChild(internal_id);
			// Also record the account slice used for this report.  It happens to be
			// the same as the internal_id for by product reports, but it won't be for
			// by folder reports.
			MSXML2::IXMLDOMElementPtr summary_slice = pXMLDoc->createElement(L"account_summary_slice");
			summary_slice->text = spPayerSlice->ToString();
			pLevelElement->appendChild(summary_slice);
		}

		rowset->Execute();

    while(!bool(rowset->RowsetEOF))
		{
			if(VT_NULL == rowset->GetValue(L"PriceableItemTemplateId").vt)
			{
				// This is non-product catalog usage.  We will pretend that
				// it is priceable item template usage.
				// <charges>
				//   <pi uom="USD">
				//     <id>Template Name</pi>
				//     <amount>Template amount</amount>
				//   </pi>
				// </charges>

        //TODO: there is no adjustments against non prodcat usage
        //do we still need to generate same XML format?
				MSXML2::IXMLDOMElementPtr pViewElement = pXMLDoc->createElement(L"pi");
        MSXML2::IXMLDOMAttributePtr pUOMAttr = pXMLDoc->createAttribute(L"uom");
        pUOMAttr->value = _bstr_t(rowset->GetValue(L"Currency"));
        pViewElement->attributes->setNamedItem(pUOMAttr);
				MSXML2::IXMLDOMElementPtr id = pXMLDoc->createElement(L"id");
				id->text = _bstr_t(rowset->GetValue(L"ViewName"));
				pViewElement->appendChild(id);
				MSXML2::IXMLDOMElementPtr internal_id = pXMLDoc->createElement(L"internal_id");
				MTHIERARCHYREPORTSLib::IProductViewSlicePtr pView(__uuidof(MTHIERARCHYREPORTSLib::ProductViewSlice));
				pView->ViewID = (long) rowset->GetValue(L"ViewId");
				internal_id->text = pView->ToString();
				pViewElement->appendChild(internal_id);
				MSXML2::IXMLDOMElementPtr amount = pXMLDoc->createElement(L"amount");
				amount->text = _bstr_t(rowset->GetValue(L"TotalAmount"));
				pViewElement->appendChild(amount);
        CreateAdjustmentTags(rowset, pXMLDoc, pViewElement);
				MSXML2::IXMLDOMElementPtr agg = pXMLDoc->createElement(L"is_aggregate");
				agg->text = _bstr_t(L"N");
				pViewElement->appendChild(agg);
				pChargesElement->appendChild(pViewElement);
			}
			else if(VT_NULL == rowset->GetValue(L"ProductOfferingId").vt)
			{
				// This is non-product offering usage.
				// <charges>
				//   <pi>
				//     <id>Template Name</pi>
				//     <amount>Template amount</amount>
				//   </pi>
				// </charges>
				MSXML2::IXMLDOMElementPtr pTemplateElement = pXMLDoc->createElement(L"pi");
        MSXML2::IXMLDOMAttributePtr pUOMAttr = pXMLDoc->createAttribute(L"uom");
        pUOMAttr->value = _bstr_t(rowset->GetValue(L"Currency"));
        pTemplateElement->attributes->setNamedItem(pUOMAttr);
				MSXML2::IXMLDOMElementPtr id = pXMLDoc->createElement(L"id");
				id->text = _bstr_t(rowset->GetValue(L"PriceableItemName"));
				pTemplateElement->appendChild(id);
				MSXML2::IXMLDOMElementPtr internal_id = pXMLDoc->createElement(L"internal_id");
				MTHIERARCHYREPORTSLib::IPriceableItemTemplateSlicePtr pTemplate(__uuidof(MTHIERARCHYREPORTSLib::PriceableItemTemplateSlice));
				pTemplate->TemplateID = (long) rowset->GetValue(L"PriceableItemTemplateId");
				pTemplate->ViewID = (long) rowset->GetValue(L"ViewId");
				internal_id->text = pTemplate->ToString();
				pTemplateElement->appendChild(internal_id);

				MSXML2::IXMLDOMElementPtr amount = pXMLDoc->createElement(L"amount");
				amount->text = _bstr_t(rowset->GetValue(L"TotalAmount"));
				pTemplateElement->appendChild(amount);
        CreateAdjustmentTags(rowset, pXMLDoc, pTemplateElement);
				MSXML2::IXMLDOMElementPtr agg = pXMLDoc->createElement(L"is_aggregate");
				agg->text = _bstr_t(rowset->GetValue(L"IsAggregate"));
				pTemplateElement->appendChild(agg);
				pChargesElement->appendChild(pTemplateElement);
			}
			else
			{
				if((long)rowset->GetValue(L"ProductOfferingId") != id_prod)
				{
					pProductOfferingElement = pXMLDoc->createElement(L"po");
					pChargesElement->appendChild(pProductOfferingElement);
					MSXML2::IXMLDOMElementPtr id = pXMLDoc->createElement(L"id");
					id->text = _bstr_t(rowset->GetValue(L"ProductOfferingName"));
					pProductOfferingElement->appendChild(id);
					MSXML2::IXMLDOMElementPtr internal_id = pXMLDoc->createElement(L"internal_id");
					internal_id->text = _bstr_t(rowset->GetValue(L"ProductOfferingId"));
					pProductOfferingElement->appendChild(internal_id);
					// TODO: Fix the query so that we get the PO level summary amounts
					MSXML2::IXMLDOMElementPtr amount = pXMLDoc->createElement(L"amount");
					amount->text = L"TBD";
					pProductOfferingElement->appendChild(amount);
          CreateAdjustmentTags(rowset, pXMLDoc, pProductOfferingElement);
					id_prod = rowset->GetValue(L"ProductOfferingId");
				}

				MSXML2::IXMLDOMElementPtr pInstanceElement = pXMLDoc->createElement(L"pi");
        MSXML2::IXMLDOMAttributePtr pUOMAttr = pXMLDoc->createAttribute(L"uom");
        pUOMAttr->value = _bstr_t(rowset->GetValue(L"Currency"));
        pInstanceElement->attributes->setNamedItem(pUOMAttr);
				MSXML2::IXMLDOMElementPtr id = pXMLDoc->createElement(L"id");
				id->text = _bstr_t(rowset->GetValue(L"PriceableItemInstanceName"));
				pInstanceElement->appendChild(id);
				MSXML2::IXMLDOMElementPtr internal_id = pXMLDoc->createElement(L"internal_id");
				MTHIERARCHYREPORTSLib::IPriceableItemInstanceSlicePtr pInstance(__uuidof(MTHIERARCHYREPORTSLib::PriceableItemInstanceSlice));
				pInstance->InstanceID = (long) rowset->GetValue(L"PriceableItemInstanceId");
				pInstance->ViewID = (long) rowset->GetValue(L"ViewId");
				internal_id->text = pInstance->ToString();
				pInstanceElement->appendChild(internal_id);

				MSXML2::IXMLDOMElementPtr amount = pXMLDoc->createElement(L"amount");
				amount->text = _bstr_t(rowset->GetValue(L"TotalAmount"));
				pInstanceElement->appendChild(amount);
        CreateAdjustmentTags(rowset, pXMLDoc, pInstanceElement);
				MSXML2::IXMLDOMElementPtr agg = pXMLDoc->createElement(L"is_aggregate");
				agg->text = _bstr_t(rowset->GetValue(L"IsAggregate"));
				pInstanceElement->appendChild(agg);

				pProductOfferingElement->appendChild(pInstanceElement);
			}
			rowset->MoveNext();
		}

    //Append the charges to the level
    pLevelElement->appendChild(pChargesElement);

		mstrReportXML = pXMLDoc->xml;
	}
	catch (_com_error & err) 
	{
		return returnHierarchyReportError(err);
	}

	return hr;
}

HRESULT CHierarchyReportLevel::ConvertProductSummaryRowsetToXml(ROWSETLib::IMTSQLRowsetPtr rowset,
																																MSXML2::IXMLDOMDocument2Ptr pXMLDoc,
																																MSXML2::IXMLDOMElementPtr pChargesElement)
{
	HRESULT hr = S_OK;

	try
	{
		// The current product offering
		long id_prod = -1L;
		MSXML2::IXMLDOMElementPtr pProductOfferingElement;

		// Iterate over, "parse" the rowset and assemble the XML
		int numRows=0;
		while(!bool(rowset->RowsetEOF))
		{
			if(VT_NULL == rowset->GetValue(L"PriceableItemTemplateId").vt)
			{
				// This is non-product catalog usage.  We will pretend that
				// it is priceable item template usage.
				// <charges>
				//   <pi>
				//     <id>Template Name</pi>
				//     <amount>Template amount</amount>
				//   </pi>
				// </charges>
				MSXML2::IXMLDOMElementPtr pViewElement = pXMLDoc->createElement(L"pi");
				MSXML2::IXMLDOMAttributePtr pUOMAttr = pXMLDoc->createAttribute(L"uom");
				pUOMAttr->value = _bstr_t(rowset->GetValue(L"Currency"));
				pViewElement->attributes->setNamedItem(pUOMAttr);
				MSXML2::IXMLDOMElementPtr id = pXMLDoc->createElement(L"id");
				id->text = _bstr_t(rowset->GetValue(L"ViewName"));
				pViewElement->appendChild(id);
				MSXML2::IXMLDOMElementPtr internal_id = pXMLDoc->createElement(L"internal_id");
				MTHIERARCHYREPORTSLib::IProductViewSlicePtr pView(__uuidof(MTHIERARCHYREPORTSLib::ProductViewSlice));
				pView->ViewID = (long) rowset->GetValue(L"ViewId");
				internal_id->text = pView->ToString();
				pViewElement->appendChild(internal_id);
				MSXML2::IXMLDOMElementPtr amount = pXMLDoc->createElement(L"amount");
				amount->text = _bstr_t(rowset->GetValue(L"TotalAmount"));
				pViewElement->appendChild(amount);
        CreateAdjustmentTags(rowset, pXMLDoc, pViewElement);
				MSXML2::IXMLDOMElementPtr agg = pXMLDoc->createElement(L"is_aggregate");
				agg->text = _bstr_t(L"N");
				pViewElement->appendChild(agg);
				pChargesElement->appendChild(pViewElement);
			}
			else if(VT_NULL == rowset->GetValue(L"ProductOfferingId").vt)
			{
				// This is non-product offering usage.
				// <charges>
				//   <pi>
				//     <id>Template Name</pi>
				//     <amount>Template amount</amount>
				//   </pi>
				// </charges>
					
				MSXML2::IXMLDOMElementPtr pTemplateElement = pXMLDoc->createElement(L"pi");
				MSXML2::IXMLDOMAttributePtr pUOMAttr = pXMLDoc->createAttribute(L"uom");
				pUOMAttr->value = _bstr_t(rowset->GetValue(L"Currency"));
				pTemplateElement->attributes->setNamedItem(pUOMAttr);
				MSXML2::IXMLDOMElementPtr id = pXMLDoc->createElement(L"id");
				id->text = _bstr_t(rowset->GetValue(L"PriceableItemName"));
				pTemplateElement->appendChild(id);
				MSXML2::IXMLDOMElementPtr internal_id = pXMLDoc->createElement(L"internal_id");
				MTHIERARCHYREPORTSLib::IPriceableItemTemplateSlicePtr pTemplate(__uuidof(MTHIERARCHYREPORTSLib::PriceableItemTemplateSlice));
				pTemplate->TemplateID = (long) rowset->GetValue(L"PriceableItemTemplateId");
				pTemplate->ViewID = (long) rowset->GetValue(L"ViewId");
				internal_id->text = pTemplate->ToString();
				pTemplateElement->appendChild(internal_id);
				MSXML2::IXMLDOMElementPtr amount = pXMLDoc->createElement(L"amount");
				amount->text = _bstr_t(rowset->GetValue(L"TotalAmount"));
				pTemplateElement->appendChild(amount);
        //adjustment amounts will always be 0
        CreateAdjustmentTags(rowset, pXMLDoc, pTemplateElement);
				MSXML2::IXMLDOMElementPtr agg = pXMLDoc->createElement(L"is_aggregate");
				agg->text = _bstr_t(rowset->GetValue(L"IsAggregate"));
				pTemplateElement->appendChild(agg);
				pChargesElement->appendChild(pTemplateElement);
			}
			else
			{
				if((long)rowset->GetValue(L"ProductOfferingId") != id_prod)
				{
					pProductOfferingElement = pXMLDoc->createElement(L"po");
					pChargesElement->appendChild(pProductOfferingElement);
					MSXML2::IXMLDOMElementPtr id = pXMLDoc->createElement(L"id");
					id->text = _bstr_t(rowset->GetValue(L"ProductOfferingName"));
					pProductOfferingElement->appendChild(id);
					MSXML2::IXMLDOMElementPtr internal_id = pXMLDoc->createElement(L"internal_id");
					internal_id->text = _bstr_t(rowset->GetValue(L"ProductOfferingId"));
					pProductOfferingElement->appendChild(internal_id);
					// TODO: Fix the query so that we get the PO level summary amounts
					MSXML2::IXMLDOMElementPtr amount = pXMLDoc->createElement(L"amount");
					amount->text = L"TBD";
					pProductOfferingElement->appendChild(amount);
          CreateAdjustmentTags(rowset, pXMLDoc, pProductOfferingElement);
					id_prod = rowset->GetValue(L"ProductOfferingId");
				}

				MSXML2::IXMLDOMElementPtr pInstanceElement = pXMLDoc->createElement(L"pi");
				MSXML2::IXMLDOMAttributePtr pUOMAttr = pXMLDoc->createAttribute(L"uom");
				pUOMAttr->value = _bstr_t(rowset->GetValue(L"Currency"));
				pInstanceElement->attributes->setNamedItem(pUOMAttr);
				MSXML2::IXMLDOMElementPtr id = pXMLDoc->createElement(L"id");
				id->text = _bstr_t(rowset->GetValue(L"PriceableItemInstanceName"));
				pInstanceElement->appendChild(id);
				MSXML2::IXMLDOMElementPtr internal_id = pXMLDoc->createElement(L"internal_id");
				MTHIERARCHYREPORTSLib::IPriceableItemInstanceSlicePtr pInstance(__uuidof(MTHIERARCHYREPORTSLib::PriceableItemInstanceSlice));
				pInstance->InstanceID = (long) rowset->GetValue(L"PriceableItemInstanceId");
				pInstance->ViewID = (long) rowset->GetValue(L"ViewId");
				internal_id->text = pInstance->ToString();
				pInstanceElement->appendChild(internal_id);
				MSXML2::IXMLDOMElementPtr amount = pXMLDoc->createElement(L"amount");
				amount->text = _bstr_t(rowset->GetValue(L"TotalAmount"));
				pInstanceElement->appendChild(amount);
        CreateAdjustmentTags(rowset, pXMLDoc, pInstanceElement);
				MSXML2::IXMLDOMElementPtr agg = pXMLDoc->createElement(L"is_aggregate");
				agg->text = _bstr_t(rowset->GetValue(L"IsAggregate"));
				pInstanceElement->appendChild(agg);

				pProductOfferingElement->appendChild(pInstanceElement);
			}

			rowset->MoveNext();
		}
	}
	catch (_com_error & err) 
	{
		return returnHierarchyReportError(err);
	}

	return hr;
	
}

/*HRESULT CHierarchyReportLevel::GetProductSummaryForServiceEndpointPanel(long intAccountId, 
																																				long intServiceEndpointId,
																																				long intPayerId,
																																				MSXML2::IXMLDOMDocument2Ptr apXMLDoc,
																																				MSXML2::IXMLDOMElementPtr apChargesElement)
{
	HRESULT hr = S_OK;
	try
	{
		_variant_t vtPayerId((long)intPayerId, VT_I4);
		_variant_t vtServiceEndpointId((long)intServiceEndpointId, VT_I4);
		_variant_t vtAccountId((long)intAccountId, VT_I4);
		MSXML2::IXMLDOMDocument2Ptr pXMLDoc(apXMLDoc);
		MSXML2::IXMLDOMElementPtr pChargesElement(apChargesElement);


		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(L"\\Queries\\PresServer");
    
		if(VARIANT_FALSE == mPayerReport)
		{
			rowset->SetQueryTag(mMVMEnabled ? L"__GET_BYENDPOINTBYPRODUCT_DATAMART__"
						: L"__GET_BYENDPOINTBYPRODUCT__");
		}
		else
		{
			rowset->SetQueryTag(mMVMEnabled ? L"__GET_BYENDPOINTBYPRODUCTFORPAYER_DATAMART__"
						: L"__GET_BYENDPOINTBYPRODUCTFORPAYER__");
			rowset->AddParam(L"%%ID_PAYER%%", vtPayerId);
		}

		// Parameters common to both report types
		rowset->AddParam(L"%%ID_ACC%%", vtAccountId);
		//rowset->AddParam(L"%%ID_ENDPOINT%%", vtServiceEndpointId);
		rowset->AddParam(L"%%ID_LANG%%", _variant_t((long)mLanguageCode));
		rowset->AddParam(L"%%TIME_PREDICATE%%", mTimeSlice->GenerateQueryPredicate(), VARIANT_TRUE);
		rowset->AddParam(L"%%LIKE_OR_NOT_LIKE%%", mSecondPass == VARIANT_TRUE ?  L" NOT LIKE ": L" LIKE ");

		rowset->Execute();

    if (FAILED(hr=ConvertProductSummaryRowsetToXml(rowset, pXMLDoc, pChargesElement))) return hr;		
	}
	catch(_com_error& err)
	{
		return returnHierarchyReportError(err);
	}
	return hr;
}
*/

HRESULT CHierarchyReportLevel::GetAccountSummaryPanel(long intAccountId, 
																											long intPayerId,
																											MTHIERARCHYREPORTSLib::IDateRangeSlicePtr apAccountEffDate,
																											MSXML2::IXMLDOMDocument2Ptr apXMLDoc,
																											MSXML2::IXMLDOMElementPtr apLevelElement,
																											MSXML2::IXMLDOMElementPtr apChildrenElement)
{
	HRESULT hr = S_OK;
	try
	{
		_variant_t vtPayerId((long)intPayerId, VT_I4);
		_variant_t vtAccountId((long)intAccountId, VT_I4);
		MTHIERARCHYREPORTSLib::IDateRangeSlicePtr pAccountEffDate(apAccountEffDate);
		MSXML2::IXMLDOMDocument2Ptr pXMLDoc(apXMLDoc);
		MSXML2::IXMLDOMElementPtr pLevelElement(apLevelElement);
		MSXML2::IXMLDOMElementPtr pChildrenElement(apChildrenElement);

		// Let's work up the kiddies.  Note that this query will also
		// do a summary for the parent we are dealing with.
		ROWSETLib::IMTSQLRowsetPtr rowset2(MTPROGID_SQLROWSET);
		rowset2->Init(L"\\Queries\\PresServer");

		if(VARIANT_FALSE == mPayerReport)
		{
			rowset2->SetQueryTag(mMVMEnabled ? L"__GET_BYACCOUNTALLPRODUCTS_DATAMART__"
						                           : L"__GET_BYACCOUNTALLPRODUCTS__");
		}
		else
		{
			// Here we are doing a "By-Originator" report but only for charges payed
			// for by a single account. 
			rowset2->SetQueryTag(mMVMEnabled ? L"__GET_BYACCOUNTALLPRODUCTSFORPAYER_DATAMART__"
						                           : L"__GET_BYACCOUNTALLPRODUCTSFORPAYER__");
			rowset2->AddParam(L"%%ID_PAYER%%", vtPayerId, VARIANT_TRUE);
		}

		// Parameters common to both queries
		rowset2->AddParam(L"%%ID_ACC%%", vtAccountId, VARIANT_TRUE);
		rowset2->AddParam(L"%%TIME_PREDICATE%%", mTimeSlice->GenerateQueryPredicate(), VARIANT_TRUE);
		rowset2->AddParam(L"%%LIKE_OR_NOT_LIKE%%", mSecondPass == VARIANT_TRUE ? L" NOT LIKE " : L" LIKE ");

    DATE dtBegin, dtEnd;
		// TODO: The way I am handling the account effective date seems a bit of
		// a hack.  I should probably combine the two time slice (intersection?)
		// to get the correct date range here...
		if (pAccountEffDate)
		{
			pAccountEffDate->GetTimeSpan(&dtBegin, &dtEnd);
		}
		else
		{
			if(VARIANT_FALSE == mPayerReport)
			{
				mTimeSlice->GetTimeSpan(&dtBegin, &dtEnd);
			}
			else
			{
				// For payer reports initialize date range to +- infinity
				dtBegin = 25569.00;
				dtEnd = 50406.00;
			}
		}
		std::wstring buffer;
		BOOL bSuccess = FormatValueForDB(_variant_t(dtBegin, VT_DATE), FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return Error("Failure formatting DATE for database write");
		}
		rowset2->AddParam(L"%%DT_BEGIN%%", buffer.c_str(), VARIANT_TRUE);
		bSuccess = FormatValueForDB(_variant_t(dtEnd, VT_DATE), FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return Error("Failure formatting DATE for database write");
		}
		
    rowset2->AddParam(L"%%DT_END%%", buffer.c_str(), VARIANT_TRUE);

		rowset2->Execute();

		while(!bool(rowset2->RowsetEOF))
		{
			if((long)rowset2->GetValue(L"AccountID") == (long)vtAccountId)
			{
				MSXML2::IXMLDOMElementPtr id = pXMLDoc->createElement("id");
				id->text = _bstr_t(rowset2->GetValue(L"AccountName"));
				pLevelElement->appendChild(id);
				MSXML2::IXMLDOMElementPtr internal_id = pXMLDoc->createElement("internal_id");
				if(VARIANT_FALSE == mPayerReport)
				{
					MTHIERARCHYREPORTSLib::IPayeeSlicePtr pSlice("MTHierarchyReports.PayeeSlice.1");
					pSlice->PayeeID = (long)rowset2->GetValue(L"AccountID");
					internal_id->text = pSlice->ToString();
				}
				else
				{
					MTHIERARCHYREPORTSLib::IPayerAndPayeeSlicePtr pSlice("MTHierarchyReports.PayerAndPayeeSlice.1");
					pSlice->PayeeID = (long)rowset2->GetValue(L"AccountID");
					pSlice->PayerID = mPayerId;
					internal_id->text = pSlice->ToString();
				}
        pLevelElement->appendChild(internal_id);
        MSXML2::IXMLDOMElementPtr pAmount = pXMLDoc->createElement(L"amount");
        pAmount->text = _bstr_t(rowset2->GetValue(L"TotalAmount"));

        MSXML2::IXMLDOMAttributePtr pUOMAttr = pXMLDoc->createAttribute(L"uom");
        
        _bstr_t bstrCurrency = _bstr_t(rowset2->GetValue(L"Currency"));

        pUOMAttr->value = bstrCurrency;
        
        pAmount->attributes->setNamedItem(pUOMAttr);
        
        pLevelElement->appendChild(pAmount);
        CreateAdjustmentTags(rowset2, pXMLDoc, pLevelElement);
        
				MSXML2::IXMLDOMElementPtr pTax = pXMLDoc->createElement(L"tax");
				pTax->text = _bstr_t(rowset2->GetValue(L"TotalTax"));

				MSXML2::IXMLDOMAttributePtr pUOMAttr2 = pXMLDoc->createAttribute(L"uom");
				pUOMAttr2->value = _bstr_t(rowset2->GetValue(L"Currency"));
				pTax->attributes->setNamedItem(pUOMAttr2);


				pLevelElement->appendChild(pTax);
				MSXML2::IXMLDOMElementPtr pAccountTimeSlice = pXMLDoc->createElement("account_time_slice");
				if (pAccountEffDate)
				{
					// More ugly hackery dealing with hierarchy effective dates.  Since this record is
					// has num_generations = 0, its effective date is negative infinity to infinity.
					// Correct for that here by intersecting with the effective date
					pAccountTimeSlice->text = pAccountEffDate->ToString();
				}
				else
				{
					// Create a date range slice from the accountstart and accountend.
					MTHIERARCHYREPORTSLib::IDateRangeSlicePtr pSlice(__uuidof(MTHIERARCHYREPORTSLib::DateRangeSlice));
					pSlice->Begin = rowset2->GetValue(L"AccountStart");
					pSlice->End = rowset2->GetValue(L"AccountEnd");
					pAccountTimeSlice->text = pSlice->ToString();
				}
				pLevelElement->appendChild(pAccountTimeSlice);
			}
			else
			{
				// <level>
				//   <id>Engineering</id>
				//   <amount>99834.23</amount>
				// </level>
				MSXML2::IXMLDOMElementPtr pChildLevel = pXMLDoc->createElement(L"level");
				MSXML2::IXMLDOMElementPtr pId = pXMLDoc->createElement(L"id");
				pId->text = _bstr_t(rowset2->GetValue(L"AccountName"));
				pChildLevel->appendChild(pId);
				MSXML2::IXMLDOMElementPtr pInternalId = pXMLDoc->createElement(L"internal_id");
				if(VARIANT_FALSE == mPayerReport)
				{
					MTHIERARCHYREPORTSLib::IPayeeSlicePtr pSlice("MTHierarchyReports.PayeeSlice.1");
					pSlice->PayeeID = (long)rowset2->GetValue(L"AccountID");
					pInternalId->text = pSlice->ToString();
				}
				else
				{
					MTHIERARCHYREPORTSLib::IPayerAndPayeeSlicePtr pSlice("MTHierarchyReports.PayerAndPayeeSlice.1");
					pSlice->PayeeID = (long)rowset2->GetValue(L"AccountID");
					pSlice->PayerID = mPayerId;
					pInternalId->text = pSlice->ToString();
				}
				pChildLevel->appendChild(pInternalId);
				MSXML2::IXMLDOMElementPtr pAmount = pXMLDoc->createElement(L"amount");
				pAmount->text = _bstr_t(rowset2->GetValue(L"TotalAmount"));

        MSXML2::IXMLDOMAttributePtr pUOMAttr = pXMLDoc->createAttribute(L"uom");
        
        _bstr_t bstrCurrency =  _bstr_t(rowset2->GetValue(L"Currency"));
				  
        pUOMAttr->value = bstrCurrency;
        
        pAmount->attributes->setNamedItem(pUOMAttr);
        
        pChildLevel->appendChild(pAmount);
        CreateAdjustmentTags(rowset2, pXMLDoc, pChildLevel);
        
				// Create a date range slice from the accountstart and accountend.
				MTHIERARCHYREPORTSLib::IDateRangeSlicePtr pSlice(__uuidof(MTHIERARCHYREPORTSLib::DateRangeSlice));
				pSlice->Begin = rowset2->GetValue(L"AccountStart");
				pSlice->End = rowset2->GetValue(L"AccountEnd");
				MSXML2::IXMLDOMElementPtr pAccountTimeSlice = pXMLDoc->createElement("account_time_slice");
				pAccountTimeSlice->text = pSlice->ToString();
				pChildLevel->appendChild(pAccountTimeSlice);

				// Save the effective date range of the account so we can properly qualify
				// drill down.
				hr = mLevelEffDates.Add(reinterpret_cast<IDateRangeSlice*>(pSlice.GetInterfacePtr()));
				if (FAILED(hr))
					return hr;

				pChildrenElement->appendChild(pChildLevel);

				// Oh, by the way, while I am here, record the id so I can
				// instantiate kid levels later.  Hack, to record the fact
				// that this is not a service endpoint.
				mChildIds.push_back((long)rowset2->GetValue(L"AccountID"));
				//mServiceEndpointIds.push_back(-1);
			}
			rowset2->MoveNext();
		}
	}
	catch(_com_error & err)
	{
		return returnHierarchyReportError(err);
	}
	return hr;
}

/*HRESULT CHierarchyReportLevel::GetServiceEndpointSummaryPanel(long intAccountId, 
																															long intPayerId,
																															MSXML2::IXMLDOMDocument2Ptr apXMLDoc,
																															MSXML2::IXMLDOMElementPtr apChildrenElement)
{
	HRESULT hr = S_OK;
	try
	{
		_variant_t vtPayerId((long)intPayerId, VT_I4);
		_variant_t vtAccountId((long)intAccountId, VT_I4);
		MSXML2::IXMLDOMDocument2Ptr pXMLDoc(apXMLDoc);
		MSXML2::IXMLDOMElementPtr pChildrenElement(apChildrenElement);

		// Let's work up the kiddies.  Note that this query will also
		// do a summary for the parent we are dealing with.
		ROWSETLib::IMTSQLRowsetPtr rowset2(MTPROGID_SQLROWSET);
		rowset2->Init(L"\\Queries\\PresServer");

    if(VARIANT_FALSE == mPayerReport)
		{
			rowset2->SetQueryTag(L"__GET_BYENDPOINTALLPRODUCTS__");
    }
		else
		{
			// Here we are doing a "By-Originator" report but only for charges payed
			// for by a single account. 
			rowset2->SetQueryTag(L"__GET_BYENDPOINTALLPRODUCTSFORPAYER__");
			rowset2->AddParam(L"%%ID_PAYER%%", vtPayerId, VARIANT_TRUE);
		}

		// Parameters common to both queries
		rowset2->AddParam(L"%%ID_ACC%%", vtAccountId, VARIANT_TRUE);
		rowset2->AddParam(L"%%TIME_PREDICATE%%", mTimeSlice->GenerateQueryPredicate(), VARIANT_TRUE);
		rowset2->AddParam(L"%%LIKE_OR_NOT_LIKE%%", mSecondPass == VARIANT_TRUE ? L" NOT LIKE " : L" LIKE ");
		rowset2->AddParam(L"%%ENDPOINT_PREDICATE%%", L"au.id_se IS NOT NULL");
		rowset2->Execute();

		while(!bool(rowset2->RowsetEOF))
		{
			// <level>
			//   <id>Engineering</id>
			//   <amount>99834.23</amount>
			// </level>
			MSXML2::IXMLDOMElementPtr pChildLevel = pXMLDoc->createElement(L"level");
			MSXML2::IXMLDOMElementPtr pId = pXMLDoc->createElement(L"id");
			pId->text = _bstr_t(rowset2->GetValue(L"EndpointName"));
			pChildLevel->appendChild(pId);
			MSXML2::IXMLDOMElementPtr pInternalId = pXMLDoc->createElement(L"internal_id");
			if(VARIANT_FALSE == mPayerReport)
			{
				MTHIERARCHYREPORTSLib::IPayeeAndEndpointSlicePtr pSlice(__uuidof(MTHIERARCHYREPORTSLib::PayeeAndEndpointSlice));
				pSlice->PayeeID = (long)intAccountId;
				pSlice->ServiceEndpointID = (long)rowset2->GetValue(L"EndpointID");
				pInternalId->text = pSlice->ToString();
			}
			else
			{
				MTHIERARCHYREPORTSLib::IPayerAndPayeeAndEndpointSlicePtr pSlice(__uuidof(MTHIERARCHYREPORTSLib::PayerAndPayeeAndEndpointSlice));
				pSlice->ServiceEndpointID = (long)rowset2->GetValue(L"EndpointID");
				pSlice->PayeeID = (long)intAccountId;
				pSlice->PayerID = mPayerId;
				pInternalId->text = pSlice->ToString();
			}
			pChildLevel->appendChild(pInternalId);
			MSXML2::IXMLDOMElementPtr pAmount = pXMLDoc->createElement(L"amount");
			pAmount->text = _bstr_t(rowset2->GetValue(L"TotalAmount"));

      MSXML2::IXMLDOMAttributePtr pUOMAttr = pXMLDoc->createAttribute(L"uom");

      _bstr_t bstrCurrency =  _bstr_t(rowset2->GetValue(L"Currency"));
      pUOMAttr->value = bstrCurrency;
      pAmount->attributes->setNamedItem(pUOMAttr);
      
			pChildLevel->appendChild(pAmount);
      CreateAdjustmentTags(rowset2, pXMLDoc, pChildLevel);
      
      // Service endpoint associations and their owning payee accounts
			// are both explicitly stored in the account slice so we don't need a date range.
			// Thus set the date range to +- infinity
			MTHIERARCHYREPORTSLib::IDateRangeSlicePtr pSlice(__uuidof(MTHIERARCHYREPORTSLib::DateRangeSlice));
			pSlice->Begin = 25569.00;
			pSlice->End = 50406.00;
			MSXML2::IXMLDOMElementPtr pAccountTimeSlice = pXMLDoc->createElement("account_time_slice");
			pAccountTimeSlice->text = pSlice->ToString();
			pChildLevel->appendChild(pAccountTimeSlice);

			// Save the effective date range of the account so we can properly qualify
			// drill down.
			hr = mLevelEffDates.Add(reinterpret_cast<IDateRangeSlice*>(pSlice.GetInterfacePtr()));
			if (FAILED(hr))
				return hr;

			pChildrenElement->appendChild(pChildLevel);

			// Oh, by the way, while I am here, record the id so I can
			// instantiate kid levels later
			mChildIds.push_back((long)vtAccountId);
			mServiceEndpointIds.push_back((long)rowset2->GetValue(L"EndpointID"));

			rowset2->MoveNext();
		}
	}
	catch(_com_error & err)
	{
		return returnHierarchyReportError(err);
	}
	return hr;
}*/


STDMETHODIMP CHierarchyReportLevel::InitByFolderReport(int intAccountId, 
																											 int intPayerId, 
																											 IDateRangeSlice * apAccountEffDate,
																											 ITimeSlice * apTimeSlice, 
																											 int intLanguageCode,
																											 VARIANT_BOOL bPayerReport,
																											 VARIANT_BOOL bSecondPass)
{
	HRESULT hr=S_OK;

	// Make it safe to call init multiple times.
	if (mHydrated) 
	{
		return hr;
	}
	else
	{
		mHydrated = true;
	}

	try {
		MTHIERARCHYREPORTSLib::IDateRangeSlicePtr pAccountEffDate(apAccountEffDate);

		// Record who the payer is
		mPayerId = intPayerId;
		mPayerReport = bPayerReport;
		mSecondPass = bSecondPass;
		mTimeSlice = apTimeSlice;
		mLanguageCode = intLanguageCode;
	 
		mLogger.LogVarArgs(LOG_DEBUG, 
											 "HierarchyReportLevel::InitByFolderReport(%d, %d, %s, %s, %d, %d, %d)",
											 intAccountId, 
											 intPayerId, 
											 NULL == pAccountEffDate.GetInterfacePtr() ? "NULL" : (const char *)pAccountEffDate->ToString(), 
											 NULL == mTimeSlice .GetInterfacePtr() ? "NULL" : (const char *)mTimeSlice->ToString(),
											 intLanguageCode,
											 bPayerReport,
											 bSecondPass);

		if(mPayerReport == VARIANT_TRUE)
		{
			mLogger.LogVarArgs(LOG_DEBUG, "Creating by folder bill report for account id = %d and payer id = %d", intAccountId, intPayerId);
		}
		else
		{
			mLogger.LogVarArgs(LOG_DEBUG, "Creating by folder hierarchy report for account id = %d", intAccountId);
		}

		// We'll use the DOM objects to create the associated XML
		IXMLDOMDocument2Ptr pXMLDoc("MSXML2.DOMDocument.4.0");
		MSXML2::IXMLDOMElementPtr pLevelElement = pXMLDoc->createElement(L"level");
		pXMLDoc->documentElement = pLevelElement;

		// The element containing summaries of any children
		MSXML2::IXMLDOMElementPtr pChildrenElement = pXMLDoc->createElement(L"children");

		// The element containing any charges by this account
		MSXML2::IXMLDOMElementPtr pChargesElement = pXMLDoc->createElement(L"charges");

		// The current account we are working on and the level that it is in.
		long id_acc  = -1L;

		_variant_t vtAccountId((long)intAccountId, VT_I4);
		_variant_t vtPayerId((long)intPayerId, VT_I4);

		if(VARIANT_TRUE == mPayerReport && intAccountId == -1)
		{
			// This is the root of a payer report.  Fetch the corporate account.
			// TODO: The effective date logic here needs to be thought through.
			long corporateId;
			DATE dtBegin, dtEnd;
			mTimeSlice->GetTimeSpan(&dtBegin, &dtEnd);
			if(FAILED(hr=GetLeastCommonAncestorOfPayees(mPayerId, _variant_t(dtBegin, VT_DATE), _variant_t(dtEnd, VT_DATE), mTimeSlice, &corporateId))) return hr;			

			if(mLogger.IsOkToLog(LOG_DEBUG))
			{
				mLogger.LogVarArgs(LOG_DEBUG, "By folder bill report for payer id = %d is being "
													 "started with least common ancestor of payees = %d calculated "
													 "with hierarchy effective date '%s'", mPayerId, corporateId, (const char *)(_bstr_t)(_variant_t(dtEnd, VT_DATE)));
			}

			// If corporateId == 0, that means I am not paying for anyone.  In
			// this case, just return since I am an empty report.
			if (corporateId == 0) return S_OK;

			vtAccountId = corporateId;
		}

		if((VARIANT_TRUE == mPayerReport && intAccountId == -1) || (VARIANT_FALSE == mPayerReport && NULL == apAccountEffDate))
		{
			// We are at the root of a by-folder report.  Record the
			// account slice that describes the summary we are performing.
			// This is different from the account slice that is in the internal_id
			// node; that one describes the account slice used for the "account panel"
			// (by product summaries for a single payee).
			if(VARIANT_FALSE == mPayerReport)
			{
				MTHIERARCHYREPORTSLib::IDescendentPayeeSlicePtr spHierarchySlice("MTHierarchyReports.DescendentPayeeSlice.1");
				spHierarchySlice->AncestorID = vtAccountId;
				spHierarchySlice->Begin = 25569.00;
				spHierarchySlice->End = 50406.00;
				MSXML2::IXMLDOMElementPtr summary_slice = pXMLDoc->createElement(L"account_summary_slice");
				summary_slice->text = spHierarchySlice->ToString();
				pLevelElement->appendChild(summary_slice);
			}
			else
			{
				MTHIERARCHYREPORTSLib::IPayerSlicePtr spPayerSlice("MTHierarchyReports.PayerSlice.1");
				spPayerSlice->PayerID = vtPayerId;
				// Also record the account slice used for this report.  It happens to be
				// the same as the internal_id for by product reports, but it won't be for
				// by folder reports.
				MSXML2::IXMLDOMElementPtr summary_slice = pXMLDoc->createElement(L"account_summary_slice");
				summary_slice->text = spPayerSlice->ToString();
				pLevelElement->appendChild(summary_slice);
			}
		}

		if(FAILED(hr=this->GetAccountSummaryPanel(vtAccountId, 
																							vtPayerId, 
																							pAccountEffDate,
																							pXMLDoc,
																							pLevelElement,
																							pChildrenElement))) return hr;

		// Here we are retrieving the by service endpoint summaries for 
		// endpoints beneath vtAccountID (and paid for by vtPayerId if we are a bill report).
		// These are also output as <level/> elements
		//if(FAILED(hr=this->GetServiceEndpointSummaryPanel(vtAccountId, 
		//																									vtPayerId, 
		//																									pXMLDoc,
		//																									pChildrenElement))) return hr;

		

		// Here we are retrieving the by product summary for usage incurred by
		// vtAccountId (and paid for by vtPayerId if we are a bill report).
		{

			ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
			rowset->Init(L"\\Queries\\PresServer");

      if(VARIANT_FALSE == mPayerReport)
			{
  			rowset->SetQueryTag(mMVMEnabled ? L"__GET_BYACCOUNTBYPRODUCT_DATAMART__"
						                            : L"__GET_BYACCOUNTBYPRODUCT__");
			}
			else
			{
  			rowset->SetQueryTag(mMVMEnabled ? L"__GET_BYACCOUNTBYPRODUCTFORPAYER_DATAMART__"
						                            : L"__GET_BYACCOUNTBYPRODUCTFORPAYER__");
				rowset->AddParam(L"%%ID_PAYER%%", vtPayerId);
			}

			// Parameters common to both report types
			rowset->AddParam(L"%%ID_ACC%%", vtAccountId);
			rowset->AddParam(L"%%ID_LANG%%", _variant_t((long)mLanguageCode));
			rowset->AddParam(L"%%TIME_PREDICATE%%", mTimeSlice->GenerateQueryPredicate(), VARIANT_TRUE);
			rowset->AddParam(L"%%LIKE_OR_NOT_LIKE%%", mSecondPass == VARIANT_TRUE ?  L" NOT LIKE ": L" LIKE ");

      DATE dtBegin, dtEnd;
			// TODO: The way I am handling the account effective date seems a bit of
			// a hack.  I should probably combine the two time slice (intersection?)
			// to get the correct date range here...
			if (pAccountEffDate)
			{
				pAccountEffDate->GetTimeSpan(&dtBegin, &dtEnd);
			}
			else
			{
				if(VARIANT_FALSE == mPayerReport)
				{
					mTimeSlice->GetTimeSpan(&dtBegin, &dtEnd);
				}
				else
				{
					dtBegin = 25569.00;
					dtEnd = 50406.00;
				}
			}
			std::wstring buffer;
			BOOL bSuccess = FormatValueForDB(_variant_t(dtBegin, VT_DATE), FALSE, buffer);
			if (bSuccess == FALSE)
			{
				return Error("Failure formatting DATE for database write");
			}
			rowset->AddParam(L"%%DT_BEGIN%%", buffer.c_str(), VARIANT_TRUE);
			bSuccess = FormatValueForDB(_variant_t(dtEnd, VT_DATE), FALSE, buffer);
			if (bSuccess == FALSE)
			{
				return Error("Failure formatting DATE for database write");
			}
			rowset->AddParam(L"%%DT_END%%", buffer.c_str(), VARIANT_TRUE);

      rowset->Execute();
			if (FAILED(hr=ConvertProductSummaryRowsetToXml(rowset, pXMLDoc, pChargesElement))) return hr;		
		}

		pLevelElement->appendChild(pChargesElement);

		pLevelElement->appendChild(pChildrenElement);

		mstrReportXML = pXMLDoc->xml;

		// For each of the children encountered, create a sub level report, but don't init
		for(std::vector<long>::const_iterator it=mChildIds.begin(); it != mChildIds.end(); it++)
		{
			MTHIERARCHYREPORTSLib::IHierarchyReportLevelPtr pChildReport(__uuidof(HierarchyReportLevel));
			hr = mLevels.Add(reinterpret_cast<IHierarchyReportLevel*>(pChildReport.GetInterfacePtr()));
			if (FAILED(hr))
				return hr;
		}		

	}
	catch(_com_error & err)
	{
		return returnHierarchyReportError(err);
	}

	return hr;
}

/*STDMETHODIMP CHierarchyReportLevel::InitByFolderServiceEndpointReport(int intAccountId,
																																			int intServiceEndpointId,
																																			int intPayerId, 
																																			ITimeSlice * apTimeSlice, 
																																			int intLanguageCode,
																																			VARIANT_BOOL bPayerReport,
																																			VARIANT_BOOL bSecondPass)
{
	HRESULT hr=S_OK;

	// Make it safe to call init multiple times.
	if (mHydrated) 
	{
		return hr;
	}
	else
	{
		mHydrated = true;
	}

	try {
		// Record who the payer is
		mPayerId = intPayerId;
		mPayerReport = bPayerReport;
		mSecondPass = bSecondPass;
		mTimeSlice = apTimeSlice;
		mLanguageCode = intLanguageCode;
	 
		mLogger.LogVarArgs(LOG_DEBUG, 
											 "HierarchyReportLevel::InitByFolderServiceEndpointReport(%d, %d, %d, %s, %d, %d, %d)",
											 intAccountId,
											 intServiceEndpointId,
											 intPayerId, 
											 NULL == mTimeSlice .GetInterfacePtr() ? "NULL" : (const char *)mTimeSlice->ToString(),
											 intLanguageCode,
											 bPayerReport,
											 bSecondPass);

		if(mPayerReport == VARIANT_TRUE)
		{
			mLogger.LogVarArgs(LOG_DEBUG, "Creating by folder bill report for service endpoint id = %d and account id = %d and payer id = %d", intServiceEndpointId, intAccountId, intPayerId);
		}
		else
		{
			mLogger.LogVarArgs(LOG_DEBUG, "Creating by folder hierarchy report for service endpoint id = %d and account id = %d", intServiceEndpointId, intAccountId);
		}

		// We'll use the DOM objects to create the associated XML
		IXMLDOMDocument2Ptr pXMLDoc("MSXML2.DOMDocument.4.0");
		MSXML2::IXMLDOMElementPtr pLevelElement = pXMLDoc->createElement(L"level");
		pXMLDoc->documentElement = pLevelElement;

		// The element containing any charges by this account
		MSXML2::IXMLDOMElementPtr pChargesElement = pXMLDoc->createElement(L"charges");

		_variant_t vtServiceEndpointId((long)intServiceEndpointId, VT_I4);
		_variant_t vtAccountId((long)intAccountId, VT_I4);
		_variant_t vtPayerId((long)intPayerId, VT_I4);

		// Let's work up the kiddies.  Note that this query will also
		// do a summary for the parent we are dealing with.
		ROWSETLib::IMTSQLRowsetPtr rowset2(MTPROGID_SQLROWSET);
		rowset2->Init(L"\\Queries\\PresServer");

    if(VARIANT_FALSE == mPayerReport)
		{
			rowset2->SetQueryTag(L"__GET_BYENDPOINTALLPRODUCTS__");
		}
		else
		{
			// Here we are doing a "By-Originator" report but only for charges payed
			// for by a single account. 
			rowset2->SetQueryTag(L"__GET_BYENDPOINTALLPRODUCTSFORPAYER__");
			rowset2->AddParam(L"%%ID_PAYER%%", vtPayerId, VARIANT_TRUE);
		}

		// Parameters common to both queries
		rowset2->AddParam(L"%%ID_ACC%%", vtAccountId, VARIANT_TRUE);
		rowset2->AddParam(L"%%TIME_PREDICATE%%", mTimeSlice->GenerateQueryPredicate(), VARIANT_TRUE);
		rowset2->AddParam(L"%%LIKE_OR_NOT_LIKE%%", mSecondPass == VARIANT_TRUE ? L" NOT LIKE " : L" LIKE ");

		// Create an equality predicate
		char buf[64];
		sprintf_s(buf, 64, "au.id_se=%d", intServiceEndpointId);
		rowset2->AddParam(L"%%ENDPOINT_PREDICATE%%", _bstr_t(buf));
		rowset2->Execute();

    MSXML2::IXMLDOMElementPtr pId = pXMLDoc->createElement(L"id");
		pId->text = _bstr_t(rowset2->GetValue(L"EndpointName"));
		pLevelElement->appendChild(pId);
		MSXML2::IXMLDOMElementPtr pInternalId = pXMLDoc->createElement(L"internal_id");
		if(VARIANT_FALSE == mPayerReport)
		{
			MTHIERARCHYREPORTSLib::IPayeeAndEndpointSlicePtr pSlice(__uuidof(MTHIERARCHYREPORTSLib::PayeeAndEndpointSlice));
			pSlice->ServiceEndpointID = (long)rowset2->GetValue(L"EndpointID");
			pSlice->PayeeID = (long)intAccountId;
			pInternalId->text = pSlice->ToString();
		}
		else
		{
			MTHIERARCHYREPORTSLib::IPayerAndPayeeAndEndpointSlicePtr pSlice(__uuidof(MTHIERARCHYREPORTSLib::PayerAndPayeeAndEndpointSlice));
			pSlice->ServiceEndpointID = (long)rowset2->GetValue(L"EndpointID");
			pSlice->PayeeID = (long)intAccountId;
			pSlice->PayerID = mPayerId;
			pInternalId->text = pSlice->ToString();
		}
    pLevelElement->appendChild(pInternalId);
    MSXML2::IXMLDOMElementPtr pAmount = pXMLDoc->createElement(L"amount");
    pAmount->text = _bstr_t(rowset2->GetValue(L"TotalAmount"));

    MSXML2::IXMLDOMAttributePtr pUOMAttr = pXMLDoc->createAttribute(L"uom");
    
    _bstr_t bstrCurrency =  _bstr_t(rowset2->GetValue(L"Currency"));

    pUOMAttr->value = bstrCurrency;
    
    pAmount->attributes->setNamedItem(pUOMAttr);
    
    pLevelElement->appendChild(pAmount);
    CreateAdjustmentTags(rowset2, pXMLDoc, pLevelElement);
    
    
    MSXML2::IXMLDOMElementPtr pTax = pXMLDoc->createElement(L"tax");
    pTax->text = _bstr_t(rowset2->GetValue(L"TotalTax"));

		MSXML2::IXMLDOMAttributePtr pUOMAttr2 = pXMLDoc->createAttribute(L"uom");
		pUOMAttr2->value = _bstr_t(rowset2->GetValue(L"Currency"));
		pTax->attributes->setNamedItem(pUOMAttr2);

		pLevelElement->appendChild(pTax);
		MSXML2::IXMLDOMElementPtr pAccountTimeSlice = pXMLDoc->createElement("account_time_slice");
		// Create a date range slice from the accountstart and accountend.
		MTHIERARCHYREPORTSLib::IDateRangeSlicePtr pSlice(__uuidof(MTHIERARCHYREPORTSLib::DateRangeSlice));
		pSlice->Begin = 25569.00;
		pSlice->End = 50406.00;
		pAccountTimeSlice->text = pSlice->ToString();
		pLevelElement->appendChild(pAccountTimeSlice);
		
		// Here we are retrieving the by service endpoint summaries for 
		// endpoints beneath vtAccountID (and paid for by vtPayerId if we are a bill report).
		// These are also output as <level/> elements
		if(FAILED(hr=this->GetProductSummaryForServiceEndpointPanel(vtAccountId, 
																																vtServiceEndpointId,
																																vtPayerId, 
																																pXMLDoc,
																																pChargesElement))) return hr;

		
		pLevelElement->appendChild(pChargesElement);

		// The element containing summaries of any children (empty for a service endpoint)
		MSXML2::IXMLDOMElementPtr pChildrenElement = pXMLDoc->createElement(L"children");
		pLevelElement->appendChild(pChildrenElement);

		mstrReportXML = pXMLDoc->xml;

	}
	catch(_com_error & err)
	{
		return returnHierarchyReportError(err);
	}

	return hr;
}*/

HRESULT CHierarchyReportLevel::GetCorporateAccount(long aAccountId, _variant_t aEffDate, long* apCorporateId)
{
	HRESULT hr = S_OK;

	if (!apCorporateId)
		return E_POINTER;
	else
		*apCorporateId = 0;

	try 
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(L"\\Queries\\AccHierarchies");
 		rowset->SetQueryTag(L"__GET_CORPORATEACCOUNT__");

		rowset->AddParam(L"%%ID_ACC%%", _variant_t(aAccountId));
		std::wstring buffer;
		BOOL bSuccess = FormatValueForDB(aEffDate, FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return E_FAIL;
		}
		rowset->AddParam(L"%%EFF_DATE%%", buffer.c_str(), VARIANT_TRUE);

		rowset->Execute();

		wchar_t buf[512];
    if(rowset->GetRecordCount() < 1)
    {
      swprintf_s(buf, 512, L"Unable to get corporate account for Account %d as of %s", aAccountId, buffer);
      MT_THROW_COM_ERROR(buf);
    }
    else if(rowset->GetRecordCount() > 1)
    {
      swprintf_s(buf, 512, L"Got multiple records while resolving corporate account for Account %d as of %s", aAccountId, buffer);
      MT_THROW_COM_ERROR(buf);
    }
    *apCorporateId =	(long)rowset->GetValue(L"id_ancestor");
	}
	catch(_com_error & err)
	{
		return returnHierarchyReportError(err);
	}
	return hr;
}

HRESULT CHierarchyReportLevel::GetLeastCommonAncestorOfPayees(long aAccountId, _variant_t aBeginDate, _variant_t aEndDate, MTHIERARCHYREPORTSLib::ITimeSlicePtr apTimeSlice, long* apCorporateId)
{
	HRESULT hr = S_OK;

	if (!apCorporateId)
		return E_POINTER;
	else
		*apCorporateId = 0;

	try 
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(L"\\Queries\\PresServer");
		rowset->SetQueryTag(mMVMEnabled ? L"__GET_LEASTCOMMONANCESTOROFPAYEES_DATAMART__"
						                            : L"__GET_LEASTCOMMONANCESTOROFPAYEES_PRESSERVER_");

		rowset->AddParam(L"%%ID_ACC%%", _variant_t(aAccountId));
		std::wstring buffer;
		BOOL bSuccess = FormatValueForDB(aBeginDate, FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return E_FAIL;
		}
		rowset->AddParam(L"%%BEGIN_DATE%%", buffer.c_str(), VARIANT_TRUE);
		bSuccess = FormatValueForDB(aEndDate, FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return E_FAIL;
		}
		rowset->AddParam(L"%%END_DATE%%", buffer.c_str(), VARIANT_TRUE);
		rowset->AddParam(L"%%TIME_PREDICATE%%", apTimeSlice->GenerateQueryPredicate(), VARIANT_TRUE);
		rowset->Execute();

		if(rowset->GetRecordCount() == 1)
		{
			*apCorporateId =	(long)rowset->GetValue(L"id_ancestor");
		}
		
		// TODO: Handle this more gracefully.
		ASSERT(rowset->GetRecordCount() == 1 || rowset->GetRecordCount() == 0);
	}
	catch(_com_error & err)
	{
		return returnHierarchyReportError(err);
	}
	return hr;
}

STDMETHODIMP CHierarchyReportLevel::Init(/*[in]*/ IMPSRenderInfo* pRenderInfo, /*[in]*/ IMPSReportInfo* pReportInfo)
{
	HRESULT hr = S_OK;

	try
	{
		MTHIERARCHYREPORTSLib::IMPSRenderInfoPtr render(pRenderInfo);
		MTHIERARCHYREPORTSLib::IMPSReportInfoPtr report(pReportInfo);
		MTHIERARCHYREPORTSLib::IHierarchyReportLevelPtr pThis(this);

		if (render->TimeSlice == NULL)
		{
			mLogger.LogThis(LOG_ERROR, "CHierarchyReportLevel::Init called with null time slice");
			return Error("Must specify time slice for report");
		}

    //Decide based on Report Type and Report View
    if(report->Type == MTHIERARCHYREPORTSLib::REPORT_TYPE_BILL)
    {
			// Use second pass of aggregate charges if doing an estimate
      if(render->ViewType == MTHIERARCHYREPORTSLib::VIEW_TYPE_BY_FOLDER)
      {
        pThis->InitByFolderReport(-1, render->AccountID, NULL,
																	render->TimeSlice, 
																	render->LanguageCode, VARIANT_TRUE, 
																	render->Estimate);
      }
      else if(render->ViewType == MTHIERARCHYREPORTSLib::VIEW_TYPE_BY_PRODUCT)
      {
				pThis->InitByProductReport(render->AccountID, render->TimeSlice, render->LanguageCode, VARIANT_TRUE, render->Estimate);
      }
    }
    else if(report->Type == MTHIERARCHYREPORTSLib::REPORT_TYPE_INTERACTIVE_REPORT)
    {
			// Always use the second pass of aggregate charges if doing a report
      if(render->ViewType == MTHIERARCHYREPORTSLib::VIEW_TYPE_BY_FOLDER)
      {
				pThis->InitByFolderReport(render->AccountID, -1, NULL, render->TimeSlice, render->LanguageCode, VARIANT_FALSE, VARIANT_TRUE);
      }
      else if(render->ViewType == MTHIERARCHYREPORTSLib::VIEW_TYPE_BY_PRODUCT)
      {
				pThis->InitByProductReport(render->AccountID, render->TimeSlice, render->LanguageCode, VARIANT_FALSE, VARIANT_TRUE);
      }
    }
	}
	catch(_com_error & err)
	{
		return returnHierarchyReportError(err);
	}
	
	return hr;
}

//////////////////////////////////////
STDMETHODIMP CHierarchyReportLevel::get_ExternalID(BSTR *pVal)
{
  *pVal = mstrExternalID.copy();

  return S_OK;
}

STDMETHODIMP CHierarchyReportLevel::put_ExternalID(BSTR newVal)
{
  mstrExternalID = newVal;

  return S_OK;
}

//Append Adjustment stuff after Amount element
void CHierarchyReportLevel::CreateAdjustmentTags
( 
 ROWSETLib::IMTSQLRowsetPtr& pRowset, 
 MSXML2::IXMLDOMDocument2Ptr& pXMLDoc, 
 MSXML2::IXMLDOMElementPtr& pLevelElement
 )
{
  MSXML2::IXMLDOMElementPtr pAJ = pXMLDoc->createElement(L"prebilladjustmentamount");
  MSXML2::IXMLDOMElementPtr pAJAmount = pXMLDoc->createElement(L"prebilladjustedamount");
  MSXML2::IXMLDOMElementPtr pAJPost = pXMLDoc->createElement(L"postbilladjustmentamount");
  MSXML2::IXMLDOMElementPtr pAJAmountPost = pXMLDoc->createElement(L"postbilladjustedamount");
  MSXML2::IXMLDOMElementPtr pNumPrebillAdjustments = pXMLDoc->createElement(L"numprebilladjustments");
  MSXML2::IXMLDOMElementPtr pNumPostbillAdjustments = pXMLDoc->createElement(L"numpostbilladjustments");

  pNumPrebillAdjustments->text = _bstr_t(pRowset->GetValue(L"NumPrebillAdjustments"));
  pNumPostbillAdjustments->text = _bstr_t(pRowset->GetValue(L"NumPostbillAdjustments"));

  pAJ->text = _bstr_t(pRowset->GetValue(L"PrebillAdjAmt"));
  pAJAmount->text = _bstr_t(pRowset->GetValue(L"PrebillAdjustedAmount"));
  
  pAJPost->text = _bstr_t(pRowset->GetValue(L"PostbillAdjAmt"));
  pAJAmountPost->text = _bstr_t(pRowset->GetValue(L"PostbillAdjustedAmount"));
  
  MSXML2::IXMLDOMAttributePtr pAJAmountUOMAttr = pXMLDoc->createAttribute(L"uom");
  MSXML2::IXMLDOMAttributePtr pAJUOMAttr = pXMLDoc->createAttribute(L"uom");

  MSXML2::IXMLDOMAttributePtr pAJAmountUOMAttrPost = pXMLDoc->createAttribute(L"uom");
  MSXML2::IXMLDOMAttributePtr pAJUOMAttrPost = pXMLDoc->createAttribute(L"uom");

  _bstr_t bstrCurrency = _bstr_t(pRowset->GetValue(L"Currency"));
  
  pAJUOMAttr->value =  bstrCurrency;
  pAJAmountUOMAttr->value =  bstrCurrency;
  pAJUOMAttrPost->value =  bstrCurrency;
  pAJUOMAttrPost->value =  bstrCurrency;

  pAJ->attributes->setNamedItem(pAJUOMAttr);
  pAJAmount->attributes->setNamedItem(pAJAmountUOMAttr);
  pAJPost->attributes->setNamedItem(pAJUOMAttrPost);
  pAJAmountPost->attributes->setNamedItem(pAJAmountUOMAttrPost);

  pLevelElement->appendChild(pNumPrebillAdjustments);
  pLevelElement->appendChild(pNumPostbillAdjustments);
  pLevelElement->appendChild(pAJ);
  pLevelElement->appendChild(pAJAmount);
  pLevelElement->appendChild(pAJPost);
  pLevelElement->appendChild(pAJAmountPost);

}
