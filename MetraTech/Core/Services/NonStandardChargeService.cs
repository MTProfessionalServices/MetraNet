using System;
using System.Collections.Generic;
using System.Data;
using System.Reflection;
using System.ServiceModel;
using System.Text;

using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.ProductView;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.Core.Services
{
  [ServiceContract]
  public interface INonStandardChargeService
  {
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void ApproveNonStandardCharges(List<long> sessionids);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DenyNonStandardCharges(List<long> sessionids);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetNonStandardCharges(ref MTList<Metratech_com_NonStandardChargeProductView> charges);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DenyAllNonStandardCharges(ref MTList<Metratech_com_NonStandardChargeProductView> charges);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void ApproveAllNonStandardCharges(ref MTList<Metratech_com_NonStandardChargeProductView> charges);

  }

  [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Multiple, InstanceContextMode = InstanceContextMode.Single)]
  public class NonStandardChargeService : CMASServiceBase, INonStandardChargeService
  {
    private const string NONSTANDARD_CHARGE_QUERY_FOLDER = @"queries\NonStandardCharges";
    private static Logger mLogger = new Logger("[NonStandardChargeService]");

    #region Service Methods
    [OperationCapability("Manage NonStandardCharges")]
    public void ApproveNonStandardCharges(List<long> sessionids)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ApproveNonStandardCharges"))
      {
        ResourcesManager resourceManager = new ResourcesManager();
        if (sessionids.Count > 0)
        {
          string ids = GetSessionIds(sessionids);
          int issuerId = GetSessionContext().AccountID;
          MeterNonStandardCharges(true, ids, issuerId);
        }
        else
        {
          mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_NO_CHARGE_FOR_APPROVE"));
        }
      }
    }

    [OperationCapability("Manage NonStandardCharges")]
    public void DenyNonStandardCharges(List<long> sessionids)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DenyNonStandardCharges"))
      {
        ResourcesManager resourceManager = new ResourcesManager();
        if (sessionids.Count > 0)
        {
          string ids = GetSessionIds(sessionids);
          int issuerId = GetSessionContext().AccountID;
          MeterNonStandardCharges(false, ids, issuerId);
        }
        else
        {
          mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_NO_CHARGE_FOR_DENY"));
        }
      }
    }

    [OperationCapability("Manage NonStandardCharges")]
    public void GetNonStandardCharges(ref MTList<Metratech_com_NonStandardChargeProductView> charges)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetNonStandardCharges"))
      {
        ResourcesManager resourceManager = new ResourcesManager();
        try
        {
          // dummy object to get the properties for our map
          Metratech_com_NonStandardChargeProductView temp = new Metratech_com_NonStandardChargeProductView();
          Dictionary<string, PropertyInfo> chargePropertyMap = new Dictionary<string, PropertyInfo>();
          List<PropertyInfo> props = temp.GetMTProperties();
          foreach (var propertyInfo in props)
          {
            chargePropertyMap.Add(propertyInfo.Name.ToLower(), propertyInfo);
          }

          using (IMTConnection conn = ConnectionManager.CreateConnection(NONSTANDARD_CHARGE_QUERY_FOLDER))
          {
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(NONSTANDARD_CHARGE_QUERY_FOLDER, "__GET_NONSTANDARDCHARGES__"))
            {
              #region reset filter
              List<MTBaseFilterElement> filters = charges.Filters;
              charges.Filters = null;
              foreach (MTFilterElement fe in filters)
              {
                string filter = fe.PropertyName.ToLower();
                MTFilterElement cleaned = null;
                switch (filter)
                {
                  case "sessionid":
                    cleaned = new MTFilterElement(String.Format("id_sess", fe.PropertyName), fe.Operation,
                                                                  fe.Value);
                    break;
                  case "intervalid":
                    cleaned = new MTFilterElement(String.Format("id_usage_interval", fe.PropertyName), fe.Operation,
                                                                  fe.Value);
                    break;
                  default:
                    cleaned = new MTFilterElement(String.Format("c_{0}", fe.PropertyName), fe.Operation,
                                                                  fe.Value);
                    break;
                }
                charges.Filters.Add(cleaned);
              }
              #endregion

              #region reset sort

              if (charges.SortCriteria != null && charges.SortCriteria.Count > 0)
              {
                List<MetraTech.ActivityServices.Common.SortCriteria> sorting = charges.SortCriteria;
                charges.SortCriteria = null;

                foreach (MetraTech.ActivityServices.Common.SortCriteria sc in sorting)
                {
                  string sort = sc.SortProperty.ToLower();
                  MetraTech.ActivityServices.Common.SortCriteria sorted = null;
                  switch (sort)
                  {
                    case "sessionid":
                      sorted = new MetraTech.ActivityServices.Common.SortCriteria("id_sess", sc.SortDirection);
                      break;
                    case "intervalid":
                      sorted = new MetraTech.ActivityServices.Common.SortCriteria("id_usage_interval", sc.SortDirection);
                      break;
                    default:
                      sorted = new MetraTech.ActivityServices.Common.SortCriteria(String.Format("c_{0}", sc.SortProperty), sc.SortDirection);
                      break;
                  }
                  charges.SortCriteria.Add(sorted);
                }
              }

              #endregion

              ApplyFilterSortCriteria(stmt, charges);
              using (IMTDataReader chargeReader = stmt.ExecuteReader())
              {
                #region Read Data
                while (chargeReader.Read())
                {
                  Metratech_com_NonStandardChargeProductView charge = new Metratech_com_NonStandardChargeProductView();
                  for (int i = 0; i < chargeReader.FieldCount; i++)
                  {
                    string fieldName = chargeReader.GetName(i).ToLower().Trim();
                    PropertyInfo p = null;
                    switch (fieldName)
                    {
                      case "id_sess":
                        p = chargePropertyMap["sessionid"];
                        if (!chargeReader.IsDBNull(i))
                        {
                          p.SetValue(charge, BasePCWebService.GetValue(i, p, chargeReader), null);
                        }
                        break;
                      case "id_usage_interval":
                        p = chargePropertyMap["intervalid"];
                        if (!chargeReader.IsDBNull(i))
                        {
                          p.SetValue(charge, BasePCWebService.GetValue(i, p, chargeReader), null);
                        }
                        break;
                      case "Currency":
                        p = chargePropertyMap["currency"];
                        if (!chargeReader.IsDBNull(i))
                        {
                          p.SetValue(charge, BasePCWebService.GetValue(i, p, chargeReader), null);
                        }
                        break;
                      case "rownumber":
                        break;
                      case "row_num":
                        break;
                      default:
                        // remove the c_ from the column names
                        string key = fieldName.Remove(0, 2);
                        p = chargePropertyMap[key];
                        if (!chargeReader.IsDBNull(i))
                        {
                          p.SetValue(charge, BasePCWebService.GetValue(i, p, chargeReader), null);
                        }
                        break;

                    }
                  }

                  charges.Items.Add(charge);
                }
                #endregion
                charges.TotalRows = stmt.TotalRows;
              }
            }
          }
        }
        catch (CommunicationException e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_NO_CHARGE_FOUND"), e);
          throw;
        }

        catch (Exception e)
        {
          string message = resourceManager.GetLocalizedResource("TEXT_NO_CHARGE_FOUND");
          mLogger.LogException(message, e);
          throw new MASBasicException(message);
        }
      }
    }

    [OperationCapability("Manage NonStandardCharges")]
    public void DenyAllNonStandardCharges(ref MTList<Metratech_com_NonStandardChargeProductView> charges)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DenyAllNonStandardCharges"))
      {
        ResourcesManager resourceManager = new ResourcesManager();
        mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_DENYING_NS_CHARGES"));
        GetNonStandardCharges(ref charges);
        List<long> sessionIds = new List<long>();
        foreach (Metratech_com_NonStandardChargeProductView nsc in charges.Items)
        {
          sessionIds.Add(nsc.SessionID);
        }
        DenyNonStandardCharges(sessionIds);

        mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_DENIED_NS_CHARGES"));
      }
    }

    [OperationCapability("Manage NonStandardCharges")]
    public void ApproveAllNonStandardCharges(ref MTList<Metratech_com_NonStandardChargeProductView> charges)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ApproveAllNonStandardCharges"))
      {
        ResourcesManager resourceManager = new ResourcesManager();
        mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_APPROVING_NS_CHARGES"));
        GetNonStandardCharges(ref charges);
        List<long> sessionIds = new List<long>();
        foreach (Metratech_com_NonStandardChargeProductView nsc in charges.Items)
        {
          sessionIds.Add(nsc.SessionID);
        }
        ApproveNonStandardCharges(sessionIds);

        mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_APPROVED_NS_CHARGES"));
      }
    }

    #endregion

    #region private members
    private void MeterNonStandardCharges(bool approve, string ids, int userId)
    {
      ResourcesManager resourceManager = new ResourcesManager();
      PipelineMeteringHelperCache cache = new PipelineMeteringHelperCache("metratech.com/NonStandardCharge");
      PipelineMeteringHelper helper = null;

      try
      {
        cache.PoolSize = 30;
        cache.PollingInterval = 0;
        helper = cache.GetMeteringHelper();

        Metratech_com_NonStandardChargeProductView temp = new Metratech_com_NonStandardChargeProductView();
        Dictionary<string, PropertyInfo> chargePropertyMap = new Dictionary<string, PropertyInfo>();
        List<PropertyInfo> props = temp.GetMTProperties();
        foreach (var propertyInfo in props)
        {
          chargePropertyMap.Add(propertyInfo.Name.ToLower(), propertyInfo);
        }

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (
            IMTAdapterStatement stmt = conn.CreateAdapterStatement(NONSTANDARD_CHARGE_QUERY_FOLDER,
                                                                   "__LOAD_PENDING_NONSTANDARDCHARGES__"))
          {
            stmt.AddParam("%%SESSION_IDS%%", ids);

            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
              while (rdr.Read())
              {
                Metratech_com_NonStandardChargeProductView charge = new Metratech_com_NonStandardChargeProductView();

                DataRow row = helper.CreateRowForServiceDef("metratech.com/NonStandardCharge");
                for (int i = 0; i < rdr.FieldCount; i++)
                {
                  string fieldName = rdr.GetName(i).ToLower().Trim();
                  PropertyInfo p = null;
                  switch (fieldName)
                  {
                    case "id_sess":
                      p = chargePropertyMap["sessionid"];
                      if (!rdr.IsDBNull(i))
                      {
                        object chargeId = BasePCWebService.GetValue(i, p, rdr);
                        row["InternalChargeId"] = chargeId;
                      }
                      break;
                    case "id_usage_interval":
                      // not needed
                      break;
                    case "c_status":
                      if (approve)
                        row["Status"] = "A";
                      else
                        row["Status"] = "D";
                      break;
                    case "c_subscriberaccountid":
                      if (!rdr.IsDBNull(i))
                      {
                        p = chargePropertyMap["subscriberaccountid"];
                        object accId = BasePCWebService.GetValue(i, p, rdr);
                        row["_AccountID"] = accId;
                      }
                      break;
                    case "c_internalchargeid":
                      break;
                    case "c_chargeamount":
                      break;
                    case "rownumber":
                      break;
                    default:
                      // remove the c_ from the column names
                      string key = fieldName.Remove(0, 2).ToLower().Trim();
                      p = chargePropertyMap[key];

                          if (!rdr.IsDBNull(i))
                          {
                              object val = BasePCWebService.GetValue(i, p, rdr);
                              if (key.Equals("chargecurrency"))
                                  row["_Currency"] = val;
                              else
                              {
                                  if (val == null)
                                  {
                                      row[key] = DBNull.Value;
                                  }
                                  else if (val.GetType().IsEnum)
                                  {
                                      row[key] = EnumHelper.GetDbValueByEnum(val);
                                  }
                                  else
                                      row[key] = val;
                              }
                          }
                          break;
                  }
                }
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
          error.Append(resourceManager.GetLocalizedResource("TEXT_UNABLE_TO_PROCESS"));

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
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_UNABLE_TO_APPROVE_PENDING_NS"), e);
        else
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_UNABLE_TO_DENY_PENDING_NS"), e);
        throw;
      }
      catch (Exception e)
      {
        if (approve)
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_UNABLE_TO_APPROVE_PENDING_NS"), e);
        else
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_UNABLE_TO_DENY_PENDING_NS"), e);

        throw new MASBasicException(e.Message);
      }
      finally
      {
        cache.Release(helper);
      }
    }

    // TODO: Maybe move to a base class
    private string GetSessionIds(List<long> sessionIds)
    {
      ResourcesManager resourceManager = new ResourcesManager();
      string ids = "";
      if (sessionIds.Count == 0)
        throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_NO_SESSION_IDS"));
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
