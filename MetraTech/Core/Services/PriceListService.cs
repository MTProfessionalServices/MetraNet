
using System;
using System.Reflection;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.ServiceModel;
using System.Runtime.Serialization;
using MetraTech.Application;
using MetraTech.Application.ProductManagement;
using MetraTech.DataAccess;
using MetraTech.Interop.QueryAdapter;
using RS = MetraTech.Interop.Rowset;
using YAAC = MetraTech.Interop.MTYAAC;
using Auth = MetraTech.Interop.MTAuth;
using Coll = MetraTech.Interop.GenericCollection;

using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.ProductCatalog;

using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.Interop.MTProductCatalog;
using System.Runtime.InteropServices;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;
using System.Transactions;
using MetraTech.Debug.Diagnostics;
using IMTSessionContext = MetraTech.Interop.MTAuth.IMTSessionContext;


namespace MetraTech.Core.Services
{

  [ServiceContract()]
  public interface IPriceListService
  {
    // Load price lists.
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoadPriceLists(out List<PriceList> priceListColl);

    //Get PriceList name
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetPriceList(int PriceListId, out PriceList PriList);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetSharedPriceLists(ref MTList<PriceList> sharedPriceLists);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetSharedPriceList(PCIdentifier plID, out PriceList priceList);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteSharedPriceList(PCIdentifier plID);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetParamTablesForSubscription(int subID, ref List<PriceableItemParamTable> paramTables);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetRateSchedulesForSubscription(int subId,
                                         PCIdentifier piInstanceID,
                                         PCIdentifier paramTableID,
                                         out List<BaseRateSchedule> rscheds);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SaveRateSchedulesForSubscription(int subId,
                                          PCIdentifier piInstanceID,
                                          PCIdentifier paramTableID,
                                          List<BaseRateSchedule> rscheds);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void RemoveRateScheduleFromSubscription(int subId, int rschedID);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetRateSchedulesForProductOffering(PCIdentifier poID,
                                                          PCIdentifier piInstanceID,
                                                          PCIdentifier paramTableID,
                                          out List<BaseRateSchedule> rscheds);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SaveRateScheduleForProductOffering(PCIdentifier poID,
                                                           PCIdentifier piInstanceID,
                                                           PCIdentifier paramTableID,
                                           List<BaseRateSchedule> rscheds);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void RemoveRateScheduleFromProductOffering(PCIdentifier poID, int rschedID);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SavePriceListMappingForProductOffering(PCIdentifier poID,
                                              PCIdentifier piInstanceID,
                                              PCIdentifier paramTableDefID, ref PriceListMapping plMap);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetPriceListMappingForProductOffering(PCIdentifier poID,
                                               PCIdentifier piInstanceID,
                                               PCIdentifier paramTableDefID,
                                               out PriceListMapping plMap);


    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetRateSchedulesForSharedPriceList(PCIdentifier priceListID, PCIdentifier paramTableID, out List<BaseRateSchedule> rscheds);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SaveRateSchedulesForSharedPriceList(PCIdentifier priceListID, PCIdentifier piTemplateID, PCIdentifier paramTableID, List<BaseRateSchedule> rscheds);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void RemoveRateScheduleFromSharedPriceList(PCIdentifier plID, int rschedID);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SaveSharedPriceList(ref PriceList priceList);
  }

  [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Multiple, InstanceContextMode = InstanceContextMode.Single)]
  public class PriceListService : BasePCWebService, IPriceListService
  {
    #region Private Members
    private Logger m_PriceListLogger = new Logger("[PriceListService]");
    #endregion

    #region IPriceListService Members
    public void LoadPriceLists(out List<PriceList> priceListColl)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("LoadPriceLists"))
      {
        priceListColl = new List<PriceList>();

        try
        {
          MTProductCatalog mtpc = new MTProductCatalog();
          RS.MTDataFilter plFilter = new RS.MTDataFilter();
          plFilter.Add("Type", RS.MTOperatorType.OPERATOR_TYPE_EQUAL, MTPriceListType.PRICELIST_TYPE_REGULAR);

          MetraTech.Interop.Rowset.IMTRowSet rowset =
            (MetraTech.Interop.Rowset.IMTRowSet)mtpc.FindPriceListsAsRowset(plFilter);

          if (rowset != null)
          {

            while (!System.Convert.ToBoolean(rowset.EOF))
            {
              PriceList pl = new PriceList();
              pl.ID = (int)rowset.get_Value("id_prop");
              pl.Name = rowset.get_Value("nm_name").ToString();
              pl.Description = rowset.get_Value("nm_desc").ToString();
              //pl.Currency = (SystemCurrencies) Enum.Parse(typeof(SystemCurrencies), rowset.get_Value("nm_currency_code").ToString());
              pl.Currency = (SystemCurrencies)EnumHelper.GetEnumByValue(typeof(SystemCurrencies), (string)rowset.get_Value("nm_currency_code"));

              priceListColl.Add(pl);
              rowset.MoveNext();
            }
          }

        }
        catch (MASBasicException masBasic)
        {
          m_PriceListLogger.LogException("Exception while getting pricelist details", masBasic);
          throw;
        }
        catch (COMException comE)
        {
          m_PriceListLogger.LogException("COM Exception getting pricelist details", comE);
          throw new MASBasicException(comE.Message);
        }
        catch (Exception e)
        {
          m_PriceListLogger.LogException("Exception getting pricelist details", e);
          throw new MASBasicException("Error getting pricelist details");
        }
      }
    }


    public void GetPriceList(int PriceListId, out PriceList PriList)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetPriceList"))
      {
        try
        {
          MTProductCatalog mtpc = new MTProductCatalog();
          MTPriceList mtpl = new MTPriceList();
          mtpl = mtpc.GetPriceList(PriceListId);
          PriceList plobj = new PriceList();
          plobj.Name = mtpl.Name;
          //plobj.Currency = (SystemCurrencies)Enum.Parse(typeof(SystemCurrencies), mtpl.CurrencyCode);
          plobj.Currency = (SystemCurrencies)EnumHelper.GetEnumByValue(typeof(SystemCurrencies), mtpl.CurrencyCode);
          plobj.Description = mtpl.Description;
          plobj.ID = mtpl.ID;
          PriList = plobj;
        }
        catch (MASBasicException masBasic)
        {
          m_PriceListLogger.LogException("Exception while retrieving pricelist properties", masBasic);
          throw;
        }
        catch (COMException comE)
        {
          m_PriceListLogger.LogException("COM Exception getting pricelist name", comE);
          throw new MASBasicException("Error getting pricelist properties");
        }
        catch (Exception e)
        {
          m_PriceListLogger.LogException("Exception getting price list name", e);
          throw new MASBasicException("Error getting pricelist name");
        }

      }
    }


    /// <summary>
    /// Remove Rate Schedule from the shared pricelist.
    /// </summary>
    /// <param name="plID">Pricelist Id</param>
    /// <param name="rschedID">rate schedule id</param>
    public void RemoveRateScheduleFromSharedPriceList(PCIdentifier plID, int rschedID)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("RemoveRateScheduleFromSharedPriceList"))
      {
        try
        {
          int priceListId = PCIdentifierResolver.ResolvePriceList(plID);

          if (priceListId == -1)
          {
            throw new MASBasicException("Invalid Pricelist ID specified.");
          }

          m_PriceListLogger.LogDebug("Pricelist found in database");

          using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
          {
            using (IMTConnection conn = ConnectionManager.CreateConnection(PCWS_QUERY_FOLDER))
            {
              using (IMTCallableStatement removeStmt = conn.CreateCallableStatement("sp_DeleteRateSchedule"))
              {
                m_PriceListLogger.LogDebug(string.Format("Executing DeleteRateSchedule for rate schedule id : {0}", rschedID));
                try
                {
                  removeStmt.AddParam("a_rsID", MTParameterType.Integer, rschedID);

                  try
                  {
                    removeStmt.ExecuteNonQuery();
                  }
                  catch (Exception e)
                  {
                    m_PriceListLogger.LogException(string.Format("Error while executing DeleteRateSchedule for rate schedule id : {0}", rschedID), e);
                    throw;
                  }
                }
                catch (Exception e)
                {
                  m_PriceListLogger.LogDebug(string.Format("Error occurred during DeleteRateSchedule for rate schedule id : {0}, Error:{1}", rschedID, e.Message));
                  throw;
                }
              }
            }

            scope.Complete();
          }
        }
        catch (MASBasicException masE)
        {
          m_PriceListLogger.LogException("MAS Exception caught removing rate schedule from shared pricelist", masE);
          throw;
        }
        catch (Exception e)
        {
          m_PriceListLogger.LogException("Error while removing rate schedule from shared pricelist.", e);
          throw new MASBasicException("Error while removing rate schedule from shared pricelist.");
        }
      }
    }

    /// <summary>
    /// Create or Update Shared Pricelist.
    /// </summary>
    /// <param name="priceList">Pricelist to be added/updated.</param>
    public void SaveSharedPriceList(ref PriceList priceList)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("SaveSharedPriceList"))
      {
        try
        {
          int PRICELIST_TYPE_SHARED = 1;

          PCIdentifier plIdentifier = null;

          #region Checking pricelist exists.
          if (priceList.ID.HasValue && priceList.IsNameDirty)
          {
            plIdentifier = new PCIdentifier(priceList.ID.Value, priceList.Name);
          }
          else if (priceList.ID.HasValue)
          {
            plIdentifier = new PCIdentifier(priceList.ID.Value);
          }
          else
          {
            plIdentifier = new PCIdentifier(priceList.Name);
          }
          #endregion

          using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
          {
            MetraTech.Interop.MTAuth.IMTSessionContext context = GetSessionContext();

            priceList.ID = PCIdentifierResolver.ResolvePriceList(plIdentifier, true);

            using (IMTConnection conn = ConnectionManager.CreateConnection(PCWS_QUERY_FOLDER))
            {

              if (priceList.ID.Value != -1)
              {
                #region Updating Shared pricelist.
                m_PriceListLogger.LogDebug("Updating shared pricelist");
                m_PriceListLogger.LogDebug("Updating base props for shared pricelist.");

                BasePropsUtils.UpdateBaseProps(context,
                                priceList.Description,
                                priceList.IsDescriptionDirty,
                                null,
                                false,
                                priceList.ID.Value);

                m_PriceListLogger.LogDebug("Preparing update statement for shared pricelist.");
                using (IMTAdapterStatement updatePlStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__UPDATE_PRICELIST_PCWS__"))
                {
                  updatePlStmt.AddParam("%%TYPE%%", PRICELIST_TYPE_SHARED);
                  updatePlStmt.AddParam("%%ID_PL%%", priceList.ID.Value);
                  updatePlStmt.AddParam("%%CURRENCY_CODE%%", EnumHelper.GetValueByEnum(priceList.Currency));
                  try
                  {
                    m_PriceListLogger.LogDebug("Executing Update Statement for shared pricelist.");
                    updatePlStmt.ExecuteNonQuery();
                  }
                  catch (Exception e)
                  {
                    m_PriceListLogger.LogException("Error while updating shared pricelist", e);
                    throw;
                  }
                }

                AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_PL_UPDATE, context.AccountID, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, priceList.ID.Value,
                                        String.Format("Successfully created shared price list: {0}", priceList.ID.Value));
                #endregion
              }

              else
              {
                #region Adding Shared pricelist.
                m_PriceListLogger.LogDebug("Adding Shared pricelist.");
                m_PriceListLogger.LogDebug("Updating base props for shared pricelist.");
                priceList.ID = BasePropsUtils.CreateBaseProps(context, priceList.Name, priceList.Description, null, PRICELIST_KIND);

                m_PriceListLogger.LogDebug("Preparing update statement for shared pricelist.");
                using (IMTAdapterStatement createStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__ADD_PRICELIST_PCWS__"))
                {
                  createStmt.AddParam("%%ID_PL%%", priceList.ID.Value);
                  createStmt.AddParam("%%TYPE%%", PRICELIST_TYPE_SHARED);
                  createStmt.AddParam("%%CURRENCY_CODE%%", EnumHelper.GetValueByEnum(priceList.Currency));
                  try
                  {
                    createStmt.ExecuteNonQuery();
                    m_PriceListLogger.LogDebug("Executing insert Statement for shared pricelist.");
                  }
                  catch (Exception e)
                  {
                    m_PriceListLogger.LogException("Error while creating shared pricelist", e);
                    throw;
                  }

                  AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_PL_CREATE, context.AccountID, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
                                          String.Format("Successfully created shared price list: {0}", priceList.ID.Value));

                  m_PriceListLogger.LogDebug(string.Format("Successfully created shared price list : {0}", priceList.ID.Value));
                }
                #endregion
              }

              ProcessLocalizationData(priceList.ID.Value, null, false, priceList.LocalizedDescriptions, priceList.IsLocalizedDescriptionsDirty);



            }

            scope.Complete();
          }

        }
        catch (MASBasicException masE)
        {
          m_PriceListLogger.LogException("MAS Exception caught saving shared pricelist", masE);
          throw;
        }
        catch (Exception e)
        {
          m_PriceListLogger.LogException("Error saving shared price list", e);
          throw new MASBasicException("Error while saving shared price list");
        }
      }
    }

    public void GetSharedPriceLists(ref MTList<PriceList> sharedPriceLists)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetSharedPriceLists"))
      {
        string priceListIds = "";
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(PCWS_QUERY_FOLDER))
          {
            Dictionary<int, PriceList> priceListDictionary = new Dictionary<int, PriceList>();

            // return high level list of priceable item instances in the sytstem
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(PCWS_QUERY_FOLDER, "__GET_SHARED_PRICELISTS_HL__"))
            {
              ApplyFilterSortCriteria<PriceList>(stmt, sharedPriceLists);

              using (IMTDataReader dataReader = stmt.ExecuteReader())
              {
                if (dataReader.FieldCount > 0)
                {
                  int idxID = dataReader.GetOrdinal("ID");
                  int idxCurrency = dataReader.GetOrdinal("Currency");
                  int idxName = dataReader.GetOrdinal("Name");
                  int idxDescription = dataReader.GetOrdinal("Description");

                  while (dataReader.Read())
                  {
                    PriceList priceList = new PriceList();

                    if (!dataReader.IsDBNull(idxID))
                    {
                      priceList.ID = dataReader.GetInt32(idxID);
                    }

                    if (!dataReader.IsDBNull(idxCurrency))
                    {
                      //priceList.Currency = (SystemCurrencies)Enum.Parse(typeof(SystemCurrencies), dataReader.GetString(idxCurrency));
                      priceList.Currency = (SystemCurrencies)EnumHelper.GetEnumByValue(typeof(SystemCurrencies), dataReader.GetString(idxCurrency));
                    }

                    if (!dataReader.IsDBNull(idxName))
                    {
                      priceList.Name = dataReader.GetString(idxName);
                    }

                    if (!dataReader.IsDBNull(idxDescription))
                    {
                      priceList.Description = dataReader.GetString(idxDescription);
                    }

                    priceListDictionary[priceList.ID.Value] = priceList;
                    priceListIds += priceList.ID.Value.ToString() + ",";

                    sharedPriceLists.Items.Add(priceList);
                  }

                  sharedPriceLists.TotalRows = stmt.TotalRows;
                }
              }

              if (priceListIds.Length > 0)
              {
                // remove trailing comma
                int length = priceListIds.Length - 1;
                priceListIds = priceListIds.Remove(length, 1);

                using (IMTAdapterStatement local = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_LOCALIZED_PROPS__"))
                {
                  local.AddParam("%%PITYPE_IDS%%", priceListIds);
                  using (IMTDataReader localizedReader = local.ExecuteReader())
                  {
                    while (localizedReader.Read())
                    {
                      int id = localizedReader.GetInt32("ID");
                      PriceList priceList = priceListDictionary[id];
                      priceList.LocalizedDescriptions = new Dictionary<LanguageCode, string>();

                      if (!(localizedReader.IsDBNull("LanguageCode") || localizedReader.IsDBNull("Description")))
                      {
                        LanguageCode langCode = (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), localizedReader.GetInt32("LanguageCode").ToString());
                        if (!localizedReader.IsDBNull("Description"))
                          priceList.LocalizedDescriptions.Add(langCode, localizedReader.GetString("Description"));
                      }
                    }
                  }
                }
              }
            }
          }
        }
        catch (Exception e)
        {
          m_PriceListLogger.LogException("Error getting shared price lists", e);
          throw new MASBasicException("Error while getting shared price lists");
        }
      }
    }


    private PriceList GetSharedPriceList(PCIdentifier plID)
    {
      int priceListId = -1;
      priceListId = PCIdentifierResolver.ResolvePriceList(plID, true);

      if (priceListId == -1)
        return null;

      return GetSharedPriceList(priceListId);
    }

    private PriceList GetSharedPriceList(int priceListId)
    {
      PriceList priceList = null;

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTMultiSelectAdapterStatement stmt = conn.CreateMultiSelectStatement(PCWS_QUERY_FOLDER, "__GET_SHARED_PRICELIST__"))
        {
          stmt.AddParam("%%PRICELIST_ID%%", priceListId);
          stmt.SetResultSetCount(2);

          using (IMTDataReader rdr = stmt.ExecuteReader())
          {
            if (rdr.Read())
            {
              priceList = new PriceList();
              priceList.ID = priceListId;

              int idxCurrency = rdr.GetOrdinal("Currency");
              int idxName = rdr.GetOrdinal("Name");
              int idxDescription = rdr.GetOrdinal("Description");

              if (!rdr.IsDBNull(idxCurrency))
              {
                priceList.Currency = (SystemCurrencies)EnumHelper.GetEnumByValue(typeof(SystemCurrencies), rdr.GetString(idxCurrency));
              }

              if (!rdr.IsDBNull(idxName))
              {
                priceList.Name = rdr.GetString(idxName);
              }

              if (!rdr.IsDBNull(idxDescription))
              {
                priceList.Description = rdr.GetString(idxDescription);
              }

              if (rdr.NextResult())
              {
                priceList.ParameterTables = new List<PCIdentifier>();

                int idxParamTableID = rdr.GetOrdinal("id_pt");

                while (rdr.Read())
                {
                  priceList.ParameterTables.Add(new PCIdentifier(rdr.GetInt32(idxParamTableID), rdr.GetString("nm_name")));
                }
              }

              priceList.LocalizedDescriptions = new Dictionary<LanguageCode, string>();

              PopulateLocalizedNamesAndDescriptions(priceListId.ToString(), null, priceList.LocalizedDescriptions);
            }
          }
        }
      }

      return priceList;
    }

    public void GetSharedPriceList(PCIdentifier plID, out PriceList priceList)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetSharedPriceList"))
      {
        priceList = null;

        try
        {
          int priceListId = -1;
          priceListId = PCIdentifierResolver.ResolvePriceList(plID, true);

          if (priceListId == -1)
            throw new MASBasicException("Invalid Pricelist id specified");

          priceList = GetSharedPriceList(priceListId);
        }
        catch (Exception e)
        {
          m_PriceListLogger.LogException("Error getting shared price list", e);
          throw new MASBasicException("Error while getting shared price list");
        }
      }
    }

    public void DeleteSharedPriceList(PCIdentifier plID)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DeleteSharedPriceList"))
      {
        try
        {
          int pl_id = PCIdentifierResolver.ResolvePriceList(plID, true);

          if (pl_id == -1)
          {
            throw new MASBasicException("Invalid pricelist specified");
          }

          m_PriceListLogger.LogDebug(String.Format("About to delete pricelist {0} ", pl_id));
          using (IMTConnection connection = ConnectionManager.CreateConnection())
          {
            using (IMTCallableStatement deletePriceList = connection.CreateCallableStatement("sp_DeletePricelist"))
            {
              deletePriceList.AddParam("a_plID", MTParameterType.Integer, pl_id);
              deletePriceList.AddOutputParam("status", MTParameterType.Integer);

              deletePriceList.ExecuteNonQuery();

              int retval = -1;
              retval = (int)deletePriceList.GetOutputValue("status");

              switch (retval)
              {
                case 0:
                  AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_PL_DELETE, -1, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
                      String.Format("Successfully Deleted Pricelist: {0}", pl_id));
                  m_PriceListLogger.LogDebug(String.Format("Successfully deleted pricelist {0} ", pl_id));
                  break;
                case 1:
                  m_PriceListLogger.LogError("This product offerring is currently in use.");
                  throw new MASBasicException("Product Offering is currently in use.");
                  break;
                case 2:
                  m_PriceListLogger.LogError("MTPCUSER_CANNOT_DELETE_PRICELIST_ACCUSED");
                  throw new MASBasicException("MTPCUSER_CANNOT_DELETE_PRICELIST_ACCUSED");
                  break;
                default:
                  m_PriceListLogger.LogError("Unknown error occurred.");
                  throw new MASBasicException("Unknown error occurred");
                  break;
              }
            }
          }
        }
        catch (MASBasicException masE)
        {
          m_PriceListLogger.LogException("MAS Exception caught in DeletePriceList", masE);
          throw;
        }
        catch (Exception e)
        {
          m_PriceListLogger.LogException("Unexpected exception caught in DeletePriceList", e);
          throw new MASBasicException("Unexpected error deleting price list.  Please ask system administrator to review server logs.");
        }
      }
    }

    public void GetParamTablesForSubscription(int subID, ref List<PriceableItemParamTable> paramTables)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetParamTablesForSubscription"))
      {
        try
        {
          Dictionary<string, PriceableItemParamTable> dict = new Dictionary<string, PriceableItemParamTable>();

          using (IMTConnection conn = ConnectionManager.CreateConnection(PCWS_QUERY_FOLDER))
          {
            using (IMTMultiSelectAdapterStatement stmt = conn.CreateMultiSelectStatement(PCWS_QUERY_FOLDER, "__GET_PTS_AND_PIINSTANCES_FOR_SUB__"))
            {
              stmt.SetResultSetCount(3);

              stmt.AddParam("%%ID_SUB%%", subID);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                if (rdr.Read())
                {
                  rdr.NextResult();

                  if (rdr.FieldCount > 0)
                  {
                    while (rdr.Read())
                    {
                      int idPIInstance = rdr.GetInt32(0);
                      string piName = rdr.GetString(1);

                      PriceableItemParamTable pipt = new PriceableItemParamTable();
                      pipt.piInstanceID = new PCIdentifier(idPIInstance, piName);

                      int ptId = rdr.GetInt32(2);
                      string ptName = rdr.GetString(3);

                      pipt.paramTableID = new PCIdentifier(ptId, ptName);

                      if (!rdr.IsDBNull(4))
                      {
                        pipt.CanICB = StringUtils.ConvertToBoolean(rdr.GetString(4));
                      }
                      if (!rdr.IsDBNull(5))
                      {
                        pipt.PersonalRate = StringUtils.ConvertToBoolean(rdr.GetString(5));
                      }

                      paramTables.Add(pipt);

                      dict.Add(string.Format("{0}_{1}", idPIInstance, ptId), pipt);
                    }
                  }

                  rdr.NextResult();

                  while (rdr.Read())
                  {
                    int pi_id = rdr.GetInt32(0);
                    int pt_id = rdr.GetInt32(1);

                    if (dict.ContainsKey(string.Format("{0}_{1}", pi_id, pt_id)))
                    {
                      PriceableItemParamTable pipt = dict[string.Format("{0}_{1}", pi_id, pt_id)];

                      if (!rdr.IsDBNull(2) && !rdr.IsDBNull(3))
                      {
                        int languageCode = rdr.GetInt32(2);
                        LanguageCode langCode = (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), languageCode.ToString());
                        pipt.LocalizedPIInstDisplayNames[langCode] = rdr.GetString(3);
                      }

                      if (!rdr.IsDBNull(4) && !rdr.IsDBNull(5))
                      {
                        int languageCode = rdr.GetInt32(4);
                        LanguageCode langCode = (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), languageCode.ToString());
                        pipt.LocalizedPTDisplayNames[langCode] = rdr.GetString(5);
                      }
                    }
                  }
                }
                else
                {
                  throw new MASBasicException("Invalid subscription specified");
                }
              }
            }
          }
        }
        catch (MASBasicException e)
        {
          m_PriceListLogger.LogException(String.Format("Cannot retrieve parameter tables for subscription id {0}.", subID), e);
          throw;
        }
        catch (Exception e)
        {
          m_PriceListLogger.LogException(String.Format("Error retrieving parameter tables for subscription id {0}.", subID), e);
          throw new MASBasicException(String.Format("Error retrieving parameter tables for subscription id {0}.", subID));
        }
      }
    }

    public void GetRateSchedulesForSubscription(int subId,
                                         PCIdentifier piInstanceID,
                                         PCIdentifier paramTableID,
                                         out List<BaseRateSchedule> rscheds)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetRateSchedulesForSubscription"))
      {
        int instanceId = PCIdentifierResolver.ResolvePIInstanceBySub(subId, piInstanceID, false);

        int ptId = -1;

        if (paramTableID.ID.HasValue)
        {
          if (CacheManager.ParamTableIdToNameMap.ContainsKey(paramTableID.ID.Value))
          {
            ptId = CacheManager.ParamTableIdToNameMap[paramTableID.ID.Value].ID;
          }
        }
        else if (!string.IsNullOrEmpty(paramTableID.Name))
        {
          if (CacheManager.ParamTableNameToIdMap.ContainsKey(paramTableID.Name.ToUpper()))
          {
            ptId = CacheManager.ParamTableNameToIdMap[paramTableID.Name.ToUpper()].ID;
          }
        }

        if (instanceId == -1)
          throw new MASBasicException(String.Format("Invalid Priceable Item Instance specified for subscription {0}.", subId));

        if (ptId == -1)
          throw new MASBasicException(String.Format("Invalid Parameter Table ID specified for subscription {0}.", subId));

        m_PriceListLogger.LogDebug("Retrieving rate schedules for parameter table {0}, pi instance {1}, and subscription {2}", ptId, instanceId, subId);

        Dictionary<int, BaseRateSchedule> schedEntryList = new Dictionary<int, BaseRateSchedule>();
        string ptName = CacheManager.ParamTableIdToNameMap[ptId].Name;

        rscheds = new List<BaseRateSchedule>();
        RateEntry defaultRateEntry = (RateEntry)RetrieveClassName(ptName.Replace('/', '_'), "DefaultRateEntry");
        RateEntry rateEntry = (RateEntry)RetrieveClassName(ptName.Replace('/', '_'), "RateEntry");
        Type brs = typeof(RateSchedule<,>);
        Type rateEntryType = rateEntry.GetType();
        PropertyInfo[] rateEntryProperties = rateEntryType.GetProperties();
        string columns = GetColumnsForRateEntry(rateEntryProperties);

        // create type of particular rate schedule based on the RateSched
        Type[] typeArgs = { rateEntry.GetType(), defaultRateEntry.GetType() };
        Type constructed = brs.MakeGenericType(typeArgs);

        using (IMTConnection connection = ConnectionManager.CreateConnection())
        {
          string ptTableName = CacheManager.ParamTableIdToNameMap[ptId].TableName;
          using (IMTMultiSelectAdapterStatement getRschedsStmt = connection.CreateMultiSelectStatement(PCWS_QUERY_FOLDER, "__GET_RSCHEDS_FOR_SUBSCRIPTION__"))
          {
            getRschedsStmt.AddParam("%%ID_PI_INSTANCE%%", instanceId);
            getRschedsStmt.AddParam("%%ID_SUB%%", subId);
            getRschedsStmt.AddParam("%%ID_PT%%", ptId);
            getRschedsStmt.AddParam("%%COLUMNS%%", columns);
            getRschedsStmt.AddParam("%%PT_NAME%%", ptTableName);
            getRschedsStmt.AddParam("%%MT_TIME%%", MetraTime.Now);
            getRschedsStmt.SetResultSetCount(2);

            using (IMTDataReader scheduleReader = getRschedsStmt.ExecuteReader())
            {
              GetRateSchedules(scheduleReader, constructed, rateEntryType, schedEntryList, ref rscheds);
              scheduleReader.NextResult();
              GetRateEntries(scheduleReader, schedEntryList, rateEntryType, defaultRateEntry.GetType(), rateEntryProperties);
            }
          }
        }
        m_PriceListLogger.LogDebug("Successfully retrieved rate schedules for the subscription.");
      }
    }

    public void SaveRateSchedulesForSubscription(int subId,
                                          PCIdentifier piInstanceID,
                                          PCIdentifier paramTableID,
                                          List<BaseRateSchedule> rscheds)
    {
      using (new HighResolutionTimer("SaveRateSchedulesForSubscription"))
      using (var scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(),
                                         EnterpriseServicesInteropOption.Full))
      {
        Application.ProductManagement.PriceListService.SaveRateSchedulesForSubscription(subId, piInstanceID,
                                                                                         paramTableID, rscheds,
                                                                                         m_PriceListLogger,
                                                                                         GetSessionContext());

        scope.Complete();
      }
    }

    public void RemoveRateScheduleFromSubscription(int subId, int rschedID)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("RemoveRateScheduleFromSubscription"))
      {
        m_PriceListLogger.LogDebug(String.Format("Trying to remove rate schedule from subscription {0}", subId));
        bool vaildatedSubSched = false;

        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
        {
          using (IMTConnection connection = ConnectionManager.CreateConnection())
          {
            using (IMTAdapterStatement checkSchedSubStmt = connection.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__CHECK_SUB_RSCHED_MAPPING__"))
            {
              checkSchedSubStmt.AddParam("%%ID_SUB%%", subId);
              checkSchedSubStmt.AddParam("%%RSCHED_ID%%", rschedID);
              using (IMTDataReader checkSchedSubReader = checkSchedSubStmt.ExecuteReader())
              {
                while (checkSchedSubReader.Read())
                  vaildatedSubSched = true;
              }
            }

            if (vaildatedSubSched)
            {
              DeleteRateSchedule(rschedID);
            }
          }
          scope.Complete();
        }

        if (!vaildatedSubSched)
          throw new MASBasicException("Subscription and Rsched mapping is incorrect.");

        m_PriceListLogger.LogDebug("Successfully removed rate schedule {0} from subscription {1}", rschedID, subId);
      }
    }

    public void GetRateSchedulesForProductOffering(PCIdentifier poID,
                                            PCIdentifier piInstanceID,
                                            PCIdentifier paramTableID,
                                            out List<BaseRateSchedule> rscheds)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetRateSchedulesForProductOffering"))
      {
        int productOfferingId = PCIdentifierResolver.ResolveProductOffering(poID);
        int instanceId = PCIdentifierResolver.ResolvePriceableItemInstance(productOfferingId, piInstanceID, false);
        int ptId = -1;
        if (paramTableID.ID.HasValue)
        {
          PTTableDef ptDef = null;
          if (!CacheManager.ParamTableIdToNameMap.TryGetValue(paramTableID.ID.Value, out ptDef))
          {
            throw new MASBasicException(String.Format("A Parameter Table ID of {0} for product offering {1} is not valid.", paramTableID.ID.Value, productOfferingId));
          }

          ptId = ptDef.ID;
        }
        else
        {
          PTTableDef ptDef = null;
          if (!CacheManager.ParamTableNameToIdMap.TryGetValue(paramTableID.Name.Trim().ToUpper(), out ptDef))
          {
            throw new MASBasicException(String.Format("A Parameter Table Name of {0} for product offering {1} is not valid.", paramTableID.Name, productOfferingId));
          }

          ptId = ptDef.ID;
        }

        if (productOfferingId == -1)
          throw new MASBasicException("Invalid Parameter Table ID specified for product offering.");

        if (instanceId == -1)
          throw new MASBasicException(String.Format("Invalid Priceable Item Instance specified for product offering {0}.", productOfferingId));

        if (ptId == -1)
          throw new MASBasicException(String.Format("Invalid Parameter Table ID specified for product offering {0}.", productOfferingId));

        m_PriceListLogger.LogDebug("Retrieving rate schedules for parameter table {0}, pi instance {1}, and product offering {2}", ptId, instanceId, productOfferingId);

        Dictionary<int, BaseRateSchedule> schedEntryList = new Dictionary<int, BaseRateSchedule>();
        rscheds = new List<BaseRateSchedule>();

        string ptName = CacheManager.ParamTableIdToNameMap[ptId].Name;
        RateEntry defaultRateEntry = (RateEntry)RetrieveClassName(ptName.Replace('/', '_'), "DefaultRateEntry");
        RateEntry rateEntry = (RateEntry)RetrieveClassName(ptName.Replace('/', '_'), "RateEntry");
        Type rateEntryType = rateEntry.GetType();
        PropertyInfo[] rateEntryProperties = rateEntryType.GetProperties();
        string columns = GetColumnsForRateEntry(rateEntryProperties);

        // create type of particular rate schedule based on the RateSched
        Type brs = typeof(RateSchedule<,>);
        Type[] typeArgs = { rateEntryType, defaultRateEntry.GetType() };
        Type constructed = brs.MakeGenericType(typeArgs);

        using (IMTConnection connection = ConnectionManager.CreateConnection())
        {
          string ptTableName = CacheManager.ParamTableIdToNameMap[ptId].TableName;
          using (IMTMultiSelectAdapterStatement getRschedsStmt = connection.CreateMultiSelectStatement(PCWS_QUERY_FOLDER, "__GET_RSCHEDS_FOR_PO__"))
          {
            getRschedsStmt.AddParam("%%ID_PI_INSTANCE%%", instanceId);
            getRschedsStmt.AddParam("%%ID_PO%%", productOfferingId);
            getRschedsStmt.AddParam("%%ID_PT%%", ptId);
            getRschedsStmt.AddParam("%%COLUMNS%%", columns);
            getRschedsStmt.AddParam("%%PT_NAME%%", ptTableName);
            getRschedsStmt.AddParam("%%MT_TIME%%", MetraTime.Now);
            getRschedsStmt.SetResultSetCount(2);

            using (IMTDataReader scheduleReader = getRschedsStmt.ExecuteReader())
            {
              GetRateSchedules(scheduleReader, constructed, rateEntryType, schedEntryList, ref rscheds);
              scheduleReader.NextResult();
              GetRateEntries(scheduleReader, schedEntryList, rateEntryType, defaultRateEntry.GetType(), rateEntryProperties);
            }
          }
        }
        m_PriceListLogger.LogDebug("Successfully retrieved rate schedules for the product offering.");
      }
    }

    public void SaveRateScheduleForProductOffering(PCIdentifier poID,
                                             PCIdentifier piInstanceID,
                                             PCIdentifier paramTableID,
                                             List<BaseRateSchedule> rscheds)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("SaveRateScheduleForProductOffering"))
      {
        try
        {
          int id_po = -1;
          id_po = PCIdentifierResolver.ResolveProductOffering(poID);

          if (id_po == -1)
          {
            throw new MASBasicException("Invalid product offering specified.");
          }

          int id_instance = -1;
          id_instance = PCIdentifierResolver.ResolvePriceableItemInstance(id_po, piInstanceID);

          if (id_instance == -1)
          {
            throw new MASBasicException("Invalid priceable item instance specified");
          }

          int id_paramtable = -1;

          if (paramTableID.ID.HasValue)
          {
            if (CacheManager.ParamTableIdToNameMap.ContainsKey(paramTableID.ID.Value))
            {
              id_paramtable = paramTableID.ID.Value;
            }
          }
          else if (!string.IsNullOrEmpty(paramTableID.Name))
          {
            if (CacheManager.ParamTableNameToIdMap.ContainsKey(paramTableID.Name.ToUpper()))
            {
              id_paramtable = CacheManager.ParamTableNameToIdMap[paramTableID.Name.ToUpper()].ID;
            }
          }

          if (id_paramtable == -1)
          {
            throw new MASBasicException("Invalid parameter table specified");
          }

          using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
          {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
              int pricelistId = -1;
              int templateId = -1;
              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_PRICELIST_MAPPING_PCWS__"))
              {
                stmt.AddParam("%%PO_ID%%", id_po);
                stmt.AddParam("%%PI_ID%%", id_instance);
                stmt.AddParam("%%PT_ID%%", id_paramtable);

                using (IMTDataReader rdr = stmt.ExecuteReader())
                {
                  if (rdr.Read())
                  {
                    pricelistId = rdr.GetInt32("id_pricelist");
                    templateId = rdr.GetInt32("id_pi_template");
                  }
                  else
                  {
                    throw new MASBasicException(string.Format("Unable to locate pricelist mapping for PO {0}, PI Instance {1}, Paramter table {2}", id_po, id_instance, id_paramtable));
                  }
                }
              }

              Application.ProductManagement.PriceListService.UpsertRateSchedulesForPricelist(pricelistId, PriceListTypes.DEFAULT, templateId, id_paramtable, rscheds, m_PriceListLogger, GetSessionContext());
            }

            scope.Complete();
          }
        }
        catch (MASBasicException masE)
        {
          m_PriceListLogger.LogException("MAS Exception caught in Save Rate Schedules for Shared Price List", masE);
          throw;
        }
        catch (Exception e)
        {
          m_PriceListLogger.LogException("Unexpected exception caught in Save Rate Schedules for Shared Price List", e);
          throw new MASBasicException("Unexpected error saving rate schedules for shared price list.  Please ask system administrator to review server logs.");
        }
      }
    }

    public void SavePriceListMappingForProductOffering(PCIdentifier poID,
                                                PCIdentifier piInstanceID,
                                                PCIdentifier paramTableDefID, ref PriceListMapping plMap)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("SavePriceListMappingForProductOffering"))
      {
        try
        {
          if (plMap == null)
          {
            throw new MASBasicException("A PriceListMapping must be supplied.");
          }

          int poId = -1;
          if (poID.ID.HasValue)
          {
            poId = poID.ID.Value;
          }
          else
          {
            poId = PCIdentifierResolver.ResolveProductOffering(poID, true);
          }

          if (poId == -1)
            throw new MASBasicException("Invalid Product Offering id specified");


          int piInstanceId = -1;
          if (piInstanceID.ID.HasValue)
          {
            piInstanceId = piInstanceID.ID.Value;
          }
          else
          {
            piInstanceId = PCIdentifierResolver.ResolvePriceableItemInstance(poId, piInstanceID, true);
          }

          if (piInstanceId == -1)
            throw new MASBasicException("Invalid Priceable Item Instance Specified");

          int paramTableDefId = -1;
          if (paramTableDefID.ID.HasValue)
          {
            paramTableDefId = paramTableDefID.ID.Value;
          }
          else
          {
            PTTableDef paramTableDef = new PTTableDef();
            if (!CacheManager.ParamTableNameToIdMap.TryGetValue(paramTableDefID.Name.Trim().ToUpper(), out paramTableDef))
            {
              throw new MASBasicException("Invalid Parameter Table Defintion Id specified");
            }

            paramTableDefId = paramTableDef.ID;
            if (paramTableDefId == -1)
              throw new MASBasicException("Bad Parameter Table Defintion Id specified");
          }

          #region Check Incoming Pricelist exists in db and whether its shared / not.
          bool isPriceListNewShared = false;

          PriceList checkIncPriceList = GetSharedPriceList(new PCIdentifier(plMap.priceListID)); //read it as Check Incoming Pricelist.
          if (checkIncPriceList != null)
          {
            isPriceListNewShared = true;
          }
          else
          {
            GetPriceList(plMap.priceListID, out checkIncPriceList);
            if (checkIncPriceList == null)
            {
              throw new MASBasicException("Pricelist does not exist" + plMap.priceListID);
            }
          }

          // The code below used to cause a false alarm due to an error entry appearing in the log
          // try
          // {
          //     GetSharedPriceList(new PCIdentifier(plMap.priceListID), out checkIncPriceList);
          //     isPriceListNewShared = true;
          // }
          // catch
          // {
          //     GetPriceList(plMap.priceListID, out checkIncPriceList);
          //     if (checkIncPriceList == null)
          //     {
          //         throw new MASBasicException("Pricelist does not exist" + plMap.priceListID);
          //    }
          // }

          #endregion



          PriceListMapping checkPlMap = null;
          GetPriceListMappingForProductOffering(poID, piInstanceID, paramTableDefID, out checkPlMap);

          if (checkPlMap != null)
          {
            /* **** (-: ************STICKY NOTE ************* :-) */

            // **** Non Shared --> Shared is allowed.
            // **** Shared --> Another Shared is allowed.
            // **** Non Shared --> another Non Shared (not a default price list for PO) is not allowed.
            // **** Shared --> Non Shared (not a default price list for PO) is not allowed.
            // **** Shared --> Non Shared (default price list for PO) is allowed.

            /* **** (-: ************STICKY NOTE ************* :-) */


            //Incoiming pricelist is non-shared and existing is non-shared then check whether its default pricelist for PO.
            if (!isPriceListNewShared)
            {
              //if existing pricelist is non-shared one.
              if (checkPlMap.SharedPriceList.HasValue && checkPlMap.SharedPriceList == false)
              {
                if (plMap.priceListID != checkPlMap.priceListID)
                  throw new MASBasicException("Invalid Pricelist Id provided");
              }
              else //either existing price list id not available or shared then check incoming non-shared one is default pricelist for po.
              {
                int? defPriceListIDForPO = GetDefaultNonSharedPriceListForPO(poId);

                //throw error if incoming non-shared pricelist id is not same as default non-shared pricelist id for po.
                if (defPriceListIDForPO.HasValue && defPriceListIDForPO.Value != plMap.priceListID)
                {
                  throw new MASBasicException("Cannot set price list. Incoming Non-shared price list is not same as default price list for PO");
                }
              }

            }
          }
          else
          {   //If pricelist mapping not exists, incoming pricelist is non-shared and not a default non-shared pricelist for PO then throw error.
            int? defPriceListIDForPO = GetDefaultNonSharedPriceListForPO(poId);
            if (!isPriceListNewShared && defPriceListIDForPO.HasValue && defPriceListIDForPO.Value != plMap.priceListID)
            {
              throw new MASBasicException("Cannot set price list. Incoming Non-shared price list is not same as default price list for PO");
            }
          }


          int oldPriceListId = 0;
          String oldCanICB = "N";
          using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
          {
            MetraTech.Interop.MTAuth.IMTSessionContext context = GetSessionContext();

            using (IMTConnection conn = ConnectionManager.CreateConnection(PCWS_QUERY_FOLDER))
            {
              if (checkPlMap != null)
              {
                #region Get old map info for auditing
                m_PriceListLogger.LogDebug("Updating price list mapping {0} for product offering {1}.", plMap.priceListID, poId);
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PROD_CATALOG_QUERY_FOLDER, "__GET_PRC_LST_MAPPING__"))
                {
                  stmt.AddParam("%%ID_PI%%", piInstanceId);
                  stmt.AddParam("%%ID_PTD%%", paramTableDefId);

                  try
                  {
                    using (IMTDataReader dataReader = stmt.ExecuteReader())
                    {
                      if (dataReader.Read())
                      {
                        oldPriceListId = dataReader.GetInt32(dataReader.GetOrdinal("id_pricelist"));
                        oldCanICB = dataReader.GetString(dataReader.GetOrdinal("b_canICB"));
                      }
                    }
                  }
                  catch (Exception e)
                  {
                    m_PriceListLogger.LogException(String.Format("Error while updating price list mapping {0} for product offering {1}.", plMap.priceListID, poId), e);
                    throw e;
                  }
                }
                #endregion

                #region Update Price List Mapping
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__UPDATE_PL_MAPPING_FOR_PO__"))
                {
                  stmt.AddParam("%%ID_PI%%", piInstanceId);
                  stmt.AddParam("%%ID_PTD%%", paramTableDefId);
                  stmt.AddParam("%%ID_PO%%", poId);
                  stmt.AddParam("%%ID_PL%%", plMap.priceListID);
                  if (plMap.CanICB.HasValue)
                  {
                    stmt.AddParam("%%CAN_ICB%%", StringUtils.ConvertFromBoolean(plMap.CanICB.Value, "Y", "N"));
                  }
                  else
                  {
                    stmt.AddParam("%%CAN_ICB%%", "N");
                  }

                  try
                  {
                    m_PriceListLogger.LogDebug("Executing statement: Updating price list mapping {0} for product offering {1}.", plMap.priceListID, poId);
                    stmt.ExecuteNonQuery();
                  }
                  catch (Exception e)
                  {
                    m_PriceListLogger.LogException(String.Format("Error while updating price list mapping {0} for product offering {1}.", plMap.priceListID, poId), e);
                    throw e;
                  }
                }

                AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_PLM_UPDATE, context.AccountID, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, plMap.priceListID,
                                        String.Format("Successfully updated price list mapping {0} for product offering {1}, old prices list ID was {2}, old CanICB was {3}", plMap.priceListID, poId, oldPriceListId, oldCanICB));
                #endregion
              }
              else
              {
                #region Add Price List Mapping
                m_PriceListLogger.LogDebug("Adding price list mapping {0} to product offering {1}.", plMap.priceListID, poId);

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__ADD_PO_PIMAPPING_EX__"))
                {

                  stmt.AddParam("%%ID_PI%%", piInstanceId);
                  stmt.AddParam("%%ID_PTD%%", paramTableDefId);
                  stmt.AddParam("%%ID_PO%%", poId);
                  stmt.AddParam("%%ID_PL%%", plMap.priceListID);
                  if (plMap.CanICB.HasValue)
                  {
                    stmt.AddParam("%%CAN_ICB%%", StringUtils.ConvertFromBoolean(plMap.CanICB.Value, "Y", "N"));
                  }
                  else
                  {
                    stmt.AddParam("%%CAN_ICB%%", "N");
                  }

                  try
                  {
                    m_PriceListLogger.LogDebug("Executing statement: Adding price list mapping {0} to product offering {1}.", plMap.priceListID, poId);
                    stmt.ExecuteNonQuery();
                  }
                  catch (Exception e)
                  {
                    m_PriceListLogger.LogException(String.Format("Error while adding price list mapping {0} for product offering {1}.", plMap.priceListID, poId), e);
                    throw e;
                  }
                }

                AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_PLM_CREATE, context.AccountID, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, plMap.priceListID,
                                        String.Format("Successfully added price list mapping {0} to product offering {1}", plMap.priceListID, poId));
                #endregion
              }
            }

            plMap.piInstanceID = piInstanceId;
            plMap.paramTableDefID = paramTableDefId;

            scope.Complete();
          }

        }
        catch (Exception e)
        {
          m_PriceListLogger.LogException("Error saving price list mapping for PO", e);
          throw new MASBasicException("Error while saving price list mapping for PO");
        }
      }
    }

    public void GetPriceListMappingForProductOffering(PCIdentifier poID,
                                               PCIdentifier piInstanceID,
                                               PCIdentifier paramTableDefID,
                                               out PriceListMapping plMap)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetPriceListMappingForProductOffering"))
      {
        plMap = null;
        try
        {
          int poId = PCIdentifierResolver.ResolveProductOffering(poID, true);

          if (poId == -1)
            throw new MASBasicException("Invalid Product Offering id specified");

          int piInstanceId = PCIdentifierResolver.ResolvePriceableItemInstance(poId, piInstanceID, true);

          if (piInstanceId == -1)
            throw new MASBasicException("Invalid Priceable Item Instance id specified");

          int paramTableDefId = -1;
          if (paramTableDefID.ID.HasValue)
          {
            if (CacheManager.ParamTableIdToNameMap.ContainsKey(paramTableDefID.ID.Value))
            {
              paramTableDefId = CacheManager.ParamTableIdToNameMap[paramTableDefID.ID.Value].ID;
            }
          }
          else
          {
            if (CacheManager.ParamTableNameToIdMap.ContainsKey(paramTableDefID.Name.ToUpper()))
            {
              paramTableDefId = CacheManager.ParamTableNameToIdMap[paramTableDefID.Name.ToUpper()].ID;
            }
          }

          if (paramTableDefId == -1)
            throw new MASBasicException("Invalid Parmeter Table identifier specified");

          using (IMTConnection conn = ConnectionManager.CreateConnection(PCWS_QUERY_FOLDER))
          {
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(PCWS_QUERY_FOLDER, "__GET_PL_MAP_FOR_PO__"))
            {
              stmt.AddParam("%%ID_PI%%", piInstanceId);
              stmt.AddParam("%%ID_PTD%%", paramTableDefId);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                if (rdr.FieldCount > 0)
                {
                  int idxPriceListID = rdr.GetOrdinal("priceListID");
                  int idxSharedPriceList = rdr.GetOrdinal("sharedPriceList");
                  int idxPiInstanceID = rdr.GetOrdinal("piInstanceID");
                  int idxParamTableDefID = rdr.GetOrdinal("paramTableDefID");
                  int idxCanICB = rdr.GetOrdinal("b_CanICB");

                  while (rdr.Read())
                  {
                    plMap = new PriceListMapping();

                    plMap.priceListID = rdr.GetInt32(idxPriceListID);
                    plMap.SharedPriceList = (rdr.GetInt32(idxSharedPriceList) == 1 ? true : false);
                    plMap.piInstanceID = rdr.GetInt32(idxPiInstanceID);
                    plMap.paramTableDefID = rdr.GetInt32(idxParamTableDefID);
                    plMap.CanICB = StringUtils.ConvertToBoolean(rdr.GetString(idxCanICB));
                  }
                }
              }
            }
          }
        }
        catch (Exception e)
        {
          m_PriceListLogger.LogException("Error getting price list mapping for PO", e);
          throw new MASBasicException("Error while getting price list mapping for PO");
        }
      }
    }

    public void RemoveRateScheduleFromProductOffering(PCIdentifier poID, int rschedID)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("RemoveRateScheduleFromProductOffering"))
      {
        try
        {
          int po_id = PCIdentifierResolver.ResolveProductOffering(poID, false);

          if (po_id == -1)
          {
            throw new MASBasicException("Invalid product offering specified");
          }

          m_PriceListLogger.LogDebug("Removing Rate Schedule {0} from Product Offering {1}", rschedID, po_id);
          bool vaildatedPOSched = false;

          using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
          {
            using (IMTConnection connection = ConnectionManager.CreateConnection())
            {
              using (IMTAdapterStatement checkSchedPOStmt = connection.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__CHECK_PO_RSCHED_MAPPING__"))
              {
                checkSchedPOStmt.AddParam("%%ID_PO%%", po_id);
                checkSchedPOStmt.AddParam("%%RSCHED_ID%%", rschedID);
                using (IMTDataReader checkSchedPOReader = checkSchedPOStmt.ExecuteReader())
                {
                  while (checkSchedPOReader.Read())
                    vaildatedPOSched = true;
                }
              }

              if (vaildatedPOSched)
              {
                DeleteRateSchedule(rschedID);
              }
            }
            scope.Complete();
          }

          if (!vaildatedPOSched)
            throw new MASBasicException("Product Offering and Rate Schedule Mapping is Incorrect.");
          m_PriceListLogger.LogDebug("Removed Rate Schedule {0} from Product Offering {1}", rschedID, po_id);
        }
        catch (MASBasicException masE)
        {
          m_PriceListLogger.LogException("MAS Exception caught in RemoveRateScheduleFromProductOffering", masE);
          throw;
        }
        catch (Exception e)
        {
          m_PriceListLogger.LogException("Unexpected exception caught in RemoveRateScheduleFromProductOffering", e);
          throw new MASBasicException("Unexpected error removing rate schedule from product offering.  Please ask system administrator to review server logs.");
        }
      }
    }

    public void GetRateSchedulesForSharedPriceList(PCIdentifier priceListID, PCIdentifier paramTableID, out List<BaseRateSchedule> rscheds)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetRateSchedulesForSharedPriceList"))
      {
        int plId = PCIdentifierResolver.ResolvePriceList(priceListID);
        if (plId == -1)
          throw new MASBasicException(String.Format("Invalid Parameter Table ID specified for product offering id {0}.", plId));

        int ptId = -1;

        if (paramTableID.ID.HasValue)
        {
          if (CacheManager.ParamTableIdToNameMap.ContainsKey(paramTableID.ID.Value))
          {
            ptId = CacheManager.ParamTableIdToNameMap[paramTableID.ID.Value].ID;
          }
        }
        else
        {
          if (CacheManager.ParamTableNameToIdMap.ContainsKey(paramTableID.Name.ToUpper()))
          {
            ptId = CacheManager.ParamTableNameToIdMap[paramTableID.Name.ToUpper()].ID;
          }
        }

        if (ptId == -1)
          throw new MASBasicException(String.Format("Invalid Parameter Table ID specified for subscription {0}.", ptId));

        m_PriceListLogger.LogDebug("Retrieving rate schedules for shared pricelist {0} and parameter table {1}", plId, ptId);

        Dictionary<int, BaseRateSchedule> schedEntryList = new Dictionary<int, BaseRateSchedule>();
        rscheds = new List<BaseRateSchedule>();

        string ptName = CacheManager.ParamTableIdToNameMap[ptId].Name;
        RateEntry defaultRateEntry = (RateEntry)RetrieveClassName(ptName.Replace('/', '_'), "DefaultRateEntry");
        RateEntry rateEntry = (RateEntry)RetrieveClassName(ptName.Replace('/', '_'), "RateEntry");
        Type rateEntryType = rateEntry.GetType();
        PropertyInfo[] rateEntryProperties = rateEntryType.GetProperties();
        string columns = GetColumnsForRateEntry(rateEntryProperties);

        // create type of particular rate schedule based on the RateSched
        Type brs = typeof(RateSchedule<,>);
        Type[] typeArgs = { rateEntryType, defaultRateEntry.GetType() };
        Type constructed = brs.MakeGenericType(typeArgs);

        using (IMTConnection connection = ConnectionManager.CreateConnection())
        {
          string ptTableName = CacheManager.ParamTableIdToNameMap[ptId].TableName;
          using (IMTMultiSelectAdapterStatement getRschedsStmt = connection.CreateMultiSelectStatement(PCWS_QUERY_FOLDER, "__GET_RSCHED_BY_PL_AND_PT_ID__"))
          {
            getRschedsStmt.AddParam("%%PRICELIST_ID%%", plId);
            getRschedsStmt.AddParam("%%PT_ID%%", ptId);
            getRschedsStmt.AddParam("%%COLUMNS%%", columns);
            getRschedsStmt.AddParam("%%PT_NAME%%", ptTableName);
            getRschedsStmt.AddParam("%%MT_TIME%%", MetraTime.Now);
            getRschedsStmt.SetResultSetCount(2);

            using (IMTDataReader scheduleReader = getRschedsStmt.ExecuteReader())
            {
              GetRateSchedules(scheduleReader, constructed, rateEntryType, schedEntryList, ref rscheds);
              scheduleReader.NextResult();
              GetRateEntries(scheduleReader, schedEntryList, rateEntryType, defaultRateEntry.GetType(), rateEntryProperties);
            }
          }



        }
        m_PriceListLogger.LogDebug("Successfully retrieved rate schedules for the subscription.");
      }
    }

    public void SaveRateSchedulesForSharedPriceList(PCIdentifier priceListID, PCIdentifier piTemplateID, PCIdentifier paramTableID, List<BaseRateSchedule> rscheds)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("SaveRateSchedulesForSharedPriceList"))
      {
        try
        {
          int plID = -1;
          plID = PCIdentifierResolver.ResolvePriceList(priceListID);

          if (plID == -1)
          {
            throw new MASBasicException("Invalid Pricelist ID specified.");
          }

          int id_template = -1;
          id_template = PCIdentifierResolver.ResolvePriceableItemTemplate(piTemplateID);

          if (id_template == -1)
          {
            throw new MASBasicException("Invalid priceable item template specified");
          }

          int id_paramtable = -1;

          if (paramTableID.ID.HasValue)
          {
            if (CacheManager.ParamTableIdToNameMap.ContainsKey(paramTableID.ID.Value))
            {
              id_paramtable = paramTableID.ID.Value;
            }
          }
          else if (!string.IsNullOrEmpty(paramTableID.Name))
          {
            if (CacheManager.ParamTableNameToIdMap.ContainsKey(paramTableID.Name.ToUpper()))
            {
              id_paramtable = CacheManager.ParamTableNameToIdMap[paramTableID.Name.ToUpper()].ID;
            }
          }

          if (id_paramtable == -1)
          {
            throw new MASBasicException("Invalid parameter table specified");
          }

          using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
          {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
              Application.ProductManagement.PriceListService.UpsertRateSchedulesForPricelist(plID, PriceListTypes.DEFAULT, id_template, id_paramtable, rscheds, m_PriceListLogger, GetSessionContext());
            }

            scope.Complete();
          }
        }
        catch (MASBasicException masE)
        {
          m_PriceListLogger.LogException("MAS Exception caught in Save Rate Schedules for Shared Price List", masE);
          throw;
        }
        catch (Exception e)
        {
          m_PriceListLogger.LogException("Unexpected exception caught in Save Rate Schedules for Shared Price List", e);
          throw new MASBasicException("Unexpected error saving rate schedules for shared price list.  Please ask system administrator to review server logs.");
        }
      }
    }
    #endregion

    #region private methods

    private void GetRateSchedules(IMTDataReader scheduleReader, Type constructed, Type rateEntryType, Dictionary<int, BaseRateSchedule> schedEntryList, ref List<BaseRateSchedule> rscheds)
    {
      while (scheduleReader.Read())
      {
        BaseRateSchedule sched = (BaseRateSchedule)System.Activator.CreateInstance(constructed);
        List<PropertyInfo> properties = sched.GetProperties();

        sched.ID = scheduleReader.GetInt32("ID");
        sched.ParameterTableID = scheduleReader.GetInt32("ParameterTableID");
        sched.EffectiveDate = EffectiveDateUtils.GetEffectiveDate(scheduleReader, "Effective");
        sched.Description = scheduleReader.IsDBNull("Description") ? null : scheduleReader.GetString("Description");
        sched.ParameterTableName = CacheManager.ParamTableIdToNameMap[sched.ParameterTableID].Name;

        // Create List Of RateEntry for a particular rate sched
        Type re = typeof(List<>);
        Type reType = re.MakeGenericType(new System.Type[] { rateEntryType });
        foreach (PropertyInfo pi in properties)
        {
          if (pi.Name == "RateEntries")
          {
            object rateEntries = System.Activator.CreateInstance(reType);
            pi.SetValue(sched, rateEntries, null);

            List<RateEntry> entries = new List<RateEntry>();
            schedEntryList.Add(sched.ID.Value, sched);
          }
        }

        rscheds.Add(sched);
      }
    }

    private void GetRateEntries(IMTDataReader scheduleReader, Dictionary<int, BaseRateSchedule> schedEntryList, Type rateEntryType, Type defaultRateEntryType, PropertyInfo[] rateEntryProperties)
    {
      while (scheduleReader.Read())
      {
        RateEntry aRateEntry = null;
        bool bIsDefaultRateEntry = false;
        aRateEntry = GetRateEntry(rateEntryType, defaultRateEntryType, rateEntryProperties, scheduleReader, out bIsDefaultRateEntry);
        BaseRateSchedule temp = schedEntryList[aRateEntry.RateScheduleId.Value];
        if (bIsDefaultRateEntry)
        {
          temp.GetProperty("DefaultRateEntry").SetValue(temp, aRateEntry, null);
        }
        else
        {
          PropertyInfo propRateEntries = temp.GetProperty("RateEntries");
          IList list = (IList)propRateEntries.GetValue(temp, null);
          list.Add(aRateEntry);
        }
      }
    }

    private string GetColumnsForRateEntry(PropertyInfo[] rateEntryProperties)
    {
      string columns = "";
      foreach (PropertyInfo rateEntryProp in rateEntryProperties)
      {
        object[] rateEntryAttribs = rateEntryProp.GetCustomAttributes(typeof(MTRateEntryMetadataAttribute), false);
        if (rateEntryAttribs.Length > 0)
        {
          columns += string.Format(", c_{0}", ((MTRateEntryMetadataAttribute)rateEntryAttribs[0]).ColumnName);
        }
      }

      return columns;
    }

    private void DeleteRateSchedule(int rschedID)
    {
      using (IMTConnection connection = ConnectionManager.CreateConnection())
      {
        using (IMTCallableStatement deleteRsched = connection.CreateCallableStatement("sp_DeleteRateSchedule"))
        {
          deleteRsched.AddParam("a_rsID", MTParameterType.Integer, rschedID);
          deleteRsched.ExecuteNonQuery();
        }
      }

      AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_RS_DELETE, -1, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
String.Format("Successfully Deleted Rate Schedule: {0}", rschedID));
    }
    #endregion
  }
}




