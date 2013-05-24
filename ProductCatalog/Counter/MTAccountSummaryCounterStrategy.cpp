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

#include "StdAfx.h"
#include "MTAccountSummaryCounterStrategy.h"

CMTAccountSummaryCounterStrategy::~CMTAccountSummaryCounterStrategy()
		
{
	WhereTokens::iterator it;
	for(it = mWhereClause.begin(); it != mWhereClause.end(); ++it)
	{
		if(*it)
		{
			delete (*it);
			(*it) = NULL;
		}
	}
}
	

HRESULT CMTAccountSummaryCounterStrategy::Init()
{
	HRESULT hr(S_OK);
	CComPtr<IMTSQLRowset> rs;
	BSTR dbtype;

	hr = rs.CoCreateInstance(__uuidof(MTSQLRowset));
	
	if(FAILED(hr))
		return hr;

	hr = rs->Init(CONFIG_DIR);

	if(FAILED(hr))
		return hr;
	
	rs->GetDBType(&dbtype);
	_bstr_t bstrDBType = _bstr_t(dbtype, false);

	wstring sDBType = (const wchar_t*) bstrDBType;
	
	StrToLower(sDBType);

	if(sDBType.find(wstring(L"oracle")) == wstring::npos)
		mbUseOracle = FALSE;
	else
		mbUseOracle = TRUE;

	return hr;
}

void CMTAccountSummaryCounterStrategy::AddSelectFromTable(BSTR aTable, BSTR aPVName)
{
	mSelectFromTables.insert(Table2PVMap::value_type(aTable, aPVName) );
}

void CMTAccountSummaryCounterStrategy::AddCounter(BSTR aCounter)
{
	mCounters.push_back(aCounter);
}

void CMTAccountSummaryCounterStrategy::AddWhereClauseCondition(BSTR aField, long aCondition,DataType aDataType, Operator aOp)
{
	CWhereConditionDataTypeAndOperator* obj = new CWhereConditionDataTypeAndOperator();
	obj->Field = aField;
	obj->Condition = aCondition;
	obj->DataType = aDataType;
	obj->SetOperator(aOp);
	
	mWhereClause.push_back(obj);
	
}

void CMTAccountSummaryCounterStrategy::AddWhereClauseCondition(BSTR aField, BSTR aCondition, DataType aDataType, Operator aOp)
{
	CWhereConditionDataTypeAndOperator* obj = new CWhereConditionDataTypeAndOperator();
	obj->Field = aField;
	obj->Condition = aCondition;
	obj->DataType = aDataType;
	obj->SetOperator(aOp);
	
	mWhereClause.push_back(obj);
	
}

HRESULT CMTAccountSummaryCounterStrategy::AddWhereClauseCondition(BSTR aField, IMTCollection* apConditions, DataType aDataType, Operator aOp)
{
	HRESULT hr(S_OK);
	_ASSERTE(apConditions != NULL) ;
	
	CWhereConditionDataTypeAndOperator* obj = new CWhereConditionDataTypeAndOperator();
	obj->Condition = _variant_t( (IDispatch*) apConditions, true /*addref*/);
	obj->Field = aField;
	obj->DataType = aDataType;
	obj->SetOperator(aOp);
	mWhereClause.push_back(obj);
	
	return hr;
}

void CMTAccountSummaryCounterStrategy::AddWhereClauseCondition(BSTR aField, DATE aCondition, DataType aDataType, Operator aOp)
{
	CWhereConditionDataTypeAndOperator* obj = new CWhereConditionDataTypeAndOperator();
	obj->Field = aField;
	obj->Condition = _variant_t(aCondition, VT_DATE);
	obj->DataType = aDataType;
	obj->SetOperator(aOp);
	
	mWhereClause.push_back(obj);
}

void CMTAccountSummaryCounterStrategy::Clear()
{
	
}

void CMTAccountSummaryCounterStrategy::AddSelectField(BSTR aField)
{
	mSelectFields.push_back(aField);
}



_bstr_t CMTAccountSummaryCounterStrategy::CreateStatement()
{
	HRESULT hr(S_OK);
	_TCHAR buffer[255];
	QueryTokens::iterator it;
	map<_bstr_t, _bstr_t>::iterator mapit;
	WhereTokens::iterator whereClauseIt;
	BOOL bFirstTime(TRUE);
	BOOL bInternalFirstTime(TRUE);
	_bstr_t bstrGroupBy = " GROUP BY ";
	
	//this is a collection of variants
	CComPtr<IMTCollection> ptr;

	mapit = mSelectFromTables.begin();
	_bstr_t bstrMasterTable = (*mapit).first;
				
	int iInternal;

	mStatement = "SELECT ";

	//append select fields;
	//mSelectFields.i

	//need to get CMSIXProperties *first to get real column name
	//because it's usually has c_ prepended

  
	for(it = mSelectFields.begin(); it != mSelectFields.end(); ++it)
	{
		if(!bFirstTime)
		{
			bstrGroupBy += ", ";
		}
		_bstr_t field = (*it);
		
		//need to qualify select field with table name for the case of more then one
		//table
		//by the nature of this strategy it's doesn't really matter which table,
		//so just take the first one from the table list
		

		mStatement += bstrMasterTable;
		mStatement += ".";
		mStatement += field;
		mStatement += ", ";
		
		bstrGroupBy += bstrMasterTable;
		bstrGroupBy += ".";
		bstrGroupBy += field;
		
		bFirstTime = FALSE;
	}
	
	bFirstTime = TRUE;

	for(it = mCounters.begin(); it != mCounters.end(); ++it)
	{
		if(!bFirstTime)
			mStatement += ", ";
		mStatement += (*it);
		bFirstTime = FALSE;
	}

	mStatement += " FROM ";
	
	bFirstTime = TRUE;

	for(mapit = mSelectFromTables.begin(); mapit != mSelectFromTables.end(); ++mapit)
	{
		if(!bFirstTime)
			mStatement += ", ";
		bFirstTime = FALSE;
		mStatement += (*mapit).first;
	}

	mStatement += " WHERE ";
	
	bFirstTime = TRUE;
	
	for(mapit = mSelectFromTables.begin(); mapit != mSelectFromTables.end(); ++mapit)
	{
		//every where clause condition has to be qualified with table name
		_bstr_t bstrTable = (*mapit).first;

		for(whereClauseIt = mWhereClause.begin(); whereClauseIt != mWhereClause.end(); ++whereClauseIt)
		{
			CWhereConditionDataTypeAndOperator* obj;
			if(!bFirstTime)
				mStatement += " AND ";
			
			//every where clause condition has to be qualified with table name
			mStatement += bstrTable;
			mStatement += ".";

			bFirstTime = FALSE;
			obj = (*whereClauseIt);
			
			mStatement += obj->Field;
			mStatement += " ";
			mStatement += obj->ConditionOperator;
			mStatement += " ";
			
			//switch on Condition's type
			switch(obj->Condition.vt)
			{
			case VT_I4:
				{
					_stprintf(buffer, _T("%d"), (double) V_I4(&obj->Condition));
					mStatement += _bstr_t(buffer);
				}
			case VT_I2:
				{
					_stprintf(buffer, _T("%hd"),V_I2(&obj->Condition));
					mStatement += _bstr_t(buffer);
					break;
				}
			case VT_BSTR:
				{
					mStatement += "N'";
					mStatement += V_BSTR (&obj->Condition);
					mStatement += "'";
					break;
				}
			case VT_DATE: //Date
				{
					struct tm temp;
					StructTmFromOleDate(&temp, obj->Condition.date);
					wcsftime(buffer, 255, _T("%Y-%m-%d %H:%M:%S"), &temp);
					
					//ORACLE case
					if (mbUseOracle)
					{
						mStatement += L"TO_DATE('" ;
						mStatement += buffer;
						mStatement += L"', 'YYYY-MM-DD HH24:MI:SS')" ;
					}
					else
					{
						mStatement += L"'" ;
						mStatement += buffer;
						mStatement += L"'" ;
					}
					break;
				}
			case VT_DISPATCH:
				{
					long lCount;
					hr = obj->Condition.pdispVal->QueryInterface(__uuidof(IMTCollection), (void**) &ptr.p);
					_ASSERTE(SUCCEEDED(hr));
					
					ptr->get_Count(&lCount);
					
					bInternalFirstTime = TRUE;
					
					//it's 1-based
					for (iInternal=1; iInternal <= lCount; iInternal++)
					{
						_variant_t element;
						ptr->get_Item(iInternal, &element);
						
						if(bInternalFirstTime)
							mStatement += "(";
						else
							mStatement += ", ";
						
						bInternalFirstTime = FALSE;
						
						//now switch on this vt, expect it to be string or long
						switch(element.vt)
						{
						case VT_I4:
							{
								_stprintf(buffer, _T("%d"), (double) V_I4(&element));
								mStatement += _bstr_t(buffer);
							}
						case VT_I2:
							{
								_stprintf(buffer, _T("%hd"),V_I2(&element));
								mStatement += _bstr_t(buffer);
								break;
							}
						case VT_BSTR:
							{	
								mStatement += "N'";
								mStatement +=  V_BSTR (&element);
								mStatement += "'";
								break;
							}
						default: _ASSERTE(0);
						}
					}
					mStatement += ")";
					break;
				}
			default: _ASSERTE(0);
			}//switch
		}//for
	}

	//add GROUP BY
	mStatement += bstrGroupBy;

	
	return mStatement;
}

HRESULT CMTAccountSummaryCounterStrategy::Execute(IMTSQLRowset** apRowset)
{
	HRESULT hr(S_OK);
	CComPtr<IMTSQLRowset> rs;

	hr = rs.CoCreateInstance(__uuidof(MTSQLRowset));
	
	if(FAILED(hr))
		return hr;

	hr = rs->Init(CONFIG_DIR);

	if(FAILED(hr))
		return hr;

	hr = rs->SetQueryString(mStatement);
	
	if(FAILED(hr))
		return hr;

	rs->Execute();

	if(FAILED(hr))
		return hr;

	(*apRowset) = rs.Detach();
	
	return hr;
}
