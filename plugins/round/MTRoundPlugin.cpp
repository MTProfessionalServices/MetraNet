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


#include <PlugInSkeleton.h>
#include <mtprogids.h>
#include <XMLset.h>
#include <math.h>
#include <MTDec.h>
#include <vector>

using namespace std;

#define MAX __max

/////////////////////////////////////////////////////////////////////////////
//struct ServiceItem
/////////////////////////////////////////////////////////////////////////////

struct ServiceItem {
public:
  long mRoundingAmountID;
	_bstr_t mRoundingAmount;
  long mPrecision;
};

bool operator==(ServiceItem a,ServiceItem b) { ASSERT(false); return false; }

typedef vector<ServiceItem> ServiceItemList;
typedef vector<long> PropIdsList;

// generate using uuidgen

CLSID CLSID_MTRoundPlugin = { /* e339c490-809a-11d3-a5e9-00c04f579c39 */
    0xe339c490,
    0x809a,
    0x11d3,
    {0xa5, 0xe9, 0x00, 0xc0, 0x4f, 0x57, 0x9c, 0x39}
  };

class ATL_NO_VTABLE MTRoundPlugin
	: public MTPipelinePlugIn<MTRoundPlugin, &CLSID_MTRoundPlugin>
{
protected:
	// Initialize the processor, looking up any necessary property IDs.
	// The processor can also use this time to do any other necessary initialization.
	// NOTE: This method can be called any number of times in order to
	//  refresh the initialization of the processor.
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
                                  MTPipelineLib::IMTSystemContextPtr aSysContext);

	// Shutdown the processor.  The processor can release any resources
	// it no longer needs.

	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

protected: // data
  MTPipelineLib::IMTLogPtr mLogger;
	ServiceItemList mList;
	

};

PLUGIN_INFO(CLSID_MTRoundPlugin, MTRoundPlugin,
						"MetraPipeline.MTRoundPlugin.1", "MetraPipeline.MTRoundPlugin", "Free")



/////////////////////////////////////////////////////////////////////////////
//class MTServicePropMap
/////////////////////////////////////////////////////////////////////////////

class MTServicePropMap : public MTXMLSetRepeat {
public:

  MTServicePropMap(ServiceItemList& aList) : mList(aList) {}
  void Iterate(MTXmlSet_Item aSet[]);

protected:
  ServiceItemList& mList;
};


/////////////////////////////////////////////////////////////////////////////
// Function name	: MTServicePropMap::Iterate
// Description	    : 
// Return type		: void 
// Argument         : MTXmlSet_Item aSet[]
/////////////////////////////////////////////////////////////////////////////

void MTServicePropMap::Iterate(MTXmlSet_Item aSet[])
{
  ServiceItem aServiceItem;

  aServiceItem.mRoundingAmount = *aSet[0].mType.aBSTR;
  aServiceItem.mPrecision = *aSet[1].mType.aLong;
	mList.push_back(aServiceItem);
}


/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTRoundPlugin ::PlugInConfigure"
HRESULT MTRoundPlugin::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																				MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																				MTPipelineLib::IMTNameIDPtr aNameID,
                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  mLogger = aLogger;

  _bstr_t aRoundingValueStr;
	long aPrecision;


  // step 1: create definitions for the expected format of the XML

  MTServicePropMap aServiceProps(mList);

  DEFINE_XML_SET(ServiceSet)
    DEFINE_XML_STRING("Value",aRoundingValueStr)
    DEFINE_XML_INT("Precision",aPrecision)
  END_XML_SET()

  DEFINE_XML_SET(XmlSet)
    DEFINE_XML_REPEATING_SUBSET("Rounding",ServiceSet,&aServiceProps)
  END_XML_SET()

  // step 2: read service information
  MTLoadXmlSet(XmlSet,(IMTConfigPropSet*)aPropSet.GetInterfacePtr());

  // step 2: read the expected values from the session to populate the 
  // remetered session
  for(unsigned int i=0;i<mList.size();i++) {
    ServiceItem aServiceItem = mList[i];
		aServiceItem.mRoundingAmountID = aNameID->GetNameID(aServiceItem.mRoundingAmount);
		mList.erase(mList.begin()+i);
		mList.insert(mList.begin()+i,aServiceItem);
  }

	return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////


#pragma warning (disable : 4800)

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTRoundPlugin::PlugInProcessSession"
HRESULT MTRoundPlugin::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT hr(S_OK);

#ifdef DECIMAL_PLUGINS
	// step 1: read the properties from the session
	for(unsigned int i=0;i<mList.size();i++) {
		MTDecimal aRoundingValue = aSession->GetDecimalProperty(mList[i].mRoundingAmountID);

		// don't do all the work if the value is 0
		if(aRoundingValue != 0) {
			aRoundingValue.Round(mList[i].mPrecision);
			aSession->SetDecimalProperty(mList[i].mRoundingAmountID,aRoundingValue);
		}
	}
#else
	// step 1: read the properties from the session
	for(unsigned int i=0;i<mList.length();i++) {
		double aRoundingValue = aSession->GetDoubleProperty(mList[i].mRoundingAmountID);

		// don't do all the work if the value is 0
		if(aRoundingValue != 0) {
			bool bNegative = false;
			
			if(aRoundingValue < 0) {
				bNegative = true;
				aRoundingValue = -aRoundingValue;

			}
			// step 2: perform the rounding
			double multiplier = pow(10,mList[i].mPrecision);

			double temp = aRoundingValue * multiplier;
			// NOTE: IMPORTANT:
			// numbers slightly less than a cent will floor down to the
			// next lowest number unless we add in a small value.
			double foo = floor(temp);
			double t1 = floor(temp + 0.001);
			//double t2 = floor(temp);
			// temp = floor(temp) / multiplier;
			temp = t1 / multiplier;
			aRoundingValue = temp;


			if(bNegative)
				aRoundingValue = -aRoundingValue;

			aSession->SetDoubleProperty(mList[i].mRoundingAmountID,aRoundingValue);
		}
	}
#endif

  return hr;
}

#pragma warning (default : 4800)


