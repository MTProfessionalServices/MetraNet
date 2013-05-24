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
#include "ReportManager.h"
#include "MPSReportInfo.h"
#include "MPSRenderInfo.h"
#include "DBViewHierarchy.h"
#include "mtprogids.h"

#import <MTYAAC.tlb> rename("EOF", "RowsetEOF")
#import <rowsetinterfaceslib.tlb> rename("EOF", "RowsetEOF")
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" ) 
#import <NameID.tlb>


/////////////////////////////////////////////////////////////////////////////
// CReportManager

STDMETHODIMP CReportManager::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IReportManager
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


//////////////////////////////////////////////////////////////////////////////
//  Function    : GetReportTopLevel(...)                                    //
//  Description : Return the top level HierarchyReportLevel object for the  //
//              : selected report.                                          //
//  Inputs      : lngReportIndex -- Zero-based index into the reports       //
//              :                   collection for the report to get.       //
//              : pRenderInfo -- Render info object, with report            //
//              :                information.                               //
//  Outputs     : Hierarchy Report level interface.                         //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportManager::GetReportTopLevel(long lngReportIndex, IMPSRenderInfo *pRenderInfo, IHierarchyReportLevel **pReportTopLevel)
{
	HRESULT hr;
  long lngCount;
  
  //Hierarchy Report Level
  MTHIERARCHYREPORTSLib::IHierarchyReportLevelPtr pReportLevel("MTHierarchyReports.HierarchyReportLevel.1");
  
  //Create smart pointer
	MTHIERARCHYREPORTSLib::IMPSRenderInfoPtr renderInfoPtr(pRenderInfo);

  //Report Info object
  IMPSReportInfo *pReportInfo;
  
  //BETTER ERRORS NEEDED


  //Create a smart pointer
  MTHIERARCHYREPORTSLib::IMPSReportInfoPtr reportInfoPtr;

  try
  {
    //Get the number of reports
    hr = mcollReportInfo.Count(&lngCount);

    if(FAILED(hr))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportManager, "CReportManager", "GetReportTopLevel()", "Unable to get the size of the report collection.", LOG_ERROR));

    //Check for invalid index
    if(lngReportIndex < 1 || lngReportIndex > lngCount)
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportManager, "CReportManager", "GetReportTopLevel()", "Invalid report index passed.", LOG_ERROR));

    //Get the reportinfo with the specified index
    hr = mcollReportInfo.Item(lngReportIndex, &pReportInfo);

    if(FAILED(hr))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportManager, "CReportManager", "GetReportTopLevel()", "Unable to get the item from the report collection.", LOG_ERROR));

    reportInfoPtr = pReportInfo;
		pReportInfo->Release();
		pReportInfo = 0;

    hr = pReportLevel->Init(renderInfoPtr, reportInfoPtr);

    if(FAILED(hr))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportManager, "CReportManager", "GetReportTopLevel()", "Initialization of the report level failed.", LOG_ERROR));

  }
	catch(_com_error& err)
	{
		reportInfoPtr.Release();
		return returnHierarchyReportError(err);
	}

  //NOTE:  CTX interface is no longer supported by RenderInfo, it now
  //       supports the YAAC interface.
  //hr = pReportLevel->LoadReportLevelFromXML(strReportName, "0");
	//Initialize for a payer report.  Set -1 for the account, so that
	//the report initializes to the corporate account level.
	//hr = pReportLevel->Init(-1, renderInfoPtr->CTX->AccountID, VARIANT_TRUE);
	//To initialize for a hierarchy report do the following:
	//hr = pReportLevel->Init(renderInfoPtr->CTX->AccountID, -1, VARIANT_FALSE);
  
  //if(FAILED(hr))
  //  return(Error("Unable to load report level from XML"));

  //Detach report level interface pointer so it isn't cleaned up
  *pReportTopLevel = (IHierarchyReportLevel *)pReportLevel.Detach();

  //Detach render info pointer so calling code doesn't lose it's pointer
  renderInfoPtr.Detach();

	return S_OK;
}


STDMETHODIMP CReportManager::GetReportAsXML(long lngReportIndex, IMPSRenderInfo *pRenderInfo, BSTR *strXML)
{

	return E_NOTIMPL;
}
//////////////////////////////////////////////////////////////////////////////
//  Function      : GetAvailableReportList(pYAAC)                           //
//  Description   : Return a list of reports available to the passed in     //
//                : user.  A list is generated based on the user info and   //
//                : the available types.                                    //
//  Inputs        : pYAAC -- Pointer to logged-in user's YAAC               //
//  Outputs       : Collection of report info items.                        //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportManager::GetAvailableReportList(IMTYAAC *pYAAC, IMTCollection **collReports)
{

  MTObjectCollection<IMPSReportInfo> collAvailableReports;            //Reports to return
  MTHIERARCHYREPORTSLib::IMPSReportInfoPtr spNewReportInfo;           //Used to populate new collection
  MTHIERARCHYREPORTSLib::IMPSReportInfoPtr spTempReportInfo;          //Used to iterate through report info collection
  MTYAACLib::IMTYAACPtr spYAAC;

  ROWSETLib::IMTSQLRowsetPtr spRowset;                                //Used to get folder list
  
  IMPSReportInfo *pReportInfo;                                        //Used to iterate through existing collection
  
  HRESULT hr;                                                         //HResult
  long lCount, i;                                                     //Number of items in existing collection, counter
  long lIndex = 0;

  bool bOwnedFolders = false;                                         //Report is allowed for owned folders
  bool bOnlyOwnedFolders = false;                                     //Report is ONLY allowed for owned folders
  
  bool bBillableFolders = false;                                      //Report is allowed for owned, billable folders
  bool bOnlyBillableFolders = false;                                  //Report is ONLY allowed for owned, billable folders

  _bstr_t strName;
  MTHIERARCHYREPORTSLib::MPS_REPORT_TYPE etype;


  spYAAC = pYAAC;
  
  try {

    //Get the number of items
    hr = mcollReportInfo.Count(&lCount);

    if(FAILED(hr))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportManager, "CReportManager", "GetAvailableReportList()", "Unable to get the size of the report collection.", LOG_ERROR));
    
    //For each report type, find any reports available for the user
    for(i = 1; i <= lCount; i++)
    {
      //Get the item
      hr = mcollReportInfo.Item(i, &pReportInfo);
    
      if(FAILED(hr)) {
        return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportManager, "CReportManager", "GetAvailableReportList()", "Unable to get the item from of the report collection.", LOG_ERROR));
      }
    
      //Use smart pointer
      spTempReportInfo = pReportInfo;

			//Release the non-smart pointer
			pReportInfo->Release();
			pReportInfo = 0;

      etype = spTempReportInfo->Type;
      strName = spTempReportInfo->Name;

      //Get any reports available for the user -- perform basic check
      if(CheckReportAvailability(pYAAC, spTempReportInfo))
      {
        //Perform owned folders checks
        //Check if this report is available for owned folders only
        if(spTempReportInfo->Restricted) {
          if(spTempReportInfo->RestrictionOwnedFolders == RESTRICTION_ALWAYS) {
            bOwnedFolders = true;
            bOnlyOwnedFolders = false;
          } else if(spTempReportInfo->RestrictionOwnedFolders == RESTRICTION_NEVER) {
            bOwnedFolders = false;
            bOnlyOwnedFolders = false;
          } else if(spTempReportInfo->RestrictionOwnedFolders == RESTRICTION_EXCLUSIVE) {
            bOwnedFolders = true;
            bOnlyOwnedFolders = true;
          } else {
            bOwnedFolders = true;
            bOnlyOwnedFolders = false;
          }
        } else {
          bOwnedFolders = true;
          bOnlyOwnedFolders = false;
        }              
          

        if(bOwnedFolders) {
          spRowset = spYAAC->GetOwnedFolderList();
          
          if((bool)spRowset->RowsetEOF == false) {
            spRowset->MoveFirst();

            while((bool)spRowset->RowsetEOF == false) {
              
              //Set flags for billable
              if(spTempReportInfo->Restricted) {
                if(spTempReportInfo->RestrictionBillableOwnedFolders == RESTRICTION_ALWAYS) {
                  bBillableFolders = true;
                  bOnlyBillableFolders = false;
                } else if(spTempReportInfo->RestrictionBillableOwnedFolders == RESTRICTION_NEVER) {
                  bBillableFolders = false;
                  bOnlyBillableFolders = false;
                } else if(spTempReportInfo->RestrictionBillableOwnedFolders == RESTRICTION_EXCLUSIVE) {
                  bBillableFolders = true;
                  bOnlyBillableFolders = true;
                } else {
                  bBillableFolders = true;
                  bOnlyBillableFolders = false;
                }
              } else {
                bBillableFolders = true;
                bOnlyBillableFolders = false;
              }
          
              //Check for billable folder restriction
              if(_bstr_t(spRowset->GetValue("billable")) == _bstr_t("Y"))
              {
                if(bBillableFolders) {
                  
                  //Add a report
                  hr = spNewReportInfo.CreateInstance("MTHierarchyReports.MPSReportInfo.1");

                  if(FAILED(hr))
                    return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportManager, "CReportManager", "GetAvailableReportList()", "Unable to create ReportInfo object to add to the report collection.", LOG_ERROR));
            
                  CopyReportInfo(spTempReportInfo, spNewReportInfo);

                  //Set a unique index for the report, start at 1
                  lIndex++;
                  spNewReportInfo->Index = lIndex;
                  
                  //Set the ID of the folder
                  spNewReportInfo->AccountIDOverride = (long)spRowset->GetValue("id_acc");

                  //Add the item to the collection
                  collAvailableReports.Add((IMPSReportInfo *)spNewReportInfo.GetInterfacePtr());

                  //Release
                  spNewReportInfo.Release();
                }

              //Handle non-billable folders
              } else {
                //Check exclusion of all non-billable owned folders
                if(!bOnlyBillableFolders) {
                  //Add a report
                  hr = spNewReportInfo.CreateInstance("MTHierarchyReports.MPSReportInfo.1");

                  if(FAILED(hr))
                    return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportManager, "CReportManager", "GetAvailableReportList()", "Unable to create ReportInfo object to add to the report collection.", LOG_ERROR));
            
                  CopyReportInfo(spTempReportInfo, spNewReportInfo);

                  //Set a unique index for the report, start at 1
                  lIndex++;
                  spNewReportInfo->Index = lIndex;
                  
                  //Set the ID of the folder
                  spNewReportInfo->AccountIDOverride = (long)spRowset->GetValue("id_acc");


                  //Add the item to the collection
                  collAvailableReports.Add((IMPSReportInfo *)spNewReportInfo.GetInterfacePtr());

                  //Release
                  spNewReportInfo.Release();
                }
              }

              //Get the next row
              spRowset->MoveNext();
            }
          }
        
        } else {      //Matches if bOwned

          //Check OwnedFolders and BillableOwnedFolders exclusions
          //Note that !bOwnedFolders implies !bBillableOwnedFolders and !bOnlyBillableOwnedFolders
          if(!bOnlyOwnedFolders) {

            //Create an item to add to the collection
            hr = spNewReportInfo.CreateInstance("MTHierarchyReports.MPSReportInfo.1");

            if(FAILED(hr)) {
              return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportManager, "CReportManager", "GetAvailableReportList()", "Unable to create ReportInfo object to add to the collection.", LOG_ERROR));
            }

            //Set properties
            CopyReportInfo(spTempReportInfo, spNewReportInfo);

            //Set a unique index for the report, start at 1
            lIndex++;
            spNewReportInfo->Index = lIndex;
            
            //Set the override to -1, indicating no override
            spNewReportInfo->AccountIDOverride = (long)(-1);

            //Add the item to the available item collection
            collAvailableReports.Add((IMPSReportInfo *)spNewReportInfo.GetInterfacePtr());

            //Release
            spNewReportInfo.Release();
          }
        }
      }
    }
  }
  catch(_com_error & err)
  {    
    return(returnHierarchyReportError(err));
  }

  //Copy the collection
  collAvailableReports.CopyTo(collReports);
  
	return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Function      : CopyReportInfo(spSrc, spDest)                           //
//  Description   : Copy the properties of one ReportInfo object to another //
//  Inputs        : spSrc   -- Report Info to copy from                     //
//                : spDest  -- Report Info to copy to                       //
//  Outputs       : HRESULT                                                 //
//////////////////////////////////////////////////////////////////////////////
HRESULT CReportManager::CopyReportInfo(MTHIERARCHYREPORTSLib::IMPSReportInfoPtr spSrc, MTHIERARCHYREPORTSLib::IMPSReportInfoPtr spDest)
{
  try {
    spDest->Index                           = spSrc->Index;
    spDest->Name                            = spSrc->Name;
    spDest->Description                     = spSrc->Description;
    spDest->Type                            = spSrc->Type;
    spDest->ViewType                        = spSrc->ViewType;
    spDest->Restricted                      = spSrc->Restricted;
    spDest->RestrictionBillable             = spSrc->RestrictionBillable;
    spDest->RestrictionFolderAccount        = spSrc->RestrictionFolderAccount;
    spDest->RestrictionOwnedFolders         = spSrc->RestrictionOwnedFolders;
    spDest->RestrictionBillableOwnedFolders = spSrc->RestrictionBillableOwnedFolders;
    spDest->RestrictionIndependentAccount   = spSrc->RestrictionIndependentAccount;
    spDest->DisplayMethod                   = spSrc->DisplayMethod;
    spDest->DisplayData                     = spSrc->DisplayData;
  }
  catch(_com_error & err)
  {
    return(returnHierarchyReportError(err));
  }

  return(S_OK);

}
//////////////////////////////////////////////////////////////////////////////
//  Function      : CheckBillable(pYAAC)                                    //
//  Description   : Determine if the user is billable.                      //
//  Inputs        : pYAAC -- User YAAC                                      //
//  Outputs       : boolean indicating if the user is billable or not.      //
//////////////////////////////////////////////////////////////////////////////
bool CReportManager::CheckBillable(IMTYAAC *pYAAC)
{
  MTYAACLib::IMTPaymentMgrPtr pPaymentManager;
  MTYAACLib::IMTYAACPtr spYAAC;

  spYAAC = pYAAC;

  pPaymentManager = spYAAC->GetPaymentMgr();

  if(pPaymentManager->AccountIsBillable)
    return(true);
  else
    return(false);

}
//////////////////////////////////////////////////////////////////////////////
//  Function      : CheckFolderOwner(spYAAC)                                //
//  Description   : Determine if the user is a folder owner.                //
//  Inputs        : pYAAC -- User YAAC                                      //
//  Outputs       : boolean indicating if the user owns folders.            //
//////////////////////////////////////////////////////////////////////////////
bool CReportManager::CheckFolderOwner(IMTYAAC *pYAAC)
{
  ROWSETLib::IMTSQLRowsetPtr pRowset;
  MTYAACLib::IMTYAACPtr spYAAC;

  spYAAC = pYAAC;

  pRowset = spYAAC->GetOwnedFolderList();

  if(pRowset->RecordCount > 0)
    return(true);
  else
    return(false);
  
}
//////////////////////////////////////////////////////////////////////////////
//  Function      : CheckFolderAccount(pspYAAC)                             //
//  Description   : Determine if the user is a folder account.              //
//  Inputs        : spYAAC -- User YAAC                                     //
//  Outputs       : boolean indicating if the user is a folder.             //
//////////////////////////////////////////////////////////////////////////////
bool CReportManager::CheckFolderAccount(IMTYAAC *pYAAC)
{
  MTYAACLib::IMTYAACPtr spYAAC;

  spYAAC = pYAAC;
  
  return(spYAAC->IsFolder == VARIANT_TRUE) ? true : false;
}
//////////////////////////////////////////////////////////////////////////////
//  Function      : CheckIndependentAccount(pYAAC)                          //
//  Description   : Determine if the user is an independent account.        //
//  Inputs        : pYAAC -- User YAAC                                      //
//  Outputs       : boolean indicating if the user is an independent        //
//                : account or not.                                         //
//////////////////////////////////////////////////////////////////////////////
bool CReportManager::CheckIndependentAccount(IMTYAAC *pYAAC)
{
  MTYAACLib::IMTYAACPtr spYAAC;

  spYAAC = pYAAC;

  if(spYAAC->AccountType == _bstr_t(L"IndependentAccount"))
    return(true);
  else
    return(false);

}
//////////////////////////////////////////////////////////////////////////////
//  Function      : CheckReportAvailability(pspYAAC, pReportInfo)           //
//  Description   : Based on the render information, check if restrictions  //
//                : in the report information allow the user to view the    //
//                : report.                                                 //
//  Inputs        : spYAAC -- User YAAC                                     //
//                : pReportInfo -- ReportInfo object with information about //
//                :                the report.                              //
//  Outputs       : Boolean indicating if the user described by the render  //
//                : information can view the report.                        //
//////////////////////////////////////////////////////////////////////////////
bool CReportManager::CheckReportAvailability(IMTYAAC *pYAAC, MTHIERARCHYREPORTSLib::IMPSReportInfoPtr spReportInfo)
{
  bool bBillable = false;
  bool bFolderAccount = false;
  bool bFolderOwner = false;
  bool bIndependent = false;
  
  //Check restrictions
  if(spReportInfo->Restricted)
  {
    bBillable = CheckBillable(pYAAC);
    bFolderOwner = CheckFolderOwner(pYAAC);
    bFolderAccount = CheckFolderAccount(pYAAC);
    bIndependent = CheckIndependentAccount(pYAAC);
  
    //Check the exclusives first, negative cases
    //Billable
    if(spReportInfo->RestrictionBillable == RESTRICTION_EXCLUSIVE) {
      if(!bBillable)
        return(false);
    }

    //Folder Account
    if(spReportInfo->RestrictionFolderAccount == RESTRICTION_EXCLUSIVE) {
      if(!bFolderAccount)
        return(false);
    }

    //Folder Owner
    if(spReportInfo->RestrictionOwnedFolders == RESTRICTION_EXCLUSIVE) {
      if(!bFolderOwner)
        return(false);
    }
    
    if(spReportInfo->RestrictionBillableOwnedFolders == RESTRICTION_EXCLUSIVE) {
      if(!bFolderOwner)
        return(false);
    }

    if(spReportInfo->RestrictionIndependentAccount == RESTRICTION_EXCLUSIVE) {
      if(!bIndependent)
        return(false);
    
    }
    
    //Now check other restrictions -- Owned folder restrictions are checked in the
    //                                calling function

    //Billable
    if(bBillable)
      if(spReportInfo->RestrictionBillable == RESTRICTION_NEVER)
        return(false);
    
	  //Folder
    if(bFolderAccount)
  	  if(spReportInfo->RestrictionFolderAccount == RESTRICTION_NEVER)
	      return(false);

    if(bIndependent)  
      if(spReportInfo->RestrictionIndependentAccount == RESTRICTION_NEVER)
        return(false);

  } //if spReportInfo->Restricted
  
  return(true);
}
//////////////////////////////////////////////////////////////////////////////
//  Function      : AddReportToCollection(...)                              //
//  Description   : Based on the passed in XML, create and add a ReportInfo //
//                : object to the collection of possible reports.           //
//  Inputs        : pReportNode -- XML node containing the report data.     //
//                : eReportType -- The type of report to add.               //
//  Outputs       : HRESULT                                                 //
//////////////////////////////////////////////////////////////////////////////
HRESULT CReportManager::AddReportToCollection(MSXML2::IXMLDOMNode *pReportNode, MPS_REPORT_TYPE eReportType, long lngIndex)
{
  MTHIERARCHYREPORTSLib::IMPSReportInfoPtr pReportInfo;     //Report info  
  MSXML2::IXMLDOMNodePtr pChildNode = NULL;                 //Child nodes of the report node
  MSXML2::IXMLDOMAttributePtr pAttr = NULL;
  _bstr_t strText;                                          //Used to get node values
  HRESULT hr;
  
  try {
    //Create a report info object
    if(FAILED(hr = pReportInfo.CreateInstance("MTHierarchyReports.MPSReportInfo.1")))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportManager, "CReportManager", "AddReportToCollection()", "Unable to create ReportInfo object to add to the collection.", LOG_ERROR));

    //Set the index
    pReportInfo->Index = lngIndex;

    //Set the report type
    pReportInfo->Type = static_cast<MTHIERARCHYREPORTSLib::MPS_REPORT_TYPE>(eReportType);
    

    //Get the report name
    pChildNode = pReportNode->selectSingleNode(L"name");
    strText = pChildNode->text;
    pReportInfo->Name = strText;

    //Get the description
    pChildNode = pReportNode->selectSingleNode(L"description");
    strText = pChildNode->text;
    pReportInfo->Description = strText;

    //Get the view type
    if(eReportType != REPORT_TYPE_STATIC_REPORT) {
      pChildNode = pReportNode->selectSingleNode(L"view_type");
      strText = pChildNode->text;

      if(strText == _bstr_t("By Folder"))
        pReportInfo->ViewType = static_cast<MTHIERARCHYREPORTSLib::MPS_VIEW_TYPE>(VIEW_TYPE_BY_FOLDER);
      else if(strText == _bstr_t("By Product"))
        pReportInfo->ViewType = static_cast<MTHIERARCHYREPORTSLib::MPS_VIEW_TYPE>(VIEW_TYPE_BY_PRODUCT);
      else
        pReportInfo->ViewType = static_cast<MTHIERARCHYREPORTSLib::MPS_VIEW_TYPE>(VIEW_TYPE_BOTH);
    }

  
    //Get the restricted flag
    pChildNode = pReportNode->selectSingleNode(L"restricted");
    strText = pChildNode->text;

    if(strText == _bstr_t("Yes"))
    {
      pReportInfo->Restricted = true;

      //Get the restrictions
    
      //Billable
      pAttr = pChildNode->attributes->getNamedItem(L"billable");

      if(pAttr != NULL) {
        strText = pAttr->value;

        if(strText == _bstr_t("Always"))
          pReportInfo->RestrictionBillable = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(RESTRICTION_ALWAYS);
        else if(strText == _bstr_t("Never"))
          pReportInfo->RestrictionBillable = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(RESTRICTION_NEVER);
        else if(strText == _bstr_t("Exclusive"))
          pReportInfo->RestrictionBillable = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(RESTRICTION_EXCLUSIVE);
        else
          pReportInfo->RestrictionBillable = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(NOT_RESTRICTED);
      } else {
        pReportInfo->RestrictionBillable = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(NOT_RESTRICTED);   //Don't leave unitialized
      }

      //Folder
      pAttr = pChildNode->attributes->getNamedItem(L"folder");

      if(pAttr != NULL) {
        strText =  pAttr->value;

        if(strText == _bstr_t("Always"))
          pReportInfo->RestrictionFolderAccount = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(RESTRICTION_ALWAYS);
        else if(strText == _bstr_t("Never"))
          pReportInfo->RestrictionFolderAccount = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(RESTRICTION_NEVER);
        else if(strText == _bstr_t("Exclusive"))
          pReportInfo->RestrictionFolderAccount = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(RESTRICTION_EXCLUSIVE);
        else
          pReportInfo->RestrictionFolderAccount = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(NOT_RESTRICTED);
      } else {
        pReportInfo->RestrictionFolderAccount = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(NOT_RESTRICTED);  //Don't leave unitialized
      }


      //Owned Folders
      //Only Supports YES / NO
      pAttr = pChildNode->attributes->getNamedItem(L"owned_folders");

      if(pAttr != NULL) {
        strText = pAttr->value;

        if(strText == _bstr_t("Always"))
          pReportInfo->RestrictionOwnedFolders = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(RESTRICTION_ALWAYS);
        else if(strText == _bstr_t("Never"))
          pReportInfo->RestrictionOwnedFolders = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(RESTRICTION_NEVER);
        else if(strText == _bstr_t("Exclusive"))
          pReportInfo->RestrictionOwnedFolders = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(RESTRICTION_EXCLUSIVE);
        else
          pReportInfo->RestrictionOwnedFolders = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(NOT_RESTRICTED);
        
      } else {
        pReportInfo->RestrictionOwnedFolders = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(NOT_RESTRICTED);
      }


      //Billable Owned Folders
      pAttr = pChildNode->attributes->getNamedItem(L"billable_owned_folders");

      if(pAttr != NULL) {
        strText = pAttr->value;

        if(strText == _bstr_t("Always"))
          pReportInfo->RestrictionBillableOwnedFolders = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(RESTRICTION_ALWAYS);
        else if(strText == _bstr_t("Never"))
          pReportInfo->RestrictionBillableOwnedFolders = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(RESTRICTION_NEVER);
        else if(strText == _bstr_t("Exclusive"))
          pReportInfo->RestrictionBillableOwnedFolders = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(RESTRICTION_EXCLUSIVE);
        else
          pReportInfo->RestrictionBillableOwnedFolders = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(NOT_RESTRICTED);

      } else {
        pReportInfo->RestrictionBillableOwnedFolders = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(NOT_RESTRICTED);
      }

      //Independent Accounts
      pAttr = pChildNode->attributes->getNamedItem(L"independent_accounts");

      if(pAttr != NULL) {
        strText = pAttr->value;
        
        if(strText == _bstr_t("Always"))
          pReportInfo->RestrictionIndependentAccount = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(RESTRICTION_ALWAYS);
        else if(strText == _bstr_t("Never"))
          pReportInfo->RestrictionIndependentAccount = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(RESTRICTION_NEVER);
        else if(strText == _bstr_t("Exclusive"))
          pReportInfo->RestrictionIndependentAccount = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(RESTRICTION_EXCLUSIVE);
        else
          pReportInfo->RestrictionIndependentAccount = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(NOT_RESTRICTED);
        
      } else {
        pReportInfo->RestrictionIndependentAccount = static_cast<MTHIERARCHYREPORTSLib::MPS_RESTRICTION>(NOT_RESTRICTED);
      }

    } else {
      pReportInfo->Restricted = false;
    }


    //Get the display method -- Static reports always link to a custom page
    if(eReportType != REPORT_TYPE_STATIC_REPORT) {
      pChildNode = pReportNode->selectSingleNode(L"display_method");

      strText = pChildNode->text;

      //Get the value of a node, depending on the value
      if(strText == _bstr_t("XSL")) {
        pReportInfo->DisplayMethod = static_cast<MTHIERARCHYREPORTSLib::MPS_DISPLAY_METHOD>(DISPLAY_METHOD_XSL);
        pChildNode = pReportNode->selectSingleNode(L"stylesheet");
        pReportInfo->DisplayData = pChildNode->text;
  
      } else if(strText == _bstr_t("Generic ASP")) {
        pReportInfo->DisplayMethod = static_cast<MTHIERARCHYREPORTSLib::MPS_DISPLAY_METHOD>(DISPLAY_METHOD_GENERIC_ASP);
      } else if(strText == _bstr_t("Object Report")) {
        pReportInfo->DisplayMethod = static_cast<MTHIERARCHYREPORTSLib::MPS_DISPLAY_METHOD>(DISPLAY_METHOD_OBJECT_REPORT);
      } else if(strText == _bstr_t("Custom ASP")) {
        pReportInfo->DisplayMethod = static_cast<MTHIERARCHYREPORTSLib::MPS_DISPLAY_METHOD>(DISPLAY_METHOD_CUSTOM_ASP);
        pChildNode = pReportNode->selectSingleNode(L"custom_asp");
        pReportInfo->DisplayData = pChildNode->text;
      } else {
        pReportInfo->DisplayMethod = static_cast<MTHIERARCHYREPORTSLib::MPS_DISPLAY_METHOD>(DISPLAY_METHOD_CUSTOM_FUNCTION);
        pChildNode = pReportNode->selectSingleNode(L"custom_function");
        pReportInfo->DisplayData = pChildNode->text;
      }
    } else {
      pChildNode = pReportNode->selectSingleNode(L"custom_asp");
      
      pReportInfo->DisplayMethod = static_cast<MTHIERARCHYREPORTSLib::MPS_DISPLAY_METHOD>(DISPLAY_METHOD_CUSTOM_ASP);
      pReportInfo->DisplayData = pChildNode->text;
    }
  

    //Add the item to the collection
    mcollReportInfo.Add((IMPSReportInfo *)pReportInfo.GetInterfacePtr());

    pReportInfo.Release();
  }

  
  catch(_com_error & err)
  {
    return(returnHierarchyReportError(err));
  }

  return(S_OK);
}
//////////////////////////////////////////////////////////////////////////////
//  Function      : Initialize(strReportConfigPath)                         //
//  Description   : At application start, load the report configurations    //
//                : from the specified files.                               //
//  Inputs        : strReportConfigPath -- Path to report configuration     //
//                :                        file.                            //
//  Outputs       : HRESULT                                                 //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportManager::Initialize(BSTR strReportConfigPath)
{
  MSXML2::IXMLDOMDocumentPtr pXMLDoc("MSXML2.DOMDocument.4.0");         //XML document
  MSXML2::IXMLDOMNodeListPtr pNodeList;                                 //XML node list
  MSXML2::IXMLDOMNodePtr pReportNode = NULL;                            //XML report / bill node
  MSXML2::IXMLDOMParseErrorPtr pParseError = NULL;                      //XML parse error object
  long lngErrorCode = 0;                                                //XML parse error value
  long i = 0;                                                           //Loop counter
  long lngLength = 0;                                                   //Nodelist length
  long lngCount = 0;                                                    //Count of number of reports
  HRESULT hr;

  try 
  {
    //Initialize the DOMDocument
    pXMLDoc->async = false;
    pXMLDoc->validateOnParse = false;
    pXMLDoc->resolveExternals = false;

    //Load the report configuration
    if(pXMLDoc->load(strReportConfigPath) == false) 
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportManager, "CReportManager", "Initialize()", "Unable to open specified reports configuration file.", LOG_ERROR));

    
    //Check for parse error
    pParseError = pXMLDoc->parseError;

    lngErrorCode = pParseError->errorCode;

    if(lngErrorCode != 0) 
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportManager, "CReportManager", "Initialize()", "A parse error occurred while reading the report configuration file.", LOG_ERROR));

    //If we get here, the file loaded and parsed
    //Now get a list of the bills
    pNodeList = pXMLDoc->selectNodes(L"/metraview_reports/bills/bill");

    lngLength = pNodeList->length;

    //Loop through the list
    for(i = 0; i < lngLength; i++)
    {
      //Increment counter
      lngCount++;

      //Get the bill node
      pReportNode = pNodeList->item[i];
      
      if(FAILED(hr = AddReportToCollection(pReportNode, REPORT_TYPE_BILL, lngCount)))
        return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportManager, "CReportManager", "Initialize()", "An error occurred while adding the report metadata to the collection.", LOG_ERROR));
    }


    //Get the list of Interactive Reports
    pNodeList = pXMLDoc->selectNodes(L"/metraview_reports/interactive_reports/interactive_report");
    
    //Get the length of the list
    lngLength = pNodeList->length;
    
    //Loop through the list
    for(i = 0; i < lngLength; i++)
    {
      //Increment counter
      lngCount++;

      //Get the report node
      if(FAILED(hr = pNodeList->get_item(i, &pReportNode)))
        return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportManager, "CReportManager", "Initialize()", "Unable to get Node from NodeList.", LOG_ERROR));

      if(FAILED(hr = AddReportToCollection(pReportNode, REPORT_TYPE_INTERACTIVE_REPORT, lngCount)))
        return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportManager, "CReportManager", "Initialize()", "An error occurred while adding the report metadata to the collection.", LOG_ERROR));
    }


    //Get the list of Static Reports
    pNodeList = pXMLDoc->selectNodes(L"/metraview_reports/static_reports/static_report");

    //Get the length of the list
    lngLength = pNodeList->length;

    //Loop throught the list
    for(i = 0; i < lngLength; i++)
    {
      //Increment Counter
      lngCount++;

      //Get the report node
      if(FAILED(hr = pNodeList->get_item(i, &pReportNode)))
        return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportManager, "CReportManager", "Initialize()", "Unable to get Node from NodeList.", LOG_ERROR));

      if(FAILED(hr = AddReportToCollection(pReportNode, REPORT_TYPE_STATIC_REPORT, lngCount)))
        return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportManager, "CReportManager", "Initialize()", "An error occurred while adding the report metadata to the collection.", LOG_ERROR));
    }


  }

  catch(_com_error & err)
  {
    return(returnHierarchyReportError(err));
  }

  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
//  Function      : GetReportHelper(pYAAC, lngLanguageID)                   //
//  Description   : Create and a return a reports helper for the user.     //
//  Inputs        : pYAAC -- YAAC for the user                             //
//                : lngLanguageID -- Language ID for the user              //
//  Outputs       : pReportsHelper Interface                               //
/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportManager::GetReportHelper(IMTYAAC *pYAAC, long lngLanguageID, IReportHelper **pReportHelper)
{
  MTObjectCollection<IMPSReportInfo> collAvailableReports; 
  MTHIERARCHYREPORTSLib::IReportHelperPtr spReportHelper("MTHierarchyReports.ReportHelper.1");
  MTHIERARCHYREPORTSLib::IMTCollection *pCollection;
    
  try {
    //Get the collection of available reports
    GetAvailableReportList(pYAAC, &collAvailableReports);

    collAvailableReports.CopyTo((IMTCollection **)&pCollection);
    
    //Initialize the reports helper
    spReportHelper->Initialize((MTHIERARCHYREPORTSLib::IMTYAAC *)pYAAC, lngLanguageID, pCollection);

    //Assign the output
    *pReportHelper = (IReportHelper *)spReportHelper.Detach();

		pCollection->Release();
  }

  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }

	return S_OK;
}

