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
// PropGenerator.h: interface for the PropGenerator class.
//
//////////////////////////////////////////////////////////////////////

/*
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") rename("tagDOMNodeType", "MTPipelineLibtagDOMNodeType") exclude ("IMTSecurity") \
  exclude ("IMTAccountTemplate") \
  exclude ("IMTAccountTemplateSubscriptions") exclude ("IMTYAAC")  exclude ("IMTAccountTemplateProperties") \
  no_function_mapping
*/

using MTPipelineLib::IMTActionSetPtr;
using MTPipelineLib::IMTAssignmentActionPtr;

//using MTPipelineLib::IMTRuleSetPtr;
using MTPipelineLib::IMTRulePtr;

using MTPipelineLib::IMTConditionSetPtr;
using MTPipelineLib::IMTSimpleConditionPtr;

class ConditionTripletLibrary;
class DerivedPropInfoLibrary;


// ----------------------------------------------------------------------------
// Description: PropGenerator is a class that holds:
//							a) default property set list
//							b) property constraint list
//							c) property constraint set mask list
//							d) derived property set list
//							From session record, a property constraint set mask is 
//							generated by comparing the properties in the session against 
//							property constraint list.  The mask will be used to create 
//							property constraint set id by comparing against property 
//							constraint set mask list.  Finally the id is used to get 
//							derived property set and set into the session record.
// ----------------------------------------------------------------------------
#if !defined(AFX_PROPGENERATOR_H__8417C8F1_2C6F_11D2_80ED_006008C0E8B7__INCLUDED_)
#define AFX_PROPGENERATOR_H__8417C8F1_2C6F_11D2_80ED_006008C0E8B7__INCLUDED_


#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000


#include "errobj.h"

#include "PropConstInfo.h"
#include "PCSetInfo.h"
#include "DerivedPropInfo.h"
#include "PropGenInclude.h"

//class __declspec(dllexport) RWCString;

//class __declspec(dllexport) PropGenerator;

class PropGenerator : virtual ObjectWithError
{
public:
	// --------------------------------------------------------------------------
	// Description: Construction that initialize the default member value the 
	//							empty collection list
	// --------------------------------------------------------------------------
	PropGenerator();

	// --------------------------------------------------------------------------
	// Description: Copy Construction that initialize the default member value the 
	//							empty collection list
	// --------------------------------------------------------------------------
	PropGenerator(const long& aPropNameID);

	// --------------------------------------------------------------------------
	// Description: Destruction of the object that clean up the collection list
	// --------------------------------------------------------------------------
	virtual ~PropGenerator(void);

  // --------------------------------------------------------------------------
	// Description: private method to return hash key from property name id, 
	//							constraint condition, property type, and property value.
	// --------------------------------------------------------------------------
	

private:

	
	// --------------------------------------------------------------------------
	// Description: Load derived property set from propset
	// --------------------------------------------------------------------------
	int LoadDerivedPropSet(DerivedPropInfoList*	apDerivedPropInfoList, 
												MTPipelineLib::IMTConfigPropSetPtr	apDerivedPropSet,
												MTPipelineLib::IMTNameIDPtr aIdlookup);


	int LoadDerivedPropSet(DerivedPropInfoList*	apDerivedPropInfoList, 
												 IMTActionSetPtr aActions,
												 MTPipelineLib::IMTNameIDPtr aIdlookup);

  int LoadDerivedPropSet(DerivedPropInfoList*	apDerivedPropInfoList, 
												 const vector<const DerivedPropInfo*>* aActions,
												 MTPipelineLib::IMTNameIDPtr aIdlookup);



	// --------------------------------------------------------------------------
	// Description: Clean up derived property list
	// --------------------------------------------------------------------------
	void ListCleanup(DerivedPropInfoList*	apDerivedPropInfoList);


	// --------------------------------------------------------------------------
	// Description: Property constraint id count
	// --------------------------------------------------------------------------
	const long PCIDCount()
	{
		return ++mPCIDCount;
	}

	// --------------------------------------------------------------------------
	// Description: Property constraint set id count
	// --------------------------------------------------------------------------
	const long GetNextPCSetID()
	{
		return ++mPCSetID;
	}

	// --------------------------------------------------------------------------
	// Description: add derived property to derived property info list
	// --------------------------------------------------------------------------
	void SetDerivedPropValue(DerivedPropInfoList*	apDerivedPropInfoList,
													const long& aNameID,
													const MTPipelineLib::PropValType& propType,
													const _variant_t& propValue);

	void SetDerivedPropValue(DerivedPropInfoList*	apDerivedPropInfoList,
													const long& aNameID,
													const _bstr_t aSourcePropertyName, 
													const long& aSourceNameID,
													const _bstr_t aSourcePropType);

	// --------------------------------------------------------------------------
	// Description: convert the enum condition value into string value
	// --------------------------------------------------------------------------
	PropGenEnums::ConditionType GetNativeCondition(_bstr_t& condition);

	// --------------------------------------------------------------------------
	// Description: add derived property set to the table
	// --------------------------------------------------------------------------
	void SetDerivedPropInfoTbl(int* apKey, DerivedPropInfoList* apValue)
	{
		mDerivedPropInfoListTbl->insert(DerivedPropInfoListColl::value_type(*apKey, *apValue));
	}


	// --------------------------------------------------------------------------
	// Description: Property Constraint evaluator return a list of bit mask 
	//							which represents a set of PC_ID base on Property Constraint 
	//							table (Table 1), given session object.
	// --------------------------------------------------------------------------
	int PCEvaluator(CMTSessionBase* apSession);

	// --------------------------------------------------------------------------
	// Description: generates PCSet_ID based on the result from PCEvaluator() 
	//							and Property Constraint Set Table(Table 2).
	// --------------------------------------------------------------------------
	const int PCSetEvaluator(const PCSetInfo* aPCSetInfo);



	void DumpDerivedPropInfoTbl();
	// data dump for test

	void DumpPropList(DerivedPropInfoList* apValue);
	//////////////////////////////////////////////////////////////////////////

	RTCondition* PropGenerator::AddConstraint(long& nameid, PropGenEnums::ConditionType& condition, _variant_t& val, MTPipelineLib::PropValType type);



public:
	// Public methods
	// --------------------------------------------------------------------------
	// Description: Public Methods serialize with configuration tables.
	// --------------------------------------------------------------------------
	void Configure(IUnknown * systemContext, MTPipelineLib::IMTConfigPropSetPtr apPropSet);

	// --------------------------------------------------------------------------
	// Description: Configure the ruleset given a ruleset object
	// --------------------------------------------------------------------------
	//void Configure(MTPipelineLib::IMTLogPtr aLogger, MTPipelineLib::IMTNameIDPtr aNameID,
	//							 IMTRuleSetPtr aRuleSet);

  // --------------------------------------------------------------------------
	// Description: Configure the ruleset given a raw C++ version of a ruleset object
	// --------------------------------------------------------------------------
	void Configure(MTPipelineLib::IMTLogPtr aLogger, MTPipelineLib::IMTNameIDPtr aNameID,
								 MTautoptr<PropGenRuleSet> &aRuleSet);

	// --------------------------------------------------------------------------
	// Description: process session to generate new Property Value(Product name 
	//							for Product.  Determination, view name for View 
	//							Determination, etc.)
	// --------------------------------------------------------------------------
	BOOL ProcessSession(CMTSessionBase* apSession);
  BOOL PropGenerator::ProcessSession(MTPipelineLib::IMTSessionPtr apSession);

	///////////////  for debug purposes ////////////////////////////


	// --------------------------------------------------------------------------
	// Description: number of property constraints in table
	// --------------------------------------------------------------------------
	const int GetPCIDCount()
	{
		return mPCIDCount;
	}

	// --------------------------------------------------------------------------
	// Description: set derived property to session record
	// --------------------------------------------------------------------------
	void SetPropInSession(CMTSessionBase* apSession, 
												DerivedPropInfoList* apNewPropList);

	///////////////////////////////////////////////////////////////

private:
	// member variables
	MTPipelineLib::IMTLogPtr								mIMTLogPtr;
	MTPipelineLib::IMTNameIDPtr							mIdlookupPtr;

	// number of property constraints in table
	long										mPCIDCount;

	// number of property set
	long										mPCSetID; 

	// default derived property list - list of nameID's and values
	DerivedPropInfoList*		mDefDerivedPropInfoList;

	// Derived property Table
	DerivedPropInfoListColl			*mDerivedPropInfoListTbl;

  map<const ConditionTriplet*, RTCondition*>* mRTConditions;

  RTCondition* GetRTCondition(ConditionTriplet*);
  
  vector<RTRule*> mRTRules;

  ConditionTripletLibrary * mConditionTripletLibrary;

  DerivedPropInfoLibrary * mDerivedPropInfoLibrary;

};


#endif // !defined(AFX_PROPGENERATOR_H__8417C8F1_2C6F_11D2_80ED_006008C0E8B7__INCLUDED_)

///////////////////////////////////////////////////////////////////////////////
