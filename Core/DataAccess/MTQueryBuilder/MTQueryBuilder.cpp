/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#include <metra.h>
#include <mtcom.h>
#include <comdef.h>
#include <comutil.h>
#include <mtcomerr.h>
#include <stdutils.h>
#include "MTQueryBuilder.h"

//formatting helpers
const wchar_t* NEWLINE =          L"\n";
const wchar_t* NEWLINE_1_INDENT = L"\n  ";
const wchar_t* NEWLINE_2_INDENT = L"\n    ";


MTQueryBuilder::MTQueryBuilder(bool aIsOracle) :
  mIsOracle(aIsOracle),
  mMaxRows(0)
{
}

MTQueryBuilder::~MTQueryBuilder()
{
  //cleanup mSelectColumns
  for(std::vector<CQBColumn*>::iterator colItr = mSelectColumns.begin();
      colItr != mSelectColumns.end();
      ++colItr)
  {
    CQBColumn* col = *colItr;
    delete col;
  }

  //cleanup mTableMap
  for( std::map<wstring , CQBTable*>::iterator tblItr = mTableMap.begin();
       tblItr != mTableMap.end();
       ++tblItr)
  {
    CQBTable* tbl = tblItr->second;
		delete tbl;
	}
}


void MTQueryBuilder::AddSelectColumn( const wstring& aTableAlias,
                                      const wstring& aColumnName,
                                      const wstring& aColumnAlias )
{
  mSelectColumns.push_back(new CQBColumn(aTableAlias,aColumnName,aColumnAlias));
}

bool MTQueryBuilder::HasTable(const wstring& aTableAlias)
{
  return (mTableMap.find(aTableAlias) != mTableMap.end());
}

void MTQueryBuilder::AddTable(const wstring& aTableName, const wstring& aTableAlias)
{
  //treat table as just a special case of join
  AddJoinTable(aTableName, aTableAlias, NO_JOIN, L"", L"");
}

void MTQueryBuilder::AddJoinTable(const wstring& aTableName,
                    const wstring& aTableAlias,
                    JoinType aJoinType,
                    const wstring& aJoinCondition, //wstring in format "thisColumn = other.otherColumn"
                                  const wstring& aTableHint) 
{
  if(HasTable(aTableAlias))
    MT_THROW_COM_ERROR("table with alias %s already in query", aTableAlias.c_str());
  
  //add alias to aJoinCondition to make full condition string
  wstring fullCondition = aTableAlias;
  fullCondition += L".";
  fullCondition += aJoinCondition;

  mTableMap[aTableAlias] = new CQBTable(aTableName, aTableAlias, aJoinType, fullCondition, aTableHint);
}

// adds a AND condition to join
void MTQueryBuilder::AddJoinCondition(const wstring& aTableAlias,
                                      const wstring& aCondition)
{
  CQBTable* table = mTableMap[aTableAlias];
  if(table == NULL)
    MT_THROW_COM_ERROR("table with alias %s not query", aTableAlias.c_str());

  if (table->JoinCondition.size() > 0)
  { table->JoinCondition += NEWLINE_2_INDENT;
    table->JoinCondition += L"AND ";
  }

  table->JoinCondition += aCondition;
}

void MTQueryBuilder::AddWhereCondition(const wstring& aCondition)
{
  mWhereConditions.push_back(aCondition);
}

void MTQueryBuilder::AddOrderBy(const wstring& aTableAlias, const wstring& aColumnName)
{
  wstring fullName;
  fullName = aTableAlias;
  fullName += L".";
  fullName += aColumnName;

  mOrderColumns.push_back(fullName);
}


void MTQueryBuilder::SetMaxRows(long maxRows)
{
  mMaxRows = maxRows;
}


wstring MTQueryBuilder::GenerateString()
{
  wstring query;
  wchar_t buffer[100];

  //generate SELECT
  query = L"SELECT ";

  //add TOP for SQLServer
  if (!mIsOracle && mMaxRows > 0)
  { 
    _ltow(mMaxRows, buffer, 10);
    query += L"TOP ";
    query += buffer;
  }

  for(std::vector<CQBColumn*>::iterator colItr = mSelectColumns.begin();
      colItr != mSelectColumns.end();
      ++colItr)
  {
    if (colItr != mSelectColumns.begin())
    { query += L",";
    }
    query += NEWLINE_1_INDENT;

    CQBColumn* col = *colItr;
    query += col->TableAlias;
    query += L".";
    query += col->ColumnName;
    // Accessing alias in quotes from a subquery is close to impossible if case is not correct.
    // So uppercasing alias as a standard.
    wstring Alias = col->ColumnAlias;
    if (mIsOracle) {
      StrToUpper(Alias);
    }
    query += L" \"";
    query += Alias;
    query += L"\"";

/*
    bool needAliasInQuotes = true;
    // Accessing alias in quotes from a subquery is close to impossible if case is not correct.
    // So only use quotes around aliases when an alias starts with underscore.
    if (mIsOracle) {
      if (col->ColumnAlias[0] != '_') 
        needAliasInQuotes = false;
    }
    if (needAliasInQuotes) {
      query += L" \"";
      query += col->ColumnAlias;
      query += L"\"";
    } else {
      query += L" ";
      query += col->ColumnAlias;
    }
*/
  }
  
  //generate FROM
  query += NEWLINE;
  query += L"FROM";

  // add no_joins
  bool bTableAdded = false;
  std::map<wstring , CQBTable*>::iterator tblItr;
  for(tblItr = mTableMap.begin();
      tblItr != mTableMap.end();
      ++tblItr)
  {
    CQBTable* tbl = tblItr->second;
    if (tbl->JoinType == NO_JOIN)
    {
      if(bTableAdded)
      { query += L",";
      }
      query += NEWLINE_1_INDENT;
      query += tbl->TableName;
      query += L" ";
      query += tbl->TableAlias;
      if (tbl->TableHint.size() > 0)
      {
        query += L" ";
        query += tbl->TableHint;
      }
      bTableAdded = true;
    }
  }

  // add joins
  for(tblItr = mTableMap.begin();
      tblItr != mTableMap.end();
      ++tblItr)
  {
    CQBTable* tbl = tblItr->second;
    if (tbl->JoinType != NO_JOIN)
    {
      query += NEWLINE_1_INDENT;

      switch(tbl->JoinType)
      { case INNER_JOIN:       query += L" INNER JOIN "; break;
        case LEFT_OUTER_JOIN:  query += L" LEFT OUTER JOIN "; break;
        case RIGHT_OUTER_JOIN: query += L" RIGHT OUTER JOIN "; break;
        case FULL_OUTER_JOIN:  query += L" FULL OUTER JOIN "; break;
        default: MT_THROW_COM_ERROR("invalid join type");
      }
          
      query += tbl->TableName;
      query += L" ";
      query += tbl->TableAlias;

      if (tbl->TableHint.size() > 0)
      {
        query += L" ";
        query += tbl->TableHint;
      }

      if(tbl->JoinCondition.size() > 0)
      { query += NEWLINE_2_INDENT;
        query += L"ON ";
        query += tbl->JoinCondition;
      }
    }
  }


  //generate WHERE
  if (mWhereConditions.size() > 0 || mIsOracle)
  {
    query += NEWLINE;
    query += L"WHERE ";

    for(std::vector<wstring >::iterator condItr = mWhereConditions.begin();
        condItr != mWhereConditions.end();
        ++condItr)
    {
      query += NEWLINE_1_INDENT;

      if (condItr != mWhereConditions.begin())
      { query += L"AND ";
      }
      query += *condItr;
    }

    //add rownum for oracle
    if (mIsOracle && mMaxRows > 0)
    { 
      query += NEWLINE_1_INDENT;
      if (mWhereConditions.size() > 0)
      { query += L"AND ";
      }

      _ltow(mMaxRows, buffer, 10);
      query += L"rownum <= ";
      query += buffer;
    }
  }

  //generate ORDER BY
  if (mOrderColumns.size() > 0)
  {
    query += NEWLINE;
    query += L"ORDER BY ";

    for(std::vector<wstring >::iterator itr = mOrderColumns.begin();
        itr != mOrderColumns.end();
        ++itr)
    {
      if (itr != mOrderColumns.begin())
      { query += L", ";
      }
      query += *itr;
    }
  }


  return query;
}
