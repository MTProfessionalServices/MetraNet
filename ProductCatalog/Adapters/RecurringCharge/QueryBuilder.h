#ifndef __QUERY_BUILDER_H__
#define __QUERY_BUILDER_H__

#import <Rowset.tlb> rename( "EOF", "RowsetEOF" ) 

class IMTRecurringChargeVisitor
{
public:
  virtual ~IMTRecurringChargeVisitor() {}
  virtual ROWSETLib::IMTSQLRowsetPtr GetRowset() =0;
  virtual void Visit() =0;
  virtual void VisitConnected() =0;
};

class CMTRecurringChargeExecuteVisitor : public IMTRecurringChargeVisitor
{
private:
  ROWSETLib::IMTSQLRowsetPtr mRowset;

public:
  CMTRecurringChargeExecuteVisitor(ROWSETLib::IMTSQLRowsetPtr rowset) { mRowset = rowset; }
  ROWSETLib::IMTSQLRowsetPtr GetRowset()
  {
    return mRowset;
  }
  void Visit()
  {
    mRowset->Execute();
  }
  void VisitConnected()
  {
    mRowset->ExecuteConnected();
  }  
};

class IMTRecurringChargeScriptVisitor : public IMTRecurringChargeVisitor
{
public:
  virtual ~IMTRecurringChargeScriptVisitor() {}
  virtual _bstr_t GetScript() const =0;
};

class CMTRecurringChargeSQLServerScriptVisitor : public IMTRecurringChargeScriptVisitor
{
private:
  _bstr_t mScript;
  ROWSETLib::IMTSQLRowsetPtr mRowset;

public:
  CMTRecurringChargeSQLServerScriptVisitor(ROWSETLib::IMTSQLRowsetPtr rowset) 
  { 
    mRowset = rowset; 
  }
  _bstr_t GetScript() const 
  { 
    return mScript; 
  }
  ROWSETLib::IMTSQLRowsetPtr GetRowset()
  {
    return mRowset;
  }
  void Visit()
  {
    mScript += mRowset->GetQueryString();
    mScript += L"GO\n";
  }
  void VisitConnected()
  {
    mScript += mRowset->GetQueryString();
    mScript += L"GO\n";
  }  
};

class CMTRecurringChargeOracleScriptVisitor : public IMTRecurringChargeScriptVisitor
{
private:
  _bstr_t mScript;
  ROWSETLib::IMTSQLRowsetPtr mRowset;

public:
  CMTRecurringChargeOracleScriptVisitor(ROWSETLib::IMTSQLRowsetPtr rowset) 
  { 
    mRowset = rowset; 
    mScript = L"BEGIN\n";
  }
  _bstr_t GetScript() const 
  { 
    return mScript + L"\nEND;"; 
  }
  ROWSETLib::IMTSQLRowsetPtr GetRowset()
  {
    return mRowset;
  }
  void Visit()
  {
    mScript += mRowset->GetQueryString();
  }
  void VisitConnected()
  {
    mScript += mRowset->GetQueryString();
  }  
};


class PerParticipantOrPerSubscriptionQueryBuilder
{
public:
	PerParticipantOrPerSubscriptionQueryBuilder()
	{
	}

	void BuildPerParticipantArrearsQuery(ROWSETLib::IMTSQLRowsetPtr rowset, bool createTable, bool isOracle);
	void BuildPerSubscriptionArrearsQuery(ROWSETLib::IMTSQLRowsetPtr rowset, bool createTable, bool isOracle);
	void BuildPerParticipantAdvanceQuery(ROWSETLib::IMTSQLRowsetPtr rowset);
	void BuildPerSubscriptionAdvanceQuery(ROWSETLib::IMTSQLRowsetPtr rowset);
	void BuildPerParticipantAdvanceCreditQuery(ROWSETLib::IMTSQLRowsetPtr rowset);
	void BuildPerSubscriptionAdvanceCreditQuery(ROWSETLib::IMTSQLRowsetPtr rowset);
	void BuildPerParticipantInitialQuery(ROWSETLib::IMTSQLRowsetPtr rowset, bool createTable, bool isOracle);
	void BuildPerSubscriptionInitialQuery(ROWSETLib::IMTSQLRowsetPtr rowset, bool createTable, bool isOracle);
	void BuildPerParticipantInitialCreditQuery(ROWSETLib::IMTSQLRowsetPtr rowset);
	void BuildPerSubscriptionInitialCreditQuery(ROWSETLib::IMTSQLRowsetPtr rowset);
};


#endif
