// MTRuleSetEvaluator.cpp : Implementation of CMTRuleSetEvaluator
#include "StdAfx.h"
#import <MTPipelineLib.tlb> rename("EOF", "RowsetEOF")
#include <MTSessionBaseDef.h>
#include "RuleSetEval.h"
#include "MTRuleSetEvaluatorDef.h"



#include <mtcomerr.h>

// import the query adapter tlb
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName")

#include <mtprogids.h>
#include <SetIterate.h>
#include <mtglobal_msg.h>

//#import <MTRuleSet.tlb>

using MTPipelineLib::IMTNameIDPtr;
using MTPipelineLib::IMTLogPtr;

using MTPipelineLib::IMTActionSetPtr;
using MTPipelineLib::IMTAssignmentActionPtr;

using MTPipelineLib::IMTRuleSetPtr;
using MTPipelineLib::IMTRulePtr;

using MTPipelineLib::IMTConditionSetPtr;
using MTPipelineLib::IMTSimpleConditionPtr;

/////////////////////////////////////////////////////////////////////////////
// CMTRuleSetEvaluator

STDMETHODIMP CMTRuleSetEvaluator::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTRuleSetEvaluator
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTRuleSetEvaluator::Configure(::IMTRuleSet *aRuleset)
{
	try
	{
		IMTNameIDPtr nameid("MetraPipeline.MTNameID.1");
		IMTLogPtr logger("MetraPipeline.MTLog.1");
		logger->Init("logging", "[RuleSetEval]");

		try
		{
			// configure the engine
      MTautoptr<PropGenRuleSet> ruleset = new PropGenRuleSet;
			mPropGen.Configure(logger, nameid, ruleset);

      //BP TODO:
      //Convert PropGenRuleSet into IMTRuleSet

		}
		catch (ErrorObject localError)
		{
			char buffer[1024];

			sprintf(buffer, "Error: %s, %s(%d) %s(error code: %X)", 
							localError.GetModuleName(),
							localError.GetFunctionName(),
							localError.GetLineNumber(),
							localError.GetProgrammerDetail().c_str(),
							localError.GetCode());
			logger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);


			sprintf(buffer, "Error in loading configuration data: %s.", 
							localError.GetProgrammerDetail().c_str());
			logger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);

			return Error(buffer);
		}
	}
	catch (_com_error &err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

#define DYNAMIC_TABLE_QUERY_PATH L"\\Queries\\DynamicTable"
#define ROWSET_INIT_PATH L"\\Queries\\Database"


			// c_duration (int)
			// c_rate (decimal)
			// c_mti (int)
			// c_mincharge (decimal)
			// c_minuom (string)
			// c_setupcharge (decimal)


			// PROP_TYPE_UNKNOWN = 0,
			// PROP_TYPE_DEFAULT = 1,
			// PROP_TYPE_INTEGER = 2,
			// PROP_TYPE_DOUBLE = 3,
			// PROP_TYPE_STRING = 4,
			// PROP_TYPE_DATETIME = 5,
			// PROP_TYPE_TIME = 6,
			// PROP_TYPE_BOOLEAN = 7,
			// PROP_TYPE_SET = 8,
			// PROP_TYPE_OPAQUE = 9,
			// PROP_TYPE_ENUM = 10,
			// PROP_TYPE_DECIMAL = 11

#if 0
struct ConditionMetaData
{
	const wchar_t * name;
	const wchar_t * propName;
	const wchar_t * test;
	MTPipelineLib::PropValType type;
};

struct ActionMetaData
{
	const wchar_t * name;
	const wchar_t * propName;
	MTPipelineLib::PropValType type;
};

struct ConditionMetaData conditionMeta[] =
{
	L"c_duration",	L"Duration", L"less_than", MTPipelineLib::PROP_TYPE_INTEGER,
};

struct ActionMetaData actionMeta[] =
{
	L"c_rate", L"Rate",  MTPipelineLib::PROP_TYPE_DECIMAL,
	L"c_mti", L"MTI", MTPipelineLib::PROP_TYPE_INTEGER,
	L"c_mincharge", L"MinCharge", MTPipelineLib::PROP_TYPE_DECIMAL,
	L"c_minuom", L"MinUOM", MTPipelineLib::PROP_TYPE_STRING,
	L"c_setupcharge", L"SetupCharge", MTPipelineLib::PROP_TYPE_DECIMAL,
};
#endif


#if 0
class CollectionAdapter
{
public:
	CollectionAdapter(VBA::_CollectionPtr aCollection)
		: mCollection(aCollection)
	{ }

	HRESULT get__NewEnum(IUnknown * * pVal)
	{ return mCollection->raw__NewEnum(pVal); }

	CollectionAdapter * operator -> ()
	{ return this; }

private:
	VBA::_CollectionPtr mCollection;
};


const wchar_t * OpToString(MTOperatorType aOp)
{
	const wchar_t * test;
	switch (aOp)
	{
	case OPERATOR_TYPE_EQUAL:
		test = L"equals"; break;
	case OPERATOR_TYPE_NOT_EQUAL:
		test = L"not_equals"; break;
	case OPERATOR_TYPE_GREATER:
		test = L"greater_than"; break;
	case OPERATOR_TYPE_GREATER_EQUAL:
		test = L"greater_equal"; break;
	case OPERATOR_TYPE_LESS:
		test = L"less_than"; break;
	case OPERATOR_TYPE_LESS_EQUAL:
		test = L"less_equal"; break;

	case OPERATOR_TYPE_LIKE:
	case OPERATOR_TYPE_LIKE_W:
	default:
		// TODO:
		ASSERT(0);
		return NULL;
	}

	return test;
}


MTPipelineLib::PropValType StringToType(_bstr_t dataType)
{
	MTPipelineLib::PropValType type;
	if (dataType == _bstr_t("int32"))
		type = MTPipelineLib::PROP_TYPE_INTEGER;
	else if (dataType == _bstr_t("int64"))
		type = MTPipelineLib::PROP_TYPE_BIGINTEGER;
	else if (dataType == _bstr_t("double"))
		type = MTPipelineLib::PROP_TYPE_DOUBLE;
	else if (dataType == _bstr_t("string"))
		type = MTPipelineLib::PROP_TYPE_STRING;
	else if (dataType == _bstr_t("datetime"))
		type = MTPipelineLib::PROP_TYPE_DATETIME;
	else if (dataType == _bstr_t("time"))
		type = MTPipelineLib::PROP_TYPE_TIME;
	else if (dataType == _bstr_t("boolean"))
		type = MTPipelineLib::PROP_TYPE_BOOLEAN;
	else if (dataType == _bstr_t("enum"))
		type = MTPipelineLib::PROP_TYPE_ENUM;
	else if (dataType == _bstr_t("decimal"))
		type = MTPipelineLib::PROP_TYPE_DECIMAL;
	else
		ASSERT(0);

	return type;
}

MTOperatorType DBOpToOp(_bstr_t opStr)
{
	MTOperatorType test;
	if (opStr == _bstr_t("<"))
		test = OPERATOR_TYPE_LESS;
	else if (opStr == _bstr_t("<="))
		test = OPERATOR_TYPE_LESS_EQUAL;
	else if (opStr == _bstr_t("="))
		test = OPERATOR_TYPE_EQUAL;
	else if (opStr == _bstr_t(">="))
		test = OPERATOR_TYPE_GREATER_EQUAL;
	else if (opStr == _bstr_t(">"))
		test = OPERATOR_TYPE_GREATER;
	else
		ASSERT(0);

	return test;
}
#endif

STDMETHODIMP CMTRuleSetEvaluator::Match(::IMTSession * session, VARIANT_BOOL * matched)
{
	try
	{
		// configure the engine
		BOOL returnval = mPropGen.ProcessSession(session);

		// TODO: figure this out
		*matched = returnval ? VARIANT_TRUE : VARIANT_FALSE;
	}
	catch (ErrorObject localError)
	{
		IMTLogPtr logger("MetraPipeline.MTLog.1");
		logger->Init("logging", "[RuleSetEval]");

		char buffer[1024];

		sprintf(buffer, "Error: %s, %s(%d) %s(error code: %X)", 
						localError.GetModuleName(),
						localError.GetFunctionName(),
						localError.GetLineNumber(),
						localError.GetProgrammerDetail().c_str(),
						localError.GetCode());
		logger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);


		sprintf(buffer, "Error in loading configuration data: %s.", 
						localError.GetProgrammerDetail().c_str());
		logger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);

    // I know we can translate PIPE_ERR_INVALID_PROPERTY back to a
    // a com_error as it is a valid HRESULT.  Some of the other mCodes
    // may be Windows errors so I don't want to blindly translate
    // everything.  MG
    if (localError.GetCode() == PIPE_ERR_INVALID_PROPERTY)
      return Error(buffer, GUID_NULL, PIPE_ERR_INVALID_PROPERTY);
    else
      return Error(buffer);
	}
	catch (_com_error &err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}
