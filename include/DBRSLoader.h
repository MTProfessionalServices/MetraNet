/**************************************************************************
 * @doc DBRSLOADER
 *
 * @module |
 *
 *
 * Copyright 2001 by MetraTech Corporation
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | DBRSLOADER
 ***************************************************************************/

#ifndef _DBRSLOADER_H
#define _DBRSLOADER_H

#include <RSCache.h>

#include <classobject.h>

#import <MTProductCatalog.tlb> rename("EOF", "EOFX") 
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <MTEnumConfigLib.tlb>

struct IMTProductCatalog;

/************************************************ DBRSLoader ***/
class ParamTableMetaData;
// a rate schedule loader that reads rates from the database
class DBRSLoader : public RateScheduleLoader
{
public:

	// initialize the loader
	BOOL Init();

	// get the last modified date of the given rate schedule
	// (mostly for debugging)
	time_t GetLastModified(int aScheduleID);

  // create a rate schedule with the ruleset evaluator created
  // and modification date initialized.
  virtual CachedRateSchedulePropGenerator* CreateRateSchedule(int aParameterTable, time_t aModifiedAt);

	// load a rate schedule and return a pointer to it.
	// it's expected that this call allocates the CachedRateSchedule
	// with new.  If the schedule cannot be loaded, return NULL.
	virtual CachedRateSchedule * LoadRateSchedule(int    aParamTableID,
                                                int    aScheduleID,
																								time_t aModifiedAt);

	BOOL LoadRateScheduleToRuleSet(//MTPRODUCTCATALOGLib::IMTRuleSetPtr aRuleset,
                                 PropGenRuleSet* apRuleset,
																 int                                aParamTableID,
																 int                                aScheduleID,
																 CachedRateSchedulePropGenerator*   apSchedule);

	// NOTE: this method will throw COM errors!
	BOOL LoadRateScheduleToRuleSet(//MTPRODUCTCATALOGLib::IMTRuleSetPtr              aRuleset,
                                 PropGenRuleSet* apRuleset,
																 MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr aParamTableDef,
																 int                                             aScheduleID,
																 CachedRateSchedulePropGenerator*                apSchedule,
                                 VARIANT                                         aRefDate);


  BOOL LoadRateScheduleToRuleSet(MTPRODUCTCATALOGLib::IMTRuleSetPtr              aRuleset,
																 MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr aParamTableDef,
																 int                                             aScheduleID,
																 CachedRateSchedulePropGenerator*                apSchedule,
                                 VARIANT                                         aRefDate);
                                 //wstring                                         strRefDate);

  // load all rate schedules in the specified parameter table.
	// it's expected that this call allocates the CachedRateSchedules
	// with new.  If the schedules cannot be loaded, return FALSE.
  virtual BOOL LoadRateSchedules(int                 aParamTableID,
                                 time_t              aModifiedAt,
                                 RATESCHEDULEVECTOR& aRateSchedInfo);

private:

	// NOTE: this method will throw COM errors!
	BOOL LoadRateSchedulesToRuleSets(
													 			  int                                             aParamTableID,
                                  MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr aParamTableDef,
                                  time_t                                          aModifiedAt,
                                  RATESCHEDULEVECTOR&                             aRateSchedInfo);

  BOOL LoadRateScheduleToRuleSetFromRowSet(
                                 MTPipelineLib::IMTSQLRowsetPtr                  aRowset,
                                 //MTPRODUCTCATALOGLib::IMTRuleSetPtr              aRuleset,
                                 PropGenRuleSet* apRuleset,
																 MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr aParamTableDef,
                                 ParamTableMetaData* aMD,
																 int                                             aScheduleID,
																 CachedRateSchedulePropGenerator*                apSchedule);
   
  void InitMetaData(MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr aParamTableDef, ParamTableMetaData& aMD);


	void ConvertConditionToCom(const ConditionTriplet* condition,
														 MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr aParamTableDef,
														 MTPipelineLib::IMTSimpleConditionPtr comCondition);

	void ConvertActionToCom(const DerivedPropInfo* action,
													MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr aParamTableDef,
													MTPipelineLib::IMTAssignmentActionPtr comAction);


	MTPRODUCTCATALOGLib::IMTConditionMetaDataPtr LookupConditionMetadata(long propNameID,
																																			 MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr aParamTableDef);
	MTPRODUCTCATALOGLib::IMTActionMetaDataPtr LookupActionMetadata(long propNameID,
																																 MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr aParamTableDef);


	MTPipelineLib::IMTSQLRowsetPtr mRowset;

	MTPRODUCTCATALOGLib::IMTProductCatalogPtr mpCatalog;

	// for converting enum IDs to their string values
	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
  MTPipelineLib::IMTNameIDPtr mNameId;
  MTPipelineLib::IMTLogPtr mLogger;
	void ChangeToBool(_variant_t& aVal);
	
	// class factories for various rule set objects
	ClassObject<MTPRODUCTCATALOGLib::IMTRuleSetPtr> mRuleSetFactory;
	ClassObject<MTPRODUCTCATALOGLib::IMTRulePtr> mRuleFactory;
	ClassObject<MTPRODUCTCATALOGLib::IMTActionSetPtr> mActionSetFactory;
	ClassObject<MTPRODUCTCATALOGLib::IMTConditionSetPtr> mConditionSetFactory;
	ClassObject<MTPRODUCTCATALOGLib::IMTAssignmentActionPtr> mActionFactory;
	ClassObject<MTPRODUCTCATALOGLib::IMTSimpleConditionPtr> mConditionFactory;

	ClassObject<MTPipelineLib::IMTRuleSetEvaluatorPtr> mRuleSetEvaluatorFactory;

};

class ConditionMetaData
{
public:
   ConditionMetaData(_bstr_t& aName, _bstr_t& aColName, 
     MTPRODUCTCATALOGLib::PropValType& aDataType, VARIANT_BOOL aOpPerRule, VARIANT_BOOL aRequired, MTPRODUCTCATALOGLib::MTOperatorType& aOp) :
   PropertyName(aName), ColumnName(aColName), DataType(aDataType), OperatorPerRule(aOpPerRule), IsRequired(aRequired), Operator(aOp) {}

   const _bstr_t GetPropertyName() const {return PropertyName;}
   const _bstr_t GetColumnName() const {return ColumnName;}
   const MTPRODUCTCATALOGLib::PropValType GetDataType() const {return DataType;}
   const VARIANT_BOOL GetOperatorPerRule() const {return OperatorPerRule;}
   const VARIANT_BOOL GetRequired() const {return IsRequired;}
   const MTPRODUCTCATALOGLib::MTOperatorType GetOperator() const  {return Operator;}

private:
  _bstr_t PropertyName;
  _bstr_t ColumnName;
  MTPRODUCTCATALOGLib::PropValType DataType;
  VARIANT_BOOL OperatorPerRule;
  VARIANT_BOOL IsRequired;
  MTPRODUCTCATALOGLib::MTOperatorType Operator;
};

class ActionMetaData
{
public:
   ActionMetaData(_bstr_t& aName, _bstr_t& aColName, 
     MTPRODUCTCATALOGLib::PropValType& aDataType, VARIANT_BOOL aRequired) :
   PropertyName(aName), ColumnName(aColName), DataType(aDataType), IsRequired(aRequired) {}
   
   const _bstr_t GetPropertyName() const {return PropertyName;}
   const _bstr_t GetColumnName() const {return ColumnName;}
   const MTPRODUCTCATALOGLib::PropValType GetDataType() const {return DataType;}
   const VARIANT_BOOL GetRequired() const {return IsRequired;}
private:
  _bstr_t PropertyName;
  _bstr_t ColumnName;
  MTPRODUCTCATALOGLib::PropValType DataType;
  VARIANT_BOOL IsRequired;
};

class ParamTableMetaData
{
friend class DBRSLoader;
public:
  const vector<ConditionMetaData>* GetConditions() const
  {
    return &Conditions;
  }
  const vector<ActionMetaData>* GetActions() const
  {
    return &Actions;
  }
private:
  vector<ConditionMetaData> Conditions;
  vector<ActionMetaData> Actions;
};



#endif /* _DBRSLOADER_H */

