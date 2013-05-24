/**************************************************************************
 * @doc SIMPLE
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


#include <TransactionPlugInSkeleton.h>
#include <mtprogids.h>
#include <XMLset.h>
#include <vector>
#include <SetIterate.h>
#include <metra.h>
#include <comutil.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF")
using namespace ROWSETLib;

#define MAX __max




class QueryTriplet
{
public:

  _bstr_t mQueryParam;
  _bstr_t mPropertyName;
  long mPropertyID;
  _bstr_t mPropertyType;
  _bstr_t mEnumSpace;
  _bstr_t mEnumType;
  MTPipelineLib::MTSessionPropType mSessionPropType;
};


typedef std::vector<QueryTriplet> aQueryItemList;
typedef aQueryItemList::iterator aQueryItemListIter;


class MTQueryTagSet : public MTXMLSetRepeat {
public:

  MTQueryTagSet(aQueryItemList& aList) : mList(aList),bError(false) {}
  void Iterate(MTXmlSet_Item aSet[]);
  bool GetError() { return bError; }
  _bstr_t& ErrorStr() { return aErrorStr; }

protected:
  aQueryItemList& mList;
  bool bError;
  _bstr_t aErrorStr;
};

const _bstr_t aStrType("string");
const _bstr_t aIntType("int32");
const _bstr_t aBigIntType("int64");
const _bstr_t aDoubleType("double");
const _bstr_t aTimeStampType("timestamp");
const _bstr_t aDecimalType("decimal");
const _bstr_t aEnumType("enum");
const _bstr_t aBoolType("bool");

void MTQueryTagSet::Iterate(MTXmlSet_Item aSet[])
{
  // stop processing if we have allready encountered an error
  if(bError) {
    return;
  }

  QueryTriplet aQueryTriplet;

  aQueryTriplet.mQueryParam = *aSet[0].mType.aBSTR;
  aQueryTriplet.mPropertyName = *aSet[1].mType.aBSTR;
  aQueryTriplet.mPropertyType = *aSet[2].mType.aBSTR;

  // put it in the appropriate bucket
  if(aQueryTriplet.mPropertyType == aStrType) {
    aQueryTriplet.mSessionPropType = MTPipelineLib::SESS_PROP_TYPE_STRING;
  }
  else if(aQueryTriplet.mPropertyType == aIntType) {
    aQueryTriplet.mSessionPropType = MTPipelineLib::SESS_PROP_TYPE_LONG;
  }
  else if(aQueryTriplet.mPropertyType == aBigIntType) {
    aQueryTriplet.mSessionPropType = MTPipelineLib::SESS_PROP_TYPE_LONGLONG;
  }
  else if(aQueryTriplet.mPropertyType == aDoubleType) {
    aQueryTriplet.mSessionPropType = MTPipelineLib::SESS_PROP_TYPE_DOUBLE;
  }
  else if(aQueryTriplet.mPropertyType == aTimeStampType) {
    aQueryTriplet.mSessionPropType = MTPipelineLib::SESS_PROP_TYPE_TIME;
  }
  else if(aQueryTriplet.mPropertyType == aDecimalType) {
    aQueryTriplet.mSessionPropType = MTPipelineLib::SESS_PROP_TYPE_DECIMAL;
  }
  else if(aQueryTriplet.mPropertyType == aEnumType) {
    aQueryTriplet.mSessionPropType = MTPipelineLib::SESS_PROP_TYPE_ENUM;

    // check the attribset for the 
    //enumspace="metratech.com/audioconfconnection" enumtype="CallType"
    if(aSet[2].aAttribsSet == NULL) {
      bError = true;
      aErrorStr = "enumspace and enumtype attributes required for <type>enum</type> for property ";
      aErrorStr += aQueryTriplet.mPropertyName;
      return;
    }
    BSTR bstrTemp;
    if(FAILED(aSet[2].aAttribsSet->get_AttrValue(_bstr_t("enumspace"),&bstrTemp))) {
      bError = true;
      aErrorStr = "enumspace attribute not found on element <type>enum</type> for property ";
      aErrorStr += aQueryTriplet.mPropertyName;
      return;
    }
    else {
      aQueryTriplet.mEnumSpace = _bstr_t(bstrTemp,false);
    }
    if(FAILED(aSet[2].aAttribsSet->get_AttrValue(_bstr_t("enumtype"),&bstrTemp))) {
      bError = true;
      aErrorStr = "enumtype attribute not found on element <type>enum</type> for property ";
      aErrorStr += aQueryTriplet.mPropertyName;
      return;
    }
    else {
      aQueryTriplet.mEnumType = _bstr_t(bstrTemp,false);
    }

  }
  else if(aQueryTriplet.mPropertyType == aBoolType) {
    aQueryTriplet.mSessionPropType = MTPipelineLib::SESS_PROP_TYPE_BOOL;
  }
  else {
    bError = true;
    aErrorStr = aQueryTriplet.mPropertyType;
    aErrorStr += " is not a valid type";
    return;
  }

  mList.push_back(aQueryTriplet);
}


// generate using uuidgen

CLSID CLSID_MTGenericInsert = { /* 14d72660-d6ab-11d4-a66c-00c04f579c39 */
    0x14d72660,
    0xd6ab,
    0x11d4,
    {0xa6, 0x6c, 0x00, 0xc0, 0x4f, 0x57, 0x9c, 0x39}
  };

class ATL_NO_VTABLE MTGenericInsert
  : public MTTransactionPlugIn<MTGenericInsert, &CLSID_MTGenericInsert>
{
protected:

  MTGenericInsert() {}

  // Initialize the processor, looking up any necessary property IDs.
  // The processor can also use this time to do any other necessary initialization.
  // NOTE: This method can be called any number of times in order to
  //  refresh the initialization of the processor.
  virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
                                  MTPipelineLib::IMTConfigPropSetPtr aPropSet,
                                  MTPipelineLib::IMTNameIDPtr aNameID,
                                  MTPipelineLib::IMTSystemContextPtr aSysContext);

  virtual HRESULT PlugInProcessSessionWithTransaction(MTPipelineLib::IMTSessionPtr aSession,
                                                      MTPipelineLib::IMTSQLRowsetPtr aTransactionRS);


protected: // data

  MTPipelineLib::IMTLogPtr mLogger;
  aQueryItemList mItemList;
  
  _bstr_t mQuery;
  bool mbRelativeToExtension;
};

PLUGIN_INFO(CLSID_MTGenericInsert, MTGenericInsert,
            "MetraPipeline.MTGenericInsert.1", "MetraPipeline.MTGenericInsert", "both")




/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTGenericInsert ::PlugInConfigure"
HRESULT MTGenericInsert::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
                                        MTPipelineLib::IMTConfigPropSetPtr aPropSet,
                                        MTPipelineLib::IMTNameIDPtr aNameID,
                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  mLogger = aLogger;
  // step 1: define the XML layout
  _bstr_t aQueryTagStr,aPropertyStr,aTypeStr;

  MTQueryTagSet aQueryTagSet(mItemList);

  DEFINE_XML_SET(QueryTagSet)
    DEFINE_XML_STRING("query_tag",aQueryTagStr)
    DEFINE_XML_STRING("property",aPropertyStr)
    DEFINE_XML_STRING("type",aTypeStr)
  END_XML_SET()

  DEFINE_XML_SET(XmlSet)
    DEFINE_XML_STRING("InitPath",mQueryInitPath)
    DEFINE_XML_BOOL("RelativeToExtension",mbRelativeToExtension)
    DEFINE_XML_STRING("query",mQuery)
    DEFINE_XML_REPEATING_SUBSET("insert_values",QueryTagSet,&aQueryTagSet)
  END_XML_SET()

  // step 2: read service information
  MTLoadXmlSet(XmlSet,(IMTConfigPropSet*)aPropSet.GetInterfacePtr());

  // do the nameID lookup
  aQueryItemListIter it = mItemList.begin();
  while(it != mItemList.end()) {
    (*it).mPropertyID = aNameID->GetNameID((*it).mPropertyName);
    it++;
  }

  // step 3: build the query path
  if(mbRelativeToExtension) {
    _bstr_t aTemp = aSysContext->GetExtensionName();
    aTemp += DIR_SEP;
    aTemp += mQueryInitPath;
    mQueryInitPath = aTemp;
  }

  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////


#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTGenericInsert::PlugInProcessSession"
HRESULT MTGenericInsert::PlugInProcessSessionWithTransaction(MTPipelineLib::IMTSessionPtr aSession,
                                                             MTPipelineLib::IMTSQLRowsetPtr aTransactionRowset)
{
  HRESULT hr = S_OK;

  // step 1: get the rowset with the initialization path
  IMTSQLRowsetPtr pRowset = aTransactionRowset;

  // step 2: set the query
  pRowset->SetQueryTag(mQuery);

  // step 3: iterate throw the specified parameters
  aQueryItemListIter it = mItemList.begin();
  while(it != mItemList.end()) {
    _variant_t aTempVar;
    long aCurrentProp = (*it).mPropertyID;
    switch((*it).mSessionPropType)  {

      case MTPipelineLib::SESS_PROP_TYPE_DATE:
        {
          _variant_t aTemp(aSession->GetOLEDateProperty(aCurrentProp),VT_DATE);
          aTempVar = aTemp;
        }
        break;
      case MTPipelineLib::SESS_PROP_TYPE_TIME:
        aTempVar = aSession->GetTimeProperty(aCurrentProp);
        break;
      case MTPipelineLib::SESS_PROP_TYPE_STRING:
        aTempVar = aSession->GetStringProperty(aCurrentProp);
        break;
      case MTPipelineLib::SESS_PROP_TYPE_LONG:
        aTempVar = aSession->GetLongProperty(aCurrentProp);
        break;
      case MTPipelineLib::SESS_PROP_TYPE_LONGLONG:
        aTempVar = aSession->GetLongLongProperty(aCurrentProp);
        break;
      case MTPipelineLib::SESS_PROP_TYPE_DOUBLE:
        aTempVar = aSession->GetDoubleProperty(aCurrentProp);
        break;
      case MTPipelineLib::SESS_PROP_TYPE_BOOL:
        aTempVar = aSession->GetBoolProperty(aCurrentProp) == VARIANT_TRUE ? true : false;
        break;
      case MTPipelineLib::SESS_PROP_TYPE_ENUM:
        aTempVar = aSession->GetEnumProperty(aCurrentProp);
        break;
      case MTPipelineLib::SESS_PROP_TYPE_DECIMAL:
        aTempVar = aSession->GetDecimalProperty(aCurrentProp);
        break;
      default:
        ASSERT(!"Unknown type");
        return Error("Unknown type");
    }

    pRowset->AddParam((*it).mQueryParam,aTempVar);
    it++;

  }
  // step 4: execute the query
  pRowset->Execute();
  return hr;
}

