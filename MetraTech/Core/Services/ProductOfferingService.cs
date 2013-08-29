using System;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Text;
using System.Reflection;

using MetraTech.Accounts;
using MetraTech.Accounts.Type;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.Application;
using MetraTech.Application.ProductManagement;
using MetraTech.DataAccess;
using MetraTech.Domain;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.IMTAccountType;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Interop.MTAuth;
using System.Transactions;
using MetraTech.DomainModel.Common;
using System.Collections;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;
using MetraTech.Debug.Diagnostics;
using DatabaseUtils = MetraTech.Domain.DataAccess.DatabaseUtils;

namespace MetraTech.Core.Services
{
  [ServiceContract]
  public interface IProductOfferingService
  {
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetProductOfferings(ref MTList<ProductOffering> productOfferings);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetProductOffering(PCIdentifier productOfferingID, out ProductOffering productOffering);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetProductOfferingWithDescription(PCIdentifier productOfferingID, out ProductOffering productOffering);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SaveProductOffering(ref ProductOffering productOffering);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteProductOffering(PCIdentifier productOfferingID);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void AddPIInstanceToPO(PCIdentifier poID, ref BasePriceableItemInstance piInstance);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void RemovePIInstanceFromPO(PCIdentifier poID, PCIdentifier piInstanceID);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetPIInstancesForPO(PCIdentifier poID, ref MTList<BasePriceableItemInstance> piInstances);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetPIInstanceForPO(PCIdentifier poID,
                            PCIdentifier piInstanceID,
                            out BasePriceableItemInstance piInstance);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void UpdatePIInstance(BasePriceableItemInstance piInstance);
  }

  [ServiceBehavior(InstanceContextMode = InstanceContextMode.Single, ConcurrencyMode = ConcurrencyMode.Multiple)]
  public class ProductOfferingService : BasePCWebService, IProductOfferingService
  {
    #region Private Members

    private static Logger mLogger = new Logger("[ProductOfferingService]");
    private AccountTypeManager mAccountTypeManager = new AccountTypeManager();

    #endregion

    #region IProductOfferingService Members

    public void GetProductOfferings(ref MTList<ProductOffering> productOfferings)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetProductOfferings"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
          {
            string poIds = "";
            Dictionary<int, ProductOffering> poDictionary = new Dictionary<int, ProductOffering>();

            // return high level list of product offerings in the sytste
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("Queries\\PCWS", "__GET_PO_HL_DETAILS__"))
            {
              ApplyFilterSortCriteria<ProductOffering>(stmt, productOfferings);

              using (IMTDataReader dataReader = stmt.ExecuteReader())
              {
                //if there are records, create a ProductOffering object for eacg
                while (dataReader.Read())
                {
                  ProductOffering po = new ProductOffering();
                  po.ProductOfferingId = dataReader.GetInt32("ProductOfferingId");
                  poIds = poIds + po.ProductOfferingId + ",";
                  po.Name = dataReader.GetString("Name");
                  po.Description = dataReader.IsDBNull("Description") ? null : dataReader.GetString("Description");
                  po.DisplayName = dataReader.IsDBNull("DisplayName") ? null : dataReader.GetString("DisplayName");
                  po.CanUserSubscribe = dataReader.GetBoolean("CanUserSubscribe");
                  po.CanUserUnsubscribe = dataReader.GetBoolean("CanUserUnSubscribe");
                  po.IsHidden = dataReader.GetBoolean("IsHidden");
                  po.Currency = (SystemCurrencies)EnumHelper.GetEnumByValue(typeof(SystemCurrencies), dataReader.GetString("Currency"));

                  // set up effective and avail dates
                  ProdCatTimeSpan effectiveDate = EffectiveDateUtils.GetEffectiveDate(dataReader, "Effective");
                  ProdCatTimeSpan availableDate = EffectiveDateUtils.GetEffectiveDate(dataReader, "Available");

                  po.EffectiveTimeSpan.TimeSpanId = effectiveDate.TimeSpanId.Value;
                  po.EffectiveTimeSpan.StartDateOffset = effectiveDate.StartDateOffset;
                  po.EffectiveTimeSpan.StartDateType = effectiveDate.StartDateType;
                  po.EffectiveTimeSpan.EndDateOffset = effectiveDate.EndDateOffset;
                  po.EffectiveTimeSpan.EndDateType = effectiveDate.EndDateType;
                  po.EffectiveTimeSpan.StartDate = effectiveDate.StartDate;
                  po.EffectiveTimeSpan.EndDate = effectiveDate.EndDate;

                  po.AvailableTimeSpan.TimeSpanId = availableDate.TimeSpanId.Value;
                  po.AvailableTimeSpan.StartDateOffset = availableDate.StartDateOffset;
                  po.AvailableTimeSpan.StartDateType = availableDate.StartDateType;
                  po.AvailableTimeSpan.EndDateOffset = availableDate.EndDateOffset;
                  po.AvailableTimeSpan.EndDateType = availableDate.EndDateType;
                  po.AvailableTimeSpan.StartDate = availableDate.StartDate;
                  po.AvailableTimeSpan.EndDate = availableDate.EndDate;

                  Dictionary<LanguageCode, string> localizedNames = new Dictionary<LanguageCode, string>();
                  Dictionary<LanguageCode, string> localizedDesc = new Dictionary<LanguageCode, string>();
                  po.LocalizedDisplayNames = localizedNames;
                  po.LocalizedDescriptions = localizedDesc;

                  poDictionary.Add(po.ProductOfferingId.Value, po);
                  productOfferings.Items.Add(po);
                }

                productOfferings.TotalRows = stmt.TotalRows;
              }
            }

            if (poIds.Length > 0)
            {
              // remove trailing comma
              int length = poIds.Length - 1;
              poIds = poIds.Remove(length, 1);


              using (IMTAdapterStatement local = conn.CreateAdapterStatement("Queries\\PCWS", "__GET_LOCALIZED_PROPS__"))
              {
                local.AddParam("%%PITYPE_IDS%%", poIds);
                using (IMTDataReader localizedReader = local.ExecuteReader())
                {
                  while (localizedReader.Read())
                  {
                    int id = localizedReader.GetInt32("ID");
                    ProductOffering po = poDictionary[id];
                    if (!localizedReader.IsDBNull("LanguageCode"))
                    {
                      LanguageCode langCode = (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), localizedReader.GetInt32("LanguageCode").ToString());
                      po.LocalizedDisplayNames.Add(langCode, (!localizedReader.IsDBNull("DisplayName")) ? localizedReader.GetString("DisplayName") : null);
                      po.LocalizedDescriptions.Add(langCode, (!localizedReader.IsDBNull("Description")) ? localizedReader.GetString("Description") : null);
                    }
                  }
                }
              }
            }
          }


          mLogger.LogDebug("Retrieved {0} product offerings ", productOfferings.Items.Count);
        }
        catch (CommunicationException e)
        {
          mLogger.LogException("Cannot retrieve product offerings form system ", e);
          throw;
        }

        catch (Exception e)
        {
          mLogger.LogException("Error retrieving product offerings from the system ", e);
          throw new MASBasicException("Error retrieving product offerings");
        }
      }
    }

    public void GetProductOffering(PCIdentifier productOfferingID, out ProductOffering productOffering)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetProductOffering"))
      {
        int poId = -1;

        if (productOfferingID == null)
        {
          mLogger.LogWarning("Must specify identifier of product offering to be loaded");
          throw new MASBasicException("Must specify identifier of product offering to be loaded");
        }

        poId = PCIdentifierResolver.ResolveProductOffering(productOfferingID);

        if (poId == -1)
        {
          mLogger.LogWarning("Invalid Product Offering id.");
          throw new MASBasicException("Invalid Product Offering id.");
        }

        try
        {
          productOffering = new ProductOffering();

          using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
          {
            using (IMTMultiSelectAdapterStatement poStatement = conn.CreateMultiSelectStatement("Queries\\PCWS", "__GET_PO_DETAILS__"))
            {
              poStatement.AddParam("%%PO_ID%%", poId);
              poStatement.SetResultSetCount(2);

              using (IMTDataReader poReader = poStatement.ExecuteReader())
              {
                if (poReader.Read())
                {
                  do
                  {
                    productOffering.ProductOfferingId = poReader.GetInt32("ProductOfferingId");
                    productOffering.Name = poReader.GetString("Name");
                    productOffering.DisplayName = poReader.GetString("DisplayName");
                    productOffering.CanUserSubscribe = poReader.GetBoolean("CanUserSubscribe");
                    productOffering.CanUserUnsubscribe = poReader.GetBoolean("CanUserUnSubscribe");
                    productOffering.IsHidden = poReader.GetBoolean("IsHidden");
                    productOffering.Currency = (SystemCurrencies)EnumHelper.GetEnumByValue(typeof(SystemCurrencies), poReader.GetString("Currency"));

                    ProdCatTimeSpan effectiveDate = EffectiveDateUtils.GetEffectiveDate(poReader, "Effective");
                    ProdCatTimeSpan availableDate = EffectiveDateUtils.GetEffectiveDate(poReader, "Available");

                    productOffering.EffectiveTimeSpan.TimeSpanId = effectiveDate.TimeSpanId.Value;
                    productOffering.EffectiveTimeSpan.StartDateOffset = effectiveDate.StartDateOffset;
                    productOffering.EffectiveTimeSpan.StartDateType = effectiveDate.StartDateType;
                    productOffering.EffectiveTimeSpan.EndDateOffset = effectiveDate.EndDateOffset;
                    productOffering.EffectiveTimeSpan.EndDateType = effectiveDate.EndDateType;
                    productOffering.EffectiveTimeSpan.StartDate = effectiveDate.StartDate;
                    productOffering.EffectiveTimeSpan.EndDate = effectiveDate.EndDate;

                    productOffering.AvailableTimeSpan.TimeSpanId = availableDate.TimeSpanId.Value;
                    productOffering.AvailableTimeSpan.StartDateOffset = availableDate.StartDateOffset;
                    productOffering.AvailableTimeSpan.StartDateType = availableDate.StartDateType;
                    productOffering.AvailableTimeSpan.EndDateOffset = availableDate.EndDateOffset;
                    productOffering.AvailableTimeSpan.EndDateType = availableDate.EndDateType;
                    productOffering.AvailableTimeSpan.StartDate = availableDate.StartDate;
                    productOffering.AvailableTimeSpan.EndDate = availableDate.EndDate;

                  } while (poReader.Read());

                  // move on to AccountType props
                  poReader.NextResult();
                  List<string> supportedAccTypes = new List<string>();
                  while (poReader.Read())
                  {
                    supportedAccTypes.Add(poReader.GetString("AccountTypeName"));
                  }

                  productOffering.SupportedAccountTypes = supportedAccTypes;
                }
              }

              if (productOffering.ProductOfferingId.HasValue)
              {
                Dictionary<LanguageCode, string> localizedNames = new Dictionary<LanguageCode, string>();
                Dictionary<LanguageCode, string> localizedDesc = new Dictionary<LanguageCode, string>();
                productOffering.LocalizedDisplayNames = localizedNames;
                productOffering.LocalizedDescriptions = localizedDesc;
                //ESR-4290: Method GetProductOffering() can't get MasterProductOffering for PO (Extended Prorerties)
                PopulateExtendedProperties(productOffering, productOffering.ProductOfferingId.Value);
                MTList<BasePriceableItemInstance> piInstanceList = new MTList<BasePriceableItemInstance>();
                GetPIInstancesForPO(productOfferingID, ref piInstanceList);
                List<BasePriceableItemInstance> piInstances = new List<BasePriceableItemInstance>();

                for (int item = 0; item < piInstanceList.Items.Count; item++)
                {
                  BasePriceableItemInstance instance = piInstanceList.Items[item];
                  piInstances.Add(instance);
                }
                productOffering.PriceableItems = piInstances;

                using (IMTAdapterStatement local = conn.CreateAdapterStatement("Queries\\PCWS", "__GET_LOCALIZED_PROPS__"))
                {
                  local.AddParam("%%PITYPE_IDS%%", productOffering.ProductOfferingId.Value);
                  using (IMTDataReader localizedReader = local.ExecuteReader())
                  {
                    while (localizedReader.Read())
                    {
                      int id = localizedReader.GetInt32("ID");
                      if (!localizedReader.IsDBNull("LanguageCode"))
                      {
                        LanguageCode langCode = (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), localizedReader.GetInt32("LanguageCode").ToString());
                        productOffering.LocalizedDisplayNames.Add(langCode, (!localizedReader.IsDBNull("DisplayName")) ? localizedReader.GetString("DisplayName") : null);
                        productOffering.LocalizedDescriptions.Add(langCode, (!localizedReader.IsDBNull("Description")) ? localizedReader.GetString("Description") : null);
                      }
                    }
                  }
                }
              }
            }
          }
          mLogger.LogDebug("Returned " + productOffering.Name);
        }
        catch (CommunicationException e)
        {
          mLogger.LogException("Cannot retrieve product offering from system ", e);
          throw;
        }

        catch (Exception e)
        {
          mLogger.LogException("Error retrieving product offering from the system ", e);
          throw new MASBasicException("Error retrieving product offering");
        }
      }
    }


    public void GetProductOfferingWithDescription(PCIdentifier productOfferingID, out ProductOffering productOffering)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetProductOfferingWithDescription"))
      {
        int poId = -1;

        if (productOfferingID == null)
        {
          mLogger.LogWarning("Must specify identifier of product offering to be loaded");
          throw new MASBasicException("Must specify identifier of product offering to be loaded");
        }

        poId = PCIdentifierResolver.ResolveProductOffering(productOfferingID);

        if (poId == -1)
        {
          mLogger.LogWarning("Invalid Product Offering id.");
          throw new MASBasicException("Invalid Product Offering id.");
        }

        try
        {
          productOffering = new ProductOffering();

          using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
          {
            using (IMTMultiSelectAdapterStatement poStatement = conn.CreateMultiSelectStatement("Queries\\PCWS", "__GET_PO_DETAILS__"))
            {
              poStatement.AddParam("%%PO_ID%%", poId);
              poStatement.SetResultSetCount(2);

              using (IMTDataReader poReader = poStatement.ExecuteReader())
              {
                if (poReader.Read())
                {
                  do
                  {
                    productOffering.ProductOfferingId = poReader.GetInt32("ProductOfferingId");
                    productOffering.Name = poReader.GetString("Name");
                    productOffering.DisplayName = poReader.GetString("DisplayName");
                    productOffering.Description = poReader.GetString("Description");
                    productOffering.CanUserSubscribe = poReader.GetBoolean("CanUserSubscribe");
                    productOffering.CanUserUnsubscribe = poReader.GetBoolean("CanUserUnSubscribe");
                    productOffering.IsHidden = poReader.GetBoolean("IsHidden");
                    productOffering.Currency = (SystemCurrencies)EnumHelper.GetEnumByValue(typeof(SystemCurrencies), poReader.GetString("Currency"));

                    ProdCatTimeSpan effectiveDate = EffectiveDateUtils.GetEffectiveDate(poReader, "Effective");
                    ProdCatTimeSpan availableDate = EffectiveDateUtils.GetEffectiveDate(poReader, "Available");

                    productOffering.EffectiveTimeSpan.TimeSpanId = effectiveDate.TimeSpanId.Value;
                    productOffering.EffectiveTimeSpan.StartDateOffset = effectiveDate.StartDateOffset;
                    productOffering.EffectiveTimeSpan.StartDateType = effectiveDate.StartDateType;
                    productOffering.EffectiveTimeSpan.EndDateOffset = effectiveDate.EndDateOffset;
                    productOffering.EffectiveTimeSpan.EndDateType = effectiveDate.EndDateType;
                    productOffering.EffectiveTimeSpan.StartDate = effectiveDate.StartDate;
                    productOffering.EffectiveTimeSpan.EndDate = effectiveDate.EndDate;

                    productOffering.AvailableTimeSpan.TimeSpanId = availableDate.TimeSpanId.Value;
                    productOffering.AvailableTimeSpan.StartDateOffset = availableDate.StartDateOffset;
                    productOffering.AvailableTimeSpan.StartDateType = availableDate.StartDateType;
                    productOffering.AvailableTimeSpan.EndDateOffset = availableDate.EndDateOffset;
                    productOffering.AvailableTimeSpan.EndDateType = availableDate.EndDateType;
                    productOffering.AvailableTimeSpan.StartDate = availableDate.StartDate;
                    productOffering.AvailableTimeSpan.EndDate = availableDate.EndDate;

                  } while (poReader.Read());

                  // move on to AccountType props
                  poReader.NextResult();
                  List<string> supportedAccTypes = new List<string>();
                  while (poReader.Read())
                  {
                    supportedAccTypes.Add(poReader.GetString("AccountTypeName"));
                  }

                  productOffering.SupportedAccountTypes = supportedAccTypes;
                }
              }

              if (productOffering.ProductOfferingId.HasValue)
              {
                Dictionary<LanguageCode, string> localizedNames = new Dictionary<LanguageCode, string>();
                Dictionary<LanguageCode, string> localizedDesc = new Dictionary<LanguageCode, string>();
                productOffering.LocalizedDisplayNames = localizedNames;
                productOffering.LocalizedDescriptions = localizedDesc;
                //ESR-4290: Method GetProductOffering() can't get MasterProductOffering for PO (Extended Prorerties)
                PopulateExtendedProperties(productOffering, productOffering.ProductOfferingId.Value);
                MTList<BasePriceableItemInstance> piInstanceList = new MTList<BasePriceableItemInstance>();
                GetPIInstancesForPO(productOfferingID, ref piInstanceList);
                List<BasePriceableItemInstance> piInstances = new List<BasePriceableItemInstance>();

                for (int item = 0; item < piInstanceList.Items.Count; item++)
                {
                  BasePriceableItemInstance instance = piInstanceList.Items[item];
                  piInstances.Add(instance);
                }
                productOffering.PriceableItems = piInstances;

                using (IMTAdapterStatement local = conn.CreateAdapterStatement("Queries\\PCWS", "__GET_LOCALIZED_PROPS__"))
                {
                  local.AddParam("%%PITYPE_IDS%%", productOffering.ProductOfferingId.Value);
                  using (IMTDataReader localizedReader = local.ExecuteReader())
                  {
                    while (localizedReader.Read())
                    {
                      int id = localizedReader.GetInt32("ID");
                      if (!localizedReader.IsDBNull("LanguageCode"))
                      {
                        LanguageCode langCode = (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), localizedReader.GetInt32("LanguageCode").ToString());
                        productOffering.LocalizedDisplayNames.Add(langCode, (!localizedReader.IsDBNull("DisplayName")) ? localizedReader.GetString("DisplayName") : null);
                        productOffering.LocalizedDescriptions.Add(langCode, (!localizedReader.IsDBNull("Description")) ? localizedReader.GetString("Description") : null);
                      }
                    }
                  }
                }
              }
            }
          }
          mLogger.LogDebug("Returned " + productOffering.Name + " with default description... " + productOffering.Description);
        }
        catch (CommunicationException e)
        {
          mLogger.LogException("Cannot retrieve product offering from system ", e);
          throw;
        }

        catch (Exception e)
        {
          mLogger.LogException("Error retrieving product offering from the system ", e);
          throw new MASBasicException("Error retrieving product offering");
        }
      }
    }

    public void SaveProductOffering(ref ProductOffering productOffering)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("SaveProductOffering"))
      {
        try
        {
          string poName = productOffering.Name;
          PCIdentifier poIdentifier = null;

          if (productOffering.ProductOfferingId.HasValue && productOffering.IsNameDirty)
          {
            poIdentifier = new PCIdentifier(productOffering.ProductOfferingId.Value, poName);
          }
          else if (productOffering.ProductOfferingId.HasValue)
          {
            poIdentifier = new PCIdentifier(productOffering.ProductOfferingId.Value);
          }
          else
          {
            poIdentifier = new PCIdentifier(poName);
          }

          int poId = PCIdentifierResolver.ResolveProductOffering(poIdentifier, true);

          if (productOffering.ProductOfferingId.HasValue && productOffering.ProductOfferingId.Value != poId)
          {
            throw new MASBasicException("Invalid product offering ID");
          }

          productOffering.ProductOfferingId = poId;

          IMTSessionContext context = GetSessionContext();
          if (poId != -1)
          {
            mLogger.LogDebug("Updating existing product offering.");

            //TransactionOptions txOptions = new TransactionOptions();
            //txOptions.IsolationLevel = System.Transactions.IsolationLevel.ReadCommitted;

            using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
            {
              mLogger.LogDebug("TXN ISOLATION LEVEL IN saveproductoffering" + Transaction.Current.IsolationLevel.ToString());

              using (IMTConnection conn = ConnectionManager.CreateConnection(PCWS_QUERY_FOLDER))
              {

                # region check configuration and availability date
                // TODO: It seems like configuration is mostly meta data check, but we should check the availability date
                #endregion

                bool availabilityDateSaved = false;
                //Clear off availability dates if start date has no value to allow "PO CAN BE MODIFIED" rule to work.
                if (!productOffering.AvailableTimeSpan.StartDate.HasValue)
                {
                  availabilityDateSaved = true;
                  UpdateAvailableDateForPO(poId, productOffering.AvailableTimeSpan);
                }


                foreach (BasePriceableItemInstance instance in productOffering.PriceableItems)
                {
                  BasePriceableItemInstance aPI = instance;
                  PCIdentifier instanceIdentifier = new PCIdentifier(aPI.Name);

                  int poInstanceId = PCIdentifierResolver.ResolvePriceableItemInstance(productOffering.ProductOfferingId.Value, instanceIdentifier);
                  if (poInstanceId == -1)
                    AddPIInstanceToPO(poIdentifier, ref aPI);
                  else
                    UpdatePIInstance(aPI);

                }

                #region Update Base Props, UpdatePO, UpdateExtendedProperties
                if (productOffering.IsDescriptionDirty || productOffering.IsDisplayNameDirty)
                {
                  BasePropsUtils.UpdateBaseProps(context,
                                  productOffering.Description,
                                  productOffering.IsDescriptionDirty,
                                  productOffering.DisplayName,
                                  productOffering.IsDisplayNameDirty,
                                  productOffering.ProductOfferingId.Value);
                }


                using (IMTAdapterStatement updatePoStmt = conn.CreateAdapterStatement("queries\\PCWS", "__UPDATE_PO__"))
                {
                  if (productOffering.CanUserSubscribe.Value)
                    updatePoStmt.AddParam("%%CAN_SUBSCRIBE%%", "Y");
                  else
                    updatePoStmt.AddParam("%%CAN_SUBSCRIBE%%", "N");

                  if (productOffering.CanUserUnsubscribe.Value)
                    updatePoStmt.AddParam("%%CAN_UNSUBSCRIBE%%", "Y");
                  else
                    updatePoStmt.AddParam("%%CAN_UNSUBSCRIBE%%", "N");

                  //ESR-4293 : SaveProductOffering method does not update bHidden field 
                  if (productOffering.IsHidden)
                    updatePoStmt.AddParam("%%IS_HIDDEN%%", "Y");
                  else
                    updatePoStmt.AddParam("%%IS_HIDDEN%%", "N");

                  updatePoStmt.AddParam("%%ID_PO%%", productOffering.ProductOfferingId.Value);
                  updatePoStmt.ExecuteNonQuery();
                }

                UpsertExtendedProps(productOffering.ProductOfferingId.Value, productOffering);
                #endregion

                UpdateEffectiveDateForPO(poId, productOffering.EffectiveTimeSpan);

                #region Check subs against po effective date
                int stDtViolations = -1;
                int endDtViolations = -1;

                using (IMTAdapterStatement checkSubPoStmt = conn.CreateAdapterStatement("queries\\PCWS", "__CHECK_SUBSCRIPTIONS_AGAINST_PO_EFFECTIVE_DATE_PCWS__"))
                {
                  checkSubPoStmt.AddParam("%%ID_PO%%", productOffering.ProductOfferingId.Value);

                  using (IMTDataReader checkPoSubReader = checkSubPoStmt.ExecuteReader())
                  {
                    while (checkPoSubReader.Read())
                    {
                      stDtViolations = checkPoSubReader.GetInt32("n_start_date_violations");
                      endDtViolations = checkPoSubReader.GetInt32("n_end_date_violations");
                    }
                  }
                }

                if (stDtViolations > 0)
                  throw new MASBasicException(ErrorCodes.MTPCUSER_SUBS_EXIST_BEFORE_PO_EFF_START_DATE);
                else if (endDtViolations > 0)
                  throw new MASBasicException(ErrorCodes.MTPCUSER_SUBS_EXIST_AFTER_PO_EFF_END_DATE);

                #endregion

                # region prop end dt change to subscribed users
                using (IMTAdapterStatement propagateSubToPoStmt = conn.CreateAdapterStatement("queries\\PCWS", "__UPDATE_SUB_EFFECTIVEDATE_LIST_THROUGH_PO_PCWS__"))
                {
                  propagateSubToPoStmt.AddParam("%%END_DATE%%", productOffering.EffectiveTimeSpan.EndDate); //do not validate string (needed quotes are already included)
                  propagateSubToPoStmt.AddParam("%%ID_PO%%", productOffering.ProductOfferingId.Value);
                  propagateSubToPoStmt.ExecuteNonQuery();
                }
                #endregion

                //call only if not saved in the beginning. see above.
                if (!availabilityDateSaved)
                {
                  UpdateAvailableDateForPO(poId, productOffering.AvailableTimeSpan);
                }

                ProcessLocalizationData(productOffering.ProductOfferingId.Value,
                                        productOffering.LocalizedDisplayNames,
                                        productOffering.IsLocalizedDisplayNamesDirty,
                                        productOffering.LocalizedDescriptions,
                                        productOffering.IsLocalizedDescriptionsDirty);

                #region AccountTypeMapping Restrictions

                if (productOffering.SupportedAccountTypes.Count > 0)
                {
                  // There might be a bug here, what if user wants to remove all accout type mappings and sends an empty list
                  mLogger.LogDebug("Updating account type mapping restrictions for PO");
                  using (IMTAdapterStatement removeAccResStmt = conn.CreateAdapterStatement("queries\\PCWS", "__REMOVE_SUBSCRIBABLE_ACCOUNT_TYPES_PCWS__"))
                  {
                    removeAccResStmt.AddParam("%%ID_PO%%", productOffering.ProductOfferingId.Value);
                    removeAccResStmt.ExecuteNonQuery();
                  }

                  AddPoAccTypeMappings(productOffering, context);

                }
                else
                {
                  mLogger.LogDebug("No Account Type mappings to update.");
                }
                #endregion
              }

              AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_PO_UPDATE, -1, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
              String.Format("Successfully updated product offering: {0}", productOffering.ProductOfferingId.Value));
              mLogger.LogDebug(String.Format("Successfully updated product offering: {0}", productOffering.ProductOfferingId.Value));
              scope.Complete();
            }
          }
          else
          {
            mLogger.LogDebug("Creating a new product offering.");

            bool bAvailableDateSent = false;

            //TransactionOptions txOptions = new TransactionOptions();
            //txOptions.IsolationLevel = System.Transactions.IsolationLevel.ReadCommitted;
            using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
            {
              mLogger.LogDebug("TXN ISOLATION LEVEL IN saveproductoffering" + Transaction.Current.IsolationLevel.ToString());
              using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
              {
                // Verify that Name does not exist for another PO
                if (PCConfigManager.IsBusinessRuleEnabled(PCConfigManager.MTPC_BUSINESS_RULE_ProdOff_NoDuplicateName))
                  CheckPoName(poName);

                # region create avialabile and effective dates
                // Create availbility date id for the available date
                if (productOffering.EffectiveTimeSpan == null)
                  productOffering.EffectiveTimeSpan = new ProdCatTimeSpan();

                productOffering.EffectiveTimeSpan.TimeSpanId = EffectiveDateUtils.CreateEffectiveDate(context, productOffering.EffectiveTimeSpan);

                // Create availbility date id for the available date
                if (productOffering.AvailableTimeSpan == null)
                {
                  productOffering.AvailableTimeSpan = new ProdCatTimeSpan();
                }
                else
                {
                  bAvailableDateSent = true;
                }

                //Create availability date using Empty to allow "check for po modification" rule to allow adding PI Instances during new PO addition.
                productOffering.AvailableTimeSpan.TimeSpanId = EffectiveDateUtils.CreateEffectiveDate(context, new ProdCatTimeSpan());

                #endregion

                #region Create Non Shared Pl
                // create non-shared pricelist
                PriceList nonSharedPl = new PriceList();

                nonSharedPl.Currency = productOffering.Currency;
                nonSharedPl.Name = String.Format("Nonshared PL for:{0}", productOffering.Name);
                nonSharedPl.Description = String.Format("Nonshared PL for:{0}", productOffering.Description);
                int nsPlId = BasePropsUtils.CreateBaseProps(context, nonSharedPl.Name, nonSharedPl.Description, "", PRICELIST_KIND);
                nonSharedPl.ID = nsPlId;

                using (IMTAdapterStatement createPlStmt = conn.CreateAdapterStatement("queries\\PCWS", "__ADD_PRICELIST_PCWS__"))
                {
                  createPlStmt.AddParam("%%ID_PL%%", nsPlId);
                  createPlStmt.AddParam("%%TYPE%%", NON_SHARED_PL_TYPE);
                  createPlStmt.AddParam("%%CURRENCY_CODE%%", EnumHelper.GetValueByEnum(nonSharedPl.Currency));
                  createPlStmt.ExecuteNonQuery();
                }
                #endregion

                #region Add po to system
                // Add Product Offering to system
                int idPo = BasePropsUtils.CreateBaseProps(context, productOffering.Name, productOffering.Description, productOffering.DisplayName, PRODUCT_OFFERING_KIND);
                using (IMTAdapterStatement createPoStmt = conn.CreateAdapterStatement("queries\\PCWS", "__ADD_PO_PCWS__"))
                {

                  createPoStmt.AddParam("%%ID_PO%%", idPo);
                  createPoStmt.AddParam("%%ID_EFF_DATE%%", productOffering.EffectiveTimeSpan.TimeSpanId);
                  createPoStmt.AddParam("%%ID_AVAIL%%", productOffering.AvailableTimeSpan.TimeSpanId);
                  if (productOffering.CanUserSubscribe.Value)
                    createPoStmt.AddParam("%%CAN_SUBSCRIBE%%", "Y");
                  else
                    createPoStmt.AddParam("%%CAN_SUBSCRIBE%%", "N");

                  if (productOffering.CanUserUnsubscribe.Value)
                    createPoStmt.AddParam("%%CAN_UNSUBSCRIBE%%", "Y");
                  else
                    createPoStmt.AddParam("%%CAN_UNSUBSCRIBE%%", "N");

                  createPoStmt.AddParam("%%ID_NONSHARED_PL%%", nsPlId);

                  if (productOffering.IsHidden)
                    createPoStmt.AddParam("%%IS_HIDDEN%%", "Y");
                  else
                    createPoStmt.AddParam("%%IS_HIDDEN%%", "N");

                  createPoStmt.ExecuteNonQuery();
                }

                productOffering.ProductOfferingId = idPo;
                #endregion

                ProcessLocalizationData(productOffering.ProductOfferingId.Value,
                                        productOffering.LocalizedDisplayNames,
                                        productOffering.IsLocalizedDisplayNamesDirty,
                                        productOffering.LocalizedDescriptions,
                                        productOffering.IsLocalizedDescriptionsDirty);

                if (productOffering.SupportedAccountTypes.Count > 0)
                  AddPoAccTypeMappings(productOffering, context);
                else
                  mLogger.LogDebug("No Account Type Mapping Restrictions to propagate.");

                foreach (BasePriceableItemInstance instance in productOffering.PriceableItems)
                {
                  BasePriceableItemInstance poInstance = instance;
                  AddPIInstanceToPO(poIdentifier, ref poInstance);
                }

                UpsertExtendedProps(productOffering.ProductOfferingId.Value, productOffering);

                //Update Availability date sent by user.
                if (bAvailableDateSent)
                  UpdateAvailableDateForPO(idPo, productOffering.AvailableTimeSpan);

              }

              AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_PO_CREATE, -1, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
              String.Format("Successfully updated product offering: {0}", productOffering.ProductOfferingId.Value));
              mLogger.LogDebug("Successfully created product offering.");
              scope.Complete();

            }
          }
        }
        catch (MASBasicException masE)
        {
          mLogger.LogException("Handled exception caught in SaveProductOffering", masE);
          throw masE;
        }
        catch (Exception e)
        {
          mLogger.LogException("Unhandled error caught in SaveProductOffering", e);

          throw new MASBasicException("Unexpected error saving Product Offering");
        }
      }
    }

    public void DeleteProductOffering(PCIdentifier productOfferingID)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DeleteProductOffering"))
      {
        // Resolve PCIdentifier to internal integer
        int poID = PCIdentifierResolver.ResolveProductOffering(productOfferingID, true);

        if (poID == -1)
        {
          throw new MASBasicException("Unable to locate specified product offering");
        }

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          #region Check if any subscriptions to PO exist
          using (IMTAdapterStatement adapterStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_ALL_SUB_COUNT_BY_PO_PCWS__"))
          {
            adapterStmt.AddParam("%%ID_PO%%", poID);

            using (IMTDataReader rdr = adapterStmt.ExecuteReader())
            {
              if (rdr.Read())
              {
                int subCount = rdr.GetInt32(0);

                if (subCount > 0)
                {
                  throw new MASBasicException("Cannot delete product offering because subscriptions exist");
                }
              }
            }
          }
          #endregion

          List<int> piInstanceIds = new List<int>();

          #region Load PI Instance IDs for PO
          using (IMTAdapterStatement adapterStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__LOAD_PIINSTANCE_IDS_FOR_PO__"))
          {
            adapterStmt.AddParam("%%PO_ID%%", poID);

            // need to add updlock in SQLServer case to prevent deadlocks
            if (conn.ConnectionInfo.IsOracle)
            {
              adapterStmt.AddParam("%%UPDLOCK%%", "");
            }
            else
            {
              adapterStmt.AddParam("%%UPDLOCK%%", "with(updlock)");
            }

            using (IMTDataReader rdr = adapterStmt.ExecuteReader())
            {
              while (rdr.Read())
              {
                int piInstanceId = rdr.GetInt32("id_pi_instance");
                piInstanceIds.Add(piInstanceId);
              }
            }
          }
          #endregion

          #region Delete Pricable Item Instances
          foreach (int poInstanceId in piInstanceIds)
          {
            RemovePIInstanceFromPO(productOfferingID, new PCIdentifier(poInstanceId));
          }
          #endregion

          #region Execute DeleteProductOffering Stored Procedure
          using (IMTCallableStatement callableStmt = conn.CreateCallableStatement("DeleteProductOffering"))
          {
            callableStmt.AddParam("poID", MTParameterType.Integer, poID);

            callableStmt.ExecuteNonQuery();
          }
          #endregion
        }

        #region Add Audit Entry

        #endregion
      }
    }

    public void AddPIInstanceToPO(PCIdentifier poID, ref BasePriceableItemInstance piInstance)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("AddPIInstanceToPO"))
      {
        if (piInstance == null)
        {
          throw new MASBasicException("Must provide priceable item instance to be added");
        }

        int id_po = PCIdentifierResolver.ResolveProductOffering(poID);

        try
        {
          if (id_po == -1)
          {
            throw new MASBasicException("Unable to locate specified Product Offering");
          }

          mLogger.LogInfo("Adding PI Instance '{0}' to PO {1}", piInstance.Name, id_po);

          #region Validate Addition
          CanProductOfferingBeModified(id_po);

          mLogger.LogDebug("Checking if attempt to add a child priceable item instance");
          PropertyInfo parentPIProperty = piInstance.GetProperty("ParentPIInstance");
          if (parentPIProperty != null)
          {
            throw new MASBasicException("Cannot add a child priceable item instance");
          }
          #endregion

          #region Rollback Non-overrideable properties
          //Rollback non overridable properties of piinstance
          BasePriceableItemTemplate piTemplate = null;

          if (piInstance == null)
          {
            mLogger.LogError("Priceable Instance cannot be null. error while adding PI INstance to PO");
            throw new MASBasicException("Priceable Instance cannot be null. error while adding PI INstance to PO.");
          }

          RollbackNonOverrideableProps(ref piInstance, ref piTemplate);

          //Rollback non overridable properties on child piinstances.
          List<PropertyInfo> childPIProperties = piInstance.GetMTProperties();
          foreach (PropertyInfo childPIProperty in childPIProperties)
          {
            if (childPIProperty.PropertyType.IsSubclassOf(typeof(BasePriceableItemInstance)))
            {
              if (childPIProperty.GetValue(piInstance, null) == null)
              {
                mLogger.LogError("Child Priceable Instance cannot be null. error while adding PI INstance to PO");
                throw new MASBasicException("Child Priceable Instance cannot be null. error while adding PI INstance to PO.");
              }

              BasePriceableItemInstance childPIInstance = (BasePriceableItemInstance)childPIProperty.GetValue(piInstance, null);
              BasePriceableItemTemplate childPITemplate = (BasePriceableItemTemplate)piTemplate.GetValue(childPIProperty.Name.Replace("PIInstance", "PITemplate"));
              RollbackNonOverrideableProps(ref childPIInstance, ref childPITemplate);
            }
          }
          #endregion

          //TransactionOptions txOptions = new TransactionOptions();
          //txOptions.IsolationLevel = System.Transactions.IsolationLevel.ReadCommitted;
          using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
          {
            mLogger.LogDebug("TXN ISOLATION LEVEL IN addpiinstancetopo" + Transaction.Current.IsolationLevel.ToString());

            #region Add parent priceable item instance
            try
            {
              mLogger.LogDebug("Add root priceable item instance '{0}'", piInstance.Name);
              InternalAddPIInstance(id_po, null, ref piInstance);

              mLogger.LogDebug("Add audit event");
              AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_PO_ADDPI,
                                          GetSessionContext().AccountID,
                                          (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT,
                                          id_po,
                                          piInstance.Name);
            }
            catch (MASBasicException masE)
            {
              throw masE;
            }
            catch (Exception e)
            {
              mLogger.LogException("Unhandled error creating parent PI instance", e);

              throw new MASBasicException("Error creating parent priceable item instance");
            }
            #endregion

            #region Add child priceable item instances
            mLogger.LogDebug("Add child priceable item instances");
            //List<PropertyInfo> childPIProperties = piInstance.GetProperties();
            foreach (PropertyInfo childPIProperty in childPIProperties)
            {
              if (childPIProperty.PropertyType.IsSubclassOf(typeof(BasePriceableItemInstance)))
              {
                try
                {
                  BasePriceableItemInstance childPIInstance = (BasePriceableItemInstance)childPIProperty.GetValue(piInstance, null);
                  if (childPIInstance == null)
                  {
                    mLogger.LogError("Child Priceable Instance cannot be null. error while adding PI INstance to PO");
                    throw new MASBasicException("Child Priceable Instance cannot be null. error while adding PI INstance to PO.");
                  }

                  mLogger.LogDebug("Add child priceable item instance '{0}'", childPIInstance.Name);
                  InternalAddPIInstance(id_po, piInstance.ID, ref childPIInstance);

                  mLogger.LogDebug("Add audit event");
                  AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_PO_ADDPI,
                                              GetSessionContext().AccountID,
                                              (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT,
                                              id_po,
                                              childPIInstance.Name);
                }
                catch (MASBasicException masE)
                {
                  throw masE;
                }
                catch (Exception e)
                {
                  mLogger.LogException("Unhandled error creating child PI instance", e);

                  throw new MASBasicException("Error creating child priceable item instance");
                }
              }
            }
            #endregion

            scope.Complete();
          }

          mLogger.LogInfo("Finished adding priceable item instance to product offering {0}", id_po);
        }
        catch (MASBasicException masE)
        {
          mLogger.LogException("MASBasicException caught adding priceable item instance", masE);

          throw masE;
        }
        catch (Exception e)
        {
          mLogger.LogException("Unhandled exception adding priceable item instance", e);
          throw new MASBasicException("Unexpected error adding priceable item instance.  Ask system administrator to review server logs.");
        }
      }
    }

    public void RemovePIInstanceFromPO(PCIdentifier poID, PCIdentifier piInstanceID)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("RemovePIInstanceFromPO"))
      {
        try
        {
          //TransactionOptions txOptions = new TransactionOptions();
          //txOptions.IsolationLevel = System.Transactions.IsolationLevel.ReadCommitted;
          using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
          {
            mLogger.LogDebug("TXN ISOLATION LEVEL IN removepiinstancetopo" + Transaction.Current.IsolationLevel.ToString());
            int id_po = PCIdentifierResolver.ResolveProductOffering(poID);

            if (id_po == -1)
            {
              throw new MASBasicException("Unable to locate specified product offering");
            }

            int id_pi = PCIdentifierResolver.ResolvePriceableItemInstance(id_po, piInstanceID, true);

            if (id_pi == -1)
            {
              throw new MASBasicException("Unable to locate specified priceable item instance");
            }

            CanProductOfferingBeModified(id_po);

            InternalRemovePIInstanceFromPO(id_po, id_pi);

            scope.Complete();
          }

        }
        catch (MASBasicException masE)
        {
          mLogger.LogException("MASBasicException caught removing priceable item instance", masE);

          throw masE;
        }
        catch (Exception e)
        {
          mLogger.LogException("Unhandled exception removing priceable item instance", e);
          throw new MASBasicException("Unexpected error removing priceable item instance.  Ask system administrator to review server logs.");
        }
      }
    }

    public void GetPIInstancesForPO(PCIdentifier poID, ref MTList<BasePriceableItemInstance> piInstances)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetPIInstancesForPO"))
      {
        IMTSessionContext sessionContext = GetSessionContext();
        try
        {
          int poId = -1;
          if (poID.ID.HasValue)
            poId = poID.ID.Value;
          else
            poId = PCIdentifierResolver.ResolveProductOffering(poID);

          if (poId == -1)
            throw new MASBasicException("Invalid Product Offering id.");

          string piInstanceIds = "";

          using (IMTConnection conn = ConnectionManager.CreateConnection(PCWS_QUERY_FOLDER))
          {
            Dictionary<int, BasePriceableItemInstance> piDictionary = new Dictionary<int, BasePriceableItemInstance>();

            // return high level list of priceable item instances in the sytstem
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(PCWS_QUERY_FOLDER, "__GET_PI_INSTANCES_FOR_PO__"))
            {
              stmt.AddParam("%%PO_ID%%", poId);
              stmt.AddParam("%%PARENT_SELECTION_CONDITION%%", "and map.id_pi_instance_parent is NULL");

              ApplyFilterSortCriteria<BasePriceableItemInstance>(stmt, piInstances);

              RetrievePIInstances(stmt, ref piDictionary, ref piInstanceIds, ref piInstances);
            }

            if (piInstances.Items.Count > 0)
            {

              string piParentIds = piInstanceIds.Substring(0, piInstanceIds.Length - 1);

              RetrievePIChildInstances(poId, ref piParentIds, ref piDictionary, ref piInstanceIds);

            }

            if (piInstanceIds.Length > 0)
            {
              // remove trailing comma
              int length = piInstanceIds.Length - 1;
              piInstanceIds = piInstanceIds.Remove(length, 1);

              using (IMTAdapterStatement local = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_LOCALIZED_PROPS__"))
              {
                local.AddParam("%%PITYPE_IDS%%", piInstanceIds);
                using (IMTDataReader localizedReader = local.ExecuteReader())
                {
                  while (localizedReader.Read())
                  {
                    int id = localizedReader.GetInt32("ID");
                    BasePriceableItemInstance pi = piDictionary[id];
                    if (!localizedReader.IsDBNull("LanguageCode"))
                    {
                      LanguageCode langCode = (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), localizedReader.GetInt32("LanguageCode").ToString());
                      int idxDisplayName = localizedReader.GetOrdinal("DisplayName");
                      if (!localizedReader.IsDBNull(idxDisplayName))
                      {
                        pi.LocalizedDisplayNames.Add(langCode, localizedReader.GetString("DisplayName"));
                      }
                      int idxDescription = localizedReader.GetOrdinal("Description");
                      if (!localizedReader.IsDBNull(idxDescription))
                      {
                        pi.LocalizedDescriptions.Add(langCode, localizedReader.GetString("Description"));
                      }
                    }
                  }
                }
              }
            }
          }

          mLogger.LogDebug("Retrieved {0} priceable item instances ", piInstances.Items.Count);
        }
        catch (CommunicationException e)
        {
          mLogger.LogException("Cannot retrieve priceable item instances from system ", e);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Error retrieving priceable item instances from the system ", e);
          throw new MASBasicException("Error retrieving priceable item instances");
        }
      }
    }

    private class ChildPropertyData
    {
      public ChildPropertyData(BasePriceableItemInstance parent, PropertyInfo propertyInfo)
      {
        this.parent = parent;
        this.propertyInfo = propertyInfo;

      }

      public BasePriceableItemInstance parent;
      public PropertyInfo propertyInfo;
    }

    private void RetrievePIChildInstances(int poId,
                                          ref string piParentIDs,
                                          ref Dictionary<int, BasePriceableItemInstance> piDictionary,
                                          ref string piGlobalInstanceIds)
    {
      string piChildrenIds = "";
      Dictionary<int, BasePriceableItemInstance> piChildrenDictionary = new Dictionary<int, BasePriceableItemInstance>();
      MTList<BasePriceableItemInstance> piChildrenList = new MTList<BasePriceableItemInstance>();

      // return high level list of priceable item instances in the sytstem
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(PCWS_QUERY_FOLDER, "__GET_PI_INSTANCES_FOR_PO__"))
        {
          stmt.AddParam("%%PO_ID%%", poId);
          stmt.AddParam("%%PARENT_SELECTION_CONDITION%%", "and map.id_pi_instance_parent in (" + piParentIDs + ")");

          RetrievePIInstances(stmt, ref piChildrenDictionary, ref piChildrenIds, ref piChildrenList);
        }
      }

      if (!String.IsNullOrEmpty(piChildrenIds))
      {
        piGlobalInstanceIds += piChildrenIds;

        // Set up a collection of child properties to set
        Dictionary<string, ChildPropertyData> parentProperties = new Dictionary<string, ChildPropertyData>();
        foreach (BasePriceableItemInstance parentInstance in piDictionary.Values)
        {
          List<PropertyInfo> propertyList = parentInstance.GetProperties();

          foreach (PropertyInfo property in propertyList)
          {
            if (property.PropertyType.IsSubclassOf(typeof(BasePriceableItemInstance)))
            {
              parentProperties.Add(property.Name, new ChildPropertyData(parentInstance, property));
            }

          }

        }

        // Link up parents and children
        foreach (BasePriceableItemInstance child in piChildrenList.Items)
        {
          ChildPropertyData propertyData = null;
          if (parentProperties.TryGetValue(child.Name, out propertyData))
          {
            propertyData.propertyInfo.SetValue(propertyData.parent, child, null);
          }

          //Add the instance to the global dictionary for late processing
          piDictionary.Add(child.ID.Value, child);
        }

        //Find children recursively...  
        //We need to setup a separate dictionary so that we can iterate over the properties of any children that we find
        Dictionary<int, BasePriceableItemInstance> piSubChildrenDictionary = new Dictionary<int, BasePriceableItemInstance>();

        piChildrenIds = piChildrenIds.Substring(0, piChildrenIds.Length - 1);

        RetrievePIChildInstances(poId, ref piChildrenIds, ref piSubChildrenDictionary, ref piGlobalInstanceIds);

        if (piSubChildrenDictionary.Count > 0)
        {
          // Continue to build up a global dictionary of PIInstances
          // to be used for later processing (e.g. localization)
          piDictionary.Concat(piSubChildrenDictionary);
        }
      }
    }

    private void RetrievePIInstances(IMTFilterSortStatement stmt,
                                     ref Dictionary<int, BasePriceableItemInstance> piDictionary,
                                     ref string piInstanceIds,
                                     ref MTList<BasePriceableItemInstance> piInstances)
    {

      using (IMTDataReader dataReader = stmt.ExecuteReader())
      {
        //if there are records, create a PriceableItem Insntance
        while (dataReader.Read())
        {
          string name = dataReader.GetString("PITypeName");
          BasePriceableItemInstance pi = (BasePriceableItemInstance)RetrieveClassName(name, "PIInstance");

          PopulatePIInstanceDetails((BasePriceableItemInstance)pi, dataReader);

          Dictionary<LanguageCode, string> localizedNames = new Dictionary<LanguageCode, string>();
          Dictionary<LanguageCode, string> localizedDesc = new Dictionary<LanguageCode, string>();

          piInstanceIds = piInstanceIds + pi.ID.Value + ",";
          pi.LocalizedDisplayNames = localizedNames;
          pi.LocalizedDescriptions = localizedDesc;

          piDictionary.Add(pi.ID.Value, pi);
          piInstances.Items.Add(pi);

        }

        piInstances.TotalRows = stmt.TotalRows;
      }
    }

    public void GetPIInstanceForPO(PCIdentifier poIdentifier, PCIdentifier piIdentifier, out BasePriceableItemInstance piInstance)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetPIInstanceForPO"))
      {
        try
        {
          piInstance = null;
          int poId = PCIdentifierResolver.ResolveProductOffering(poIdentifier);

          if (poId == -1)
          {
            throw new MASBasicException("Invalid product offering specified");
          }

          int piId = PCIdentifierResolver.ResolvePriceableItemInstance(poId, piIdentifier);

          if (piId == -1)
          {
            throw new MASBasicException("Invalid priceable item instance specified");
          }

          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            piInstance = CreatePIInstance(poId, piId);

            if (piInstance == null)
            {
              string poName;
              string piName;

              if (!String.IsNullOrEmpty(poIdentifier.Name))
              {
                poName = poIdentifier.Name;
              }
              else
              {
                poName = poId.ToString();
              }

              if (!String.IsNullOrEmpty(piIdentifier.Name))
              {
                piName = piIdentifier.Name;
              }
              else
              {
                piName = piId.ToString();
              }

              mLogger.LogDebug("Unable to find PIInstance: PO = {0}, PI = {1}", poName, piName);
            }
          }
        }
        catch (MASBasicException masBasic)
        {
          mLogger.LogError("MAS Basic exception caught getting priceable item instance", masBasic);

          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Exception getting priceable item instance", e);

          throw new MASBasicException("Error getting priceable item instance");
        }
      }
    }

    public void UpdatePIInstance(BasePriceableItemInstance piInstance)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("UpdatePIInstance"))
      {
        //TransactionOptions txOptions = new TransactionOptions();
        //txOptions.IsolationLevel = System.Transactions.IsolationLevel.ReadCommitted;
        var rm = new ResourcesManager();
        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
        {
          mLogger.LogDebug("TXN ISOLATION LEVEL IN updatepiinstance" + Transaction.Current.IsolationLevel.ToString());

          int poId = -1;
          #region Retrieve product offering ID
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_PO_ID_FOR_PI_INSTANCE__"))
            {
              string predicate;

              if (piInstance.ID.HasValue)
              {
                predicate = string.Format("id_pi_instance = {0}", piInstance.ID.Value);
              }
              else
              {
                predicate = string.Format("nm_name = {0}", DatabaseUtils.FormatValueForDB(piInstance.Name));
              }

              stmt.AddParam("%%PREDICATE%%", predicate, true);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                if (rdr.Read())
                {
                  poId = rdr.GetInt32("id_po");
                }
                else
                {
                  mLogger.LogError("Priceable Item Instance ({0}) not associated with a Product Offering", predicate);
                  throw new MASBasicException("Priceable Item Instance not associated with a Product Offering");
                }
              }
            }
          }
          #endregion

          ValidatePIInstanceNameAndID(poId, ref piInstance);

          CanProductOfferingBeModified(poId);

          try
          {
            mLogger.LogDebug("Update top-level priceable item instance '{0}'", piInstance.Name);
            var oldPiInstance = piInstance;
            InternalUpdatePIInstance(poId, ref piInstance);

            mLogger.LogDebug("Add audit event");
            String auditInfo = "";
            if (!oldPiInstance.Description.Equals(piInstance.Description))
            {
              auditInfo += String.Format(rm.GetLocalizedResource("PI_DESCRIPTION_WAS"), oldPiInstance.Description, piInstance.Description);
            }
            if (!oldPiInstance.DisplayName.Equals(piInstance.DisplayName))
            {
              auditInfo += String.Format(rm.GetLocalizedResource("PI_DISPLAY_NAME_WAS"), oldPiInstance.DisplayName, piInstance.DisplayName);
            }
            if (!oldPiInstance.Name.Equals(piInstance.Name))
            {
              auditInfo += String.Format(rm.GetLocalizedResource("PI_NAME_WAS"), oldPiInstance.Name, piInstance.Name);
            }
            if (!oldPiInstance.PIKind.Equals(piInstance.PIKind))
            {
              auditInfo += String.Format(rm.GetLocalizedResource("PI_KIND_WAS"), oldPiInstance.PIKind, piInstance.PIKind);
            }
            AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_PO_UPDATEPI,
                                        GetSessionContext().AccountID,
                                        (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT,
                                        poId,
                                        piInstance.Name + " " + auditInfo);
          }
          catch (MASBasicException masE)
          {
            throw masE;
          }
          catch (Exception e)
          {
            mLogger.LogException("Unhandled error updating top-level PI instance", e);

            throw new MASBasicException("Error updating top-level priceable item instance");
          }

          mLogger.LogDebug("Updating child priceable item instances");
          List<PropertyInfo> childPIProperties = piInstance.GetProperties();
          foreach (PropertyInfo childPIProperty in childPIProperties)
          {
            if (childPIProperty.PropertyType.IsSubclassOf(typeof(BasePriceableItemInstance)))
            {
              try
              {
                BasePriceableItemInstance childPIInstance = (BasePriceableItemInstance)childPIProperty.GetValue(piInstance, null);

                ValidatePIInstanceNameAndID(poId, ref childPIInstance);

                mLogger.LogDebug("Update child priceable item instance '{0}'", childPIInstance.Name);
                var oldPiInstance = childPIInstance;
                InternalUpdatePIInstance(poId, ref childPIInstance);

                mLogger.LogDebug("Add audit event");
                String auditInfo = "";
                if (!oldPiInstance.Description.Equals(childPIInstance.Description))
                {
                  auditInfo += String.Format(rm.GetLocalizedResource("PI_DESCRIPTION_WAS"), oldPiInstance.Description, childPIInstance.Description);
                }
                if (!oldPiInstance.DisplayName.Equals(childPIInstance.DisplayName))
                {
                  auditInfo += String.Format(rm.GetLocalizedResource("PI_DISPLAY_NAME_WAS"), oldPiInstance.DisplayName, childPIInstance.DisplayName);
                }
                if (!oldPiInstance.Name.Equals(childPIInstance.Name))
                {
                  auditInfo += String.Format(rm.GetLocalizedResource("PI_NAME_WAS"), oldPiInstance.Name, childPIInstance.Name);
                }
                if (!oldPiInstance.PIKind.Equals(childPIInstance.PIKind))
                {
                  auditInfo += String.Format(rm.GetLocalizedResource("PI_KIND_WAS"), oldPiInstance.PIKind, childPIInstance.PIKind);
                }
                AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_PO_UPDATEPI,
                                            GetSessionContext().AccountID,
                                            (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT,
                                            poId,
                                            piInstance.Name + " " +
                                            String.Format(rm.GetLocalizedResource("CHANGED_CHILD_PI_INSTANCE"),
                                            oldPiInstance.Name, childPIInstance.Name) + auditInfo);
              }
              catch (MASBasicException masE)
              {
                throw masE;
              }
              catch (Exception e)
              {
                mLogger.LogException("Unhandled error updating child PI instance", e);

                throw new MASBasicException("Error creating updating priceable item instance");
              }
            }
          }

          scope.Complete();
        }
      }
    }

    #endregion

    #region Private methods

    private void RollbackNonOverrideableProps(ref BasePriceableItemInstance piInstance, ref BasePriceableItemTemplate piTemplate)
    {
      ProductCatalogService prodCatalogService = new ProductCatalogService();

      if (piTemplate == null)
      {
        prodCatalogService.GetPriceableItemTemplate(piInstance.PITemplate, out piTemplate);
      }

      if (piTemplate == null)
      {
        throw new MASBasicException("Unable to locate priceable item template for override property check.");
      }

      #region check and rollback base and extended properties.



      List<PropertyInfo> baseInstProps = GetProperties(typeof(BasePriceableItemInstance));
      List<PropertyInfo> baseTempProps = GetProperties(typeof(BasePriceableItemTemplate));

      List<KeyValuePair<PropertyInfo, PropertyInfo>> baseProperties = (from i in baseInstProps.ToArray()
                                                                       from t in baseTempProps.ToArray()
                                                                       where i.Name == t.Name
                                                                       select new KeyValuePair<PropertyInfo, PropertyInfo>(i, t)).ToList();

      //loop thru props and rollback if not overridable.
      string attributeName;

      foreach (KeyValuePair<PropertyInfo, PropertyInfo> kvpair in baseProperties)
      {
        PropertyInfo iPropInfo = kvpair.Key;
        PropertyInfo tPropInfo = kvpair.Value;

        attributeName = iPropInfo.Name;

        if (iPropInfo.Name == "LocalizedDescriptions")
          attributeName = "Descriptions";
        if (iPropInfo.Name == "LocalizedDisplayNames")
          attributeName = "DisplayNames";

        if (!PCConfigManager.IsPropertyOverridable((int)piInstance.PIKind, attributeName) &&
            !piInstance.IsDirtyProperty(iPropInfo))
        {
          iPropInfo.SetValue(piInstance, tPropInfo.GetValue(piTemplate, null), null);
        }
      }


      //Append extended properties into base prop info list.
      List<PropertyInfo> extInstProps = GetExtendedProperyInfos(piInstance);
      List<PropertyInfo> extTempProps = GetExtendedProperyInfos(piTemplate);

      if (extInstProps != null && extTempProps != null && extInstProps.Count > 0 && extTempProps.Count > 0)
      {
        List<KeyValuePair<PropertyInfo, PropertyInfo>> extProperties = (from i in extInstProps.ToArray()
                                                                        from t in extTempProps.ToArray()
                                                                        where i.Name == t.Name
                                                                        select new KeyValuePair<PropertyInfo, PropertyInfo>(i, t)).ToList();

        foreach (KeyValuePair<PropertyInfo, PropertyInfo> kvpair in extProperties)
        {
          PropertyInfo iPropInfo = kvpair.Key;
          PropertyInfo tPropInfo = kvpair.Value;

          attributeName = iPropInfo.Name;

          if (iPropInfo.Name == "LocalizedDescriptions")
            attributeName = "Descriptions";
          if (iPropInfo.Name == "LocalizedDisplayNames")
            attributeName = "DisplayNames";

          if (!PCConfigManager.IsPropertyOverridable((int)piInstance.PIKind, attributeName) &&
                      !piInstance.IsDirtyProperty(iPropInfo))
          {
            iPropInfo.SetValue(piInstance, tPropInfo.GetValue(piTemplate, null), null);
          }
        }
      }

      #endregion


      //Check for Override Flag and Rollback Instance property changes.
      MethodInfo methodInfo = this.GetType().GetMethod("RollbackNonOveridableNKindProperties", BindingFlags.NonPublic | BindingFlags.Instance);
      methodInfo = methodInfo.MakeGenericMethod(GetPIKindInstanceType(piInstance.PIKind));
      methodInfo.Invoke(this, new object[2] { piInstance, piTemplate });

    }

    private void RollbackNonOveridableNKindProperties<T>(ref BasePriceableItemInstance piInstance, BasePriceableItemTemplate piTemplate) where T : BaseObject
    {

      T kindObject = piInstance as T;
      string attributeName;

      List<PropertyInfo> kindPropInfos = GetProperties(typeof(T));

      var query = from k in kindPropInfos
                  from t in piTemplate.GetProperties() // piTemplate.GetProperty(k.Name) is PropertyInfo
                  where k.Name == t.Name
                  select new KeyValuePair<PropertyInfo, PropertyInfo>(k, t);

      foreach (KeyValuePair<PropertyInfo, PropertyInfo> kvpair in query)
      {
        PropertyInfo kindPropInfo = kvpair.Key;
        PropertyInfo tempPropInfo = kvpair.Value;

        attributeName = kindPropInfo.Name;

        if (kindPropInfo.Name == "LocalizedDescriptions")
          attributeName = "Descriptions";
        if (kindPropInfo.Name == "LocalizedDisplayNames")
          attributeName = "DisplayNames";


        if ((piInstance.IsDirtyProperty(kindPropInfo) && piInstance.GetValue(kindPropInfo) == null) ||
            !PCConfigManager.IsPropertyOverridable((int)piInstance.PIKind, attributeName) &&
            !piInstance.IsDirtyProperty(kindPropInfo))
        {
          //check the property is Cycle.
          if (kindPropInfo.PropertyType == typeof(ExtendedUsageCycleInfo) ||
              kindPropInfo.PropertyType.IsSubclassOf(typeof(ExtendedUsageCycleInfo)))
          {
            ExtendedUsageCycleInfo piInstanceCycleInfo = piInstance.GetValue(kindPropInfo) as ExtendedUsageCycleInfo;
            ExtendedUsageCycleInfo pitemplateCycleInfo = piTemplate.GetValue(tempPropInfo) as ExtendedUsageCycleInfo;

            PopulateCycleProperties(ref piInstanceCycleInfo, pitemplateCycleInfo);

            kindPropInfo.SetValue(kindObject, piInstanceCycleInfo, null);
            //kindObject.SetValue(kindPropInfo, piInstanceCycleInfo);

          }
          else
          {
            kindPropInfo.SetValue(kindObject, tempPropInfo.GetValue(piTemplate, null), null);
          }
        }
      }

      piInstance = kindObject as BasePriceableItemInstance;
    }

    private void InternalRemovePIInstanceFromPO(int poID, int piInstanceID)
    {
      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          //load child priceable item instances for given priceable 
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__LOAD_PI_CHILD_INSTANCE_IDS__"))
          {
            stmt.AddParam("%%PI_ID%%", piInstanceID);

            // need to add updlock in SQLServer case to prevent deadlocks
            if (conn.ConnectionInfo.IsOracle)
            {
              stmt.AddParam("%%UPDLOCK%%", "");
            }
            else
            {
              stmt.AddParam("%%UPDLOCK%%", "with(updlock)");
            }

            using (IMTDataReader reader = stmt.ExecuteReader())
            {
              while (reader.Read())
              {
                InternalRemovePIInstanceFromPO(poID, reader.GetInt32(0));
              }
            }
          }

          mLogger.LogDebug("Deleting PI Instance {0} for PO {1}", piInstanceID, poID);

          //delete priceable item instance.
          using (IMTCallableStatement delStmt = conn.CreateCallableStatement("DeletePriceableItemInstance"))
          {
            delStmt.AddParam("piID", MTParameterType.Integer, piInstanceID);
            delStmt.AddParam("poID", MTParameterType.Integer, poID);
            delStmt.AddOutputParam("status", MTParameterType.Integer);
            delStmt.ExecuteNonQuery();

            int status = (int)delStmt.GetOutputValue("status");

            if (status == -10)
            {
              throw new MASBasicException(string.Format("Unable to remove priceable item instance with ID {0} because there are existing adjustment transactions", piInstanceID));
            }
          }
        }

        #region Add Audit Entry
        AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_PO_DELETEPI, -1, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
        string.Format("Successfully removed Priceable Item instance : {0}", piInstanceID));
        mLogger.LogDebug(string.Format("Successfully removed Priceable Item instance : {0}", piInstanceID));
        #endregion

      }
      catch (MASBasicException masE)
      {
        mLogger.LogException("MASBasicException caught removing priceable item instance", masE);

        throw masE;
      }
      catch (Exception e)
      {
        mLogger.LogException("Unhandled exception removing priceable item instance", e);
        throw new MASBasicException("Unexpected error removing priceable item instance.  Ask system administrator to review server logs.");
      }
    }

    private void CheckPoName(string poName)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement checkPoNameStmt = conn.CreateAdapterStatement("queries\\PCWS", "__CHECK_PO_NAME__"))
        {
          checkPoNameStmt.AddParam("%%N_KIND%%", PRODUCT_OFFERING_KIND);
          checkPoNameStmt.AddParam("%%NM_NAME%%", poName);

          if (!conn.ConnectionInfo.IsOracle)
          {
            checkPoNameStmt.AddParam("%%UPDLOCK%%", "WITH (UPDLOCK)");
          }
          else
          {
            checkPoNameStmt.AddParam("%%UPDLOCK%%", "");
          }

          using (IMTDataReader poNameReader = checkPoNameStmt.ExecuteReader())
          {
            while (poNameReader.Read())
            {
              throw new MASBasicException(String.Format("{0} name already exists.", poName));
            }
          }
        }
      }
    }

    private void AddPoAccTypeMappings(ProductOffering productOffering, IMTSessionContext context)
    {
      List<string> accRestrictions = productOffering.SupportedAccountTypes;
      if (accRestrictions.Count > 0)
      {
        IMTQueryAdapter qa = new MTQueryAdapterClass();
        qa.Init(PCWS_QUERY_FOLDER);
        string updateQueries = "BEGIN\n";

        foreach (string accType in accRestrictions)
        //for (int i = 0; i < accRestrictions.Count; i++)
        {
          qa.SetQueryTag("__ADD_SUBSCRIBABLE_ACCOUNT_TYPE_BYNAME_PCWS__");
          qa.AddParam("%%ID_PO%%", productOffering.ProductOfferingId.Value, true);
          qa.AddParam("%%NAME%%", accType, true);
          updateQueries += qa.GetQuery().Trim() + ";\n";
        }

        if (updateQueries.Length > 0)
        {
          try
          {
            updateQueries += "END;";

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
              using (IMTStatement stmt = conn.CreateStatement(updateQueries))
              {
                stmt.ExecuteNonQuery();
              }
            }
          }
          catch (Exception ex)
          {
            mLogger.LogException("Exception updating account type mapping details ", ex);
            mLogger.LogError("Exception when updating account type mapping details :\n{0}", updateQueries);
          }

          updateQueries = "";
        }
      }
    }

    private void InternalAddPIInstance(int id_po, int? basePIInstanceID, ref BasePriceableItemInstance piInstance)
    {
      ValidatePIInstance(id_po, piInstance);

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        #region Create base properties
        mLogger.LogDebug("Call CreateBaseProps to insert PO base props");
        piInstance.ID = BasePropsUtils.CreateBaseProps(GetSessionContext(), piInstance.Name, piInstance.Description, piInstance.DisplayName, (int)piInstance.PIKind);

        int piTemplateID = PCIdentifierResolver.ResolvePriceableItemTemplate(piInstance.PITemplate);
        if (piTemplateID == -1)
        {
          throw new MASBasicException("Invalid priceable item template specified");
        }
        #endregion

        mLogger.LogDebug("Add pricelist mappings");
        #region Add Pricelist Mappings
        try
        {
          // Add base PL mapping with null parameter table ID to identify PI without param tables
          object[] attribs = piInstance.GetType().GetCustomAttributes(typeof(MTPriceableItemInstanceAttribute), true);
          if (attribs.Length == 0)
          {
            throw new MASBasicException("Unable to get MTPriceableItemInstanceAttribute from priceable item instance class");
          }


          int id = PCIdentifierResolver.ResolvePriceableItemType(new PCIdentifier(((MTPriceableItemInstanceAttribute)attribs[0]).PIType));
          if (id == -1)
          {
            throw new MASBasicException("Invalid priceable item type specified");
          }

          using (IMTCallableStatement callableStmt = conn.CreateCallableStatement("AddDefaultPIPLMappings"))
          {
            callableStmt.AddParam("piType", MTParameterType.Integer, id);
            callableStmt.AddParam("piTemplateID", MTParameterType.Integer, piTemplateID);

            callableStmt.AddParam("piInstanceID", MTParameterType.Integer, piInstance.ID.Value);

            //Do not resolve parentPIInstanceID, take the method parameter value.
            callableStmt.AddParam("piInstanceParentID", MTParameterType.Integer,
                ((basePIInstanceID.HasValue && basePIInstanceID.Value > 0) ? basePIInstanceID : null));

            callableStmt.AddParam("poID", MTParameterType.Integer, id_po);
            callableStmt.AddParam("systemDate", MTParameterType.DateTime, MetraTime.Now);

            callableStmt.ExecuteNonQuery();
          }
        }
        catch (MASBasicException masE)
        {
          throw masE;
        }
        catch (Exception e)
        {
          mLogger.LogException("Unknown error adding pricelist mappings", e);

          throw new MASBasicException("Error creating pricelist mappings");
        }
        #endregion

        #region Add PI Kind Specific Properties
        try
        {
          switch (piInstance.PIKind)
          {
            case PriceableItemKinds.NonRecurring:
              mLogger.LogDebug("Adding NonRecurring specific properties");
              #region Insert NonRecurringCharge Properties
              using (IMTAdapterStatement adapterStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__INSERT_NRC_PROPERTIES_BY_ID_PCWS__"))
              {
                adapterStmt.AddParam("%%ID_PROP%%", piInstance.ID);
                adapterStmt.AddParam("%%N_EVENT_TYPE%%", (int)((NonRecurringChargePIInstance)piInstance).EventType);

                adapterStmt.ExecuteNonQuery();
              }
              #endregion
              break;
            case PriceableItemKinds.Discount:
              mLogger.LogDebug("Adding Discount specific properties");
              #region Insert Discount Properties
              DiscountPIInstance discInstance = ((DiscountPIInstance)piInstance);
              using (IMTAdapterStatement adapterStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__INSERT_DISCOUNT_PROPERTIES_BY_ID_PCWS__"))
              {
                adapterStmt.AddParam("%%ID_PROP%%", piInstance.ID.Value);
                adapterStmt.AddParam("%%N_VALUE_TYPE%%", 0);
                adapterStmt.AddParam("%%ID_DISTRIBUTION_CPD%%", null);

                AddCycleIDsToQuery(adapterStmt, discInstance.Cycle);

                adapterStmt.ExecuteNonQuery();
              }
              #endregion
              break;
            case PriceableItemKinds.Recurring:
            case PriceableItemKinds.UnitDependentRecurring:
              mLogger.LogDebug("Adding Recurring specific properties");
              #region Insert Recurring Charge Properties
              BaseRecurringChargePIInstance baseRC = (BaseRecurringChargePIInstance)piInstance;

              using (IMTAdapterStatement adapterStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__INSERT_RECURRING_CHARGE_PROPERTIES_BY_ID_PCWS__"))
              {
                adapterStmt.AddParam("%%ID_PROP%%", piInstance.ID.Value);

                adapterStmt.AddParam("%%ID_LANG_CODE%%", GetSessionContext().LanguageID);

                if (!baseRC.ChargeAdvance.HasValue)
                {
                  throw new MASBasicException(String.Format("Error saving PriceableItemInstance id = {0} : ChargeAdvance property must have a value", piInstance.ID.Value));
                }
                adapterStmt.AddParam("%%B_ADVANCE%%", (baseRC.ChargeAdvance.Value ? "Y" : "N"));

                if (!baseRC.ProrateOnActivation.HasValue)
                {
                  throw new MASBasicException(String.Format("Error saving PriceableItemInstance id = {0} : ProrateOnActivation property must have a value", piInstance.ID.Value));
                }
                adapterStmt.AddParam("%%B_PRORATE_ON_ACTIVATE%%", (baseRC.ProrateOnActivation.Value ? "Y" : "N"));

                if (!baseRC.ProrateInstantly.HasValue)
                {
                  throw new MASBasicException(String.Format("Error saving PriceableItemInstance id = {0} : ProrateInstantly property must have a value", piInstance.ID.Value));
                }
                adapterStmt.AddParam("%%B_PRORATE_INSTANTLY%%", (baseRC.ProrateInstantly.Value ? "Y" : "N"));

                if (!baseRC.ProrateOnDeactivation.HasValue)
                {
                  throw new MASBasicException(String.Format("Error saving PriceableItemInstance id = {0} : ProrateOnDeactivation property must have a value", piInstance.ID.Value));
                }
                adapterStmt.AddParam("%%B_PRORATE_ON_DEACTIVATE%%", (baseRC.ProrateOnDeactivation.Value ? "Y" : "N"));

                if (!baseRC.FixedProrationLength.HasValue)
                {
                  throw new MASBasicException(String.Format("Error saving PriceableItemInstance id = {0} : FixedProrationLength property must have a value", piInstance.ID.Value));
                }
                adapterStmt.AddParam("%%B_FIXED_PRORATION_LENGTH%%", (baseRC.FixedProrationLength.Value ? "Y" : "N"));

                if (!baseRC.ChargePerParticipant.HasValue)
                {
                  throw new MASBasicException(String.Format("Error saving PriceableItemInstance id = {0} : ChargePerParticipant property must have a value", piInstance.ID.Value));
                }
                adapterStmt.AddParam("%%B_CHARGE_PER_PARTICIPANT%%", (baseRC.ChargePerParticipant.Value ? "Y" : "N"));

                if (piInstance.PIKind == PriceableItemKinds.UnitDependentRecurring)
                {
                  UnitDependentRecurringChargePIInstance udrcInstance = ((UnitDependentRecurringChargePIInstance)baseRC);

                  adapterStmt.AddParam("%%NM_UNIT_NAME%%", udrcInstance.UnitName);
                  adapterStmt.AddParam("%%NM_UNIT_DISPLAY_NAME%%", udrcInstance.UnitDisplayName);
                  adapterStmt.AddParam("%%N_RATING_TYPE%%", (int)udrcInstance.RatingType);

                  if (!udrcInstance.IntegerUnitValue.HasValue)
                  {
                    throw new MASBasicException(String.Format("Error saving PriceableItemInstance id = {0} : IntegerUnitValue property must have a value", piInstance.ID.Value));
                  }
                  adapterStmt.AddParam("%%B_INTEGRAL%%", (udrcInstance.IntegerUnitValue.Value ? "Y" : "N"));

                  adapterStmt.AddParam("%%MAX_UNIT_VALUE%%", udrcInstance.MaxUnitValue);
                  adapterStmt.AddParam("%%MIN_UNIT_VALUE%%", udrcInstance.MinUnitValue);
                }
                else
                {
                  adapterStmt.AddParam("%%NM_UNIT_NAME%%", "");
                  adapterStmt.AddParam("%%NM_UNIT_DISPLAY_NAME%%", "");
                  adapterStmt.AddParam("%%N_RATING_TYPE%%", 1);
                  adapterStmt.AddParam("%%B_INTEGRAL%%", "N");
                  adapterStmt.AddParam("%%MAX_UNIT_VALUE%%", 999999999.000000);
                  adapterStmt.AddParam("%%MIN_UNIT_VALUE%%", 0);
                }

                AddExtendedCycleIDsToQuery(adapterStmt, baseRC.Cycle);

                adapterStmt.ExecuteNonQuery();
              }

              if (piInstance.PIKind == PriceableItemKinds.UnitDependentRecurring)
              {
                mLogger.LogDebug("Adding UDRC unit name");
                UnitDependentRecurringChargePIInstance udrcInstance = ((UnitDependentRecurringChargePIInstance)baseRC);
                int n_unit_displayname = -1;

                using (IMTAdapterStatement adapterStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_UNITDISPLAYNAME_DESC_ID_FOR_UDRC_PCWS__"))
                {
                  adapterStmt.AddParam("%%ID_PROP%%", piInstance.ID.Value);

                  using (IMTDataReader rdr = adapterStmt.ExecuteReader())
                  {
                    if (rdr.Read())
                    {
                      n_unit_displayname = rdr.GetInt32("n_unit_display_name");
                    }
                  }
                }

                ProcessLocalizationData(n_unit_displayname,
                                        udrcInstance.LocalizedUnitDisplayNames,
                                        udrcInstance.IsLocalizedUnitDisplayNamesDirty,
                                        null,
                                        null,
                                        false);

                AddUDRCUnitValues(udrcInstance);
              }
              #endregion
              break;
            case PriceableItemKinds.AggregateCharge:
              mLogger.LogDebug("Adding Aggregate specific properties");
              #region Insert Aggregate Charge Properties
              using (IMTAdapterStatement adapterStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__INSERT_AGGREGATE_CHARGE_PROPERTIES_BY_ID_PCWS__"))
              {
                adapterStmt.AddParam("%%ID_PROP%%", piInstance.ID.Value);

                AddCycleIDsToQuery(adapterStmt, ((AggregateChargePIInstance)piInstance).Cycle);

                adapterStmt.ExecuteNonQuery();
              }
              #endregion
              break;
          }
        }
        catch (MASBasicException masE)
        {
          throw masE;
        }
        catch (Exception e)
        {
          mLogger.LogException("Unknown error adding pi kind specific properties", e);

          throw new MASBasicException("Error adding priceable item kind specific properties");
        }
        #endregion

        UpsertExtendedProps(piInstance.ID.Value, piInstance);

        CreateAdjustmentInstances(piInstance);

        ProcessLocalizationData(piInstance.ID.Value,
                                piInstance.LocalizedDisplayNames,
                                piInstance.IsLocalizedDisplayNamesDirty,
                                piInstance.LocalizedDescriptions,
                                piInstance.IsLocalizedDescriptionDirty);

        UpsertRateSchedules(id_po, piTemplateID, piInstance);
      }
    }

    private void AddUDRCUnitValues(UnitDependentRecurringChargePIInstance udrcInstance)
    {
      if (udrcInstance != null && udrcInstance.AllowedUnitValues.HasValue())
      {
        mLogger.LogDebug("Adding UDRC allowed unit values");
        string baseQueryText = "\n INSERT INTO t_recur_enum (id_prop, enum_value) values ({0},{1}); \n";

        string queryText = "BEGIN\n";

        foreach (decimal udrcEnumValue in udrcInstance.AllowedUnitValues)
        {
          queryText += string.Format(baseQueryText, udrcInstance.ID.Value, udrcEnumValue.ToString());
        }

        queryText += "\nEND;";

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTStatement stmt = conn.CreateStatement(queryText))
          {
            stmt.ExecuteNonQuery();
          }
        }
      }
    }

    private void UpsertRateSchedules(int id_po, int piTemplateID, BasePriceableItemInstance piInstance)
    {
      mLogger.LogDebug("Upserting Rate Schedules");

      try
      {
        List<PropertyInfo> properties = piInstance.GetMTProperties();

        foreach (PropertyInfo prop in properties)
        {

          object[] attribs = prop.GetCustomAttributes(typeof(MTRateSchedulesPropertyAttribute), true);
          if (attribs.Length > 0)
          {
            string ptName = ((MTRateSchedulesPropertyAttribute)attribs[0]).ParameterTable;

            if (piInstance.IsDirty(prop))
            {
              int pricelistId = -1;
              using (IMTConnection conn = ConnectionManager.CreateConnection())
              {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_PRICELIST_MAPPING_PCWS__"))
                {
                  stmt.AddParam("%%PO_ID%%", id_po);
                  stmt.AddParam("%%PI_ID%%", piInstance.ID.Value);
                  stmt.AddParam("%%PT_ID%%", CacheManager.ParamTableNameToIdMap[ptName.ToUpper()].ID);

                  using (IMTDataReader rdr = stmt.ExecuteReader())
                  {
                    if (rdr.Read())
                    {
                      pricelistId = rdr.GetInt32("id_pricelist");
                    }
                  }
                }
              }

              if (pricelistId == -1)
              {
                throw new MASBasicException(string.Format("Unable to locate pricelist mapping for PO {0}, PI Instance {1}, Template {2}, Paramter table {3}", id_po, piInstance.ID, piTemplateID, ptName));
              }

              IList rsList = prop.GetValue(piInstance, null) as IList;
              Application.ProductManagement.PriceListService.UpsertRateSchedulesForPricelist(pricelistId, PriceListTypes.DEFAULT, piInstance.PITemplate.ID.Value, CacheManager.ParamTableNameToIdMap[ptName.ToUpper()].ID, rsList, mLogger, GetSessionContext());
            }
          }
        }
      }
      catch (MASBasicException masE)
      {
        throw masE;
      }
      catch (Exception e)
      {
        mLogger.LogException("Unknown error adding rate schedules", e);

        throw new MASBasicException("Error creating rate schedules");
      }

    }

    private void CreateAdjustmentInstances(BasePriceableItemInstance piInstance)
    {
      mLogger.LogDebug("Creating adjustment instances");

      try
      {
        List<PropertyInfo> properties = piInstance.GetProperties();

        foreach (PropertyInfo prop in properties)
        {
          if (prop.PropertyType == typeof(AdjustmentInstance))
          {
            object[] attribs = prop.GetCustomAttributes(typeof(MTAdjustmentTypeAttribute), true);
            AdjustmentInstance adjInst = prop.GetValue(piInstance, null) as AdjustmentInstance;

            if (adjInst != null)
            {
              if (attribs.Length > 0)
              {
                MTAdjustmentTypeAttribute attrib = attribs[0] as MTAdjustmentTypeAttribute;

                mLogger.LogDebug("Adding adjustment instance: {0} for type", adjInst.Name, attrib.Type);
                adjInst.ID = BasePropsUtils.CreateBaseProps(GetSessionContext(), adjInst.Name, adjInst.Description, adjInst.DisplayName, ADJUSTMENT_TYPE);

                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                  using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__INSERT_ADJUSTMENT_INSTANCE__"))
                  {
                    stmt.AddParam("%%ID_PROP%%", adjInst.ID.Value);
                    stmt.AddParam("%%GUID%%", "0xABCD");//TODO: fix GUIDs System.Guid.NewGuid().ToByteArray());
                    stmt.AddParam("%%PI_ID%%", piInstance.ID);
                    stmt.AddParam("%%ADJ_NAME%%", attrib.Type);
                    stmt.ExecuteNonQuery();
                  }
                }

                ProcessLocalizationData(adjInst.ID.Value,
                                        adjInst.LocalizedDisplayNames,
                                        adjInst.IsLocalizedDisplayNamesDirty,
                                        adjInst.LocalizedDescriptions,
                                        adjInst.IsLocalizedDescriptionsDirty);
              }
              else
              {
                throw new MASBasicException("Missing MTAdjustmentInstance attribute");
              }
            }
          }
        }
      }
      catch (MASBasicException masE)
      {
        throw masE;
      }
      catch (Exception e)
      {
        mLogger.LogException("Unknown error adding adjustment instances", e);

        throw new MASBasicException("Error creating adjustment instances");
      }
    }

    private void UpdateAdjustmentInstances(BasePriceableItemInstance piInstance)
    {
      mLogger.LogDebug("Updating adjustment instances");

      try
      {
        List<PropertyInfo> properties = piInstance.GetProperties();

        foreach (PropertyInfo prop in properties)
        {
          if (prop.PropertyType == typeof(AdjustmentInstance) && piInstance.IsDirty(prop))
          {
            object[] attribs = prop.GetCustomAttributes(typeof(MTAdjustmentTypeAttribute), true);

            if (attribs.Length > 0)
            {
              MTAdjustmentTypeAttribute attrib = attribs[0] as MTAdjustmentTypeAttribute;
              AdjustmentInstance adjInst = prop.GetValue(piInstance, null) as AdjustmentInstance;
              int adjId = -1;
              using (IMTConnection conn = ConnectionManager.CreateConnection())
              {

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_ADJ_INST_ID_FOR_UPDATE__"))
                {
                  stmt.AddParam("%%ADJ_NAME%%", attrib.Type);
                  stmt.AddParam("%%PI_ID%%", piInstance.ID.Value);

                  using (IMTDataReader rdr = stmt.ExecuteReader())
                  {
                    if (rdr.Read())
                    {
                      adjId = rdr.GetInt32("id_prop");
                    }
                  }
                }


                if (adjId != -1)
                {
                  if (adjInst != null)
                  {
                    mLogger.LogDebug("Updating adjustment instance: {0} for type {1}", adjInst.Name, attrib.Type);

                    BasePropsUtils.UpdateBaseProps(GetSessionContext(),
                                    adjInst.Description,
                                    adjInst.IsDescriptionDirty,
                                    adjInst.DisplayName,
                                    adjInst.IsDisplayNameDirty,
                                    adjId);

                    ProcessLocalizationData(adjId,
                                            adjInst.LocalizedDisplayNames,
                                            adjInst.IsLocalizedDisplayNamesDirty,
                                            adjInst.LocalizedDescriptions,
                                            adjInst.IsLocalizedDescriptionsDirty);

                  }
                  else
                  {
                    mLogger.LogDebug("Deleting adjustment instance: {0} for type {1}", adjInst.Name, attrib.Type);

                    using (IMTCallableStatement callableStmt = conn.CreateCallableStatement("DeleteBaseProps"))
                    {
                      callableStmt.AddParam("a_id_prop", MTParameterType.Integer, adjId);
                      callableStmt.ExecuteNonQuery();
                    }

                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__DELETE_ADJUSTMENT_INSTANCE__"))
                    {
                      stmt.AddParam("%%ID_PROP%%", adjId);
                      stmt.ExecuteNonQuery();
                    }
                  }
                }
                else
                {
                  if (adjInst != null)
                  {
                    mLogger.LogDebug("Adding adjustment instance: {0} for type {1}", adjInst.Name, attrib.Type);
                    adjInst.ID = BasePropsUtils.CreateBaseProps(GetSessionContext(), adjInst.Name, adjInst.Description, adjInst.DisplayName, ADJUSTMENT_TYPE);

                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__INSERT_ADJUSTMENT_INSTANCE__"))
                    {
                      stmt.AddParam("%%ID_PROP%%", adjInst.ID.Value);
                      stmt.AddParam("%%GUID%%", "0xABCD");//TODO: fix GUIDs System.Guid.NewGuid().ToByteArray());
                      stmt.AddParam("%%PI_ID%%", piInstance.ID);
                      stmt.AddParam("%%ADJ_NAME%%", attrib.Type);
                      stmt.ExecuteNonQuery();
                    }

                    ProcessLocalizationData(adjInst.ID.Value,
                                            adjInst.LocalizedDisplayNames,
                                            adjInst.IsLocalizedDisplayNamesDirty,
                                            adjInst.LocalizedDescriptions,
                                            adjInst.IsLocalizedDescriptionsDirty);
                  }
                }
              }

            }
            else
            {
              throw new MASBasicException("Missing MTAdjustmentInstance attribute");
            }
          }
        }
      }
      catch (MASBasicException masE)
      {
        throw masE;
      }
      catch (Exception e)
      {
        mLogger.LogException("Unknown error adding adjustment instances", e);

        throw new MASBasicException("Error updating adjustment instances");
      }
    }


    private void ValidatePIInstance(int id_po, BasePriceableItemInstance piInstance)
    {
      mLogger.LogDebug("Validate PI Instance: {0}", piInstance.Name);

      try
      {
        #region Validate submitted data
        if (string.IsNullOrEmpty(piInstance.Name))
        {
          throw new MASBasicException("Priceable Item Name must be specified");
        }

        if (string.IsNullOrEmpty(piInstance.DisplayName))
        {
          throw new MASBasicException("Priceable Item Display Name must be specified");
        }

        if (piInstance.PITemplate == null)
        {
          throw new MASBasicException("The template for the priceable item instance must be specified");
        }
        #endregion

        mLogger.LogDebug("Validate usage cycle compatibility");
        #region Validate Usage Cycle Compatibility
        ValidateCycleChange(id_po, piInstance);
        #endregion

        mLogger.LogDebug("Check if specified PI Template Exists");
        int templateId = PCIdentifierResolver.ResolvePriceableItemTemplate(piInstance.PITemplate);

        if (templateId == -1)
        {
          throw new MASBasicException("Specified priceable item template does not exist in MetraNet");
        }

        mLogger.LogDebug("Check for duplicate templates if business rules enabled");
        #region Check for Duplicate Templates if Business Rules enabled
        if (PCConfigManager.IsBusinessRuleEnabled(PCConfigManager.MTPC_BUSINESS_RULE_ProdOff_NoDuplicateTemplate) ||
            PCConfigManager.IsBusinessRuleEnabled(PCConfigManager.MTPC_BUSINESS_RULE_ProdOff_NoDuplicateUsageTemplate))
        {
          mLogger.LogDebug("Check for duplicate templates on product offering");
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__FIND_PI_TEMPLATE_IN_PO_PCWS__"))
            {
              stmt.AddParam("%%ID_PO%%", id_po);
              stmt.AddParam("%%ID_TEMPL%%", templateId);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                if (rdr.Read())
                {
                  if (piInstance.PIKind == PriceableItemKinds.Usage || piInstance.PIKind == PriceableItemKinds.AggregateCharge)
                  {
                    if (PCConfigManager.IsBusinessRuleEnabled(PCConfigManager.MTPC_BUSINESS_RULE_ProdOff_NoDuplicateUsageTemplate))
                    {
                      throw new MASBasicException("Usage priceable item template already exists on product offering");
                    }
                  }
                  else
                  {
                    if (PCConfigManager.IsBusinessRuleEnabled(PCConfigManager.MTPC_BUSINESS_RULE_ProdOff_NoDuplicateTemplate))
                    {
                      throw new MASBasicException("Priceable item template already exists on product offering");
                    }
                  }
                }
              }
            }
          }
        }
        #endregion

        // If PIInstance is UDRC, 
        //      Check for Min < Max
        //      ensure that unit name and unit display name are set and do not exist on PO
        if (piInstance.PIKind == PriceableItemKinds.UnitDependentRecurring)
        {
          UnitDependentRecurringChargePIInstance udrc = ((UnitDependentRecurringChargePIInstance)piInstance);

          mLogger.LogDebug("Ensure that MinUnitValue is less than MaxUnitValue");
          if (udrc.MinUnitValue > udrc.MaxUnitValue)
          {
            throw new MASBasicException("Min Unit Value must be less than the Max Unit Value");
          }

          #region Validate UDRC Unit Name Does Not Exist
          mLogger.LogDebug("Validate that UDRC UnitName doesn't already exist for PO");
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__UNIT_NAME_EXISTS_ON_PO__"))
            {
              stmt.AddParam("%%ID_PO%%", id_po);
              stmt.AddParam("%%NM_UNIT_NAME%%", udrc.UnitName);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                if (rdr.Read())
                {
                  throw new MASBasicException("Unit name has already been defined for the product offering");
                }
              }
            }
          }
          #endregion
        }

        mLogger.LogDebug("Check if PI Instance name exists on PO");
        if (PCConfigManager.IsBusinessRuleEnabled(PCConfigManager.MTPC_BUSINESS_RULE_ProdOff_NoDuplicateInstanceName))
        {
          int piID = PCIdentifierResolver.ResolvePriceableItemInstance(id_po, new PCIdentifier(piInstance.Name));

          if (piID != -1)
          {
            throw new MASBasicException("Priceable Item Name already exists on Product Offering");
          }
        }
      }
      catch (MASBasicException masE)
      {
        throw masE;
      }
      catch (Exception e)
      {
        mLogger.LogException("Unknown error validating priceable item instance", e);

        throw new MASBasicException("Unknown error validating priceable item instance");
      }
    }

    private void ValidatePIInstanceNameAndID(int poID, ref BasePriceableItemInstance piInstance)
    {
      int piID = -1;

      PCIdentifier piIdentifier = null;

      if (piInstance.ID.HasValue && piInstance.IsNameDirty)
      {
        piIdentifier = new PCIdentifier(piInstance.ID.Value, piInstance.Name);
      }
      else if (piInstance.ID.HasValue)
      {
        piIdentifier = new PCIdentifier(piInstance.ID.Value);
      }
      else
      {
        piIdentifier = new PCIdentifier(piInstance.Name);
      }

      piID = PCIdentifierResolver.ResolvePriceableItemInstance(poID, piIdentifier);

      if (piID == -1 || (piInstance.ID.HasValue && piInstance.ID.Value != piID))
      {
        throw new MASBasicException("Invalid priceable item instance ID");
      }

      piInstance.ID = piID;
    }

    private void InternalUpdatePIInstance(int poId, ref BasePriceableItemInstance piInstance)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        if (PCConfigManager.IsBusinessRuleEnabled(PCConfigManager.MTPC_BUSINESS_RULE_PI_CheckCycleChange))
        {
          ValidateCycleChange(poId, piInstance);
        }

        int piTemplateID = PCIdentifierResolver.ResolvePriceableItemTemplate(piInstance.PITemplate);
        if (piTemplateID == -1)
        {
          throw new MASBasicException("Invalid priceable item template specified");
        }

        #region Update Description and DisplayName

        if (piInstance.IsDescriptionDirty || piInstance.IsDisplayNameDirty)
        {
          BasePropsUtils.UpdateBaseProps(GetSessionContext(),
                          piInstance.Description,
                          piInstance.IsDescriptionDirty & PCConfigManager.IsPropertyOverridable((int)piInstance.PIKind, "Description"),
                          piInstance.DisplayName,
                          piInstance.IsDisplayNameDirty & PCConfigManager.IsPropertyOverridable((int)piInstance.PIKind, "DisplayName"),
                          piInstance.ID.Value);
        }

        #endregion

        #region Update Kind Specific Properties
        switch (piInstance.PIKind)
        {
          case PriceableItemKinds.NonRecurring:
            UpdateNonRecurringChargePIInstance(((NonRecurringChargePIInstance)piInstance));
            break;
          case PriceableItemKinds.Discount:
            UpdateDiscountPIInstance(((DiscountPIInstance)piInstance));
            break;
          case PriceableItemKinds.Recurring:
          case PriceableItemKinds.UnitDependentRecurring:
            UpdateRecurringChargePIInstance(((BaseRecurringChargePIInstance)piInstance));
            break;
          case PriceableItemKinds.AggregateCharge:
            UpdateAggregateChargePIInstance(((AggregateChargePIInstance)piInstance));
            break;
        }
        #endregion

        #region Update Localized Descriptions and DisplayNames
        if (piInstance.IsLocalizedDescriptionDirty || piInstance.IsLocalizedDisplayNamesDirty)
        {
          ProcessLocalizationData(piInstance.ID.Value,
                                  piInstance.LocalizedDisplayNames,
                                  piInstance.IsLocalizedDisplayNamesDirty & PCConfigManager.IsPropertyOverridable((int)piInstance.PIKind, "DisplayNames"),
                                  piInstance.LocalizedDescriptions,
                                  piInstance.IsLocalizedDescriptionDirty & PCConfigManager.IsPropertyOverridable((int)piInstance.PIKind, "Descriptions"));
        }
        #endregion

        UpdateAdjustmentInstances(piInstance);

        UpsertRateSchedules(poId, piTemplateID, piInstance);
      }
    }

    private void ValidateCycleChange(int id_po, BasePriceableItemInstance piInstance)
    {
      if (piInstance.PIKind == PriceableItemKinds.Recurring ||
              piInstance.PIKind == PriceableItemKinds.UnitDependentRecurring ||
              piInstance.PIKind == PriceableItemKinds.Discount ||
              piInstance.PIKind == PriceableItemKinds.AggregateCharge)
      {
        mLogger.LogDebug("Get UsageCycle property");
        PropertyInfo usageCycleProp = piInstance.GetProperty("Cycle");

        if (usageCycleProp != null)
        {
          mLogger.LogDebug("Get UsageCycle property value");
          ExtendedUsageCycleInfo cycleInfo = usageCycleProp.GetValue(piInstance, null) as ExtendedUsageCycleInfo;

          if (cycleInfo != null)
          {
            string mode;
            int? cycleId, cycleTypeId;

            ResolveUsageCycleInfo(cycleInfo, out mode, out cycleId, out cycleTypeId);

            // Only check if type is EBCR or BCR Constrained
            if (mode == "EBCR" || mode == "BCR Constrained")
            {
              mLogger.LogDebug("Cycle type needs to be validated");
              using (IMTConnection conn = ConnectionManager.CreateConnection())
              {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__CHECK_FOR_USAGE_CYCLE_CONFLICTS__"))
                {
                  stmt.AddParam("%%ID_PO%%", id_po);
                  stmt.AddParam("%%CYCLE_MODE%%", mode);
                  stmt.AddParam("%%CYCLE_TYPE%%", cycleTypeId);

                  using (IMTDataReader rdr = stmt.ExecuteReader())
                  {
                    mLogger.LogDebug("Cycle validation query executed");
                    if (rdr.Read())
                    {
                      string name = rdr.GetString(0);
                      mLogger.LogInfo("Usage cycle conflicts with priceable item {0}", name);

                      throw new MASBasicException(string.Format("The usage cycle of priceable item '{0}' conflicts with this priceable item's usage cycle", name));
                    }
                  }
                }
              }
            }
          }
          else
          {
            throw new MASBasicException("Usage cycle not specified for priceable item kind that requires one");
          }
        }
        else
        {
          throw new MASBasicException("Usage cycle property does not exist for priceable item kind that requires one");
        }
      }
    }

    private void UpdateNonRecurringChargePIInstance(NonRecurringChargePIInstance nonRecurringChargePIInstance)
    {
      bool bRunUpdate = false;
      string updateStr = "";

      if (PCConfigManager.IsPropertyOverridable((int)nonRecurringChargePIInstance.PIKind, "EventType"))
      {
        if (nonRecurringChargePIInstance.IsEventTypeDirty)
        {
          bRunUpdate = true;

          updateStr = String.Format("n_event_type = {0}", (int)nonRecurringChargePIInstance.EventType);
        }
      }

      if (bRunUpdate)
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__UPDATE_PIKIND_SPECIFIC_PROPERTIES__"))
          {
            stmt.AddParam("%%TABLE_NAME%%", "t_nonrecur");
            stmt.AddParam("%%UPDATE_VALUES%%", updateStr);
            stmt.AddParam("%%ID_PROP%%", nonRecurringChargePIInstance.ID.Value);

            stmt.ExecuteNonQuery();
          }
        }
      }
    }

    private void UpdateDiscountPIInstance(DiscountPIInstance discountPIInstance)
    {
      bool bRunUpdate = false;
      string updateStr = "";

      if (PCConfigManager.IsPropertyOverridable((int)discountPIInstance.PIKind, "Cycle"))
      {
        if (discountPIInstance.IsCycleDirty)
        {
          bRunUpdate = true;

          string mode;
          int? cycleId, cycleTypeId;
          ResolveUsageCycleInfo(discountPIInstance.Cycle, out mode, out cycleId, out cycleTypeId);

          updateStr = String.Format("id_usage_cycle = {0}, id_cycle_type = {1}", ((cycleId.HasValue) ? cycleId.Value.ToString() : "null"), ((cycleTypeId.HasValue) ? cycleTypeId.Value.ToString() : "null"));
        }
      }

      if (bRunUpdate)
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__UPDATE_PIKIND_SPECIFIC_PROPERTIES__"))
          {
            stmt.AddParam("%%TABLE_NAME%%", "t_discount");
            stmt.AddParam("%%UPDATE_VALUES%%", updateStr);
            stmt.AddParam("%%ID_PROP%%", discountPIInstance.ID.Value);

            stmt.ExecuteNonQuery();
          }
        }
      }
    }

    private void UpdateAggregateChargePIInstance(AggregateChargePIInstance aggregateChargePIInstance)
    {
      bool bRunUpdate = false;
      string updateStr = "";

      if (PCConfigManager.IsPropertyOverridable((int)aggregateChargePIInstance.PIKind, "Cycle"))
      {
        if (aggregateChargePIInstance.IsCycleDirty)
        {
          bRunUpdate = true;


          string mode;
          int? cycleId, cycleTypeId;
          ResolveUsageCycleInfo(aggregateChargePIInstance.Cycle, out mode, out cycleId, out cycleTypeId);

          updateStr = String.Format("id_usage_cycle = {0}, id_cycle_type = {1}", ((cycleId.HasValue) ? cycleId.Value.ToString() : "null"), ((cycleTypeId.HasValue) ? cycleTypeId.Value.ToString() : "null"));

        }
      }

      if (bRunUpdate)
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__UPDATE_PIKIND_SPECIFIC_PROPERTIES__"))
          {
            stmt.AddParam("%%TABLE_NAME%%", "t_aggregate");
            stmt.AddParam("%%UPDATE_VALUES%%", updateStr);
            stmt.AddParam("%%ID_PROP%%", aggregateChargePIInstance.ID.Value);

            stmt.ExecuteNonQuery();
          }
        }
      }
    }

    private void UpdateRecurringChargePIInstance(BaseRecurringChargePIInstance baseRecurringChargePIInstance)
    {
      bool bRunUpdate = false;
      bool bUpdateLocalizedUnitValueNames = false;
      bool bUpdateUnitValueEnumeration = false;
      bool bUpdateUnitValue = false;
      StringBuilder updateStr = new StringBuilder();

      #region Update Cycle
      if (PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePIInstance.PIKind, "Cycle"))
      {
        if (baseRecurringChargePIInstance.IsCycleDirty)
        {
          bRunUpdate = true;

          string mode;
          int? cycleId, cycleTypeId;
          ResolveUsageCycleInfo(baseRecurringChargePIInstance.Cycle, out mode, out cycleId, out cycleTypeId);

          updateStr.Append(String.Format(",id_usage_cycle = {0}, id_cycle_type = {1}", ((cycleId.HasValue) ? cycleId.Value.ToString() : "null"), ((cycleTypeId.HasValue) ? cycleTypeId.Value.ToString() : "null")));
        }
      }
      #endregion

      #region Update FixedProrationLength
      if (PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePIInstance.PIKind, "FixedProrationLength"))
      {
        if (baseRecurringChargePIInstance.IsFixedProrationLengthDirty)
        {
          bRunUpdate = true;

          updateStr.Append(String.Format(",b_fixed_proration_length = '{0}'", (baseRecurringChargePIInstance.FixedProrationLength.Value) ? "Y" : "N"));
        }
      }
      #endregion

      #region Update ProrateOnDeactivation
      if (PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePIInstance.PIKind, "ProrateOnDeactivation"))
      {
        if (baseRecurringChargePIInstance.IsProrateOnDeactivationDirty)
        {
          bRunUpdate = true;

          updateStr.Append(String.Format(",b_prorate_on_deactivate = '{0}'", (baseRecurringChargePIInstance.ProrateOnDeactivation.Value) ? "Y" : "N"));
        }
      }
      #endregion

      #region Update ProrateInstantly
      if (PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePIInstance.PIKind, "ProrateInstantly"))
      {
        if (baseRecurringChargePIInstance.IsProrateInstantlyDirty)
        {
          bRunUpdate = true;

          updateStr.Append(String.Format(",b_prorate_instantly = '{0}'", (baseRecurringChargePIInstance.ProrateInstantly.Value) ? "Y" : "N"));
        }
      }
      #endregion

      #region Update ProrateOnActivation
      if (PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePIInstance.PIKind, "ProrateOnActivation"))
      {
        if (baseRecurringChargePIInstance.IsProrateOnActivationDirty)
        {
          bRunUpdate = true;

          updateStr.Append(String.Format(",b_prorate_on_activate = '{0}'", (baseRecurringChargePIInstance.ProrateOnActivation.Value) ? "Y" : "N"));
        }
      }
      #endregion

      #region Update ChargeAdvance
      if (PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePIInstance.PIKind, "ChargeAdvance"))
      {
        if (baseRecurringChargePIInstance.IsChargeAdvanceDirty)
        {
          bRunUpdate = true;

          updateStr.Append(String.Format(",b_advance = '{0}'", (baseRecurringChargePIInstance.ChargeAdvance.Value) ? "Y" : "N"));
        }
      }
      #endregion

      #region Update ChargePerParticipant
      if (PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePIInstance.PIKind, "ChargePerParticipant"))
      {
        if (baseRecurringChargePIInstance.IsChargePerParticipantDirty)
        {
          bRunUpdate = true;

          updateStr.Append(String.Format(",b_charge_per_participant = '{0}'", (baseRecurringChargePIInstance.ChargePerParticipant.Value) ? "Y" : "N"));
        }
      }
      #endregion

      if (baseRecurringChargePIInstance.GetType().IsSubclassOf(typeof(UnitDependentRecurringChargePIInstance)))
      {
        UnitDependentRecurringChargePIInstance udrcInstance = ((UnitDependentRecurringChargePIInstance)baseRecurringChargePIInstance);

        #region Update UnitDisplayName
        if (PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePIInstance.PIKind, "UnitDisplayName"))
        {
          if (udrcInstance.IsUnitDisplayNameDirty)
          {
            bRunUpdate = true;

            updateStr.Append(String.Format(",nm_unit_display_name = {0}", DatabaseUtils.FormatValueForDB(udrcInstance.UnitDisplayName)));
          }

          if (udrcInstance.IsLocalizedUnitDisplayNamesDirty)
          {
            bUpdateLocalizedUnitValueNames = true;
          }
        }
        #endregion

        #region Update RatingType
        if (PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePIInstance.PIKind, "RatingType"))
        {
          if (udrcInstance.IsRatingTypeDirty)
          {
            bRunUpdate = true;

            updateStr.Append(String.Format(",n_rating_type = {0}", (int)udrcInstance.RatingType));
          }
        }
        #endregion

        #region Update IntegerUnitValue
        if (PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePIInstance.PIKind, "IntegerUnitValue"))
        {
          if (udrcInstance.IsIntegerUnitValueDirty)
          {
            bRunUpdate = true;

            updateStr.Append(String.Format(",b_integral = '{0}'", (udrcInstance.IntegerUnitValue.Value) ? "Y" : "N"));
          }
        }
        #endregion

        #region Update MaxUnitValue
        if (PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePIInstance.PIKind, "MaxUnitValue"))
        {
          if (udrcInstance.IsMaxUnitValueDirty)
          {
            bRunUpdate = true;
            bUpdateUnitValue = true;

            updateStr.Append(String.Format(",max_unit_value = {0}", udrcInstance.MaxUnitValue));
          }
        }
        #endregion

        #region Update MinUnitValue
        if (PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePIInstance.PIKind, "MinUnitValue"))
        {
          if (udrcInstance.IsMinUnitValueDirty)
          {
            bRunUpdate = true;
            bUpdateUnitValue = true;

            updateStr.Append(String.Format(",min_unit_value = {0}", udrcInstance.MinUnitValue));
          }
        }
        #endregion

        #region Check For Updating UnitValueEnumeration
        if (PCConfigManager.IsPropertyOverridable((int)udrcInstance.PIKind, "UnitValueEnumeration"))
        {
          if (udrcInstance.IsAllowedUnitValuesDirty)
          {
            bUpdateUnitValueEnumeration = true;
          }
        }
        #endregion
      }

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        if (bRunUpdate)
        {
          //Remove comma at the beginning
          updateStr.Remove(0, 1);

          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__UPDATE_PIKIND_SPECIFIC_PROPERTIES__"))
          {
            stmt.AddParam("%%TABLE_NAME%%", "t_recur");
            stmt.AddParam("%%UPDATE_VALUES%%", updateStr.ToString(), true); //third parameter added to stop adding comma for every comma in updatestr which is causing sql syntax error.
            stmt.AddParam("%%ID_PROP%%", baseRecurringChargePIInstance.ID.Value);

            stmt.ExecuteNonQuery();
          }
        }

        #region Update Localized UnitName values
        if (bUpdateLocalizedUnitValueNames)
        {
          UnitDependentRecurringChargePIInstance udrcInstance = ((UnitDependentRecurringChargePIInstance)baseRecurringChargePIInstance);

          int n_unit_displayname = -1;
          using (IMTAdapterStatement adapterStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_UNITDISPLAYNAME_DESC_ID_FOR_UDRC_PCWS__"))
          {
            adapterStmt.AddParam("%%ID_PROP%%", udrcInstance.ID.Value);

            using (IMTDataReader rdr = adapterStmt.ExecuteReader())
            {
              if (rdr.Read())
              {
                n_unit_displayname = rdr.GetInt32("n_unit_display_name");
              }
            }
          }


          ProcessLocalizationData(n_unit_displayname,
                                  udrcInstance.LocalizedUnitDisplayNames,
                                  udrcInstance.IsLocalizedUnitDisplayNamesDirty,
                                  null,
                                  null,
                                  false);
        }

        #endregion

        #region Update AllowedUnitValues
        if (bUpdateUnitValueEnumeration)
        {
          UnitDependentRecurringChargePIInstance udrcInstance = ((UnitDependentRecurringChargePIInstance)baseRecurringChargePIInstance);

          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__DELETE_RECURRING_CHARGE_ENUMS_BY_ID_PCWS__"))
          {
            stmt.AddParam("%%ID_PROP%%", udrcInstance.ID.Value);
            stmt.ExecuteNonQuery();
          }

          AddUDRCUnitValues(udrcInstance);
        }
        #endregion

        #region Check for UnitValue violations
        if (bUpdateUnitValue || bUpdateUnitValueEnumeration)
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_UNIT_VALUE_CONSTRAINT_VIOLATIONS_PCWS__"))
          {
            stmt.AddParam("%%TT_MAX%%", MetraTime.Max);

            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
              if (rdr.Read())
              {
                throw new MASBasicException("Specified Unit value constraints invalidate existing subscriptions");
              }
            }
          }
        }
        #endregion
      }
    }

    private BasePriceableItemInstance CreatePIInstance(int poId, int piId)
    {
      BasePriceableItemInstance piInstance = null;

      //Create the instance
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTMultiSelectAdapterStatement stmt = conn.CreateMultiSelectStatement(PCWS_QUERY_FOLDER, "__LOAD_PI_INSTANCE_DETAILS__"))
        {
          stmt.AddParam("%%PO_ID%%", poId);
          stmt.AddParam("%%PI_ID%%", piId);

          stmt.SetResultSetCount(2);

          using (IMTDataReader rdr = stmt.ExecuteReader())
          {
            if (rdr.Read())
            {
              string piName = rdr.GetString("PITypeName");

              try
              {
                piInstance = (BasePriceableItemInstance)RetrieveClassName(piName, "PIInstance");
              }
              catch (Exception e)
              {
                mLogger.LogException(String.Format("Unable to create Priceable Item Instance: {0}", piName), e);
                return null;
              }

              int piKind = rdr.GetOrdinal("PIKind");
              if (!rdr.IsDBNull(piKind))
              {
                piInstance.PIKind = (PriceableItemKinds)rdr.GetInt32(piKind);
              }
              else
              {
                throw new MASBasicException(String.Format("Unable to retrieve priceable item kind for {0}", piInstance.Name));
              }


              switch (piInstance.PIKind)
              {
                case PriceableItemKinds.NonRecurring:
                  PopulatePIInstanceDetails((NonRecurringChargePIInstance)piInstance, rdr);
                  break;
                case PriceableItemKinds.Discount:
                  PopulatePIInstanceDetails((DiscountPIInstance)piInstance, rdr);
                  break;
                case PriceableItemKinds.Recurring:
                  PopulatePIInstanceDetails((BaseRecurringChargePIInstance)piInstance, rdr);
                  break;
                case PriceableItemKinds.UnitDependentRecurring:
                  PopulatePIInstanceDetails((UnitDependentRecurringChargePIInstance)piInstance, rdr);
                  break;
                case PriceableItemKinds.AggregateCharge:
                  PopulatePIInstanceDetails((AggregateChargePIInstance)piInstance, rdr);
                  break;
                default:
                  PopulatePIInstanceDetails(piInstance, rdr);
                  break;
              }
            }
          }

          PopulateExtendedProperties(piInstance, piInstance.ID.Value);

          PopulateLocalizedNamesAndDescriptions(piInstance);

          AddAdjustmentInstances(piInstance);

          GetRateSchedules(poId, piInstance.PITemplate.ID.Value, piInstance);

          //Create children
          stmt.QueryTag = "__GET_PI_INSTANCE_CHILDREN__";
          stmt.AddParam("%%PO_ID%%", poId);
          stmt.AddParam("%%PI_ID%%", piId);

          using (IMTDataReader childRdr = stmt.ExecuteReader())
          {

            if (childRdr != null && childRdr.FieldCount > 0)
            {
              int idxPiId = childRdr.GetOrdinal("PI_ID");
              int idxPropertyName = childRdr.GetOrdinal("PropertyName");

              while (childRdr.Read())
              {
                int childPiId = childRdr.GetInt32(idxPiId);
                string childPropertyName = childRdr.GetValue(idxPropertyName).ToString().Trim();
                childPropertyName = StringUtils.MakeAlphaNumeric(childPropertyName);

                BasePriceableItemInstance childPiInstance = CreatePIInstance(poId, childPiId);

                if (childPiInstance != null)
                {
                  piInstance.SetValue(childPropertyName, childPiInstance);
                }

              }
            }
          }
        }
      }

      return piInstance;
    }

    private bool PopulatePIInstanceDetails(BasePriceableItemInstance pi, IMTDataReader rdr)
    {
      int id = rdr.GetOrdinal("ID");
      int name = rdr.GetOrdinal("Name");
      int displayName = rdr.GetOrdinal("DisplayName");
      int description = rdr.GetOrdinal("Description");
      int piTemplateID = rdr.GetOrdinal("PITemplateID");
      int piTemplate = rdr.GetOrdinal("PITemplateName");
      int parentPIInstance = rdr.GetOrdinal("ParentPIInstanceID");

      if (!rdr.IsDBNull(id))
      {
        pi.ID = rdr.GetInt32(id);
      }
      if (!rdr.IsDBNull(name))
      {
        pi.Name = rdr.GetString(name);
      }
      if (!rdr.IsDBNull(displayName))
      {
        pi.DisplayName = rdr.GetString(displayName);
      }
      if (!rdr.IsDBNull(description))
      {
        pi.Description = rdr.GetString(description);
      }
      if (!rdr.IsDBNull(piTemplateID))
      {
        pi.PITemplate = new PCIdentifier(rdr.GetInt32(piTemplateID));
      }
      if (!rdr.IsDBNull(piTemplate))
      {
        if (pi.PITemplate == null)
        {
          pi.PITemplate = new PCIdentifier(rdr.GetString(piTemplate));
        }
      }
      if (!rdr.IsDBNull(parentPIInstance))
      {
        pi.SetValue("ParentPIInstance", new PCIdentifier(rdr.GetInt32(parentPIInstance)));
      }

      return true;
    }

    private bool PopulatePIInstanceDetails(BaseRecurringChargePIInstance pi, IMTDataReader rdr)
    {
      if (!PopulatePIInstanceDetails((BasePriceableItemInstance)pi, rdr))
      {
        return false;
      }

      int fixedProrationLength = rdr.GetOrdinal("FixedProrationLength");
      int prorateOnDeactivation = rdr.GetOrdinal("ProrateOnDeactivation");
      int prorateOnActivation = rdr.GetOrdinal("ProrateOnActivation");
      int prorateInstantly = rdr.GetOrdinal("ProrateInstantly");
      int chargeInAdvance = rdr.GetOrdinal("ChargeInAdvance");
      int chargePerParticipant = rdr.GetOrdinal("ChargePerParticipant");

      if (!rdr.IsDBNull(fixedProrationLength))
      {
        pi.FixedProrationLength = rdr.GetBoolean(fixedProrationLength);
      }
      if (!rdr.IsDBNull(prorateOnDeactivation))
      {
        pi.ProrateOnDeactivation = rdr.GetBoolean(prorateOnDeactivation);
      }
      if (!rdr.IsDBNull(prorateInstantly))
      {
        pi.ProrateOnDeactivation = rdr.GetBoolean(prorateInstantly);
      }
      if (!rdr.IsDBNull(prorateOnActivation))
      {
        pi.ProrateOnActivation = rdr.GetBoolean(prorateOnActivation);
      }
      if (!rdr.IsDBNull(chargeInAdvance))
      {
        pi.ChargeAdvance = rdr.GetBoolean(chargeInAdvance);
      }
      if (!rdr.IsDBNull(chargePerParticipant))
      {
        pi.ChargePerParticipant = rdr.GetBoolean(chargePerParticipant);
      }


      pi.Cycle = ResolveUsageCycleInfo(rdr);

      return true;
    }

    private bool PopulatePIInstanceDetails(UnitDependentRecurringChargePIInstance pi, IMTDataReader rdr)
    {
      if (!PopulatePIInstanceDetails((BasePriceableItemInstance)pi, rdr))
      {
        return false;
      }

      int unitName = rdr.GetOrdinal("UnitName");
      int unitDisplayName = rdr.GetOrdinal("UnitDisplayName");
      int integerUnitValue = rdr.GetOrdinal("IntegerUnitValue");
      int minUnitValue = rdr.GetOrdinal("MinUnitValue");
      int maxUnitValue = rdr.GetOrdinal("MaxUnitValue");
      int ratingType = rdr.GetOrdinal("RatingType");

      if (!rdr.IsDBNull(unitName))
      {
        pi.UnitName = rdr.GetString(unitName);
      }
      if (!rdr.IsDBNull(unitDisplayName))
      {
        pi.UnitDisplayName = rdr.GetString(unitDisplayName);
      }
      if (!rdr.IsDBNull(integerUnitValue))
      {
        pi.IntegerUnitValue = rdr.GetBoolean(integerUnitValue);
      }
      if (!rdr.IsDBNull(minUnitValue))
      {
        pi.MinUnitValue = rdr.GetDecimal(minUnitValue);
      }
      if (!rdr.IsDBNull(maxUnitValue))
      {
        pi.MaxUnitValue = rdr.GetDecimal(maxUnitValue);
      }
      if (!rdr.IsDBNull(ratingType))
      {
        pi.RatingType = (UDRCRatingType)rdr.GetInt32(ratingType);
      }

      if (rdr.NextResult())
      {
        if (rdr.FieldCount > 0)
        {
          int idxAllowdUnitValue = rdr.GetOrdinal("AllowedUnitValue");

          while (rdr.Read())
          {
            decimal allowedUnitValue = rdr.GetDecimal(idxAllowdUnitValue);
            pi.AllowedUnitValues.Add(allowedUnitValue);
          }
        }
      }

      return true;
    }

    private bool PopulatePIInstanceDetails(DiscountPIInstance pi, IMTDataReader rdr)
    {
      if (!PopulatePIInstanceDetails((BasePriceableItemInstance)pi, rdr))
      {
        return false;
      }

      ExtendedUsageCycleInfo usageCycleInfo = ResolveUsageCycleInfo(rdr);

      if (usageCycleInfo != null && usageCycleInfo is UsageCycleInfo)
      {
        pi.Cycle = (UsageCycleInfo)usageCycleInfo;
      }
      else
      {
        mLogger.LogError(String.Format("{0} could not resolve usage cycle.", pi.Name));
      }


      return true;
    }

    private bool PopulatePIInstanceDetails(NonRecurringChargePIInstance pi, IMTDataReader rdr)
    {
      if (!PopulatePIInstanceDetails((BasePriceableItemInstance)pi, rdr))
      {
        return false;
      }

      int eventType = rdr.GetOrdinal("EventType");

      if (!rdr.IsDBNull(eventType))
      {
        pi.EventType = (NonRecurringChargeEvents)rdr.GetInt32(eventType);
      }

      return true;
    }

    private bool PopulatePIInstanceDetails(AggregateChargePIInstance pi, IMTDataReader rdr)
    {
      if (!PopulatePIInstanceDetails((BasePriceableItemInstance)pi, rdr))
      {
        return false;
      }

      ExtendedUsageCycleInfo usageCycleInfo = ResolveUsageCycleInfo(rdr);

      if (usageCycleInfo != null && usageCycleInfo is UsageCycleInfo)
      {
        pi.Cycle = (UsageCycleInfo)usageCycleInfo;
      }
      else
      {
        mLogger.LogError(String.Format("{0} could not resolve usage cycle.", pi.Name));
      }


      return true;
    }

    private void AddAdjustmentInstances(BasePriceableItemInstance pi)
    {
      //Add Adjustments
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__LOAD_ADJUSTMENT_INSTANCES__"))
        {
          stmt.AddParam("%%PI_ID%%", pi.ID);

          using (IMTDataReader rdr = stmt.ExecuteReader())
          {
            if (rdr != null && rdr.FieldCount > 0)
            {
              int idxID = rdr.GetOrdinal("ID");
              int idxName = rdr.GetOrdinal("Name");
              int idxDisplayName = rdr.GetOrdinal("DisplayName");
              int idxLanguageCode = rdr.GetOrdinal("LanguageCode");
              int idxLocalizedDisplayName = rdr.GetOrdinal("tx_desc");

              int currentId = -1;
              AdjustmentInstance adjustment = null;
              while (rdr.Read())
              {
                int id = rdr.GetInt32(idxID);
                if (id != currentId)
                {
                  currentId = id;
                  string name = rdr.GetString(idxName);
                  string displayName = rdr.GetString(idxDisplayName);

                  adjustment = new AdjustmentInstance();
                  adjustment.ID = id;
                  adjustment.Name = name;
                  adjustment.DisplayName = rdr.GetString(idxDisplayName);

                  string piPropertyName = StringUtils.MakeAlphaNumeric(name);

                  if (pi.GetProperty(piPropertyName) != null)
                  {
                    pi.SetValue(piPropertyName, adjustment);
                  }
                }

                if (!rdr.IsDBNull(idxLanguageCode))
                {
                  int languageCode = rdr.GetInt32(idxLanguageCode);
                  LanguageCode lCode = (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), languageCode.ToString());
                  string localizedDisplayName = (!rdr.IsDBNull(idxLocalizedDisplayName)) ? rdr.GetString(idxLocalizedDisplayName) : null;

                  if (adjustment.LocalizedDescriptions == null)
                  {
                    adjustment.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
                  }
                  adjustment.LocalizedDisplayNames.Add(lCode, localizedDisplayName);
                }

              }
            }
          }
        }
      }
    }

    private ExtendedUsageCycleInfo ResolveUsageCycleInfo(IMTDataReader rdr)
    {
      ExtendedUsageCycleInfo info = null;
      int idxUsageCycleId = rdr.GetOrdinal("UsageCycleID");
      int idxUsageCycleType = rdr.GetOrdinal("UsageCycleType");
      int idxRelativeCycleType = rdr.GetOrdinal("RelativeCycleType");

      int idxDayOfMonth = rdr.GetOrdinal("DayOfMonth");
      int idxDayOfWeek = rdr.GetOrdinal("DayOfWeek");
      int idxFirstDayOfMonth = rdr.GetOrdinal("FirstDayOfMonth");
      int idxSecondDayOfMonth = rdr.GetOrdinal("SecondDayOfMonth");
      int idxStartDay = rdr.GetOrdinal("StartDay");
      int idxStartMonth = rdr.GetOrdinal("StartMonth");
      int idxStartYear = rdr.GetOrdinal("StartYear");

      int idxCycleMode = rdr.GetOrdinal("CycleMode");

      // id_usage_cycle | id_cycle_type
      if (!rdr.IsDBNull(idxUsageCycleType)) //       X        |    NULL
      {
        #region Fixed Usage Cycle
        //It's a fixed usage cycle
        int usageCycleType = rdr.GetInt32(idxUsageCycleType);

        if (!Enum.IsDefined(typeof(CycleType), usageCycleType))
        {
          mLogger.LogError(String.Format("CycleType {0} is not in range", usageCycleType));
          return null;
        }

        CycleType cycleType = (CycleType)usageCycleType;

        switch (cycleType)
        {
          case CycleType.Annually:
            {
              info = new AnnualUsageCycleInfo();
              if (!rdr.IsDBNull(idxStartDay))
              {
                ((AnnualUsageCycleInfo)info).StartDay = rdr.GetInt32(idxStartDay);
              }
              if (!rdr.IsDBNull(idxStartMonth))
              {
                ((AnnualUsageCycleInfo)info).StartMonth = rdr.GetInt32(idxStartMonth);
              }
              break;
            }
          case CycleType.Semi_Annually:
            {
              info = new SemiAnnualUsageCycleInfo();
              if (!rdr.IsDBNull(idxStartDay))
              {
                ((SemiAnnualUsageCycleInfo)info).StartDay = rdr.GetInt32(idxStartDay);
              }
              if (!rdr.IsDBNull(idxStartMonth))
              {
                ((SemiAnnualUsageCycleInfo)info).StartMonth = rdr.GetInt32(idxStartMonth);
              }
              break;
            }

          case CycleType.Bi_Weekly:
            {
              info = new BiWeeklyUsageCycleInfo();
              if (!rdr.IsDBNull(idxStartDay))
              {
                ((BiWeeklyUsageCycleInfo)info).StartDay = rdr.GetInt32(idxStartDay);
              }
              if (!rdr.IsDBNull(idxStartMonth))
              {
                ((BiWeeklyUsageCycleInfo)info).StartMonth = rdr.GetInt32(idxStartMonth);
              }
              if (!rdr.IsDBNull(idxStartYear))
              {
                ((BiWeeklyUsageCycleInfo)info).StartYear = rdr.GetInt32(idxStartYear);
              }
              break;
            }
          case CycleType.Daily:
            {
              info = new DailyUsageCycleInfo();
              break;
            }
          case CycleType.Monthly:
            {
              info = new MonthlyUsageCycleInfo();
              if (!rdr.IsDBNull(idxDayOfMonth))
              {
                ((MonthlyUsageCycleInfo)info).EndDay = rdr.GetInt32(idxDayOfMonth);
              }
              break;
            }
          case CycleType.Quarterly:
            {
              info = new QuarterlyUsageCycleInfo();
              if (!rdr.IsDBNull(idxStartDay))
              {
                ((QuarterlyUsageCycleInfo)info).StartDay = rdr.GetInt32(idxStartDay);
              }
              if (!rdr.IsDBNull(idxStartMonth))
              {
                ((QuarterlyUsageCycleInfo)info).StartMonth = rdr.GetInt32(idxStartMonth);
              }
              break;
            }
          case CycleType.Semi_Monthly:
            {
              info = new SemiMonthlyUsageCycleInfo();
              if (!rdr.IsDBNull(idxFirstDayOfMonth))
              {
                ((SemiMonthlyUsageCycleInfo)info).Day1 = rdr.GetInt32(idxFirstDayOfMonth);
              }
              if (!rdr.IsDBNull(idxSecondDayOfMonth))
              {
                ((SemiMonthlyUsageCycleInfo)info).Day2 = rdr.GetInt32(idxSecondDayOfMonth);
              }
              break;
            }
          case CycleType.Weekly:
            {
              info = new WeeklyUsageCycyleInfo();
              if (!rdr.IsDBNull(idxDayOfWeek))
              {
                ((WeeklyUsageCycyleInfo)info).DayOfWeek = (DayOfWeek)rdr.GetInt32(idxDayOfWeek);
              }
              break;
            }
          default:
            {
              mLogger.LogError("Unrecognized Usage Cycle Type");
              break;
            }
        }
        #endregion Fixed Usage Cycle
      }
      else if (!rdr.IsDBNull(idxRelativeCycleType)) // NULL | X
      {
        #region BCR Constained or Extended BCR

        if (!rdr.IsDBNull(idxCycleMode))
        {

          //Constrained or Extended. Find out which.
          string cycleMode = rdr.GetString(idxCycleMode);
          cycleMode = cycleMode.Trim();
          if (String.Compare(cycleMode, "EBCR", true) == 0)
          {
            info = new ExtendedRelativeUsageCycleInfo();

            ((ExtendedRelativeUsageCycleInfo)info).ExtendedUsageCycle = (ExtendedCycleType)rdr.GetInt32(idxRelativeCycleType);
          }
          else if (String.Compare(cycleMode, "BCR Constrained", true) == 0)
          {
            info = new RelativeUsageCycleInfo();

            ((RelativeUsageCycleInfo)info).UsageCycleType = (CycleType)rdr.GetInt32(idxRelativeCycleType);

          }
          else
          {
            mLogger.LogError("Unrecognized Usage Cycle Mode: " + cycleMode);
          }

        }
        else // NULL | X  (Mode is NULL)
        {
          // BCR Constrained (for Discount or Aggregate)

          info = new RelativeUsageCycleInfo();

          ((RelativeUsageCycleInfo)info).UsageCycleType = (CycleType)rdr.GetInt32(idxRelativeCycleType);
        }

        #endregion BCR Constained or Extended BCR
      }
      else                                          // NULL | NULL
      {
        #region Relative Usage Cycle (BCR - no constraint)

        //It's a Relative Usage Cycle (BCR - Same as user's billing cycle, no constraint)

        info = new RelativeUsageCycleInfo();

        #endregion Relative Usage Cycle (BCR - no constraint)
      }

      return info;
    }

    private void GetRateSchedules(int id_po, int piTemplateID, BasePriceableItemInstance piInstance)
    {
      try
      {
        List<PropertyInfo> properties = piInstance.GetProperties();

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_RSCHED__"))
          {

            foreach (PropertyInfo prop in properties)
            {
              object[] attribs = prop.GetCustomAttributes(typeof(MTRateSchedulesPropertyAttribute), true);
              if (attribs.Length > 0)
              {
                #region Instantiate the list of rate schedules

                //List<RateSchedule<_R_, _D_>>
                Type rateScheduleListType = prop.PropertyType;

                //piInstance.XXXX_RateSchecules = new List<RateSchedule<_R_, _D_>>
                IList rateScheduleList = (IList)System.Activator.CreateInstance(prop.PropertyType);
                prop.SetValue(piInstance, rateScheduleList, null);

                #endregion Instantiate the list of rate schedules

                #region Add Rate Schedules to the list

                //RateSchedule<_R_, _D_>
                Type[] rateScheduleTypeArray = rateScheduleListType.GetGenericArguments();
                Type rateScheduleType = rateScheduleTypeArray[0];


                string ptName = ((MTRateSchedulesPropertyAttribute)attribs[0]).ParameterTable;


                stmt.AddParam("%%ID_PI%%", piInstance.ID);
                stmt.AddParam("%%ID_TMPL%%", piTemplateID);
                stmt.AddParam("%%ID_PO%%", id_po);
                stmt.AddParam("%%ID_PT%%", CacheManager.ParamTableNameToIdMap[ptName.ToUpper()].ID);

                using (IMTDataReader rdr = stmt.ExecuteReader())
                {
                  if (rdr != null && rdr.FieldCount > 0)
                  {
                    int idxID = rdr.GetOrdinal("ID");
                    //int idxPriceListID = rdr.GetOrdinal("PriceListID");
                    int idxParameterTableID = rdr.GetOrdinal("ParameterTableID");
                    int idxEffeciveDate = rdr.GetOrdinal("EffectiveDate");
                    int idxDescription = rdr.GetOrdinal("Description");

                    while (rdr.Read())
                    {
                      //piInstance.XXXX_RateSchecules.Add(new RateSchedule<_R_, _D_>)
                      BaseRateSchedule rateSchedule = (BaseRateSchedule)System.Activator.CreateInstance(rateScheduleType);
                      rateScheduleList.Add(rateSchedule);

                      rateSchedule.ParameterTableName = ptName;

                      if (!rdr.IsDBNull(idxID))
                      {
                        rateSchedule.ID = rdr.GetInt32(idxID);
                      }
                      if (!rdr.IsDBNull(idxParameterTableID))
                      {
                        rateSchedule.ParameterTableID = rdr.GetInt32(idxParameterTableID);
                      }
                      if (!rdr.IsDBNull(idxEffeciveDate))
                      {
                        rateSchedule.EffectiveDate = new ProdCatTimeSpan();
                        rateSchedule.EffectiveDate.TimeSpanId = rdr.GetInt32(idxEffeciveDate);
                      }
                      if (!rdr.IsDBNull(idxDescription))
                      {
                        rateSchedule.Description = rdr.GetString(idxDescription);
                      }

                      #region Add Rates to the Rate Schedule

                      PopulateRateEntries(rateSchedule.ParameterTableID, rateSchedule);

                      #endregion Add Rates to the Rate Schedule

                    }
                  }
                }

                stmt.ClearQuery();

                #endregion Add Rate Schedules to the list
              }
            }
          }
        }

      }
      catch (MASBasicException masE)
      {
        throw masE;
      }
      catch (Exception e)
      {
        mLogger.LogException(String.Format("Unknown error retrieving rate schedules for {0}", piInstance.Name), e);

        throw new MASBasicException(String.Format("Error retrieving rate schedules for {0}", piInstance.Name));
      }
    }

    private void PopulateRateEntries(int tableID, BaseRateSchedule rateSchedule)
    {
      Type rateScheduleType = rateSchedule.GetType();
      PropertyInfo propRateEntries = rateScheduleType.GetProperty("RateEntries");
      IList list = (IList)propRateEntries.GetValue(rateSchedule, null);
      Type[] genericArgs = rateScheduleType.GetGenericArguments();
      Type rateEntryType = genericArgs[0];
      Type defaultRateEntryType = genericArgs[1];

      try
      {

        string columns = "";

        PropertyInfo[] rateEntryProperties = rateEntryType.GetProperties();

        foreach (PropertyInfo rateEntryProp in rateEntryProperties)
        {
          object[] rateEntryAttribs = rateEntryProp.GetCustomAttributes(typeof(MTRateEntryMetadataAttribute), false);
          if (rateEntryAttribs.Length > 0)
          {
            columns += string.Format(", c_{0}", ((MTRateEntryMetadataAttribute)rateEntryAttribs[0]).ColumnName);
          }
        }

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_RATES__"))
          {
            if (!String.IsNullOrEmpty(columns))
            {
              stmt.AddParam("%%COLUMNS%%", columns);
            }

            stmt.AddParam("%%TABLE_NAME%%", CacheManager.ParamTableIdToNameMap[tableID].TableName);
            stmt.AddParam("%%ID_SCHED%%", rateSchedule.ID.Value);

            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
              if (rdr != null && rdr.FieldCount > 0)
              {
                while (rdr.Read())
                {
                  bool bIsDefaultRateEntry = false;
                  RateEntry rateEntry = GetRateEntry(rateEntryType, defaultRateEntryType, rateEntryProperties, rdr, out bIsDefaultRateEntry);
                  if (bIsDefaultRateEntry)
                  {
                    rateSchedule.GetProperty("DefaultRateEntry").SetValue(rateSchedule, rateEntry, null);
                  }
                  else
                  {
                    list.Add(rateEntry);
                  }
                }
              }
            }
          }
        }
      }
      catch (MASBasicException masE)
      {
        throw masE;
      }
      catch (Exception e)
      {
        mLogger.LogException(String.Format("Unknown error retrieving rates for {0}", rateEntryType.ToString()), e);

        throw new MASBasicException(String.Format("Error retrieving rates for {0}", rateEntryType.ToString()));
      }
    }

    #endregion

  }
}
