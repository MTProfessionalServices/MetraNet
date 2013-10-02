// MTRuleSetDef.cpp : Implementation of CMTRuleSet
#include "StdAfx.h"
#include "MTRuleSet.h"
#include "MTRuleSetDef.h"

//#import <MTRuleSet.tlb>

#include <mtprogids.h>

#include <mtcomerr.h>

#include <SetIterate.h>

using MTConfigLib::IMTConfigPtr;
using MTConfigLib::IMTConfigPropSetPtr;
using MTConfigLib::IMTConfigAttribSetPtr;
using MTConfigLib::IMTConfigPropPtr;

using MTRULESETLib::IMTRulePtr;
using MTRULESETLib::IMTActionSetPtr;
using MTRULESETLib::IMTConditionSetPtr;
using MTRULESETLib::IMTAssignmentActionPtr;
using MTRULESETLib::IMTSimpleConditionPtr;

#include <RuleSetConfigInclude.h>

// TODO:
// next set with name

/////////////////////////////////////////////////////////////////////////////
// CMTRuleSet

STDMETHODIMP CMTRuleSet::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTRuleSet,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTRuleSet::FinalConstruct()
{
	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &m_pUnkMarshaler.p);
}

void CMTRuleSet::FinalRelease()
{
	m_pUnkMarshaler.Release();
}

// ----------------------------------------------------------------
// Description: Read the rule set from the given file.
// Arguments:   filename - XML file to read rules from.
// ----------------------------------------------------------------
STDMETHODIMP CMTRuleSet::Read(/*[in]*/ BSTR filename)
{
	try
	{
		IMTConfigPtr config(MTPROGID_CONFIG);

		_bstr_t bstrName(filename);

		VARIANT_BOOL checksumMatch;
		config->PutAutoEnumConversion(VARIANT_FALSE);
		IMTConfigPropSetPtr propSet = config->ReadConfiguration(bstrName, &checksumMatch);

		HRESULT hr = InputRuleSet(propSet);
		return hr;
	}
	catch (_com_error err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}


// ----------------------------------------------------------------
// Description: Read the rule set from an IMTConfigPropSet object
// Arguments:   set - IMTConfigPropSet object holding the rule set
// ----------------------------------------------------------------
STDMETHODIMP CMTRuleSet::ReadFromSet(::IMTConfigPropSet* pSet)
{

	HRESULT hr = S_OK;

	try {
		IMTConfigPropSetPtr propSet = pSet;
		HRESULT hr = InputRuleSetData(propSet);
		if (FAILED(hr))
			return hr;
	}
	catch (_com_error err)
	{
		hr = ReturnComError(err);
	}
	return hr;

	return S_OK;
}


// ----------------------------------------------------------------
// Description: Read the rule set from the given host, via HTTP
// Arguments:   hostname - HTTP host to read rules from
//              relativePath - file part of the URL to read from
//              secure - if true, read using HTTPS, otherwise use HTTP
// ----------------------------------------------------------------
STDMETHODIMP CMTRuleSet::ReadFromHost(/*[in]*/ BSTR hostname, /*[in]*/ BSTR relativePath,
																			VARIANT_BOOL secure)
{
	try
	{
		IMTConfigPtr config(MTPROGID_CONFIG);

		VARIANT_BOOL checksumMatch;
 
		IMTConfigPropSetPtr propSet = config->ReadConfigurationFromHost(hostname,
																																		relativePath,
																																		secure,
																																		&checksumMatch);

		HRESULT hr = InputRuleSet(propSet);
		if (FAILED(hr))
			return hr;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}



// ----------------------------------------------------------------
// Description: Write the rule set to a file.
// Arguments:   filename - path of the XML file to write to
// ----------------------------------------------------------------
STDMETHODIMP CMTRuleSet::Write(/*[in]*/ BSTR filename)
{
	try
	{
		IMTConfigPropSetPtr propSet;

		IMTConfigPtr config(MTPROGID_CONFIG);
		config->PutAutoEnumConversion(VARIANT_FALSE);
		// TODO: should this always be xmlconfig?
		propSet = config->NewConfiguration("xmlconfig");

		HRESULT hr = OutputRules(propSet);
		if (FAILED(hr))
			return hr;

		_bstr_t bstrName(filename);
		propSet->Write(bstrName);

		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}


// ----------------------------------------------------------------
// Description:  Write the rule set to an IMTConfigPropSet object
// Return Value: IMTConfigPropSet holding the rule set
// ----------------------------------------------------------------
STDMETHODIMP CMTRuleSet::WriteToSet(::IMTConfigPropSet** ppSet)
{
	HRESULT hr = S_OK;
	try
	{	
		IMTConfigPtr config(MTPROGID_CONFIG);

		IMTConfigPropSetPtr propSet = config->NewConfiguration("configdata");

		HRESULT hr = OutputRuleSetData(propSet);
		if (FAILED(hr))
			return hr;

		(*ppSet) = (IMTConfigPropSet *) propSet.GetInterfacePtr();
		(*ppSet)->AddRef();
	}
	catch (_com_error err)
	{
		return ReturnComError(err);
	}
	return hr;
}


// ----------------------------------------------------------------
// Description: Write the rule set to the given host, via HTTP
// Arguments:   hostname - HTTP host to read rules from
//              relativePath - file part of the URL to read from
//              username - HTTP basic auth user name.  If empty string,
//                         use no username
//              password - HTTP basic auth password.  If empty string,
//                         use no password
//              secure - if true, read using HTTPS, otherwise use HTTP
// ----------------------------------------------------------------
STDMETHODIMP CMTRuleSet::WriteToHost(BSTR aHostName, BSTR aRelativePath,
																		 BSTR aUsername, BSTR aPassword,
																		 VARIANT_BOOL aSecure)
{
	try
	{
		IMTConfigPropSetPtr propSet;

		IMTConfigPtr config(MTPROGID_CONFIG);
		config->PutAutoEnumConversion(VARIANT_FALSE);
		// TODO: should this always be xmlconfig?
		propSet = config->NewConfiguration("xmlconfig");

		HRESULT hr = OutputRules(propSet);
		if (FAILED(hr))
			return hr;

		// last param is the checksum flag
		propSet->WriteToHost(aHostName, aRelativePath, aUsername, aPassword,
												 aSecure, VARIANT_TRUE);

		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

/******************************************** Output methods ***/


HRESULT CMTRuleSet::OutputMTSysHeader(IMTConfigPropSetPtr aPropSet,
																			long aDate, long aTimeoutDates)
{
	// insert header information: effective date, timeout value etc.
	IMTConfigPropSetPtr header = aPropSet->InsertSet(SYSCONFIGDATA);

	if (aDate == -1)
		return Error("Invalid date");

	header->InsertProp(EFFECTIVEDATE, MTConfigLib::PROP_TYPE_DATETIME, aDate);

	long timeout;
	if (aTimeoutDates == 0)
		timeout = DEFAULT_TIMEOUT;
	else
		timeout = aTimeoutDates;

	_variant_t var = timeout;

	header->InsertProp(TIMEOUT, MTConfigLib::PROP_TYPE_INTEGER, var);

	header->InsertProp(CONFIGFILETYPE, MTConfigLib::PROP_TYPE_STRING, CONFIG_DATA);
	return S_OK;
}


HRESULT CMTRuleSet::OutputMTPlugInHeader(IMTConfigPropSetPtr aPropSet, 
																				 _bstr_t name, 
																				 _bstr_t aProgID,
																				 _bstr_t aDescription)
{
//	char errBuf[MAX_BUFFER_SIZE];

	/*
			<name>Stage1</name>
			<progid>MTPipeline.PropGenProcessor.1</progid>
			<description>Determintes the applicability (true or false) of cancellation charges.</description>

			<inputs>
        <input type="LONG">ServiceLevel</input>
				<input type="LONG">ScheduledConnections</input>
				<input type="LONG">Notice</input>
      </inputs>

      <outputs>
        <output type="BOOLEAN">CancelApplicBool</output>
      </outputs>
*/
	aPropSet->InsertProp(RULESET_NAME, MTConfigLib::PROP_TYPE_STRING, name);
	aPropSet->InsertProp(RULESET_PROGID, MTConfigLib::PROP_TYPE_STRING, aProgID);
	if (aDescription.length() == 0)
	{
		aPropSet->InsertProp(RULESET_DESCRIPTION, MTConfigLib::PROP_TYPE_STRING,
												 mDescription);
	}
	else
	{
		aPropSet->InsertProp(RULESET_DESCRIPTION, MTConfigLib::PROP_TYPE_STRING,
												 aDescription);
	}

	IMTConfigPropSetPtr subSet = aPropSet->InsertSet(RULESET_INPUTS);

	IMTConfigAttribSetPtr aAttribSet(MTPROGID_CONFIG_ATTRIB_SET);
	IMTConfigPropPtr aConfigProp(MTPROGID_PROPERTY);

	_bstr_t propertyName;
	_bstr_t propertyType;
	_bstr_t enumType;
	_bstr_t enumSpace;
	MTConfigLib::PropValType nameType = MTConfigLib::PROP_TYPE_STRING;
	int i;

	int entries = mInputArgList.size();
	for (i = 0; i < entries; i++)
	{
		propertyName = mInputArgList[i].GetPropertyName();
		propertyType = mInputArgList[i].GetPropertyType();
		enumType = mInputArgList[i].GetEnumType();
		enumSpace = mInputArgList[i].GetEnumSpace();

		if (propertyType.length() != 0)
		{
			aAttribSet->Initialize();
			aAttribSet->AddPair(gpPropertyTypeTag, propertyType);

			// if there is enumType value, put it in.
			if (enumType.length() != 0)
			{
				aAttribSet->AddPair(gpEnumTypeTag, enumType);
			}

			// if there is enumSpace value, put it in.
			if (enumSpace.length() != 0)
			{
				aAttribSet->AddPair(gpEnumSpaceTag, enumSpace);
			}

			aConfigProp->PutName(RULESET_INPUT);
			aConfigProp->AddProp(nameType, propertyName);

			aConfigProp->PutAttribSet(aAttribSet);

			subSet->InsertConfigProp(aConfigProp);
		}
		else
		{
			subSet->InsertProp(RULESET_INPUT, MTConfigLib::PROP_TYPE_STRING, propertyName);
		}
	}


	subSet = aPropSet->InsertSet(RULESET_OUTPUTS);
	
	entries = mOutputArgList.size();
	for (i = 0; i < entries; i++)
	{
		propertyName = mOutputArgList[i].GetPropertyName();
		propertyType = mOutputArgList[i].GetPropertyType();
		enumSpace = mOutputArgList[i].GetEnumSpace();

		if (propertyType.length() != 0)
		{
			aAttribSet->Initialize();
			aAttribSet->AddPair(gpPropertyTypeTag, propertyType);

			// if there is enumType value, put it in.
			if (enumType.length() != 0)
			{
				aAttribSet->AddPair(gpEnumTypeTag, enumType);
			}

			// if there is enumSpace value, put it in.
			if (enumSpace.length() != 0)
			{
				aAttribSet->AddPair(gpEnumSpaceTag, enumSpace);
			}

			aConfigProp->PutName(RULESET_OUTPUT);
			aConfigProp->AddProp(nameType,propertyName);

			aConfigProp->PutAttribSet(aAttribSet);

			subSet->InsertConfigProp(aConfigProp);
		}
		else
		{
			subSet->InsertProp(RULESET_OUTPUT, MTConfigLib::PROP_TYPE_STRING, propertyName);
		}
	}

	return S_OK;
}

HRESULT CMTRuleSet::OutputRuleSetData(IMTConfigPropSetPtr aPropSet)
{
	HRESULT hr = S_OK;

	// default actions
	if (mDefaultActions)
	{
		IMTConfigPropSetPtr propSet = aPropSet->InsertSet(DEFAULT_ACTIONS);
		hr = OutputActionSet(propSet, mDefaultActions);
		if (FAILED(hr))
			return hr;
	}

	// now each rule
	SetIterator<IMTCollection *, IMTRulePtr> it;
	hr = it.Init(*(&mRules));
	if (FAILED(hr))
		return hr;
	
	while (TRUE)
	{
		IMTRulePtr rule = it.GetNext();
		if (rule == NULL)
			break;

		IMTConfigPropSetPtr propSet = aPropSet->InsertSet(CONSTRAINT_SET);
		hr = OutputRule(propSet, rule);
		if (FAILED(hr))
			return hr;
	}

	return S_OK;
}

HRESULT CMTRuleSet::OutputActionSet(MTConfigLib::IMTConfigPropSetPtr aPropSet,
																		MTRULESETLib::IMTActionSetPtr aActionSet)
{
	// each action
	SetIterator<IMTActionSetPtr, IMTAssignmentActionPtr> it;
	HRESULT hr = it.Init(aActionSet);
	if (FAILED(hr))
		return hr;
	
	while (TRUE)
	{
		IMTAssignmentActionPtr rule = it.GetNext();
		if (rule == NULL)
			break;

		IMTConfigPropSetPtr propSet = aPropSet->InsertSet(ACTION);
		HRESULT hr = OutputAction(propSet, rule);
		if (FAILED(hr))
			return hr;
	}
	return S_OK;
}

HRESULT CMTRuleSet::OutputAction(MTConfigLib::IMTConfigPropSetPtr aPropSet,
																 MTRULESETLib::IMTAssignmentActionPtr aAction)
{
	_bstr_t name = aAction->GetPropertyName();
	aPropSet->InsertProp(PROP_NAME, MTConfigLib::PROP_TYPE_STRING, name);

	unsigned int length1 = aAction->GetEnumType().length();
	unsigned int length2 = aAction->GetEnumSpace().length();
	
	// if we don't have an enumtype if we have an enumspace or vise versa
	if ((length1 > 0 && length2 == 0) || (length2 > 0 && length1 == 0))
		return Error("Must specify both an enumspace AND a enum type");

	if (length1 > 0 && length2 > 0)
	{
		IMTConfigAttribSetPtr aAttribSet(MTPROGID_CONFIG_ATTRIB_SET);
		aAttribSet->Initialize();
		aAttribSet->AddPair(gpEnumSpaceTag, aAction->GetEnumSpace());
		aAttribSet->AddPair(gpEnumTypeTag, aAction->GetEnumType());

		IMTConfigPropPtr configProp(MTPROGID_PROPERTY);
		configProp->PutName(PROP_VALUE);
		configProp->AddProp((MTConfigLib::PropValType) aAction->GetPropertyType(),
												aAction->GetPropertyValue());
		configProp->PutAttribSet(aAttribSet);
		aPropSet->InsertConfigProp(configProp);
	}
	else
	{
		aPropSet->InsertProp(PROP_VALUE,
												 (MTConfigLib::PropValType) aAction->GetPropertyType(),
												 aAction->GetPropertyValue());
	}

	return S_OK;
}

HRESULT CMTRuleSet::OutputConditionSet(MTConfigLib::IMTConfigPropSetPtr aPropSet,
																			 MTRULESETLib::IMTConditionSetPtr aConditionSet)
{
	// each condition
	SetIterator<IMTConditionSetPtr, IMTSimpleConditionPtr> it;
	HRESULT hr = it.Init(aConditionSet);
	if (FAILED(hr))
		return hr;
	
	while (TRUE)
	{
		IMTSimpleConditionPtr condition = it.GetNext();
		if (condition == NULL)
			break;

		IMTConfigPropSetPtr propSet = aPropSet->InsertSet(CONSTRAINT);
		HRESULT hr = OutputCondition(propSet, condition);
		if (FAILED(hr))
			return hr;
	}

	return S_OK;
}

HRESULT CMTRuleSet::OutputCondition(MTConfigLib::IMTConfigPropSetPtr aPropSet,
																		MTRULESETLib::IMTSimpleConditionPtr aCondition)
{
	_variant_t var;

	_bstr_t name = aCondition->GetPropertyName();
	var = name;
	aPropSet->InsertProp(PROP_NAME, MTConfigLib::PROP_TYPE_STRING, var);

	_bstr_t condition = aCondition->GetTest();
	var = condition;
	aPropSet->InsertProp(CONDITION, MTConfigLib::PROP_TYPE_STRING, var);


	unsigned int length1 = aCondition->GetEnumType().length();
	unsigned int length2 = aCondition->GetEnumSpace().length();
	
	// if we don't have an enumtype if we have an enumspace or vise versa
	if ((length1 > 0 && length2 == 0) || (length2 > 0 && length1 == 0))
		return Error("Must specify both an enumspace AND a enum type");

	if (length1 > 0 && length2 > 0)
	{
		IMTConfigAttribSetPtr aAttribSet(MTPROGID_CONFIG_ATTRIB_SET);
		aAttribSet->Initialize();
		aAttribSet->AddPair(gpEnumSpaceTag, aCondition->GetEnumSpace());
		aAttribSet->AddPair(gpEnumTypeTag, aCondition->GetEnumType());

		IMTConfigPropPtr aConfigProp(MTPROGID_PROPERTY);
		aConfigProp->PutName(PROP_VALUE);
		aConfigProp->AddProp((MTConfigLib::PropValType) aCondition->GetValueType(),
												 aCondition->GetValue());
		aConfigProp->PutAttribSet(aAttribSet);
		aPropSet->InsertConfigProp(aConfigProp);
	}
	else
	{
		aPropSet->InsertProp(PROP_VALUE, (MTConfigLib::PropValType) aCondition->GetValueType(),
												 aCondition->GetValue());
	}

	return S_OK;
}


HRESULT CMTRuleSet::OutputRule(MTConfigLib::IMTConfigPropSetPtr aPropSet,
															 MTRULESETLib::IMTRulePtr aRule)
{
	// actions
	IMTConfigPropSetPtr propSet = aPropSet->InsertSet(ACTIONS);
	HRESULT hr = OutputActionSet(propSet, aRule->GetActions());
	if (FAILED(hr))
		return hr;

	// conditions
  // We allow a rule to be created that has no conditions.
	IMTConditionSetPtr conditions = aRule->GetConditions();
	if (conditions)
	{
		hr = OutputConditionSet(aPropSet, conditions);
		if (FAILED(hr))
			return hr;
	}

	return S_OK;
}



HRESULT CMTRuleSet::OutputRules(MTConfigLib::IMTConfigPropSetPtr aPropSet)
{
	time_t TempTime;
	TimetFromOleDate(&TempTime,mOleDate);

	RefreshArgumentMap();

  // COM 32BIT TIME_T
	HRESULT hr = OutputMTSysHeader(aPropSet, (long) TempTime, mTimeOut);
	if (FAILED(hr))
		return hr;

	IMTConfigPropSetPtr mtconfigdata = aPropSet->InsertSet(MTCONFIGDATA);

	long version = 1;
	_variant_t var;
	var = version;
	mtconfigdata->InsertProp(RULESET_VERSION, MTConfigLib::PROP_TYPE_INTEGER, var);

	IMTConfigPropSetPtr processor = mtconfigdata->InsertSet(RULESET_PROCESSOR);

	hr = OutputMTPlugInHeader(processor, mPluginName, MTPROGID_PROPGENPROC, mDescription);
	if (FAILED(hr))
		return hr;

	IMTConfigPropSetPtr configdata = processor->InsertSet(RULESET_CONFIGDATA);

	return OutputRuleSetData(configdata);
}


/********************************************* Input methods ***/

HRESULT CMTRuleSet::InputRuleSet(MTConfigLib::IMTConfigPropSetPtr aPropSet)
{
	/*
	<mtsysconfigdata>
		<effective_date ptype="DATETIME">1998-11-1T00:00:00Z</effective_date>
		<timeout ptype="INTEGER">30</timeout>
		<configfiletype>CONFIG_DATA</configfiletype>
	</mtsysconfigdata>

	<mtconfigdata>

		<version ptype="INTEGER">1</version>
		<!-- First processor configuration -->
		<processor>
			<name>Stage1</name>
			<progid>MTPipeline.PropGenProcessor.1</progid>

			<inputs>
				<input>
					<argument>duration</argument>
					<property>CallDuration</property>
				</input>
			</inputs>

			<outputs>
				<output>
					<argument>cost</argument>
					<property>CallCost</property>
				</output>
			</outputs>

			<!-- Processor specific configuration data -->
			<configdata>
				<default_actions> 
	*/
	
	if (aPropSet->NextMatches(RULESET_CONFIGDATA, MTConfigLib::PROP_TYPE_SET) == VARIANT_TRUE)
	{
		HRESULT hr = InputRulesOnly(aPropSet);
		if (FAILED(hr))
			return hr;
	}

	// <sysconfigdata> if optional
	if (aPropSet->NextMatches(SYSCONFIGDATA, MTConfigLib::PROP_TYPE_SET) == VARIANT_TRUE)
	{
		HRESULT hr = InputMTSysHeader(aPropSet);
		if (FAILED(hr))
			return hr;
	}

	if (aPropSet->NextMatches(MTCONFIGDATA, MTConfigLib::PROP_TYPE_SET) == VARIANT_TRUE)
	{
		MTConfigLib::IMTConfigPropSetPtr mainSet = aPropSet->NextSetWithName(MTCONFIGDATA);

		long version = mainSet->NextLongWithName("version");

		MTConfigLib::IMTConfigPropSetPtr subset = mainSet->NextSetWithName(RULESET_PROCESSOR);

		HRESULT hr = InputMTPlugInHeader(subset);
		if (FAILED(hr))
			return hr;

		MTConfigLib::IMTConfigPropSetPtr configdata = subset->NextSetWithName(RULESET_CONFIGDATA);

		hr = InputRuleSetData(configdata);
		if (FAILED(hr))
			return hr;
	}
#if 0
	else
	{
		mLogger->LogVarArgs(LOG_ERROR, "No %s data section found: %s", MTCONFIGDATA, PROCEDURE) ;
		return FALSE;
	}
#endif

	return S_OK;
}

HRESULT CMTRuleSet::InputRulesOnly(MTConfigLib::IMTConfigPropSetPtr aPropSet)
{
	MTConfigLib::IMTConfigPropSetPtr configdata = aPropSet->NextSetWithName(RULESET_CONFIGDATA);
	if (configdata == NULL)
		return Error("configdata section not found");

	return InputRuleSetData(configdata);
}


HRESULT CMTRuleSet::InputRuleSetData(MTConfigLib::IMTConfigPropSetPtr aPropSet)
{
	// clear default actions if there are any
	mDefaultActions = NULL;

	// clear all rules
	mRules.Clear();

	IMTConfigPropSetPtr	propSet;
	  if (aPropSet !=NULL)
	        {
	// 1. default actions
	if (aPropSet->NextMatches(DEFAULT_ACTIONS, MTConfigLib::PROP_TYPE_SET) == VARIANT_TRUE)
	{
		propSet = aPropSet->NextSetWithName(DEFAULT_ACTIONS);
		ASSERT(propSet != NULL);

		HRESULT hr = mDefaultActions.CreateInstance(MTPROGID_MTACTIONSET);
		if (FAILED(hr))
			return Error(L"Unable to create default action set", IID_IMTRuleSet, hr);

		hr = InputActionSet(propSet, mDefaultActions);
		if (FAILED(hr))
			return hr;
	}
	else
		mDefaultActions = NULL;

	propSet = aPropSet->NextSetWithName(CONSTRAINT_SET);
	while (propSet != NULL)
	{
		// read the rule
		IMTRulePtr rule(MTPROGID_MTRULE);
		HRESULT hr = InputRule(propSet, rule);
		if (FAILED(hr))
			return hr;

		// add it to the set
		hr = Add((IMTRule *) rule.GetInterfacePtr());
		if (FAILED(hr))
			return hr;

		// next rule
		propSet = aPropSet->NextSetWithName(CONSTRAINT_SET);
	}
}
	return TRUE;
}


HRESULT CMTRuleSet::InputMTSysHeader(MTConfigLib::IMTConfigPropSetPtr aPropSet)
{
	IMTConfigPropSetPtr	propSet = aPropSet->NextSetWithName(SYSCONFIGDATA);

	mOleDate = propSet->NextDateWithName(EFFECTIVEDATE);

	mTimeOut = propSet->NextLongWithName(TIMEOUT);
	
	// ignored
	_bstr_t fileType = propSet->NextStringWithName(CONFIGFILETYPE);
	
	return S_OK;
}


HRESULT CMTRuleSet::InputMTPlugInHeader(MTConfigLib::IMTConfigPropSetPtr aPropSet)
{
	mPluginName = (const char *) aPropSet->NextStringWithName(RULESET_NAME);
	mProgid = (const char *) aPropSet->NextStringWithName(RULESET_PROGID);

	if (aPropSet->NextMatches(RULESET_DESCRIPTION, MTConfigLib::PROP_TYPE_STRING) == VARIANT_TRUE)
		mDescription = (const char *) aPropSet->NextStringWithName(RULESET_DESCRIPTION);

#if 0
	// inputs
	if (aPropSet->NextMatches(RULESET_INPUTS, PROP_TYPE_SET) == VARIANT_TRUE)
	{
		MTConfigLib::IMTConfigPropSetPtr inputs = aPropSet->NextSetWithName(RULESET_INPUTS);
		MTConfigLib::IMTConfigPropPtr input;

		MTConfigLib::PropValType nameType;
		_bstr_t propertyName;
		while ((input = inputs->NextWithName(RULESET_INPUT)) != NULL)
		{
			ArgumentMap map;

			IMTConfigAttribSetPtr aAttribSet = input->GetAttribSet();
				
			BSTR aPropType;
			if(SUCCEEDED(aAttribSet->get_AttrValue(gpPropertyTypeTag, &aPropType)))
			{
				_bstr_t aTemp(aPropType,false);
				map.SetPropertyType(aTemp);
					
				// if this is a enum type, we have to get enumspace
				std::string rwcstr = (char*)aTemp;
				if (_stricmp(rwcstr.c_str(), gpEnum) == 0)
				{
					BSTR aEnumType;
					if(SUCCEEDED(aAttribSet->get_AttrValue(gpEnumTypeTag, &aEnumType)))
					{
						_bstr_t aTemp(aEnumType,false);
						map.SetEnumType(aTemp);
					}

					BSTR aEnumSpace;
					if(SUCCEEDED(aAttribSet->get_AttrValue(gpEnumSpaceTag, &aEnumSpace)))
					{
						_bstr_t aTemp(aEnumSpace,false);
						map.SetEnumSpace(aTemp);
					}
				}
			}

			propertyName = input->GetValue(&nameType);
			if (propertyName.length() != 0)
				map.SetPropertyName(propertyName);

			mInputArgList.append(map);

		}

	}

	// outputs
	if (aPropSet->NextMatches(RULESET_OUTPUTS, PROP_TYPE_SET) == VARIANT_TRUE)
	{
		MTConfigLib::IMTConfigPropSetPtr outputs = aPropSet->NextSetWithName(RULESET_OUTPUTS);
		MTConfigLib::IMTConfigPropPtr output;

		MTConfigLib::PropValType nameType;
		_bstr_t propertyName;
		while ((output = outputs->NextWithName(RULESET_OUTPUT)) != NULL)
		{
			ArgumentMap map;

			IMTConfigAttribSetPtr aAttribSet = output->GetAttribSet();
				
			BSTR aPropType;
			if(SUCCEEDED(aAttribSet->get_AttrValue(gpPropertyTypeTag, &aPropType)))
			{
				_bstr_t aTemp(aPropType,false);
				map.SetPropertyType(aTemp);

				// if this is a enum type, we have to get enumspace
				std::string rwcstr = (char*)aTemp;
				if (_stricmp(rwcstr.c_str(), gpEnum) == 0)
				{
					BSTR aEnumType;
					if(SUCCEEDED(aAttribSet->get_AttrValue(gpEnumTypeTag, &aEnumType)))
					{
						_bstr_t aTemp(aEnumType,false);
						map.SetEnumType(aTemp);
					}

					BSTR aEnumSpace;
					if(SUCCEEDED(aAttribSet->get_AttrValue(gpEnumSpaceTag, &aEnumSpace)))
					{
						_bstr_t aTemp(aEnumSpace,false);
						map.SetEnumSpace(aTemp);
					}
				}
			}

			propertyName = output->GetValue(&nameType);
			if (propertyName.length() != 0)
				map.SetPropertyName(propertyName);

			mOutputArgList.append(map);
		}
	}
#endif

	return S_OK;
}


HRESULT CMTRuleSet::InputRule(MTConfigLib::IMTConfigPropSetPtr aPropSet,
															IMTRulePtr aRule)
{
	// TODO: clear the rule or can we assume it's clear already?
	
	// 1. ACTIONS
	// NOTE: the <actions> tag is optional
	IMTConfigPropSetPtr	propSet;
	if (aPropSet->NextMatches(ACTIONS, MTConfigLib::PROP_TYPE_SET) == VARIANT_TRUE)
		propSet = aPropSet->NextSetWithName(ACTIONS);
	else
		propSet = aPropSet;

	if (propSet == NULL)
		return Error("Unable to read actions section");

	IMTActionSetPtr actionSet(MTPROGID_MTACTIONSET);
	aRule->PutActions(actionSet);

	HRESULT hr = InputActionSet(propSet, actionSet);
	if (FAILED(hr))
		return hr;

	// 2. CONDITIONS
	IMTConditionSetPtr conditionSet(MTPROGID_CONDITIONSET);
	aRule->PutConditions(conditionSet);

	// ???
	if (aPropSet == propSet)
		aPropSet->Reset();

	hr = InputConditionSet(aPropSet, conditionSet);
	if (FAILED(hr))
		return hr;

	return S_OK;
}



HRESULT CMTRuleSet::InputActionSet(MTConfigLib::IMTConfigPropSetPtr aPropSet,
																	 IMTActionSetPtr aActionSet)
{
	// loop through each action
	IMTConfigPropSetPtr	propSet = aPropSet->NextSetWithName(ACTION);
	while (propSet != NULL)
	{
		IMTAssignmentActionPtr action(MTPROGID_ASSIGNACTION);

		HRESULT hr = InputAction(propSet, action);
		if (FAILED(hr))
			return hr;

		aActionSet->Add(action);

		propSet = aPropSet->NextSetWithName(ACTION);
	}

	return TRUE;
}


HRESULT CMTRuleSet::InputConditionSet(MTConfigLib::IMTConfigPropSetPtr aPropSet,
																			IMTConditionSetPtr aConditionSet)
{
	// loop through each action
	IMTConfigPropSetPtr	propSet = aPropSet->NextSetWithName(CONSTRAINT);
	while (propSet != NULL)
	{
		IMTSimpleConditionPtr condition(MTPROGID_SIMPLECOND);

		HRESULT hr = InputCondition(propSet, condition);
		if (FAILED(hr))
			return hr;

		aConditionSet->Add(condition);

		propSet = aPropSet->NextSetWithName(CONSTRAINT);
	}

	return S_OK;
}


HRESULT CMTRuleSet::InputCondition(MTConfigLib::IMTConfigPropSetPtr aPropSet,
																	 IMTSimpleConditionPtr aCondition)
{
	aCondition->PutPropertyName(aPropSet->NextStringWithName(PROP_NAME));

	aCondition->PutTest(aPropSet->NextStringWithName(CONDITION));

	IMTConfigPropPtr nextPropValue = aPropSet->NextWithName(PROP_VALUE);
	MTConfigLib::PropValType type = nextPropValue->GetPropType();
	aCondition->PutValueType((MTRULESETLib::PropValType) type);

	if (type == MTConfigLib::PROP_TYPE_ENUM)
	{
		// get the enumspace information if it exists
		IMTConfigAttribSetPtr aAttribSet = nextPropValue->GetAttribSet();
		bool bGotEnumSpace = false,bGotEnumType= false;

		if (aAttribSet)
		{
			BSTR aEnumType, aEnumSpace;
			if(SUCCEEDED(aAttribSet->get_AttrValue(const_cast<wchar_t*>(gpEnumSpaceTag),&aEnumSpace))) {
				bGotEnumSpace = true;
				_bstr_t aTemp(aEnumSpace,false);
				aCondition->PutEnumSpace(aTemp);
			}
			if(SUCCEEDED(aAttribSet->get_AttrValue(const_cast<wchar_t*>(gpEnumTypeTag),&aEnumType))) {
				bGotEnumType = true;
				_bstr_t aTemp(aEnumType,false);
				aCondition->PutEnumType(aTemp);
			}
		}

		// check if we only have one property... This is an error condition
		if(bGotEnumSpace != bGotEnumType)
		{
			if(!bGotEnumSpace)
				return Error("enumtype value found without enumspace");
			else
				return Error("enumspace value found without enumtype");
		}

		_bstr_t val = nextPropValue->GetValueAsString();
		aCondition->PutValue(val);
	}
	else
		aCondition->PutValue(nextPropValue->GetPropValue());

	return S_OK;
}



HRESULT CMTRuleSet::InputAction(MTConfigLib::IMTConfigPropSetPtr aPropSet,
																IMTAssignmentActionPtr aAction)
{
	aAction->PutPropertyName(aPropSet->NextStringWithName(PROP_NAME));

	IMTConfigPropPtr nextPropValue = aPropSet->NextWithName(PROP_VALUE);

	MTConfigLib::PropValType type = nextPropValue->GetPropType();
	aAction->PutPropertyType((MTRULESETLib::PropValType) type);

	if (type == MTConfigLib::PROP_TYPE_ENUM)
	{
		IMTConfigAttribSetPtr aAttribSet = nextPropValue->GetAttribSet();
		bool bGotEnumSpace = false,bGotEnumType= false;
		BSTR aEnumType, aEnumSpace;

		if(SUCCEEDED(aAttribSet->get_AttrValue(gpEnumTypeTag,&aEnumType)))
		{
			bGotEnumType = true;
			_bstr_t aTemp(aEnumType,false);
			aAction->PutEnumType(aTemp);
		}
		if(SUCCEEDED(aAttribSet->get_AttrValue(gpEnumSpaceTag,&aEnumSpace))) {
			bGotEnumSpace = true;
			_bstr_t aTemp(aEnumSpace,false);
			aAction->PutEnumSpace(aTemp);
		}

		if (bGotEnumSpace != bGotEnumType) {
			if(!bGotEnumSpace) {
				return Error("enumtype value found without enumspace");
			}
			else {
				return Error("enumspace value found without enumtype");
			}
		}
		aAction->PutPropertyValue(nextPropValue->GetValueAsString());
	}
	else {
		aAction->PutPropertyValue(nextPropValue->GetPropValue());
	}

	return TRUE;
}

/************************************** Argument map methods ***/

void GetPropTypeString(MTConfigLib::PropValType	propType, 
											 _bstr_t& propTypeString)
{
	switch(propType)
	{
		case PROP_TYPE_DEFAULT:
		case PROP_TYPE_STRING:
			propTypeString = "STRING";
			break;

		case PROP_TYPE_INTEGER:
			propTypeString = "LONG";
			break;

		case PROP_TYPE_BIGINTEGER:
			propTypeString = "LONGLONG";
			break;

		case PROP_TYPE_DOUBLE:
			propTypeString = "DOUBLE";
			break;

		case PROP_TYPE_DATETIME:
			propTypeString = "DATETIME";
			break;

		case PROP_TYPE_TIME:
			propTypeString = "TIME";
			break;

		case PROP_TYPE_BOOLEAN:
			propTypeString = "BOOLEAN";
			break;

		case PROP_TYPE_OPAQUE:
			propTypeString = "OPAQUE";
			break;

		case PROP_TYPE_ENUM:
			propTypeString = "ENUM";
			break;

		case PROP_TYPE_DECIMAL:
			propTypeString = "DECIMAL";
			break;


		case PROP_TYPE_UNKNOWN:
		default:
			propTypeString = "UNKNOWN";
			break;
	}
}

// TODO: fix this - linear scan
BOOL PropertyNotFound(std::vector<ArgumentMap>& aArgList,
											_bstr_t& aPropertyName)
{
	int entries = aArgList.size();
	
	ArgumentMap map;
	_bstr_t propertyNameInMap;

	for (int i = 0; i < entries; i++)
	{
		map = aArgList[i];

		propertyNameInMap = map.GetPropertyName();
		if (propertyNameInMap == aPropertyName)
		{
			return FALSE;
		}
	}

	return TRUE;
}

HRESULT CMTRuleSet::RefreshInputList(MTRULESETLib::IMTConditionSetPtr aConditionSet)
{
	_bstr_t propName;
	MTConfigLib::PropValType	propType;
	_bstr_t propTypeString;
	_bstr_t propEnumType;
	_bstr_t propEnumSpace;

	// each condition
	SetIterator<IMTConditionSetPtr, IMTSimpleConditionPtr> it;
	HRESULT hr = it.Init(aConditionSet);
	if (FAILED(hr))
		return hr;
	
	while (TRUE)
	{
		IMTSimpleConditionPtr condition = it.GetNext();
		if (condition == NULL)
			break;

		propName = condition->GetPropertyName();
		propType = (MTConfigLib::PropValType) condition->GetValueType();
		GetPropTypeString(propType, propTypeString);

		propEnumType = condition->GetEnumType();
		
		propEnumSpace = condition->GetEnumSpace();

		ArgumentMap map(propName, propTypeString, propEnumType, propEnumSpace);

		if (PropertyNotFound(mInputArgList, propName))
			mInputArgList.push_back(map);
	}

	return S_OK;
}


HRESULT CMTRuleSet::RefreshOutputList(MTRULESETLib::IMTActionSetPtr aActionSet)
{

	_bstr_t propName;
	MTConfigLib::PropValType	propType;
	_bstr_t propTypeString;
	_bstr_t propEnumType;
	_bstr_t propEnumSpace;

	// each action
	SetIterator<IMTActionSetPtr, IMTAssignmentActionPtr> it;
	HRESULT hr = it.Init(aActionSet);
	if (FAILED(hr))
		return hr;
	
	while (TRUE)
	{
		IMTAssignmentActionPtr apAction = it.GetNext();
		if (apAction == NULL)
			break;

		propName = apAction->GetPropertyName();

		propType = (MTConfigLib::PropValType) apAction->GetPropertyType();
		
		GetPropTypeString(propType, propTypeString);

		propEnumType = apAction->GetEnumType();
		
		propEnumSpace = apAction->GetEnumSpace();

		ArgumentMap map(propName, propTypeString, propEnumType, propEnumSpace);

		if (PropertyNotFound(mOutputArgList, propName))
			mOutputArgList.push_back(map);
	}

	return TRUE;
}


HRESULT CMTRuleSet::RefreshArgumentMap()
{
	mInputArgList.clear();
	mOutputArgList.clear();

	HRESULT hr;
	if (mDefaultActions)
	{
		hr = RefreshOutputList(mDefaultActions);
		if (FAILED(hr))
			return hr;
	}

	SetIterator<IMTCollection *, IMTRulePtr> it;
	hr = it.Init(*(&mRules));
	if (FAILED(hr))
		return hr;
	
	while (TRUE)
	{
		IMTRulePtr rule = it.GetNext();
		if (rule == NULL)
			break;

		hr = RefreshInputList(rule->GetConditions());
		if (FAILED(hr))
			return hr;

		hr = RefreshOutputList(rule->GetActions());
		if (FAILED(hr))
			return hr;
	}

	return S_OK;
}

// ----------------------------------------------------------------
// Description:  Actions that are applied if no rules match
// Return Value: Actions that are applied if no rules match
// ----------------------------------------------------------------
STDMETHODIMP CMTRuleSet::get_DefaultActions(IMTActionSet * * pVal)
{
	if (mDefaultActions == NULL)
	{
		*pVal = NULL;
		return S_OK;
	}

	*pVal = (IMTActionSet *) mDefaultActions.GetInterfacePtr();
	// TODO: this might leak..
	(*pVal)->AddRef();
	return S_OK;
}

// ----------------------------------------------------------------
// Description:  Actions that are applied if no rules match
// Argument:  actions - Actions that are applied if no rules match
// ----------------------------------------------------------------
STDMETHODIMP CMTRuleSet::put_DefaultActions(IMTActionSet * newVal)
{
	mDefaultActions = newVal;
	return S_OK;
}


// ----------------------------------------------------------------
// Description:  Automation method, used for enumerating rules within this ruleset
// ----------------------------------------------------------------
STDMETHODIMP CMTRuleSet::get__NewEnum(/*[out, retval]*/ LPUNKNOWN *pVal)
{
	GENERICCOLLECTIONLib::IMTCollection * set = NULL;
	HRESULT hr = mRules.CopyTo((::IMTCollection **) &set);
	if (FAILED(hr))
		return hr;

	hr = set->get__NewEnum(pVal);
	set->Release();
	return hr;
}

// ----------------------------------------------------------------
// Description:  Return the given rule.  the index is 1-based.
// Argument:  index - 1-based index.  1 returns the first rule in the set
// Return Value: n-th rule in the set
// ----------------------------------------------------------------
STDMETHODIMP CMTRuleSet::get_Item(/*[in]*/ long index, /*[out,retval]*/ LPVARIANT pItem)
{
	IMTRule * rule = NULL;
	HRESULT hr = mRules.Item(index, &rule);

	// TODO: this should be false?
	_variant_t var(rule, true);
	*pItem = var;
	return hr;
}

// ----------------------------------------------------------------
// Description: Add a rule to the rule set.
// Argument:  rule - rule to add to the set
// ----------------------------------------------------------------
STDMETHODIMP CMTRuleSet::Add(/*[in]*/ IMTRule * pMyObj )
{
	return mRules.Add(pMyObj);
}

// ----------------------------------------------------------------
// Description: Insert a rule into the rule set at the given index.
//              The index is 1-based.
// Argument:  rule - rule to add to the set
//            index - new index of the rule added to the set
// ----------------------------------------------------------------
STDMETHODIMP CMTRuleSet::Insert(/*[in]*/ IMTRule * pMyObj, int aIndex )
{
	return mRules.Insert(pMyObj, aIndex);
}

// ----------------------------------------------------------------
// Description: Remove the rule at the given index.  The index is
//              1-based.
// Argument:    index - index of the rule to remove
// ----------------------------------------------------------------
STDMETHODIMP CMTRuleSet::Remove(int aIndex )
{
	return mRules.Remove(aIndex);
}


// ----------------------------------------------------------------
// Description: The number of rules within this rule set
// Return value: number of rules in the set
// ----------------------------------------------------------------
STDMETHODIMP CMTRuleSet::get_Count(/*[out, retval]*/ long *pVal )
{
	if (!pVal)
		return E_POINTER;

	return mRules.Count(pVal);
}

// ----------------------------------------------------------------
// Description: The name of the plug-in executing the rules.
//              Used when generating a plug-in configuration file.
// Return value: The name of the plug-in executing the rules.
// ----------------------------------------------------------------
STDMETHODIMP CMTRuleSet::get_PluginName(BSTR * pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = mPluginName.copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Description: The name of the plug-in executing the rules.
//              Used when generating a plug-in configuration file.
// Argument: name - The name of the plug-in executing the rules.
// ----------------------------------------------------------------
STDMETHODIMP CMTRuleSet::put_PluginName(BSTR newVal)
{
  mPluginName = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Description: The effective date of the plugin configuration file.
//              (The date when the ruleset can be used for rating)
// Return value: the effective date
// ----------------------------------------------------------------
STDMETHODIMP CMTRuleSet::get_EffectiveDate(VARIANT *pVal)
{
	if(!pVal) return E_POINTER;
	_variant_t aVariant(mOleDate,VT_DATE);
	::VariantClear(pVal);
	::VariantCopy(pVal,&aVariant);
	return S_OK;
}

// ----------------------------------------------------------------
// Description: The effective date of the plugin configuration file.
//              (The date when the ruleset can be used for rating)
// Argument:    date - the effective date
// ----------------------------------------------------------------
STDMETHODIMP CMTRuleSet::put_EffectiveDate(VARIANT newVal)
{
	mOleDate = _variant_t(newVal);
	return S_OK;
}

// ----------------------------------------------------------------
// Description: The number of days that the plug-in configuration file
//              is still available after it is no longer effective
// Return value: timeout in days
// ----------------------------------------------------------------
STDMETHODIMP CMTRuleSet::get_Timeout(long *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;
	*pVal = mTimeOut;
	return S_OK;
}

// ----------------------------------------------------------------
// Description: The number of days that the plug-in configuration file
//              is still available after it is no longer effective
// Argument: days - timeout in days
// ----------------------------------------------------------------
STDMETHODIMP CMTRuleSet::put_Timeout(long newVal)
{
	if(newVal < 0) {
		return Error("Timeout must be greater than 0");
	}
	mTimeOut = newVal;
	return S_OK;
}
