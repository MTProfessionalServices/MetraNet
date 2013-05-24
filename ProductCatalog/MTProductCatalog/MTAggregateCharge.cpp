/**************************************************************************
* Copyright 1997-2001 by MetraTech
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
* $Header: MTAggregateCharge.cpp, 38, 10/9/2002 5:36:06 PM, Derek Young$
* 
***************************************************************************/


#include "StdAfx.h"
#include "MTAggregateCharge.h"
#include <mtcomerr.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <DataAccessDefs.h>
#include <RowsetDefs.h>
#include <perflog.h>
#include <MSIX.h>
#include <ServicesCollection.h>
#include <reservedproperties.h>
#include <mttime.h>

// Dataflow framework
#include <PlanInterpreter.h>
#include <HashAggregate.h>
#include <DatabaseSelect.h>
#include <DatabaseInsert.h>
#include <DatabaseMetering.h>
#include <AggregateExpression.h>

#include <boost/format.hpp>
#include <boost/random.hpp>

#include <strstream>
#include <memory>

// import the query adapter tlb ...
#import <QueryAdapter.tlb> rename("GetUserName", "GetUserNameQA")

// 
// Generate the dataflow program
//
class AggregateDataflowPlanGenerator
{
private:
  NTLogger mLogger;
  MTNAMEIDLib::IMTNameIDPtr mNameID;
  CProductViewCollection mProductViews;
	CServicesCollection mServices;
  DesignTimePlan& mPlan;
  std::wstring& mProgram;

  std::vector<boost::shared_ptr<Port> > mAggregateOutputs;
  std::vector<std::wstring > mProgramOutputs;

  HRESULT ProcessIncrementalCounters(MTPRODUCTCATALOGLib::IMTAggregateChargePtr aggCharge, 
                                     std::wstring& wstrInitializeProgram,
                                     std::set<std::wstring>& counters,
                                     std::vector<AggregateRatingCountableSpec>& countables);

  HRESULT AddAggregateCharge(const std::vector<boost::int32_t>& aUsageIntervalID, 
                             boost::int32_t aBillingGroup,
                             bool aIsEstimate,
                             bool aReadAllRatedUsageColumns,
                             MTPRODUCTCATALOGLib::IMTAggregateChargePtr charge,
                             std::set<std::wstring>& counters);

public:
  AggregateDataflowPlanGenerator(NTLogger & logger, DesignTimePlan& plan, std::wstring& program)
    :
    mLogger(logger),
    mNameID(MTPROGID_NAMEID),
    mPlan(plan),
    mProgram(program)
  {
		if (!mProductViews.Initialize())
    {
      const ErrorObject* err = mProductViews.GetLastError();
      std::string msg = "Could not initialize product view collection! ";
      msg += err->GetProgrammerDetail();
      throw MTException(msg, err->GetCode());
    }
    //
    // builds a map of our own service def objects keyed by service ID
    //
    if (!mServices.Initialize())
    {
      const ErrorObject* err = mServices.GetLastError();
      std::string msg = "Could not initialize service def collection! ";
      msg += err->GetProgrammerDetail();
      throw MTException(msg, err->GetCode());
    }
  }

  std::vector<boost::shared_ptr<Port> >& GetAggregateOutputs()
  {
    return mAggregateOutputs;
  }

  std::vector<std::wstring>& GetProgramOutputs()
  {
    return mProgramOutputs;
  }

  HRESULT GenerateForAggregateParent(const std::vector<boost::int32_t>& aUsageIntervalID, 
                                     boost::int32_t aBillingGroupID,
                                     bool aIsEstimate,
                                     bool aReadAllRatedUsageColumns,
                                     MTPRODUCTCATALOGLib::IMTAggregateChargePtr parentCharge,
                                     MetraTech_UsageServer::IRecurringEventRunContextPtr apRunContext,
                                     std::vector<std::wstring> & aggregateServices,
                                     std::vector<std::wstring> & firstPassProductViews,
                                     std::vector<std::set<std::wstring> >& counters);

}
; 

HRESULT AggregateDataflowPlanGenerator::AddAggregateCharge(
  const std::vector<boost::int32_t>& aUsageIntervalID, 
  boost::int32_t aBillingGroupID,
  bool aIsEstimate,
  bool aReadAllRatedUsageColumns,
  MTPRODUCTCATALOGLib::IMTAggregateChargePtr charge,
  std::set<std::wstring>& counters)
{ 
  _bstr_t firstPassProductView = charge->FirstPassProductView;
  long paramFirstPassViewID = mNameID->GetNameID(firstPassProductView);
  CMSIXDefinition * pv = NULL;
  if (!mProductViews.FindProductView((const wchar_t *) firstPassProductView, pv))
  {
    // TODO: better error handling
    std::string utf8FirstPassProductView;
    ::WideStringToUTF8((const wchar_t *) firstPassProductView, utf8FirstPassProductView);
    mLogger.LogVarArgs(LOG_ERROR, "Product view <%s> not found", utf8FirstPassProductView.c_str());
    return E_FAIL;
  }

  mLogger.LogVarArgs(LOG_DEBUG, "FIRST_PASS_PV_VIEWID = \"%d\"", paramFirstPassViewID);

  std::vector<AggregateRatingCountableSpec> countables;
  std::wstring initializeProgram;
  HRESULT hr = ProcessIncrementalCounters(charge, initializeProgram, counters, countables);
  if (FAILED(hr))
    return hr;

  AggregateRatingUsageSpec usgSpec(pv->GetTableName(), 
                                   paramFirstPassViewID, 
                                   aUsageIntervalID, 
                                   aBillingGroupID,
                                   aIsEstimate,
                                   counters,
                                   initializeProgram,
                                   charge->ID);
  AggregateRating agg(mPlan, usgSpec, countables, aReadAllRatedUsageColumns);

  AggregateRatingScript script(mProgram, usgSpec, countables, aReadAllRatedUsageColumns);

  // serialize the plan 
//   { 
//     std::strstream oss;
//     boost::archive::xml_oarchive oa(oss);
//     // write class instance to archive
//     oa << BOOST_SERIALIZATION_NVP(mPlan);
//     // archive and stream closed when destructors are called
//     mLogger.LogThis(LOG_DEBUG, oss.str());
//   }  

  mAggregateOutputs.push_back(agg.GetOutputPort());
  mProgramOutputs.push_back(script.GetOutputPort());
    
  return S_OK;
}

HRESULT AggregateDataflowPlanGenerator::GenerateForAggregateParent(
  const std::vector<boost::int32_t>& aUsageIntervalID, 
  boost::int32_t aBillingGroupID,
  bool aIsEstimate,
  bool aReadAllUsageColumns,
  MTPRODUCTCATALOGLib::IMTAggregateChargePtr parentCharge,
  MetraTech_UsageServer::IRecurringEventRunContextPtr apRunContext,
  std::vector<std::wstring> & aggregateServices,
  std::vector<std::wstring> & firstPassProductViews,
  std::vector<std::set<std::wstring> >& counters)
{
  aggregateServices.push_back((const wchar_t *)parentCharge->SecondPassServiceDefinition);
  firstPassProductViews.push_back((const wchar_t *)parentCharge->FirstPassProductView);
  counters.push_back(std::set<std::wstring>());
  HRESULT hr = AddAggregateCharge(aUsageIntervalID, aBillingGroupID, aIsEstimate, aReadAllUsageColumns, parentCharge, counters.back());
  if (FAILED(hr))
    return hr;

  //loops over children (if any) 
  MTPRODUCTCATALOGLib::IMTCollectionPtr children = parentCharge->GetChildren();
  long childrenCount = children->Count;
  mLogger.LogVarArgs(LOG_DEBUG, "Aggregate charge is a parent of %d children.", childrenCount); 
  if (apRunContext.GetInterfacePtr() != NULL)
  {
    _bstr_t msg = "Aggregate charge is a parent of ";
    msg += _bstr_t(childrenCount);
    msg += " children";
    apRunContext->RecordInfo(msg);
  }

  for(long i = 1; i <= childrenCount; i++) 
  {
    IMTAggregateChargePtr child = children->GetItem(i);
    aggregateServices.push_back((const wchar_t *)child->SecondPassServiceDefinition);
    firstPassProductViews.push_back((const wchar_t *)child->FirstPassProductView);
    counters.push_back(std::set<std::wstring>());
    if (apRunContext.GetInterfacePtr() != NULL)
    {
      _bstr_t msg = "Processing child aggregate charge '";
      msg += child->Name;
      msg += "' with template ID ";
      msg += _bstr_t(child->ID);
      apRunContext->RecordInfo(msg);
      mLogger.LogThis(LOG_DEBUG, (const char *) msg);
    }
    hr = AddAggregateCharge(aUsageIntervalID, aBillingGroupID, aIsEstimate, aReadAllUsageColumns, child, counters.back());
    if (FAILED(hr))
      return hr;
  }

  return S_OK;
}

HRESULT AggregateDataflowPlanGenerator::ProcessIncrementalCounters(
  MTPRODUCTCATALOGLib::IMTAggregateChargePtr aggCharge, 
  std::wstring& wstrInitializeProgram,
  std::set<std::wstring>& counters,
  std::vector<AggregateRatingCountableSpec>& countables)
{
	try {
		//gets this aggregate charge's cpd collection
		MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr piType = aggCharge->PriceableItemType;
		MTPRODUCTCATALOGLib::IMTCollectionPtr cpdColl = piType->GetCounterPropertyDefinitions();

		MTNAMEIDLib::IMTNameIDPtr nameid(MTPROGID_NAMEID);

    // For our incremental calculation we want to look at the counter set a bit 
    // differently from the old way.  The old ways is to say "given a counter, show
    // me the product view properies that contribute to it".  We want to say: "for a given
    // product view record (countable) give me the counters it contributes to and the expressions/program
    // by which to update those counters".
    // This is because we take the approach of our data flow framework which calculates counters
    // by feeding each countable product view into a shared aggregate operator:
    // 
    //                  ------------------------
    //  ratedUsage ---> |                      | ---> ratedUsageWithCounters
    //                  |                      |
    //  countable1 ---> |    Running Total     |
    //      .           |                      |
    //      .           |      Operator        |
    //      .           |                      |
    //  countableN ---> |                      |
    //                  ------------------------
    //
    // This operator reads each input stream (in timestamp order) and for countables it 
    // increments the value of the counters to which that particular stream contribute.  Got it?
    //
    // So we have to reorganize the counter configuration so that we group the underlying expressions
    // by contributing product view.
    // To do this we associate to each product view the counters to which it contributes and the
    // parameter to product view property bindings for that counter.
    std::vector<AggregateExpressionSpec> exprs;
    map<std::wstring, std::set<std::wstring> > referencedProperties;
    map<std::wstring, long > referencedPVs;

		//iterates through the template's CPD collection 
		long nCPDCount =  cpdColl->Count;
		mLogger.LogVarArgs(LOG_DEBUG, "CPD count = %d", nCPDCount);
		long countableIndex = 0;
		for (int counterIndex = 1; counterIndex <= nCPDCount; counterIndex++) {
			MTPRODUCTCATALOGLib::IMTCounterPropertyDefinitionPtr cpd = cpdColl->GetItem(counterIndex);
			MTPRODUCTCATALOGLib::IMTCounterPtr counter = aggCharge->GetCounter(cpd->GetID());

			if(counter == NULL) {
				mLogger.LogVarArgs(LOG_ERROR, "CPD with ID %d does not have a counter associated with it!", cpd->GetID());
				return E_FAIL;  //TODO: what to do?
			}

      // Extract the counter formula and counter output property.  Save the counter
      // output property.  Parse.
      std::wstring formula = (const wchar_t *) counter->GetFormula(MTPRODUCTCATALOGLib::VIEW_NORMAL);
      std::wstring counterOutput = L"c_";
      counterOutput += (const wchar_t*) cpd->ServiceDefProperty;
      counters.insert(counterOutput);
      std::string utf8Formula;
      std::string utf8CounterOutput;
      ::WideStringToUTF8(formula, utf8Formula);
      ::WideStringToUTF8(counterOutput, utf8CounterOutput);
      exprs.push_back(AggregateExpressionSpec());
      exprs.back().Output = utf8CounterOutput;
      exprs.back().Expression = utf8Formula;

			//gets the counter's parameter collection
			MTPRODUCTCATALOGLib::IMTCollectionPtr paramColl = counter->Parameters;
			long nParamCount = paramColl->Count;

			//
			// iterates through param collection for the current counter
			//
			for (int paramIndex = 1; paramIndex <= nParamCount; paramIndex++) 
      {
				MTCOUNTERLib::IMTCounterParameterPtr param = paramColl->GetItem(paramIndex);

				//if a parameter is just a constant, then don't do anything
				if (param->GetKind() == PARAM_CONST)
					continue;
				
				//if the product view has not yet been added, then lookup info and add it
				std::string tableName = (const char *) param->ProductViewTable;
				if (exprs.back().Binding.find(tableName) == exprs.back().Binding.end()) 
        {
          exprs.back().Binding[tableName] = std::map<std::string,std::pair<std::string,MTPipelineLib::PropValType> >();
          referencedPVs[(const wchar_t *) param->ProductViewTable] = nameid->GetNameID(param->ProductViewName);
				}

        std::string paramMarker = "%%";
        paramMarker += (const char *)param->Name;
        paramMarker += "%%";

				if (param->GetKind() == PARAM_PRODUCT_VIEW_PROPERTY)
        {
          CMSIXDefinition * pvDef;
          if (FALSE==mProductViews.FindProductView((const wchar_t *) param->ProductViewName, pvDef))
          {
            throw std::exception("Couldn't find product view for counter");
          }
          CMSIXProperties * pvPropDef;
          // If we don't find the property name then it belongs to t_acc_usage
          // and therefore must be decimal.
          MTPipelineLib::PropValType ty = MTPipelineLib::PROP_TYPE_DECIMAL;
          if(TRUE==pvDef->FindProperty((const wchar_t *) param->PropertyName, pvPropDef))
          {
            switch(pvPropDef->GetPropertyType())
            {
            case CMSIXProperties::TYPE_INT32:
              ty = MTPipelineLib::PROP_TYPE_INTEGER;
              break;
            case CMSIXProperties::TYPE_FLOAT:
            case CMSIXProperties::TYPE_DOUBLE:
            case CMSIXProperties::TYPE_NUMERIC:
            case CMSIXProperties::TYPE_DECIMAL:
              ty = MTPipelineLib::PROP_TYPE_DECIMAL;
              break;
            case CMSIXProperties::TYPE_INT64:
              ty = MTPipelineLib::PROP_TYPE_BIGINTEGER;
              break;
            case CMSIXProperties::TYPE_TIME:
            case CMSIXProperties::TYPE_ENUM:
            case CMSIXProperties::TYPE_BOOLEAN:
            case CMSIXProperties::TYPE_TIMESTAMP:
            case CMSIXProperties::TYPE_STRING:
            case CMSIXProperties::TYPE_WIDESTRING:
              throw std::exception("Product view property must be of numeric type to be used as a counter parameter");
            }
          }
          exprs.back().Binding[tableName][paramMarker] = std::make_pair((const char *) param->ColumnName,ty);
          referencedProperties[(const wchar_t *) param->ProductViewTable].insert((const wchar_t *)param->ColumnName);
        }
        else
        {
          ASSERT(param->GetKind() == PARAM_PRODUCT_VIEW);
          exprs.back().Binding[tableName][paramMarker] = std::make_pair("*", MTPipelineLib::PROP_TYPE_INTEGER);          
        }
			}
		}

    // Generate the incremental program
    IncrementalAggregateExpression incrementalExpr(exprs);

    // Output the initialize program.
    ::ASCIIToWide(wstrInitializeProgram, incrementalExpr.initialize());

    mLogger.LogThis(LOG_DEBUG,
                    (boost::wformat(L"Counter Initializer Program for Priceable Item Type '%1%': \n %2%") 
                     % (const wchar_t *)piType->Name % wstrInitializeProgram).str().c_str());

    // All counters processed.  Put everything into our countable specs.
    for(map<std::wstring, long >::iterator it = referencedPVs.begin();
        it != referencedPVs.end();
        it++)
    {
      std::string utf8TableName;
      ::WideStringToUTF8(it->first, utf8TableName);
      std::wstring wstrUpdateProgram;
      ::ASCIIToWide(wstrUpdateProgram, incrementalExpr.update(utf8TableName));
      mLogger.LogVarArgs(LOG_DEBUG,
                         (boost::wformat(L"Counter Update Program for Priceable Item Type='%1%', "
                                         L"Countable Product View='%2%', ViewID = %3%: \n %4%")
                          % (const wchar_t *)piType->Name % it->first % 
                          it->second % wstrUpdateProgram).str().c_str());
      countables.push_back(AggregateRatingCountableSpec(it->first, 
                                                        it->second,
                                                        referencedProperties[it->first],
                                                        wstrUpdateProgram));
    }
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }
	
	return S_OK;
}



STDMETHODIMP CMTAggregateCharge::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAggregateCharge,
    &IID_IMTPriceableItem,
    &IID_IMTPCBase
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTAggregateCharge::FinalConstruct()
{
	try {
		HRESULT hr = CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &m_pUnkMarshaler.p);
		if (FAILED(hr))
			return hr;

		//initializes the logger
		LoggerConfigReader configReader;
		mLogger.Init(configReader.ReadConfiguration("ProductCatalog"), "[MTAggregateCharge]");
		
		//loads meta data
		LoadPropertiesMetaData( PCENTITY_TYPE_AGGREGATE_CHARGE );
		
		//sets the kind
		put_Kind( PCENTITY_TYPE_AGGREGATE_CHARGE );
		
		//creates the MTPCCycle instance
		MTPRODUCTCATALOGLib::IMTPCCyclePtr cyclePtr(__uuidof(MTPCCycle));
		PutPropertyObject("Cycle", cyclePtr);



	}	catch (_com_error & err) 
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;	
}

void CMTAggregateCharge::OnSetSessionContext(IMTSessionContext* apSessionContext)
{
	// session context for nested objects can't be set inside the constructor
	// (since this object does not have a session context at the time it constructs its nested objects)
	// so set session context of derived objects now
	// caller will catch any exceptions

	CMTPriceableItem::OnSetSessionContext(apSessionContext); //any base work first
	
	MTPRODUCTCATALOGLib::IMTAggregateChargePtr thisPtr = this;

	thisPtr->Cycle->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apSessionContext));
}


// ----------------------------------------------------------------
// Name:          CopyNonBaseMembersTo
// Arguments:     apPrcItemTarget - PI template or instanc
//                
// Errors Raised: _com_error
// Description:   copy the members that are not in the base class
//                this method can be called for templates or instances
// ----------------------------------------------------------------
void CMTAggregateCharge::CopyNonBaseMembersTo(IMTPriceableItem* apPrcItemTarget)
{
	MTPRODUCTCATALOGLib::IMTAggregateChargePtr self = this;
	MTPRODUCTCATALOGLib::IMTAggregateChargePtr target = apPrcItemTarget;
	
	//copies the cycle
	self->Cycle->CopyTo(target->Cycle);

	//copies counters 
	MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr aggregateChargeType = self->PriceableItemType;
	MTPRODUCTCATALOGEXECLib::IMTCollectionPtr cpdColl = aggregateChargeType->GetCounterPropertyDefinitions();
	int cpdCount = cpdColl->Count;
	for(int i = 1; i <= cpdCount; i++) {
		MTPRODUCTCATALOGLib::IMTCounterPropertyDefinitionPtr cpd = cpdColl->GetItem(i);
		long cpdID = cpd->ID;
		target->SetCounter(cpdID, self->GetCounter(cpdID));
	}
}

STDMETHODIMP CMTAggregateCharge::get_Cycle(IMTPCCycle **pVal) {
	return GetPropertyObject( "Cycle", reinterpret_cast<IDispatch**>(pVal) );
}

STDMETHODIMP CMTAggregateCharge::get_FirstPassProductView(BSTR* pVal) {
	//gets the first pass product view based on the type's service def
	IMTPriceableItemTypePtr piType;
	HRESULT hr = get_PriceableItemType((IMTPriceableItemType**) &piType);
	if (FAILED(hr))
		return hr;
	_bstr_t productView = piType->GetServiceDefinition();
	productView += "_temp"; //first pass product view suffix
	*pVal = productView.copy();
	return hr;
}

STDMETHODIMP CMTAggregateCharge::get_SecondPassServiceDefinition(BSTR* pVal) {
	//gets the second pass service def based on the type's product view
	IMTPriceableItemTypePtr piType;
	HRESULT hr = get_PriceableItemType((IMTPriceableItemType**) &piType);
	if (FAILED(hr))
		return hr;
	_bstr_t serviceDefinition = piType->GetProductView();
	serviceDefinition += "_temp"; //second pass service def suffix
	*pVal = serviceDefinition.copy();
	return hr;
}


STDMETHODIMP CMTAggregateCharge::GetCounter(long aCPDId, IMTCounter** apCounter) {
	try {
		//looks up the counter
		LongToCounterMap::iterator firstOccurence = mCounterMap.find(aCPDId);
		if(firstOccurence == mCounterMap.end()) {
			*apCounter = NULL;
			if(IsValidCounterPropertyDefinitionID(aCPDId))
				return S_OK;
			else
				MT_THROW_COM_ERROR(MTPC_WRONG_COUNTER_PROPERTY_DEFINITION);
		}

		//returns the counter object to the caller
		MTPRODUCTCATALOGLib::IMTCounterPtr counter = firstOccurence->second.GetInterfacePtr();
		counter->AddRef();
		*apCounter = reinterpret_cast<IMTCounter*>(counter.GetInterfacePtr());
	}
	catch(_com_error& err) { return LogAndReturnComError(PCCache::GetLogger(),err);}

	return S_OK;
}

STDMETHODIMP CMTAggregateCharge::SetCounter(long aCPDId, IMTCounter* apCounter) {
	try {
		if(!IsValidCounterPropertyDefinitionID(aCPDId))
			MT_THROW_COM_ERROR( MTPC_WRONG_COUNTER_PROPERTY_DEFINITION );

		MTPRODUCTCATALOGLib::IMTCounterPtr counter(apCounter);

		// first, check, if there was a counter assigned to given property
		LongToCounterMap::iterator firstOccurrence = mCounterMap.find(aCPDId);

		bool bOldCounterExists = (firstOccurrence != mCounterMap.end());
		bool bNewCounterIsNull = (counter == NULL);
		long newCounterID = 0;
		if(!bNewCounterIsNull)
		{
			newCounterID = counter->ID;
		}

		// if there already was a counter, and it is not the same as new one...
		if(bOldCounterExists && (bNewCounterIsNull || (firstOccurrence->second->ID != newCounterID)))
		{
			// move it to the list of old counters, so it will be deleted on Save();
			mOldCounters.push_back(firstOccurrence->second->ID);
		}

		// set new counter in the map
		if(!bNewCounterIsNull)
			mCounterMap[aCPDId] = counter;
		else
			mCounterMap.erase(aCPDId);
	}
	catch(_com_error& err) {return LogAndReturnComError(PCCache::GetLogger(),err);}

	return S_OK;
}


STDMETHODIMP CMTAggregateCharge::get_RemovedCounters(IMTCollection **apColl)
{
	try
	{
    GENERICCOLLECTIONLib::IMTCollectionPtr coll( __uuidof(GENERICCOLLECTIONLib::MTCollection));

		for(LongList::iterator counterId = mOldCounters.begin(); counterId != mOldCounters.end(); counterId++)
		{
			coll->Add(*counterId);
		}
		
		*apColl = reinterpret_cast<IMTCollection*>(coll.Detach());

	}
	catch(_com_error e)
	{
		return e.Error();
	}

	return S_OK;
}


//rates all aggregate usage based on this template for a given interval
//waits for all sessions to commit
STDMETHODIMP CMTAggregateCharge::Rate(long aUsageIntervalID, long aSessionSetSize) 
{
	return RateInternal2(aUsageIntervalID, NULL, true, aSessionSetSize, NULL, false, NULL, NULL, NULL, NULL);
}


//rates all aggregate usage based on this template for a given interval and a given account
//waits for all sessions to commit
STDMETHODIMP CMTAggregateCharge::RateAccount(long aUsageIntervalID, long aAccountID) 
{
	return RateInternal2(aUsageIntervalID, aAccountID, true, 1000, NULL, false, NULL, NULL, NULL, NULL);
}

//rates all aggregate usage based on this template for a given interval and a given account
//does *NOT* wait for all sessions to commit
STDMETHODIMP CMTAggregateCharge::RateAccountAsynch(long aUsageIntervalID, long aAccountID) 
{
	return RateInternal2(aUsageIntervalID, aAccountID, false, 1000, NULL, false, NULL, NULL, NULL, NULL);
}

STDMETHODIMP CMTAggregateCharge::RateForRecurringEvent(long aSessionSetSize,
																											 long aCommitTimeout,
																											 VARIANT_BOOL aFailImmediately,
																											 BSTR aEventName,
																											 IRecurringEventRunContext* apRunContext,
																											 long * apChargesGenerated) 
{
	return RateInternal2(NULL, NULL, true,
											aSessionSetSize, aCommitTimeout, aFailImmediately == VARIANT_TRUE ? true : false,
											aEventName, apRunContext, NULL, apChargesGenerated);
}

STDMETHODIMP CMTAggregateCharge::RateRemoteForRecurringEvent(long aSessionSetSize,
																											 long aCommitTimeout,
																											 VARIANT_BOOL aFailImmediately,
																											 BSTR aEventName,
																											 IRecurringEventRunContext* apRunContext,
																											 IMetraFlowConfig* apMetraFlowConfig,
																											 long * apChargesGenerated) 
{
	return RateInternal2(NULL, NULL, true,
											aSessionSetSize, aCommitTimeout, aFailImmediately == VARIANT_TRUE ? true : false,
											aEventName, apRunContext, apMetraFlowConfig, apChargesGenerated);
}

HRESULT CMTAggregateCharge::RateInternal2(long aUsageIntervalID,
																				 long aAccountID,
																				 bool aWaitForCommit,
																				 long aSessionSetSize,
																				 long aCommitTimeout,
																				 bool aFailImmediately,
																				 BSTR aEventName,
																				 IRecurringEventRunContext* apRunContext,
                                          IMetraFlowConfig* apMetraFlowConfig,
																				 long * apChargesGenerated)
{
	MarkRegion region("AggregateCharge::RateInternal2");

	HRESULT hr;

	try {

		if (apChargesGenerated)
			*apChargesGenerated = 0;

		IMTAggregateChargePtr thisPtr(this);
		MetraTech_UsageServer::IRecurringEventRunContextPtr runContext(apRunContext);

		// gets the usage interval id to operator on
		// either passed in explicitly or given by the event run context
		long intervalID = 0;
		if (apRunContext)
			intervalID = runContext->GetUsageIntervalID();
		else
			intervalID = aUsageIntervalID;

    // Figure out if we are processing multiple intervals.
    std::vector<boost::int32_t> intervalIDs;
    if (intervalID <= 0)
    {
      ASSERT(NULL == apRunContext);
      // Look to the t_agg_interval_arg table
      ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
      rowset->Init("queries\\ProductCatalog");
      rowset->SetQueryTag(L"__GET_AGGREGATE_INTERVAL_ARGS__");
      rowset->Execute();
      while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
      {
        intervalIDs.push_back(rowset->GetValue(L"id_usage_interval"));
        rowset->MoveNext();
      }		
      if (0 == intervalIDs.size()) {
        mLogger.LogVarArgs(LOG_ERROR, "CMTAggregateCharge::RateInternal2 called with empty interval argument table"); 
        return E_FAIL; 
      }
    }
    else
    {
      intervalIDs.push_back(intervalID);
    }


		//only rates if this is a template (not an instance)
		VARIANT_BOOL bTemplate;
		IsTemplate(&bTemplate);
		if (bTemplate == VARIANT_FALSE) {
			mLogger.LogVarArgs(LOG_ERROR, "The Rate method must be called on a template priceable item!"); 
			return E_FAIL; 
		}

		//only parents can be rated (parents will recursively rate the children)
		if (thisPtr->GetParent()) {
			mLogger.LogVarArgs(LOG_ERROR, "The Rate method must be called on the parent of this priceable item!"); 
			return E_FAIL; 
		}

		//
		// deletes records from second pass product view (and all children)
		//
		IMTPriceableItemTypePtr piType = thisPtr->PriceableItemType;
		_bstr_t secondPassProductView = piType->GetProductView();

		MarkEnterRegion("RemovePVRecords");
		hr = RemovePVRecords(intervalID, aAccountID, apRunContext);
		if(FAILED(hr))
			return hr;
		MarkExitRegion("RemovePVRecords");

    //
    // Set up the batch.  We use meter rowset for some of the batch stuff even
    // though we meter with the dataflow framework.
    //
		METERROWSETLib::IMeterRowsetPtr meterRowset("MetraTech.MeterRowset");
		meterRowset->InitSDK("AggregateRatingServer");

		_bstr_t batchID = "";
		if (apRunContext)
		{
			MarkRegion region("CreateAdapterBatch");

			METERROWSETLib::IBatchPtr batch = meterRowset->CreateAdapterBatch(runContext->RunID,
																																				aEventName,
																																				thisPtr->Name);
			batchID = batch->GetUID();
		}
		else
		{
			batchID = meterRowset->GenerateBatchID();
		}
		std::vector<unsigned char> collectionID(16);
		MSIXUidGenerator::Decode(&collectionID[0], (const char *) (batchID));

    // 
    // Generate the dataflow program
    //

		// TODO: Adds the special _IntervalID property (only on the parent) so that the remetered
		// usage does not go into the currently open interval (because the
		// adapter is run after the interval has closed).

		// If this is not being run as part of EOP processing, then just use the default
		// interval guiding (CR9065)
// 		if (apRunContext)
// 			meterRowset->AddCommonProperty("_IntervalId", METERROWSETLib::MTC_DT_INT, intervalID);

    bool readAllUsageRecords(true);
    DesignTimePlan plan;
    std::vector<std::wstring> aggregateServices;
    std::vector<std::wstring> firstPassProductViews;
    std::vector<std::set<std::wstring> > counters;
    std::wstring program;
    AggregateDataflowPlanGenerator generator(mLogger,plan, program);
    hr = generator.GenerateForAggregateParent(intervalIDs,
                                              apRunContext ? runContext->BillingGroupID : -1,
                                              apRunContext ? false : true,
                                              readAllUsageRecords,
                                              thisPtr,
                                              apRunContext,
                                              aggregateServices,
                                              firstPassProductViews,
                                              counters);

    if (FAILED(hr))
      return hr;

    // Add the metering operator and glue it in.
    std::wstring services;
    for(std::vector<std::wstring>::const_iterator it=aggregateServices.begin();
        it != aggregateServices.end();
        ++it)
    {
      services += (boost::wformat(L", service=\"%1%\"") % (*it)).str();
    }
    // write collection id in hex
    std::wstring hexFormat(L"0123456789ABCDEF");
    wchar_t uid[35];
    uid[0] = L'0';
    uid[1] = L'x';
    for(int i=0; i<16; i++)
    {
      uid[2*i + 2] = hexFormat[(collectionID[i] & 0xF0) >> 4];
      uid[2*i + 3] = hexFormat[(collectionID[i] & 0x0F)];
    }
    uid[34] = 0;
    program += (boost::wformat(L"meter[targetMessageSize=%1%, targetCommitSize=20000, collectionID=%2%%3%];") % 
                aSessionSetSize % uid % services).str();
    for(std::size_t i=0; i<generator.GetProgramOutputs().size(); i++)
    {
      program += (boost::wformat(L"%1% -> meter(%2%);\n") % generator.GetProgramOutputs()[i] % i).str();
    }

    // Log the MFS script.
    mLogger.LogThis(LOG_DEBUG, program.c_str());

    MetraTech_UsageServer::IMetraFlowRunPtr mf(__uuidof(MetraTech_UsageServer::MetraFlowRun));
    _bstr_t bstrProgram(program.c_str());
    _bstr_t bstrLoggerTag(L"[MTAggregateCharge]");
    long ret = mf->Run(bstrProgram, bstrLoggerTag, reinterpret_cast<MetraTech_UsageServer::IMetraFlowConfig *>(apMetraFlowConfig));
    if (ret != 0)
    {
      if(apRunContext) 
      {
        runContext->RecordWarning("MetraFlow failed while calculating aggregate counters");
      }
      mLogger.LogThis(LOG_ERROR, "MetraFlow failed while calculating aggregate counters");
      return E_FAIL;
    }

		long meteredRecords;
		long errorRecords = 0;

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init("queries\\ProductCatalog");
    rowset->SetQueryTag(L"__GET_AGGREGATE_METERING_COUNT__");
    rowset->Execute();
    _variant_t nullVariant;
    nullVariant.ChangeType(VT_NULL);
    _variant_t val = rowset->GetValue(L"cnt");
    if (nullVariant == val)
      meteredRecords = 0;
    else
      meteredRecords = (long) val;


//     // Hook up the metering to the aggregate rating outputs.
//     // Do our metering using a private staging area for just our services
//     boost::shared_ptr<DatabaseMeteringStagingDatabase> stagingArea(
//       readAllUsageRecords ?
//       new DatabaseMeteringStagingDatabase(aggregateServices, DatabaseMeteringStagingDatabase::STREAMING) :
//       new DatabaseMeteringStagingDatabase(aggregateServices, firstPassProductViews, counters, DatabaseMeteringStagingDatabase::STREAMING));
//     boost::shared_ptr<Metering> meter(
//       readAllUsageRecords ?
//       new Metering() :
//       new AggregateMetering(counters));
//     meter->SetCollectionID(uid);
//     meter->SetServices(aggregateServices);
//     meter->SetTargetMessageSize(aSessionSetSize);
//     meter->SetTargetCommitSize(20000);
//     meter->Generate(plan, stagingArea);
//     ASSERT(generator.GetAggregateOutputs().size() == meter->GetInputPorts().size());
//     for(std::size_t i=0; i<generator.GetAggregateOutputs().size(); i++)
//     {
//       plan.push_back(new DesignTimeChannel(generator.GetAggregateOutputs()[i], meter->GetInputPorts()[i]));
//     }
//     // Here is a (testing) option to just run things into dev null.
//     for(std::size_t i=0; i<generator.GetAggregateOutputs().size(); i++)
//     {
//       DesignTimeDevNull * devNull = new DesignTimeDevNull();
//       devNull->SetName((boost::wformat(L"devNull(%1%)") % i).str());
//       plan.push_back(devNull);
//       plan.push_back(new DesignTimeChannel(generator.GetAggregateOutputs()[i], devNull->GetInputPorts()[0]));
//     }

    // Here is a (testing) option to just stick identifiers on records and land
    // into the database.
//     for(std::size_t i=0; i<generator.GetAggregateOutputs().size(); i++)
//     {
//       DesignTimeExpressionGenerator * generateID = new DesignTimeExpressionGenerator();
//       generateID->SetName((boost::wformat(L"generateID(%1%)") % i).str());
//       generateID->SetProgram(
//         L"CREATE PROCEDURE set_identity @RecordID BIGINT OUTPUT\n"
//         L"AS\n"
//         L"SET @RecordID = @@RECORDCOUNT*CAST(@@PARTITIONCOUNT AS BIGINT) + CAST(@@PARTITION AS BIGINT)\n");
//       plan.push_back(generateID);
//       plan.push_back(new DesignTimeChannel(generator.GetAggregateOutputs()[i], generateID->GetInputPorts()[0]));
//       DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
//       insert->SetName((boost::wformat(L"generateID(%1%)") % i).str());
//       insert->SetCreateTable(true);
//       insert->SetTableName((boost::wformat(L"dbg_aggregate_running_total_%1%") % i).str());
//       insert->SetBatchSize(10000);
//       plan.push_back(insert);
//       plan.push_back(new DesignTimeChannel(generateID->GetOutputPorts()[0], insert->GetInputPorts()[0]));
//     }

//     plan.type_check();
//     // Run one partition per processor.
//     SYSTEM_INFO si;
//     ::GetSystemInfo(&si);
//     mLogger.LogVarArgs(LOG_INFO, "Aggregate rating detected %d processor(s), running %d partition(s)", si.dwNumberOfProcessors, si.dwNumberOfProcessors);
//     ParallelPlan pplan(si.dwNumberOfProcessors);
//     plan.code_generate(pplan);



//     //
//     // Run the dataflow to populate the staging database.
//     //
//     std::vector<boost::int32_t> numRecords;
//     stagingArea->Start(pplan, numRecords);
//     // Should have two inserts for each service/t_svc/t_session + one each for t_session_set and t_message.
//     // HACK (sort of): Assumption is that the parent service is inserted 1st so we can use numRecords[0]
//     // as the number of compounds metered!  Note that when we are doing streaming inserts, the dataflow
//     // itself records info about number of sessions metering into logging tables. In that case, we go there
//     // to get the counts.

    
//     // Cram the info about metered records into meter rowset object.

// 		long meteredRecords;
// 		long errorRecords = 0;
//     if (DatabaseMeteringStagingDatabase::STREAMING==stagingArea->GetStagingMethod())
//     {
//       ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
//       rowset->Init("queries\\ProductCatalog");
//       rowset->SetQueryTag(L"__GET_AGGREGATE_METERING_COUNT__");
//       rowset->Execute();
//       _variant_t nullVariant;
//       nullVariant.ChangeType(VT_NULL);
//       _variant_t val = rowset->GetValue(L"cnt");
//       if (nullVariant == val)
//         meteredRecords = 0;
//       else
//         meteredRecords = (long) val;
//     }
//     else
//     {
//       ASSERT(numRecords.size() == 2*aggregateServices.size() + 2);
//       meteredRecords = numRecords[0];		
//     }
		//
		// waits until all sessions commit
		//
		if (aWaitForCommit) 
		{
			if (apRunContext)
			{
				_bstr_t msg = "Waiting for sessions to commit (timeout = ";
				msg += _bstr_t(aCommitTimeout);
				msg += " seconds)";
				runContext->RecordInfo(msg);
			}
			meterRowset->WaitForCommit(meteredRecords, aCommitTimeout);
		}

		if (apRunContext)
		{
			runContext->RecordInfo("All sessions have been committed");

			if (apChargesGenerated)
				*apChargesGenerated = meterRowset->CommittedSuccessCount;

			if (meterRowset->CommittedErrorCount > 0)
			{
				_bstr_t msg = _bstr_t(meterRowset->CommittedErrorCount);
				msg += " sessions failed during pipeline processing!";
				MT_THROW_COM_ERROR((const char *) msg);
			}
		}
	}	
	catch (_com_error & err)
	{ 
    return LogAndReturnComError(mLogger, err); 
  }
	catch (std::exception & e)
	{ 
    mLogger.LogVarArgs(LOG_ERROR, "Exception in CMTAggregateCharge::RateInternal2: %s", e.what());
    return E_FAIL; 
  }

	return S_OK;
}

HRESULT CMTAggregateCharge::RateInternal(long aUsageIntervalID,
																				 long aAccountID,
																				 bool aWaitForCommit,
																				 long aSessionSetSize,
																				 long aCommitTimeout,
																				 bool aFailImmediately,
																				 BSTR aEventName,
																				 IRecurringEventRunContext* apRunContext,
																				 long * apChargesGenerated)
{
	MarkRegion region("AggregateCharge::RateInternal");

	HRESULT hr;

	try {

		if (apChargesGenerated)
			*apChargesGenerated = 0;

		IMTAggregateChargePtr thisPtr(this);
		MetraTech_UsageServer::IRecurringEventRunContextPtr runContext(apRunContext);

		// gets the usage interval id to operator on
		// either passed in explicitly or given by the event run context
		long intervalID = 0;
		if (apRunContext)
			intervalID = runContext->GetUsageIntervalID();
		else
			intervalID = aUsageIntervalID;


		//only rates if this is a template (not an instance)
		VARIANT_BOOL bTemplate;
		IsTemplate(&bTemplate);
		if (bTemplate == VARIANT_FALSE) {
			mLogger.LogVarArgs(LOG_ERROR, "The Rate method must be called on a template priceable item!"); 
			return E_FAIL; 
		}

		//
		// deletes records from second pass product view (and all children)
		//
		IMTPriceableItemTypePtr piType = thisPtr->PriceableItemType;
		_bstr_t secondPassProductView = piType->GetProductView();

		MarkEnterRegion("RemovePVRecords");
		hr = RemovePVRecords(intervalID, aAccountID, apRunContext);
		if(FAILED(hr))
			return hr;
		MarkExitRegion("RemovePVRecords");

		//
		// executes the aggregation sproc and query
		//
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init("queries\\ProductCatalog\\AggregateRating");

		//only parents can be rated (parents will recursively rate the children)
		if (thisPtr->GetParent()) {
			mLogger.LogVarArgs(LOG_ERROR, "The Rate method must be called on the parent of this priceable item!"); 
			return E_FAIL; 
		}

		std::vector<_bstr_t> dropTableQueries;
		_bstr_t dropTable1Query;
		_bstr_t dropTable2Query;
		MarkEnterRegion("ExecuteQuery");
		hr = ExecuteQuery((ROWSETLib::IMTSQLRowset*) rowset, intervalID, aAccountID, false, apRunContext,
											dropTable1Query, dropTable2Query);
		MarkExitRegion("ExecuteQuery");
		dropTableQueries.push_back(dropTable1Query);
		dropTableQueries.push_back(dropTable2Query);

		if (FAILED(hr)) {
			mLogger.LogVarArgs(LOG_ERROR, "ExecuteQuery failed! hr = %x", hr); 
			return hr;
		}

		// avoids metering when unnecessary
		MarkEnterRegion("CheckRecordCount");
		if (rowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
		{
			mLogger.LogVarArgs(LOG_INFO, "No usage to rate, not metering to second pass.");
			if (apRunContext)
				runContext->RecordInfo("No usage to rate, not metering to second pass.");
			MarkExitRegion("CheckRecordCount");
			return S_OK;
		}
		MarkExitRegion("CheckRecordCount");
		

		//
		// meters the returned rows as sessions
		// 
		METERROWSETLib::IMeterRowsetPtr meterRowset("MetraTech.MeterRowset");
		meterRowset->InitSDK("AggregateRatingServer");

		BSTR str;
		HRESULT hr = get_SecondPassServiceDefinition(&str);
		if (FAILED(hr))
			return hr;
		bstr_t secondPassServiceDef(str, false);

		meterRowset->InitForService((char*) secondPassServiceDef);

		_bstr_t batchID = "";
		if (apRunContext)
		{
			MarkRegion region("CreateAdapterBatch");

			METERROWSETLib::IBatchPtr batch = meterRowset->CreateAdapterBatch(runContext->RunID,
																																				aEventName,
																																				thisPtr->Name);
			batchID = batch->GetUID();
		}
		else
		{
			batchID = meterRowset->GenerateBatchID();
		}

		meterRowset->SessionSetSize = aSessionSetSize;
	

		// Adds the special _IntervalID property so that the remetered
		// usage does not go into the currently open interval (because the
		// adapter is run after the interval has closed).

		// If this is not being run as part of EOP processing, then just use the default
		// interval guiding (CR9065)
		if (apRunContext)
			meterRowset->AddCommonProperty("_IntervalId", METERROWSETLib::MTC_DT_INT, intervalID);

		//maps the dt_session column to the second pass service def property OriginalSessionTimestamp
		meterRowset->AddColumnMapping("c_SessionDate", METERROWSETLib::MTC_DT_WCHAR,
																	"OriginalSessionTimestamp", VARIANT_TRUE);
		
		// map the session ID so we can relate sessions back to their 
		meterRowset->AddColumnMapping("id_sess", METERROWSETLib::MTC_DT_BIGINT, "_firstpassid", VARIANT_TRUE);

		//loops over children (if any) forcing them to execute their own query
		MTPRODUCTCATALOGLib::IMTCollectionPtr children = thisPtr->GetChildren();
		long childrenCount = children->Count;
		mLogger.LogVarArgs(LOG_DEBUG, "Aggregate charge is a parent of %d children.", childrenCount); 
		if (apRunContext)
		{
			_bstr_t msg = "Aggregate charge is a parent of ";
			msg += _bstr_t(childrenCount);
			msg += " children";
			runContext->RecordInfo(msg);
		}
		for(long i = 1; i <= childrenCount; i++) 
		{
			IMTAggregateChargePtr child = children->GetItem(i);

			if (apRunContext)
			{
				_bstr_t msg = "Processing child aggregate charge '";
				msg += child->Name;
				msg += "' with template ID ";
				msg += _bstr_t(child->ID);
				runContext->RecordInfo(msg);
				mLogger.LogThis(LOG_DEBUG, (const char *) msg);
			}

			// executes the aggregation sproc and query on the child
			BSTR bstrDropChildTable1Query;
			BSTR bstrDropChildTable2Query;
			ROWSETLib::IMTSQLRowsetPtr childRowset;
			childRowset = child->GetRowsetForParent(intervalID, aAccountID, 
																							(MTPRODUCTCATALOGLib::IRecurringEventRunContext *) apRunContext,
																							&bstrDropChildTable1Query, &bstrDropChildTable2Query);
			_bstr_t dropChildTable1Query(bstrDropChildTable1Query, false);
			_bstr_t dropChildTable2Query(bstrDropChildTable2Query, false);
			dropTableQueries.push_back(dropChildTable1Query);
			dropTableQueries.push_back(dropChildTable2Query);


			meterRowset->AddChildRowset((METERROWSETLib::IMTSQLRowsetPtr) childRowset, child->GetSecondPassServiceDefinition());

			// maps the dt_session column to the second pass service def property OriginalSessionTimestamp
			meterRowset->AddChildColumnMapping("c_SessionDate", METERROWSETLib::MTC_DT_WCHAR,
																				 "OriginalSessionTimestamp", VARIANT_TRUE, child->GetSecondPassServiceDefinition());
		}
		

		//
		// meters all the results
		//
		if (apRunContext)
		{
			_bstr_t msg = "Metering results to second pass service definition '";
			msg += secondPassServiceDef;
			msg += "'";
			runContext->RecordInfo(msg);
		}
		mLogger.LogVarArgs(LOG_INFO, "Metering the results to the second pass stage"); 
		meterRowset->MeterRowset((METERROWSETLib::IMTSQLRowsetPtr) rowset);

		long meteredRecords = meterRowset->MeteredCount;
		long errorRecords = meterRowset->MeterErrorCount;
		
		if (apRunContext)
		{
			_bstr_t msg = _bstr_t(meteredRecords);
			msg += " sessions were metered";
			runContext->RecordInfo(msg);

			if (errorRecords > 0)
			{
				_bstr_t msg = _bstr_t(errorRecords);
				msg += " sessions failed to meter (client side)! The adapter will need to be run again.";
				MT_THROW_COM_ERROR((const char *) msg);
			}
		}

		//
		// drops the "temp" tables
		//
		if (apRunContext)
			runContext->RecordInfo("Dropping temporary aggregation tables");
		mLogger.LogThis(LOG_DEBUG, "Dropping temporary aggregation tables"); 
		ROWSETLib::IMTSQLRowsetPtr cleanupRowset(MTPROGID_SQLROWSET);
		cleanupRowset->Init("queries\\ProductCatalog\\AggregateRating");
		vector<_bstr_t>::iterator it = dropTableQueries.begin();
		while(it != dropTableQueries.end())
		{
			_bstr_t dropQuery = *it++;
			mLogger.LogVarArgs(LOG_DEBUG, "Dropping table: %s", (const char *) dropQuery); 
			cleanupRowset->SetQueryString(dropQuery);
			cleanupRowset->Execute();
			cleanupRowset->Clear();
		}
		
		//
		// waits until all sessions commit
		//
		if (aWaitForCommit) 
		{
			if (apRunContext)
			{
				_bstr_t msg = "Waiting for sessions to commit (timeout = ";
				msg += _bstr_t(aCommitTimeout);
				msg += " seconds)";
				runContext->RecordInfo(msg);
			}
			meterRowset->WaitForCommit(meteredRecords, aCommitTimeout);
		}

		if (apRunContext)
		{
			runContext->RecordInfo("All sessions have been committed");

			if (apChargesGenerated)
				*apChargesGenerated = meterRowset->CommittedSuccessCount;

			if (meterRowset->CommittedErrorCount > 0)
			{
				_bstr_t msg = _bstr_t(meterRowset->CommittedErrorCount);
				msg += " sessions failed during pipeline processing!";
				MT_THROW_COM_ERROR((const char *) msg);
			}
		}
	}	
	catch (_com_error & err)
	{ return LogAndReturnComError(mLogger, err); }

	return S_OK;
}


// *** FOR INTERNAL USE ONLY ***
//called by a parent AggregateCharge on a child, returns a rowset to the parent in
//which the parent will meter as part of a compound session.
STDMETHODIMP CMTAggregateCharge::GetRowsetForParent(long aUsageIntervalID, long aAccountID,
																										IRecurringEventRunContext* apRunContext,
																										BSTR * apDropChildTable1Query,
																										BSTR * apDropChildTable2Query,
																										/*[out, retval]*/ ::IMTSQLRowset** apRowset)
{
	HRESULT hr;
	try 
	{ 
		MetraTech_UsageServer::IRecurringEventRunContextPtr runContext(apRunContext);

		MTPRODUCTCATALOGLib::IMTAggregateChargePtr thisPtr = this;
		IMTPriceableItemTypePtr piType = thisPtr->PriceableItemType;
		_bstr_t secondPassProductView = piType->GetProductView();

		_bstr_t dropChildTable1Query;
		_bstr_t dropChildTable2Query;
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init("queries\\ProductCatalog\\AggregateRating");
		hr = ExecuteQuery(rowset.GetInterfacePtr(), aUsageIntervalID, aAccountID, true, apRunContext,
											dropChildTable1Query, dropChildTable2Query);
		*apDropChildTable1Query = dropChildTable1Query.copy();
		*apDropChildTable2Query = dropChildTable2Query.copy();

		if (FAILED(hr)) 
		{
			mLogger.LogVarArgs(LOG_ERROR, "ExecuteQuery failed! hr = %x", hr); 
			return hr;
		}

		*apRowset = reinterpret_cast<::IMTSQLRowset*>(rowset.Detach());
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }
	
	return S_OK;
}


bool CMTAggregateCharge::IsValidCounterPropertyDefinitionID(long lCounterPropertyDefinitionID)
{
	return true;
	// TODO: copy from discount when implemented there
}


HRESULT CMTAggregateCharge::ExecuteQuery(ROWSETLib::IMTSQLRowset* apRowset,
																				 long aUsageIntervalID, long aAccountID,
																				 bool aChild,
																				 IRecurringEventRunContext* apRunContext,
																				 _bstr_t & dropTable1Query,
																				 _bstr_t & dropTable2Query)
{
	HRESULT hr;
	bool bIsOracle = FALSE;
	unsigned int i;
	std::string logBuffer;
	
	try	{
		MetraTech_UsageServer::IRecurringEventRunContextPtr runContext(apRunContext);
		ROWSETLib::IMTSQLRowsetPtr rowset(apRowset);

		_bstr_t dbtype = rowset->GetDBType() ;

		// oracle database?
		bIsOracle = (mtwcscasecmp(dbtype, ORACLE_DATABASE_TYPE) == 0);

		// extracts useful information from the counters
		std::vector<std::string> counterFormulas, counterFormulaAliases;
		std::map<std::string, std::string> countableProductViews, countableProperties;
		mLogger.LogThis(LOG_DEBUG, "Processing aggregate counters");
		hr = ProcessCounters(counterFormulas, 
												 countableProductViews,
												 countableProperties,
												 counterFormulaAliases);
		if (FAILED(hr))
			return hr;


		//
		// counter formulas, counter formula aliases
		//
		std::string paramCounterFormulas;
		std::string paramCounterFormulaAliases;
		for (i = 0; i < counterFormulas.size(); i++)
		{
			paramCounterFormulas += ", " + counterFormulas[i];
			paramCounterFormulaAliases += ", tp2." + counterFormulaAliases[i];
		}

		// NOTE: uses LogThis instead of LogVarArgs because the latter cannot 
		// correctly log large strings
		logBuffer = "COUNTER_FORMULAS = \"" + paramCounterFormulas + "\"";
		mLogger.LogThis(LOG_DEBUG, logBuffer.c_str());
		logBuffer = "COUNTER_FORMULAS_ALIASES = \"" + paramCounterFormulaAliases + "\"";
		mLogger.LogThis(LOG_DEBUG, logBuffer.c_str()); 


		//
		// countable outer joins and countable view id's
		//
		std::string paramCountableJoins;
		std::string paramCountableViewIDs;
		std::map<std::string, std::string>::iterator pvIt;
		for (pvIt = countableProductViews.begin(); pvIt != countableProductViews.end(); ++pvIt)
		{
			if (pvIt != countableProductViews.begin())
				paramCountableViewIDs += ", ";
			paramCountableViewIDs += pvIt->second;

			paramCountableJoins += " LEFT OUTER JOIN ";
			paramCountableJoins += pvIt->first;  //the actual countable's product view
			paramCountableJoins += " ON ";
			paramCountableJoins += pvIt->first;
			paramCountableJoins += ".id_sess = au.id_sess ";

		}

		logBuffer = "COUNTABLE_OJOINS = \"" + paramCountableJoins + "\"";
		mLogger.LogThis(LOG_DEBUG, logBuffer.c_str()); 
		mLogger.LogVarArgs(LOG_DEBUG, "COUNTABLE_VIEWIDS = \"%s\"", paramCountableViewIDs.c_str());


		//
		// countable properties
		//
		std::string paramCountableProperties;
		for (std::map<std::string, std::string>::iterator it = countableProperties.begin();
				 it != countableProperties.end(); ++it)
		{
			paramCountableProperties += ", ";
			paramCountableProperties += it->first;  // original table/column name: "t_pv_songdownloads_temp.blah"
			paramCountableProperties += " as ";
			paramCountableProperties += it->second; // unique countable alias: "countable_1"
		}
		logBuffer = "COUNTABLE_PROPERTIES = \"" + paramCountableProperties + "\"";
		mLogger.LogThis(LOG_DEBUG, logBuffer.c_str()); 


		//
		// first pass product view table
		//
		std::string paramFirstPassTable;
		BSTR str;
		hr = get_FirstPassProductView(&str);
		if (FAILED(hr))
			return hr;
		bstr_t firstPassProductView(str, false);
		std::vector<std::string> firstPassColumns;
		hr = GetProductViewProps((char*) firstPassProductView, paramFirstPassTable, firstPassColumns);
		if (FAILED(hr))
			return hr;
		mLogger.LogVarArgs(LOG_DEBUG, "FIRST_PASS_PV_TABLE = \"%s\"", paramFirstPassTable.c_str());
		
		//
		// first pass product view properties
		//
		std::string paramFirstPassPropsAliased;
		for (i = 0; i < firstPassColumns.size(); i++) 
		{
			paramFirstPassPropsAliased += ", firstpasspv.";
			paramFirstPassPropsAliased += firstPassColumns[i];
			paramFirstPassPropsAliased += " as ";
			paramFirstPassPropsAliased += firstPassColumns[i];
		}

		logBuffer = "FIRST_PASS_PV_PROPERTIES_ALIASED = \"" + paramFirstPassPropsAliased + "\"";
		mLogger.LogThis(LOG_DEBUG, logBuffer.c_str()); 


		//
    // first pass product view's view ID
		//
		long paramFirstPassViewID;
		MTNAMEIDLib::IMTNameIDPtr nameid(MTPROGID_NAMEID);
		paramFirstPassViewID = nameid->GetNameID(firstPassProductView);
		mLogger.LogVarArgs(LOG_DEBUG, "FIRST_PASS_PV_VIEWID = \"%d\"", paramFirstPassViewID);


		//
		// account filter
		//
		std::string paramAccountFilter;
		char buffer[256];
		if (aAccountID) {
			paramAccountFilter = "and au.id_acc = ";
			sprintf(buffer, "%d", aAccountID);
			paramAccountFilter += buffer;
		}
		mLogger.LogVarArgs(LOG_DEBUG, "ACCOUNT_FILTER = \"%s\"", paramAccountFilter.c_str());


		//
		// usage interval ID
		//
		long paramUsageInterval = aUsageIntervalID;
		mLogger.LogVarArgs(LOG_DEBUG, "USAGE_INTERVAL = \"%d\"", paramUsageInterval);


		//
		// aggregate charge's template ID
		//
		long paramTemplateID;
		get_ID(&paramTemplateID);
		mLogger.LogVarArgs(LOG_DEBUG, "TEMPLATE_ID = \"%d\"", paramTemplateID);


		//
		// compound ordering 
		//
		std::string paramCompoundOrdering;
		if (aChild) 
			// this ordering is required to work with MeterRowset's compound support 
			paramCompoundOrdering = "au.id_parent_sess, ";
		else
			paramCompoundOrdering = "au.id_sess, ";
		mLogger.LogVarArgs(LOG_DEBUG, "COMPOUND_ORDERING = \"%s\"", paramCompoundOrdering.c_str());


		//
		// sets up the stored procedure (this is ugly!)
		//
		rowset->Clear();
		rowset->InitializeForStoredProc("MTSP_RATE_AGGREGATE_CHARGE");

		_variant_t vt_null;
		vt_null.ChangeType(VT_NULL);

		// input parameters
		rowset->AddInputParameterToStoredProc("input_RUN_ID",
																					MTTYPE_INTEGER,
																					INPUT_PARAM,
																					apRunContext ? _variant_t(runContext->RunID) : vt_null);
		rowset->AddInputParameterToStoredProc("input_USAGE_INTERVAL",
																					MTTYPE_INTEGER,
																					INPUT_PARAM,
																					_variant_t(paramUsageInterval));
		rowset->AddInputParameterToStoredProc("input_BILLING_GROUP_ID",
																					MTTYPE_INTEGER,
																					INPUT_PARAM,
																					apRunContext ? _variant_t(runContext->BillingGroupID) : vt_null);
		rowset->AddInputParameterToStoredProc("input_TEMPLATE_ID",
																					MTTYPE_INTEGER,
																					INPUT_PARAM,
																					_variant_t(paramTemplateID));
		rowset->AddInputParameterToStoredProc("input_FIRST_PASS_PV_VIEWID", 
																					MTTYPE_INTEGER,
																					INPUT_PARAM,
																					_variant_t(paramFirstPassViewID));
		rowset->AddInputParameterToStoredProc("input_FIRST_PASS_PV_TABLE",
																					MTTYPE_VARCHAR,
																					INPUT_PARAM,
																					_variant_t(paramFirstPassTable.c_str()));
		rowset->AddInputParameterToStoredProc("input_COUNTABLE_VIEWIDS",
																					MTTYPE_VARCHAR,
																					INPUT_PARAM,
																					_variant_t(paramCountableViewIDs.c_str()));
		rowset->AddInputParameterToStoredProc("input_COUNTABLE_OJOINS",
																					MTTYPE_VARCHAR,
																					INPUT_PARAM,
																					_variant_t(paramCountableJoins.c_str()));
		rowset->AddInputParameterToStoredProc("input_1STPASSPV_PROPS_ALIASED",
																					MTTYPE_VARCHAR,
																					INPUT_PARAM,
																					_variant_t(paramFirstPassPropsAliased.c_str()));
		rowset->AddInputParameterToStoredProc("input_COUNTABLE_PROPERTIES",
																					MTTYPE_VARCHAR,
																					INPUT_PARAM,
																					_variant_t(paramCountableProperties.c_str()));
		rowset->AddInputParameterToStoredProc("input_COUNTER_FORMULAS",
																					MTTYPE_VARCHAR,
																					INPUT_PARAM,
																					_variant_t(paramCounterFormulas.c_str()));
		rowset->AddInputParameterToStoredProc("input_ACCOUNT_FILTER",
																					MTTYPE_VARCHAR,
																					INPUT_PARAM,
																					_variant_t(paramAccountFilter.c_str()));
		rowset->AddInputParameterToStoredProc("input_COMPOUND_ORDERING",
																					MTTYPE_VARCHAR,
																					INPUT_PARAM,
																					_variant_t(paramCompoundOrdering.c_str()));
		rowset->AddInputParameterToStoredProc("input_COUNTER_FORMULAS_ALIASES",
																					MTTYPE_VARCHAR,
																					INPUT_PARAM,
																					_variant_t(paramCounterFormulaAliases.c_str()));

		// output parameters
		rowset->AddOutputParameterToStoredProc("output_SQLStmt_SELECT", MTTYPE_VARCHAR, OUTPUT_PARAM);
		rowset->AddOutputParameterToStoredProc("output_SQLStmt_DROPTMPTBL1", MTTYPE_VARCHAR, OUTPUT_PARAM);
		rowset->AddOutputParameterToStoredProc("output_SQLStmt_DROPTMPTBL2", MTTYPE_VARCHAR, OUTPUT_PARAM);
		rowset->AddOutputParameterToStoredProc("return_code", MTTYPE_INTEGER, OUTPUT_PARAM);

		if (apRunContext)
			runContext->RecordInfo("Executing the aggregation stored procedure");
		mLogger.LogThis(LOG_DEBUG, "Executing the aggregation stored procedure"); 

		rowset->ExecuteStoredProc();	

		// checks for failure
		_variant_t status = rowset->GetParameterFromStoredProc("return_code");
		if ((long) status == -1)
			return Error("The aggregation stored procedure failed!");

		if (apRunContext)
			runContext->RecordInfo("Aggregation stored procedure completed successfully");

		// the stored procedure returns 3 queries for us to execute:
		//    1) the final aggregation query (goes against temp tables created by the sproc)
		//    2) drop a temp table
		//    3) drop another temp table
		_bstr_t aggregationQuery = rowset->GetParameterFromStoredProc("output_SQLStmt_SELECT");
		dropTable1Query = rowset->GetParameterFromStoredProc("output_SQLStmt_DROPTMPTBL1");
		dropTable2Query = rowset->GetParameterFromStoredProc("output_SQLStmt_DROPTMPTBL2");

		
		// executes the final aggregation query (this will be returned to the caller)
		rowset->Clear();
		rowset->SetQueryString(aggregationQuery);

		if (apRunContext)
			runContext->RecordInfo("Executing the aggregation query");
		mLogger.LogThis(LOG_DEBUG, "Executing the aggregation query"); 

		rowset->ExecuteConnected();

		if (apRunContext)
			runContext->RecordInfo("Aggregation query completed successfully");

	}	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}


HRESULT CMTAggregateCharge::GetProductViewProps(const char * apProductViewName,
																								std::string& arTableName,
																								std::vector<std::string>& arProperties)
{
	
	try {
		CProductViewCollection productViews;
		productViews.Initialize();

		CMSIXDefinition * pv = NULL;
		if (!productViews.FindProductView((wchar_t*) _bstr_t(apProductViewName), pv))
		{
			// TODO: better error handling
			mLogger.LogVarArgs(LOG_ERROR, 
												 "Product view <%s> not found", apProductViewName);
			return Error("Product view not found");
		}

		arTableName = ascii(pv->GetTableName());

		MSIXPropertiesList props = pv->GetMSIXPropertiesList();
		MSIXPropertiesList::iterator it;
		for (it = props.begin(); it != props.end(); ++it)
		{
			CMSIXProperties * prop = *it;
			string columnName = ascii(prop->GetColumnName()); //converts from wchar_t
			arProperties.push_back(columnName);
		}
	}	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }
	
	return S_OK;
}

HRESULT CMTAggregateCharge::ProcessCounters(std::vector<std::string>& arCounterFormulas, 
																						std::map<std::string, std::string>& arCountableProductViews, // <pv name, pv nameid>
																						std::map<std::string, std::string>& arCountableProperties,
																						std::vector<std::string>& arCounterFormulaAliases)
{
	try {

		//gets this aggregate charge's cpd collection
		MTPRODUCTCATALOGLib::IMTAggregateChargePtr aggCharge(this);
		MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr piType = aggCharge->PriceableItemType;
		MTPRODUCTCATALOGLib::IMTCollectionPtr cpdColl = piType->GetCounterPropertyDefinitions();

		MTNAMEIDLib::IMTNameIDPtr nameid(MTPROGID_NAMEID);

		//iterates through the template's CPD collection 
		long nCPDCount =  cpdColl->Count;
		mLogger.LogVarArgs(LOG_DEBUG, "CPD count = %d", nCPDCount);
		long countableIndex = 0;
		for (int counterIndex = 1; counterIndex <= nCPDCount; counterIndex++) {
			MTPRODUCTCATALOGLib::IMTCounterPropertyDefinitionPtr cpd = cpdColl->GetItem(counterIndex);
			MTPRODUCTCATALOGLib::IMTCounterPtr counter = aggCharge->GetCounter(cpd->GetID());

			if(counter == NULL) {
				mLogger.LogVarArgs(LOG_ERROR, "CPD with ID %d does not have a counter associated with it!", cpd->GetID());
				return E_FAIL;  //TODO: what to do?
			}

			//aliases the counter to the output property found in the CPD
			string alias = "c_";  //column prefix in productview
			alias += (char*) _bstr_t(cpd->ServiceDefProperty); 
			counter->Alias = _bstr_t(alias.c_str());
			arCounterFormulaAliases.push_back(alias);
			
			//gets the counter's parameter collection
			MTPRODUCTCATALOGLib::IMTCollectionPtr paramColl = counter->Parameters;
			long nParamCount = paramColl->Count;


			std::string formula = (char*) _bstr_t(counter->GetFormula(MTPRODUCTCATALOGLib::VIEW_SQL));

			//
			// iterates through param collection for the current counter
			//
			for (int paramIndex = 1; paramIndex <= nParamCount; paramIndex++) {
				MTCOUNTERLib::IMTCounterParameterPtr param = paramColl->GetItem(paramIndex);

				//if a parameter is just a constant, then don't do anything
				if (param->GetKind() == PARAM_CONST)
					continue;
				
				//if the product view has not yet been added, then lookup info and add it
				std::string tableName = (char*) _bstr_t(param->ProductViewTable);
				std::map<std::string, std::string>::iterator findit;
				findit = arCountableProductViews.find(tableName);
				if (findit == arCountableProductViews.end()) {

					//calculates view id of the countable's product view
					long nViewID = nameid->GetNameID(param->ProductViewName);
					char viewID[256];
					sprintf(viewID, "%d", nViewID);

					arCountableProductViews[tableName] = viewID;
				}
				
				// generates a unique countable alias
				std::string columnName = (char*) _bstr_t(param->GetColumnName());
				std::string originalTableColumn = tableName + "." + columnName;
				char countableAlias[64];
				sprintf(countableAlias, "countable_%d", countableIndex++);
				arCountableProperties[originalTableColumn] = countableAlias;
				std::string aliasedTableColumn = "tp2.";
				aliasedTableColumn += countableAlias;

				// replaces the orginal table/column name of the parameter
				// in the formula with the unique countable alias  
				std::string::size_type pos = 0;
				while(true)
				{
					pos = formula.find(originalTableColumn);
					if (pos == std::string::npos) // no more instances found
						break;
					formula.replace(pos, originalTableColumn.length(), aliasedTableColumn); 
				}
			}

			arCounterFormulas.push_back(formula);
		} 
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }
	
	return S_OK;
}


// INTERNAL USE ONLY
HRESULT CMTAggregateCharge::RemovePVRecords(long aUsageIntervalID, long aAccountID,
																						IRecurringEventRunContext * apRunContext)
{
	HRESULT hr;

	try {
		MetraTech_UsageServer::IRecurringEventRunContextPtr runContext(apRunContext);

    //0. Figure out if we are processing multiple intervals.
    std::wstring intervalIDs;
    if (aUsageIntervalID <= 0)
    {
      ASSERT(NULL == apRunContext);
      // Look to the t_agg_interval_arg table
      ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
      rowset->Init("queries\\ProductCatalog");
      rowset->SetQueryTag(L"__GET_AGGREGATE_INTERVAL_ARGS__");
      rowset->Execute();
      while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
      {
        intervalIDs += (boost::wformat(intervalIDs.size() > 0 ? L", %1%" : L"%1%") % 
                        (const wchar_t *)(_bstr_t)(rowset->GetValue(L"id_usage_interval"))).str();
        rowset->MoveNext();
      }		
      if (0 == intervalIDs.size()) {
        mLogger.LogVarArgs(LOG_ERROR, "CMTAggregateCharge::RemovePVRecords called with empty interval argument table"); 
        return E_FAIL; 
      }
      intervalIDs = L" IN (" + intervalIDs + L")";
    }
    else
    {
      intervalIDs = (boost::wformat(L" = %1%") % aUsageIntervalID).str();
    }

		//1. Get ID (it's supposed to be a template object)
		long lPITemplateID;
		hr = get_ID(&lPITemplateID);
		if(FAILED(hr))
			return hr;
		_ASSERTE(lPITemplateID > 0);
	
		//2. get product view from the type object
		IMTPriceableItemTypePtr piType;
		hr = get_PriceableItemType((IMTPriceableItemType**) &piType);
		if (FAILED(hr))
			return hr;
		_bstr_t bstrSecondPassProductView = piType->GetProductView();

		//3. gets the second pass product view's view ID
		MTNAMEIDLib::IMTNameIDPtr nameid(MTPROGID_NAMEID);
		long nSecondPassProductViewID = nameid->GetNameID(bstrSecondPassProductView);
		
		//4. get table name (will be table name for second pass pv)
		std::string sTableName;
		vector<string> vScratch;
		hr = GetProductViewProps((const char*)bstrSecondPassProductView, sTableName, vScratch); 	//TODO:: redundant
		if (FAILED(hr))
			return hr;
		
		if (apRunContext)
		{
			_bstr_t msg = "Removing pre-existing second pass product view records from ";
			msg += sTableName.c_str();
			runContext->RecordInfo(msg);
		}

    //5. Get the second pass service def; we only delete records that underwent second pass processing
    MTPRODUCTCATALOGLib::IMTAggregateChargePtr This(this);
    long nSecondPassServiceDefID = nameid->GetNameID(This->SecondPassServiceDefinition);

		if (aAccountID)
			ASSERT(!"Account specific aggregate rating is no longer supported!");

		mLogger.LogVarArgs(LOG_DEBUG, "Removing previous second pass product view data from table = '%s' where piID = %d,"
											 "intervalID = %d, viewID = %d, svcID = %d for all accounts", sTableName.c_str(), lPITemplateID,
											 aUsageIntervalID, nSecondPassProductViewID, nSecondPassServiceDefID);


		// only applies the billing group filter to EOP runs (not on estimates)
		_bstr_t billingGroupFilter;
		if (apRunContext)
		{
			billingGroupFilter = "AND id_acc IN (SELECT id_acc FROM t_billgroup_member WHERE id_billgroup = ";
			billingGroupFilter += _bstr_t(runContext->BillingGroupID);
			billingGroupFilter += ")";
		}
		
		//
		// deletes the second pass usage (t_acc_usage and t_pv)
		//
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init("queries\\ProductCatalog");
		rowset->SetQueryTag("__DELETE_SECOND_PASS_AGGREGATE_ESTIMATE_DATA__");
		rowset->AddParam("%%SECOND_PASS_PV_TABLE_NAME%%", sTableName.c_str());
		rowset->AddParam("%%USAGE_INTERVAL_FILTER%%", intervalIDs.c_str());
		rowset->AddParam("%%ID_PI_TEMPLATE%%", lPITemplateID);
		rowset->AddParam("%%SECOND_PASS_VIEW_ID%%", nSecondPassProductViewID);
		rowset->AddParam("%%BILLING_GROUP_FILTER%%", billingGroupFilter);
		rowset->Execute();

		if (apRunContext)
			runContext->RecordInfo("Successfully removed pre-existing second pass product view records");


		//
		// removes PV data from children before performing any connected executes (CR11975)
		//

		// TODO: this would be more efficient if we issued just
		// two deletes for a compound: 1 for all PV data, and 1 for all t_acc_usage data.
		// The current algorithm issues 2n + 2 delete statements where n is the number of children! 
		IMTAggregateChargePtr thisPtr(this);
		MTPRODUCTCATALOGLib::IMTCollectionPtr children = thisPtr->GetChildren();
		long childrenCount = children->Count;
		for(long i = 1; i <= childrenCount; i++) 
		{
			IMTAggregateChargePtr child = children->GetItem(i);
			child->RemovePVRecords(aUsageIntervalID,
														 aAccountID, 
														 (MTPRODUCTCATALOGLib::IRecurringEventRunContext *) apRunContext);
		}
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}
