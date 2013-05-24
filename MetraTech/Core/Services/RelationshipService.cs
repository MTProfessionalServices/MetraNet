using System;
using System.Data;
using System.Collections.Generic;
using System.ServiceModel;
using System.Text;

using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Billing;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.Core.Services
{
  [ServiceContract]
  public interface IRelationshipService
  {
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAccountBillManagers(ref MTList<AccountBillManager> adjustedTransactions);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void AddAccountBillManager(AccountBillManager manager);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void RemoveAccountBillManager(AccountBillManager manager);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void AddBillManagees(int managerId, List<int> accountIds);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void RemoveBillManagees(int managerId, List<int> accountIds);

  }

  [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Multiple, InstanceContextMode = InstanceContextMode.Single)]
  public class RelationshipService : CMASServiceBase, IRelationshipService
  {
    private const string BILLMANAGER_QUERY_FOLDER = @"queries\Account";
    private static Logger mLogger = new Logger("[RelationshipService]");

    #region RelationshipService Methods
    [OperationCapability("Manage Subscriber Auth")]
    public void GetAccountBillManagers(ref MTList<AccountBillManager> managers)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAccountBillManagers"))
      {
        ResourcesManager resourceManager = new ResourcesManager();
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(BILLMANAGER_QUERY_FOLDER))
          {
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(BILLMANAGER_QUERY_FOLDER, "__GET_ACCOUNT_BILL_MANAGERS__"))
            {
              ApplyFilterSortCriteria<AccountBillManager>(stmt, managers);

              using (IMTDataReader mgrReader = stmt.ExecuteReader())
              {
                while (mgrReader.Read())
                {
                  AccountBillManager mgr = new AccountBillManager();
                  mgr.AdminID = mgrReader.GetInt32("AdminID");
                  mgr.AccountID = mgrReader.GetInt32("AccountID");
                  mgr.BillManager = mgrReader.GetString("BillManager");
                  mgr.BillManagee = mgrReader.GetString("BillManagee");
                  managers.Items.Add(mgr);
                }
                managers.TotalRows = stmt.TotalRows;
              }
            }
          }
        }
        catch (CommunicationException e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_RETRIEVE_DATA"), e);
          throw;
        }

        catch (Exception e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_RETRIEVE_DATA"), e);
          throw;
        }
      }
    }

    [OperationCapability("Manage Subscriber Auth")]
    public void AddAccountBillManager(AccountBillManager manager)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("AddAccountBillManager"))
      {
        ResourcesManager resourceManager = new ResourcesManager();
        try
        {
          mLogger.LogDebug("Adding Bill Manager to system");
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTCallableStatement callStmt = conn.CreateCallableStatement("AddBillManager"))
            {
              callStmt.AddParam("managee", MTParameterType.Integer, manager.AccountID);
              callStmt.AddParam("manager", MTParameterType.Integer, manager.AdminID);
              callStmt.AddParam("p_systemdate", MTParameterType.DateTime, MetraTime.Now);
              if (PCConfigManager.IsBusinessRuleEnabled(PCConfigManager.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations))
                callStmt.AddParam("p_enforce_same_corporation", MTParameterType.String, "F");
              else
                callStmt.AddParam("p_enforce_same_corporation", MTParameterType.String, "T");

              callStmt.AddOutputParam("status", MTParameterType.Integer);
              callStmt.ExecuteNonQuery();
              int status = (int)callStmt.GetOutputValue("status");
              if (status == 0)
              {
                mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_ADDED_BILL_MANAGER"));
              }
              else if (status == 1)
                throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_BILL_MANAGER_EXISTS"));
              else if (status == 2)
                throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_ACCOUNT_CANNOT_BE_OWN_BILL_MANAGER"));
              else if (status == 3)
                throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_BILL_MANAGER_CORPORATION"));
            }
          }
          mLogger.LogDebug("Added Bill Manager to system");
        }
        catch (CommunicationException e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_ADD_BILL_MANAGER"), e);
          throw;
        }

        catch (Exception e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_ADD_BILL_MANAGER"), e);
          throw;
        }
      }
    }

    [OperationCapability("Manage Subscriber Auth")]
    public void RemoveAccountBillManager(AccountBillManager manager)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("RemoveAccountBillManager"))
      {
        ResourcesManager resourceManager = new ResourcesManager();
        try
        {
          mLogger.LogDebug("Removing account bill manager");
          using (IMTConnection conn = ConnectionManager.CreateConnection(BILLMANAGER_QUERY_FOLDER))
          {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(BILLMANAGER_QUERY_FOLDER, "__DELETE_BILL_MANAGER_FOR_ACCOUNT__"))
            {
              stmt.AddParam("%%ADMIN_ID%%", manager.AdminID);
              stmt.AddParam("%%ID_ACC%%", manager.AccountID);
              stmt.ExecuteNonQuery();
              stmt.ClearQuery();
            }
          }
          mLogger.LogDebug("Removed account bill manager");
        }
        catch (CommunicationException e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_ADD_BILL_MANAGER"), e);
          throw;
        }

        catch (Exception e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_ADD_BILL_MANAGER"), e);
          throw;
        }
      }
    }

    [OperationCapability("Manage Subscriber Auth")]
    public void AddBillManagees(int managerId, List<int> accountIds)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("AddBillManagees"))
      {
        ResourcesManager resourceManager = new ResourcesManager();
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            foreach (int id in accountIds)
            {
              using (IMTCallableStatement callStmt = conn.CreateCallableStatement("AddBillManager"))
              {
                callStmt.AddParam("managee", MTParameterType.Integer, id);
                callStmt.AddParam("manager", MTParameterType.Integer, managerId);
                callStmt.AddParam("p_systemdate", MTParameterType.DateTime, MetraTime.Now);
                if (
                  PCConfigManager.IsBusinessRuleEnabled(PCConfigManager.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations))
                  callStmt.AddParam("p_enforce_same_corporation", MTParameterType.String, "F");
                else
                  callStmt.AddParam("p_enforce_same_corporation", MTParameterType.String, "T");

                callStmt.AddOutputParam("status", MTParameterType.Integer);
                callStmt.ExecuteNonQuery();

                int status = (int)callStmt.GetOutputValue("status");
                if (status == 0)
                {
                  mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_ADDED_BILL_MANAGEE"));
                }
                else if (status == 1)
                  throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_BILL_MANAGER_EXISTS"));
                else if (status == 2)
                  throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_ACCOUNT_CANNOT_BE_OWN_BILL_MANAGER"));
                else if (status == 3)
                  throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_BILL_MANAGER_CORPORATION"));
              }
            }
          }
        }
        catch (CommunicationException e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_ADD_BILL_MANAGEES"), e);
          throw;
        }

        catch (Exception e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_ADD_BILL_MANAGEES"), e);
          throw;
        }
      }
    }

    [OperationCapability("Manage Subscriber Auth")]
    public void RemoveBillManagees(int managerId, List<int> accountIds)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("RemoveBillManagees"))
      {
        ResourcesManager resourceManager = new ResourcesManager();
        try
        {
          string ids = "";
          string temp = "";
          foreach (int id in accountIds)
            temp += String.Format("{0},", id);

          // remove trailing comma
          ids = temp.Substring(0, temp.Length - 1);

          using (IMTConnection conn = ConnectionManager.CreateConnection(BILLMANAGER_QUERY_FOLDER))
          {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(BILLMANAGER_QUERY_FOLDER, "__DELETE_BILL_MANAGEES_FROM_ACCOUNT__"))
            {
              stmt.AddParam("%%ADMIN_ID%%", managerId);
              stmt.AddParam("%%ID_ACCS%%", ids);
              stmt.ExecuteNonQuery();
              stmt.ClearQuery();
            }
          }
        }
        catch (CommunicationException e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_REMOVE_BILL_MANAGEES"), e);
          throw;
        }

        catch (Exception e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_REMOVE_BILL_MANAGEES"), e);
          throw;
        }
      }
    }

    #endregion

    #region private methods

    #endregion

  }
}
