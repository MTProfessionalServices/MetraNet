// AudioConfMeterTestCtl.cpp : Implementation of CAudioConfMeterTestCtl

#include "StdAfx.h"
#include "AudioConfMeterTestCtl.h"


// CAudioConfMeterTestCtl

CAudioConfMeterTestCtl::CAudioConfMeterTestCtl() 
: mSessionSetSize(0),
  mCallCount(0),
  mConnsPerCall(0),
  mRandomizeConnsPerCall(false),
  mFeaturesPerCall(0),
  mRandomizeFeaturesPerCall(false),
  mNumberOfAccounts(0),
  mLimitAccountRange(false),
  mStartingAccountId(0),
  mEndingAccountId(0),
  mIncludeUnsubscribedAccounts(false),
  mUnsubscribedPercentage(0),
  mStartDate(0),
  mEndDate(0)
{}

STDMETHODIMP CAudioConfMeterTestCtl::SetSessionSetSize(ULONG sessionSetSize)
{
  mSessionSetSize = sessionSetSize;

  return S_OK;
}

STDMETHODIMP CAudioConfMeterTestCtl::SetCallCount(ULONG callCount)
{
  mCallCount = callCount;

  return S_OK;
}

STDMETHODIMP CAudioConfMeterTestCtl::SetConnsPerCall(ULONG connsPerCall, VARIANT_BOOL randomizeConnsPerCall)
{
  mConnsPerCall = connsPerCall;
  mRandomizeConnsPerCall = randomizeConnsPerCall;

  return S_OK;
}

STDMETHODIMP CAudioConfMeterTestCtl::SetFeaturesPerCall(ULONG featuresPerCall, VARIANT_BOOL randomizeFeaturesPerCall)
{
  mFeaturesPerCall = featuresPerCall;
  mRandomizeFeaturesPerCall = randomizeFeaturesPerCall;

  return S_OK;
}

STDMETHODIMP CAudioConfMeterTestCtl::SetNumberOfAccounts(ULONG numberOfAccounts, BSTR offeringName)
{
  mNumberOfAccounts = numberOfAccounts;
  mOfferingName = SysAllocString(offeringName);

  return S_OK;
}

STDMETHODIMP CAudioConfMeterTestCtl::SetAccountRange(LONG startingAccountId, LONG endingAccountId)
{
  mLimitAccountRange = true;
  mStartingAccountId =startingAccountId;
  mEndingAccountId = endingAccountId;

  return S_OK;
}


STDMETHODIMP CAudioConfMeterTestCtl::ClearAccountRange(void)
{
  mLimitAccountRange = false;

  return S_OK;
}

STDMETHODIMP CAudioConfMeterTestCtl::IncludeUnsubscribedAccounts()
{
  mIncludeUnsubscribedAccounts = true;

  return S_OK;
}

STDMETHODIMP CAudioConfMeterTestCtl::ClearUnsubscribedAccounts(void)
{
  mIncludeUnsubscribedAccounts = false;

  return S_OK;
}

STDMETHODIMP CAudioConfMeterTestCtl::SetCallDateRange(BSTR startDate, BSTR endDate)
{
  COleDateTime date;

  date.ParseDateTime(startDate);
  mStartDate = (DATE)date;

  date.ParseDateTime(endDate);
  mEndDate = (DATE)date;

  return S_OK;
}

STDMETHODIMP CAudioConfMeterTestCtl::GenerateTestData(void)
{
  if( mSessionSetSize == 0 || mCallCount == 0 || 
      mNumberOfAccounts == 0 || mStartDate > mEndDate || 
      (mLimitAccountRange && (mStartingAccountId > mEndingAccountId)))
  {
    return E_INVALIDARG;
  }

  try
  {
    DesignTimePlan plan;
    wstring exprText;

    // generate master call data
    DesignTimeOperator *genCall = CreateMasterCallData(plan);
    
    // Generate list of accounts
    DesignTimeOperator *accountGen = this->CreatePayerAccountMapping(plan);

    // Join the accounts to the master call data
    DesignTimeOperator *accountJoin = JoinAccountsToCalls(plan, genCall, accountGen);

    // Split out into drivers for each of call, connection and feature.
    DesignTimeOperator *copyOpr = GenerateMasterCallCopies(plan, accountJoin);

    // Unroll connections and features
    DesignTimeUnroll *unrollConnection, *unrollFeature;
    UnrollMasterCallData(plan, copyOpr, &unrollConnection, &unrollFeature);
    
    // Generate Conference data
    DesignTimeOperator *confData = GenerateConferenceData(plan, copyOpr);

    // Generate connection records
    DesignTimeOperator *connData = GenerateConnectionData(plan, unrollConnection);

    // Generate Feature data
    DesignTimeOperator *featureData = GenerateFeatureData(plan, unrollFeature);

    // Do our metering using a private staging area for just audioconf services
    std::vector<std::wstring> audioConfServices;
    audioConfServices.push_back(L"metratech.com/audioconfcall");
    audioConfServices.push_back(L"metratech.com/audioconfconnection");
    audioConfServices.push_back(L"metratech.com/audioconffeature");
    boost::shared_ptr<DatabaseMeteringStagingDatabase> stagingArea(new DatabaseMeteringStagingDatabase(audioConfServices, 
                                                                                                        DatabaseMeteringStagingDatabase::STREAMING));
    
    Metering meter;
    meter.SetParent(L"metratech.com/audioconfcall");
    meter.SetParentKey(L"c_ConferenceID");
    std::vector<std::wstring> kiddos;
    std::vector<std::wstring> kiddoKeys;
    kiddos.push_back(L"metratech.com/audioconfconnection");
    kiddos.push_back(L"metratech.com/audioconffeature");
    meter.SetChildren(kiddos);
    kiddoKeys.push_back(L"c_ConferenceID");
    kiddoKeys.push_back(L"c_ConferenceID");
    meter.SetChildKeys(kiddoKeys);
    meter.SetTargetMessageSize(mSessionSetSize);
    meter.Generate(plan, stagingArea);

    plan.push_back(new DesignTimeChannel(confData->GetOutputPorts()[0], meter.GetInputPorts()[0]));
    plan.push_back(new DesignTimeChannel(connData->GetOutputPorts()[0], meter.GetInputPorts()[1]));
    plan.push_back(new DesignTimeChannel(featureData->GetOutputPorts()[0], meter.GetInputPorts()[2]));

    plan.type_check();
    ParallelPlan pplan(1);
    plan.code_generate(pplan);

    stagingArea->Start(pplan);
  }
  catch(std::exception &e)
  {
    std::cerr << e.what() << std::endl;
    return E_FAIL;
  }
  
  return S_OK;
}

DesignTimeOperator *CAudioConfMeterTestCtl::CreateMasterCallData(DesignTimePlan &plan)
{
    DesignTimeGenerator * genCall = new DesignTimeGenerator ();
    wstring exprText;
    string sqlText;
    char offName[256];
    long accountCount(0);

    boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
    boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());

    if( this->mIncludeUnsubscribedAccounts || mOfferingName == L"")
    {
      sqlText = "select count(*) from t_account_mapper m where id_acc > 1";
    }
    else
    {
      sqlText = "select count(*) from t_account_mapper m inner join t_sub s on m.id_acc = s.id_acc "
          "inner join t_base_props bp on s.id_po = bp.id_prop where bp.n_kind=100 and bp.nm_name like '%";
      sprintf(offName, "%S", mOfferingName);
      sqlText += offName;
      sqlText += "%'";
    }

    if( this->mLimitAccountRange )
    {
      char limitClause[255];
      sprintf_s(limitClause, 255, " and m.id_acc between %d and %d", this->mStartingAccountId, this->mEndingAccountId);
      sqlText += limitClause;
    }

    boost::shared_ptr<COdbcResultSet> rs(stmt->ExecuteQuery(sqlText));
    if(rs->Next())
    {
      ULONG val = (ULONG)rs->GetInteger(1);
      accountCount = min(val, mNumberOfAccounts);
    }  
    
    if( accountCount == 0 )
    {
      throw;
    }

    wchar_t buf[20];
    
    COleDateTime startDt(mStartDate);
    COleDateTime endDt(mEndDate);
    COleDateTimeSpan dayCount = endDt - startDt;
    int dayCnt = dayCount.GetDays() + 1;

    CString curDateStr = COleDateTime::GetCurrentTime().Format(L"%m%d%y%H%M%S");
        
    genCall->SetName(L"genCall");
    exprText = L"CREATE PROCEDURE genCall ";
    exprText += L"@id_sess NVARCHAR\n";
    exprText += L"@c_ConferenceID NVARCHAR\n";
    exprText += L"@c_ParentPayerIndex INTEGER\n";
    exprText += L"@baseDateTime DATETIME\n";
    exprText += L"@numConnections INTEGER\n";
    exprText += L"@numFeatures INTEGER\n";
    exprText += L"AS\n";
    exprText += L"SET @id_sess = CAST(@@RECORDCOUNT AS NVARCHAR)\n";
    exprText += L"SET @c_ConferenceID = CAST(@@RECORDCOUNT AS NVARCHAR)\n";
    //exprText += L"SET @c_ConferenceID = N'";
    //exprText += curDateStr.GetString();
    //exprText += L"' + CAST(@@RECORDCOUNT AS NVARCHAR)\n";
    exprText += L"SET @c_ParentPayerIndex = CAST(CAST(@@RECORDCOUNT as INTEGER) % CAST(";

    swprintf(buf, 20, L"%d", accountCount);
    exprText += buf;

    exprText += L" AS INTEGER) AS INTEGER)\n";

    swprintf(buf, 20, L"%d", dayCnt);
    exprText += L"SET @baseDateTime =dateadd(N'd', CAST(CAST(@@RECORDCOUNT as INTEGER) %";
    exprText += buf;
    exprText += L" as DECIMAL), CAST('";

    swprintf(buf, 20, L"%d/%d/%d", startDt.GetMonth(), startDt.GetDay(), startDt.GetYear());
    exprText += buf;
    exprText += L"' as DATETIME))\n";

    exprText += L"SET @baseDateTime = dateadd(N'hh', CAST(rand() * CAST(23 as DOUBLE PRECISION) as DECIMAL), @baseDateTime)\n";
    exprText += L"SET @baseDateTime = dateadd(N'mi', CAST(rand() * CAST(59 as DOUBLE PRECISION) as DECIMAL), @baseDateTime)\n";
    exprText += L"SET @baseDateTime = dateadd(N's', CAST(rand() * CAST(59 as DOUBLE PRECISION) as DECIMAL), @baseDateTime)\n";

    swprintf(buf, 20, L"%d", this->mConnsPerCall);
    if(this->mRandomizeConnsPerCall)
    {
      exprText += L"SET @numConnections = CAST(rand() * CAST(";
      exprText += buf;
      exprText += L" AS DOUBLE PRECISION) AS INTEGER)\n";
    }
    else
    {
      exprText += L"SET @numConnections = ";
      exprText += buf;
      exprText += L"\n";
    }
    
    swprintf(buf, 20, L"%d", this->mFeaturesPerCall);
    if(this->mRandomizeFeaturesPerCall)
    {
      exprText += L"SET @numFeatures = CAST(rand() * CAST(";
      exprText += buf;
      exprText += L" AS DOUBLE PRECISION) AS INTEGER)\n";;
    }
    else
    {
      exprText += L"SET @numFeatures = ";
      exprText += buf;
      exprText += L"\n";
    }

    genCall->SetProgram(exprText);
    genCall->SetNumRecords(mCallCount);

    plan.push_back(genCall);

    return genCall;
}

DesignTimeOperator *CAudioConfMeterTestCtl::CreatePayerAccountMapping(DesignTimePlan &plan)
{
    DesignTimeDatabaseSelect * select = new DesignTimeDatabaseSelect();
    wstring sqlText;
    
    if( this->mIncludeUnsubscribedAccounts || mOfferingName == L"")
    {
      sqlText = L"select nm_login from t_account_mapper m where id_acc > 1";
    }
    else
    {
      sqlText = L"select nm_login from t_account_mapper m inner join t_sub s on m.id_acc = s.id_acc "
          L"inner join t_base_props bp on s.id_po = bp.id_prop where bp.n_kind=100 and bp.nm_name like '%";
      sqlText += mOfferingName;
      sqlText += L"%'";
    }

    if( this->mLimitAccountRange )
    {
      wchar_t limitClause[255];
      swprintf(limitClause, 255, L" and m.id_acc between %d and %d", this->mStartingAccountId, this->mEndingAccountId);
      sqlText += limitClause;
    }

    //select->SetMaxRecordCount(mNumberOfAccounts);
    select->SetBaseQuery(sqlText);
    plan.push_back(select);

    if( this->mLimitAccountRange )
      {
        wchar_t limitClause[255];
        swprintf(limitClause, 255, L" where id_acc between %d and %d", this->mStartingAccountId, this->mEndingAccountId);
        sqlText += limitClause;
      }

    DesignTimeExpressionGenerator *expGen1 = new DesignTimeExpressionGenerator();
    expGen1->SetName(L"expGen1");
    expGen1->SetProgram(
          L"CREATE PROCEDURE expGen1 "
          L"@nm_login NVARCHAR\n"
          L"@c_PayerIndex INTEGER OUTPUT\n"
          L"@c_Payer NVARCHAR OUTPUT\n"
          L"AS SET @c_PayerIndex = CAST(@@RECORDCOUNT as INTEGER)\n"
          L"SET @c_Payer = @nm_login\n"
      );
    plan.push_back(expGen1);
    plan.push_back(new DesignTimeChannel(select->GetOutputPorts()[0], expGen1->GetInputPorts()[0]));

    return expGen1;
}

DesignTimeOperator *CAudioConfMeterTestCtl::JoinAccountsToCalls(DesignTimePlan &plan, DesignTimeOperator *genCall, DesignTimeOperator *accountGen)
{
  DesignTimeHashJoin * join = new DesignTimeHashJoin();
  std::vector<std::wstring> idAccJoinKeys;
  idAccJoinKeys.push_back(L"c_PayerIndex");
  join->SetTableEquiJoinKeys(idAccJoinKeys);
  DesignTimeHashJoinProbeSpecification probeSpec;
  std::vector<std::wstring> idAvAccJoinKeys;
  idAvAccJoinKeys.push_back(L"c_ParentPayerIndex");
  probeSpec.SetEquiJoinKeys(idAvAccJoinKeys);
  probeSpec.SetJoinType(DesignTimeHashJoinProbeSpecification::INNER_JOIN);
  join->AddProbeSpecification(probeSpec);
  plan.push_back(join);

  plan.push_back(new DesignTimeChannel(accountGen->GetOutputPorts()[0], join->GetInputPorts()[L"table"]));
  plan.push_back(new DesignTimeChannel(genCall->GetOutputPorts()[0], join->GetInputPorts()[L"probe(0)"]));

  return join;
}
DesignTimeOperator *CAudioConfMeterTestCtl::GenerateMasterCallCopies(DesignTimePlan &plan, DesignTimeOperator *accountJoin)
{
    DesignTimeCopy * copy = new DesignTimeCopy(3);
    plan.push_back(copy);

    plan.push_back(new DesignTimeChannel(accountJoin->GetOutputPorts()[0], copy->GetInputPorts()[0]));

    return copy;
}
void CAudioConfMeterTestCtl::UnrollMasterCallData(DesignTimePlan &plan, DesignTimeOperator *copy, DesignTimeUnroll **unrollConnection, DesignTimeUnroll **unrollFeature)
{
    (*unrollConnection)= new DesignTimeUnroll();
    (*unrollConnection)->SetCount(L"numConnections");
    plan.push_back((*unrollConnection));
    plan.push_back(new DesignTimeChannel(copy->GetOutputPorts()[1], (*unrollConnection)->GetInputPorts()[0]));
    (*unrollFeature) = new DesignTimeUnroll();
    (*unrollFeature)->SetCount(L"numFeatures");
    plan.push_back((*unrollFeature));
    plan.push_back(new DesignTimeChannel(copy->GetOutputPorts()[2], (*unrollFeature)->GetInputPorts()[0]));
}
DesignTimeOperator *CAudioConfMeterTestCtl::GenerateConferenceData(DesignTimePlan &plan, DesignTimeOperator *copyOpr)
{
    DesignTimeExpression * callExpression = new DesignTimeExpression();

    wstring exprText;
    COleDateTime startDt(mStartDate);

    plan.push_back(callExpression);
    callExpression->SetName(L"callExpression");
    exprText = L"CREATE PROCEDURE genCall ";
    exprText += L"@baseDateTime DATETIME\n";
    exprText += L"@c_AccountingCode NVARCHAR OUTPUT \n";
    exprText += L"@c_ConferenceName NVARCHAR OUTPUT \n";
    exprText += L"@c_ConferenceSubject NVARCHAR OUTPUT \n";
    exprText += L"@c_OrganizationName NVARCHAR OUTPUT \n";
    exprText += L"@c_SpecialInfo NVARCHAR OUTPUT \n";
    exprText += L"@c_SchedulerComments NVARCHAR OUTPUT \n";
    exprText += L"@c_ScheduledConnections INTEGER OUTPUT \n";
    exprText += L"@c_ScheduledStartTime DATETIME OUTPUT \n";
    exprText += L"@c_ScheduledTimeGMTOffset DECIMAL OUTPUT \n";
    exprText += L"@c_ScheduledDuration INTEGER OUTPUT \n";
    exprText += L"@c_CancelledFlag NVARCHAR OUTPUT \n";
    exprText += L"@c_CancellationTime DATETIME OUTPUT \n";
    exprText += L"@c_ServiceLevel ENUM OUTPUT \n";
    exprText += L"@c_TerminationReason NVARCHAR OUTPUT \n";
    exprText += L"@c_SystemName NVARCHAR OUTPUT \n";
    exprText += L"@c_SalesPersonID NVARCHAR OUTPUT \n";
    exprText += L"@c_OperatorID NVARCHAR OUTPUT \n";
    exprText += L"AS\n";
    exprText += L"SET @c_AccountingCode = N'123'\n";
    exprText += L"SET @c_ConferenceName = N'TradeShow'\n";
    exprText += L"SET @c_ConferenceSubject = N'TradeShow'\n";
    exprText += L"SET @c_OrganizationName = N'MetraTech'\n";
    exprText += L"SET @c_SpecialInfo = N'SpecialInfo'\n";
    exprText += L"SET @c_SchedulerComments = N'ScheduleComments'\n";
    exprText += L"SET @c_ScheduledConnections = 10\n";
    exprText += L"SET @c_ScheduledStartTime = @baseDateTime\n";
    exprText += L"SET @c_ScheduledTimeGMTOffset = 0.0\n";
    exprText += L"SET @c_ScheduledDuration = 100\n";
    exprText += L"SET @c_CancelledFlag = N'N'\n";
    exprText += L"SET @c_CancellationTime = @baseDateTime\n";
    exprText += L"SET @c_ServiceLevel = #metratech.com/audioconfcommon/ServiceLevel/Basic#\n";
    exprText += L"SET @c_TerminationReason = N'Normal'\n";
    exprText += L"SET @c_SystemName = N'Bridge1'\n";
    exprText += L"SET @c_SalesPersonID = N'Amy'\n";
    exprText += L"SET @c_OperatorID = N'Mark'\n";
    
    callExpression->SetProgram(exprText);
    plan.push_back(new DesignTimeChannel(copyOpr->GetOutputPorts()[0], callExpression->GetInputPorts()[0]));

    return callExpression;
}

DesignTimeOperator *CAudioConfMeterTestCtl::GenerateConnectionData(DesignTimePlan &plan, DesignTimeUnroll *unrollConnection)
{
    DesignTimeExpression * connExpression = new DesignTimeExpression ();
    plan.push_back(connExpression);
    connExpression->SetName(L"connExpression");
    connExpression->SetProgram(
      L"CREATE PROCEDURE connExpression "
      L"@baseDateTime DATETIME\n"
      L"@c_UserBilled NVARCHAR OUTPUT\n"
      L"@c_UserName NVARCHAR OUTPUT\n"
      L"@c_UserRole ENUM OUTPUT\n"
      L"@c_OrganizationName NVARCHAR OUTPUT\n"
      L"@c_userphonenumber NVARCHAR OUTPUT\n"
      L"@c_specialinfo NVARCHAR OUTPUT\n"
      L"@c_CallType ENUM OUTPUT\n"
      L"@c_transport ENUM OUTPUT\n"
      L"@c_Mode ENUM OUTPUT\n"
      L"@c_ConnectTime DATETIME OUTPUT\n"
      L"@c_EnteredConferenceTime DATETIME OUTPUT\n"
      L"@c_ExitedConferenceTime DATETIME OUTPUT\n"
      L"@c_DisconnectTime DATETIME OUTPUT\n"
      L"@c_Transferred NVARCHAR OUTPUT\n"
      L"@c_TerminationReason NVARCHAR OUTPUT\n"
      L"@c_ISDNDisconnectCause INTEGER OUTPUT\n"
      L"@c_TrunkNumber INTEGER OUTPUT\n"
      L"@c_LineNumber INTEGER OUTPUT\n"
      L"@c_DNISDigits NVARCHAR OUTPUT\n"
      L"@c_ANIDigits NVARCHAR OUTPUT\n"
      L"AS\n"
      L"SET @c_UserBilled = N'N'\n"
      L"SET @c_UserName = N'Max'\n"
      L"SET @c_UserRole = #metratech.com/audioconfconnection/UserRole/CSR#\n"
      L"SET @c_OrganizationName = N'MetraTech'\n"
      L"SET @c_userphonenumber = N'781 839 8300'\n"
      L"SET @c_specialinfo = N'SpecialInfo'\n"
      L"SET @c_CallType = #metratech.com/audioconfconnection/CallType/Dial-In#\n"
      L"SET @c_transport = #metratech.com/audioconfconnection/transport/Toll#\n"
      L"SET @c_Mode = #metratech.com/audioconfconnection/Mode/Direct-Dialed#\n"
      L"SET @c_ConnectTime = dateadd('mi', CAST(rand() * CAST(10 as DOUBLE PRECISION) as DECIMAL), @baseDateTime)\n"
      L"SET @c_EnteredConferenceTime = @c_ConnectTime\n"
      L"SET @c_ExitedConferenceTime = dateadd('mi', CAST(rand() * CAST(10 as DOUBLE PRECISION) as DECIMAL), @c_ConnectTime)\n"
      L"SET @c_DisconnectTime = @c_ExitedConferenceTime\n"
      L"SET @c_Transferred = N'N'\n"
      L"SET @c_TerminationReason = N'Normal'\n"
      L"SET @c_ISDNDisconnectCause = 0\n"
      L"SET @c_TrunkNumber = 10\n"
      L"SET @c_LineNumber = 35\n"
      L"SET @c_DNISDigits = N'781 398 2000'\n"
      L"SET @c_ANIDigits = N'781 398 2242'\n");
 
    plan.push_back(new DesignTimeChannel(unrollConnection->GetOutputPorts()[0], connExpression->GetInputPorts()[0]));

    return connExpression;
}
DesignTimeOperator *CAudioConfMeterTestCtl::GenerateFeatureData(DesignTimePlan &plan, DesignTimeUnroll *unrollFeature)
{
    DesignTimeExpression * featureExpression = new DesignTimeExpression ();
    plan.push_back(featureExpression);
    featureExpression->SetName(L"featureExpression");
    featureExpression->SetProgram(
      L"CREATE PROCEDURE featureExpression "
      L"@baseDateTime DATETIME\n"
      L"@c_FeatureType ENUM OUTPUT\n"
      L"@c_Metric DECIMAL OUTPUT\n"
      L"@c_StartTime DATETIME OUTPUT\n"
      L"@c_EndTime DATETIME OUTPUT\n"
      L"AS\n"
      L"SET @c_FeatureType = #metratech.com/audioconffeature/FeatureType/Record#\n"
      L"SET @c_Metric = 2.0\n"
      L"SET @c_StartTime = @baseDateTime\n"
      L"SET @c_EndTime = dateadd('mi', CAST(rand() * CAST(10 as DOUBLE PRECISION) AS DECIMAL), @baseDateTime)");

    plan.push_back(new DesignTimeChannel(unrollFeature->GetOutputPorts()[0], featureExpression->GetInputPorts()[0]));

    return featureExpression;
}