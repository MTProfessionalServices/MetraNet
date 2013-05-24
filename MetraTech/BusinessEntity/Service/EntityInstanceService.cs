using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;

using MetraTech.Basic;
using MetraTech.ActivityServices.Common;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.BusinessEntity.Service
{
  [ServiceContract()]
  public interface IEntityInstanceService
  {
  
    #region Create/Update
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SaveEntityInstance(ref EntityInstance entityInstance);

    [OperationContract()]
    [FaultContract(typeof (MASBasicFaultDetail))]
    void SaveEntityInstanceVoid(EntityInstance entityInstance);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SaveEntityInstances(ref List<EntityInstance> entityInstances);

    /// <summary>
    ///   Create the specified EntityInstance for the given related type (forEntityName) and id (forEntityId).
    /// </summary>
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void CreateEntityInstanceFor(string forEntityName, Guid forEntityId, ref EntityInstance entityInstance);

    /// <summary>
    ///   Create EntityInstances for the given related type (forEntityName) and id (forEntityId).
    /// </summary>
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void CreateEntityInstancesFor(string forEntityName, Guid forEntityId, ref List<EntityInstance> entityInstances);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void CreateRelationships(List<RelationshipEntityInstanceData> relationshipEntityInstanceDataList);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteRelationships(List<RelationshipEntityInstanceData> relationshipEntityInstanceDataList);


    /// <summary>
    /// Provides bulk update of properties [propertiesValues] entities with particular ids [ids]
    /// </summary>
    /// <param name="propertiesToUpdate">Name of properties to be updated</param>
    /// <param name="beInstance">Object with new property values</param>
    /// <param name="ids">Ids of items to be updated</param>
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void UpdateEntitiesByGuids(List<string> propertiesToUpdate, EntityInstance beInstance, Guid[] ids);

    /// <summary>
    /// Provides bulk update of properties [propertiesValues] entities with particular ids [ids]
    /// </summary>
    /// <param name="propertiesToUpdate">Name of properties to be updated</param>
    /// <param name="beInstance">Object with new property values</param>
    /// <param name="mtList">Items to be updated</param>
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void UpdateEntities(List<string> propertiesToUpdate, EntityInstance beInstance, MTList<EntityInstance> mtList);

    #endregion

    #region Load
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoadEntityInstance(string entityName, Guid id, out EntityInstance entityInstance);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoadEntityInstanceByBusinessKey(string entityName, List<PropertyInstance> businessKeyProperties, out EntityInstance entityInstance);
   
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoadEntityInstances(string entityName, ref MTList<EntityInstance> entityInstances);

    /// <summary>
    /// Returns entities of specified type [entityName] with particular ids [ids]
    /// </summary>
    /// <param name="entityName"></param>
    /// <param name="ids"></param>
    /// <param name="entityInstances"></param>
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoadEntityInstancesByGuids(string entityName, Guid[] ids, ref MTList<EntityInstance> entityInstances);

    /// <summary>
    ///   Returns the row of type [entityName] for the given related type [forEntityName] and id [forEntityId].
    ///   typeName and forTypeName must have a one-to-one relationship
    /// </summary>
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoadEntityInstanceFor(string entityName,
                               string forEntityName,
                               Guid forEntityId,
                               out EntityInstance entityInstance);

    /// <summary>
    ///   Returns rows of type [entityName] for the given related type [forEntityName] and id [forEntityId].
    /// </summary>
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoadEntityInstancesFor(string entityName,
                                string forEntityName,
                                Guid forEntityId,
                                ref MTList<EntityInstance> mtList);

    /// <summary>
    ///   Returns unrelated rows of type [entityName] for the given related type [forEntityName] and id [forEntityId].
    /// </summary>
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoadUnrelatedEntityInstancesFor(string entityName,
                                         string forEntityName,
                                         Guid forEntityId,
                                         ref MTList<EntityInstance> mtList);

    [OperationContract()]
    [FaultContract(typeof (MASBasicFaultDetail))]
    void LoadEntityInstancesForMetranetEntity(string entityName,
                                              MetranetEntity metranetEntity,
                                              ref MTList<EntityInstance> mtList);
    #endregion

    #region Delete
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteEntityInstanceUsingEntityName(string entityName, Guid id);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteEntityInstance(EntityInstance entityInstance);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteAllEntityInstances(string entityName);
    #endregion

    #region Capability
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void CheckCapability(string extensionName, AccessType accessType);
    #endregion

    #region Misc
    /// <summary>
    ///   Create a new entity instance for the given entityName.
    /// </summary>
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetNewEntityInstance(string entityName, out EntityInstance entityInstance);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetEntityInstanceBusinessKeyProperties(string entityName, out List<PropertyInstance> propertyInstances);




    #endregion
  }

  [ServiceBehavior()]
  public class EntityInstanceService : BusinessEntityService, IEntityInstanceService
  {
    #region IEntityInstanceService Members

    #region Create/Update
    public void SaveEntityInstance(ref EntityInstance entityInstance)
    {
      SaveEntityInstanceInternal(ref entityInstance, false);
    }

    public void SaveEntityInstanceVoid(EntityInstance entityInstance)
    {
      SaveEntityInstanceInternal(ref entityInstance, true);
    }

    private void SaveEntityInstanceInternal(ref EntityInstance entityInstance, bool isVoid)
    {
      Check.Require(entityInstance != null,
                    "entityInstance cannot be null",
                    SystemConfig.CallerInfo);

      Check.Require(!String.IsNullOrEmpty(entityInstance.EntityFullName),
                      "entityInstance cannot have a null or empty EntityFullName",
                      SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityInstance.EntityFullName), AccessType.Write);

      try
      {
        logger.Debug(String.Format("Saving entity instance of type '{0}' and id '{1}'",
                                   entityInstance.EntityFullName, entityInstance.Id));

        using (new HighResolutionTimer("EntityInstanceService::SaveEntityInstance method"))
        {
          if (isVoid)
          {
            Repository.SaveEntityInstanceVoid(entityInstance);            
          }
          else
          {
            entityInstance = Repository.SaveEntityInstance(entityInstance);            
          }
          
        }
      }
      catch (SaveDataException e)
      {
        logger.Error(e.Message, e);
        throw new MASBasicException(e.Message);
      }
      catch (UniqueKeyViolationException e)
      {
        logger.Error(e.Message, e);
        throw new MASBasicException(e.Message);
      }
      catch (Exception e)
      {
        string message = String.Format("Error saving entity instance of type '{0}'",
                                       entityInstance.EntityFullName);

        logger.Error(message, e);
        throw new MASBasicException(message);
      }

    }

    public void SaveEntityInstances(ref List<EntityInstance> entityInstances)
    {
      if (entityInstances == null || entityInstances.Count == 0)
      {
        return;
      }

      InternalCheckCapability(Name.GetExtensionName(entityInstances[0].EntityFullName), AccessType.Write);

      try
      {
        logger.Debug(String.Format("Saving entity instances of type '{0}'", entityInstances[0].EntityFullName));
        using (var timer = new HighResolutionTimer("EntityInstanceService::SaveEntityInstances method"))
        {
          entityInstances = Repository.SaveEntityInstances(entityInstances);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error saving entity instances of type '{0}'", entityInstances[0].EntityFullName);

        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void CreateEntityInstanceFor(string forEntityName, Guid forEntityId, ref EntityInstance entityInstance)
    {
      Check.Require(forEntityName != null,
                    "forEntityName cannot be null",
                    SystemConfig.CallerInfo);

      Check.Require(forEntityId != Guid.Empty,
                    "forEntityId must be a non-empty Guid",
                    SystemConfig.CallerInfo);

      Check.Require(entityInstance != null,
                    "entityInstance cannot be null",
                    SystemConfig.CallerInfo);

      Check.Require(!String.IsNullOrEmpty(entityInstance.EntityFullName),
                    "entityInstance cannot have a null or empty EntityFullName",
                    SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityInstance.EntityFullName), AccessType.Write);

      try
      {
        logger.Debug(String.Format("Creating entity instance of type '{0}' for type '{1}' and id '{2}'",
                                   entityInstance.EntityFullName, forEntityName, forEntityId));

        using (var timer = new HighResolutionTimer("EntityInstanceService::CreateEntityInstanceFor method"))
        {
          entityInstance = Repository.CreateEntityInstanceFor(forEntityName, forEntityId, entityInstance);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error creating entity instance of type '{0}' for type '{1}' and id '{2}'",
                                       entityInstance.EntityFullName, forEntityName, forEntityId);

        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void CreateEntityInstancesFor(string forEntityName, Guid forEntityId, ref List<EntityInstance> entityInstances)
    {
      Check.Require(forEntityName != null,
                    "forEntityName cannot be null",
                    SystemConfig.CallerInfo);

      Check.Require(forEntityId != Guid.Empty,
                    "forEntityId must be a non-empty Guid",
                    SystemConfig.CallerInfo);

      Check.Require(entityInstances != null,
                    "entityInstances cannot be null",
                    SystemConfig.CallerInfo);

      if (entityInstances.Count == 0)
      {
        return;
      }

      InternalCheckCapability(Name.GetExtensionName(entityInstances[0].EntityFullName), AccessType.Write);

      foreach (EntityInstance entityInstance in entityInstances)
      {
        Check.Require(!String.IsNullOrEmpty(entityInstance.EntityFullName),
                      "entityInstance cannot have a null or empty EntityFullName",
                      SystemConfig.CallerInfo);
      }

      try
      {
        logger.Debug(String.Format("Creating entity instance of type '{0}' for type '{1}' and id '{2}'",
                                   entityInstances[0].EntityFullName, forEntityName, forEntityId));

        using (var timer = new HighResolutionTimer("EntityInstanceService::CreateEntityInstancesFor method"))
        {
          entityInstances =
            (List<EntityInstance>) Repository.CreateEntityInstancesFor(forEntityName,
                                                                       forEntityId,
                                                                       entityInstances);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error creating entity instance of type '{0}' for type '{1}' and id '{2}'",
                                   entityInstances[0].EntityFullName, forEntityName, forEntityId);

        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void CreateRelationships(List<RelationshipEntityInstanceData> relationshipEntityInstanceDataList)
    {
      Check.Require(relationshipEntityInstanceDataList != null, "relationshipEntityInstanceDataList cannot be null");
      if (relationshipEntityInstanceDataList.Count == 0)
      {
        return;
      }

      InternalCheckCapability(Name.GetExtensionName(relationshipEntityInstanceDataList[0].Source.EntityFullName), AccessType.Write);
      InternalCheckCapability(Name.GetExtensionName(relationshipEntityInstanceDataList[0].Target.EntityFullName), AccessType.Write);

      try
      {
        using (var timer = new HighResolutionTimer("RepositoryService::CreateEntityInstanceRelationships method"))
        {
          Repository.CreateEntityInstanceRelationships(relationshipEntityInstanceDataList);
        }
      }
      catch (Exception)
      {
        string message = String.Format("Error creating relationships");
        throw new MASBasicException(message);
      }
    }

    public void DeleteRelationships(List<RelationshipEntityInstanceData> relationshipEntityInstanceDataList)
    {
      Check.Require(relationshipEntityInstanceDataList != null, "relationshipEntityInstanceDataList cannot be null");
      if (relationshipEntityInstanceDataList.Count == 0)
      {
        return;
      }

      InternalCheckCapability(Name.GetExtensionName(relationshipEntityInstanceDataList[0].Source.EntityFullName), AccessType.Write);
      InternalCheckCapability(Name.GetExtensionName(relationshipEntityInstanceDataList[0].Target.EntityFullName), AccessType.Write);

      try
      {
        using (var timer = new HighResolutionTimer("RepositoryService::DeleteEntityInstanceRelationships method"))
        {
          Repository.DeleteEntityInstanceRelationships(relationshipEntityInstanceDataList);
        }
      }
      catch (Exception)
      {
        string message = String.Format("Error deleting relationships");
        throw new MASBasicException(message);
      }
    }
    /// <summary>
    /// Remove item from [propertiesValues] if property doesn't exist in EntityInstance [bme]    
    /// </summary>
    /// <param name="bme"></param>
    /// <param name="propertiesToUpdate"></param>
    private void CheckPropertyValuesForBME(EntityInstance bme, List<string> propertiesToUpdate)
    {
      foreach (var propVal in propertiesToUpdate)
      {
        if (bme.Properties.All(prop => prop.Name != propVal))
          propertiesToUpdate.Remove(propVal);
      }
      
    }

    private void UpdateEntitiesInternal(MTList<EntityInstance> itemsToUpdate, EntityInstance beInstance, List<string> propertiesToUpdate)
    {
      if (itemsToUpdate.Items.Count == 0)
        return;

      CheckPropertyValuesForBME(beInstance, propertiesToUpdate);

      var updatedItems = itemsToUpdate.Items;

      // Set [propertiesValues] for BME entities [updatedInstances]
      foreach (var prop in propertiesToUpdate)
        foreach (var bme in updatedItems)
          bme.SetValue(beInstance[prop].Value, prop);

      SaveEntityInstances(ref updatedItems); 

    }

    public void UpdateEntitiesByGuids(List<string> propertiesToUpdate, EntityInstance beInstance, Guid[] ids)
    {
      var entityInstances = new MTList<EntityInstance>();

      LoadEntityInstancesByGuids(beInstance.EntityFullName, ids, ref entityInstances);

      UpdateEntitiesInternal(entityInstances, beInstance, propertiesToUpdate);
    }

    public void UpdateEntities(List<string> propertiesToUpdate, EntityInstance beInstance, MTList<EntityInstance> mtList)
    {
      LoadEntityInstances(beInstance.EntityFullName, ref mtList);

      UpdateEntitiesInternal(mtList, beInstance, propertiesToUpdate);
   
    }
    #endregion

    #region Load
    public void LoadEntityInstance(string entityName, Guid id, out EntityInstance entityInstance)
    {
      Check.Require(!String.IsNullOrEmpty(entityName),
                      "entityName cannot be null or empty",
                    SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityName),AccessType.Read);

      try
      {
        logger.Debug(String.Format("Loading entity instance of type '{0}' and id '{1}'",
                                   entityName, id));

        using (var timer = new HighResolutionTimer("EntityInstanceService::LoadEntityInstance method"))
        {
          entityInstance = Repository.LoadEntityInstance(entityName, id);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error loading entity instance of type '{0}' and id '{1}'",
                                   entityName, id);

        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void LoadEntityInstanceByBusinessKey(string entityName, List<PropertyInstance> businessKeyProperties, out EntityInstance entityInstance)
    {
      Check.Require(!String.IsNullOrEmpty(entityName),
                      "entityName cannot be null or empty",
                      SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityName), AccessType.Read);

      try
      {
        logger.Debug(String.Format("Loading entity instance of type '{0}' using business key properties '{1}'",
                                   entityName, StringUtil.Join(",", businessKeyProperties, p => p.ToString())));

        using (var timer = new HighResolutionTimer("EntityInstanceService::LoadEntityInstanceByBusinessKey method"))
        {
          entityInstance = Repository.LoadEntityInstanceByBusinessKey(entityName, businessKeyProperties);
        }
      }
      catch (Exception e)
      {
        logger.Error(e.Message);
        throw new MASBasicException(e.Message);
      }
    }

    public void LoadEntityInstances(string entityName, ref MTList<EntityInstance> entityInstances)
    {
      Check.Require(!String.IsNullOrEmpty(entityName),
                    "entityName cannot be null or empty",
                    SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityName),AccessType.Read);

      try
      {
        logger.Debug(String.Format("Loading entity instances of type '{0}'", entityName));

        using (var timer = new HighResolutionTimer("EntityInstanceService::LoadEntityInstances method"))
        {
          entityInstances = Repository.LoadEntityInstances(entityName, entityInstances);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error loading entity instances of type '{0}'", entityName);
        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void LoadEntityInstancesByGuids(string entityName, Guid[] ids, ref MTList<EntityInstance> entityInstances)
    {
      Check.Require(!String.IsNullOrEmpty(entityName),
                    "entityName cannot be null or empty",
                    SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityName), AccessType.Read);

      try
      {
        logger.Debug(String.Format("Loading entity instances of type '{0}'", entityName));

        using (var timer = new HighResolutionTimer("EntityInstanceService::LoadEntityInstances method"))
        {
          entityInstances = Repository.LoadEntityInstances(entityName, ids);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error loading entity instances of type '{0}'", entityName);
        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void LoadEntityInstanceFor(string entityName,
                                      string forEntityName,
                                      Guid forEntityId,
                                      out EntityInstance entityInstance)
    {
      Check.Require(!String.IsNullOrEmpty(entityName),
                    "entityName cannot be null or empty",
                    SystemConfig.CallerInfo);

      Check.Require(!String.IsNullOrEmpty(forEntityName),
                    "forEntityName cannot be null or empty",
                    SystemConfig.CallerInfo);

      Check.Require(forEntityId != Guid.Empty,
                    "forEntityId must be a guid",
                    SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityName),AccessType.Read);

      try
      {
        logger.Debug(String.Format("Loading entity instance of type '{0}' for type '{1}' and id '{2}'", entityName, forEntityName, forEntityId));
        using (var timer = new HighResolutionTimer("EntityInstanceService::LoadEntityInstanceFor method"))
        {
          entityInstance = Repository.LoadEntityInstanceFor(entityName, forEntityName, forEntityId);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error loading entity instance of type '{0}' for type '{1}' and id '{2}'", entityName, forEntityName, forEntityId);
        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void LoadEntityInstancesFor(string entityName,
                                       string forEntityName,
                                       Guid forEntityId,
                                       ref MTList<EntityInstance> mtList)
    {
      Check.Require(!String.IsNullOrEmpty(entityName),
                    "entityName cannot be null or empty",
                    SystemConfig.CallerInfo);

      Check.Require(!String.IsNullOrEmpty(forEntityName),
                    "forEntityName cannot be null or empty",
                    SystemConfig.CallerInfo);

      Check.Require(forEntityId != Guid.Empty,
                    "forEntityId must be a guid",
                    SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityName),AccessType.Read);

      try
      {
        using (new HighResolutionTimer("EntityInstanceService::LoadEntityInstancesFor method"))
        {
          logger.Debug(String.Format("Loading entity instances of type '{0}' for type '{1}' and id '{2}'", entityName,
                                     forEntityName, forEntityId));
          mtList = Repository.LoadEntityInstancesFor(entityName, forEntityName, forEntityId, mtList);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error loading entity instances of type '{0}' for type '{1}' and id '{2}'", entityName, forEntityName, forEntityId);
        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void LoadUnrelatedEntityInstancesFor(string entityName,
                                                string forEntityName,
                                                Guid forEntityId,
                                                ref MTList<EntityInstance> mtList)
    {
      Check.Require(!String.IsNullOrEmpty(entityName),
                    "entityName cannot be null or empty",
                    SystemConfig.CallerInfo);

      Check.Require(!String.IsNullOrEmpty(forEntityName),
                    "forEntityName cannot be null or empty",
                    SystemConfig.CallerInfo);

      Check.Require(forEntityId != Guid.Empty,
                    "forEntityId must be a guid",
                    SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityName), AccessType.Read);

      try
      {
        using (var timer = new HighResolutionTimer("EntityInstanceService::LoadUnrelatedEntityInstancesFor method"))
        {
          logger.Debug(String.Format("Loading unrelated entity instances of type '{0}' for type '{1}' and id '{2}'", entityName,
                                     forEntityName, forEntityId));
        }
        mtList = Repository.LoadEntityInstancesFor(entityName, forEntityName, forEntityId, mtList, null, false);
      }
      catch (Exception e)
      {
        string message = String.Format("Error loading unrelated entity instances of type '{0}' for type '{1}' and id '{2}'", entityName, forEntityName, forEntityId);
        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void LoadEntityInstancesForMetranetEntity(string entityName,
                                                     MetranetEntity metranetEntity,
                                                     ref MTList<EntityInstance> mtList)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(metranetEntity != null, "metranetEntity cannot be null", SystemConfig.CallerInfo);
      Check.Require(mtList != null, "mtList cannot be null", SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityName),AccessType.Read);

      try
      {
        logger.Debug(String.Format("Loading entity instances of type '{0}' for metranet entity '{1}'", 
                                   entityName, metranetEntity.GetType().FullName));

        using (var timer = new HighResolutionTimer("EntityInstanceService::LoadEntityInstancesForMetranetEntity method"))
        {
          mtList = Repository.LoadEntityInstancesForMetranetEntity(entityName, metranetEntity, mtList);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error loading entity instances of type '{0}' for metranet entity '{1}'",
                                       entityName, metranetEntity.GetType().FullName);
        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }
    #endregion

    #region Delete

    public void DeleteEntityInstance(EntityInstance entityInstance)
    {
      Check.Require(entityInstance != null, "entityInstance cannot be null", SystemConfig.CallerInfo);
      Check.Require(entityInstance.Id != Guid.Empty, "entityInstance cannot have an empty Id", SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityInstance.EntityFullName), AccessType.Write);

      try
      {
        logger.Debug(String.Format("Deleting entity instances of type '{0}' and id '{1}'",
                                   entityInstance.EntityFullName, entityInstance.Id));

        using (var timer = new HighResolutionTimer("EntityInstanceService::DeleteEntityInstance method"))
        {
          Repository.DeleteEntityInstance(entityInstance);
        }
      }
      catch (Exception)
      {
        string message = String.Format("Error deleting entity of type '{0}' and id '{1}'", entityInstance.EntityFullName, entityInstance.Id);
        throw new MASBasicException(message);
      }
    }

    public void DeleteAllEntityInstances(string entityName)
    {
      logger.Debug(String.Format("Deleting all entity instances of type '{0}'", entityName));

      using (var timer = new HighResolutionTimer("EntityInstanceService::DeleteAllEntityInstances method"))
      {
        InternalDeleteAll(entityName);
      }
    }

    public void DeleteEntityInstanceUsingEntityName(string entityName, Guid id)
    {
      logger.Debug(String.Format("Deleting entity instances of type '{0}' and id '{1}'",
                                 entityName, id));

      using (var timer = new HighResolutionTimer("EntityInstanceService::DeleteEntityInstanceUsingEntityName method"))
      {
        InternalDelete(entityName, id);
      }
    }

    #endregion

    #region Misc
    public void GetNewEntityInstance(string entityName, out EntityInstance entityInstance)
    {
      Check.Require(!String.IsNullOrEmpty(entityName),
                    "entityName cannot be null",
                    SystemConfig.CallerInfo);

      entityInstance = null;

      InternalCheckCapability(Name.GetExtensionName(entityName), AccessType.Write);

      try
      {
        logger.Debug(String.Format("Creating a new entity instance of type '{0}'", entityName));

        using (var timer = new HighResolutionTimer("EntityInstanceService::GetNewEntityInstance method"))
        {
          Entity entity = MetadataRepository.Instance.GetEntity(entityName);
          if (entity == null)
          {
            throw new MetadataException("Cannot find entity '{0}'", entityName);
          }

          entityInstance = entity.GetEntityInstance();
        }
      }
      catch (MetadataException e)
      {
        throw new MASBasicException(e.Message);
      }
      catch (Exception e)
      {
        string message = String.Format("Error creating a new entity instance of type '{0}'", entityName);

        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void CheckCapability(string extensionName, AccessType accessType)
    {
      InternalCheckCapability(extensionName, accessType);
    }

    public void GetEntityInstanceBusinessKeyProperties(string entityName, out List<PropertyInstance> propertyInstances)
    {
      InternalGetBusinessKeyProperties(entityName, out propertyInstances);
    }
    #endregion

    #endregion

    #region Private Methods

    #endregion

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("EntityInstanceService");
    #endregion
  }

 
}
