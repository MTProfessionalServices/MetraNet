using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Text;
using System.Threading;
using System.Transactions;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.MTAuditEvents;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.Core.Services
{
  [ServiceContract]
  public interface ISpecificationsService
  {
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetSpecificationCharacteristicsForEntity(int entityId, ref MTList<SpecificationCharacteristic> specs);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SaveSpecificationCharacteristicForEntity(int entityId, EntityType entityType, SpecificationCharacteristic spec);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SaveOrMapSpecificationCharacteristicForEntity(int entityId, EntityType entityType, SpecificationCharacteristic spec);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SaveSpecificationCharacteristic(ref SpecificationCharacteristic spec);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetSpecificationCharacteristic(int id, out SpecificationCharacteristic spec);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetSpecificationCharacteristics(ref MTList<SpecificationCharacteristic> specs);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void RemoveSpecificationCharacteristicFromEntity(int specId, int entityId);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteSpecificationCharacteristic(int specId);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void AddSpecCharValsToSpecificationCharacteristic(int specId, List<int> valueIds);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void RemoveSpecCharValsFromSpecificationCharacteristic(int specId, List<int> valueIds, int? entityId);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetSpecCharacteristicValuesForSpec(int specId, ref MTList<SpecCharacteristicValue> vals);


  }

  [ServiceBehavior(InstanceContextMode = InstanceContextMode.Single, ConcurrencyMode = ConcurrencyMode.Multiple)]
  public class SpecificationsService : BasePCWebService, ISpecificationsService
  {

    #region private members
    private static Logger mLogger = new Logger("[SpecificationsService]");
    Auditor auditor = new Auditor();
    #endregion

    #region ISpecificationsService members

    /// <summary>
    /// This method will save specification characteristics for an entity.
    /// </summary>
    /// <param name="entityId"></param>
    /// <param name="entityType"></param>
    /// <param name="spec"></param>
    [OperationCapability("Manage Specification Characteristics")]
    public void SaveSpecificationCharacteristicForEntity(int entityId, EntityType entityType, SpecificationCharacteristic spec)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("SaveSpecificationCharacteristicForEntity"))
      {
        var resourceManager = new ResourcesManager();
        if (spec.ID.HasValue)
        {
          MTList<SpecificationCharacteristic> specs = new MTList<SpecificationCharacteristic>();
          GetSpecificationCharacteristicsForEntity(entityId, ref specs);

          // check to see if we have the mapping and add it if we do not
          SpecificationCharacteristic s = specs.Items.Find(s1 => s1.ID.Value == spec.ID.Value);
          SaveSpecificationCharacteristicInternal(ref spec, entityId);
          if (s == null)
          {
            AddSpecToEntity(entityId, entityType, spec);
          }
          else
          {
            if (spec.DisplayOrder.HasValue)
            {
              UpdateDisplayOrder(entityId, spec.ID.Value, spec.DisplayOrder.Value);
            }
          }
        }
        else
        {
          try
          {
            using (
              TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(),
                                                            EnterpriseServicesInteropOption.Full))
            {
              mLogger.LogDebug("TXN ISOLATION LEVEL IN SaveSpecificationCharacteristicForEntity" +
                               Transaction.Current.IsolationLevel.ToString());
              SaveSpecificationCharacteristic(ref spec);
              AddSpecToEntity(entityId, entityType, spec);
              scope.Complete();
            }
          }
          catch (MASBasicException masE)
          {
            mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_MAS_BASE_SAVING_SPECS_TO_ENTITY"), masE);

            throw masE;
          }
          catch (Exception e)
          {
            mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_EXCEPTION_SAVING_SPECS_TO_ENTITY"), e);
            throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_REVIEW_LOGS"));
          }
        }
      }
    }

    /// <summary>
    /// This method will save specification characteristics for an entity in case there is no such spec with the same name, category and description, otherwise - map it to the entity.
    /// </summary>
    /// <param name="entityId"></param>
    /// <param name="entityType"></param>
    /// <param name="spec"></param>
    [OperationCapability("Manage Specification Characteristics")]
    public void SaveOrMapSpecificationCharacteristicForEntity(int entityId, EntityType entityType, SpecificationCharacteristic spec)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("SaveOrMapSpecificationCharacteristicForEntity"))
      {
        var resourceManager = new ResourcesManager();
        var specId = GetSpecificationId(spec);
        if (specId == -1)
          SaveSpecificationCharacteristicForEntity(entityId, entityType, spec);
        else
        {
          try
          {
            using (
              var scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(),
                                                            EnterpriseServicesInteropOption.Full))
            {
              mLogger.LogDebug("TXN ISOLATION LEVEL IN SaveSpecificationCharacteristicForEntity" +
                               Transaction.Current.IsolationLevel.ToString());
              spec.ID = specId;
              AddSpecToEntity(entityId, entityType, spec);
              scope.Complete();
            }
          }
          catch (MASBasicException masE)
          {
            mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_MAS_BASE_SAVING_SPECS_TO_ENTITY"), masE);

            throw masE;
          }
          catch (Exception e)
          {
            mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_EXCEPTION_SAVING_SPECS_TO_ENTITY"), e);
            throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_REVIEW_LOGS"));
          }
        }
      }
    }

    [OperationCapability("Manage Specification Characteristics")]
    public void SaveSpecificationCharacteristic(ref SpecificationCharacteristic spec)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("SaveSpecificationCharacteristic"))
      {
        SaveSpecificationCharacteristicInternal(ref spec, null);
      }
    }

    /// <summary>
    /// This method will get the specification characteristics and take into account any paging, filtering, or sorting
    /// that are set on the list.
    /// </summary>
    /// <param name="specs">MTList that can set paging, filtering, or sorting.</param>
    public void GetSpecificationCharacteristics(ref MTList<SpecificationCharacteristic> specs)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetSpecificationCharacteristics"))
      {
        var resourceManager = new ResourcesManager();
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
          {
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("Queries\\PCWS", "__GET_SPECS__"))
            {
              ApplyFilterSortCriteria<SpecificationCharacteristic>(stmt, specs);
              using (IMTDataReader dataReader = stmt.ExecuteReader())
              {
                while (dataReader.Read())
                {
                  // TODO Localization
                  SpecificationCharacteristic spec = new SpecificationCharacteristic();
                  spec.ID = dataReader.GetInt32("ID");
                  PropertyType specType = (PropertyType)EnumHelper.GetEnumByValue(typeof(PropertyType), dataReader.GetInt32("SpecType").ToString());
                  spec.SpecType = specType;
                  spec.Category = dataReader.GetString("Category");
                  spec.IsRequired = dataReader.GetBoolean("IsRequired");
                  spec.Description = dataReader.GetString("Description");
                  spec.Name = dataReader.GetString("Name");
                  spec.UserVisible = dataReader.GetBoolean("UserVisible");
                  spec.UserEditable = dataReader.GetBoolean("UserEditable");
                  specs.Items.Add(spec);
                }
              }
              specs.TotalRows = stmt.TotalRows;
            }
          }

          mLogger.LogDebug(String.Format("{0} {1}", specs.TotalRows, resourceManager.GetLocalizedResource("TEXT_RETRIEVED")));
        }
        catch (CommunicationException e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SPECS"), e);
          throw;
        }

        catch (Exception e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SPECS"), e);
          throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SPECS"));
        }
      }
    }

    public void GetSpecificationCharacteristic(int id, out SpecificationCharacteristic spec)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetSpecificationCharacteristic"))
      {
        spec = null;
        string categoryId = "";
        string displayNameId = "";
        string descId = "";
        var resourceManager = new ResourcesManager();
        mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVING_SPEC"));
        using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS`"))
        {
          using (
            IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\PCWS", "__GET_SPECIFICATION_CHARACTERISTIC__")
            )
          {
            stmt.AddParam("%%ID_SPEC%%", id);
            using (IMTDataReader dataReader = stmt.ExecuteReader())
            {
              while (dataReader.Read())
              {
                // TODO Localization
                spec = new SpecificationCharacteristic();
                spec.ID = dataReader.GetInt32("ID");
                PropertyType specType =
                  (PropertyType)
                  EnumHelper.GetEnumByValue(typeof(PropertyType), dataReader.GetInt32("SpecType").ToString());
                spec.SpecType = specType;
                categoryId = dataReader.GetInt32("CategoryId").ToString();
                spec.Category = dataReader.GetString("Category");
                spec.IsRequired = dataReader.GetBoolean("IsRequired");
                descId = dataReader.GetInt32("DescId").ToString();
                spec.Description = dataReader.GetString("Description");
                displayNameId = dataReader.GetInt32("NameId").ToString();
                spec.Name = dataReader.GetString("Name");
                spec.UserVisible = dataReader.GetBoolean("UserVisible");
                spec.UserEditable = dataReader.GetBoolean("UserEditable");
                spec.MinValue = dataReader.IsDBNull("MinValue") ? null : dataReader.GetString("MinValue");
                spec.MaxValue = dataReader.IsDBNull("MaxValue") ? null : dataReader.GetString("MaxValue");
              }

            }
          }
          mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVING_LOCALE"));
          spec.CategoryDisplayNames = new Dictionary<LanguageCode, string>();
          spec.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
          spec.LocalizedDescriptions = new Dictionary<LanguageCode, string>();
          using (
            IMTMultiSelectAdapterStatement localStmt = conn.CreateMultiSelectStatement("Queries\\PCWS",
                                                                                       "__GET_SPEC_LOCALIZATION__"))
          {
            localStmt.AddParam("%%ID_CATEGORY%%", categoryId);
            localStmt.AddParam("%%ID_DISPLAY_NAME%%", displayNameId);
            localStmt.AddParam("%%ID_DESCRIPTION%%", descId);
            localStmt.SetResultSetCount(3);

            using (IMTDataReader rdr = localStmt.ExecuteReader())
            {
              while (rdr.Read())
              {
                LanguageCode langCode = (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), rdr.GetInt32("LanguageCode").ToString());
                spec.CategoryDisplayNames.Add(langCode, (!rdr.IsDBNull("CategoryDescription")) ? rdr.GetString("CategoryDescription") : null);
              }
              rdr.NextResult();
              while (rdr.Read())
              {
                LanguageCode langCode = (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), rdr.GetInt32("LanguageCode").ToString());
                spec.LocalizedDisplayNames.Add(langCode, (!rdr.IsDBNull("DisplayNameDescription")) ? rdr.GetString("DisplayNameDescription") : null);
              }
              rdr.NextResult();
              while (rdr.Read())
              {
                LanguageCode langCode = (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), rdr.GetInt32("LanguageCode").ToString());
                spec.LocalizedDescriptions.Add(langCode, (!rdr.IsDBNull("Description")) ? rdr.GetString("Description") : null);
              }
            }
          }
          mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVED_LOCALE"));
        }
        if (spec == null)
          throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_UNABLE_TO_RETRIEVE_SPEC"));

        MTList<SpecCharacteristicValue> vals = new MTList<SpecCharacteristicValue>();
        mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVING_SPEC_CHAR_VALS"));
        GetSpecCharacteristicValuesForSpec(spec.ID.Value, ref vals);
        spec.SpecCharacteristicValues = vals.Items;
        mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVED_SPEC_CHAR_VALS"));
      }
    }

    public void GetSpecCharacteristicValuesForSpec(int specId, ref MTList<SpecCharacteristicValue> vals)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetSpecCharacteristicValuesForSpec"))
      {
        var resourceManager = new ResourcesManager();
        try
        {
          mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVING_SPEC_CHAR_VALS"));
          using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
          {
            string valueIds = "";
            Dictionary<int, SpecCharacteristicValue> valDictionary = new Dictionary<int, SpecCharacteristicValue>();
            using (
              IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("Queries\\PCWS",
                                                                           "__GET_SPEC_CHAR_VALS_FOR_SPEC__"))
            {
              ApplyFilterSortCriteria<SpecCharacteristicValue>(stmt, vals);
              stmt.AddParam("%%ID_SPEC%%", specId);
              using (IMTDataReader dataReader = stmt.ExecuteReader())
              {
                while (dataReader.Read())
                {
                  // TODO Localization
                  SpecCharacteristicValue val = new SpecCharacteristicValue();
                  int id = dataReader.GetInt32("ID");
                  val.ID = id;
                  val.IsDefault = dataReader.GetBoolean("IsDefault");
                  val.ValueID = dataReader.GetInt32("ValueId");
                  val.Value = dataReader.GetString("Value");
                  valDictionary.Add(id, val);
                  vals.Items.Add(val);
                }
              }

              GetLocalizationDetialsForSpecs(valueIds, conn, valDictionary);
              vals.TotalRows = stmt.TotalRows;
            }
            mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVED_SPEC_CHAR_VALS"));
          }
        }
        catch (CommunicationException e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SPEC_VALS"), e);
          throw;
        }

        catch (Exception e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SPEC_VALS"), e);
          throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SPEC_VALS"));
        }
      }
    }

    /// <summary>
    /// This method will delete a specification characteristic from an entity.
    /// </summary>
    /// <param name="specId">The specification characteristic id.</param>
    /// <param name="entityId">The entity id.</param>
    [OperationCapability("Manage Specification Characteristics")]
    public void RemoveSpecificationCharacteristicFromEntity(int specId, int entityId)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("RemoveSpecificationCharacteristicFromEntity"))
      {
        var resourceManager = new ResourcesManager();
        try
        {
          mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_REMOVING_SPEC_FROM_ENTITY"));
          using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(),
                                                               EnterpriseServicesInteropOption.Full))
          {
            using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
            {
              using (IMTAdapterStatement checkSpecStmt = conn.CreateAdapterStatement("Queries\\PCWS", "__CHECK_SPEC_ON_ENTITY__"))
              {
                checkSpecStmt.AddParam("%%ID_SPEC%%", specId);
                checkSpecStmt.AddParam("%%ID_ENTITY%%", entityId);
                using (IMTDataReader rdr = checkSpecStmt.ExecuteReader())
                {
                  while (rdr.Read())
                  {
                    int count = rdr.GetInt32("NumVals");
                    if (count != 0)
                      throw new MASBasicException(
                        resourceManager.GetLocalizedResource("TEXT_UNABLE_TO_REMOVE_SPEC_FROM_ENTITY"));
                  }
                }
              }
              using (
                IMTAdapterStatement deleteSpecStmt = conn.CreateAdapterStatement("queries\\PCWS",
                                                                                 "__REMOVE_SPEC_FROM_ENTITY__"))
              {
                // TODO: How do we set the id on a spec?
                deleteSpecStmt.AddParam("%%ID_SPEC%%", specId);
                deleteSpecStmt.AddParam("%%ID_ENTITY%%", entityId);
                deleteSpecStmt.ExecuteNonQuery();
              }
            }
            scope.Complete();
          }
          auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_REMOVE_SPEC_FROM_ENTITY, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, entityId,
  resourceManager.GetLocalizedResource("TEXT_REMOVED_SPEC_FROM_ENTITY"));
        }

        catch (MASBasicException masE)
        {

          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_UNABLE_TO_REMOVE_SPEC_FROM_ENTITY"), masE);
          throw masE;
        }
        catch (Exception e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_UNABLE_TO_REMOVE_SPEC_FROM_ENTITY"), e);
          throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_REVIEW_LOGS"));
        }
      }
    }

    /// <summary>
    /// This method will delete a specification characteristic from the system if it is not associated with an entity.  
    /// As a part of this process, the details will be removec as well.
    /// </summary>
    /// <param name="specId">The specification characteristic id.</param>
    [OperationCapability("Manage Specification Characteristics")]
    public void DeleteSpecificationCharacteristic(int specId)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DeleteSpecificationCharacteristic"))
      {
        var resourceManager = new ResourcesManager();
        try
        {
          mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_DELETING_SPEC"));
          using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(),
                                                               EnterpriseServicesInteropOption.Full))
          {
            bool specInUse = false;
            int categoryId = -1;
            int nameId = -1;
            int descId = -1;

            using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
            {
              // check to see if this spec is associated with an entity
              using (IMTAdapterStatement checkSpecStmt = conn.CreateAdapterStatement("queries\\PCWS", "__CHECK_IF_SPEC_IS_USED__"))
              {
                // TODO: How do we set the id on a spec?
                checkSpecStmt.AddParam("%%ID_SPEC%%", specId);
                checkSpecStmt.ExecuteNonQuery();

                using (IMTDataReader specReader = checkSpecStmt.ExecuteReader())
                  while (specReader.Read())
                  {
                    int numSpecs = specReader.GetInt32("NumSpec");
                    if (numSpecs != 0)
                    {
                      specInUse = true;
                      break;
                    }
                    categoryId = specReader.GetInt32("CategoryId");
                    nameId = specReader.GetInt32("NameId");
                    descId = specReader.GetInt32("DescId");
                  }

                if (specInUse)
                  throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_CANOT_DELETE_SPEC_IN_USE"));

                using (
                  IMTAdapterStatement deleteSpecStmt = conn.CreateAdapterStatement("queries\\PCWS",
                                                                                   "__DELETE_SPEC_AND_MAP_DETAILS__"))
                {
                  deleteSpecStmt.AddParam("%%ID_CATEGORY%%", categoryId);
                  deleteSpecStmt.AddParam("%%ID_DISPLAY_NAME%%", nameId);
                  deleteSpecStmt.AddParam("%%ID_DESC%%", descId);
                  deleteSpecStmt.AddParam("%%ID_SPEC%%", specId);
                  deleteSpecStmt.ExecuteNonQuery();
                }
              }

            }
            scope.Complete();
          }
          auditor.FireEvent((int)MTAuditEvent.AUDITEEVENT_DELETE_SPEC_CHAR, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
       resourceManager.GetLocalizedResource("TEXT_DELETED_SPEC"));
        }
        catch (MASBasicException masE)
        {
          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEEVENT_DELETE_SPEC_CHAR_FAILED, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
          resourceManager.GetLocalizedResource("TEXT_COULD_NOT_DELETE_SPEC"));
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_COULD_NOT_DELETE_SPEC"), masE);
          throw masE;
        }
        catch (Exception e)
        {
          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEEVENT_DELETE_SPEC_CHAR_FAILED, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
          resourceManager.GetLocalizedResource("TEXT_COULD_NOT_DELETE_SPEC"));
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_COULD_NOT_DELETE_SPEC"), e);
          throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_REVIEW_LOGS"));
        }
      }
    }

    public void GetSpecificationCharacteristicsForEntity(int entityId, ref MTList<SpecificationCharacteristic> specs)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetSpecificationCharacteristicsForEntity"))
      {
        var resourceManager = new ResourcesManager();
        try
        {
          mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVING_SPECS_FOR_ENTITY"));
          using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
          {
            using (
              IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("Queries\\PCWS", "__GET_SPECS_FOR_ENTITY__"))
            {
              ApplyFilterSortCriteria<SpecificationCharacteristic>(stmt, specs);
              stmt.AddParam("%%ENTITY_ID%%", entityId);
              using (IMTDataReader dataReader = stmt.ExecuteReader())
              {
                while (dataReader.Read())
                {
                  // TODO Localization
                  SpecificationCharacteristic spec = new SpecificationCharacteristic();
                  spec.ID = dataReader.GetInt32("ID");
                  PropertyType specType =
                    (PropertyType)
                    EnumHelper.GetEnumByValue(typeof(PropertyType), dataReader.GetInt32("SpecType").ToString());
                  spec.SpecType = specType;
                  spec.Category = dataReader.GetString("Category");
                  spec.IsRequired = dataReader.GetBoolean("IsRequired");
                  spec.Description = dataReader.GetString("Description");
                  spec.Name = dataReader.GetString("Name");
                  spec.UserVisible = dataReader.GetBoolean("UserVisible");
                  spec.UserEditable = dataReader.GetBoolean("UserEditable");
                  spec.MinValue = dataReader.IsDBNull("MinValue") ? null : dataReader.GetString("MinValue");
                  spec.MaxValue = dataReader.IsDBNull("MaxValue") ? null : dataReader.GetString("MaxValue");
                  if (!dataReader.IsDBNull("DisplayOrder"))
                    spec.DisplayOrder = dataReader.GetInt32("DisplayOrder");
                  specs.Items.Add(spec);
                }
              }
              specs.TotalRows = stmt.TotalRows;
            }
          }
          mLogger.LogDebug(String.Format("{0} {1}", specs.TotalRows, resourceManager.GetLocalizedResource("TEXT_RETRIEVED_SPECS_FOR_ENTITY")));
        }
        catch (CommunicationException e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SPECS"), e);
          throw;
        }

        catch (Exception e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SPECS"), e);
          throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SPECS"));
        }
      }
    }

    // TODO: Code duplication and might want to use an internal method
    [OperationCapability("Manage Specification Characteristics")]
    public void AddSpecCharValsToSpecificationCharacteristic(int specId, List<int> valueIds)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("AddSpecCharValsToSpecificationCharacteristic"))
      {
        var resourceManager = new ResourcesManager();
        try
        {
          string insertStmt = "BEGIN\n";
          mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_CREATING_SPEC_VAL_MAP"));
          using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
          {
            IMTQueryAdapter qa = new MTQueryAdapterClass();
            qa.Init(@"Queries\PCWS");

            foreach (int val in valueIds)
            {
              qa.SetQueryTag("__ADD_SPEC_VAL_MAP_ENTRY__");
              qa.AddParam("%%ID_SPEC%%", specId);
              qa.AddParam("%%ID_SCV%%", val);
              insertStmt += qa.GetQuery().Trim() + ";\n";
            }
            insertStmt += "END;";

            using (IMTStatement stmt = conn.CreateStatement(insertStmt))
            {
              stmt.ExecuteNonQuery();
            }
          }
          mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_CREATED_SPEC_VAL_MAP"));
        }

        catch (CommunicationException e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_CREATED_SPEC_VAL_MAP_FAILED"), e);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_CREATED_SPEC_VAL_MAP_FAILED"), e);
          throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_CREATED_SPEC_VAL_MAP_FAILED"));
        }
      }
    }

    [OperationCapability("Manage Specification Characteristics")]
    public void RemoveSpecCharValsFromSpecificationCharacteristic(int specId, List<int> valueIds, int? entityId)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("RemoveSpecCharValsFromSpecificationCharacteristic"))
      {
        var resourceManager = new ResourcesManager();
        if (valueIds.Count > 0)
        {
          try
          {
            bool valInUse = false;
            string ids = "";
            string temp = "";
            foreach (int id in valueIds)
              temp += String.Format("{0},", id);

            // remove trailing comma
            ids = temp.Substring(0, temp.Length - 1);

            using (
              TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(),
                                                            EnterpriseServicesInteropOption.Full))
            {
              string deleteStmt = "BEGIN\n";
              mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_REMOVING_SPEC_VAL_MAP"));
              using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
              {
                if (entityId.HasValue)
                {
                  using (
                    IMTAdapterStatement checkSpecStmt = conn.CreateAdapterStatement("queries\\PCWS",
                                                                                    "__CHECK_IF_VALS_ARE_USED__"))
                  {
                    // TODO: How do we set the id on a spec?
                    checkSpecStmt.AddParam("%%ID_SPEC%%", specId);
                    checkSpecStmt.AddParam("%%ID_SCV%%", ids);
                    checkSpecStmt.AddParam("%%ENTITY_CLAUSE%%", String.Format(" and specs.id_entity = {0}", entityId));

                    checkSpecStmt.ExecuteNonQuery();

                    using (IMTDataReader specReader = checkSpecStmt.ExecuteReader())
                      while (specReader.Read())
                      {
                        int numSpecs = specReader.GetInt32("NumVals");
                        if (numSpecs != 0)
                          valInUse = true;
                      }
                  }
                }
                if (valInUse)
                  throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_SPEC_VAL_MAPPING_IN_USE"));

                IMTQueryAdapter qa = new MTQueryAdapterClass();
                qa.Init(@"Queries\PCWS");

                foreach (int val in valueIds)
                {
                  qa.SetQueryTag("__DELETE_SPEC_CHAR_VAL_MAP_ENTRY__");
                  qa.AddParam("%%ID_SPEC%%", specId);
                  qa.AddParam("%%ID_SCV%%", val);
                  deleteStmt += qa.GetQuery().Trim() + ";\n";
                }
                deleteStmt += "END;";

                using (IMTStatement stmt = conn.CreateStatement(deleteStmt))
                {
                  stmt.ExecuteNonQuery();
                }
              }

              mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_REMOVED_SPEC_VAL_MAP"));
              scope.Complete();
            }
            auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_REMOVED_CHAR_VAL, this.GetSessionContext().AccountID,
                                     (int)MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
                                     resourceManager.GetLocalizedResource("TEXT_REMOVED_SPEC_VAL_MAP"));
          }
          catch (CommunicationException e)
          {
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_REMOVED_CHAR_VAL_FAILED,
                                     this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT,
                                     -1,
                                     resourceManager.GetLocalizedResource("TEXT_REMOVED_SPEC_VAL_MAP_FAILED"));
            mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_REMOVED_SPEC_VAL_MAP_FAILED"), e);
            throw;
          }

          catch (Exception e)
          {
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_REMOVED_CHAR_VAL_FAILED,
                                     this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT,
                                     -1,
                                     resourceManager.GetLocalizedResource("TEXT_REMOVED_SPEC_VAL_MAP_FAILED"));
            mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_REMOVED_SPEC_VAL_MAP_FAILED"), e);
            throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_REMOVED_SPEC_VAL_MAP_FAILED"));
          }
        }
        else
        {
          mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_NO_VALS_TO_DELETE"));
        }
      }
    }


    #endregion

    #region private methods

    private void GetLocalizationDetialsForSpecs(string valIds, IMTConnection conn, Dictionary<int, SpecCharacteristicValue> valDictionary)
    {
      if (valIds.Length > 0)
      {
        // remove trailing comma
        int length = valIds.Length - 1;
        valIds = valIds.Remove(length, 1);

        using (IMTAdapterStatement local = conn.CreateAdapterStatement("Queries\\PCWS", "__GET_DESCRIPTION_DETAILS__"))
        {
          local.AddParam("%%ID_DESCRIPTIONS%%", valIds);
          using (IMTDataReader localizedReader = local.ExecuteReader())
          {
            while (localizedReader.Read())
            {
              int id = localizedReader.GetInt32("ID");
              SpecCharacteristicValue val = valDictionary[id];
              if (!localizedReader.IsDBNull("LanguageCode"))
              {
                val.LocalizedDisplayValues = new Dictionary<LanguageCode, string>();
                LanguageCode langCode = (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), localizedReader.GetInt32("LanguageCode").ToString());
                val.LocalizedDisplayValues.Add(langCode, (!localizedReader.IsDBNull("Description")) ? localizedReader.GetString("Description") : null);
              }
            }
          }
        }
      }
    }

    private void AddNewSpecCharVals(IMTConnection conn, string insertStmt, IdGenerator specDetailIdGenerator, MTList<SpecCharacteristicValue> specs, int specId)
    {
      IMTQueryAdapter qa = new MTQueryAdapterClass();
      qa.Init(@"Queries\PCWS");

      IMTQueryAdapter qa2 = new MTQueryAdapterClass();
      qa2.Init(@"Queries\PCWS");

      foreach (SpecCharacteristicValue specValue in specs.Items)
      {
        int descId = -1;
        using (IMTCallableStatement stmt = conn.CreateCallableStatement("UpsertDescriptionV2"))
        {
          stmt.AddParam("id_lang_code", MTParameterType.Integer, GetSessionContext().LanguageID);
          stmt.AddParam("a_nm_desc", MTParameterType.WideString, specValue.Value);
          stmt.AddParam("a_id_desc_in", MTParameterType.Integer, null);
          stmt.AddOutputParam("a_id_desc", MTParameterType.Integer);
          stmt.ExecuteNonQuery();
          descId = (int)stmt.GetOutputValue("a_id_desc");
        }

        int specValId = specDetailIdGenerator.NextId;
        specValue.ID = specValId;
        qa.SetQueryTag("__ADD_SPEC_CHAR_VAL__");
        qa.AddParam("%%ID_SCV%%", specValId, true);

        if (specValue.IsDefault)
          qa.AddParam("%%IS_DEFAULT%%", "Y", true);
        else
          qa.AddParam("%%IS_DEFAULT%%", "N", true);

        qa.AddParam("%%N_VALUE%%", descId, true);
        qa.AddParam("%%NM_VALUE%%", specValue.Value, true);
        insertStmt += qa.GetQuery().Trim() + ";\n";

        qa2.SetQueryTag("__ADD_SPEC_VAL_MAP_ENTRY__");
        qa2.AddParam("%%ID_SPEC%%", specId);
        qa2.AddParam("%%ID_SCV%%", specValId);
        insertStmt += qa2.GetQuery().Trim() + ";\n";
        ProcessLocalizationData(descId, specValue.LocalizedDisplayValues, specValue.IsLocalizedDisplayValuesDirty, null, null, false);
      }
      insertStmt += "END;";
      mLogger.LogDebug(insertStmt);
      using (IMTStatement stmt = conn.CreateStatement(insertStmt))
      {
        stmt.ExecuteNonQuery();
      }
    }

    private void AddSpecToEntity(int entityId, EntityType entityType, SpecificationCharacteristic spec)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
      {
        using (
          IMTAdapterStatement specStmt = conn.CreateAdapterStatement("queries\\PCWS", "__ADD_SPEC_TO_ENTITY__")
          )
        {
          specStmt.AddParam("%%ID_ENTITY%%", entityId);
          specStmt.AddParam("%%ID_SPEC%%", spec.ID);
          if (spec.DisplayOrder.HasValue)
            specStmt.AddParam("%%C_DISPLAY_ORDER%%", spec.DisplayOrder.Value);
          else
            specStmt.AddParam("%%C_DISPLAY_ORDER%%", null);
          specStmt.AddParam("%%ENTITY_TYPE%%", EnumHelper.GetValueByEnum(entityType));
          specStmt.ExecuteNonQuery();
        }
      }
    }

    private void UpdateDisplayOrder(int entityId, int specId, int displayOrder)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
      {
        using (
          IMTAdapterStatement specStmt = conn.CreateAdapterStatement("queries\\PCWS", "__UPDATE_DISPLAY_ORDER__")
          )
        {
          specStmt.AddParam("%%ID_ENTITY%%", entityId);
          specStmt.AddParam("%%ID_SPEC%%", specId);
          specStmt.AddParam("%%C_DISPLAY_ORDER%%", displayOrder);
          specStmt.ExecuteNonQuery();
        }
      }
    }

    private int AddDescription(string desc, IMTConnection conn)
    {
      int descId = -1;
      using (IMTCallableStatement stmt = conn.CreateCallableStatement("UpsertDescriptionV2"))
      {
        stmt.AddParam("id_lang_code", MTParameterType.Integer, GetSessionContext().LanguageID);
        stmt.AddParam("a_nm_desc", MTParameterType.WideString, desc);
        stmt.AddParam("a_id_desc_in", MTParameterType.Integer, null);
        stmt.AddOutputParam("a_id_desc", MTParameterType.Integer);
        stmt.ExecuteNonQuery();
        descId = (int)stmt.GetOutputValue("a_id_desc");
      }
      return descId;
    }

    private void SaveSpecificationCharacteristicInternal(ref SpecificationCharacteristic spec, int? entityId)
    {
      var resourceManager = new ResourcesManager();
      if (spec.ID.HasValue)
      {
        mLogger.LogDebug(String.Format("{0} {1}", resourceManager.GetLocalizedResource("TEXT_UPDATING_SPEC"), spec.Name));
        using (
           TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(),
                                                         EnterpriseServicesInteropOption.Full))
        {
          mLogger.LogDebug("TXN ISOLATION LEVEL IN savespeccharacteristic" +
                           Transaction.Current.IsolationLevel.ToString());
          string insertStmt = "BEGIN\n";
          int categoryId = -1;
          int descId = -1;
          int nameId = -1;
          IdGenerator specDetailIdGenerator = null;

          using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
          {
            using (
              IMTAdapterStatement getLocalDataStmt = conn.CreateAdapterStatement("queries\\PCWS",
                                                                                 "__GET_SPEC_LOCALIZATION_DATA__"))
            {
              getLocalDataStmt.AddParam("%%ID_SPEC%%", spec.ID.Value);
              using (IMTDataReader sLocalReader = getLocalDataStmt.ExecuteReader())
              {
                while (sLocalReader.Read())
                {
                  categoryId = sLocalReader.GetInt32("CategoryId");
                  descId = sLocalReader.GetInt32("DescriptionId");
                  nameId = sLocalReader.GetInt32("NameId");
                }
              }
            }

            if ((categoryId == -1) || (descId == -1) || (nameId == -1))
              throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_COULD_NOT_GET_LOCALE"));

            mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVED_LOCALE"));

            using (
              IMTAdapterStatement updateSpecStmt = conn.CreateAdapterStatement("queries\\PCWS",
                                                                               "__UPDATE_SPEC_CHARACTERISTIC__"))
            {
              updateSpecStmt.AddParam("%%SPEC_TYPE%%", spec.SpecType);
              updateSpecStmt.AddParam("%%CATEGORY%%", spec.Category);
              if (spec.IsRequired)
                updateSpecStmt.AddParam("%%C_IS_REQUIRED%%", "Y");
              else
                updateSpecStmt.AddParam("%%C_IS_REQUIRED%%", "N");
              updateSpecStmt.AddParam("%%NM_DESCRIPTION%%", spec.Description);
              updateSpecStmt.AddParam("%%NM_NAME%%", spec.Name);
              if (spec.UserVisible)
                updateSpecStmt.AddParam("%%C_USER_VISIBLE%%", "Y");
              else
                updateSpecStmt.AddParam("%%C_USER_VISIBLE%%", "N");

              if (spec.UserEditable)
                updateSpecStmt.AddParam("%%C_USER_EDITABLE%%", "Y");
              else
                updateSpecStmt.AddParam("%%C_USER_EDITABLE%%", "N");
              updateSpecStmt.AddParam("%%ID_SPEC%%", spec.ID.Value);
              updateSpecStmt.AddParam("%%MIN_VALUE%%", spec.MinValue);
              updateSpecStmt.AddParam("%%MAX_VALUE%%", spec.MaxValue);

              updateSpecStmt.ExecuteNonQuery();
            }


            ProcessLocalizationData(nameId, spec.LocalizedDisplayNames, spec.IsLocalizedDisplayNamesDirty, descId,
                                    spec.LocalizedDescriptions, spec.IsLocalizedDescriptionsDirty);
            ProcessLocalizationData(categoryId, spec.CategoryDisplayNames, spec.IsCategoryDisplayNamesDirty, null, null,
                                    false);

            mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_PROCESSED_LOCALE"));
            // update the spec char vals
            if (spec.IsSpecCharacteristicValuesDirty)
            {
              // UI will send null if they want to update the spec but not values
              if (spec.SpecCharacteristicValues != null)
              {
                mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_UPDATING_VALUES_FOR_SPEC"));
                MTList<SpecCharacteristicValue> vals = new MTList<SpecCharacteristicValue>();
                GetSpecCharacteristicValuesForSpec(spec.ID.Value, ref vals);

                List<int> valIds = new List<int>();
                foreach (SpecCharacteristicValue v in vals.Items)
                {
                  valIds.Add(v.ID.Value);
                }


                // remove the values from the map
                RemoveSpecCharValsFromSpecificationCharacteristic(spec.ID.Value, valIds, entityId);

                // find the specs that are new vals or existing vals
                List<SpecCharacteristicValue> newVals = spec.SpecCharacteristicValues.FindAll(s => !s.ID.HasValue);
                MTList<SpecCharacteristicValue> addVals = new MTList<SpecCharacteristicValue>();
                List<SpecCharacteristicValue> oldVals = spec.SpecCharacteristicValues.FindAll(s => s.ID.HasValue);

                foreach (SpecCharacteristicValue s in newVals)
                  addVals.Items.Add(s);

                if (newVals.Count > 0)
                {
                  int blockSize = newVals.Count;
                  specDetailIdGenerator = new IdGenerator("id_scv", blockSize);
                  AddNewSpecCharVals(conn, insertStmt, specDetailIdGenerator, addVals, spec.ID.Value);
                }

                // TODO: this needs to be optimized . . .

                // check to see if the localization has been added or not
                foreach (SpecCharacteristicValue valLoc in oldVals)
                {
                  if (valLoc.ValueID <= 0)
                  {
                    valLoc.ValueID = AddDescription(valLoc.Value, conn);
                  }
                }

                if (oldVals.Count > 0)
                {
                  IMTQueryAdapter qa = new MTQueryAdapterClass();
                  qa.Init(@"Queries\PCWS");

                  foreach (SpecCharacteristicValue val in oldVals)
                  {
                    qa.SetQueryTag("__UPDATE_SPEC_CHAR_VAL_BULK__");
                    if (val.IsDefault)
                      qa.AddParam("%%C_IS_DEFAULT%%", "Y");
                    else
                      qa.AddParam("%%C_IS_DEFAULT%%", "N");
                    qa.AddParam("%%N_VALUE%%", val.ValueID);
                    qa.AddParam("%%NM_VALUE%%", val.Value);
                    qa.AddParam("%%ID_SCV%%", val.ID.Value);
                    qa.AddParam("%%ID_SPEC%%", spec.ID.Value);
                    insertStmt += qa.GetQuery().Trim() + ";\n";
                  }
                  insertStmt += "END;";
                  using (IMTStatement updateStmt = conn.CreateStatement(insertStmt))
                  {
                    updateStmt.ExecuteNonQuery();
                  }
                }

                foreach (SpecCharacteristicValue val in oldVals)
                {
                  ProcessLocalizationData(val.ValueID, val.LocalizedDisplayValues, val.IsLocalizedDisplayValuesDirty,
                                          null, null, false);
                }
                mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_UPDATED_VALUES_FOR_SPEC"));
              }
            }
          }
          scope.Complete();
        }
        auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_UPDATE_SPEC_CHAR, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
             resourceManager.GetLocalizedResource("TEXT_UPDATED_SPEC"));
        mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_UPDATED_SPEC"));
      }
      else
      {
        #region save spec characteristic value
        mLogger.LogInfo(resourceManager.GetLocalizedResource("TEXT_CREATING_SPEC"));

        try
        {
          IdGenerator specIdGenerator = new IdGenerator("id_spec", 1);
          int specId = specIdGenerator.NextId;
          IdGenerator specDetailIdGenerator = null;
          bool hasSpecDetails = false;
          spec.ID = specId;

          if (spec.SpecCharacteristicValues.Count != 0)
          {
            hasSpecDetails = true;
            // TODO: Grab a block of ids for the detail
            int blockSize = spec.SpecCharacteristicValues.Count;
            specDetailIdGenerator = new IdGenerator("id_scv", blockSize);
          }

          string insertStmt = "BEGIN\n";
          int descId = -1;
          int nameId = -1;
          int categoryId = -1;

          using (
            TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(),
                                                          EnterpriseServicesInteropOption.Full))
          {
            mLogger.LogDebug("TXN ISOLATION LEVEL IN savespeccharacteristics" +
                             Transaction.Current.IsolationLevel.ToString());
            using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
            {
              //TODO: Maybe we change this all to a sproc ??
              using (IMTCallableStatement stmt = conn.CreateCallableStatement("UpsertDescriptionV2"))
              {
                stmt.AddParam("id_lang_code", MTParameterType.Integer, GetSessionContext().LanguageID);
                stmt.AddParam("a_nm_desc", MTParameterType.WideString, spec.Description);
                stmt.AddParam("a_id_desc_in", MTParameterType.Integer, null);
                stmt.AddOutputParam("a_id_desc", MTParameterType.Integer);
                stmt.ExecuteNonQuery();
                descId = (int)stmt.GetOutputValue("a_id_desc");
              }

              using (IMTCallableStatement stmt1 = conn.CreateCallableStatement("UpsertDescriptionV2"))
              {
                stmt1.AddParam("id_lang_code", MTParameterType.Integer, GetSessionContext().LanguageID);
                stmt1.AddParam("a_nm_desc", MTParameterType.WideString, spec.Description);
                stmt1.AddParam("a_id_desc_in", MTParameterType.Integer, null);
                stmt1.AddOutputParam("a_id_desc", MTParameterType.Integer);
                stmt1.ExecuteNonQuery();
                nameId = (int)stmt1.GetOutputValue("a_id_desc");
              }

              using (IMTCallableStatement stmt2 = conn.CreateCallableStatement("UpsertDescriptionV2"))
              {
                stmt2.AddParam("id_lang_code", MTParameterType.Integer, GetSessionContext().LanguageID);
                stmt2.AddParam("a_nm_desc", MTParameterType.WideString, spec.Description);
                stmt2.AddParam("a_id_desc_in", MTParameterType.Integer, null);
                stmt2.AddOutputParam("a_id_desc", MTParameterType.Integer);
                stmt2.ExecuteNonQuery();
                categoryId = (int)stmt2.GetOutputValue("a_id_desc");
              }

              if ((nameId == -1) || (descId == -1) || (categoryId == -1))
                throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_PROCESSED_LOCALE"));

              using (IMTAdapterStatement createSpecStmt = conn.CreateAdapterStatement("queries\\PCWS", "__ADD_SPEC__"))
              {
                // TODO: How do we set the id on a spec?
                createSpecStmt.AddParam("%%ID_SPEC%%", specId);
                createSpecStmt.AddParam("%%C_SPEC_TYPE%%", EnumHelper.GetValueByEnum(spec.SpecType));
                createSpecStmt.AddParam("%%ID_CATEGORY%%", categoryId);
                createSpecStmt.AddParam("%%C_CATEGORY%%", spec.Category);
                if (spec.IsRequired)
                  createSpecStmt.AddParam("%%C_IS_REQUIRED%%", "Y");
                else
                  createSpecStmt.AddParam("%%C_IS_REQUIRED%%", "N");
                createSpecStmt.AddParam("%%N_DESCRIPTION%%", descId);
                createSpecStmt.AddParam("%%NM_DESCRIPTION%%", spec.Description);
                createSpecStmt.AddParam("%%N_NAME%%", nameId);
                createSpecStmt.AddParam("%%NM_NAME%%", spec.Name);
                if (spec.UserVisible)
                  createSpecStmt.AddParam("%%C_USER_VISIBLE%%", "Y");
                else
                  createSpecStmt.AddParam("%%C_USER_VISIBLE%%", "N");

                if (spec.UserEditable)
                  createSpecStmt.AddParam("%%C_USER_EDITABLE%%", "Y");
                else
                  createSpecStmt.AddParam("%%C_USER_EDITABLE%%", "N");

                createSpecStmt.AddParam("%%MIN_VALUE%%", spec.MinValue);
                createSpecStmt.AddParam("%%MAX_VALUE%%", spec.MaxValue);
                createSpecStmt.ExecuteNonQuery();
              }

              if (hasSpecDetails)
              {
                mLogger.LogDebug(resourceManager.GetLocalizedResource("ADDING_SPEC_CHAR_VALS"));
                MTList<SpecCharacteristicValue> vals = new MTList<SpecCharacteristicValue>();
                foreach (SpecCharacteristicValue val in spec.SpecCharacteristicValues)
                {
                  vals.Items.Add(val);
                }
                AddNewSpecCharVals(conn, insertStmt, specDetailIdGenerator, vals, spec.ID.Value);
                mLogger.LogDebug(resourceManager.GetLocalizedResource("ADDED_SPEC_CHAR_VALS"));
              }

              ProcessLocalizationData(nameId,
                                      spec.LocalizedDisplayNames,
                                      spec.IsLocalizedDisplayNamesDirty,
                                      descId,
                                      spec.LocalizedDescriptions,
                                      spec.IsLocalizedDescriptionsDirty);

              ProcessLocalizationData(categoryId, spec.CategoryDisplayNames, spec.IsCategoryDisplayNamesDirty, null,
                                      null, false);
            }
            scope.Complete();
          }
          mLogger.LogDebug(resourceManager.GetLocalizedResource("TEXT_CREATED_SPEC"));
          auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_CREATE_SPEC_CHAR, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
     resourceManager.GetLocalizedResource("TEXT_CREATED_SPEC"));
        }
        catch (MASBasicException masE)
        {
          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_CREATE_SPEC_CHAR_FAILED, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
             resourceManager.GetLocalizedResource("TEXT_CREATED_SPEC_FAILED"));
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_CREATED_SPEC_FAILED"), masE);
          throw masE;
        }
        catch (Exception e)
        {
          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_CREATE_SPEC_CHAR_FAILED, this.GetSessionContext().AccountID, (int)MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
             resourceManager.GetLocalizedResource("TEXT_CREATED_SPEC_FAILED"));
          mLogger.LogException(resourceManager.GetLocalizedResource("TEXT_CREATED_SPEC_FAILED"), e);

          throw new MASBasicException(resourceManager.GetLocalizedResource("TEXT_REVIEW_LOGS"));
        }
        #endregion
      }
    }

    /// <summary>Gets first id_spec for SpecificationCharacteristic with the same name, category and description
    /// </summary>
    /// <param name="spec"></param>
    /// <returns>Returns -1 in case no entities found</returns>
    private int GetSpecificationId(SpecificationCharacteristic spec)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
      {
        using (
          IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\PCWS", "__GET_SPEC_ID__")
          )
        {
          stmt.AddParam("%%CATEGORY%%", spec.Category);
          stmt.AddParam("%%DESCRIPTION%%", spec.Description);
          stmt.AddParam("%%NAME%%", spec.Name);

          using (IMTDataReader dataReader = stmt.ExecuteReader())
          {
            while (dataReader.Read())
            {
              return dataReader.GetInt32("id_spec");
            }
          }
        }
      }
      return -1;
    }

    #endregion

  }
}
