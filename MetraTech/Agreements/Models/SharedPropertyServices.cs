using System;
using System.Collections.Generic;
using System.Data;
using System.ServiceModel;
using System.Transactions;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.Interop.MTAuditEvents;
using MetraTech.Interop.QueryAdapter;
using MetraTech.UI.Common;
using PropertyType = MetraTech.DomainModel.Enums.Core.Global.PropertyType;

namespace MetraTech.Agreements.Models
{
  public interface ISharedPropertyServices
  {
    /// <summary>
    /// Retrieve list of shared properties for a given entity id
    /// </summary>
    /// <param name="entityId">entity id for the MetraNet entity to retrieve shared properties for. The entity id is the unique identifier for the MetraNet object whose type defined by the MetraNet enum Global.EntityType. 
    /// For example it could be the unique identifier for a product offering or the unique identifier for an agreement template.</param>
    /// <param name="filterpropertiesList">List of fields to filter on for the shared properties list returned by this method</param>
    /// <param name="sortCriteria">List of sort criteria for the sharedProperties list returned by this method</param>
    /// <param name="sharedProperties">Ref to list to add retrieved shared properties to. If no shared properties are found for the given entity id that match the filter criteria passed to the method, no new shared properties are added to the list.</param>
    void GetSharedPropertiesForEntity(int entityId, List<FilterElement> filterpropertiesList,
                                      List<SortCriteria> sortCriteria,
                                      ref List<SharedPropertyModel> sharedProperties);

    /// <summary>
    /// Retrieve list of shared properties for a given entity id
    /// </summary>
    /// <param name="entityId">entity id for the MetraNet entity to retrieve shared properties for. The entity id is the unique identifier for the MetraNet object whose type defined by the MetraNet enum Global.EntityType. 
    /// For example it could be the unique identifier for a product offering or the unique identifier for an agreement template.</param>
    /// <param name="entityType">tells what MetraNet entity the entityId is for. The entity id is the unique identifier for the MetraNet object whose type defined by the MetraNet enum Global.EntityType. 
    /// <param name="filterpropertiesList">List of fields to filter on for the shared properties list returned by this method</param>
    /// <param name="sortCriteria">List of sort criteria for the sharedProperties list returned by this method</param>
    /// <param name="sharedProperties">Ref to list to add retrieved shared properties to. If no shared properties are found for the given entity id that match the filter criteria passed to the method, no new shared properties are added to the list.</param>
    void GetSharedPropertiesForEntity(int entityId, EntityType entityType,
                                      List<FilterElement> filterpropertiesList,
                                      List<SortCriteria> sortCriteria,
                                      ref List<SharedPropertyModel> sharedProperties);

    /// <summary>
    /// Save a shared property and add the saved shared property to a MetraNet entity
    /// </summary>
    /// <param name="entityId">entity id for the MetraNet entity to add the sharedProperty to. If the MetraNet entity already has this shared property, then the shared property is not added a second time.</param>
    /// <param name="entityType">tells what MetraNet entity the entityId is for. The entity id is the unique identifier for the MetraNet object whose type defined by the MetraNet enum Global.EntityType. 
    /// For example it could be the unique identifier for a product offering or the unique identifier for an agreement template.</param>
    /// <param name="sharedProperty">The populated SharedPropertyModel to save. If the ID is set in the SharedPropertyModel object, then the existing shared property is updated in the database.
    /// Otherwise, a new shared proeprty is created in the database.</param>
    void SaveSharedPropertyForEntity(int entityId, EntityType entityType, SharedPropertyModel sharedProperty);

    /// <summary>
    /// Save a shared proeprty to database
    /// </summary>
    /// <param name="sharedProperty">The populated SharedPropertyModel to save. If the ID is set in the SharedPropertyModel object, then the existing shared property is updated in the database.
    /// Otherwise, a new shared proeprty is created in the database.</param>
    void SaveSharedProperty(ref SharedPropertyModel sharedProperty);

    /// <summary>
    /// Get a shared property from the database
    /// </summary>
    /// <param name="id">unique id of the shared property to retrieve</param>
    /// <param name="sharedProperty">The retrieved shared property from the database</param>
    void GetSharedProperty(int id, out SharedPropertyModel sharedProperty);

    /// <summary>
    /// Retrieve list of shared properties
    /// </summary>
    /// <param name="filterpropertiesList">List of fields to filter on for the shared properties list returned by this method</param>
    /// <param name="sortCriteria">List of sort criteria for the sharedProperties list returned by this method</param>
    /// <param name="sharedProperties">Ref to list to add retrieved shared properties to. If no shared properties are found that match the filter criteria passed to the method, no new shared properties are added to the list.</param>
    void GetSharedProperties(List<FilterElement> filterpropertiesList, List<SortCriteria> sortCriteria,
                             ref List<SharedPropertyModel> sharedProperties);

    /// <summary>
    /// Remove a shared property from a MetraNet entity. The shared property is not deleted from the database, just the mapping of shared property to entity id. If the entity is a product offering and if any subscriptions
    /// to that product offering exist, then the shared property is not removed from that MetraNet entity.
    /// </summary>
    /// <param name="sharedPropertyId">unique id of the shared property to remove.</param>
    /// <param name="entityId">Entity id for the MetraNet entity to remove the sharedProperty from. NOTE: This only works for cases where the entity id is product offering id. Also, if the 
    /// product offering with id = entity id has any subscriptions to it, this method will not remove the shared property from the entity.</param>
    void RemoveSharedPropertyFromEntity(int sharedPropertyId, int entityId);

    /// <summary>
    /// Remove a shared property from a MetraNet entity. The shared property is not deleted from the database, just the mapping of shared property to entity id. If the entity is a product offering and if any subscriptions
    /// to that product offering exist, then the shared property is not removed from that MetraNet entity.
    /// </summary>
    /// <param name="sharedPropertyId">unique id of the shared property to remove.</param>
    /// <param name="entityId">Entity id for the MetraNet entity to remove the sharedProperty from. NOTE: This only works for cases where the entity id is product offering id. Also, if the 
    /// product offering with id = entity id has any subscriptions to it, this method will not remove the shared property from the entity.</param>
    /// <param name="entityType">tells what MetraNet entity the entityId is for. The entity id is the unique identifier for the MetraNet object whose type defined by the MetraNet enum Global.EntityType. 
    /// For example it could be the unique identifier for a product offering or the unique identifier for an agreement template.</param>
    void RemoveSharedPropertyFromEntity(int sharedPropertyId, int entityId, EntityType entityType);

    /// <summary>
    /// Delete a shared property from the database. If the shared property is used by any MetraNet enitity, though, the shared property will not be deleted and a DataException is thrown.
    /// </summary>
    /// <param name="sharedPropertyId">unique id of the shared property to delete.</param>
    void DeleteSharedProperty(int sharedPropertyId);

    /// <summary>
    /// Add shared property values to an existing shared property
    /// </summary>
    /// <param name="sharedPropertyId">unique id of the shared property to save values for</param>
    /// <param name="valueIds">List of values to save to database for the shared property</param>
    void AddSharedPropertyValuesToSharedProperty(int sharedPropertyId, List<int> valueIds);

    /// <summary>
    /// Remove values from a shared property
    /// </summary>
    /// <param name="sharedPropertyId">unique id of the shared property to remove values from</param>
    /// <param name="valueIds">List of shared property value ids to remove from a shared property</param>
    /// <param name="entityId">unique id of the shared property to remove values for. 
    /// If this entityId is not null, then check if there are any subscriptions to the propuct offering with id_po = entityId. If any subscriptions exist to that
    /// product offering, then the shared property values are not removed from the shared property.
    /// If this entityId is null, then no checks are made to see if the shared property values are in use and the shared property values are removed from the
    /// shared property.</param>
    void RemoveSharedPropertyValuesFromSharedProperty(int sharedPropertyId, List<int> valueIds, int? entityId);

    /// <summary>
    /// Get values for a shared property
    /// </summary>
    /// <param name="sharedPropertyId">unique id of the shared property to get values for</param>
    /// <param name="filterpropertiesList">List of fields to filter on for the vals list returned by this method</param>
    /// <param name="sortCriteria">List of sort criteria for the vals list returned by this method</param>
    /// <param name="vals">Ref to list to add retrieved shared property values to. If no values are found for the given shared property id that match the filter criteria passed to the method, no new shared property values are added to the list.</param>
    void GetSharedPropertyValuesForSharedProperty(int sharedPropertyId, List<FilterElement> filterpropertiesList,
                                                  List<SortCriteria> sortCriteria,
                                                  ref List<SharedPropertyValueModel> vals);
  }

  public class SharedPropertyServicesFactory
  {
    public static ISharedPropertyServices GetSharedPropertyService(int i = 0)
    {
      return new SharedPropertyServices();
    }
  }

  public class SharedPropertyServices : BaseService, ISharedPropertyServices
  {
    /// <summary>
    /// Gets the MetraTech logger object
    /// </summary>
    private Logger m_logger = new Logger("[SharedPropertyServices]");

    //Create Auditor
    private Auditor m_auditor = new Auditor();


    /// <summary>
    /// Returns the current UI Manager. Setup at login time.
    /// </summary>
    private static UIManager UI
    {
      get { return System.Web.HttpContext.Current.Session[MetraTech.UI.Common.Constants.UI_MANAGER] as UIManager; }
    }

    /// <summary>
    /// The language id for data inserted into t_description by this service
    /// </summary>
    private int m_languageID = UI.SessionContext.LanguageID;

    /// <summary>
    /// id_acc for all auditing
    /// </summary>
    private int m_auditIdAcc = UI.User.AccountId;

    #region ISharedPropertyServices Members

    public void GetSharedPropertiesForEntity(int entityId,
                                             List<FilterElement> filterpropertiesList,
                                             List<SortCriteria> sortCriteria,
                                             ref List<SharedPropertyModel> sharedProperties)
    {
      var resourceManager = new ResourcesManager();
      try
      {
        m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVING_SHARED_PROPERTIES_FOR_ENTITY"));
        using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
        {
          using (
            IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("Queries\\PCWS",
                                                                         "__GET_SPECS_FOR_ENTITY__"))
          {
            ApplySortingFiltering(filterpropertiesList, sortCriteria, stmt);
            stmt.AddParam("%%ENTITY_ID%%", entityId);
            using (IMTDataReader dataReader = stmt.ExecuteReader())
            {
              while (dataReader.Read())
              {
                var sharedProperty = new SharedPropertyModel();
                sharedProperty.ID = dataReader.GetInt32("ID");
                var sharedPropertyType =
                  (PropertyType)
                  EnumHelper.GetEnumByValue(typeof (PropertyType),
                                            dataReader.GetInt32("SpecType").ToString());
                sharedProperty.PropType = sharedPropertyType;
                sharedProperty.Category = dataReader.GetString("Category");
                sharedProperty.IsRequired = dataReader.GetBoolean("IsRequired");
                sharedProperty.Description = dataReader.GetString("Description");
                sharedProperty.Name = dataReader.GetString("Name");
                sharedProperty.UserVisible = dataReader.GetBoolean("UserVisible");
                sharedProperty.UserEditable = dataReader.GetBoolean("UserEditable");
                sharedProperty.MinValue = dataReader.IsDBNull("MinValue")
                                            ? null
                                            : dataReader.GetString("MinValue");
                sharedProperty.MaxValue = dataReader.IsDBNull("MaxValue")
                                            ? null
                                            : dataReader.GetString("MaxValue");
                if (!dataReader.IsDBNull("DisplayOrder"))
                  sharedProperty.DisplayOrder = dataReader.GetInt32("DisplayOrder");
                sharedProperties.Add(sharedProperty);
              }
            }
          }
        }
        m_logger.LogDebug(String.Format("{0} {1}", sharedProperties.Count,
                                        resourceManager.GetLocalizedResource(
                                          "TEXT_RETRIEVED_SHARED_PROPERTIES_FOR_ENTITY")));
      }
      catch (CommunicationException e)
      {
        m_logger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SHARED_PROPERTIES"), e);
        throw;
      }

      catch (Exception e)
      {
        m_logger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SHARED_PROPERTIES"), e);
        throw new DataException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SHARED_PROPERTIES"));
      }
    }

    public void GetSharedPropertiesForEntity(int entityId, EntityType entityType,
                                      List<FilterElement> filterpropertiesList,
                                      List<SortCriteria> sortCriteria,
                                      ref List<SharedPropertyModel> sharedProperties)
    {
      var resourceManager = new ResourcesManager();
      try
      {
        m_logger.LogDebug(
          resourceManager.GetLocalizedResource("TEXT_RETRIEVING_SHARED_PROPERTIES_FOR_ENTITY_WITH_ENTITY_TYPE") +
          EnumHelper.GetCSharpEnum((int)EnumHelper.GetDbValueByEnum(entityType)));

        using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
        {
          using (
            IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("Queries\\PCWS",
                                                                         "__GET_SPECS_FOR_ENTITY_WITH_ENTITY_TYPE__"))
          {
            ApplySortingFiltering(filterpropertiesList, sortCriteria, stmt);
            stmt.AddParam("%%ENTITY_ID%%", entityId);
            stmt.AddParam("%%ENTITY_TYPE%%", EnumHelper.GetCSharpEnum((int)EnumHelper.GetDbValueByEnum(entityType)));
            using (IMTDataReader dataReader = stmt.ExecuteReader())
            {
              while (dataReader.Read())
              {
                var sharedProperty = new SharedPropertyModel();
                sharedProperty.ID = dataReader.GetInt32("ID");
                var sharedPropertyType =
                  (PropertyType)
                  EnumHelper.GetEnumByValue(typeof(PropertyType),
                                            dataReader.GetInt32("SpecType").ToString());
                sharedProperty.PropType = sharedPropertyType;
                sharedProperty.Category = dataReader.GetString("Category");
                sharedProperty.IsRequired = dataReader.GetBoolean("IsRequired");
                sharedProperty.Description = dataReader.GetString("Description");
                sharedProperty.Name = dataReader.GetString("Name");
                sharedProperty.UserVisible = dataReader.GetBoolean("UserVisible");
                sharedProperty.UserEditable = dataReader.GetBoolean("UserEditable");
                sharedProperty.MinValue = dataReader.IsDBNull("MinValue")
                                            ? null
                                            : dataReader.GetString("MinValue");
                sharedProperty.MaxValue = dataReader.IsDBNull("MaxValue")
                                            ? null
                                            : dataReader.GetString("MaxValue");
                if (!dataReader.IsDBNull("DisplayOrder"))
                  sharedProperty.DisplayOrder = dataReader.GetInt32("DisplayOrder");
                sharedProperties.Add(sharedProperty);
              }
            }
          }
        }
        m_logger.LogDebug(String.Format("{0} {1}", sharedProperties.Count,
                                        resourceManager.GetLocalizedResource(
                                          "TEXT_RETRIEVED_SHARED_PROPERTIES_FOR_ENTITY_WITH_ENTITY_TYPE")) + EnumHelper.GetCSharpEnum((int)EnumHelper.GetDbValueByEnum(entityType)));
      }
      catch (CommunicationException e)
      {
        m_logger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SHARED_PROPERTIES"), e);
        throw;
      }

      catch (Exception e)
      {
        m_logger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SHARED_PROPERTIES"), e);
        throw new DataException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SHARED_PROPERTIES"));
      }
    }

    public void SaveSharedPropertyForEntity(int entityId, EntityType entityType, SharedPropertyModel sharedProperty)
    {
      var resourceManager = new ResourcesManager();
      if (sharedProperty.ID.HasValue)
      {
        var sharedProperties = new List<SharedPropertyModel>();
        GetSharedPropertiesForEntity(entityId, entityType, null, null, ref sharedProperties);

        // check to see if we have the mapping and add it if we do not
        var s = sharedProperties.Find(s1 => s1.ID.Value == sharedProperty.ID.Value);
        SaveSharedPropertyInternal(ref sharedProperty, entityId);
        if (s == null)
        {
          AddSharedPropertyToEntity(entityId, entityType, sharedProperty);
        }
        else
        {
          if (sharedProperty.DisplayOrder.HasValue)
          {
            UpdateDisplayOrder(entityId, entityType, sharedProperty.ID.Value, sharedProperty.DisplayOrder.Value);
          }
        }
      }
      else
      {
        try
        {
          using (
            var scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(),
                                             EnterpriseServicesInteropOption.Full))
          {
            m_logger.LogDebug("TXN ISOLATION LEVEL IN SaveSharedPropertyForEntity" +
                              Transaction.Current.IsolationLevel.ToString());
            SaveSharedProperty(ref sharedProperty);
            AddSharedPropertyToEntity(entityId, entityType, sharedProperty);
            scope.Complete();
          }
        }
        catch (DataException masE)
        {
          m_logger.LogException(
            resourceManager.GetLocalizedResource("TEXT_DATA_SAVING_SHARED_PROPERTIES_TO_ENTITY"),
            masE);

          throw;
        }
        catch (Exception e)
        {
          m_logger.LogException(
            resourceManager.GetLocalizedResource("TEXT_EXCEPTION_SAVING_SHARED_PROPERTIES_TO_ENTITY"), e);
          throw;
        }
      }
    }

    public void SaveSharedProperty(ref SharedPropertyModel sharedProperty)
    {
      SaveSharedPropertyInternal(ref sharedProperty, null);
    }

    public void GetSharedProperty(int id, out SharedPropertyModel sharedProperty)
    {
      sharedProperty = null;
      string categoryId = "";
      string displayNameId = "";
      string descId = "";
      var resourceManager = new ResourcesManager();
      m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVING_SHARED_PROPERTY"));
      using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS`"))
      {
        using (
          IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\PCWS",
                                                                 "__GET_SPECIFICATION_CHARACTERISTIC__")
          )
        {
          stmt.AddParam("%%ID_SPEC%%", id);
          using (IMTDataReader dataReader = stmt.ExecuteReader())
          {
            while (dataReader.Read())
            {
              sharedProperty = new SharedPropertyModel();
              sharedProperty.ID = dataReader.GetInt32("ID");
              PropertyType sharedPropertyType =
                (PropertyType)
                EnumHelper.GetEnumByValue(typeof (PropertyType),
                                          dataReader.GetInt32("SpecType").ToString());
              sharedProperty.PropType = sharedPropertyType;
              categoryId = dataReader.GetInt32("CategoryId").ToString();
              sharedProperty.Category = dataReader.GetString("Category");
              sharedProperty.IsRequired = dataReader.GetBoolean("IsRequired");
              descId = dataReader.GetInt32("DescId").ToString();
              sharedProperty.Description = dataReader.GetString("Description");
              displayNameId = dataReader.GetInt32("NameId").ToString();
              sharedProperty.Name = dataReader.GetString("Name");
              sharedProperty.UserVisible = dataReader.GetBoolean("UserVisible");
              sharedProperty.UserEditable = dataReader.GetBoolean("UserEditable");
              sharedProperty.MinValue = dataReader.IsDBNull("MinValue")
                                          ? null
                                          : dataReader.GetString("MinValue");
              sharedProperty.MaxValue = dataReader.IsDBNull("MaxValue")
                                          ? null
                                          : dataReader.GetString("MaxValue");
            }

          }
        }
        m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVING_LOCALE"));
        sharedProperty.LocalizedCategories = new Dictionary<LanguageCode, string>();
        sharedProperty.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
        sharedProperty.LocalizedDescriptions = new Dictionary<LanguageCode, string>();
        using (
          IMTMultiSelectAdapterStatement localStmt = conn.CreateMultiSelectStatement("Queries\\PCWS",
                                                                                     "__GET_SPEC_LOCALIZATION__")
          )
        {
          localStmt.AddParam("%%ID_CATEGORY%%", categoryId);
          localStmt.AddParam("%%ID_DISPLAY_NAME%%", displayNameId);
          localStmt.AddParam("%%ID_DESCRIPTION%%", descId);
          localStmt.SetResultSetCount(3);

          using (IMTDataReader rdr = localStmt.ExecuteReader())
          {
            while (rdr.Read())
            {
              var langCode =
                (LanguageCode)
                EnumHelper.GetEnumByValue(typeof (LanguageCode), rdr.GetInt32("LanguageCode").ToString());
              sharedProperty.LocalizedCategories.Add(langCode,
                                                     (!rdr.IsDBNull("CategoryDescription"))
                                                       ? rdr.GetString("CategoryDescription")
                                                       : null);
            }
            rdr.NextResult();
            while (rdr.Read())
            {
              var langCode =
                (LanguageCode)
                EnumHelper.GetEnumByValue(typeof (LanguageCode), rdr.GetInt32("LanguageCode").ToString());
              sharedProperty.LocalizedDisplayNames.Add(langCode,
                                                       (!rdr.IsDBNull("DisplayNameDescription"))
                                                         ? rdr.GetString("DisplayNameDescription")
                                                         : null);
            }
            rdr.NextResult();
            while (rdr.Read())
            {
              var langCode =
                (LanguageCode)
                EnumHelper.GetEnumByValue(typeof (LanguageCode), rdr.GetInt32("LanguageCode").ToString());
              sharedProperty.LocalizedDescriptions.Add(langCode,
                                                       (!rdr.IsDBNull("Description"))
                                                         ? rdr.GetString("Description")
                                                         : null);
            }
          }
        }
        m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVED_LOCALE"));
      }
      if (sharedProperty == null)
        throw new DataException(resourceManager.GetLocalizedResource("TEXT_UNABLE_TO_RETRIEVE_SHARED_PROPERTY"));

      var vals = new List<SharedPropertyValueModel>();
      m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVING_SHARED_PROPERTY_VALUES"));
      GetSharedPropertyValuesForSharedProperty(sharedProperty.ID.Value, null, null, ref vals);
      sharedProperty.SharedPropertyValues = vals;
      m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVED_SHARED_PROPERTY_VALUES"));
    }

    public void GetSharedProperties(List<FilterElement> filterpropertiesList, List<SortCriteria> sortCriteria,
                                    ref List<SharedPropertyModel> sharedProperties)
    {
      var resourceManager = new ResourcesManager();
      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
        {
          using (
            IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("Queries\\PCWS", "__GET_SPECS__"))
          {
            ApplySortingFiltering(filterpropertiesList, sortCriteria, stmt);
            using (IMTDataReader dataReader = stmt.ExecuteReader())
            {
              while (dataReader.Read())
              {
                var sharedProperty = new SharedPropertyModel();
                sharedProperty.ID = dataReader.GetInt32("ID");
                var sharedPropertyType =
                  (PropertyType)
                  EnumHelper.GetEnumByValue(typeof (PropertyType),
                                            dataReader.GetInt32("SpecType").ToString());
                sharedProperty.PropType = sharedPropertyType;
                sharedProperty.Category = dataReader.GetString("Category");
                sharedProperty.IsRequired = dataReader.GetBoolean("IsRequired");
                sharedProperty.Description = dataReader.GetString("Description");
                sharedProperty.Name = dataReader.GetString("Name");
                sharedProperty.UserVisible = dataReader.GetBoolean("UserVisible");
                sharedProperty.UserEditable = dataReader.GetBoolean("UserEditable");
                sharedProperties.Add(sharedProperty);
              }
            }
          }
        }

        m_logger.LogDebug(String.Format("{0} {1}", sharedProperties.Count,
                                        resourceManager.GetLocalizedResource("TEXT_RETRIEVED")));
      }
      catch (CommunicationException e)
      {
        m_logger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SHARED_PROPERTIES"), e);
        throw;
      }

      catch (Exception e)
      {
        m_logger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SHARED_PROPERTIES"), e);
        throw new DataException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SHARED_PROPERTIES"));
      }
    }

    public void RemoveSharedPropertyFromEntity(int sharedPropertyId, int entityId)
    {
      var resourceManager = new ResourcesManager();
      try
      {
        m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_REMOVING_SHARED_PROPERTY_FROM_ENTITY"));
        using (
          TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                        new TransactionOptions(),
                                                        EnterpriseServicesInteropOption.Full))
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
          {
            using (
              IMTAdapterStatement checkSharedPropertyStmt = conn.CreateAdapterStatement("Queries\\PCWS",
                                                                                        "__CHECK_SPEC_ON_ENTITY__"))
            {
              checkSharedPropertyStmt.AddParam("%%ID_SPEC%%", sharedPropertyId);
              checkSharedPropertyStmt.AddParam("%%ID_ENTITY%%", entityId);
              using (IMTDataReader rdr = checkSharedPropertyStmt.ExecuteReader())
              {
                while (rdr.Read())
                {
                  int count = rdr.GetInt32("NumVals");
                  if (count != 0)
                    throw new DataException(
                      resourceManager.GetLocalizedResource(
                        "TEXT_UNABLE_TO_REMOVE_SHARED_PROPERTY_FROM_ENTITY"));
                }
              }
            }
            using (
              IMTAdapterStatement deleteSharedPropertyStmt = conn.CreateAdapterStatement("queries\\PCWS",
                                                                                         "__REMOVE_SPEC_FROM_ENTITY__")
              )
            {
              deleteSharedPropertyStmt.AddParam("%%ID_SPEC%%", sharedPropertyId);
              deleteSharedPropertyStmt.AddParam("%%ID_ENTITY%%", entityId);
              deleteSharedPropertyStmt.ExecuteNonQuery();
            }
          }
          scope.Complete();
        }
        m_auditor.FireEvent((int) MTAuditEvent.AUDITEVENT_REMOVE_SPEC_FROM_ENTITY, m_auditIdAcc,
                            (int) MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, entityId,
                            resourceManager.GetLocalizedResource("TEXT_REMOVED_SHARED_PROPERTY_FROM_ENTITY"));
      }

      catch (DataException masE)
      {

        m_logger.LogException(
          resourceManager.GetLocalizedResource("TEXT_UNABLE_TO_REMOVE_SHARED_PROPERTY_FROM_ENTITY"), masE);
        throw masE;
      }
      catch (Exception e)
      {
        m_logger.LogException(
          resourceManager.GetLocalizedResource("TEXT_UNABLE_TO_REMOVE_SHARED_PROPERTY_FROM_ENTITY"), e);
        throw new DataException(resourceManager.GetLocalizedResource("TEXT_REVIEW_LOGS"));
      }
    }


    public void RemoveSharedPropertyFromEntity(int sharedPropertyId, int entityId, EntityType entityType)
    {
      var resourceManager = new ResourcesManager();
      try
      {
        m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_REMOVING_SHARED_PROPERTY_FROM_ENTITY_WITH_ENTITY_TYPE") + 
          EnumHelper.GetCSharpEnum((int)EnumHelper.GetDbValueByEnum(entityType)));
        using (
          TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                        new TransactionOptions(),
                                                        EnterpriseServicesInteropOption.Full))
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
          {
            if (entityType == EntityType.ProductOffering) // only check for subscriptions to product offerings where id_po = entityId if the entityType = EntityType.ProductOffering
            {
              using (
                IMTAdapterStatement checkSharedPropertyStmt = conn.CreateAdapterStatement("Queries\\PCWS",
                                                                                          "__CHECK_SPEC_ON_ENTITY__"))
              {
                checkSharedPropertyStmt.AddParam("%%ID_SPEC%%", sharedPropertyId);
                checkSharedPropertyStmt.AddParam("%%ID_ENTITY%%", entityId);
                using (IMTDataReader rdr = checkSharedPropertyStmt.ExecuteReader())
                {
                  while (rdr.Read())
                  {
                    int count = rdr.GetInt32("NumVals");
                    if (count != 0)
                      throw new DataException(
                        resourceManager.GetLocalizedResource(
                          "TEXT_UNABLE_TO_REMOVE_SHARED_PROPERTY_FROM_ENTITY"));
                  }
                }
              }
            }
            using (
              IMTAdapterStatement deleteSharedPropertyStmt = conn.CreateAdapterStatement("queries\\PCWS",
                                                                                         "__REMOVE_SPEC_FROM_ENTITY_WITH_ENTITY_TYPE__")
              )
            {
              deleteSharedPropertyStmt.AddParam("%%ID_SPEC%%", sharedPropertyId);
              deleteSharedPropertyStmt.AddParam("%%ID_ENTITY%%", entityId);
              deleteSharedPropertyStmt.AddParam("%%ENTITY_TYPE%%", EnumHelper.GetCSharpEnum((int)EnumHelper.GetDbValueByEnum(entityType)));
              deleteSharedPropertyStmt.ExecuteNonQuery();
            }
          }
          scope.Complete();
        }
        m_auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_REMOVE_SPEC_FROM_ENTITY, m_auditIdAcc,
                            (int)MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, entityId,
                            resourceManager.GetLocalizedResource("TEXT_REMOVED_SHARED_PROPERTY_FROM_ENTITY_WITH_ENTITY_TYPE") +
                            EnumHelper.GetCSharpEnum((int)EnumHelper.GetDbValueByEnum(entityType)));
      }

      catch (DataException masE)
      {

        m_logger.LogException(
          resourceManager.GetLocalizedResource("TEXT_UNABLE_TO_REMOVE_SHARED_PROPERTY_FROM_ENTITY"), masE);
        throw masE;
      }
      catch (Exception e)
      {
        m_logger.LogException(
          resourceManager.GetLocalizedResource("TEXT_UNABLE_TO_REMOVE_SHARED_PROPERTY_FROM_ENTITY"), e);
        throw new DataException(resourceManager.GetLocalizedResource("TEXT_REVIEW_LOGS"));
      }
    }

    public void DeleteSharedProperty(int sharedPropertyId)
    {
      var resourceManager = new ResourcesManager();
      try
      {
        m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_DELETING_SHARED_PROPERTY"));
        using (
          TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                        new TransactionOptions(),
                                                        EnterpriseServicesInteropOption.Full))
        {
          bool sharedPropertyInUse = false;
          int categoryId = -1;
          int nameId = -1;
          int descId = -1;

          using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
          {
            // check to see if this shared property is associated with an entity
            using (
              IMTAdapterStatement checkSharedPropertyStmt = conn.CreateAdapterStatement("queries\\PCWS",
                                                                                        "__CHECK_IF_SPEC_IS_USED__")
              )
            {
              checkSharedPropertyStmt.AddParam("%%ID_SPEC%%", sharedPropertyId);
              checkSharedPropertyStmt.ExecuteNonQuery();

              using (IMTDataReader sharedPropertyReader = checkSharedPropertyStmt.ExecuteReader())
                while (sharedPropertyReader.Read())
                {
                  int numSharedProperties = sharedPropertyReader.GetInt32("NumSpec");
                  if (numSharedProperties != 0)
                  {
                    sharedPropertyInUse = true;
                    break;
                  }
                  categoryId = sharedPropertyReader.GetInt32("CategoryId");
                  nameId = sharedPropertyReader.GetInt32("NameId");
                  descId = sharedPropertyReader.GetInt32("DescId");
                }

              if (sharedPropertyInUse)
                throw new DataException(
                  resourceManager.GetLocalizedResource("TEXT_CANNOT_DELETE_SHARED_PROPERTY_IN_USE"));

              using (
                IMTAdapterStatement deleteSharedPropertyStmt = conn.CreateAdapterStatement("queries\\PCWS",
                                                                                           "__DELETE_SPEC_AND_MAP_DETAILS__")
                )
              {
                deleteSharedPropertyStmt.AddParam("%%ID_CATEGORY%%", categoryId);
                deleteSharedPropertyStmt.AddParam("%%ID_DISPLAY_NAME%%", nameId);
                deleteSharedPropertyStmt.AddParam("%%ID_DESC%%", descId);
                deleteSharedPropertyStmt.AddParam("%%ID_SPEC%%", sharedPropertyId);
                deleteSharedPropertyStmt.ExecuteNonQuery();
              }
            }

          }
          scope.Complete();
        }
        m_auditor.FireEvent((int) MTAuditEvent.AUDITEEVENT_DELETE_SPEC_CHAR, m_auditIdAcc,
                            (int) MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
                            resourceManager.GetLocalizedResource("TEXT_DELETED_SHARED_PROPERTY"));
      }
      catch (DataException masE)
      {
        m_auditor.FireFailureEvent((int) MTAuditEvent.AUDITEEVENT_DELETE_SPEC_CHAR_FAILED, m_auditIdAcc,
                                   (int) MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
                                   resourceManager.GetLocalizedResource("TEXT_COULD_NOT_DELETE_SPEC"));
        m_logger.LogException(resourceManager.GetLocalizedResource("TEXT_COULD_NOT_DELETE_SHARED_PROPERTY"),
                              masE);
        throw masE;
      }
      catch (Exception e)
      {
        m_auditor.FireFailureEvent((int) MTAuditEvent.AUDITEEVENT_DELETE_SPEC_CHAR_FAILED, m_auditIdAcc,
                                   (int) MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
                                   resourceManager.GetLocalizedResource("TEXT_COULD_NOT_DELETE_SHARED_PROPERTY"));
        m_logger.LogException(resourceManager.GetLocalizedResource("TEXT_COULD_NOT_DELETE_SHARED_PROPERTY"), e);
        throw new DataException(resourceManager.GetLocalizedResource("TEXT_REVIEW_LOGS"));
      }
    }

    public void AddSharedPropertyValuesToSharedProperty(int sharedPropertyId, List<int> valueIds)
    {
      var resourceManager = new ResourcesManager();
      try
      {
        string insertStmt = "BEGIN\n";
        m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_CREATING_SHARED_PROPERTY_VALUE_MAP"));
        using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
        {
          IMTQueryAdapter qa = new MTQueryAdapterClass();
          qa.Init(@"Queries\PCWS");

          foreach (int val in valueIds)
          {
            qa.SetQueryTag("__ADD_SPEC_VAL_MAP_ENTRY__");
            qa.AddParam("%%ID_SPEC%%", sharedPropertyId);
            qa.AddParam("%%ID_SCV%%", val);
            insertStmt += qa.GetQuery().Trim() + ";\n";
          }
          insertStmt += "END;";

          using (IMTStatement stmt = conn.CreateStatement(insertStmt))
          {
            stmt.ExecuteNonQuery();
          }
        }
        m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_CREATED_SHARED_PROPERTY_VALUE_MAP"));
      }

      catch (CommunicationException e)
      {
        m_logger.LogException(
          resourceManager.GetLocalizedResource("TEXT_CREATE_SHARED_PROPERTY_VALUE_MAP_FAILED"), e);
        throw;
      }
      catch (Exception e)
      {
        m_logger.LogException(
          resourceManager.GetLocalizedResource("TEXT_CREATE_SHARED_PROPERTY_VALUE_MAP_FAILED"), e);
        throw new DataException(
          resourceManager.GetLocalizedResource("TEXT_CREATE_SHARED_PROPERTY_VALUE_MAP_FAILED"));
      }
    }

    public void RemoveSharedPropertyValuesFromSharedProperty(int sharedPropertyId, List<int> valueIds, int? entityId)
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
            TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                          new TransactionOptions(),
                                                          EnterpriseServicesInteropOption.Full))
          {
            string deleteStmt = "BEGIN\n";
            m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_REMOVING_SHARED_PROPERTY_VALUE_MAP"));
            using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
            {
              if (entityId.HasValue)
              {
                using (
                  IMTAdapterStatement checkSharedPropertyStmt = conn.CreateAdapterStatement("queries\\PCWS",
                                                                                            "__CHECK_IF_VALS_ARE_USED__")
                  )
                {
                  checkSharedPropertyStmt.AddParam("%%ID_SPEC%%", sharedPropertyId);
                  checkSharedPropertyStmt.AddParam("%%ID_SCV%%", ids);
                  checkSharedPropertyStmt.AddParam("%%ENTITY_CLAUSE%%",
                                                   String.Format(" and specs.id_entity = {0}", entityId));

                  checkSharedPropertyStmt.ExecuteNonQuery();

                  using (IMTDataReader sharedPropertyReader = checkSharedPropertyStmt.ExecuteReader())
                    while (sharedPropertyReader.Read())
                    {
                      int numSharedPoperties = sharedPropertyReader.GetInt32("NumVals");
                      if (numSharedPoperties != 0)
                        valInUse = true;
                    }
                }
              }
              if (valInUse)
                throw new DataException(
                  resourceManager.GetLocalizedResource("TEXT_SHARED_PROPERTY_VALUE_MAPPING_IN_USE"));

              IMTQueryAdapter qa = new MTQueryAdapterClass();
              qa.Init(@"Queries\PCWS");

              foreach (int val in valueIds)
              {
                qa.SetQueryTag("__DELETE_SPEC_CHAR_VAL_MAP_ENTRY__");
                qa.AddParam("%%ID_SPEC%%", sharedPropertyId);
                qa.AddParam("%%ID_SCV%%", val);
                deleteStmt += qa.GetQuery().Trim() + ";\n";
              }
              deleteStmt += "END;";

              using (IMTStatement stmt = conn.CreateStatement(deleteStmt))
              {
                stmt.ExecuteNonQuery();
              }
            }

            m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_REMOVED_SHARED_PROPERTY_VALUE_MAP"));
            scope.Complete();
          }
          m_auditor.FireEvent((int) MTAuditEvent.AUDITEVENT_REMOVED_CHAR_VAL, m_auditIdAcc,
                              (int) MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
                              resourceManager.GetLocalizedResource("TEXT_REMOVED_SHARED_PROPERTY_VALUE_MAP"));
        }
        catch (CommunicationException e)
        {
          m_auditor.FireFailureEvent((int) MTAuditEvent.AUDITEVENT_REMOVED_CHAR_VAL_FAILED,
                                     this.m_auditIdAcc, (int) MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
                                     resourceManager.GetLocalizedResource(
                                       "TEXT_REMOVE_SHARED_PROPERTY_VALUE_MAP_FAILED"));
          m_logger.LogException(
            resourceManager.GetLocalizedResource("TEXT_REMOVE_SHARED_PROPERTY_VALUE_MAP_FAILED"), e);
          throw;
        }

        catch (Exception e)
        {
          m_auditor.FireFailureEvent((int) MTAuditEvent.AUDITEVENT_REMOVED_CHAR_VAL_FAILED,
                                     m_auditIdAcc, (int) MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
                                     resourceManager.GetLocalizedResource(
                                       "TEXT_REMOVE_SHARED_PROPERTY_VALUE_MAP_FAILED"));
          m_logger.LogException(
            resourceManager.GetLocalizedResource("TEXT_REMOVE_SHARED_PROPERTY_VALUE_MAP_FAILED"), e);
          throw new DataException(
            resourceManager.GetLocalizedResource("TEXT_REMOVE_SHARED_PROPERTY_VALUE_MAP_FAILED"));
        }
      }
      else
      {
        m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_NO_VALS_TO_DELETE"));
      }
    }

    public void GetSharedPropertyValuesForSharedProperty(int sharedPropertyId,
                                                         List<FilterElement> filterpropertiesList,
                                                         List<SortCriteria> sortCriteria,
                                                         ref List<SharedPropertyValueModel> vals)
    {
      var resourceManager = new ResourcesManager();
      try
      {
        m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVING_SHARED_PROPERTY_VALUES"));
        using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
        {
          string valueIds = "";
          var valDictionary = new Dictionary<int, SharedPropertyValueModel>();
          using (
            IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("Queries\\PCWS",
                                                                         "__GET_SPEC_CHAR_VALS_FOR_SPEC__"))
          {
            ApplySortingFiltering(filterpropertiesList, sortCriteria, stmt);
            stmt.AddParam("%%ID_SPEC%%", sharedPropertyId);
            using (IMTDataReader dataReader = stmt.ExecuteReader())
            {
              while (dataReader.Read())
              {
                var val = new SharedPropertyValueModel();
                int id = dataReader.GetInt32("ID");
                val.ID = id;
                val.IsDefault = dataReader.GetBoolean("IsDefault");
                val.ValueID = dataReader.GetInt32("ValueId");
                val.Value = dataReader.GetString("Value");
                valDictionary.Add(id, val);
                vals.Add(val);
              }
            }

            GetLocalizationDetailsForSharedPropertyValues(valueIds, conn, valDictionary);
          }
          m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVED_SHARED_PROPERTY_VALUES"));
        }
      }
      catch (CommunicationException e)
      {
        m_logger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SHARED_PROPERTY_VALUES"), e);
        throw;
      }

      catch (Exception e)
      {
        m_logger.LogException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SHARED_PROPERTY_VALUES"), e);
        throw new DataException(resourceManager.GetLocalizedResource("TEXT_CANNOT_GET_SHARED_PROPERTY_VALUES"));
      }
    }

    #endregion

    #region private methods

    private void GetLocalizationDetailsForSharedPropertyValues(string valIds, IMTConnection conn,
                                                               Dictionary<int, SharedPropertyValueModel>
                                                                 valDictionary)
    {
      if (valIds.Length > 0)
      {
        // remove trailing comma
        int length = valIds.Length - 1;
        valIds = valIds.Remove(length, 1);

        using (
          IMTAdapterStatement local = conn.CreateAdapterStatement("Queries\\PCWS",
                                                                  "__GET_DESCRIPTION_DETAILS__"))
        {
          local.AddParam("%%ID_DESCRIPTIONS%%", valIds);
          using (IMTDataReader localizedReader = local.ExecuteReader())
          {
            while (localizedReader.Read())
            {
              int id = localizedReader.GetInt32("ID");
              SharedPropertyValueModel val = valDictionary[id];
              if (!localizedReader.IsDBNull("LanguageCode"))
              {
                val.LocalizedDisplayValues = new Dictionary<LanguageCode, string>();
                LanguageCode langCode =
                  (LanguageCode)
                  EnumHelper.GetEnumByValue(typeof (LanguageCode),
                                            localizedReader.GetInt32("LanguageCode").ToString());
                val.LocalizedDisplayValues.Add(langCode,
                                               (!localizedReader.IsDBNull("Description"))
                                                 ? localizedReader.GetString("Description")
                                                 : null);
              }
            }
          }
        }
      }
    }

    /// <summary>Gets first id_spec for shared property with the same name, category and description
    /// </summary>
    /// <param name="sharedProperty">populated SharedPropertyModel to search for in the database by name, description, and category</param>
    /// <returns>Returns -1 in case no entities found</returns>
    private int GetSharedPropertyId(SharedPropertyModel sharedProperty)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
      {
        using (
          IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\PCWS", "__GET_SPEC_ID__")
          )
        {
          stmt.AddParam("%%CATEGORY%%", sharedProperty.Category);
          stmt.AddParam("%%DESCRIPTION%%", sharedProperty.Description);
          stmt.AddParam("%%NAME%%", sharedProperty.Name);

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

    /// <summary>
    /// Save a shared property to the database
    /// </summary>
    /// <param name="sharedProperty">populated shared property object to save to database. If the shared property object has the ID set, then the existing
    /// shared property with that unique id is updated in the database. Otherwise, a new shared property is created in the database with a new unique id.
    /// </param>
    /// <param name="entityId">The unique identifier for the MetraNet entity to save shared property for. If this entityId is null, then no checks are made
    ///  to see if the shared property values are in use when making updates to the shared property values for the shared property being saved. If this entity is
    /// not null, then checks to see if any subscriptions exist to a product offering with id_po = entityId. If there are subscriptions, then the existing
    /// shared property values are not removed from this shared property at all.</param>
    private void SaveSharedPropertyInternal(ref SharedPropertyModel sharedProperty, int? entityId)
    {
      var resourceManager = new ResourcesManager();
      if (sharedProperty.ID.HasValue)
      {
        m_logger.LogDebug(String.Format("{0} {1}",
                                        resourceManager.GetLocalizedResource("TEXT_UPDATING_SHARED_PROPERTY"),
                                        sharedProperty.Name));
        using (
          var scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(),
                                           EnterpriseServicesInteropOption.Full))
        {
          m_logger.LogDebug("TXN ISOLATION LEVEL IN SaveSharedProperty" +
                            Transaction.Current.IsolationLevel.ToString());
          string insertStmt = "BEGIN\n";
          int categoryId = -1;
          int descId = -1;
          int nameId = -1;
          IdGenerator sharedPropertyDetailIdGenerator = null;

          using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
          {
            using (
              IMTAdapterStatement getLocalDataStmt = conn.CreateAdapterStatement("queries\\PCWS",
                                                                                 "__GET_SPEC_LOCALIZATION_DATA__")
              )
            {
              getLocalDataStmt.AddParam("%%ID_SPEC%%", sharedProperty.ID.Value);
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
              throw new DataException(resourceManager.GetLocalizedResource("TEXT_COULD_NOT_GET_LOCALE"));

            m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVED_LOCALE"));

            using (
              IMTAdapterStatement updateSharedPropertyStmt = conn.CreateAdapterStatement("queries\\PCWS",
                                                                                         "__UPDATE_SPEC_CHARACTERISTIC__")
              )
            {
              updateSharedPropertyStmt.AddParam("%%SPEC_TYPE%%", sharedProperty.PropType);
              updateSharedPropertyStmt.AddParam("%%CATEGORY%%", sharedProperty.Category);
              if (sharedProperty.IsRequired)
                updateSharedPropertyStmt.AddParam("%%C_IS_REQUIRED%%", "Y");
              else
                updateSharedPropertyStmt.AddParam("%%C_IS_REQUIRED%%", "N");
              updateSharedPropertyStmt.AddParam("%%NM_DESCRIPTION%%", sharedProperty.Description);
              updateSharedPropertyStmt.AddParam("%%NM_NAME%%", sharedProperty.Name);
              if (sharedProperty.UserVisible)
                updateSharedPropertyStmt.AddParam("%%C_USER_VISIBLE%%", "Y");
              else
                updateSharedPropertyStmt.AddParam("%%C_USER_VISIBLE%%", "N");

              if (sharedProperty.UserEditable)
                updateSharedPropertyStmt.AddParam("%%C_USER_EDITABLE%%", "Y");
              else
                updateSharedPropertyStmt.AddParam("%%C_USER_EDITABLE%%", "N");
              updateSharedPropertyStmt.AddParam("%%ID_SPEC%%", sharedProperty.ID.Value);
              updateSharedPropertyStmt.AddParam("%%MIN_VALUE%%", sharedProperty.MinValue);
              updateSharedPropertyStmt.AddParam("%%MAX_VALUE%%", sharedProperty.MaxValue);

              updateSharedPropertyStmt.ExecuteNonQuery();
            }


            ProcessLocalizationData(nameId, sharedProperty.LocalizedDisplayNames, descId,
                                    sharedProperty.LocalizedDescriptions);
            ProcessLocalizationData(categoryId, sharedProperty.LocalizedCategories, null, null);

            m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_PROCESSED_LOCALE"));
            // update the shared property values
            // UI will send null if they want to update the shared property but not values
            if (sharedProperty.SharedPropertyValues != null)
            {
              m_logger.LogDebug(
                resourceManager.GetLocalizedResource("TEXT_UPDATING_VALUES_FOR_SHARED_PROPERTY"));
              var vals = new List<SharedPropertyValueModel>();
              GetSharedPropertyValuesForSharedProperty(sharedProperty.ID.Value, null, null, ref vals);

              var valIds = new List<int>();
              foreach (SharedPropertyValueModel v in vals)
              {
                valIds.Add(v.ID.Value);
              }

              // remove the values from the map
              RemoveSharedPropertyValuesFromSharedProperty(sharedProperty.ID.Value, valIds, entityId);

              // find the shared properties that are new vals or existing vals
              List<SharedPropertyValueModel> newVals =
                sharedProperty.SharedPropertyValues.FindAll(s => !s.ID.HasValue);
              var addVals = new List<SharedPropertyValueModel>();
              List<SharedPropertyValueModel> oldVals =
                sharedProperty.SharedPropertyValues.FindAll(s => s.ID.HasValue);

              foreach (SharedPropertyValueModel s in newVals)
                addVals.Add(s);

              if (newVals.Count > 0)
              {
                int blockSize = newVals.Count;
                sharedPropertyDetailIdGenerator = new IdGenerator("id_scv", blockSize);
                AddNewSharedPropertyCharVals(conn, sharedPropertyDetailIdGenerator, addVals,
                                             sharedProperty.ID.Value);
              }

              // TODO: this needs to be optimized . . .

              // check to see if the localization has been added or not
              foreach (var valLoc in oldVals)
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

                foreach (var val in oldVals)
                {
                  qa.SetQueryTag("__UPDATE_SPEC_CHAR_VAL_BULK__");
                  if (val.IsDefault)
                    qa.AddParam("%%C_IS_DEFAULT%%", "Y");
                  else
                    qa.AddParam("%%C_IS_DEFAULT%%", "N");
                  qa.AddParam("%%N_VALUE%%", val.ValueID);
                  qa.AddParam("%%NM_VALUE%%", val.Value);
                  qa.AddParam("%%ID_SCV%%", val.ID.Value);
                  qa.AddParam("%%ID_SPEC%%", sharedProperty.ID.Value);
                  insertStmt += qa.GetQuery().Trim() + ";\n";
                }
                insertStmt += "END;";
                using (IMTStatement updateStmt = conn.CreateStatement(insertStmt))
                {
                  updateStmt.ExecuteNonQuery();
                }
              }
              
              foreach (var val in oldVals)
              {
                ProcessLocalizationData(val.ValueID, val.LocalizedDisplayValues, null, null);
              }
              m_logger.LogDebug(
                resourceManager.GetLocalizedResource("TEXT_UPDATED_VALUES_FOR_SHARED_PROPERTY"));
            }
          }
          scope.Complete();
        }
        m_auditor.FireEvent((int) MTAuditEvent.AUDITEVENT_UPDATE_SPEC_CHAR, m_auditIdAcc,
                            (int) MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
                            resourceManager.GetLocalizedResource("TEXT_UPDATED_SHARED_PROPERTY"));
        m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_UPDATED_SHARED_PROPERTY"));
      }
      else
      {
        #region save shared property value

        m_logger.LogInfo(resourceManager.GetLocalizedResource("TEXT_CREATING_SHARED_PROPERTY"));

        try
        {
          IdGenerator sharedPropertyIdGenerator = new IdGenerator("id_spec", 1);
          int specId = sharedPropertyIdGenerator.NextId;
          IdGenerator sharedPropertyDetailIdGenerator = null;
          bool hasSharedPropertyDetails = false;
          sharedProperty.ID = specId;

          if (sharedProperty.SharedPropertyValues.Count != 0)
          {
            hasSharedPropertyDetails = true;
            // TODO: Grab a block of ids for the detail
            int blockSize = sharedProperty.SharedPropertyValues.Count;
            sharedPropertyDetailIdGenerator = new IdGenerator("id_scv", blockSize);
          }

          int descId = -1;
          int nameId = -1;
          int categoryId = -1;

          using (
            TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                          new TransactionOptions(),
                                                          EnterpriseServicesInteropOption.Full))
          {
            m_logger.LogDebug("TXN ISOLATION LEVEL IN savesharedpropertycharacteristics" +
                              Transaction.Current.IsolationLevel.ToString());
            using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
            {
              using (IMTCallableStatement stmt = conn.CreateCallableStatement("UpsertDescriptionV2"))
              {
                stmt.AddParam("id_lang_code", MTParameterType.Integer, m_languageID);
                stmt.AddParam("a_nm_desc", MTParameterType.WideString, sharedProperty.Description);
                stmt.AddParam("a_id_desc_in", MTParameterType.Integer, null);
                stmt.AddOutputParam("a_id_desc", MTParameterType.Integer);
                stmt.ExecuteNonQuery();
                descId = (int) stmt.GetOutputValue("a_id_desc");
              }

              using (IMTCallableStatement stmt1 = conn.CreateCallableStatement("UpsertDescriptionV2"))
              {
                stmt1.AddParam("id_lang_code", MTParameterType.Integer, m_languageID);
                stmt1.AddParam("a_nm_desc", MTParameterType.WideString, sharedProperty.Description);
                stmt1.AddParam("a_id_desc_in", MTParameterType.Integer, null);
                stmt1.AddOutputParam("a_id_desc", MTParameterType.Integer);
                stmt1.ExecuteNonQuery();
                nameId = (int) stmt1.GetOutputValue("a_id_desc");
              }

              using (IMTCallableStatement stmt2 = conn.CreateCallableStatement("UpsertDescriptionV2"))
              {
                stmt2.AddParam("id_lang_code", MTParameterType.Integer, m_languageID);
                stmt2.AddParam("a_nm_desc", MTParameterType.WideString, sharedProperty.Description);
                stmt2.AddParam("a_id_desc_in", MTParameterType.Integer, null);
                stmt2.AddOutputParam("a_id_desc", MTParameterType.Integer);
                stmt2.ExecuteNonQuery();
                categoryId = (int) stmt2.GetOutputValue("a_id_desc");
              }

              if ((nameId == -1) || (descId == -1) || (categoryId == -1))
                throw new DataException(resourceManager.GetLocalizedResource("TEXT_PROCESSED_LOCALE"));

              using (
                IMTAdapterStatement createSharedPropertyStmt = conn.CreateAdapterStatement("queries\\PCWS",
                                                                                           "__ADD_SPEC__"))
              {
                createSharedPropertyStmt.AddParam("%%ID_SPEC%%", specId);
                createSharedPropertyStmt.AddParam("%%C_SPEC_TYPE%%",
                                                  EnumHelper.GetValueByEnum(sharedProperty.PropType));
                createSharedPropertyStmt.AddParam("%%ID_CATEGORY%%", categoryId);
                createSharedPropertyStmt.AddParam("%%C_CATEGORY%%", sharedProperty.Category);
                if (sharedProperty.IsRequired)
                  createSharedPropertyStmt.AddParam("%%C_IS_REQUIRED%%", "Y");
                else
                  createSharedPropertyStmt.AddParam("%%C_IS_REQUIRED%%", "N");
                createSharedPropertyStmt.AddParam("%%N_DESCRIPTION%%", descId);
                createSharedPropertyStmt.AddParam("%%NM_DESCRIPTION%%", sharedProperty.Description);
                createSharedPropertyStmt.AddParam("%%N_NAME%%", nameId);
                createSharedPropertyStmt.AddParam("%%NM_NAME%%", sharedProperty.Name);
                if (sharedProperty.UserVisible)
                  createSharedPropertyStmt.AddParam("%%C_USER_VISIBLE%%", "Y");
                else
                  createSharedPropertyStmt.AddParam("%%C_USER_VISIBLE%%", "N");

                if (sharedProperty.UserEditable)
                  createSharedPropertyStmt.AddParam("%%C_USER_EDITABLE%%", "Y");
                else
                  createSharedPropertyStmt.AddParam("%%C_USER_EDITABLE%%", "N");

                createSharedPropertyStmt.AddParam("%%MIN_VALUE%%", sharedProperty.MinValue);
                createSharedPropertyStmt.AddParam("%%MAX_VALUE%%", sharedProperty.MaxValue);
                createSharedPropertyStmt.ExecuteNonQuery();
              }

              if (hasSharedPropertyDetails)
              {
                m_logger.LogDebug(resourceManager.GetLocalizedResource("ADDING_SHARED_PROPERTY_VALUES"));
                var vals = new List<SharedPropertyValueModel>();
                foreach (var val in sharedProperty.SharedPropertyValues)
                {
                  vals.Add(val);
                }
                AddNewSharedPropertyCharVals(conn, sharedPropertyDetailIdGenerator, vals,
                                             sharedProperty.ID.Value);
                m_logger.LogDebug(resourceManager.GetLocalizedResource("ADDED_SHARED_PROPERTY_VALUES"));
              }

              ProcessLocalizationData(nameId, sharedProperty.LocalizedDisplayNames, descId,
                                      sharedProperty.LocalizedDescriptions);

              ProcessLocalizationData(categoryId, sharedProperty.LocalizedCategories, null, null);
            }
            scope.Complete();
          }
          m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_CREATED_SHARED_PROPERTY"));
          m_auditor.FireEvent((int) MTAuditEvent.AUDITEVENT_CREATE_SPEC_CHAR, m_auditIdAcc,
                              (int) MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
                              resourceManager.GetLocalizedResource("TEXT_CREATED_SHARED_PROPERTY"));
        }
        catch (DataException masE)
        {
          m_auditor.FireFailureEvent((int) MTAuditEvent.AUDITEVENT_CREATE_SPEC_CHAR_FAILED, m_auditIdAcc,
                                     (int) MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
                                     resourceManager.GetLocalizedResource("TEXT_CREATE_SHARED_PROPERTY_FAILED"));
          m_logger.LogException(resourceManager.GetLocalizedResource("TEXT_CREATE_SHARED_PROPERTY_FAILED"),
                                masE);
          throw masE;
        }
        catch (Exception e)
        {
          m_auditor.FireFailureEvent((int) MTAuditEvent.AUDITEVENT_CREATE_SPEC_CHAR_FAILED, m_auditIdAcc,
                                     (int) MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
                                     resourceManager.GetLocalizedResource("TEXT_CREATE_SHARED_PROPERTY_FAILED"));
          m_logger.LogException(resourceManager.GetLocalizedResource("TEXT_CREATE_SHARED_PROPERTY_FAILED"), e);

          throw new Exception(resourceManager.GetLocalizedResource("TEXT_REVIEW_LOGS"));
        }

        #endregion
      }
    }

    /// <summary>
    /// Save a description to the t_description table in the NetMeter database. The language code used is the language code for the logged in user.
    /// </summary>
    /// <param name="desc">text for description to save to database</param>
    /// <param name="conn">open IMTConnection to NetMeter database</param>
    /// <returns>unique identifier of the t_description row inserted or updated by this method</returns>
    private int AddDescription(string desc, IMTConnection conn)
    {
      int descId = -1;
      using (IMTCallableStatement stmt = conn.CreateCallableStatement("UpsertDescriptionV2"))
      {
        stmt.AddParam("id_lang_code", MTParameterType.Integer, m_languageID);
        stmt.AddParam("a_nm_desc", MTParameterType.WideString, desc);
        stmt.AddParam("a_id_desc_in", MTParameterType.Integer, null);
        stmt.AddOutputParam("a_id_desc", MTParameterType.Integer);
        stmt.ExecuteNonQuery();
        descId = (int) stmt.GetOutputValue("a_id_desc");
      }
      return descId;
    }

    /// <summary>
    /// Save values for a shared property in database
    /// </summary>
    /// <param name="conn">open IMTConnection to NetMeter database</param>
    /// <param name="sharedPropertyDetailIdGenerator">IdGenerator that has been seeded with ("id_scv", blockSize). This is used
    /// for generating the unique id for each new value saved to the database for the specified shared property.</param>
    /// <param name="sharedPropertyValues">List of values to save to database for the specified shared property</param>
    /// <param name="specId">The unique identifier for the shared property to save values for</param>
    private void AddNewSharedPropertyCharVals(IMTConnection conn,
                                              IdGenerator sharedPropertyDetailIdGenerator,
                                              List<SharedPropertyValueModel> sharedPropertyValues, int specId)
    {
      string insertStmt = "BEGIN\n";

      IMTQueryAdapter qa = new MTQueryAdapterClass();
      qa.Init(@"Queries\PCWS");

      IMTQueryAdapter qa2 = new MTQueryAdapterClass();
      qa2.Init(@"Queries\PCWS");

      foreach (var sharedPropertyValue in sharedPropertyValues)
      {
        int descId = -1;
        using (IMTCallableStatement stmt = conn.CreateCallableStatement("UpsertDescriptionV2"))
        {
          stmt.AddParam("id_lang_code", MTParameterType.Integer, m_languageID);
          stmt.AddParam("a_nm_desc", MTParameterType.WideString, sharedPropertyValue.Value);
          stmt.AddParam("a_id_desc_in", MTParameterType.Integer, null);
          stmt.AddOutputParam("a_id_desc", MTParameterType.Integer);
          stmt.ExecuteNonQuery();
          descId = (int) stmt.GetOutputValue("a_id_desc");
        }

        int sharedPropertyValId = sharedPropertyDetailIdGenerator.NextId;
        sharedPropertyValue.ID = sharedPropertyValId;
        qa.SetQueryTag("__ADD_SPEC_CHAR_VAL__");
        qa.AddParam("%%ID_SCV%%", sharedPropertyValId, true);

        if (sharedPropertyValue.IsDefault)
          qa.AddParam("%%IS_DEFAULT%%", "Y", true);
        else
          qa.AddParam("%%IS_DEFAULT%%", "N", true);

        qa.AddParam("%%N_VALUE%%", descId, true);
        qa.AddParam("%%NM_VALUE%%", sharedPropertyValue.Value, true);
        insertStmt += qa.GetQuery().Trim() + ";\n";

        qa2.SetQueryTag("__ADD_SPEC_VAL_MAP_ENTRY__");
        qa2.AddParam("%%ID_SPEC%%", specId);
        qa2.AddParam("%%ID_SCV%%", sharedPropertyValId);
        insertStmt += qa2.GetQuery().Trim() + ";\n";
        ProcessLocalizationData(descId, sharedPropertyValue.LocalizedDisplayValues, null, null);
      }
      insertStmt += "END;";
      m_logger.LogDebug(insertStmt);
      using (IMTStatement stmt = conn.CreateStatement(insertStmt))
      {
        stmt.ExecuteNonQuery();
      }
    }

    /// <summary>
    /// Insert a new row into the NetMeter.t_entity_specs table for a given MetraNet entity/shared property combination. If the display order is not set in the 
    /// shared property object, do not set the display order in the database table for the new row inserted.
    /// </summary>
    /// <param name="entityId">The unique identifier for the MetraNet entity of the row in t_entity_specs to insert</param>
    /// <param name="entityType">The type of entity the entityId is for</param>
    /// <param name="sharedProperty">The populated shared property object to associate to the MetraNet entity in the new t_entity_specs table row</param>
    private void AddSharedPropertyToEntity(int entityId, EntityType entityType, SharedPropertyModel sharedProperty)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
      {
        using (
          IMTAdapterStatement sharedPropertyStmt = conn.CreateAdapterStatement("queries\\PCWS", "__ADD_SPEC_TO_ENTITY__")
          )
        {
          sharedPropertyStmt.AddParam("%%ID_ENTITY%%", entityId);
          sharedPropertyStmt.AddParam("%%ID_SPEC%%", sharedProperty.ID);
          if (sharedProperty.DisplayOrder.HasValue)
            sharedPropertyStmt.AddParam("%%C_DISPLAY_ORDER%%", sharedProperty.DisplayOrder.Value);
          else
            sharedPropertyStmt.AddParam("%%C_DISPLAY_ORDER%%", null);
          sharedPropertyStmt.AddParam("%%ENTITY_TYPE%%", EnumHelper.GetValueByEnum(entityType));
          sharedPropertyStmt.ExecuteNonQuery();
        }
      }
    }

    /// <summary>
    /// Update the display order in the NetMeter.t_entity_specs table for a given MetraNet entity/shared property combination
    /// </summary>
    /// <param name="entityId">The unique identifier for the MetraNet entity of the row in t_entity_specs to update</param>
    /// <param name="entityType">The type of entity the entityId is for</param>
    /// <param name="specId">The unique identifier for the shared property of the row in t_entity_specs to update</param>
    /// <param name="displayOrder">The new display order value to update the row in t_entity_specs to</param>
    private void UpdateDisplayOrder(int entityId, EntityType entityType, int specId, int displayOrder)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\PCWS"))
      {
        using (
          IMTAdapterStatement sharedPropertyStmt = conn.CreateAdapterStatement("queries\\PCWS",
                                                                               "__UPDATE_DISPLAY_ORDER_WITH_ENTITY_TYPE__")
          )
        {
          sharedPropertyStmt.AddParam("%%ID_ENTITY%%", entityId);
          sharedPropertyStmt.AddParam("%%ENTITY_TYPE%%", EnumHelper.GetCSharpEnum((int)EnumHelper.GetDbValueByEnum(entityType)));
          sharedPropertyStmt.AddParam("%%ID_SPEC%%", specId);
          sharedPropertyStmt.AddParam("%%C_DISPLAY_ORDER%%", displayOrder);
          sharedPropertyStmt.ExecuteNonQuery();
        }
      }
    }
  }

  #endregion
}