/**************************************************************************
 * @doc PropGenerator
 *
 * Copyright 1997-2000 by MetraTech Corporation
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
 *
 * Created by: Chen He
 *
 * $Header$
 ***************************************************************************/
// PropGenerator.cpp: implementation of the PropGenerator class.
//
//////////////////////////////////////////////////////////////////////
#include "StdAfx.h"
#include <iostream>
#include "autoptr.h"
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#include "SessServer.h"
#include <MTSessionDef.h>
#include <MTSessionBaseDef.h>
#include "PropGenerator.h"
#include <SetIterate.h>

#import <MTEnumConfigLib.tlb>
#include <mtprogids.h>
#include <mtcomerr.h>

#include <mtglobal_msg.h>
#include <stdutils.h>

using std::cout;
using std::endl;

using namespace MTPipelineLib;
using namespace std;

//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

// --------------------------------------------------------------------------
// Arguments:			None
//
// Return Value:	None
// Errors Raised: None
// Description:		Construction - allocate memory for tables
// --------------------------------------------------------------------------
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "PropGenerator()"
PropGenerator::PropGenerator() : mPCIDCount(0), 
                                 mPCSetID(0),
                                 mConditionTripletLibrary(NULL),
                                 mDerivedPropInfoLibrary(NULL)

{
  ErrorObject localError;
	mConditionTripletLibrary = ConditionTripletLibrary::GetInstance();
  mDerivedPropInfoLibrary = DerivedPropInfoLibrary::GetInstance();
  mRTConditions = new map<const ConditionTriplet*, RTCondition*>;

	mDefDerivedPropInfoList = NULL;

	mIMTLogPtr = NULL;

	mDerivedPropInfoListTbl = new DerivedPropInfoListColl;
	if (mDerivedPropInfoListTbl == NULL)
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);
		localError = *GetLastError();
		localError.GetProgrammerDetail() = "Can not allocate the DerivedPropInfoListTbl Table";

		throw localError;
	}
}


// --------------------------------------------------------------------------
// Arguments:			<aPropNameID> - property name id
//
// Return Value:	None
// Errors Raised: None
// Description:		Construction - allocate memory for tables
// --------------------------------------------------------------------------
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "PropGenerator()"
PropGenerator::PropGenerator(const long& aPropNameID) : mPCIDCount(0), 
                                                        mPCSetID(0),
                                                        mConditionTripletLibrary(NULL),
                                                        mDerivedPropInfoLibrary(NULL)
{
	ErrorObject localError;
	mConditionTripletLibrary = ConditionTripletLibrary::GetInstance();
  mDerivedPropInfoLibrary = DerivedPropInfoLibrary::GetInstance();
  mRTConditions = new map<const ConditionTriplet*, RTCondition*>;

	mDefDerivedPropInfoList = NULL;

	mIMTLogPtr = NULL;

	mDerivedPropInfoListTbl = new DerivedPropInfoListColl;
	if (mDerivedPropInfoListTbl == NULL)
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);
		localError = *GetLastError();
		localError.GetProgrammerDetail() = "Can not allocate the DerivedPropInfoListTbl Table";

		throw localError;
	}
}


// --------------------------------------------------------------------------
// Arguments:			<> - property name id
//
// Return Value:	None
// Errors Raised: None
// Description:		Desstruction - release allocated memory for tables
// --------------------------------------------------------------------------
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "~PropGenerator()"
PropGenerator::~PropGenerator(void)
{
  while(mRTRules.size() > 0)
	{
		delete mRTRules.back();
		mRTRules.pop_back();
	}
  if (mRTConditions)
	{
    for(
      map<const ConditionTriplet*, RTCondition*>::iterator it = mRTConditions->begin(); 
      it != mRTConditions->end(); 
      it++)
    {
      RTCondition* ptr = (*it).second;
      delete ptr;
    }
    
    mRTConditions->clear();
  	delete mRTConditions;
	}
	
  if (mDefDerivedPropInfoList)
	{
    mDefDerivedPropInfoList->clear();
		delete mDefDerivedPropInfoList;
	}

	if (mDerivedPropInfoListTbl->size() > 0)
	{
		DerivedPropInfoListColl::iterator it;
    for (it = mDerivedPropInfoListTbl->begin();
      it != mDerivedPropInfoListTbl->end();
      ++it)
    {
      DerivedPropInfoList	* pDerivedPropInfoList = &it->second;
      ListCleanup(pDerivedPropInfoList);
    }

		mDerivedPropInfoListTbl->clear();
	}

	if (mDerivedPropInfoListTbl)
		delete mDerivedPropInfoListTbl;
	
	if(mConditionTripletLibrary)
    mConditionTripletLibrary->ReleaseInstance();

  if(mDerivedPropInfoLibrary)
    mDerivedPropInfoLibrary->ReleaseInstance();
}



// --------------------------------------------------------------------------
// Arguments:			<apDerivedPropInfoList> - derived property info list
//								<apDerivedPropSet> -  propset pointer point to derived 
//																			property subset
//								<aIdlookup> -  idlookup pointer
//
// Return Value:	SUCCESS when method call is success 
//								FAILURE	when method call fail
// Errors Raised: None
// Description:		Load derived property to derived property info list
// --------------------------------------------------------------------------
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "LoadDerivedPropSet()"
int PropGenerator::LoadDerivedPropSet(DerivedPropInfoList*	apDerivedPropInfoList, 
																			 IMTConfigPropSetPtr	apDerivedPropSet,
																			 IMTNameIDPtr aIdlookup)
{
	IMTConfigPropSetPtr		propSet;
	char*									str;
	long									derivedPropNameID;
	MTPipelineLib::PropValType propType;
	_variant_t						propValue;
	ErrorObject						localError;
	char									logStr[MAX_LOG_STRING];


	try
	{
    while(apDerivedPropSet->NextMatches(ACTION, MTPipelineLib::PROP_TYPE_SET))
		{
			propSet = apDerivedPropSet->NextSetWithName(ACTION);

			_bstr_t derivedPropName = propSet->NextStringWithName(PROP_NAME);
			str = derivedPropName;
			if (str == NULL)
			{
				// error: prop_name is missing
				SetError(PIPE_ERR_MISSING_PROP_NAME, ERROR_MODULE, ERROR_LINE, PROCEDURE);

				// log error msg
				return FAILURE;
			}
			derivedPropNameID = aIdlookup->GetNameID(derivedPropName);

			// if the action is a valuable assignment
			if (propSet->NextMatches(PROP_SOURCE_NAME, MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
			{
				_bstr_t sourcePropertyName = propSet->NextStringWithName(PROP_SOURCE_NAME);
				_bstr_t SourcePropType = propSet->NextStringWithName(PROP_SOURCE_TYPE);

				long sourcePropNameID = aIdlookup->GetNameID(sourcePropertyName);
	
				// create a new object to save the name, value pair
				SetDerivedPropValue(apDerivedPropInfoList, 
														derivedPropNameID, 
														sourcePropertyName,
														sourcePropNameID,
														SourcePropType);
				
			}
			else // value assignment
			{
				// Get default value
				IMTConfigPropPtr	prop = propSet->NextWithName(PROP_VALUE);
				if (prop == NULL)
				{
					// error: prop_value is missing
					SetError(PIPE_ERR_MISSING_PROP_VALUE, ERROR_MODULE, ERROR_LINE, PROCEDURE);

					// log error msg

					return FAILURE;
				}
				propValue = prop->GetValue(&propType);

				// create a new object to save the name, value pair
				SetDerivedPropValue(apDerivedPropInfoList, 
														derivedPropNameID, 
														propType, 
														propValue);
			}
		}
	
		return SUCCESS;
	}
	catch(_com_error err)
	{
		_bstr_t errorMsg(err.ErrorMessage());
		
		sprintf(logStr, "Error in getting action name/value pair.  Error Code: %X", err.Error());

		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);
		localError.Init(err.Error(), ERROR_MODULE, ERROR_LINE, PROCEDURE);
		localError = *GetLastError();
		localError.GetProgrammerDetail() = logStr;
		throw localError;
	}

}


// --------------------------------------------------------------------------
// Arguments:			<apDerivedPropInfoList> - derived property info list
//								<aIdlookup> -  idlookup pointer
//
// Return Value:	SUCCESS when method call is success 
//								FAILURE	when method call fail
// Errors Raised: None
// Description:		Load derived property to derived property info list
// --------------------------------------------------------------------------
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "LoadDerivedPropSet()"
int PropGenerator::LoadDerivedPropSet(DerivedPropInfoList*	apDerivedPropInfoList, 
																			 IMTActionSetPtr aActions,
																			 IMTNameIDPtr aIdlookup)
{
	try
	{
		SetIterator<IMTActionSetPtr, IMTAssignmentActionPtr> it;
		HRESULT hr = it.Init(aActions);
		if (FAILED(hr))
		{
			// TODO:
			ASSERT(0);
		}
	
		while (TRUE)
		{
			IMTAssignmentActionPtr action = it.GetNext();
			if (action == NULL)
				break;

			_bstr_t name = action->GetPropertyName();
			long derivedPropNameID = aIdlookup->GetNameID(name);

			MTPipelineLib::PropValType propType = action->GetPropertyType();
			_variant_t propValue = action->GetPropertyValue();

			//convert to ENUM id
			if (propType == MTPipelineLib::PROP_TYPE_ENUM)
			{	
				_bstr_t enumSpace = action->GetEnumSpace();
				if (enumSpace.length() > 0)
				{
					// TODO: create in advance?
					MTENUMCONFIGLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);
					long id = enumConfig->GetID(enumSpace, action->GetEnumType(),
																			_bstr_t(propValue));			
					// use the ID as the value, not the string
					propValue = id;
				}
				else
				{
					// no enumspace/enum name.  xmlconfig would convert this to a name ID
					// so we will to.
					// TODO: is this case ever used?
					ASSERT(0);
				}
			}

			// create a new object to save the name, value pair
			SetDerivedPropValue(apDerivedPropInfoList, 
													derivedPropNameID, 
													(MTPipelineLib::PropValType) propType, 
													propValue);
		}

		return SUCCESS;
	}
	catch(_com_error err)
	{
		_bstr_t errorMsg(err.ErrorMessage());
		
		char									logStr[MAX_LOG_STRING];
		sprintf(logStr, "Error in getting action name/value pair.  Error Code: %X", err.Error());

		ErrorObject						localError;
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);
		localError.Init(err.Error(), ERROR_MODULE, ERROR_LINE, PROCEDURE);
		localError = *GetLastError();
		localError.GetProgrammerDetail() = logStr;
		throw localError;
	}
}

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "LoadDerivedPropSet()"
int PropGenerator::LoadDerivedPropSet(DerivedPropInfoList*	apDerivedPropInfoList, 
																			 const vector<const DerivedPropInfo*>* aActions,
																			 IMTNameIDPtr aIdlookup)
{
	try
	{
    for(vector<const DerivedPropInfo*>::const_iterator it = aActions->begin(); it != aActions->end(); it++)
    {
      const DerivedPropInfo* action = *it;
      apDerivedPropInfoList->push_back(action);
    }
		return SUCCESS;
	}
	catch(_com_error err)
	{
		_bstr_t errorMsg(err.ErrorMessage());
		
		char									logStr[MAX_LOG_STRING];
		sprintf(logStr, "Error in getting action name/value pair.  Error Code: %X", err.Error());

		ErrorObject						localError;
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);
		localError.Init(err.Error(), ERROR_MODULE, ERROR_LINE, PROCEDURE);
		localError = *GetLastError();
		localError.GetProgrammerDetail() = logStr;
		throw localError;
	}
}



// --------------------------------------------------------------------------
// Arguments:			<apDerivedPropInfoList> - derived property info list
//
// Return Value:	none
// Errors Raised: None
// Description:		Clean up derived property info list
// --------------------------------------------------------------------------
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "ListCleanup()"
void PropGenerator::ListCleanup(DerivedPropInfoList*	apDerivedPropInfoList)
{
	if (apDerivedPropInfoList != NULL)
	{
		apDerivedPropInfoList->clear();
	}
}


// --------------------------------------------------------------------------
// Arguments:			<apDerivedPropInfoList> - derived property info list
//								<aNameID> - property name id
//								<aPropType> - property value type
//								<aPropValue> - property value
//
// Return Value:	none
// Errors Raised: None
// Description:		create a new derived property info object and add into 
//								derived property info list
// --------------------------------------------------------------------------
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "SetDerivedPropValue()"
void PropGenerator::SetDerivedPropValue(DerivedPropInfoList*	apDerivedPropInfoList,
																				const long& aNameID, 
																				const MTPipelineLib::PropValType& aPropType,
																				const _variant_t& aPropValue)
{
	// add the object to the list
	apDerivedPropInfoList->push_back(mDerivedPropInfoLibrary->Add(aNameID, aPropType, aPropValue));
}


// --------------------------------------------------------------------------
// Arguments:			<apDerivedPropInfoList> - derived property info list
//								<aNameID> - property name id
//								<aSourcePropertyName> - source property name
//								<aSourceNameID> - source property name id
//								<aPropType> - property value type
//
// Return Value:	none
// Errors Raised: None
// Description:		create a new derived property info object and add into 
//								derived property info list
// --------------------------------------------------------------------------
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "SetDerivedPropValue()"
void PropGenerator::SetDerivedPropValue(DerivedPropInfoList*	apDerivedPropInfoList,
													const long& aNameID,
													const _bstr_t aSourcePropertyName, 
													const long& aSourceNameID,
													const _bstr_t aSourcePropType)
{
  ErrorObject			localError;
	SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);
  localError = *GetLastError();
  localError.GetProgrammerDetail() = "Unsupported configuration: use MTSQL plugin instead.";
	throw localError;
}


// --------------------------------------------------------------------------
// Arguments:			<condition> - property constraint condition
//
// Return Value:	PropConstInfo enum value
// Errors Raised: None
// Description:		convert condition string value to PropConstInfo enum value
// --------------------------------------------------------------------------
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "GetNativeCondition()"
PropGenEnums::ConditionType PropGenerator::GetNativeCondition(_bstr_t& aCondition)
{
	string XML_EQUAL("equal");
	string XML_EQUALS("equals");
	string XML_EQUALSG1("=");
	string XML_EQUALSG2("==");

	string XML_LESS_THAN("less_than");
	string XML_LESS_THANSG("<");

	string XML_GREAT_THAN("great_than");
	string XML_GREATER_THAN("greater_than");
	string XML_GREAT_THANSG(">");

	string XML_LESS_EQUAL("less_equal");
	string XML_LESS_EQUALSG("<=");

	string	XML_GREAT_EQUAL("great_equal");
	string	XML_GREATER_EQUAL("greater_equal");
	string	XML_GREAT_EQUALSG(">=");

	string	XML_NOT_EQUAL("not_equal");
	string	XML_NOT_EQUALS("not_equals");
	string	XML_NOT_EQUALSG("!=");

	PropGenEnums::ConditionType cond;

  string condition = aCondition;

	if (strcasecmp(XML_EQUAL, condition) == 0 ||
			strcasecmp(XML_EQUALS, condition) == 0 ||
      strcasecmp(XML_EQUALSG1, condition) == 0 ||
      strcasecmp(XML_EQUALSG2, condition) == 0
			)
	{
		cond = PropGenEnums::EQUAL;
	}
	else if ( strcasecmp(XML_LESS_THAN, condition) == 0 ||
            strcasecmp(XML_LESS_THANSG, condition) == 0)
	{
		cond = PropGenEnums::LESS_THAN;
	}
	else if ( strcasecmp(XML_GREAT_THAN, condition) == 0 ||
            strcasecmp(XML_GREATER_THAN, condition) == 0 ||
            strcasecmp(XML_GREAT_THANSG, condition) == 0)
					
	{
		cond = PropGenEnums::GREAT_THAN;
	}
	else if ( strcasecmp(XML_LESS_EQUAL, condition) == 0 ||
            strcasecmp(XML_LESS_EQUALSG, condition) == 0)
            
	{
		cond = PropGenEnums::LESS_EQUAL;
	}
	else if ( strcasecmp(XML_GREAT_EQUAL, condition) == 0 ||
            strcasecmp(XML_GREATER_EQUAL, condition) == 0 ||
            strcasecmp(XML_GREAT_EQUALSG, condition) == 0)
	{
		cond = PropGenEnums::GREAT_EQUAL;
	}
	else if ( strcasecmp(XML_NOT_EQUAL, condition) == 0 ||
            strcasecmp(XML_NOT_EQUALS, condition) == 0 ||
            strcasecmp(XML_NOT_EQUALSG, condition) == 0)
	{
		cond = PropGenEnums::NOT_EQUAL;
	}
	else
	{
		cond = PropGenEnums::UNKNOWN_CONDITION_TYPE;
		ASSERT(0);
	}

	return cond;
}


// --------------------------------------------------------------------------
// Arguments:			<apSession> - session record
//
// Return Value:	PCSetInfo - property constraint set info object that 
//								contains the bit mask of the properties in session record
// Errors Raised: error object
// Description:		evaluate properties in session record to generate a 
//								PCSetInfo record that contains bit mask of the properties.
// --------------------------------------------------------------------------
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "PCEvaluator()"
int PropGenerator::PCEvaluator(CMTSessionBase* apSession)
{
  ErrorObject							localError;
  RTRule*							    rule;
  char										logStr[MAX_LOG_STRING];
  //real rule id (pcid) starts with 1. 0 indicates that none of the rules succeeded
  int ret = 0;

  BOOL okToLog = (mIMTLogPtr->OKToLog(PLUGIN_LOG_DEBUG) == VARIANT_TRUE);

  _bstr_t name;
  vector<AutoReset<RTCondition> > autoreset;
  vector<AutoReset<RTRule> > ruleautoreset;
  bool firstrule = true;
  vector<RTRule*>::iterator it;
  int pcid = 0;
  for (it = mRTRules.begin(); it != mRTRules.end(); ++it)
  {
    pcid++;
    rule = *it;
    ruleautoreset.push_back(rule);
    //rule has already been marked as "failed"
    //by one of the conditions referenced in this rule but also
    //previously executed on a different rule
    if(false)//rule->Executable == 0)
    {
      continue;
    }

    vector<RTCondition*>* conditions = rule->GetConditions();
    bool rule_succeeded = false;
    for(vector<RTCondition*>::iterator it1 = conditions->begin();
      it1 != conditions->end(); it1++)
    {
      RTCondition* cond = *it1;
      //if this condition has already been executed successfully
      //or unsuccessfully, don't execute it again.
      if(cond->Executed())
      {
        //if it executed successfully, proceed to the next condition
        if(cond->Success())
        {
          rule_succeeded = true;
          continue;
        }
        //if it already failed on some previous rule; no need to
        //execute the rest of the conditions on this rule
        else
        {
          rule_succeeded = false;
          break;
        }
      }
      else
      {
        try
        {
          //mark it for autoreset (flip executed bit back to false) when we go out of scope
          autoreset.push_back(cond);
      
          if (cond->Evaluate(apSession))
          {
            if (okToLog)
            {
              _bstr_t name = mIdlookupPtr->GetName(cond->GetPropNameID());
              sprintf(logStr, "Match property(string): %s, PCID: %d", 
                (char*)name, 
                pcid);
              mIMTLogPtr->LogString(PLUGIN_LOG_DEBUG, logStr);
            }
            rule_succeeded = true;
            continue;
          }
          //no need to execute the rest of the conditions on this rule
          else
          {
            rule_succeeded = false;
            break;
          }

        }
        catch(_com_error& err)
        {
          _bstr_t errorMsg(err.ErrorMessage());

          sprintf(logStr, "Failed to evaluate property '%s'.  Error Code: %X", 
            (char*)mIdlookupPtr->GetName(cond->GetPropNameID()), 
            err.Error());
          mIMTLogPtr->LogString(PLUGIN_LOG_ERROR, logStr);

          localError = *CreateErrorFromComError(err);
          localError.GetProgrammerDetail() = logStr;
          throw localError;
        }
        catch (...)
        {
          sprintf(logStr, "Failed to evaluate property '%s'.", 
            (char*)mIdlookupPtr->GetName(cond->GetPropNameID()));
          mIMTLogPtr->LogString(PLUGIN_LOG_ERROR, logStr);

          SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);
          localError = *GetLastError();
          localError.GetProgrammerDetail() = logStr;
          throw localError;
        }
      }//else()
    }//for conditions
    if(firstrule)
      firstrule = false;
    
    //if this rule succeeded, return its' id
    //and terminate iteration through rules
    if(rule_succeeded)
    {
      ret = pcid;
      break;
    }
  }

  return ret;
}


// --------------------------------------------------------------------------
// Arguments:			none
//
// Return Value:	none
// Errors Raised: None
// Description:		test utility to dump derived property info table
// --------------------------------------------------------------------------
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "DumpDerivedPropInfoTbl()"
void PropGenerator::DumpDerivedPropInfoTbl()
{
}



// --------------------------------------------------------------------------
// Arguments:			<apValue> - derived property info table
//
// Return Value:	none
// Errors Raised: None
// Description:		test utility to dump derived property info table
// --------------------------------------------------------------------------
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "DumpPropList()"
void PropGenerator::DumpPropList(DerivedPropInfoList* apValue)
{
}


// --------------------------------------------------------------------------
// Arguments:			<apSystemContext> - contains MTLog object and IdLookup 
//																		object
//								<apPropSet> - propset pointer contains RuleSet info
//
// Return Value:	none
// Errors Raised: Error object
// Description:		load configuration info
// --------------------------------------------------------------------------
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "Configure()"
void PropGenerator::Configure(IUnknown * apSystemContext, 
															IMTConfigPropSetPtr apPropSet)
{
	ErrorObject						localError;
	IMTNameIDPtr					idlookup(apSystemContext);
	IMTConfigPropSetPtr		derivedPropSet;
	DerivedPropInfoList*	derivedPropInfoList;
	long									propNameID;
	IMTConfigPropSetPtr		constraintSet;
	IMTConfigPropSetPtr		constraint;
	_bstr_t								propName;
	_bstr_t								condition;
	PropGenEnums::ConditionType	propCondition;
	_variant_t						propValue;
	long									PCSetID;
	MTPipelineLib::PropValType propType;
	char*									str;


	mIMTLogPtr = apSystemContext;
	mIdlookupPtr = apSystemContext;

	// Get target name
	VARIANT_BOOL actionsFlag = apPropSet->NextMatches(DEFAULT_ACTIONS, MTPipelineLib::PROP_TYPE_SET);
	if (actionsFlag == VARIANT_TRUE)
	{
		derivedPropSet = apPropSet->NextSetWithName(DEFAULT_ACTIONS);
	}
	else
	{
		// the default actions can also labeled as <ACTIONS>
		actionsFlag = apPropSet->NextMatches(ACTIONS, MTPipelineLib::PROP_TYPE_SET);
		if (actionsFlag == VARIANT_TRUE)
		{
			derivedPropSet = apPropSet->NextSetWithName(ACTIONS);
		}
		else
		{
			derivedPropSet = apPropSet;
		}
	}

	if (derivedPropSet != NULL)
	{
		mDefDerivedPropInfoList = new DerivedPropInfoList;
		if (mDefDerivedPropInfoList == NULL)
		{
			SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);
			localError = *GetLastError();
			localError.GetProgrammerDetail() = "Can not allocate the DefDerivedPropInfoList";

			throw localError;
		}

		// load up the default derived value set
		if (LoadDerivedPropSet(mDefDerivedPropInfoList, derivedPropSet, idlookup) 
				== FAILURE)
		{
			// error: incorrect default derived value
			ListCleanup(mDefDerivedPropInfoList);
			delete mDefDerivedPropInfoList;

			localError = *GetLastError();
			localError.GetProgrammerDetail() = "DEFAULT_ACTIONS is missing or incorrect";
			// log error msg
			throw localError;
		}
	}
	else
	{
		SetError(PIPE_ERR_MISSING_ACTIONS, ERROR_MODULE, ERROR_LINE, PROCEDURE);
		localError = *GetLastError();
		localError.GetProgrammerDetail() = "DEFAULT_ACTIONS is missing or incorrect";
		// log error msg: no default value set available

		throw localError;
	}

	VARIANT_BOOL bFlag;
	// iterate through the constraint set
	while ((constraintSet = apPropSet->NextSetWithName(CONSTRAINT_SET)) != NULL)
	{
		PCSetID = GetNextPCSetID();
    RTRule* rtrule = new RTRule(PCSetID);

		derivedPropInfoList = NULL;

		actionsFlag = constraintSet->NextMatches(ACTIONS, MTPipelineLib::PROP_TYPE_SET);

		if (actionsFlag == VARIANT_TRUE)
		{
			derivedPropSet = constraintSet->NextSetWithName(ACTIONS);
		}
		else
		{
			derivedPropSet = constraintSet;
		}

		if (derivedPropSet != NULL)
		{
			derivedPropInfoList = &(*mDerivedPropInfoListTbl)[PCSetID];
			if (derivedPropInfoList == NULL)
			{
				SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);
				localError = *GetLastError();
				localError.GetProgrammerDetail() = "Can not allocate the derivedPropInfoList";

				throw localError;
			}

			// load up derived value set
			if (LoadDerivedPropSet(derivedPropInfoList, derivedPropSet, idlookup) 
					== FAILURE)
			{
				ListCleanup(derivedPropInfoList);

				localError = *GetLastError();
				localError.GetProgrammerDetail() = "ACTIONS is missing or incorrect";
				throw localError;
			}

		}
		else
		{
			localError = *GetLastError();
			localError.GetProgrammerDetail() = "ACTIONS is missing";
			throw localError;
		}

		_bstr_t sourcePropertyName;
		_bstr_t SourcePropType;
		
		while ((constraint = constraintSet->NextSetWithName(CONSTRAINT)) != NULL)
		{
			//TODO: Decimal support
			bFlag = constraint->NextMatches(PROP_NAME, MTPipelineLib::PROP_TYPE_STRING);
			if (bFlag != VARIANT_TRUE)
			{
				SetError(PIPE_ERR_INCORRECT_CONSTRAINT_SET, ERROR_MODULE, ERROR_LINE, PROCEDURE);
				localError = *GetLastError();
				localError.GetProgrammerDetail() = "prop_name is missing";
				throw localError;
			}

			propName = constraint->NextStringWithName(PROP_NAME);
			str = propName;
			if (str == NULL)
			{
				SetError(PIPE_ERR_INCORRECT_CONSTRAINT_SET, ERROR_MODULE, ERROR_LINE, PROCEDURE);
				localError = *GetLastError();
				localError.GetProgrammerDetail() = "prop_name is missing";
				throw localError;
			}
			propNameID = idlookup->GetNameID(propName);

			bFlag = constraint->NextMatches(CONDITION, MTPipelineLib::PROP_TYPE_STRING);
			if (bFlag != VARIANT_TRUE)
			{
				SetError(PIPE_ERR_INCORRECT_CONSTRAINT_SET, ERROR_MODULE, ERROR_LINE, PROCEDURE);
				localError = *GetLastError();
				localError.GetProgrammerDetail() = "condition is missing";
				throw localError;
			}
			condition = constraint->NextStringWithName(CONDITION);
			str = condition;
			if (str == NULL)
			{
				SetError(PIPE_ERR_INCORRECT_CONSTRAINT_SET, ERROR_MODULE, ERROR_LINE, PROCEDURE);
				localError = *GetLastError();
				localError.GetProgrammerDetail() = "condition is missing";
				throw localError;
			}
			propCondition = GetNativeCondition(condition);

			// if the constraint is a valuable comparison
			if (constraint->NextMatches(PROP_SOURCE_NAME, MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
			{
        SetError(PIPE_ERR_INCORRECT_CONSTRAINT_SET, ERROR_MODULE, ERROR_LINE, PROCEDURE);
					localError = *GetLastError();
					localError.GetProgrammerDetail() = "Unsupported configuration - use MTSQL instead.";
					throw localError;
			}
			else
			{

				IMTConfigPropPtr	nextPropValue = constraint->NextWithName(PROP_VALUE);
				if (nextPropValue == NULL)
				{
					SetError(PIPE_ERR_INCORRECT_CONSTRAINT_SET, ERROR_MODULE, ERROR_LINE, PROCEDURE);
					localError = *GetLastError();
					localError.GetProgrammerDetail() = "prop_value is missing";
					throw localError;
				}
				propValue = nextPropValue->GetValue(&propType);
			}
      
      rtrule->AddCondition(AddConstraint(propNameID, propCondition, propValue, propType));

		} // while (constraint)

    mRTRules.push_back(rtrule);
	}  // while (constraint_set)

}

// --------------------------------------------------------------------------
// Description: Configure the ruleset given a ruleset object
// --------------------------------------------------------------------------


void PropGenerator::Configure(MTPipelineLib::IMTLogPtr aLogger,
															MTPipelineLib::IMTNameIDPtr aNameID,
															MTautoptr<PropGenRuleSet> &aRuleSet)
{
	const char * functionName = "PropGenerator::Configure";
	ErrorObject						localError;
  
	mIMTLogPtr = aLogger;
	mIdlookupPtr = aNameID;

	const vector<const DerivedPropInfo*>* defaultActions = aRuleSet->GetDefaultActions();

  if (defaultActions != NULL)
  {
    // there are default actions
		mDefDerivedPropInfoList = new DerivedPropInfoList;
    // load up the default derived value set
		if (LoadDerivedPropSet(mDefDerivedPropInfoList, defaultActions, aNameID)
				== FAILURE)
		{
			// error: incorrect default derived value
			ListCleanup(mDefDerivedPropInfoList);
			delete mDefDerivedPropInfoList;

			localError = *GetLastError();
			localError.GetProgrammerDetail() = "DEFAULT_ACTIONS is missing or incorrect";
			// log error msg
			throw localError;
		}
  }
  else
	{
		// no default actions
		mDefDerivedPropInfoList = NULL;
	}
  
  const vector<MTautoptr<PropGenRule> >* rules = aRuleSet->GetRules();
  const vector<ConditionTriplet*>* conditions;
  const vector<const DerivedPropInfo*>* actions;
  for(vector<MTautoptr<PropGenRule> >::const_iterator it = rules->begin(); it != rules->end(); it++)
  {
    // internal ID that holds this rule
		int PCSetID = GetNextPCSetID();
    RTRule* rtrule = new RTRule(PCSetID);
    const PropGenRule* rule = &*it;

    actions = rule->GetActions();

    DerivedPropInfoList * derivedPropInfoList = &(*mDerivedPropInfoListTbl)[PCSetID];

    if (LoadDerivedPropSet(derivedPropInfoList, actions, aNameID) 
				== FAILURE)
		{
			ListCleanup(derivedPropInfoList);

			localError = *GetLastError();
			localError.GetProgrammerDetail() = "ACTIONS is missing or incorrect";
			throw localError;
		}

    conditions = rule->GetConditions();
    for(vector<ConditionTriplet*>::const_iterator it = conditions->begin(); it != conditions->end(); it++)
    {
      ConditionTriplet* condition = *it;
      RTCondition* rtcond = GetRTCondition(condition);
      rtrule->AddCondition(rtcond);
			//AddConstraint(condition, aNameID, PCSetID);
    }
    mRTRules.push_back(rtrule);

  }
  
}

RTCondition* PropGenerator::AddConstraint(long& nameid, PropGenEnums::ConditionType& cond, _variant_t& val, MTPipelineLib::PropValType type)
{
  ConditionTriplet* condition = 
            mConditionTripletLibrary->Add(nameid, cond, val, (MTPipelineLib::PropValType)type);
  RTCondition* rtc = GetRTCondition(condition);
  return rtc;
}






// --------------------------------------------------------------------------
// Arguments:			<apSession> - session object to be processed
//
// Return Value:	false if no default rules and no rules matched
// Errors Raised: None
// Description:		Evaluate session object against property constraint set to 
//								generate a PCSetInfo object that contains a bit mask of the 
//								eveluate result.  The mask is then used to find the 
//								property constraint set id, which is then being used to get
//								derived property set.  Last step is to set the property set 
//								into session object.
// --------------------------------------------------------------------------
#ifdef PROCEDURE
#undef PROCEDURE
#endif


//BP: Remove this method later
BOOL PropGenerator::ProcessSession(MTPipelineLib::IMTSessionPtr apSession)
{
  CMTSession* s;
  CMTSessionBase* sbase;
  HRESULT hr = apSession->QueryInterface(IID_NULL,(void**)&s);
	if(FAILED(hr)) 
  {
    ASSERT(false);
	}
  s->GetSessionBase(&sbase);
  ASSERT(sbase != NULL);
  return ProcessSession(sbase);
}

#define PROCEDURE "ProcessSession()"
BOOL PropGenerator::ProcessSession(CMTSessionBase* apSession)
{
	ErrorObject						localError;
	int										ret = 1;
	DerivedPropInfoList*	newPropList;


	int ruleid = PCEvaluator(apSession);

	// Get new property list

	// no PCSetID was found, use the default value
	if (ruleid == 0)
	{
		if (!mDefDerivedPropInfoList || !mDefDerivedPropInfoList->size())
		{
			mIMTLogPtr->LogString(PLUGIN_LOG_DEBUG, "No default property configured - nothing is done.");
			return FALSE;
		}
		newPropList = mDefDerivedPropInfoList;
	}
	else
	{
		DerivedPropInfoListColl::iterator it = mDerivedPropInfoListTbl->find(ruleid);
		if (it == mDerivedPropInfoListTbl->end())
		{
			SetError(PIPE_ERR_MISSING_DERIVED_PROP_VALUE, ERROR_MODULE, ERROR_LINE, PROCEDURE);
			localError = *GetLastError();
			localError.GetProgrammerDetail() = "PCSetID is not in DerivedPropInfoListTbl";

			throw localError;
		}
		else
			newPropList = &it->second;
	}

	SetPropInSession(apSession, newPropList);

	return TRUE;
}


// --------------------------------------------------------------------------
// Arguments:			<apSession> - session object to be processed
//								<apNewPropList> - derived property set to be set into 
//								session object
//
// Return Value:	None
// Errors Raised: error object
// Description:		set derived property set to session object
// --------------------------------------------------------------------------
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "SetPropInSession()"
void PropGenerator::SetPropInSession(CMTSessionBase* apSession, 
																	DerivedPropInfoList* apNewPropList)
{
	ErrorObject				localError;
	int								item;
	const DerivedPropInfo*	derivPropInfo;
	long							newPropId;
	char							logStr[MAX_LOG_STRING];
	MTDecimal						decimalPropValue;

	item = apNewPropList->size();
	if (!item)
	{
		// error: log error msg, throw error
		SetError(PIPE_ERR_MISSING_DERIVED_PROP_VALUE, ERROR_MODULE, ERROR_LINE, PROCEDURE);
		localError = *GetLastError();
		localError.GetProgrammerDetail() = "No derived property value";
		throw localError;
	}

	_bstr_t name;

	DerivedPropInfoList::iterator it;
	for (it = apNewPropList->begin(); it != apNewPropList->end(); ++it)
	{
		derivPropInfo = *it;

		newPropId = derivPropInfo->GetDerivedPropNameID();
 
		if (mIMTLogPtr->OKToLog(PLUGIN_LOG_DEBUG))
		{
			name = mIdlookupPtr->GetName(newPropId);
		}

		if (derivPropInfo->SetPropertyToSession(apSession, mIMTLogPtr, mIdlookupPtr) != SUCCESS)
		{
			sprintf(logStr, "Error setting property name: %s", (char*)name);
			mIMTLogPtr->LogString(PLUGIN_LOG_DEBUG, logStr);

			SetError(PIPE_ERR_MISSING_DERIVED_PROP_VALUE, ERROR_MODULE, ERROR_LINE, PROCEDURE);
			localError = *GetLastError();
			localError.GetProgrammerDetail() = "Error setting property value";
			throw localError;
		}

	} // for loop

}

RTCondition* PropGenerator::GetRTCondition(ConditionTriplet* aPtr)
{
  RTCondition* out = NULL;
  map<const ConditionTriplet*, RTCondition*>::iterator it = mRTConditions->find(aPtr);
  
  if(it == mRTConditions->end())
  {
    pair<map<const ConditionTriplet*, RTCondition*>::iterator, bool> find = 
      mRTConditions->insert(make_pair(aPtr, new RTCondition(aPtr)));
    ASSERT(find.second == true);
    out = find.first->second;
  }
  else
    out = it->second;

  return out;
}



// End of PropGenerator.cpp
/////////////////////////////////////////////////////////////////////////////
