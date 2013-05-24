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
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/


#include <PlugInSkeleton.h>
#include <mtprogids.h>
#include <PropValType.h>
#include <MTDec.h>

#include <vector>

using namespace std;


#define MAX __max
#define MIN __min


// {F79F1C00-2325-11d3-AA33-00105A2A148D}
CLSID CLSID_MTSubStr = { 0xf79f1c00, 0x2325, 0x11d3, { 0xaa, 0x33, 0x0, 0x10, 0x5a, 0x2a, 0x14, 0x8d } };

/////////////////////////////////////////////////////////////////////////////
// Operation struct.  This is used to represent a substr operation
/////////////////////////////////////////////////////////////////////////////

typedef struct
	{
		long	Source;
		long	Target;
		long	From;
		long	Length;
	} Operation;

bool operator==(Operation aOp1,Operation aOp2) { return true; }

/////////////////////////////////////////////////////////////////////////////
// MTAssignProp struct.  Used to assign an existing (or new property) the
// contents of another property
/////////////////////////////////////////////////////////////////////////////

typedef struct {
	long aSourceID;
	long aDestID;
	MTPipelineLib::PropValType aPropertyType;
} MTAssignProp;

bool operator==(MTAssignProp aOp1,MTAssignProp aOp2) { return true; } 


/////////////////////////////////////////////////////////////////////////////
// MTSubStr
/////////////////////////////////////////////////////////////////////////////

class ATL_NO_VTABLE MTSubStr
	: public MTPipelinePlugIn<MTSubStr, &CLSID_MTSubStr>
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
	virtual HRESULT PlugInShutdown();

	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

protected: // Non COM Methods

private: // data
	MTPipelineLib::IMTLogPtr mLogger;
	
	vector<Operation> mOperationList;
	vector<MTAssignProp> mAssignmentList;
};


PLUGIN_INFO(CLSID_MTSubStr, MTSubStr,
						"MTPipeline.MTSubStr.1", "MTPipeline.MTSubStr", "Free")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTSubStr::PlugInConfigure"
HRESULT MTSubStr::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																				MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																				MTPipelineLib::IMTNameIDPtr aNameID,
                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	mLogger = aLogger;
	HRESULT hr = S_OK;

	// step 1: get a list of the substrs to to process.

	// get the list of all substrs
	MTPipelineLib::IMTConfigPropSetPtr aAllSubStrs = aPropSet->NextSetWithName("substrs");

	if(aAllSubStrs) {

		MTPipelineLib::IMTConfigPropSetPtr SubStrs = aAllSubStrs->NextSetWithName("substr");
		while (SubStrs)
		{
			Operation oOperation;
			_bstr_t strTemp = SubStrs->NextStringWithName("source");
			oOperation.Source = aNameID->GetNameID(strTemp);
			strTemp = SubStrs->NextStringWithName("target");
			oOperation.Target = aNameID->GetNameID(strTemp);
			oOperation.From = SubStrs->NextLongWithName("start");
			oOperation.Length = SubStrs->NextLongWithName("length");
			mOperationList.push_back(oOperation);
			SubStrs = aAllSubStrs->NextSetWithName("substr");
		}
	}
	else {
		aPropSet->Reset();
	}

	// step 2: get a list of properties to assign to a new variable.  Note: if you 
	// simply want to assign a property a literal value, this is NOT the correct plugin.
	// Take a look at propgen or the ruleset plugin.

	MTPipelineLib::IMTConfigPropSetPtr aAllAssignProps = aPropSet->NextSetWithName("AssignProps");

	if(aAllAssignProps) {

		MTPipelineLib::IMTConfigPropSetPtr aAssignProp = aAllAssignProps->NextSetWithName("AssignProp");

		while(aAssignProp) {
			MTAssignProp oAssignment;
			_bstr_t aSourceProp = aAssignProp->NextStringWithName("SourceProp");
			oAssignment.aSourceID = aNameID->GetNameID(aSourceProp);

			// get the type of the property.
			MTPipelineLib::IMTConfigPropPtr aTypeProp = aAssignProp->NextWithName("type");
			oAssignment.aPropertyType = aTypeProp->GetPropType();

			// verify that the property type is supported by this plugin
			if((oAssignment.aPropertyType != MTPipelineLib::PROP_TYPE_INTEGER) &&
				 (oAssignment.aPropertyType != MTPipelineLib::PROP_TYPE_DOUBLE) &&
				 (oAssignment.aPropertyType != MTPipelineLib::PROP_TYPE_STRING) &&
				 (oAssignment.aPropertyType != MTPipelineLib::PROP_TYPE_DATETIME) &&
				 (oAssignment.aPropertyType != MTPipelineLib::PROP_TYPE_TIME) &&
				 (oAssignment.aPropertyType != MTPipelineLib::PROP_TYPE_ENUM) &&
				 (oAssignment.aPropertyType != MTPipelineLib::PROP_TYPE_DECIMAL) &&
				 (oAssignment.aPropertyType != MTPipelineLib::PROP_TYPE_BOOLEAN))
			{
				hr = Error("Property type is not supported by " PROCEDURE);
				break;
			}

			_bstr_t aDestProp = aAssignProp->NextStringWithName("DestProp");
			oAssignment.aDestID = aNameID->GetNameID(aDestProp);
			mAssignmentList.push_back(oAssignment);

			aAssignProp = aAllAssignProps->NextSetWithName("AssignProp");
		}
	}
 
	return hr;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTSubStr::PlugInProcessSession"
HRESULT MTSubStr::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{

	wstring wstrTemp;
	_bstr_t strTempSource, strTempTarget;
	HRESULT hr = S_OK;

	// step 1: process the substr operations
	
	for (unsigned int i = 0; i < mOperationList.size() ; i++)
	{
		strTempSource = aSession->GetBSTRProperty(mOperationList[i].Source);
		wstrTemp = strTempSource;
		long len = min ((long)wstrTemp.length() - mOperationList[i].From, mOperationList[i].Length);
		wstrTemp = wstrTemp.substr(mOperationList[i].From, len);
    strTempTarget = wstrTemp.c_str();
		aSession->SetBSTRProperty(mOperationList[i].Target, strTempTarget);
	}

	// step 2: process the property assignment operations
	for(i=0; i < mAssignmentList.size(); i++) {

		// get the kind of property required.
		switch(mAssignmentList[i].aPropertyType) {

			case MTPipelineLib::PROP_TYPE_INTEGER: 
				{
					long aSessionProp = aSession->GetLongProperty(mAssignmentList[i].aSourceID);
					aSession->SetLongProperty(mAssignmentList[i].aDestID,aSessionProp);
				}
				break;
			case PROP_TYPE_DOUBLE:
				{
					double aSessionProp = aSession->GetDoubleProperty(mAssignmentList[i].aSourceID);
					aSession->SetDoubleProperty(mAssignmentList[i].aDestID,aSessionProp);
				}
				break;
			case PROP_TYPE_DECIMAL:
				{
					MTDecimal aSessionProp = aSession->GetDecimalProperty(mAssignmentList[i].aSourceID);
					aSession->SetDecimalProperty(mAssignmentList[i].aDestID,aSessionProp);
				}
				break;
			case PROP_TYPE_ENUM:
				{
					long aSessionProp = aSession->GetEnumProperty(mAssignmentList[i].aSourceID);
					aSession->SetEnumProperty(mAssignmentList[i].aDestID,aSessionProp);
				}
				break;
			case PROP_TYPE_STRING: 
				{
					_bstr_t aSessionProp = aSession->GetStringProperty(mAssignmentList[i].aSourceID);
					aSession->SetStringProperty(mAssignmentList[i].aDestID,aSessionProp);
				}
				break;
			case PROP_TYPE_DATETIME: 
				{
					long aSessionProp = aSession->GetDateTimeProperty(mAssignmentList[i].aSourceID);
					aSession->SetDateTimeProperty(mAssignmentList[i].aDestID,aSessionProp);
				}
				break;
			case PROP_TYPE_TIME:
				{
					long aSessionProp = aSession->GetTimeProperty(mAssignmentList[i].aSourceID);
					aSession->SetTimeProperty(mAssignmentList[i].aDestID,aSessionProp);
				}
				break;
			case PROP_TYPE_BOOLEAN: 
				{
					VARIANT_BOOL aSessionProp = aSession->GetBoolProperty(mAssignmentList[i].aSourceID);
					aSession->SetBoolProperty(mAssignmentList[i].aDestID,aSessionProp);
				}
				break;
			default:
				hr = Error("Property type not supported.");
		}
		if(FAILED(hr)) break;
	}

	return hr;
}


/////////////////////////////////////////////////////////////////////////////
//PlugInShutdown
/////////////////////////////////////////////////////////////////////////////

HRESULT MTSubStr::PlugInShutdown()
{
	return S_OK;
}
