using System;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Text;
using System.Transactions;
using System.Reflection;
using MetraTech.Accounts;
using MetraTech.Accounts.Type;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.Adjustments;
using MetraTech.DataAccess;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Metratech_com;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.ProductView;
using MetraTech.Interop.IMTAccountType;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Security.Crypto;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.Core.Services
{
  [ServiceContract]
  public interface IAdjustmentsService
  {
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAdjustedTransactions(ref MTList<AdjustedTransaction> adjustedTransactions);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAdjustedTransactionDetail(long sessionId, out AdjustedTransactionDetail detail);

    //[Obsolete("Left for backward compatibility. Does the same as GetAccountCredits")]
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetMiscellaneousAdjustments(ref MTList<MiscellaneousAdjustment> miscAdjustments, bool pending);

    /// <summary>
    /// Get all account credits from the system
    /// </summary>
    /// <param name="accountCredits">List for storage account credits</param>
    /// <param name="pending">If true - choose records with pending status</param>
    /// <remarks>Added within the scope of ESR-4446</remarks>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAccountCredits(ref MTList<Metratech_com_AccountCreditProductView> accountCredits, bool pending);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void ApproveAdjustments(List<long> sessionids);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteAdjustments(List<long> sessionids);

    /// <summary>Approve Account Credits
    /// </summary>
    /// <param name="sessionIds"></param>
    /// <param name="userId"></param>
    /// <remarks>Added within the scope of ESR-4446</remarks>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void ApproveAccountCredits(List<long> sessionIds, int userId);

    //[Obsolete("Left for backward compatibility. Does the same as ApproveAccountCredits")]
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void ApproveMiscellaneousAdjustments(List<long> sessionIds, int userId);

    /// <summary>Deny Account Credits
    /// </summary>
    /// <param name="sessionIds"></param>
    /// <param name="userId"></param>
    /// <remarks>Added within the scope of ESR-4446</remarks>
    [OperationContract]
    void DenyAccountCredits(List<long> sessionIds, int userId);

    //[Obsolete("Left for backward compatibility. Does the same as DenyAccountCredits")]
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DenyMiscellaneousAdjustments(List<long> sessionIds, int userId);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void ApproveAllAdjustedTransactions(ref MTList<AdjustedTransaction> adjTransactions);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteAllAdjustedTransactions(ref MTList<AdjustedTransaction> adjTransactions);

    /// <summary>Approve All Account Credits
    /// </summary>
    /// <param name="accountCredits">List for storage account credits</param>
    /// <param name="userId"></param>
    /// <remarks>Added within the scope of ESR-4446</remarks>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void ApproveAllAccountCredits(ref MTList<Metratech_com_AccountCreditProductView> accountCredits, int userId);

    //[Obsolete("Left for backward compatibility. Does the same as ApproveAllAccountCredits")]
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void ApproveAllMiscellaneousAdjusments(ref MTList<MiscellaneousAdjustment> miscAdjustments, int userId);

    /// <summary>Deny All Account Credits
    /// </summary>
    /// <param name="accountCredits">List for storage account credits</param>
    /// <param name="userId"></param>
    /// <remarks>Added within the scope of ESR-4446</remarks>
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DenyAllAccountCredits(ref MTList<Metratech_com_AccountCreditProductView> accountCredits, int userId);

    //[Obsolete("Left for backward compatibility. Does the same as DenyAllAccountCredits")]
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DenyAllMiscellaneousAdjusments(ref MTList<MiscellaneousAdjustment> miscAdjustments, int userId);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetOrphanedAdjustments(ref MTList<OrphanedAdjustment> orphanedAdjustments);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetOrphanedAdjustmentDetails(long sessionId, out OrphanedAdjustmentDetail detail);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void ApproveOrphanAdjustments(List<long> sessionIds);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DenyOrphanAdjustments(List<long> sessionIds);

  }

  [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Multiple, InstanceContextMode = InstanceContextMode.Single)]
  public class AdjustmentsService : CMASServiceBase, IAdjustmentsService
  {
    private const string ADJUSTMENT_QUERY_FOLDER = @"queries\Adjustments";
    private static Logger mLogger = new Logger("[AdjustmentsService]");

    #region AdjustmentsService Methods
    [OperationCapability("Manage Adjustments")]
    public void GetAdjustedTransactions(ref MTList<AdjustedTransaction> adjTransactions)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAdjustedTransactions"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(ADJUSTMENT_QUERY_FOLDER))
          {
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(ADJUSTMENT_QUERY_FOLDER, "__GET_ADJUSTED_TRANSACTIONS_FILTERSORT__"))
            {
              ApplyFilterSortCriteria<AdjustedTransaction>(stmt, adjTransactions);
              stmt.AddParam("%%ID_LANG%%", GetSessionContext().LanguageID);

              using (IMTDataReader adjReader = stmt.ExecuteReader())
              {
                while (adjReader.Read())
                {
                  AdjustedTransaction tx = new AdjustedTransaction();
                  tx.PITemplateDisplayName = adjReader.GetString("PITemplateDisplayName");
                  tx.AdjustmentCreationDate = adjReader.GetDateTime("AdjustmentCreationDate");
                  string status = adjReader.GetString("Status");
                  if (status.ToUpper().Equals("P"))
                    tx.Status = "Pending";
                  else if (status.ToUpper().Equals("A"))
                    tx.Status = "Approved";
                  tx.Amount = adjReader.GetDecimal("Amount");
                  tx.Description = adjReader.IsDBNull("Description") ? "" : adjReader.GetString("Description");
                  tx.PendingPostbillAdjAmt = adjReader.GetDecimal("PendingPostbillAdjAmt");
                  tx.PendingPrebillAdjAmt = adjReader.GetDecimal("PendingPrebillAdjAmt");
                  tx.PostbillAdjAmt = adjReader.GetDecimal("PostbillAdjAmt");
                  tx.PrebillAdjAmt = adjReader.GetDecimal("PrebillAdjAmt");
                  tx.SessionId = adjReader.GetInt64("SessionId");
                  tx.UsernamePayee = adjReader.GetString("UsernamePayee");
                  tx.UsernamePayer = adjReader.GetString("UsernamePayer");
                  if (!adjReader.IsDBNull("ParentSessionId"))
                    tx.ParentSessionId = adjReader.GetInt64("ParentSessionId");
                  adjTransactions.Items.Add(tx);
                }
                adjTransactions.TotalRows = stmt.TotalRows;
              }
            }
          }
        }
        catch (CommunicationException e)
        {
          mLogger.LogException("Cannot retrieve adjusted transactions from the system ", e);
          throw;
        }

        catch (Exception e)
        {
          mLogger.LogException("Cannot retrieve adjusted transactions from the system ", e);
          throw new MASBasicException("Cannot retrieve adjusted transactions from the system");
        }
      }
    }

    [OperationCapability("Manage Adjustments")]
    public void GetAdjustedTransactionDetail(long sessionId, out AdjustedTransactionDetail detail)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAdjustedTransactionDetail"))
      {
        detail = null;
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(ADJUSTMENT_QUERY_FOLDER))
          {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(ADJUSTMENT_QUERY_FOLDER, "__GET_ADJ_TRANSACTION_DETAIL__"))
            {
              stmt.AddParam("%%ID_LANG_CODE%%", GetSessionContext().LanguageID);
              stmt.AddParam("%%SESSION_ID%%", sessionId);
              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                if (rdr.Read())
                {
                  detail = new AdjustedTransactionDetail();
                  detail.AdjTrxId = rdr.GetInt32("AdjTrxId");
                  detail.AdjustmentAmount = rdr.GetDecimal("AdjustmentAmount");
                  detail.AdjustmentCreationDate = rdr.GetDateTime("AdjustmentCreationDate");
                  detail.AdjustmentCurrency = (SystemCurrencies)EnumHelper.GetEnumByValue(typeof(SystemCurrencies), rdr.GetString("AdjustmentCurrency"));
                  string status = rdr.GetString("Status");
                  if (status.ToUpper().Equals("P"))
                    detail.Status = "Pending";
                  else if (status.ToUpper().Equals("A"))
                    detail.Status = "Approved";
                  detail.AdjustmentTemplateDisplayName = rdr.GetString("AdjustmentTemplateDisplayName");
                  detail.AdjustmentType = rdr.GetInt32("AdjustmentType");
                  detail.AdjustmentUsageInterval = rdr.GetInt32("AdjustmentUsageInterval");
                  detail.AtomicPostbillAdjAmt = rdr.GetDecimal("AtomicPostbillAdjAmt");
                  detail.AtomicPostbillAdjedAmt = rdr.GetDecimal("AtomicPostbillAdjedAmt");
                  detail.AtomicPostbillCntyTaxAdjAmt = rdr.GetDecimal("AtomicPostbillCntyTaxAdjAmt");
                  detail.AtomicPostbillFedTaxAdjAmt = rdr.GetDecimal("AtomicPostbillFedTaxAdjAmt");
                  detail.AtomicPostbillLocalTaxAdjAmt = rdr.GetDecimal("AtomicPostbillLocalTaxAdjAmt");
                  detail.AtomicPostbillOtherTaxAdjAmt = rdr.GetDecimal("AtomicPostbillOtherTaxAdjAmt");
                  detail.AtomicPostbillStateTaxAdjAmt = rdr.GetDecimal("AtomicPostbillStateTaxAdjAmt");
                  detail.AtomicPostbillTotalTaxAdjAmt = rdr.GetDecimal("AtomicPostbillTotalTaxAdjAmt");
                  detail.AtomicPrebillAdjAmt = rdr.GetDecimal("AtomicPrebillAdjAmt");
                  detail.AtomicPrebillAdjedAmt = rdr.GetDecimal("AtomicPrebillAdjedAmt");
                  detail.AtomicPrebillCntyTaxAdjAmt = rdr.GetDecimal("AtomicPrebillCntyTaxAdjAmt");
                  detail.AtomicPrebillFedTaxAdjAmt = rdr.GetDecimal("AtomicPrebillFedTaxAdjAmt");
                  detail.AtomicPrebillLocalTaxAdjAmt = rdr.GetDecimal("AtomicPrebillLocalTaxAdjAmt");
                  detail.AtomicPrebillOtherTaxAdjAmt = rdr.GetDecimal("AtomicPrebillOtherTaxAdjAmt");
                  detail.AtomicPrebillStateTaxAdjAmt = rdr.GetDecimal("AtomicPrebillStateTaxAdjAmt");
                  detail.AtomicPrebillTotalTaxAdjAmt = rdr.GetDecimal("AtomicPrebillTotalTaxAdjAmt");
                  detail.CanAdjust = rdr.GetBoolean("CanAdjust");
                  detail.CanManageAdjustments = rdr.GetBoolean("CanManageAdjustments");
                  detail.CanManagePostbillAdjustment = rdr.GetBoolean("CanManagePostbillAdjustment");
                  detail.CanManagePrebillAdjustment = rdr.GetBoolean("CanManagePrebillAdjustment");
                  detail.CanRebill = rdr.GetBoolean("CanRebill");
                  detail.CompoundPostbillAdjAmt = rdr.GetDecimal("CompoundPostbillAdjAmt");
                  detail.CompoundPostbillAdjedAmt = rdr.GetDecimal("CompoundPostbillAdjedAmt");
                  detail.CompoundPostbillCntyTaxAdjAmt = rdr.GetDecimal("CompoundPostbillCntyTaxAdjAmt");
                  detail.CompoundPostbillFedTaxAdjAmt = rdr.GetDecimal("CompoundPostbillFedTaxAdjAmt");
                  detail.CompoundPostbillLocalTaxAdjAmt = rdr.GetDecimal("CompoundPostbillLocalTaxAdjAmt");
                  detail.CompoundPostbillOtherTaxAdjAmt = rdr.GetDecimal("CompoundPostbillOtherTaxAdjAmt");
                  detail.CompoundPostbillStateTaxAdjAmt = rdr.GetDecimal("CompoundPostbillStateTaxAdjAmt");
                  detail.CompoundPostbillTotalTaxAdjAmt = rdr.GetDecimal("CompoundPostbillTotalTaxAdjAmt");
                  detail.CompoundPrebillAdjAmt = rdr.GetDecimal("CompoundPrebillAdjAmt");
                  detail.CompoundPrebillAdjedAmt = rdr.GetDecimal("CompoundPrebillAdjedAmt");
                  detail.CompoundPrebillCntyTaxAdjAmt = rdr.GetDecimal("CompoundPrebillCntyTaxAdjAmt");
                  detail.CompoundPrebillFedTaxAdjAmt = rdr.GetDecimal("CompoundPrebillFedTaxAdjAmt");
                  detail.CompoundPrebillLocalTaxAdjAmt = rdr.GetDecimal("CompoundPrebillLocalTaxAdjAmt");
                  detail.CompoundPrebillOtherTaxAdjAmt = rdr.GetDecimal("CompoundPrebillOtherTaxAdjAmt");
                  detail.CompoundPrebillTotalTaxAdjAmt = rdr.GetDecimal("CompoundPrebillTotalTaxAdjAmt");
                  detail.CompundPrebillStateTaxAdjAmt = rdr.GetDecimal("CompoundPrebillStateTaxAdjAmt");
                  detail.CountyTaxAmount = rdr.IsDBNull("CountyTaxAmount") ? 0 : rdr.GetDecimal("CountyTaxAmount");
                  detail.Description = rdr.IsDBNull("Description") ? "" : rdr.GetString("Description");
                  detail.DivAmount = rdr.IsDBNull("DivAmount") ? 0 : rdr.GetDecimal("DivAmount");
                  if (!rdr.IsDBNull("DivCurrency"))
                    detail.DivCurrency = (SystemCurrencies)EnumHelper.GetEnumByValue(typeof(SystemCurrencies), rdr.GetString("DivCurrency"));

                  detail.FederalTaxAmount = rdr.IsDBNull("FederalTaxAmount") ? 0 : rdr.GetDecimal("FederalTaxAmount");
                  int languageCode = rdr.GetInt32("LanguageCode");
                  detail.LanguageCode = (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), languageCode.ToString());
                  detail.LocalTaxAmount = rdr.IsDBNull("LocalTaxAmount") ? 0 : rdr.GetDecimal("LocalTaxAmount");
                  detail.ModifedDate = rdr.GetDateTime("ModifedDate");
                  detail.NumPostbillAdjustedChildren = rdr.GetInt32("NumPostbillAdjustedChildren");
                  detail.NumPrebillAdjustedChildren = rdr.GetInt32("NumPrebillAdjustedChildren");
                  detail.OtherTaxAmount = rdr.IsDBNull("OtherTaxAmount") ? 0 : rdr.GetDecimal("OtherTaxAmount");
                  if (!rdr.IsDBNull("ParentSessionId"))
                    detail.ParentSessionId = rdr.GetInt64("ParentSessionId");

                  detail.PendingPostbillAdjAmt = rdr.GetDecimal("PendingPostbillAdjAmt");
                  detail.PendingPrebillAdjAmt = rdr.GetDecimal("PendingPrebillAdjAmt");
                  detail.PITemplateDisplayName = rdr.GetString("PITemplateDisplayName");
                  detail.PostbillAdjAmt = rdr.GetDecimal("PostbillAdjAmt");
                  detail.PostbillAdjDefaultDesc = rdr.IsDBNull("PostbillAdjDefaultDesc") ? "" : rdr.GetString("PostbillAdjDefaultDesc");
                  detail.PostbillAdjustmentDescription = rdr.IsDBNull("PostbillAdjustmentDescription") ? "" : rdr.GetString("PostbillAdjustmentDescription");
                  detail.PrebillAdjAmt = rdr.GetDecimal("PrebillAdjAmt");
                  detail.PrebillAdjDefaultDesc = rdr.IsDBNull("PrebillAdjDefaultDesc") ? "" : rdr.GetString("PrebillAdjDefaultDesc");
                  detail.PrebillAdjustmentDescription = rdr.IsDBNull("PrebillAdjustmentDescription") ? "" : rdr.GetString("PrebillAdjustmentDescription");
                  detail.ReasonCodeDescription = rdr.GetString("ReasonCodeDescription");
                  detail.ReasonCodeDisplayName = rdr.GetString("ReasonCodeDisplayName");
                  detail.ReasonCodeId = rdr.GetInt32("ReasonCodeId");
                  detail.ReasonCodeName = rdr.GetString("ReasonCodeName");
                  detail.SessionId = rdr.GetInt64("SessionId");
                  detail.StateTaxAmount = rdr.IsDBNull("StateTaxAmount") ? 0 : rdr.GetDecimal("StateTaxAmount");
                  detail.UsageIntervalId = rdr.GetInt32("UsageIntervalId");
                  detail.UserNamePayee = rdr.GetString("UserNamePayee");
                  detail.UserNamePayer = rdr.GetString("UserNamePayer");
                }
              }
            }
          }
        }
        catch (CommunicationException e)
        {
          mLogger.LogException("Cannot retrieve adjusted transaction details from the system ", e);
          throw;
        }

        catch (Exception e)
        {
          mLogger.LogException("Cannot retrieve adjusted transaction details from the system ", e);
          throw new MASBasicException("Cannot retrieve adjusted transaction details from the system");
        }
      }
    }

    [OperationCapability("Manage Adjustments")]
    public void ApproveAdjustments(List<long> sessionIds)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ApproveAdjustments"))
      {
        mLogger.LogDebug("About to approve charge adjustments.");
        try
        {
          AdjustmentCatalog adjCatalog = new AdjustmentCatalog();
          MetraTech.Interop.MTAuth.IMTSessionContext sessionContext = GetSessionContext();
          IMTProductCatalog prodCat = new MTProductCatalogClass();
          prodCat.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);
          adjCatalog.Initialize(prodCat.GetSessionContext());

          // Create TransactionSet using the ChargeAdjustment Sessions
          MetraTech.Interop.GenericCollection.IMTCollection sessions = new MetraTech.Interop.GenericCollection.MTCollectionClass();
          foreach (long s in sessionIds)
            sessions.Add(s);

          IAdjustmentTransactionSet transSet = adjCatalog.CreateAdjustmentTransactions(sessions);
          var approvedAdjustmentRowset = transSet.ApproveAndSave(null);
        }
        catch (MASBasicException mas)
        {
          mLogger.LogError("Ar error occurred approving adjustments ", mas);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogError("An error occurred approving adjustments ", e);
          throw new MASBasicException("An error occurred approving adjustments.");
        }
        mLogger.LogDebug("Approved charge adjustments.");
      }
    }

    [OperationCapability("Manage Adjustments")]
    public void DeleteAdjustments(List<long> sessionIds)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DeleteAdjustments"))
      {
        mLogger.LogDebug("About to delete charge adjustments.");

        try
        {
          AdjustmentCatalog adjCatalog = new AdjustmentCatalog();
          MetraTech.Interop.MTAuth.IMTSessionContext sessionContext = GetSessionContext();
          IMTProductCatalog prodCat = new MTProductCatalogClass();
          prodCat.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);
          adjCatalog.Initialize(prodCat.GetSessionContext());

          // Create TransactionSet using the ChargeAdjustment Sessions
          MetraTech.Interop.GenericCollection.IMTCollection sessions = new MetraTech.Interop.GenericCollection.MTCollectionClass();
          foreach (long s in sessionIds)
            sessions.Add(s);

          IAdjustmentTransactionSet transSet = adjCatalog.CreateAdjustmentTransactions(sessions);
          var approvedAdjustmentRowset = transSet.DeleteAndSave(null);
        }
        catch (MASBasicException mas)
        {
          mLogger.LogError("Ar error occurred deleting adjustments ", mas);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogError("An error occurred deleting adjustments ", e);
          throw new MASBasicException("An error occurred deleting adjustments.");
        }
        mLogger.LogDebug("Deleted charge adjustments.");
      }
    }

    [OperationCapability("Manage Adjustments")]
    public void ApproveAllAdjustedTransactions(ref MTList<AdjustedTransaction> adjTransactions)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ApproveAllAdjustedTransactions"))
      {
        mLogger.LogDebug("Approving the relavent adjusted transactions.");
        GetAdjustedTransactions(ref adjTransactions);
        List<long> sessionIds = adjTransactions.Items.Select(adj => adj.SessionId).ToList();
        ApproveAdjustments(sessionIds);
        mLogger.LogDebug("Approved the relavent adjusted transactions.");
      }
    }

    [OperationCapability("Manage Adjustments")]
    public void DeleteAllAdjustedTransactions(ref MTList<AdjustedTransaction> adjTransactions)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DeleteAllAdjustedTransactions"))
      {
        mLogger.LogDebug("Denying the relavent adjusted transactions.");
        GetAdjustedTransactions(ref adjTransactions);
        List<long> sessionIds = adjTransactions.Items.Select(adj => adj.SessionId).ToList();
        DeleteAdjustments(sessionIds);
        mLogger.LogDebug("Denied the relavent adjusted transactions.");
      }
    }

    [OperationCapability("Manage Adjustments")]
    public void GetMiscellaneousAdjustments(ref MTList<MiscellaneousAdjustment> details, bool pending)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetMiscellaneousAdjustments"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(ADJUSTMENT_QUERY_FOLDER))
          {
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(ADJUSTMENT_QUERY_FOLDER, "__GET_PENDING_ACCOUNT_CREDIT_REQUEST_DETAILS__"))
            {
              if (pending)
                stmt.AddParam("%%STATUS%%", "and c_status = 'Pending'", true);
              else
                stmt.AddParam("%%STATUS%%", "");

              stmt.AddParam("%%ID_LANG_CODE%%", GetSessionContext().LanguageID);
              if (conn.ConnectionInfo.DatabaseType == DBType.SQLServer)
                stmt.AddParam("%%NULL_CLAUSE%%", "isnull");
              else
                stmt.AddParam("%%NULL_CLAUSE%%", "nvl");
              ApplyFilterSortCriteria<MiscellaneousAdjustment>(stmt, details);
              using (IMTDataReader adjReader = stmt.ExecuteReader())
              {
                while (adjReader.Read())
                {
                  MiscellaneousAdjustment detail = new MiscellaneousAdjustment();
                  detail.Other = adjReader.GetString("Other");
                  detail.Status = adjReader.GetString("Status");
                  detail.AdjustmentAmount = adjReader.GetDecimal("AdjustmentAmount");
                  detail.EmailNotification = adjReader.GetString("EmailNotification");
                  detail.EmailAddress = adjReader.GetString("EmailAddress");
                  detail.ContentionSessionId = adjReader.GetString("ContentionSessionId");
                  detail.Description = adjReader.GetString("Description");
                  detail.SubscriberAccountId = adjReader.GetInt32("SubscriberAccountId");
                  detail.GuideIntervalId = adjReader.GetInt32("GuideIntervalId");
                  detail.ViewId = adjReader.GetInt32("ViewId");
                  detail.SessionId = adjReader.GetInt64("SessionId");
                  detail.Amount = adjReader.GetDecimal("Amount");
                  detail.Currency = (SystemCurrencies)EnumHelper.GetEnumByValue(typeof(SystemCurrencies), adjReader.GetString("Currency"));
                  detail.TimeStamp = adjReader.GetDateTime("Timestamp");
                  detail.IntervalId = adjReader.GetInt32("IntervalId");
                  detail.Reason = (SubscriberCreditAccountRequestReason)EnumHelper.GetCSharpEnum(adjReader.GetInt32("Reason"));
                  detail.TaxAmount = adjReader.GetDecimal("TaxAmount");
                  detail.AmountWithTax = adjReader.GetDecimal("AmountWithTax");
                  detail.SessionType = adjReader.GetString("SessionType");
                  details.Items.Add(detail);
                }
                details.TotalRows = stmt.TotalRows;
              }
            }
          }
        }
        catch (CommunicationException e)
        {
          mLogger.LogException("Cannot retrieve miscellaneous adjustments from the system ", e);
          throw;
        }

        catch (Exception e)
        {
          mLogger.LogException("Cannot retrieve miscellaneous adjustments from the system ", e);
          throw new MASBasicException("Cannot retrieve miscellaneous adjustments from the system");
        }
      }
    }

    [OperationCapability("Manage Adjustments")]
    public void GetAccountCredits(ref MTList<Metratech_com_AccountCreditProductView> details, bool pending)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAccountCredits"))
      {

        try
        {
          // dummy object to get the properties for our map
          var temp = new Metratech_com_AccountCreditProductView();
          List<PropertyInfo> props = temp.GetMTProperties();
          Dictionary<string, PropertyInfo> chargePropertyMap = props.ToDictionary(propertyInfo => propertyInfo.Name.ToLower());

          using (IMTConnection conn = ConnectionManager.CreateConnection(ADJUSTMENT_QUERY_FOLDER))
          {
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(ADJUSTMENT_QUERY_FOLDER, "__GET_PENDING_ACCOUNT_CREDITS_DETAILS__"))
            {
              if (pending)
                stmt.AddParam("%%STATUS%%", "and c_status = 'PENDING'", true);
              else
                stmt.AddParam("%%STATUS%%", "");

              stmt.AddParam("%%ID_LANG_CODE%%", GetSessionContext().LanguageID);
              stmt.AddParam("%%NULL_CLAUSE%%", conn.ConnectionInfo.DatabaseType == DBType.SQLServer ? "isnull" : "nvl");


              #region reset filter
              List<MTBaseFilterElement> filters = details.Filters;
              details.Filters = null;

              var ColumnsWithoutPrefix = new string[] { "sessionid", "intervalid", "viewid","amount", 
                "timestamp", "taxamount", "amountwithtax", "sessiontype", "currency"};

              foreach (MTFilterElement fe in filters)
              {
                string filter = fe.PropertyName.ToLower();
                MTFilterElement cleaned = null;

                if (ColumnsWithoutPrefix.Contains(filter))
                  cleaned = new MTFilterElement(filter, fe.Operation, fe.Value);
                else
                  cleaned = new MTFilterElement(String.Format("c_{0}", fe.PropertyName), fe.Operation,
                                                fe.Value);

                details.Filters.Add(cleaned);
              }
              #endregion

              #region reset sort

              if (details.SortCriteria != null && details.SortCriteria.Count > 0)
              {
                List<MetraTech.ActivityServices.Common.SortCriteria> sorting = details.SortCriteria;
                details.SortCriteria = null;

                foreach (MetraTech.ActivityServices.Common.SortCriteria sc in sorting)
                {
                  string sort = sc.SortProperty.ToLower();
                  MetraTech.ActivityServices.Common.SortCriteria sorted = null;

                  if (ColumnsWithoutPrefix.Contains(sort))
                    sorted = new ActivityServices.Common.SortCriteria(sort, sc.SortDirection);
                  else
                    sorted = new ActivityServices.Common.SortCriteria(String.Format("c_{0}", sc.SortProperty), sc.SortDirection);

                  details.SortCriteria.Add(sorted);
                }
              }

              #endregion


              ApplyFilterSortCriteria(stmt, details);

              using (var chargeReader = stmt.ExecuteReader())
              {
                while (chargeReader.Read())
                {
                  var detail = new Metratech_com_AccountCreditProductView();
                  for (var i = 0; i < chargeReader.FieldCount; i++)
                  {
                    var fieldName = chargeReader.GetName(i).ToLower().Trim();
                    PropertyInfo p = null;

                    string key = fieldName;
                    if (!chargePropertyMap.ContainsKey(key))
                    {
                      // remove the c_ from the column names for fields from pv_AccountCreditRequest table
                      key = fieldName.Remove(0, 2);
                      if (!chargePropertyMap.ContainsKey(key))
                      {
                        mLogger.LogDebug(String.Format("The field '{0}' is absent in AccountCredit ProductView", key));
                        continue;
                      }
                    }
                    p = chargePropertyMap[key];
                    if (!chargeReader.IsDBNull(i))
                    {
                      var val = BasePCWebService.GetValue(i, p, chargeReader);
                      if (p.PropertyType.Equals(typeof(double?)))
                        val = Decimal.ToDouble((decimal)val);

                      p.SetValue(detail, val, null);
                    }

                  }
                  details.Items.Add(detail);
                }
                details.TotalRows = stmt.TotalRows;
              }
            }
          }
        }
        catch (CommunicationException e)
        {
          mLogger.LogException("Cannot retrieve account credits from the system ", e);
          throw;
        }

        catch (Exception e)
        {
          mLogger.LogException("Cannot retrieve account credits from the system  ", e);
          throw new MASBasicException("Cannot retrieve accounts from the system ");
        }

      }
    }

    [OperationCapability("Manage Adjustments")]
    public void ApproveAllMiscellaneousAdjusments(ref MTList<MiscellaneousAdjustment> miscAdjustments, int userId)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ApproveAllMiscellaneousAdjusments"))
      {
        mLogger.LogDebug("Approving all miscellaneous adjustments specified.");
        GetMiscellaneousAdjustments(ref miscAdjustments, true);
        List<long> sessionIds = new List<long>();
        foreach (MiscellaneousAdjustment adj in miscAdjustments.Items)
        {
          sessionIds.Add(adj.SessionId);
        }
        ApproveMiscellaneousAdjustments(sessionIds, userId);
        mLogger.LogDebug("Approved all miscellaneous adjustments specified.");
      }
    }

    [OperationCapability("Manage Adjustments")]
    public void ApproveAllAccountCredits(ref MTList<Metratech_com_AccountCreditProductView> accountCredits, int userId)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ApproveAllAccountCredits"))
      {
        mLogger.LogDebug("Approving all miscellaneous adjustments specified.");
        GetAccountCredits(ref accountCredits, true);
        var sessionIds = accountCredits.Items.Select(adj => adj.SessionID).ToList();
        ApproveAccountCredits(sessionIds, userId);
        mLogger.LogDebug("Approved all miscellaneous adjustments specified.");
      }
    }

    [OperationCapability("Manage Adjustments")]
    public void DenyAllMiscellaneousAdjusments(ref MTList<MiscellaneousAdjustment> miscAdjustments, int userId)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DenyAllMiscellaneousAdjusments"))
      {
        mLogger.LogDebug("Denying all miscellaneous adjustments in the system.");
        GetMiscellaneousAdjustments(ref miscAdjustments, true);
        List<long> sessionIds = new List<long>();
        foreach (MiscellaneousAdjustment adj in miscAdjustments.Items)
        {
          sessionIds.Add(adj.SessionId);
        }
        DenyMiscellaneousAdjustments(sessionIds, userId);
        mLogger.LogDebug("Denied all miscellaneous adjustments in the system.");
      }
    }

    [OperationCapability("Manage Adjustments")]
    public void DenyAllAccountCredits(ref MTList<Metratech_com_AccountCreditProductView> accountCredits, int userId)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DenyAllAccountCredits"))
      {
        mLogger.LogDebug("Denying all miscellaneous adjustments in the system.");
        GetAccountCredits(ref accountCredits, true);
        var sessionIds = accountCredits.Items.Select(adj => adj.SessionID).ToList();
        DenyAccountCredits(sessionIds, userId);
        mLogger.LogDebug("Denied all miscellaneous adjustments in the system.");
      }
    }

    [OperationCapability("Manage Adjustments")]
    public void ApproveAccountCredits(List<long> sessionIds, int userId)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ApproveAccountCredits"))
      {
        mLogger.LogDebug("About to approve miscellaneous adjustments.");
        string ids = GetSessionIds(sessionIds);
        MeterAccountCredits(true, ids, userId);
        mLogger.LogDebug("Approved miscellaneous adjustments.");
      }
    }

    [OperationCapability("Manage Adjustments")]
    public void ApproveMiscellaneousAdjustments(List<long> sessionIds, int userId)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ApproveMiscellaneousAdjustments"))
      {
        mLogger.LogDebug("About to approve miscellaneous adjustments.");
        string ids = GetSessionIds(sessionIds);
        MeterMiscAdjustments(true, ids, userId);
        mLogger.LogDebug("Approved miscellaneous adjustments.");
      }
    }

    [OperationCapability("Manage Adjustments")]
    public void DenyAccountCredits(List<long> sessionIds, int userId)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DenyAccountCredits"))
      {
        mLogger.LogDebug("About to deny miscellaneous adjustments.");
        string ids = GetSessionIds(sessionIds);
        //ESR-4388 Misc. Adjustments - After Denying Adjustment Request the Status is changed to "Active" in the pv table
        MeterAccountCredits(false, ids, userId);
        mLogger.LogDebug("Denied miscellaneous adjustments.");
      }
    }

    [OperationCapability("Manage Adjustments")]
    public void DenyMiscellaneousAdjustments(List<long> sessionIds, int userId)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DenyMiscellaneousAdjustments"))
      {
        mLogger.LogDebug("About to deny miscellaneous adjustments.");
        string ids = GetSessionIds(sessionIds);
        //ESR-4388 Misc. Adjustments - After Denying Adjustment Request the Status is changed to "Active" in the pv table
        MeterMiscAdjustments(false, ids, userId);
        mLogger.LogDebug("Denied miscellaneous adjustments.");
      }
    }

    [OperationCapability("Manage Adjustments")]
    public void GetOrphanedAdjustments(ref MTList<OrphanedAdjustment> orphanedAdjustments)
    {
      throw new NotImplementedException("GetOrphanedAdjustments is not supported.");
    }

    [OperationCapability("Manage Adjustments")]
    public void GetOrphanedAdjustmentDetails(long sessionId, out OrphanedAdjustmentDetail detail)
    {
      throw new NotImplementedException("GetOrphanedAdjustmentDetails is not supported.");
    }

    [OperationCapability("Manage Adjustments")]
    public void ApproveOrphanAdjustments(List<long> sessionIds)
    {
      throw new NotImplementedException("Approve Orphan Adjustments functionality is not currently supported.");
    }

    [OperationCapability("Manage Adjustments")]
    public void DenyOrphanAdjustments(List<long> sessionIds)
    {
      throw new NotImplementedException("Deny Orphan Adjustments functionality is not currently supported.");
    }
    #endregion

    #region private methods

    /// <summary>Meter account credits
    /// </summary>
    /// <param name="approve">Account credit status</param>
    /// <param name="ids">Session IDs values</param>
    /// <param name="userId">Issuer ID value</param>
    /// <remarks>Added within the scope of ESR-4446</remarks>
    private void MeterAccountCredits(bool approve, string ids, int userId)
    {
      var cache = new PipelineMeteringHelperCache("metratech.com/AccountCredit");
      PipelineMeteringHelper helper = null;

      try
      {
        cache.PoolSize = 30;
        cache.PollingInterval = 0;
        helper = cache.GetMeteringHelper();

        var temp = new Metratech_com_AccountCreditProductView();
        List<PropertyInfo> props = temp.GetMTProperties();
        Dictionary<string, PropertyInfo> accountCreditPropertyMap = props.ToDictionary(propertyInfo => propertyInfo.Name.ToLower());


        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(ADJUSTMENT_QUERY_FOLDER, "__LOAD_PENDING_ACCOUNT_CREDITS_REQUESTS__"))
          {
            stmt.AddParam("%%SESSION_IDS%%", ids);
            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
              //string[] UnusedFields = {"emailtext","internalcomment","accountingcode"};
              string[] AmountFields = { "requestamount", "creditamount", "_amount" };

              while (rdr.Read())
              {
                DataRow row = helper.CreateRowForServiceDef("metratech.com/AccountCredit");

                foreach (DataColumn serviceDefColumn in row.Table.Columns)
                {
                  var columnName = serviceDefColumn.ColumnName;
                  var colunmNameToLower = columnName.ToLower().Trim();

                  switch (columnName)
                  {
                    case "CreditTime":
                      {
                        row[columnName] = MetraTime.Now;
                        break;
                      }
                    case "Status":
                      {
                        row[columnName] = approve
                                            ? SubscriberCreditAccountRequestStatus.APPROVED
                                            : SubscriberCreditAccountRequestStatus.DENIED;
                        break;
                      }
                    case "RequestID":
                      {
                        row[columnName] = rdr.GetInt64("id_sess"); // Request id becomes the session id
                        break;
                      }
                    case "_Currency":
                      {
                        row[columnName] = rdr.GetString(columnName.Remove(0, 1).Trim());
                        break;
                      }
                    case "_AccountID":
                      {
                        row[columnName] = rdr.GetInt32("c_subscriberaccountid");
                        break;
                      }
                    case "Issuer":
                      {
                        row[columnName] = userId;
                        break;
                      }
                    case "InvoiceComment":
                      {
                        row[columnName] = rdr.GetString("c_description");
                        break;
                      }
                    case "ResolveWithAccountIDFlag":
                      {
                        row[columnName] = true;
                        break;
                      }
                    case "ReturnCode":
                    case "IgnorePaymentRedirection":
                      {
                        //fields with 0 value after metering
                        row[columnName] = 0;
                        break;
                      }
                    case "ContentionSessionID":
                      {
                        int columnInQueryOrder1 = -1;
                        try
                        {
                          columnInQueryOrder1 = rdr.GetOrdinal("c_contentionsessionid");
                        }
                        catch (IndexOutOfRangeException /*e*/)
                        {

                        }

                        if (columnInQueryOrder1 > -1) //assign value from the query
                        {
                          if (rdr.IsDBNull(columnInQueryOrder1))
                            row[columnName] = "";
                          else
                            row[columnName] = rdr.GetString("c_contentionsessionid");
                        }
                        row[columnName] = "";
                        break;
                      }

                    default:
                      {
                        if (AmountFields.Contains(colunmNameToLower)) //fields with amount value after metering
                        {
                          row[columnName] = rdr.GetDecimal("c_creditamount");
                          continue;
                        }

                        //check whether ServiceDefColumn has appropriate column in DataReader query
                        int columnInQueryOrder = -1;
                        try
                        {
                          columnInQueryOrder = rdr.GetOrdinal(String.Format("c_{0}", columnName));
                        }
                        catch (IndexOutOfRangeException /*e*/)
                        {

                        }

                        if (columnInQueryOrder > -1) //assign value from the query
                        {
                          PropertyInfo p = null;

                          if (accountCreditPropertyMap.ContainsKey(colunmNameToLower))
                          {
                            p = accountCreditPropertyMap[colunmNameToLower];
                            if (!rdr.IsDBNull(columnInQueryOrder))
                            {
                              var val = BasePCWebService.GetValue(columnInQueryOrder, p, rdr);
                              if (val == null)
                              {
                                row[columnName] = System.DBNull.Value;  //for esr-4727 in case of empty value for enum property
                                continue;
                              }

                              if ((val.GetType().IsEnum))
                                row[columnName] = EnumHelper.GetDbValueByEnum(val);
                              else
                                row[columnName] = val;

                              continue;
                            }
                          }
                        }
                        break;
                      }
                  }
                }

              }
            }
          }
        }

        DataSet messages = helper.Meter(GetSessionContext());
        helper.WaitForMessagesToComplete(messages, -1);
        DataTable dt = helper.GetMessageDetails(null);
        DataRow[] errorRows = dt.Select("ErrorMessage is not null");

        if (errorRows.Length != 0)
        {
          var error = new StringBuilder();
          error.Append("Your request could not be processed because of the following errors: ");

          //ErrorMessage
          foreach (var errorRow in errorRows)
          {
            error.Append(errorRow["ErrorMessage"]);
          }

          CleanFailedTransactions(errorRows);
          throw new MASBasicException(error.ToString());
        }
      }
      catch (CommunicationException e)
      {
        mLogger.LogException(
          approve
            ? "Unable to approve pending miscellaneous adjustments."
            : "Unable to deny pending miscellaneous adjustments.", e);
        throw;
      }
      catch (Exception e)
      {
        mLogger.LogException(
          approve
            ? "Unable to approve pending miscellaneous adjustments."
            : "Unable to deny pending miscellaneous adjustments.", e);

        throw new MASBasicException(e.Message);
      }
      finally
      {
        cache.Release(helper);
      }
    }


    private void MeterMiscAdjustments(bool approve, string ids, int userId)
    {
      PipelineMeteringHelperCache cache = new PipelineMeteringHelperCache("metratech.com/AccountCredit");
      PipelineMeteringHelper helper = null;

      try
      {
        cache.PoolSize = 30;
        cache.PollingInterval = 0;
        helper = cache.GetMeteringHelper();

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(ADJUSTMENT_QUERY_FOLDER, "__LOAD_PENDING_REQUESTS__"))
          {
            stmt.AddParam("%%SESSION_IDS%%", ids);
            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
              while (rdr.Read())
              {
                DataRow row = helper.CreateRowForServiceDef("metratech.com/AccountCredit");
                row["CreditTime"] = MetraTime.Now;
                if (approve)
                  row["Status"] = MetraTech.DomainModel.Enums.Core.Metratech_com.SubscriberCreditAccountRequestStatus.APPROVED;
                else
                  row["Status"] = MetraTech.DomainModel.Enums.Core.Metratech_com.SubscriberCreditAccountRequestStatus.DENIED;

                row["RequestID"] = rdr.GetInt64("SessionId");   // Request id becomes the session id
                row["_AccountID"] = rdr.GetInt32("AccountId");
                row["_Currency"] = rdr.GetString("Currency");
                row["EmailNotification"] = rdr.GetString("EmailNotificaton");
                row["EMailAddress"] = rdr.GetString("EmailAddress");
                row["EmailText"] = null;
                row["Issuer"] = userId;
                row["Reason"] = rdr.GetInt32("Reason");
                row["Other"] = rdr.GetString("Other");
                row["InvoiceComment"] = "Miscellaneous Adjustment";
                row["InternalComment"] = rdr.GetString("InternalComment");
                row["AccountingCode"] = null;
                row["ReturnCode"] = 0;
                row["ContentionSessionID"] = rdr.GetString("ContentionSessionID");
                decimal amount = rdr.GetDecimal("CreditAmount");
                row["RequestAmount"] = amount;
                row["CreditAmount"] = amount;
                row["GuideIntervalID"] = rdr.GetInt32("GuideIntervalId");
                row["ResolveWithAccountIDFlag"] = true;
                row["_Amount"] = amount;
                row["IgnorePaymentRedirection"] = 0;
              }
            }
          }
        }

        DataSet messages = helper.Meter((MetraTech.Interop.MTAuth.IMTSessionContext)GetSessionContext());
        helper.WaitForMessagesToComplete(messages, -1);
        DataTable dt = helper.GetMessageDetails(null);
        DataRow[] errorRows = dt.Select("ErrorMessage is not null");

        if (errorRows.Length != 0)
        {
          var error = new StringBuilder();
          error.Append("Your request could not be processed because of the following errors: ");

          //ErrorMessage
          foreach (var errorRow in errorRows)
          {
            error.Append(errorRow["ErrorMessage"]);
          }

          CleanFailedTransactions(errorRows);
          throw new MASBasicException(error.ToString());
        }
      }
      catch (CommunicationException e)
      {
        if (approve)
          mLogger.LogException("Unable to approve pending miscellaneous adjustments.", e);
        else
          mLogger.LogException("Unable to deny pending miscellaneous adjustments.", e);
        throw;
      }
      catch (Exception e)
      {
        if (approve)
          mLogger.LogException("Unable to approve pending miscellaneous adjustments.", e);
        else
          mLogger.LogException("Unable to deny pending miscellaneous adjustments.", e);

        throw new MASBasicException(e.Message);
      }
      finally
      {
        cache.Release(helper);
      }
    }

    private string GetSessionIds(List<long> sessionIds)
    {
      string ids = "";
      if (sessionIds.Count == 0)
        throw new MASBasicException("No adjustment ids provided for approval.");
      else
      {
        string temp = "";
        foreach (long id in sessionIds)
          temp += String.Format("{0},", id);

        // remove trailing comma
        ids = temp.Substring(0, temp.Length - 1);
      }

      return ids;
    }

    private void CleanFailedTransactions(DataRow[] errorRows)
    {
      string rawQuery = @"update t_failed_transaction set State='D' where id_failed_transaction in ({0})";

      string ids = "";
      foreach (var error in errorRows)
      {
        ids += error["FailureId"] + ",";
      }
      ids = ids.Trim(new char[] { ',' });

      rawQuery = String.Format(rawQuery, ids);

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTPreparedStatement prepStmt = conn.CreatePreparedStatement(rawQuery))
        {
          prepStmt.ExecuteNonQuery();
        }
      }
    }
    #endregion

  }
}
