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
#include "MTYAAC.h"
#include "MTAccountHierarchySlice.h"
#include "AccountMetaData.h"

/////////////////////////////////////////////////////////////////////////////
// CMTAccountHierarchySlice

STDMETHODIMP CMTAccountHierarchySlice::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAccountHierarchySlice
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


// ----------------------------------------------------------------
// Arguments: Session Context, descendent account, Reference Date, actor YYAC
// Description:  Initializes the hierarchy slice with required information
// to generate queries and/or XML
// ----------------------------------------------------------------

STDMETHODIMP CMTAccountHierarchySlice::Initialize(IMTSessionContext* apCTX,
                                                  long aDescendent, 
                                                  DATE RefDate,
                                                  IMTYAAC* pActorYAAC)
{
	mDescendent = aDescendent;
	mRefDate = RefDate;
  mCTX = apCTX;
  mActorYAAC = pActorYAAC;
	return S_OK;
}


// ----------------------------------------------------------------
// Return Value:  XMLDomNode fragment that contains all of the children of an account
// Description: Renders the database query as an XML fragment for use by the UI
// ----------------------------------------------------------------

STDMETHODIMP CMTAccountHierarchySlice::GetChildListXML(IXMLDOMNode **ppNode)
{
	try {

  // step : load data if neccesary
	CheckAndLoadData();

		//if(mDomNode != NULL) {
		//	*ppNode = reinterpret_cast<IXMLDOMNode*>(mDomNode.GetInterfacePtr());
		//	(*ppNode)->AddRef();
		//}


		MSXML2::IXMLDOMDocumentPtr domDoc("MSXML2.DOMDocument.4.0");
		domDoc->loadXML("<xmlconfig />");

		MSXML2::IXMLDOMNodePtr parentNode;
		MSXML2::IXMLDOMNodePtr childNode;
		MSXML2::IXMLDOMNodePtr nameNode;
		MSXML2::IXMLDOMNodePtr folderOwner;
		MSXML2::IXMLDOMNodePtr accIDNode;
		MSXML2::IXMLDOMNodePtr hierarchyNode;
		MSXML2::IXMLDOMAttributePtr objAttr;
    MSXML2::IXMLDOMCDATASectionPtr cdataPtr;
    //MSXML2::IXMLDOMNodePtr exPropsNode;             //container for extended properties
    //MSXML2::IXMLDOMNodePtr exPropNode;

    mDomNode = domDoc->createElement("hierarchy");
		
		// set the output value
		*ppNode = reinterpret_cast<IXMLDOMNode*>(mDomNode.GetInterfacePtr());
		(*ppNode)->AddRef();

		objAttr = domDoc->createAttribute("bFolder");
		objAttr->Putvalue("Y");

		mDomNode->Getattributes()->setNamedItem(objAttr);
		objAttr = domDoc->createAttribute("bChildren");

		// step : check if any data exists or there are children
		if(mRowset == NULL || mRowset->GetRecordCount() == 0) {
			objAttr->Putvalue("N");
		}
		else {
			objAttr->Putvalue("Y");
		}

		mDomNode->Getattributes()->setNamedItem(objAttr);
		// create parent node
		parentNode = domDoc->createElement("parent_id");
		char buff[20];
		ltoa(mDescendent,buff,10);
		parentNode->Puttext(buff);
		mDomNode->appendChild(parentNode);

		// id_acc node

		accIDNode = domDoc->createElement("id_acc");
		accIDNode->Puttext(buff);
		mDomNode->appendChild(accIDNode);

		//There may be service endpoints, but no accounts..so we'll comment out
    if(mRowset == NULL || mRowset->GetRecordCount() == 0) {
			return S_OK;
		}

    if(mRowset != NULL) {
	    for(int index = 0;index < mRowset->GetRecordCount();index++) {

        // in the case of corporate accounts, do not show any accounts that
        // are not folders
        _bstr_t folderStr = (_bstr_t(mRowset->GetValue("folder")) == bstrYes) ? "Y" : "N";
        //_bstr_t folderStr = = (mRowset->GetValue("folder") ;

			  // iterate through the list of children
			  hierarchyNode = domDoc->createElement("hierarchy");
			  objAttr = domDoc->createAttribute("bChildren");
			  objAttr->Putvalue(mRowset->GetValue("children"));
			  hierarchyNode->Getattributes()->setNamedItem(objAttr);

        //add bSE
        //objAttr = domDoc->createAttribute("bConnectedSE");
       // objAttr->Putvalue(mRowset->GetValue("connected_se"));
       // hierarchyNode->Getattributes()->setNamedItem(objAttr);

        // Add the bSE attribute
       // objAttr = domDoc->createAttribute("bSE");
       // objAttr->Putvalue("N");
       // hierarchyNode->Getattributes()->setNamedItem(objAttr);


			  objAttr = domDoc->createAttribute("bFolder");
			  objAttr->Putvalue(folderStr);
			  hierarchyNode->Getattributes()->setNamedItem(objAttr);
  	
			  objAttr = domDoc->createAttribute("bPayer");
			  _variant_t empty;
			  _variant_t vtNull;
			  vtNull.vt = VT_NULL;
			  long numPayees = mRowset->GetValue("numpayees");
			  if(numPayees > 0) {
				  objAttr->Putvalue("Y");
			  }
			  else {
				  objAttr->Putvalue("N");
			  }

			  hierarchyNode->Getattributes()->setNamedItem(objAttr);

			  objAttr = domDoc->createAttribute("status");
			  objAttr->Putvalue(mRowset->GetValue("status"));
			  hierarchyNode->Getattributes()->setNamedItem(objAttr);
			  parentNode = domDoc->createElement("parent_id");
			  parentNode->Puttext(buff);
			  hierarchyNode->appendChild(parentNode);
			  childNode = domDoc->createElement("child");
        cdataPtr = domDoc->createCDATASection(_bstr_t(mRowset->GetValue("nm_login")));
        childNode->appendChild(cdataPtr);
			  hierarchyNode->appendChild(childNode);

        nameNode = domDoc->createElement("name");
        cdataPtr = domDoc->createCDATASection(_bstr_t(mRowset->GetValue("hierarchyname")));
        nameNode->appendChild(cdataPtr);
        //nameNode->Puttext(_bstr_t(
			  hierarchyNode->appendChild(nameNode);
        accIDNode = domDoc->createElement("id_acc");
			  accIDNode->Puttext(_bstr_t(mRowset->GetValue("child_id")));
			  hierarchyNode->appendChild(accIDNode);

        folderOwner = domDoc->createElement("FolderOwner");
			  _variant_t folderVal = mRowset->GetValue("folder_owner");
			  if(folderVal.vt == VT_EMPTY || folderVal.vt == VT_NULL) {
	        folderOwner->Puttext("");
			  }
			  else {
          cdataPtr = domDoc->createCDATASection(_bstr_t(folderVal));
				  folderOwner->appendChild(cdataPtr);
			  }
			  hierarchyNode->appendChild(folderOwner);
			  mDomNode->appendChild(hierarchyNode);

			  mRowset->MoveNext();
		  }
		  // reset the rowset

      if(mRowset->GetRecordCount() > 0)
		    mRowset->MoveFirst();
    }   // if mRowset == NULL

    //Check for Unconnected Service Endpoints
// For Now, don't show unconnected endpoints
/*    if(mSEUnconnectedRowset != NULL)
    {
      for(int index = 0; index < mSEUnconnectedRowset->GetRecordCount(); index++)
      {
        hierarchyNode = domDoc->createElement("hierarchy");
        
        // Service endpoints never have children
        objAttr = domDoc->createAttribute("bChildren");
        objAttr->Putvalue("N");
        hierarchyNode->Getattributes()->setNamedItem(objAttr);

        // Service endpoints are never folders
        objAttr = domDoc->createAttribute("bFolder");
	      objAttr->Putvalue("N");
        hierarchyNode->Getattributes()->setNamedItem(objAttr);

        // Add the bUnconnectedSE attribute
        objAttr = domDoc->createAttribute("bSE");
        objAttr->Putvalue("U");
        hierarchyNode->Getattributes()->setNamedItem(objAttr);

        // Set bPayer to N
        objAttr = domDoc->createAttribute("bPayer");
        objAttr->Putvalue("N");
  	    hierarchyNode->Getattributes()->setNamedItem(objAttr);

	      // No status     
        //objAttr = domDoc->createAttribute("status");
        //objAttr->Putvalue(mSERowset->GetValue("status"));
        //hierarchyNode->Getattributes()->setNamedItem(objAttr);
  			  
        // ID of account the endpoint is connected to
        parentNode = domDoc->createElement("parent_id");
        parentNode->Puttext(buff);
        hierarchyNode->appendChild(parentNode);

        // For now, use ID of the SE for the 'child' and the 'name'
        childNode = domDoc->createElement("child");
        cdataPtr = domDoc->createCDATASection(_bstr_t(mSEUnconnectedRowset->GetValue("id_se")));
        childNode->appendChild(cdataPtr);
        hierarchyNode->appendChild(childNode);

        nameNode = domDoc->createElement("name");
        cdataPtr = domDoc->createCDATASection(_bstr_t(mSEUnconnectedRowset->GetValue("nm_login")));
        nameNode->appendChild(cdataPtr);
  	    hierarchyNode->appendChild(nameNode);
    
        // ID of the SE
        accIDNode = domDoc->createElement("id_se");
		    accIDNode->Puttext(_bstr_t(mSEUnconnectedRowset->GetValue("id_se")));
		    hierarchyNode->appendChild(accIDNode);

        // Folder owner not needed
        //folderOwner = domDoc->createElement("FolderOwner");
        //folderOwner->Puttext("");
	      //folderOwner->appendChild(cdataPtr);
			  //hierarchyNode->appendChild(folderOwner);
  			
        //Add this level to the hierarchy
        mDomNode->appendChild(hierarchyNode);

        mSEUnconnectedRowset->MoveNext();
      }

      //reset rowset pointer
      if(mSEUnconnectedRowset->GetRecordCount() > 0)
        mSEUnconnectedRowset->MoveFirst();
    } */
    
    //Connected Endpoints
   /* if(mSERowset == NULL || mSERowset->GetRecordCount() == 0)
    {
      return S_OK;
    } else {
      // iterate through the list of service endpoints
      for(int index = 0;index < mSERowset->GetRecordCount();index++) {
        hierarchyNode = domDoc->createElement("hierarchy");
        
        // Service endpoints never have children
        objAttr = domDoc->createAttribute("bChildren");
        objAttr->Putvalue("N");
        hierarchyNode->Getattributes()->setNamedItem(objAttr);

        // Service endpoints are never folders
        objAttr = domDoc->createAttribute("bFolder");
	      objAttr->Putvalue("N");
        hierarchyNode->Getattributes()->setNamedItem(objAttr);

        // Add the bSE attribute
        objAttr = domDoc->createAttribute("bSE");
        objAttr->Putvalue("Y");
        hierarchyNode->Getattributes()->setNamedItem(objAttr);

        // Set bPayer to N
        objAttr = domDoc->createAttribute("bPayer");
        objAttr->Putvalue("N");
  	    hierarchyNode->Getattributes()->setNamedItem(objAttr);

	      // No status     
        //objAttr = domDoc->createAttribute("status");
        //objAttr->Putvalue(mSERowset->GetValue("status"));
        //hierarchyNode->Getattributes()->setNamedItem(objAttr);
  			  
        // ID of account the endpoint is connected to
        parentNode = domDoc->createElement("parent_id");
        parentNode->Puttext(buff);
        hierarchyNode->appendChild(parentNode);

        
        //Add an entry for each column in the XML and handle special cases.
        //Looping through each column is done to get extended properties as well.
        
        //Create the extended properties node
        exPropsNode = domDoc->createElement("extended_properties");
        long lngCount = mSERowset->Count;
        for(long i = 0; i < lngCount; i++) {
          _bstr_t strField = mSERowset->GetName(i);

          //Service Endpoint ID
          if(_wcsicmp((wchar_t *)strField, L"ID_SE") == 0) {
            // For now, use ID of the SE for the 'child' as well as id_se
            childNode = domDoc->createElement("child");
            cdataPtr = domDoc->createCDATASection(_bstr_t(mSERowset->GetValue(strField)));
            childNode->appendChild(cdataPtr);
            hierarchyNode->appendChild(childNode);

            accIDNode = domDoc->createElement("id_se");
		        accIDNode->Puttext(_bstr_t(mSERowset->GetValue(strField)));
		        hierarchyNode->appendChild(accIDNode);

          } else if(_wcsicmp((wchar_t *)strField, L"NM_LOGIN") == 0) {
            //Endpoint Primary Name
            nameNode = domDoc->createElement("name");
            cdataPtr = domDoc->createCDATASection(_bstr_t(mSERowset->GetValue(strField)));
            nameNode->appendChild(cdataPtr);
  	        hierarchyNode->appendChild(nameNode);

          } else {
            //Extended Properties
            exPropNode = domDoc->createElement(strField);
            _variant_t vtValue = mSERowset->GetValue(strField);

            //Don't add the node if NULL or there is no value
            if(vtValue.vt != VT_NULL) {
              _bstr_t strValue = vtValue;
              
              //Handle wacky case where rowset returns a value of a space " " for 
              //columns that have no data but aren't NULL.
              if((strValue.length() > 0) &&
                (_wcsicmp((wchar_t *)strValue, L" ") != 0)) {
                exPropNode->Puttext(_bstr_t(vtValue));
                exPropsNode->appendChild(exPropNode);
              }
            }
          }
        }

        //Append the extended properties node
        hierarchyNode->appendChild(exPropsNode);

    
        // Folder owner not needed
        //folderOwner = domDoc->createElement("FolderOwner");
        //folderOwner->Puttext("");
	      //folderOwner->appendChild(cdataPtr);
			  //hierarchyNode->appendChild(folderOwner);
  			
        //Add this level to the hierarchy
        mDomNode->appendChild(hierarchyNode);

        mSERowset->MoveNext();
      }
      if(mSERowset->GetRecordCount() > 0)
        mSERowset->MoveFirst();
    }*/
	}
	catch(_com_error& err) {
		const char* pErr = "Failed to create XML child list: ";
		string bufferExtraInfo;
		StringFromComError(bufferExtraInfo, "Extra Info: ", err);
		return returnYAACError(err, pErr, bufferExtraInfo.c_str(), LOG_ERROR);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Return Value:  SQLRowset of ancestors
// Description: Returns a list of all ancestors of the descendent account
// ----------------------------------------------------------------

STDMETHODIMP CMTAccountHierarchySlice::GetAncestorList(IMTSQLRowset **ppRowset)
{
	try {
	  MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
	  QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
	  queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
    queryAdapter->SetQueryTag("__LOAD_ANCESTOR_LIST__");
	  queryAdapter->AddParam("%%DESCENDENT%%",mDescendent);
    wstring DateVal;
    FormatValueForDB(_variant_t(mRefDate,VT_DATE),queryAdapter->IsOracle(),DateVal);
    queryAdapter->AddParam("%%REF_DATE%%",DateVal.c_str(),VARIANT_TRUE);
	  *ppRowset = reinterpret_cast<IMTSQLRowset*>(reader->ExecuteStatement(queryAdapter->GetQuery()).Detach());
	}
	catch(_com_error& err) {
		string bufferExtraInfo;
		StringFromComError(bufferExtraInfo, "Extra Info: ", err);
		return returnYAACError(err, bufferExtraInfo.c_str(), LOG_ERROR);
	}
	return S_OK;
}


// ----------------------------------------------------------------
// Return Value:  parent ID
// Description:   retrieves the parent account ID
// ----------------------------------------------------------------

STDMETHODIMP CMTAccountHierarchySlice::get_Parent(long *pVal)
{
	try {
		LoadParent();
		*pVal = mAncestor;
	}
	catch(_com_error& err) {
		const char* pErr = "Failed to determine parent: ";
		string bufferExtraInfo;
		StringFromComError(bufferExtraInfo, "Extra Info: ", err);
		return returnYAACError(err,pErr,bufferExtraInfo.c_str(),LOG_ERROR);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Return Value:  descendent account ID
// Description:   retrieves the descendent account ID
// ----------------------------------------------------------------

STDMETHODIMP CMTAccountHierarchySlice::get_CurrentNodeID(long *pVal)
{
	*pVal = mDescendent;
	return S_OK;
}


// ----------------------------------------------------------------
// Description:  Generates and executes the query the retrieves the hierarchy
// slice data from the database.  Note that this method has special
// code for retrieving the root of the hierachy because it is important
// that we only fetch hierarchy accounts (ignore independent accounts) and
// accessible corporate accounts.
// ----------------------------------------------------------------

void CMTAccountHierarchySlice::LoadData()
{
	MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
	QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
	queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
  queryAdapter->SetQueryTag("__LOAD_HIERACHY_LEVEL__");
	wstring DateVal;
	FormatValueForDB(_variant_t(mRefDate,VT_DATE),queryAdapter->IsOracle(),DateVal);
	queryAdapter->AddParam("%%REF_DATE%%",DateVal.c_str(),VARIANT_TRUE);
  queryAdapter->AddParam("%%ANCESTOR%%",mDescendent);
  queryAdapter->AddParam("%%TYPE_SPACE%%","system_mps");

  CAccountMetaData* metaData = CAccountMetaData::GetInstance();
  wstring ExcludedStates = metaData->GetMAMStateFilterClause();
  queryAdapter->AddParam("%%EXCLUDED_STATES%%",ExcludedStates.c_str(),VARIANT_TRUE);


  if(mDescendent == HIERARCHY_ROOT) {

     // Now we get folders and non folders, and we use the visble in hierarchy
     // flag on the account type to limit results
     queryAdapter->AddParam("%%FOLDERCHECK%%","");

     // build a query string of the list of corporate accounts that we can manage.
     MTYAACLib::IMTCollectionReadOnlyPtr colPtr = mActorYAAC->AccessibleCorporateAccounts();
     
     // get the 1st item; it it is the hierarchy root, return all corporate accounts
     long aFirstAcc = colPtr->GetItem(1);
     if(aFirstAcc == HIERARCHY_ROOT) {
       queryAdapter->AddParam("%%DESCENDENT_RANGE_CHECK%%","");
     }
     else {
       char* buff = new char[(colPtr->GetCount()*20)+100]; // 100 for padding, *20 for maximum number of digits in ID
       strcpy(buff,"parent.id_descendent in (");

       for(int i=1;i<=colPtr->GetCount();i++) {
          sprintf(buff,"%s%d,",buff,(long)colPtr->GetItem(i));
       }
       buff[strlen(buff)-1] = '\0';
       sprintf(buff,"%s) and ",buff);
     
      queryAdapter->AddParam("%%DESCENDENT_RANGE_CHECK%%",buff);
     }
  }
  else {
    // don't filter out non folders
    queryAdapter->AddParam("%%FOLDERCHECK%%","");
    // don't constrain the list of descendents
    queryAdapter->AddParam("%%DESCENDENT_RANGE_CHECK%%","");
  }

  mRowset = reader->ExecuteStatement(queryAdapter->GetQuery());

  mLoaded = true;
}

// ----------------------------------------------------------------
// Description:  Loads the hierarchy data if not already loaded
// ----------------------------------------------------------------

void CMTAccountHierarchySlice::CheckAndLoadData()
{
	if(!mLoaded) {
		LoadData();
	}
}

// ----------------------------------------------------------------
// Description: Load parent information.
// ----------------------------------------------------------------

void CMTAccountHierarchySlice::LoadParent()
{
  //Noah: 10/22/2002
  //Original code is as follows.  Was this the real intent?
	//if(mAncestor = -1) {
  if(mAncestor == -1) {
		MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
		queryAdapter->SetQueryTag("__FIND_HIERARCHY_PARENT__");
		queryAdapter->AddParam("%%DESCENDENT%%",mDescendent);
		wstring DateVal;
		FormatValueForDB(_variant_t(mRefDate,VT_DATE),queryAdapter->IsOracle(),DateVal);
		queryAdapter->AddParam("%%REF_DATE%%",DateVal.c_str(),VARIANT_TRUE);
		ROWSETLib::IMTSQLRowsetPtr rs = reader->ExecuteStatement(queryAdapter->GetQuery());
		if(rs->GetRecordCount() > 0) {
			mAncestor = rs->GetValue(0l);
		}
		else {
			const char* pErr = "failed to find parent; account may not be in the hierarchy";
			LogYAACError(pErr,LOG_WARNING);
			MT_THROW_COM_ERROR(pErr);
		}
	}
}

// ----------------------------------------------------------------
// return value: SQLRowset of all children.
// Description: Returns the list of all children.  This method uses
// the same data that is used to generate the XML fragment
// ----------------------------------------------------------------

STDMETHODIMP CMTAccountHierarchySlice::GetChildListAsRowset(IMTSQLRowset **ppRowset)
{
	try {
		CheckAndLoadData();
		*ppRowset = reinterpret_cast<IMTSQLRowset*>(mRowset.GetInterfacePtr());
		if(mRowset->GetRecordCount() > 0) {
			mRowset->MoveFirst();
		}
		(*ppRowset)->AddRef();
	}
	catch(_com_error& err) {
		const char* pErr = "Failed to get childlist as rowset: ";
		string bufferExtraInfo;
		StringFromComError(bufferExtraInfo, "Extra Info: ", err);
		return returnYAACError(err,pErr,bufferExtraInfo.c_str(),LOG_ERROR);
	}
	return S_OK;
}
