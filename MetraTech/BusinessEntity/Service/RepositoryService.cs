using System;
using System.Collections.Generic;
using System.ServiceModel;

using MetraTech.ActivityServices.Common;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.BusinessEntity.Service
{
  [ServiceContract()]
  public interface IRepositoryService
  {
    #region Create/Update
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SaveInstance(ref DataObject dataObject);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SaveInstances(ref List<DataObject> dataObjects);

    /// <summary>
    ///   Create the specified instance for the given related type (forEntityName) and id (forEntityId).
    /// </summary>
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void CreateInstanceFor(string forEntityName, Guid forEntityId, ref DataObject dataObject);

    /// <summary>
    ///   Create instances for the given related type (forEntityName) and id (forEntityId).
    /// </summary>
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void CreateInstancesFor(string forEntityName, Guid forEntityId, ref List<DataObject> dataObjects);

    /// <summary>
    ///    Create the specified child for the given parentId. The entity must have a Self-Relationship
    /// </summary>
    /// <param name="parentId"></param>
    /// <param name="child"></param>
    /// <returns></returns>
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void CreateChild(Guid parentId, ref DataObject child);

    /// <summary>
    ///   Create the specified children for the given parentId. The entity must have a Self-Relationship
    /// </summary>
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void CreateChildren(Guid parentId, ref List<DataObject> children);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void CreateRelationship(DataObject source, DataObject target);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void CreateRelationships(List<RelationshipInstanceData> relationshipInstanceDataList);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteRelationships(List<RelationshipInstanceData> relationshipInstanceDataList);
    #endregion

    #region Load
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoadInstance(string entityName, Guid id, out DataObject dataObject);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoadInstanceByBusinessKey(string entityName, BusinessKey businessKey, out DataObject dataObject);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoadInstanceByBusinessKeyProperties(string entityName, 
                                             List<PropertyInstance> businessKeyProperties, 
                                             out DataObject dataObject);
   
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoadInstances(string entityName, ref MTList<DataObject> dataObjects);

    /// <summary>
    ///   Returns the row of type [entityName] for the given related type [forEntityName] and id [forEntityId].
    ///   typeName and forTypeName must have a one-to-one relationship
    /// </summary>
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoadInstanceFor(string entityName,
                         string forEntityName,
                         Guid forEntityId,
                         out DataObject dataObject);

    /// <summary>
    ///   Returns rows of type [entityName] for the given related type [forEntityName] and id [forEntityId].
    /// </summary>
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoadInstancesFor(string entityName,
                          string forEntityName,
                          Guid forEntityId,
                          ref MTList<DataObject> mtList);

    /// <summary>
    ///   Returns unrelated rows of type [entityName] for the given related type [forEntityName] and id [forEntityId].
    /// </summary>
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoadUnrelatedInstancesFor(string entityName,
                                   string forEntityName,
                                   Guid forEntityId,
                                   ref MTList<DataObject> mtList);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoadInstancesForMetranetEntity(string entityName,
                                        MetranetEntity metranetEntity,
                                        ref MTList<DataObject> mtList);

    /// <summary>
    ///   Load the children for the given parentId. The parent entity must have a self relationship.
    /// </summary>
    /// <param name="parentEntityName"></param>
    /// <param name="parentId"></param>
    /// <param name="mtList"></param>
    /// <returns></returns>
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoadChildren(string parentEntityName, Guid parentId, ref MTList<DataObject> mtList);

    /// <summary>
    ///   Load the instance with the given Id with values that existed for the specified effectiveDate.
    ///   This will return null for the following cases:
    ///     - if the specified entityName does not record history.
    ///     - if no history row is found with effectiveDate between start and end dates
    /// </summary>
    /// <param name="entityName"></param>
    /// <param name="id"></param>
    /// <param name="effectiveDate"></param>
    /// <param name="historyInstance"></param>
    /// <returns></returns>
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoadInstanceHistory(string entityName, Guid id, DateTime effectiveDate, out DataObject historyInstance);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoadHistoryInstances(string entityName, ref MTList<DataObject> dataObjects);
    #endregion

    #region Delete

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteInstanceUsingEntityName(string entityName, Guid id);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteInstance(DataObject dataObject);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteAllInstances(string entityName);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteRelationship(DataObject source, DataObject target);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteAllRelationships(string sourceEntityName, string targetEntityName);
    #endregion

    #region Misc
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetInstanceBusinessKey(string entityName, out BusinessKey businessKey);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetInstanceBusinessKeyProperties(string entityName, out List<PropertyInstance> propertyInstances);
    #endregion
  }

  #pragma warning disable 618
  [ServiceBehavior()]
  public class RepositoryService : BusinessEntityService, IRepositoryService
  {
    #region IRepositoryService Members

    #region Create/Update
    public void SaveInstance(ref DataObject dataObject)
    {
      InternalCheckCapability(Name.GetExtensionName(dataObject.GetType().FullName), AccessType.Write);

      try
      {
        logger.Debug(String.Format("Saving DataObject of type '{0}'", dataObject.GetType().FullName));
        using (var timer = new HighResolutionTimer("RepositoryService::SaveInstance method"))
        {
          dataObject = Repository.SaveInstance(dataObject);
        }
      }
      catch (Exception e)
      {
        logger.Error(String.Format("Error saving DataObject of type '{0}'", dataObject.GetType().FullName), e);
        throw;
      }
    }

    public void SaveInstances(ref List<DataObject> dataObjects)
    {
      if (dataObjects == null || dataObjects.Count == 0)
      {
        return;
      }

      InternalCheckCapability(Name.GetExtensionName(dataObjects[0].GetType().FullName), AccessType.Write);

      try
      {
        logger.Debug(String.Format("Saving entity instances of type '{0}'", dataObjects[0].GetType().FullName));
        using (var timer = new HighResolutionTimer("RepositoryService::SaveInstances method"))
        {
          dataObjects = Repository.SaveInstances(dataObjects);
        }
      }
      catch (Exception e)
      {
        logger.Error(String.Format("Error saving entity instances of type '{0}'", dataObjects[0].GetType().FullName), e);
        throw;
      }
    }

    public void CreateInstanceFor(string forEntityName, Guid forEntityId, ref DataObject dataObject)
    {
      Check.Require(forEntityName != null,
                    "forEntityName cannot be null",
                    SystemConfig.CallerInfo);

      Check.Require(forEntityId != Guid.Empty,
                    "forEntityId must be a non-empty Guid",
                    SystemConfig.CallerInfo);

      Check.Require(dataObject != null,
                    "dataObject cannot be null",
                    SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(dataObject.GetType().FullName), AccessType.Write);

      try
      {
        logger.Debug(String.Format("Creating instance of type '{0}' for type '{1}' and id '{2}'",
                                   dataObject.GetType().FullName, forEntityName, forEntityId));

        using (var timer = new HighResolutionTimer("RepositoryService::CreateInstanceFor method"))
        {
          dataObject = Repository.CreateInstanceFor(forEntityName, forEntityId, dataObject);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error creating instance of type '{0}' for type '{1}' and id '{2}'",
                                       dataObject.GetType().FullName, forEntityName, forEntityId);

        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void CreateInstancesFor(string forEntityName, Guid forEntityId, ref List<DataObject> dataObjects)
    {
      Check.Require(forEntityName != null,
                    "forEntityName cannot be null",
                    SystemConfig.CallerInfo);

      Check.Require(forEntityId != Guid.Empty,
                    "forEntityId must be a non-empty Guid",
                    SystemConfig.CallerInfo);

      Check.Require(dataObjects != null,
                    "dataObjects cannot be null",
                    SystemConfig.CallerInfo);

      if (dataObjects.Count == 0)
      {
        return;
      }

      InternalCheckCapability(Name.GetExtensionName(dataObjects[0].GetType().FullName), AccessType.Write);

      try
      {
        logger.Debug(String.Format("Creating instance of type '{0}' for type '{1}' and id '{2}'",
                                   dataObjects[0].GetType().FullName, forEntityName, forEntityId));

        using (var timer = new HighResolutionTimer("RepositoryService::CreateInstancesFor method"))
        {
          dataObjects =
            (List<DataObject>) Repository.CreateInstancesFor(forEntityName, forEntityId, dataObjects);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error creating instance of type '{0}' for type '{1}' and id '{2}'",
                                        dataObjects[0].GetType().FullName, forEntityName, forEntityId);

        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void CreateChild(Guid parentId, ref DataObject child)
    {
      Check.Require(parentId != Guid.Empty, "parentId must be a non-empty Guid");

      Check.Require(child != null, "child cannot be null");

      InternalCheckCapability(Name.GetExtensionName(child.GetType().FullName), AccessType.Write);

      try
      {
        logger.Debug(String.Format("Creating child of type '{0}' for parent id '{1}'",
                                   child.GetType().FullName, parentId));

        using (var timer = new HighResolutionTimer("RepositoryService::CreateChild method"))
        {
          child = Repository.CreateChild(parentId, child);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error creating child instance of type '{0}' for parent id '{1}'",
                                       child.GetType().FullName, parentId);

        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void CreateChildren(Guid parentId, ref List<DataObject> children)
    {
      Check.Require(parentId != Guid.Empty, "parentId must be a non-empty Guid");

      Check.Require(children != null, "children cannot be null");

      if (children.Count == 0)
      {
        return;
      }

      string typeName = children[0].GetType().FullName;

      InternalCheckCapability(Name.GetExtensionName(typeName), AccessType.Write);

      try
      {
        logger.Debug(String.Format("Creating children of type '{0}' for parent id '{1}'",
                                   typeName, parentId));
        using (var timer = new HighResolutionTimer("RepositoryService::CreateChildren method"))
        {
          children =
            (List<DataObject>) Repository.CreateChildren(parentId, children);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error creating instance of type '{0}' for parent id '{1}'",
                                        typeName, parentId);

        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void CreateRelationship(DataObject source, DataObject target)
    {
      Check.Require(source != null, "source cannot be null");
      Check.Require(target != null, "target cannot be null");
      Check.Require(source.Id != Guid.Empty, String.Format("Cannot create relationship with non-persisted instance of type '{0}'", source.GetType().FullName));
      Check.Require(target.Id != Guid.Empty, String.Format("Cannot create relationship with non-persisted instance of type '{0}'", target.GetType().FullName));

      InternalCheckCapability(Name.GetExtensionName(source.GetType().FullName), AccessType.Write);
      InternalCheckCapability(Name.GetExtensionName(target.GetType().FullName), AccessType.Write);

      try
      {
        using (var timer = new HighResolutionTimer("RepositoryService::CreateRelationship method"))
        {
          Repository.CreateRelationship(source, target);
        }
      }
      catch (Exception)
      {
        string message = String.Format("Error creating relationship between '{0}' and '{1}'", source, target);
        throw new MASBasicException(message);
      }
    }

    public void CreateRelationships(List<RelationshipInstanceData> relationshipInstanceDataList)
    {
      Check.Require(relationshipInstanceDataList != null, "relationshipInstanceDataList cannot be null");
      if (relationshipInstanceDataList.Count == 0)
      {
        return;
      }

      InternalCheckCapability(Name.GetExtensionName(relationshipInstanceDataList[0].Source.GetType().FullName), AccessType.Write);
      InternalCheckCapability(Name.GetExtensionName(relationshipInstanceDataList[0].Target.GetType().FullName), AccessType.Write);

      try
      {
        using (var timer = new HighResolutionTimer("RepositoryService::CreateRelationships method"))
        {
          Repository.CreateRelationships(relationshipInstanceDataList);
        }
      }
      catch (Exception)
      {
        string message = String.Format("Error creating relationships");
        throw new MASBasicException(message);
      }
    }

    public void DeleteRelationships(List<RelationshipInstanceData> relationshipInstanceDataList)
    {
      Check.Require(relationshipInstanceDataList != null, "relationshipInstanceDataList cannot be null");
      if (relationshipInstanceDataList.Count == 0)
      {
        return;
      }

      InternalCheckCapability(Name.GetExtensionName(relationshipInstanceDataList[0].Source.GetType().FullName), AccessType.Write);
      InternalCheckCapability(Name.GetExtensionName(relationshipInstanceDataList[0].Target.GetType().FullName), AccessType.Write);

      try
      {
        using (var timer = new HighResolutionTimer("RepositoryService::DeleteRelationships method"))
        {
          Repository.DeleteRelationships(relationshipInstanceDataList);
        }
      }
      catch (Exception)
      {
        string message = String.Format("Error deleting relationships");
        throw new MASBasicException(message);
      }
    }
    #endregion

    #region Load
    public void LoadInstance(string entityName, Guid id, out DataObject dataObject)
    {
      Check.Require(!String.IsNullOrEmpty(entityName),
                    "entityName cannot be null or empty",
                    SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityName), AccessType.Read);

      try
      {
        logger.Debug(String.Format("Loading DataObject of type '{0}' and id '{1}'", entityName, id));
        using (var timer = new HighResolutionTimer("RepositoryService::LoadInstance method"))
        {
          dataObject = Repository.LoadInstance(entityName, id);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error loading DataObject of type '{0}' and id '{1}'", entityName, id);
        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void LoadInstanceByBusinessKey(string entityName, BusinessKey businessKey, out DataObject dataObject)
    {
      Check.Require(!String.IsNullOrEmpty(entityName),
                    "entityName cannot be null or empty",
                    SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityName), AccessType.Read);

      try
      {
        logger.Debug(String.Format("Loading instance of type '{0}' using business key properties '{1}'",
                                   entityName, businessKey));

        using (var timer = new HighResolutionTimer("RepositoryService::LoadInstanceByBusinessKey method"))
        {
          dataObject = Repository.LoadInstanceByBusinessKey(entityName, businessKey);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error loading DataObject of type '{0}' and business key '{1}'", entityName, businessKey);
        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

   
    public void LoadInstanceByBusinessKeyProperties(string entityName,
                                                    List<PropertyInstance> businessKeyProperties,
                                                    out DataObject dataObject)
    {
      Check.Require(!String.IsNullOrEmpty(entityName),
                    "entityName cannot be null or empty",
                    SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityName), AccessType.Read);

      try
      {
        logger.Debug(String.Format("Loading entity instance of type '{0}' using business key properties '{1}'",
                                   entityName, StringUtil.Join(",", businessKeyProperties, p => p.ToString())));

        using (var timer = new HighResolutionTimer("RepositoryService::LoadInstanceByBusinessKeyProperties method"))
        {
          dataObject = Repository.LoadInstanceByBusinessKeyProperties(entityName, businessKeyProperties);
        }
      }
      catch (Exception e)
      {
        throw new MASBasicException(e.Message);
      }
    }

    public void LoadInstances(string entityName, ref MTList<DataObject> dataObjects)
    {
      Check.Require(!String.IsNullOrEmpty(entityName),
                    "entityName cannot be null or empty",
                    SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityName), AccessType.Read);

      try
      {
        logger.Debug(String.Format("Loading data objects of type '{0}'", entityName));
        using (var timer = new HighResolutionTimer("RepositoryService::LoadInstances method"))
        {
          dataObjects = Repository.LoadInstances(entityName, dataObjects);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error loading data objects of type '{0}'", entityName);
        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void LoadInstanceFor(string entityName,
                                string forEntityName,
                                Guid forEntityId,
                                out DataObject dataObject)
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
        logger.Debug(String.Format("Loading instance of type '{0}' for type '{1}' and id '{2}'", entityName, forEntityName, forEntityId));
        using (var timer = new HighResolutionTimer("RepositoryService::LoadInstanceFor method"))
        {
          dataObject = Repository.LoadInstanceFor(entityName, forEntityName, forEntityId);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error loading instance of type '{0}' for type '{1}' and id '{2}'", entityName, forEntityName, forEntityId);
        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void LoadInstancesFor(string entityName,
                                 string forEntityName,
                                 Guid forEntityId,
                                 ref MTList<DataObject> mtList)
    {
      Check.Require(!String.IsNullOrEmpty(entityName),
                    "entityName cannot be null or empty",
                    SystemConfig.CallerInfo);

      Check.Require(!String.IsNullOrEmpty(forEntityName),
                    "forEntityName cannot be null or empty",
                    SystemConfig.CallerInfo);

      Check.Require(forEntityId != Guid.Empty,
                    "forEntityId must be a non-empty guid",
                    SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityName), AccessType.Read);

      try
      {
        logger.Debug(String.Format("Loading instances of type '{0}' for type '{1}' and id '{2}'", entityName, forEntityName, forEntityId));
        using (var timer = new HighResolutionTimer("RepositoryService::LoadInstancesFor method"))
        {
          mtList = Repository.LoadInstancesFor(entityName, forEntityName, forEntityId, mtList);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error loading instances of type '{0}' for type '{1}' and id '{2}'", entityName, forEntityName, forEntityId);
        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void LoadUnrelatedInstancesFor(string entityName,
                                          string forEntityName,
                                          Guid forEntityId,
                                          ref MTList<DataObject> mtList)
    {
      Check.Require(!String.IsNullOrEmpty(entityName),
                    "entityName cannot be null or empty",
                    SystemConfig.CallerInfo);

      Check.Require(!String.IsNullOrEmpty(forEntityName),
                    "forEntityName cannot be null or empty",
                    SystemConfig.CallerInfo);

      Check.Require(forEntityId != Guid.Empty,
                    "forEntityId must be a non-empty guid",
                    SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityName), AccessType.Read);

      try
      {
        logger.Debug(String.Format("Loading unrelated instances of type '{0}' for type '{1}' and id '{2}'", entityName, forEntityName, forEntityId));
        using (var timer = new HighResolutionTimer("RepositoryService::LoadUnrelatedInstancesFor method"))
        {
          mtList = Repository.LoadInstancesFor(entityName, forEntityName, forEntityId, mtList, null, false);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error loading unrelated instances of type '{0}' for type '{1}' and id '{2}'", entityName, forEntityName, forEntityId);
        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }
    
    public void LoadInstancesForMetranetEntity(string entityName,
                                               MetranetEntity metranetEntity,
                                               ref MTList<DataObject> mtList)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(metranetEntity != null, "metranetEntity cannot be null", SystemConfig.CallerInfo);
      Check.Require(mtList != null, "mtList cannot be null", SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityName), AccessType.Read);

      try
      {
        logger.Debug(String.Format("Loading data objects of type '{0}' for metranet entity '{1}'",
                                   entityName, metranetEntity.GetType().FullName));
        using (var timer = new HighResolutionTimer("RepositoryService::LoadInstancesForMetranetEntity method"))
        {
          mtList = Repository.LoadInstancesForMetranetEntity(entityName, metranetEntity, mtList);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error loading data objects of type '{0}' for metranet entity '{1}'",
                                       entityName, metranetEntity.GetType().FullName);
        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void LoadChildren(string parentEntityName, Guid parentId, ref MTList<DataObject> mtList)
    {
      Check.Require(!String.IsNullOrEmpty(parentEntityName),
                    "parentEntityName cannot be null or empty");

      Check.Require(parentId != Guid.Empty, "parentId must be a non-empty guid");

      InternalCheckCapability(Name.GetExtensionName(parentEntityName), AccessType.Read);

      try
      {
        logger.Debug(String.Format("Loading child instances of type '{0}' for parent id '{1}'", parentEntityName, parentId));
        using (var timer = new HighResolutionTimer("RepositoryService::LoadChildren method"))
        {
          mtList = Repository.LoadChildren(parentEntityName, parentId, mtList);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error loading child instances of type '{0}' for parent id '{1}'", parentEntityName, parentId);
        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void LoadInstanceHistory(string entityName, 
                                    Guid id, 
                                    DateTime effectiveDate, 
                                    out DataObject historyInstance)
    {
      Check.Require(!String.IsNullOrEmpty(entityName),
                    "entityName cannot be null or empty",
                    SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityName), AccessType.Read);

      try
      {
        logger.Debug(String.Format("Loading history instance for type '{0}' and id '{1}' using effective date '{2}'", 
                                    entityName, id, effectiveDate));
        using (var timer = new HighResolutionTimer("RepositoryService::LoadInstanceHistory method"))
        {
          historyInstance = Repository.LoadInstanceHistory(entityName, id, effectiveDate);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error loading history instance for type '{0}' and id '{1}' using effective date '{2}'", 
                                       entityName, id, effectiveDate);
        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }

    public void LoadHistoryInstances(string entityName, ref MTList<DataObject> dataObjects)
    {
      Check.Require(!String.IsNullOrEmpty(entityName),
                    "entityName cannot be null or empty",
                    SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityName), AccessType.Read);

      try
      {
        logger.Debug(String.Format("Loading history data objects for type '{0}'", entityName));
        using (var timer = new HighResolutionTimer("RepositoryService::LoadHistoryInstances method"))
        {
          dataObjects = Repository.LoadHistoryInstances(entityName, dataObjects);
        }
      }
      catch (Exception e)
      {
        string message = String.Format("Error loading history data objects for type '{0}'", entityName);
        logger.Error(message, e);
        throw new MASBasicException(message);
      }
    }
    #endregion

    #region Delete
    public void DeleteInstance(DataObject dataObject)
    {
      Check.Require(dataObject != null, "dataObject cannot be null", SystemConfig.CallerInfo);
      Check.Require(dataObject.Id != Guid.Empty, "dataObject cannot have an empty Id", SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(dataObject.GetType().FullName), AccessType.Write);

      try
      {
        logger.Debug(String.Format("Deleting instances of type '{0}' and id '{1}'",
                                   dataObject.GetType().FullName, dataObject.Id));

        using (var timer = new HighResolutionTimer("RepositoryService::DeleteInstance method"))
        {
          Repository.DeleteInstance(dataObject);
        }
      }
      catch (Exception)
      {
        string message = String.Format("Error deleting entity of type '{0}' and id '{1}'", dataObject.GetType().FullName, dataObject.Id);
        throw new MASBasicException(message);
      }
    }

    public void DeleteAllInstances(string entityName)
    {
      logger.Debug(String.Format("Deleting all instances of type '{0}'", entityName));

      using (var timer = new HighResolutionTimer("RepositoryService::DeleteAllInstances method"))
      {
        InternalDeleteAll(entityName);
      }
    }

    public void DeleteInstanceUsingEntityName(string entityName, Guid id)
    {
      logger.Debug(String.Format("Deleting instances of type '{0}' and id '{1}'", entityName, id));

      using (var timer = new HighResolutionTimer("RepositoryService::DeleteInstanceUsingEntityName method"))
      {
        InternalDelete(entityName, id);
      }
    }

    public void DeleteRelationship(DataObject source, DataObject target)
    {
      Check.Require(source != null, "source cannot be null");
      Check.Require(target != null, "target cannot be null");
      Check.Require(source.Id != Guid.Empty, String.Format("Cannot delete relationship with non-persisted instance of type '{0}'", source.GetType().FullName));
      Check.Require(target.Id != Guid.Empty, String.Format("Cannot delete relationship with non-persisted instance of type '{0}'", target.GetType().FullName));

      InternalCheckCapability(Name.GetExtensionName(source.GetType().FullName), AccessType.Write);
      InternalCheckCapability(Name.GetExtensionName(target.GetType().FullName), AccessType.Write);

      try
      {
        using (var timer = new HighResolutionTimer("RepositoryService::DeleteRelationship method"))
        {
          Repository.DeleteRelationship(source, target);
        }
      }
      catch (Exception)
      {
        string message = String.Format("Error deleting relationship between '{0}' and '{1}'", source, target);
        throw new MASBasicException(message);
      }
    }

    public void DeleteAllRelationships(string sourceEntityName, string targetEntityName)
    {
      Check.Require(!String.IsNullOrEmpty(sourceEntityName), "sourceEntityName cannot be null or empty");
      Check.Require(!String.IsNullOrEmpty(targetEntityName), "targetEntityName cannot be null or empty");

      InternalCheckCapability(Name.GetExtensionName(sourceEntityName), AccessType.Write);
      InternalCheckCapability(Name.GetExtensionName(targetEntityName), AccessType.Write);

      try
      {
        using (var timer = new HighResolutionTimer("RepositoryService::DeleteAllRelationships method"))
        {
          Repository.DeleteAllRelationships(sourceEntityName, targetEntityName);
        }
      }
      catch (Exception)
      {
        string message = String.Format("Error deleting all relationships between '{0}' and '{1}'", sourceEntityName, targetEntityName);
        throw new MASBasicException(message);
      }
    }
    #endregion

    #region Misc
    public void GetInstanceBusinessKey(string entityName, out BusinessKey businessKey)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);

      InternalCheckCapability(Name.GetExtensionName(entityName), AccessType.Read);

      try
      {
        logger.Debug(String.Format("Getting business key for type '{0}'", entityName));

        using (var timer = new HighResolutionTimer("RepositoryService::GetInstanceBusinessKey method"))
        {
          businessKey = BusinessKey.GetBusinessKey(entityName);
        }
      }
      catch (Exception e)
      {
        throw new MASBasicException(e.Message);
      }
    }

    public void GetInstanceBusinessKeyProperties(string entityName, out List<PropertyInstance> propertyInstances)
    {
      logger.Debug(String.Format("Getting business key properties for type '{0}'", entityName));

      using (var timer = new HighResolutionTimer("RepositoryService::GetInstanceBusinessKeyProperties method"))
      {
        InternalGetBusinessKeyProperties(entityName, out propertyInstances);
      }
    }
    #endregion

    #endregion

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("RepositoryService");
    #endregion
  }

 
}
