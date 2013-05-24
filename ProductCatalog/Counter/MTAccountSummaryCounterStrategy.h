/**************************************************************************
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
 * Created by: Boris Partensky
 * $Header$
 *
 ***************************************************************************/
	
// MTView.h : Declaration of the CView

#ifndef __MTCOUNTERSTRATEGY_H_
#define __MTCOUNTERSTRATEGY_H_

#include "resource.h"       // main symbols
#include <comdef.h>

//#include "counterincludes.h"

#include <vector>

using namespace std;

class CWhereConditionDataTypeAndOperator;

typedef vector<_bstr_t> QueryTokens;
typedef map<_bstr_t, _bstr_t> Counter2AliasMap;
typedef map<_bstr_t, _bstr_t> Table2PVMap;
typedef vector<CWhereConditionDataTypeAndOperator*> WhereTokens;

typedef enum
{
	OPERATOR_EQUAL,
	OPERATOR_LESS,
	OPERATOR_GREATER,
	OPERATOR_IN
} Operator;

typedef enum
{
	DATATYPE_STRING,
	DATATYPE_NUMERIC,
	DATATYPE_DATE
} DataType;


class CWhereConditionDataTypeAndOperator
{
public:

	_bstr_t Field;
	_variant_t Condition;
	_bstr_t ConditionOperator;
	DataType DataType;

	void SetOperator(Operator aOperator)
	{
		switch(aOperator)
		{
			case OPERATOR_EQUAL: 
				ConditionOperator = "=";
				break;
			case OPERATOR_LESS: 
				ConditionOperator = "<";
				break;
			case OPERATOR_GREATER: 
				ConditionOperator = ">";
				break;
			case OPERATOR_IN:
				ConditionOperator = " IN ";
				break;
			default:
				ConditionOperator = "=";
		}
	}
private:
	
};
class CMTAccountSummaryCounterStrategy
{
public:
	
	~CMTAccountSummaryCounterStrategy();
	HRESULT Init();
	void AddSelectField(BSTR aField);
	void AddSelectFromTable(BSTR aTable, BSTR aPVName);
	void AddCounter(BSTR aCounterStatement);
	void AddWhereClauseCondition(BSTR aField, BSTR aValue, DataType aDataType, Operator aOp = OPERATOR_EQUAL);
	void AddWhereClauseCondition(BSTR aField, DATE aValue, DataType aDataType,  Operator aOp = OPERATOR_EQUAL);
	void AddWhereClauseCondition(BSTR aField, long aValue, DataType aDataType, Operator aOp = OPERATOR_EQUAL);
	HRESULT AddWhereClauseCondition(BSTR aField, IMTCollection* aValues, DataType aDataType, Operator aOp = OPERATOR_IN); /*IN*/
	HRESULT Execute(IMTSQLRowset** apRowset);
	_bstr_t GetStatement();
	_bstr_t CreateStatement();
	void Clear();

private:
	BOOL mbUseOracle;
	_bstr_t mStatement;
	QueryTokens mCounters;
	QueryTokens mSelectFields;
	Table2PVMap mSelectFromTables;
	WhereTokens mWhereClause;
};

#endif //__MTCOUNTERSTRATEGY_H_
