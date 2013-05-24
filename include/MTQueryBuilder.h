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

#ifndef __MTQUERYBUILDER_H_
#define __MTQUERYBUILDER_H_

#include <string>
#include <vector>
#include <map>

using std::string;

// class to construct a SQL Query
// usage: create an instance,
//        call AddXXX() until done,
//        then call Generatewstring to retrieve string
class MTQueryBuilder
{

public:
  enum JoinType { NO_JOIN,
                  INNER_JOIN,
                  LEFT_OUTER_JOIN,
                  RIGHT_OUTER_JOIN,
                  FULL_OUTER_JOIN
                };

  MTQueryBuilder(bool aIsOracle);
  ~MTQueryBuilder();
  
  void AddSelectColumn( const wstring& aTableAlias,
                        const wstring& aColumnName,
                        const wstring& aColumnAlias );
  
  bool HasTable(const wstring& aTableAlias);
  void AddTable(const wstring& aTableName, const wstring& aTableAlias);
  void AddJoinTable(const wstring& aTableName,
                    const wstring& aTableAlias,
                    JoinType aJoinType,
                    const wstring& aJoinCondition,
                    const wstring& aTableHint);
  void AddJoinCondition(const wstring& aTableAlias,
                        const wstring& aCondition);

  void AddWhereCondition(const wstring& aCondition);

  void AddOrderBy(const wstring& aTableAlias, const wstring& aColumnName);

  void SetMaxRows(long maxRows);
  
  wstring GenerateString();

private:
  class CQBColumn
  { 
  public: 
    wstring TableAlias;
    wstring ColumnName;
    wstring ColumnAlias;

    CQBColumn(const wstring& aTableAlias,const wstring& aColumnName, const wstring& aColumnAlias) :
      TableAlias(aTableAlias), ColumnName(aColumnName), ColumnAlias(aColumnAlias)
      {}
  };
 
  class CQBTable
  { 
  public: 
    wstring TableName;
    wstring TableAlias;
    MTQueryBuilder::JoinType JoinType;
    wstring JoinCondition; //concatenated wstring of all conditions
    wstring TableHint;

    CQBTable(wstring aTableName, wstring aTableAlias, MTQueryBuilder::JoinType aJoinType, wstring aJoinCondition, wstring aTableHint) :
      TableName(aTableName), TableAlias(aTableAlias), JoinType(aJoinType), JoinCondition(aJoinCondition), TableHint(aTableHint)
      {}
  };

  bool                        mIsOracle;
  long                        mMaxRows;
  std::vector<CQBColumn*>     mSelectColumns;
  std::map<wstring, CQBTable*> mTableMap;        //map indexed by alias
  std::vector<wstring>         mWhereConditions;
  std::vector<wstring>         mOrderColumns;
};


#endif
