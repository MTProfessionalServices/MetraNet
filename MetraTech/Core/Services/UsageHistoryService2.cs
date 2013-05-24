using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.BaseTypes;
using System.Reflection;
using MetraTech.DomainModel.ProductView;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop;
using System.Runtime.InteropServices;
using MetraTech.DataAccess;
using MetraTech.OnlineBill;
using MetraTech.DataAccess.MaterializedViews;
using MetraTech.Interop.COMDBObjects;
using HR = MetraTech.Interop.MTHierarchyReports;
using MetraTech.Interop.MTAuthExec;
using MetraTech.Interop.Rowset;
using MetraTech.DomainModel.Enums;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Interop.MTHierarchyReports;
using MetraTech.DomainModel.Common;
using BILL = MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.Enums.Core.Global;
using ProductViewLib = MetraTech.Interop.MTProductView;
using MetraTech.DomainModel.Enums.Core.Metratech_com_balanceadjustments;
using System.Collections;
using MetraTech.Debug.Diagnostics;


namespace MetraTech.Core.Services
{
  public partial interface IUsageHistoryService
  {
    //In order not to have interface changes old methods are left intact and methods with new signature
    // are renamed to 2
    #region ByFolder new methods
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetByFolderReportLevel2(AccountIdentifier owner, BILL.DateRangeSlice accountEffectiveDate, AccountIdentifier folder, ReportParameters repParams, out ReportLevel reportData);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetByFolderReportLevelChildren2(AccountIdentifier owner, BILL.DateRangeSlice accountEffectiveDate, AccountIdentifier folder, ReportParameters repParams, ref MTList<ReportLevel> children);
    #endregion
  }

  public partial class UsageHistoryService
  {
    const string METRAVIEW_QUERY_FOLDER2 = "Queries\\MetraViewServices\\UsageHistoryService2";

    #region ByFolder new methods
    [OperationCapability("Manage Account Hierarchies")]
    public void GetByFolderReportLevel2(AccountIdentifier owner, BILL.DateRangeSlice accountEffectiveDate, AccountIdentifier folder, ReportParameters repParams, out ReportLevel reportData)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetByFolderReportLevel2"))
      {
        mLogger.LogInfo("Executing GetByFolderReportLevel Method in UsageHistoryService");

        try
        {
          #region Actual Implementation

          #region Validate Input Parameters.
          if (repParams == null)
          {
            throw new MASBasicException("Invalid argument: Report Parameters is null");
          }

          if (repParams.DateRange == null)
          {
            throw new MASBasicException("Invalid ReportParameter property: DateRange.");
          }

          if (owner == null)
          {
            throw new MASBasicException("Invalid argument: owner cannot be null");
          }

          int ownerId = AccountIdentifierResolver.ResolveAccountIdentifier(owner);

          if (ownerId <= 0)
          {
            throw new MASBasicException("Unable to resolve Account Information.");
          }

          int folderId = -1;
          if (folder != null)
          {
            folderId = AccountIdentifierResolver.ResolveAccountIdentifier(folder);

            if (folderId <= 0)
            {
              throw new MASBasicException("Unable to resolve folder information");
            }
          }
          #endregion

          #region Check Caller Has "Manage Account Hierarchies" capability

          if (!HasManageAccHeirarchyAccess(ownerId, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.READ, MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
          {
            throw new MASBasicException("Account access denied");
          }

          #endregion

          ReportLevel repLevelData = new ReportLevel();

          string queryString = string.Empty;

          using (IMTConnection conn = ConnectionManager.CreateConnection(METRAVIEW_QUERY_FOLDER2, true))
          {
            using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
            {
              queryAdapter.Item = new MTQueryAdapterClass();
              queryAdapter.Item.Init(METRAVIEW_QUERY_FOLDER2);

              if (repParams.ReportView == ReportViewType.OnlineBill)
              {
                if (folder == null) //|| ownerId == folderId)
                {
                  queryAdapter.Item.SetQueryTag(IsDataMartEnabled() ? "__GET_LEASTCOMMONANCESTOROFPAYEES_DATAMART_USAGE_HISTORY_SERVICE_2__" : "__GET_LEASTCOMMONANCESTOROFPAYEES_USAGE_HISTORY_SERVICE_2__");

                  using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                  {
                    stmt.AddParam("idAcc", MTParameterType.Integer, ownerId);

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {

                      if (reader.Read())
                      {
                        folderId = reader.GetInt32("id_ancestor");
                      }
                      else
                      {
                        reportData = repLevelData;

                        mLogger.LogInfo("GetByFolderReportLevel: Nothing to report for account {0}.", ownerId);
                        return;
                      }
                    }

                  }
                }

                queryString = IsDataMartEnabled() ? "__GET_BYFOLDER_REPORT_FOR_PAYEES_DATAMART_USAGE_HISTORY_SERVICE_2__" : "__GET_BYFOLDER_REPORT_FOR_PAYEES_USAGE_HISTORY_SERVICE_2__";
              }
              else
              {
                if (folder == null)
                {
                  folderId = ownerId;
                }

                queryString = IsDataMartEnabled() ? "__GET_BYFOLDER_REPORT_FOR_DESCENDENTS_DATAMART_USAGE_HISTORY_SERVICE_2__" : "__GET_BYFOLDER_REPORT_FOR_DESCENDENTS_USAGE_HISTORY_SERVICE_2__";
              }
            }
          }

          if (queryString.Equals(string.Empty))
          {
            throw new MASBasicException("Cannot find QueryString");
          }

          using (IMTConnection conn = ConnectionManager.CreateConnection(METRAVIEW_QUERY_FOLDER2, true))
          {
            using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
            {
              queryAdapter.Item = new MTQueryAdapterClass();
              queryAdapter.Item.Init(METRAVIEW_QUERY_FOLDER2);

              queryAdapter.Item.SetQueryTag(queryString);

              int level = 0;
              queryAdapter.Item.AddParam("%%TIME_PREDICATE%%", GetQueryPredicate(repParams.DateRange, conn.ConnectionInfo.IsOracle, ref level), true);
              queryAdapter.Item.AddParam("%%LIKE_OR_NOT_LIKE%%", repParams.UseSecondPassData ? " NOT LIKE " : " LIKE ", true);

              using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetQuery()))
              {
                stmt.SetResultSetCount(2);

                if (repParams.ReportView == ReportViewType.OnlineBill)
                {
                  stmt.AddParam("idPayer", MTParameterType.Integer, ownerId);
                }

                // Original MetraView logic to get the dates.
                DateTime startDt, endDt;
                if (accountEffectiveDate != null)
                {
                  GetTimeSpan(accountEffectiveDate, out startDt, out endDt);
                }
                else if (repParams.ReportView == ReportViewType.OnlineBill)
                {
                  startDt = MetraTime.Min;
                  endDt = MetraTime.Max;
                }
                else
                {
                  GetTimeSpan(repParams.DateRange, out startDt, out endDt);
                }

                if (repParams.ReportView == ReportViewType.OnlineBill)
                {
                  BILL.PayerAccountSlice payerSlice = new BILL.PayerAccountSlice();
                  payerSlice.PayerID = new AccountIdentifier(ownerId);

                  repLevelData.OwnerSlice = payerSlice;

                  BILL.PayerAndPayeeSlice payeeSlice = new BILL.PayerAndPayeeSlice();
                  payeeSlice.PayerAccountId = new AccountIdentifier(ownerId);
                  payeeSlice.PayeeAccountId = new AccountIdentifier(folderId);

                  repLevelData.FolderSlice = payeeSlice;
                }
                else
                {
                  BILL.DescendentPayeeSlice descendentSlice = new BILL.DescendentPayeeSlice();
                  descendentSlice.AncestorAccountId = new AccountIdentifier(folderId);
                  descendentSlice.StartDate = MetraTime.Min;
                  descendentSlice.EndDate = MetraTime.Max;

                  repLevelData.OwnerSlice = descendentSlice;

                  BILL.PayeeAccountSlice payeeSlice = new PayeeAccountSlice();
                  payeeSlice.PayeeID = new AccountIdentifier(folderId);

                  repLevelData.FolderSlice = payeeSlice;
                }

                stmt.AddParam("numGenerations", MTParameterType.Integer, 0);
                stmt.AddParam("idAcc", MTParameterType.Integer, folderId);
                stmt.AddParam("dtBegin", MTParameterType.DateTime, startDt);
                stmt.AddParam("dtEnd", MTParameterType.DateTime, endDt);
                stmt.AddParam("idLang", MTParameterType.Integer, Convert.ToInt32(EnumHelper.GetValueByEnum(repParams.Language, 1)));

                level = 0;
                AddSliceParameters(stmt, repParams.DateRange, ref level);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                  while (reader.Read())
                  {
                    repLevelData.ID = folderId;
                    PopulateReportLevelData(reader, repParams.Language, repLevelData);
                    repLevelData.Name = reader.GetString("AccountName");
                    PopulateDisplayAmount(repLevelData, repParams);
                    PopulatePreBillAdjustmentDisplayAmount(repLevelData, repParams);
                    PopulateAccountEffectiveDates(reader, repLevelData);
                  }

                  reader.NextResult();

                  ParseChargeQuery(repLevelData, reader, repParams);

                }
              }
            }
          }

          reportData = repLevelData;

          #endregion
        }
        catch (MASBasicException masE)
        {
          mLogger.LogException("Error getting report level by folder. ", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Error getting report level by folder. ", e);

          throw new MASBasicException("Error getting report level by folder. ");
        }
      }
    }

    [OperationCapability("Manage Account Hierarchies")]
    public void GetByFolderReportLevelChildren2(AccountIdentifier owner, BILL.DateRangeSlice accountEffectiveDate, AccountIdentifier folder, ReportParameters repParams, ref MTList<ReportLevel> children)
    {
      mLogger.LogInfo("Executing GetByFolderReportLevelChildren Method in UsageHistoryService");

      try
      {
        using (MetraTech.Debug.Diagnostics.HighResolutionTimer timer = new MetraTech.Debug.Diagnostics.HighResolutionTimer("GetByFolderReportLevelChildren", 10000))
        {
          #region Actual Implementation

          #region Validate Input Parameters.
          if (repParams == null)
          {
            throw new MASBasicException("Invalid argument: Report Parameters is null");
          }

          if (repParams.DateRange == null)
          {
            throw new MASBasicException("Invalid ReportParameter property: DateRange.");
          }

          if (owner == null)
          {
            throw new MASBasicException("Invalid argument: owner cannot be null");
          }

          int ownerId = AccountIdentifierResolver.ResolveAccountIdentifier(owner);

          if (ownerId <= 0)
          {
            throw new MASBasicException("Unable to resolve Account Information.");
          }

          int folderId = -1;
          if (folder != null)
          {
            folderId = AccountIdentifierResolver.ResolveAccountIdentifier(folder);

            if (folderId <= 0)
            {
              throw new MASBasicException("Unable to resolve folder information");
            }
          }
          #endregion

          #region Check Caller Has "Manage Account Hierarchies" capability

          if (!HasManageAccHeirarchyAccess(ownerId, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.READ, MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
          {
            throw new MASBasicException("Account access denied");
          }

          #endregion

          using (IMTConnection conn = ConnectionManager.CreateConnection(METRAVIEW_QUERY_FOLDER2, true))
          {
            string queryString = string.Empty;

            using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
            {
              queryAdapter.Item = new MTQueryAdapterClass();
              queryAdapter.Item.Init(METRAVIEW_QUERY_FOLDER2);

              if (repParams.ReportView == ReportViewType.OnlineBill)
              {
                if (folder == null) //|| ownerId == folderId)
                {
                  queryAdapter.Item.SetQueryTag(IsDataMartEnabled() ? "__GET_LEASTCOMMONANCESTOROFPAYEES_DATAMART_USAGE_HISTORY_SERVICE_2__" : "__GET_LEASTCOMMONANCESTOROFPAYEES_USAGE_HISTORY_SERVICE_2__");

                  using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                  {
                    stmt.AddParam("idAcc", MTParameterType.Integer, ownerId);

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {

                      if (reader.Read())
                      {
                        folderId = reader.GetInt32("id_ancestor");
                      }
                      else
                      {
                        mLogger.LogInfo("GetByFolderReportLevel: Nothing to report for account {0}.", ownerId);
                        return;
                      }
                    }

                  }
                }

                queryAdapter.Item.SetQueryTag(IsDataMartEnabled() ? "__GET_BYFOLDER_REPORT_FOR_PAYEES_SUMMARY_DATAMART_USAGE_HISTORY_SERVICE_2__" : "__GET_BYFOLDER_REPORT_FOR_PAYEES_SUMMARY_USAGE_HISTORY_SERVICE_2__");
              }
              else
              {
                if (folder == null)
                {
                  folderId = ownerId;
                }

                queryAdapter.Item.SetQueryTag(IsDataMartEnabled() ? "__GET_BYFOLDER_REPORT_FOR_DESCENDENTS_SUMMARY_DATAMART_USAGE_HISTORY_SERVICE_2__" : "__GET_BYFOLDER_REPORT_FOR_DESCENDENTS_SUMMARY_USAGE_HISTORY_SERVICE_2__");
              }

              int level = 0;
              queryAdapter.Item.AddParam("%%LIKE_OR_NOT_LIKE%%", repParams.UseSecondPassData ? " NOT LIKE " : " LIKE ", true);
              queryAdapter.Item.AddParam("%%TIME_PREDICATE%%", GetQueryPredicate(repParams.DateRange, queryAdapter.Item.IsOracle(), ref level), true);
              queryString = queryAdapter.Item.GetRawSQLQuery(true);
            }

            using (IMTPreparedFilterSortStatement stmt = conn.CreatePreparedFilterSortStatement(queryString))
            {
              int level = 0;
              AddSliceParameters(stmt, repParams.DateRange, ref level);

              if (repParams.ReportView == ReportViewType.OnlineBill)
              {
                stmt.AddParam("idPayer", MTParameterType.Integer, ownerId);
              }

              ApplyFilterSortCriteria<ReportLevel>(stmt, children);

              stmt.AddParam("idAcc", MTParameterType.Integer, folderId);

              // Original MetraView logic to get the dates.
              DateTime startDt, endDt;
              if (accountEffectiveDate != null)
              {
                GetTimeSpan(accountEffectiveDate, out startDt, out endDt);
              }
              else if (repParams.ReportView == ReportViewType.OnlineBill)
              {
                startDt = MetraTime.Min;
                endDt = MetraTime.Max;
              }
              else
              {
                GetTimeSpan(repParams.DateRange, out startDt, out endDt);
              }

              stmt.AddParam("dtBegin", MTParameterType.DateTime, startDt);
              stmt.AddParam("dtEnd", MTParameterType.DateTime, endDt);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                while (reader.Read())
                {
                  ReportLevel repLevelData = new ReportLevel();
                  repLevelData.ID = folderId;

                  int accountId = reader.GetInt32("AccountId");

                  if (repParams.ReportView == ReportViewType.OnlineBill)
                  {
                    BILL.PayerAccountSlice payerSlice = new BILL.PayerAccountSlice();
                    payerSlice.PayerID = new AccountIdentifier(ownerId);

                    repLevelData.OwnerSlice = payerSlice;

                    BILL.PayerAndPayeeSlice payeeSlice = new BILL.PayerAndPayeeSlice();
                    payeeSlice.PayerAccountId = new AccountIdentifier(ownerId);
                    payeeSlice.PayeeAccountId = new AccountIdentifier(accountId);

                    repLevelData.FolderSlice = payeeSlice;
                  }
                  else
                  {
                    BILL.DescendentPayeeSlice descendentSlice = new BILL.DescendentPayeeSlice();
                    descendentSlice.AncestorAccountId = new AccountIdentifier(folderId);
                    descendentSlice.StartDate = MetraTime.Min;
                    descendentSlice.EndDate = MetraTime.Max;

                    repLevelData.OwnerSlice = descendentSlice;

                    BILL.PayeeAccountSlice payeeSlice = new PayeeAccountSlice();
                    payeeSlice.PayeeID = new AccountIdentifier(accountId);

                    repLevelData.FolderSlice = payeeSlice;
                  }

                  PopulateReportLevelData(reader, repParams.Language, repLevelData);
                  repLevelData.Name = reader.GetString("AccountName");
                  PopulateDisplayAmount(repLevelData, repParams);
                  PopulatePreBillAdjustmentDisplayAmount(repLevelData, repParams);
                  PopulateAccountEffectiveDates(reader, repLevelData);
                  children.Items.Add(repLevelData);
                }
              }

              children.TotalRows = stmt.TotalRows;
            }
          }

          #endregion
        }
      }
      catch (MASBasicException masE)
      {
        mLogger.LogException("Error getting report level children by folder. ", masE);
        throw;
      }
      catch (Exception e)
      {
        mLogger.LogException("Error getting report level by folder. ", e);

        throw new MASBasicException("Error getting report level by folder. ");
      }
    }

    private void PopulateAccountEffectiveDates(IMTDataReader reader, ReportLevel repLevelData)
    {
      BILL.DateRangeSlice accountEffectiveDate = new BILL.DateRangeSlice();
      accountEffectiveDate.Begin = reader.GetDateTime("AccountStart");
      accountEffectiveDate.End = reader.GetDateTime("AccountEnd");
      repLevelData.AccountEffectiveDate = accountEffectiveDate;
    }

    #endregion

  }
}
