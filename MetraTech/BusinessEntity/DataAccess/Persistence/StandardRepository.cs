using System.Collections;
using System.Collections.Generic;
using System;
using System.Diagnostics;
using System.Linq;
using System.Reflection;
using System.Runtime.Serialization;
using System.Transactions;
using LinFu.AOP.Interfaces;
using MetraTech.BusinessEntity.DataAccess.Metadata.Graph;
using MetraTech.DomainModel.Enums;
using NHibernate;
using NHibernate.Cfg;
using NHibernate.Criterion;
using NHibernate.Engine;
using NHibernate.Mapping;
using NHibernate.Metadata;
using NHibernate.SqlCommand;
using NHibernate.Transform;
using NHibernate.Type;

using Core.Common;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Common;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.Basic;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.ActivityServices.Common;
using MetraTech.Basic.Config;

using EntityType=MetraTech.BusinessEntity.DataAccess.Metadata.EntityType;
using IsolationLevel = System.Data.IsolationLevel;
using Property=MetraTech.BusinessEntity.DataAccess.Metadata.Property;


namespace MetraTech.BusinessEntity.DataAccess.Persistence
{
  #pragma warning disable 618
  /// <summary>
  /// </summary>
  [Serializable]
  public class StandardRepository : IStandardRepository
  {
    #region Properties
    /// <summary>
    ///   Singleton Pattern
    ///   http://msdn.microsoft.com/en-us/library/ff650316.aspx
    /// </summary>
    public static StandardRepository Instance
    {
      get
      {
        if (instance == null)
        {
          lock (syncRoot)
          {
            if (instance == null)
            {
              instance = new StandardRepository();
            }
          }
        }

        return instance;
      }
    }
    #endregion

    #region IStandardRepository

    #region EntityInstance Methods

    #region Create/Update
    public virtual EntityInstance SaveEntityInstance(EntityInstance entityInstance)
    {
      return SaveEntityInstanceInternal(entityInstance, false);
    }

    public virtual void SaveEntityInstanceVoid(EntityInstance entityInstance)
    {
      SaveEntityInstanceInternal(entityInstance, true);
    }

    private EntityInstance SaveEntityInstanceInternal(EntityInstance entityInstance, bool isVoid)
    {
      Check.Require(entityInstance != null, "entityInstance cannot be null", SystemConfig.CallerInfo);

      try
      {
        DataObject dataObject = ConvertEntityInstanceToDataObject(entityInstance);
        Check.Assert(dataObject != null,
                     String.Format("Cannot convert entityInstance of type '{0}' to DataObject", entityInstance.EntityFullName),
                     SystemConfig.CallerInfo);
        SaveInstance(ref dataObject);
        if(!isVoid)
          entityInstance = ConvertDataObjectToEntityInstance(dataObject, false);
      }
      catch (OptimisticConcurrencyException)
      {
        throw;
      }
      catch (MissingRequiredPropertyException)
      {
        throw;
      }
      catch (SaveDataException)
      {
        throw;
      }
      catch (UniqueKeyViolationException)
      {
        throw;
      }
      catch (System.Exception e)
      {
        var message = String.Format("Cannot save data object of type '{0}' and id '{1}'",
                                     entityInstance.EntityFullName, entityInstance.Id);
        if (e.InnerException != null && e.InnerException.Message.Contains("Cannot insert duplicate key"))
        {
          message = String.Format("Cannot save data of type '{0}'; unique key constraint violated.", entityInstance.EntityFullName);
          throw new UniqueKeyViolationException(message, e);
        }
        throw new SaveDataException(message, e);
      }

      return entityInstance;
    }

    public virtual List<EntityInstance> SaveEntityInstances(List<EntityInstance> entityInstances)
    {
      var savedEntityInstances = new List<EntityInstance>();

      if (entityInstances == null || entityInstances.Count == 0)
      {
        return savedEntityInstances;
      }

      try
      {
        var dataObjects = new List<DataObject>();
        foreach (EntityInstance entityInstance in entityInstances)
        {
          dataObjects.Add(ConvertEntityInstanceToDataObject(entityInstance));
        }

        SaveInstances(ref dataObjects);

        foreach (DataObject dataObject in dataObjects)
        {
          savedEntityInstances.Add(ConvertDataObjectToEntityInstance(dataObject, false));
        }
      }
      catch (OptimisticConcurrencyException)
      {
        throw;
      }
      catch (SaveDataException)
      {
        throw;
      }
      catch (System.Exception e)
      {
        var message = String.Format("Cannot save EntityInstances of type '{0}'", entityInstances[0].EntityFullName);
        if (e.InnerException != null && e.InnerException.Message.Contains("Cannot insert duplicate key"))
        {
          message = String.Format("Cannot save data of type '{0}'; unique key constraint violated.", entityInstances[0].EntityFullName);
          throw new UniqueKeyViolationException(message, e);
        }
        throw new SaveDataException(message, e);
      }

      return savedEntityInstances;
    }

    public virtual EntityInstance CreateEntityInstanceFor(string forEntityName, Guid forEntityId, EntityInstance instance)
    {
      IList<EntityInstance> entityInstances =
        CreateEntityInstancesFor(forEntityName, forEntityId, new List<EntityInstance>() { instance });

      Check.Ensure(entityInstances.Count == 1, "Expected one item in entityInstances", SystemConfig.CallerInfo);
      return entityInstances[0];
    }

    /// <summary>
    ///   Saves EntityInstances for the given related type (forEntityName) and id (forEntityId).
    /// </summary>
    public virtual IList<EntityInstance> CreateEntityInstancesFor(string forEntityName,
                                                                  Guid forEntityId,
                                                                  IList<EntityInstance> instances)
    {
      var savedEntityInstances = new List<EntityInstance>();

      if (instances == null || instances.Count == 0)
      {
        return savedEntityInstances;
      }

      Check.Require(!String.IsNullOrEmpty(forEntityName), "parentTypeName cannot be null or empty", SystemConfig.CallerInfo);

      try
      {
        IList<DataObject> dataObjects = new List<DataObject>();
        foreach (EntityInstance entityInstance in instances)
        {
          DataObject obj = ConvertEntityInstanceToDataObject(entityInstance);
          Check.Require(obj != null,
                        String.Format("Cannot convert EntityInstance '{0}' to DataObject", entityInstance.EntityFullName),
                        SystemConfig.CallerInfo);
          dataObjects.Add(obj);
        }

        if (RepositoryAccess.Instance.IsEntityInOracle(forEntityName) && Transaction.Current != null)
        {
          using (var session = RepositoryAccess.Instance.GetSession(forEntityName, FlushMode.Never))
          {
            List<ErrorObject> errors;
            CreateForInternal(session, forEntityName, forEntityId, ref dataObjects, out errors);

            if (errors.Count > 0)
            {
              string message = String.Format("Cannot save data object of type '{0}' for related type '{1}' and id '{2}'",
                                              instances[0].EntityFullName, forEntityName, forEntityId);
              throw new SaveDataException(message, errors);
            }

            foreach (DataObject dataObject in dataObjects)
            {
              EntityInstance entityInstance =
                ConvertDataObjectToEntityInstance(dataObject, false);
              Check.Require(entityInstance != null, "entityInstance cannot be null", SystemConfig.CallerInfo);
              savedEntityInstances.Add(entityInstance);
            }
          }
        }
        else
        {
          using (var session = RepositoryAccess.Instance.GetSession(forEntityName, FlushMode.Never))
          using (var tx = session.BeginTransaction())
          {
            List<ErrorObject> errors;
            CreateForInternal(session, forEntityName, forEntityId, ref dataObjects, out errors);

            if (errors.Count > 0)
            {
              string message = String.Format(
                "Cannot save data object of type '{0}' for related type '{1}' and id '{2}'",
                instances[0].EntityFullName, forEntityName, forEntityId);
              throw new SaveDataException(message, errors);
            }

            foreach (DataObject dataObject in dataObjects)
            {
              EntityInstance entityInstance =
                ConvertDataObjectToEntityInstance(dataObject, false);
              Check.Require(entityInstance != null, "entityInstance cannot be null", SystemConfig.CallerInfo);
              savedEntityInstances.Add(entityInstance);
            }

            tx.Commit();
          }
        }
      }
      catch (SaveDataException)
      {
        throw;
      }
      catch (System.Exception e)
      {
        var message = String.Format("Cannot save data object of type '{0}' for related type '{1}' and id '{2}'",
                                       instances[0].EntityFullName, forEntityName, forEntityId);
        if (e.InnerException != null && e.InnerException.Message.Contains("Cannot insert duplicate key"))
        {
          message = String.Format("Cannot save data of type '{0}'; unique key constraint violated.", instances[0].EntityFullName);
          throw new UniqueKeyViolationException(message, e);
        }
        throw new SaveDataException(message, e);
      }

      return savedEntityInstances;
    }

    public virtual void CreateEntityInstanceRelationships(List<RelationshipEntityInstanceData> relationshipEntityInstanceDataList)
    {
      var relationshipInstanceDataList = new List<RelationshipInstanceData>();
      foreach(RelationshipEntityInstanceData relationshipEntityInstanceData in relationshipEntityInstanceDataList)
      {
        relationshipInstanceDataList.Add(new RelationshipInstanceData() { Source = ConvertEntityInstanceToDataObject(relationshipEntityInstanceData.Source),
                                                                          Target = ConvertEntityInstanceToDataObject(relationshipEntityInstanceData.Target)});
      }

      CreateRelationshipInternal(relationshipInstanceDataList);
    }

    public virtual void DeleteEntityInstanceRelationships(List<RelationshipEntityInstanceData> relationshipEntityInstanceDataList)
    {
      var relationshipInstanceDataList = new List<RelationshipInstanceData>();
      foreach (RelationshipEntityInstanceData relationshipEntityInstanceData in relationshipEntityInstanceDataList)
      {
        relationshipInstanceDataList.Add(new RelationshipInstanceData()
        {
          Source = ConvertEntityInstanceToDataObject(relationshipEntityInstanceData.Source),
          Target = ConvertEntityInstanceToDataObject(relationshipEntityInstanceData.Target)
        });
      }

      DeleteRelationships(relationshipInstanceDataList);
    }
    #endregion

    #region Load
    /// <summary>
    ///    
    /// </summary>
    /// <param name="id"></param>
    /// <param name="entityName"></param>
    /// <returns></returns>
    public virtual EntityInstance LoadEntityInstance(string entityName, Guid id)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);

      EntityInstance entityInstance = null;
      try
      {
        DataObject dataObject = null;
        if (RepositoryAccess.Instance.IsEntityInOracle(entityName) && Transaction.Current != null)
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName, FlushMode.Never))
          {
            dataObject = LoadInternal(entityName, session, id);
          }
        }
        else
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName, FlushMode.Never))
          using (var tx = session.BeginTransaction())
          {
            dataObject = LoadInternal(entityName, session, id);
            tx.Commit();
          }
        }
 
        if (dataObject != null)
        {
          entityInstance = ConvertDataObjectToEntityInstance(dataObject, false);
        }
      }
      catch (System.Exception e)
      {
        string message = String.Format("Cannot load type '{0}' with id '{1}", entityName, id);
        throw new LoadDataException(message, e);
      }

      return entityInstance;
    }
    /// <summary>
    /// 
    /// </summary>
    /// <param name="entityName"></param>
    /// <param name="ids"></param>
    /// <returns></returns>
    public virtual MTList<EntityInstance> LoadEntityInstances(string entityName, Guid[] ids)
    {
      var res = new MTList<EntityInstance>();
      foreach (var id in ids.Where(id => LoadEntityInstance(entityName, id)!= null))
        res.Items.Add(LoadEntityInstance(entityName, id));
      return res;
    }

    /// <summary>
    ///    
    /// </summary>
    /// <param name="entityName"></param>
    /// <param name="businessKeyProperties"></param>
    /// <returns></returns>
    public virtual EntityInstance LoadEntityInstanceByBusinessKey(string entityName, List<PropertyInstance> businessKeyProperties)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(businessKeyProperties != null, "businessKeyProperties cannot be null or empty", SystemConfig.CallerInfo);

      BusinessKey.CheckProperties(entityName, businessKeyProperties);

      EntityInstance entityInstance = null;

      string businessKeyLog = 
        String.Join(System.Environment.NewLine, (from p in businessKeyProperties select p.ToString()).ToArray());

      try
      {
        logger.Debug(String.Format("Loading instance for entity '{0}' and business key '{1}'", 
                                   entityName, businessKeyLog));
        
        var mtList = new MTList<EntityInstance>();
        mtList.Filters = new List<MTBaseFilterElement>();

        foreach(PropertyInstance propertyInstance in businessKeyProperties)
        {
          mtList.Filters.Add(new MTFilterElement(propertyInstance.Name, 
                                                 MTFilterElement.OperationType.Equal, 
                                                 propertyInstance.Value));
        }

        MTList<EntityInstance> entityInstances = LoadEntityInstances(entityName, mtList);
        Check.Ensure(entityInstances.Items.Count <= 1, 
                     String.Format("Found more than one instance for entity '{0}' and business key '{1}'",
                                   entityName,
                                   businessKeyLog),
                     SystemConfig.CallerInfo);

        if (entityInstances.Items.Count == 1)
        {
          entityInstance = entityInstances.Items[0];
        }
      }
      catch (System.Exception e)
      {
        string message = String.Format("Cannot load instance for entity name '{0}' and business key '{1}'",
                                       entityName,
                                       businessKeyLog);
        throw new LoadDataException(message, e);
      }

      return entityInstance;
    }

    /// <summary>
    ///   Returns all rows for the specified type.
    /// </summary>
    /// <param name="entityName"></param>
    /// <param name="mtList"></param>
    /// <returns></returns>
    public virtual MTList<EntityInstance> LoadEntityInstances(string entityName, MTList<EntityInstance> mtList)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(mtList != null, "mtList cannot be null", SystemConfig.CallerInfo);

      MTList<EntityInstance> entityInstances = CopyMtList(mtList);
      entityInstances.Items.Clear();

      try
      {
        MTList<DataObject> dataObjectMtList = ConvertToDataObjectMtList(mtList);

        MTList<DataObject> dataObjects = LoadInstances(entityName, dataObjectMtList);

        Check.Ensure(dataObjects != null, "dataObjects cannot be null", SystemConfig.CallerInfo);
        entityInstances.TotalRows = dataObjects.TotalRows;

        foreach (DataObject item in dataObjects.Items)
        {
          EntityInstance entityInstance =
              ConvertDataObjectToEntityInstance(item, false);
          Check.Require(entityInstance != null, "entityInstance cannot be null", SystemConfig.CallerInfo);
          entityInstances.Items.Add(entityInstance);
        }
      }
      catch (System.Exception e)
      {
        string message = String.Format("Cannot load items of type '{0}'", entityName);
        throw new LoadDataException(message, e);
      }

      return entityInstances;
    }

    /// <summary>
    ///   Returns the row of type [entityName] for the given related type (forEntityName) and id (forEntityId).
    ///   entityName and forEntityName must have a one-to-one relationship
    /// </summary>
    public virtual EntityInstance LoadEntityInstanceFor(string entityName,
                                                         string forEntityName,
                                                         Guid forEntityId)
    {
      EntityInstance entityInstance = null;

      MTList<EntityInstance> entityInstances =
        LoadEntityInstancesFor(entityName,
                               forEntityName,
                               forEntityId,
                               new MTList<EntityInstance>());

      if (entityInstances.Items.Count > 0)
      {
        entityInstance = entityInstances.Items[0];
      }

      return entityInstance;
    }


    /// <summary>
    ///   Returns rows of type [entityName] for the given related type (forEntityName) and id (forEntityId).
    /// </summary>
    public virtual MTList<EntityInstance> LoadEntityInstancesFor(string entityName,
                                                                  string forEntityName,
                                                                  Guid forEntityId,
                                                                  MTList<EntityInstance> mtList,
                                                                  String relationshipName = null,
                                                                  bool related = true)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(mtList != null, "mtList cannot be null", SystemConfig.CallerInfo);

      MTList<EntityInstance> entityInstances = CopyMtList(mtList);
      entityInstances.Items.Clear();

      try
      {
        List<ErrorObject> errors;

        MTList<DataObject> dataObjectMtList = ConvertToDataObjectMtList(mtList);

        using (var session = RepositoryAccess.Instance.GetSession(entityName, FlushMode.Never))
        {
          if (RepositoryAccess.Instance.IsEntityInOracle(entityName) && Transaction.Current != null)
          {
              LoadInstancesForInternal(session,
                                       entityName,
                                       forEntityName,
                                       forEntityId,
                                       ref dataObjectMtList,
                                       out errors,
                                       relationshipName,
                                       related);

          }
          else
          {
            using (var tx = session.BeginTransaction())
            {
              LoadInstancesForInternal(session,
                                       entityName,
                                       forEntityName,
                                       forEntityId,
                                       ref dataObjectMtList,
                                       out errors,
                                       relationshipName,
                                       related);

              tx.Commit();
            }
          }
        }

        entityInstances.TotalRows = dataObjectMtList.TotalRows;

        if (errors.Count > 0)
        {
          string message = String.Format("Cannot load items of type '{0}' for related type '{1}' and id '{2}'",
                                          entityName, forEntityName, forEntityId);

          throw new LoadDataException(message, errors);
        }

        foreach (DataObject item in dataObjectMtList.Items)
        {
          EntityInstance entityInstance =
              ConvertDataObjectToEntityInstance(item, false);
          Check.Require(entityInstance != null, "entityInstance cannot be null", SystemConfig.CallerInfo);
          entityInstances.Items.Add(entityInstance);
        }
      }
      catch (System.Exception e)
      {
        string message = String.Format("Cannot load items of type '{0}'", entityName);
        throw new LoadDataException(message, e);
      }

      return entityInstances;
    }

    
    /// <summary>
    /// 
    /// </summary>
    /// <param name="entityName"></param>
    /// <param name="mtList"></param>
    /// <param name="metranetEntity"></param>
    public virtual MTList<EntityInstance> LoadEntityInstancesForMetranetEntity(string entityName,
                                                                               IMetranetEntity metranetEntity,
                                                                               MTList<EntityInstance> mtList)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(mtList != null, "mtList cannot be null", SystemConfig.CallerInfo);
      
      MTList<DataObject> dataObjectMtList = LoadInstancesForMetranetEntity(entityName, metranetEntity, ConvertToDataObjectMtList(mtList));
      
      MTList<EntityInstance> entityInstances = CopyMtList(mtList);
      entityInstances.Items.Clear();
      
      foreach (DataObject item in dataObjectMtList.Items)
      {
        EntityInstance entityInstance = ConvertDataObjectToEntityInstance(item, false);
        Check.Require(entityInstance != null, "entityInstance cannot be null", SystemConfig.CallerInfo);
        entityInstances.Items.Add(entityInstance);
      }     

      return entityInstances;
    }

    #endregion

    #region Delete
    public virtual void DeleteEntityInstance(EntityInstance entityInstance)
    {
      Check.Require(entityInstance != null, "entityInstance cannot be null", SystemConfig.CallerInfo);
      Check.Require(entityInstance.Id != Guid.Empty, "entityInstance must have a non-empty Id", SystemConfig.CallerInfo);

      try
      {
        DeleteInternal(entityInstance.EntityFullName, entityInstance.Id);
      }
      catch (DeleteDataException)
      {
        throw;
      }
      catch (System.Exception e)
      {
        var message = String.Format("Cannot delete data object of type '{0}' and id '{1}",
                                     entityInstance.EntityFullName, entityInstance.Id);
        throw new DeleteDataException(message, e);
      }

    }
    #endregion

    #endregion

    #region Instance Methods

    #region Create/Update

    [Obsolete("Use SaveInstance<T>(ref T dataObject)")]
    public virtual DataObject SaveInstance(DataObject dataObject)
    {
      Check.Require(dataObject != null, "dataObject cannot be null");
      DataObject value;
      try
      {
        string entityName = dataObject.GetType().FullName;
        if (RepositoryAccess.Instance.IsEntityInOracle(entityName) && Transaction.Current != null)
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName))
          {
            SaveOrUpdateInternal(dataObject, session);
            value = dataObject;
            session.Clear();
          }
        }
        else
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName))
          using (var transaction = session.BeginTransaction())
          {
            SaveOrUpdateInternal(dataObject, session);
            value = dataObject;
            transaction.Commit();
            session.Clear();
          }
        }
      }
      catch (PropertyValueException e)
      {
        if (e.Message.StartsWith("not-null property references a null or transient value"))
        {
          throw new MissingRequiredPropertyException(String.Format("Missing property value for required property '{0}' on entity '{1}'",
                                                                   e.PropertyName, e.EntityName));
        }

        var message = String.Format("Cannot save data object of type '{0}' and id '{1}",
                                    dataObject.GetType().FullName, dataObject.Id);
        throw new SaveDataException(message, e);
      }
      catch (StaleObjectStateException)
      {
        string message = String.Format("Cannot save entity instance '{0}' with Id '{1}' because it has " +
                                       "been updated by another transaction. Refresh your data and try again.",
                                       dataObject.GetType().FullName, dataObject.Id);
        throw new OptimisticConcurrencyException(message);
      }
      catch (System.Exception e)
      {
        var message = String.Format("Cannot save data object of type '{0}' and id '{1}",
                                    dataObject.GetType().FullName, dataObject.Id);
        if (e.InnerException != null && e.InnerException.Message.Contains("Cannot insert duplicate key"))
        {
          message = String.Format("Cannot save data of type '{0}'; unique key constraint violated.", dataObject.GetType().FullName);
          throw new UniqueKeyViolationException(message, e);
        }
        throw new SaveDataException(message, e);
      }

      return value;
    }


    /// <summary>
    ///   
    /// </summary>
    /// <param name="dataObject"></param>
    public virtual void SaveInstance<T>(ref T dataObject) where T : DataObject
    {
      var dataObjects = new List<DataObject>() {dataObject};
      SaveInstances(ref dataObjects);
    }

    [Obsolete("Use SaveInstances<T>(ref List<T> dataObjects)")]
    public virtual List<DataObject> SaveInstances(List<DataObject> dataObjects)
    {
      SaveInstances(ref dataObjects);
      return dataObjects;
    }

    public virtual void SaveInstances<T>(ref List<T> dataObjects) where T : DataObject
    {
      List<DataObject> dataObjects1 = dataObjects.ConvertAll(d => d as DataObject).ToList();
      SaveInstances(ref dataObjects1);
    }

    [Obsolete("Use CreateInstanceFor<TForEntity, TInstance>(Guid forEntityId, ref TInstance dataObject)")]
    public virtual DataObject CreateInstanceFor(string forEntityName, Guid forEntityId, DataObject dataObject)
    {
      IList<DataObject> dataObjects =
        CreateInstancesFor(forEntityName, forEntityId, new List<DataObject>() { dataObject });

      return dataObjects[0];
    }

    public virtual void CreateInstanceFor<TForEntity, TInstance>(Guid forEntityId, ref TInstance dataObject, string relationshipName = null)
      where TForEntity : DataObject
      where TInstance : DataObject
    {
      var dataObjects = new List<TInstance>() { dataObject };
      CreateInstancesFor<TForEntity, TInstance>(forEntityId, ref dataObjects, relationshipName);
    }

    [Obsolete("Use CreateInstancesFor<TForEntity, TInstances>(Guid forEntityId, ref List<TInstances> dataObjects")]
    public virtual IList<DataObject> CreateInstancesFor(string forEntityName, Guid forEntityId, IList<DataObject> dataObjects)
    {
      CreateInstancesFor(forEntityName, forEntityId, ref dataObjects);
      return dataObjects;
    }

    public virtual void CreateInstancesFor<TForEntity, TInstances>(Guid forEntityId, ref List<TInstances> dataObjects, string relationshipName = null)
      where TForEntity : DataObject
      where TInstances : DataObject
    {
      IList<DataObject> dataObjects1 = dataObjects.ConvertAll(d => d as DataObject).ToList();
      CreateInstancesFor(typeof(TForEntity).FullName, forEntityId, ref dataObjects1, relationshipName);
    }

    [Obsolete("Self-Relationships have been removed")]
    public virtual DataObject CreateChild(Guid parentId, DataObject childDataObject)
    {
      throw new NotImplementedException("Self relationships have been removed");

      //IList<DataObject> dataObjects =
      //  CreateChildren(parentId, new List<DataObject>() { childDataObject });

      //return dataObjects[0];
    }

    /// <summary>
    ///   Saves the specified children for the given parentId. The entity must have a Self-Relationship
    /// </summary>
    [Obsolete("Self-Relationships have been removed")]
    public IList<DataObject> CreateChildren(Guid parentId, IList<DataObject> childDataObjects)
    {
      throw new NotImplementedException("Self relationships have been removed");

      //IList<DataObject> savedDataObjects = null;

      //if (childDataObjects == null || childDataObjects.Count == 0)
      //{
      //  return savedDataObjects;
      //}

      //try
      //{
      //  using (var session = RepositoryAccess.Instance.GetSession(childDataObjects[0].GetType().FullName, FlushMode.Never))
      //  using (var tx = session.BeginTransaction())
      //  {
      //    // session.SetBatchSize(100);
      //    List<ErrorObject> errors;
      //    savedDataObjects = CreateChildrenInternal(session, parentId, childDataObjects, out errors);
      //    if (errors.Count > 0)
      //    {
      //      string message = String.Format("Cannot save children for parent type '{0}' and id '{1}'", 
      //                                     childDataObjects[0].GetType().FullName, parentId);
      //      throw new SaveDataException(message, errors);
      //    }
      //    tx.Commit();
      //  }
      //}
      //catch (SaveDataException)
      //{
      //  throw;
      //}
      //catch (System.Exception e)
      //{
      //  string message = String.Format("Cannot save children for parent type '{0}' and id '{1}'",
      //                                 childDataObjects[0].GetType().FullName, parentId);
      //  throw new SaveDataException(message, e);
      //}

      //return savedDataObjects;
    }

    /// <summary>
    ///   If there is no direct relationship defined between source type and target type, return error.
    ///   If source or target have not been persisted, return error.
    ///   
    ///   If source and target have a relationship (i.e. a row in the relationship table)
    ///   Then this method does nothing.
    /// 
    ///   Case 1: Source type has a One-to-One relationship with Target type
    ///           
    ///           The existing relationship for source (if any) is deleted.
    ///           The existing relationship for target (if any) is deleted.
    ///           A new relationship is created between source and target.
    ///   
    ///   Case 2: Source type has a One-to-Many relationship with Target type
    ///           Create a new relationship
    /// 
    ///   Case 3: Source type has a Many-to-Many relationship with Target type 
    ///           Create a new relationship
    /// 
    /// </summary>
    /// <param name="source"></param>
    /// <param name="target"></param>
    //[Obsolete("Use the RelationshipProperty on source or target")]
    public virtual void CreateRelationship(DataObject source, DataObject target)
    {
      var relationshipInstanceDataList = new List<RelationshipInstanceData>();
      relationshipInstanceDataList.Add(new RelationshipInstanceData() {Source = source, Target = target});
      CreateRelationshipInternal(relationshipInstanceDataList);
    }

   // [Obsolete("Use the RelationshipProperty on source or target")]
    public virtual void CreateRelationship<TSource, TTarget>(TSource source, TTarget target)
      where TSource : DataObject
      where TTarget : DataObject
    {
      var relationshipInstanceDataList = new List<RelationshipInstanceData>();
      relationshipInstanceDataList.Add(new RelationshipInstanceData() { Source = source, Target = target });
      CreateRelationshipInternal(relationshipInstanceDataList);
    }

    public virtual void CreateRelationships(List<RelationshipInstanceData> relationshipInstanceDataList)
    {
      CreateRelationshipInternal(relationshipInstanceDataList);
    }

    #endregion

    #region Load
    public virtual DataObject LoadInstance(string entityName, Guid id)
    {
      DataObject dataObject = null;

      try
      {
        if (RepositoryAccess.Instance.IsEntityInOracle(entityName) && Transaction.Current != null)
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName, FlushMode.Never))
          {
            dataObject = LoadInternal(entityName, session, id);
          }
        }
        else
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName, FlushMode.Never))
          using (var tx = session.BeginTransaction())
          {
            dataObject = LoadInternal(entityName, session, id);
            tx.Commit();
          }
        }
      }
      catch (System.Exception e)
      {
        string message = String.Format("Cannot load type '{0}' with id '{1}", entityName, id);
        throw new LoadDataException(message, e);
      }

      return dataObject;
    }

    public virtual T LoadInstance<T>(Guid id) where T : DataObject
    {
      return LoadInstance(typeof(T).FullName, id) as T;
    }

    public virtual DataObject LoadInstanceByBusinessKey(string entityName, BusinessKey businessKey)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(businessKey != null, "businessKey cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(!businessKey.HasNullProperties(), String.Format("businessKey cannot have null property values '{0}'", businessKey));

      DataObject dataObject = null;

      try
      {
        logger.Debug(String.Format("Loading instance for entity name '{0}' and business key '{1}'", 
                                   entityName, businessKey));

        var mtList = new MTList<DataObject>();
        mtList.Filters = new List<MTBaseFilterElement>();
        List<PropertyInstance> propertyInstances = businessKey.GetPropertyData();
        foreach (PropertyInstance propertyInstance in propertyInstances)
        {
          mtList.Filters.Add(new MTFilterElement(propertyInstance.Name,
                                                 MTFilterElement.OperationType.Equal,
                                                 propertyInstance.Value));
        }

        MTList<DataObject> instances = LoadInstances(entityName, mtList);
        Check.Ensure(instances.Items.Count <= 1,
                     String.Format("Found more than one instance for entity '{0}' and business key '{1}'",
                                   entityName,
                                   businessKey),
                     SystemConfig.CallerInfo);

        if (instances.Items.Count == 1)
        {
          dataObject = instances.Items[0];
        }
      }
      catch (System.Exception e)
      {
        string message = String.Format("Cannot load instance for entity name '{0}' and business key '{1}'",
                                       entityName, businessKey);
        throw new LoadDataException(message, e);
      }

      return dataObject;
    }

    public virtual TDataObject LoadInstanceByBusinessKey<TDataObject, TBusinessKey>(TBusinessKey businessKey)
      where TDataObject : DataObject
      where TBusinessKey : BusinessKey
    {
      return LoadInstanceByBusinessKey(typeof (TDataObject).FullName, businessKey) as TDataObject;
    }

    public virtual DataObject LoadInstanceByBusinessKeyProperties(string entityName, List<PropertyInstance> businessKeyProperties)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(businessKeyProperties != null, "businessKeyProperties cannot be null", SystemConfig.CallerInfo);

      BusinessKey.CheckProperties(entityName, businessKeyProperties);
      DataObject dataObject = null;

      string businessKeyLog =
        String.Join(System.Environment.NewLine, (from p in businessKeyProperties select p.ToString()).ToArray());

      try
      {
        logger.Debug(String.Format("Loading instance for entity name '{0}' and business key '{1}'",
                                   entityName, businessKeyLog));

        var mtList = new MTList<DataObject>();
        mtList.Filters = new List<MTBaseFilterElement>();
        foreach (PropertyInstance propertyInstance in businessKeyProperties)
        {
          mtList.Filters.Add(new MTFilterElement(propertyInstance.Name,
                                                 MTFilterElement.OperationType.Equal,
                                                 propertyInstance.Value));
        }

        MTList<DataObject> instances = LoadInstances(entityName, mtList);
        Check.Ensure(instances.Items.Count <= 1,
                     String.Format("Found more than one instance for entity '{0}' and business key '{1}'",
                                   entityName,
                                   businessKeyLog),
                     SystemConfig.CallerInfo);

        if (instances.Items.Count == 1)
        {
          dataObject = instances.Items[0];
        }
      }
      catch (System.Exception e)
      {
        string message = String.Format("Cannot load instance for entity name '{0}' and business key '{1}'",
                                       entityName, businessKeyLog);
        throw new LoadDataException(message, e);
      }

      return dataObject;
    }
    /// <summary>
    ///   Returns rows for the specified type based on filter criteria.
    /// </summary>
    public virtual MTList<DataObject> LoadInstances(string entityName, MTList<DataObject> mtList)
    {
      Check.Require(mtList != null, "mtList cannot be null", SystemConfig.CallerInfo);

      try
      {
        if (RepositoryAccess.Instance.IsEntityInOracle(entityName) && Transaction.Current != null)
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName, FlushMode.Never))
          {
            LoadInstancesInternal(entityName, session, ref mtList);
          }
        }
        else
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName, FlushMode.Never))
          using (var tx = session.BeginTransaction())
          {
            LoadInstancesInternal(entityName, session, ref mtList);
            tx.Commit();
          }
        }
      }
      catch (System.Exception e)
      {
        string message = String.Format("Cannot load items of type '{0}'", entityName);
        throw new LoadDataException(message, e);
      }

      return mtList;
    }
    
    public virtual void LoadInstances<T>(ref MTList<T> mtList) where T : DataObject
    {
      Check.Require(mtList != null, "mtList cannot be null");
      try
      {
        mtList.Items.Clear();
        MTList<DataObject> mtListDataObject = CopyMtList<T, DataObject>(mtList);

        string entityName = typeof (T).FullName;
        if (RepositoryAccess.Instance.IsEntityInOracle(entityName) && Transaction.Current != null)
        {
          using (var session = RepositoryAccess.Instance.GetSession(typeof(T).FullName, FlushMode.Never))
          {
            LoadInstancesInternal(typeof(T).FullName, session, ref mtListDataObject);
          }
        }
        else
        {
          using (var session = RepositoryAccess.Instance.GetSession(typeof(T).FullName, FlushMode.Never))
          using (var tx = session.BeginTransaction())
          {
            LoadInstancesInternal(typeof(T).FullName, session, ref mtListDataObject);
            tx.Commit();
          }
        }

        mtList.TotalRows = mtListDataObject.TotalRows;
        foreach (DataObject dataObject in mtListDataObject.Items)
        {
          dataObject.SetupRelationships();
          mtList.Items.Add(dataObject as T);
        }
      }
      catch (System.Exception e)
      {
        string message = String.Format("Cannot load items of type '{0}'", typeof(T).FullName);
        throw new LoadDataException(message, e);
      }
    }

    public virtual DataObject LoadInstanceFor(string entityName, string forEntityName, Guid forEntityId, string relationshipName = null)
    {
      DataObject dataObject = null;

      MTList<DataObject> dataObjects = LoadInstancesFor(entityName,
                                                        forEntityName,
                                                        forEntityId,
                                                        new MTList<DataObject>(),
                                                        relationshipName);

      if (dataObjects.Items.Count > 0)
      {
        dataObject = dataObjects.Items[0];
      }

      return dataObject;
    }

    public virtual TInstance LoadInstanceFor<TForEntity, TInstance>(Guid forEntityId, string relationshipName = null)
      where TForEntity : DataObject
      where TInstance : DataObject
    {
      var mtList = new MTList<TInstance>();
      LoadInstancesFor<TForEntity, TInstance>(forEntityId, ref mtList, relationshipName);

      TInstance instance = null;
      if (mtList.Items.Count > 0)
      {
        instance = mtList.Items[0];
      }

      return instance;
    }

    /// <summary>
    ///   Returns rows for the specified type (T) based on the filter criteria and 
    ///   given the parentTypeName and parentId.
    /// </summary>
    /// 
    public virtual MTList<DataObject> LoadInstancesFor(string entityName,
                                                       string forEntityName,
                                                       Guid forEntityId,
                                                       MTList<DataObject> mtList,
                                                       string relationshipName = null,
                                                       bool related = true)
    {
      try
      {
        List<ErrorObject> errors;
        if (RepositoryAccess.Instance.IsEntityInOracle(entityName) && Transaction.Current != null)
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName, FlushMode.Never))
          {
            LoadInstancesForInternal(session, entityName, forEntityName, forEntityId, ref mtList, out errors, relationshipName, related);
          }
        }
        else
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName, FlushMode.Never))
          using (var tx = session.BeginTransaction())
          {
            LoadInstancesForInternal(session, entityName, forEntityName, forEntityId, ref mtList, out errors, relationshipName);
            tx.Commit();
          }
        }
  
        if (errors.Count > 0)
        {
          string message = String.Format("Cannot load items of type '{0}' for related type '{1}' and id '{2}'",
                                          entityName, forEntityName, forEntityId);

          throw new LoadDataException(message, errors);
        }
      }
      catch (LoadDataException)
      {
        throw;
      }
      catch (System.Exception e)
      {
        string message =
          String.Format("Cannot load items of type '{0}' for related type '{1}' and id '{2}'",
                        entityName, forEntityName, forEntityId);
        throw new LoadDataException(message, e);
      }

      return mtList;
    }

    public virtual void LoadInstancesFor<TForEntity, TInstance>(TForEntity forEntity, 
                                                                ref MTList<TInstance> mtList, 
                                                                string relationshipName = null,
                                                                bool related = true) 
      where TForEntity : DataObject
      where TInstance : DataObject
    {
      LoadInstancesFor<TForEntity, TInstance>(forEntity.Id, ref mtList, relationshipName, related);
      if (mtList.Items.Count > 0)
      {
        RelationshipEntity relationshipEntity =
          MetadataRepository.Instance.GetRelationshipEntity(typeof(TInstance).FullName, typeof(TForEntity).FullName, relationshipName);
        if (relationshipEntity.IsManyEnd(typeof(TInstance).FullName) && relationshipEntity.RelationshipType != RelationshipType.ManyToMany)
        {
          foreach(TInstance dataObject in mtList.Items)
          {
            dataObject.SetValue(forEntity, relationshipEntity.TargetPropertyNameForSource);
          }
        }
      }
    }

    public virtual void LoadInstancesFor<TForEntity, TInstance>(Guid forEntityId, 
                                                                ref MTList<TInstance> mtList, 
                                                                string relationshipName = null,
                                                                bool related = true) 
      where TForEntity : DataObject
      where TInstance : DataObject
    {
      try
      {
        List<ErrorObject> errors;
        mtList.Items.Clear();
        MTList<DataObject> mtListDataObject = CopyMtList<TInstance, DataObject>(mtList);

        string entityName = typeof (TInstance).FullName;
        if (RepositoryAccess.Instance.IsEntityInOracle(entityName) && Transaction.Current != null)
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName, FlushMode.Never))
          {
            LoadInstancesForInternal(session,
                                     typeof(TInstance).FullName,
                                     typeof(TForEntity).FullName,
                                     forEntityId,
                                     ref mtListDataObject,
                                     out errors,
                                     relationshipName,
                                     related);
          }
        }
        else
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName, FlushMode.Never))
          using (var tx = session.BeginTransaction())
          {
            LoadInstancesForInternal(session,
                                     typeof(TInstance).FullName,
                                     typeof(TForEntity).FullName,
                                     forEntityId,
                                     ref mtListDataObject,
                                     out errors,
                                     relationshipName,
                                     related);
            tx.Commit();
          }
        }

        if (errors.Count > 0)
        {
          string message = String.Format("Cannot load items of type '{0}' for related type '{1}' and id '{2}'",
                                          typeof(TInstance).FullName, typeof(TForEntity).FullName, forEntityId);

          throw new LoadDataException(message, errors);
        }

        foreach (DataObject dataObject in mtListDataObject.Items)
        {
          mtList.Items.Add(dataObject as TInstance);
        }

        mtList.TotalRows = mtListDataObject.TotalRows;
      }
      catch (LoadDataException)
      {
        throw;
      }
      catch (System.Exception e)
      {
        string message =
          String.Format("Cannot load items of type '{0}' for related type '{1}' and id '{2}'",
                        typeof(TInstance).FullName, typeof(TForEntity).FullName, forEntityId);
        throw new LoadDataException(message, e);
      }
    }

    public virtual MTList<DataObject> LoadInstancesForMetranetEntity(string entityName,
                                                                     IMetranetEntity metranetEntity,
                                                                     MTList<DataObject> mtList)
    {
      try
      {
        using (var session = RepositoryAccess.Instance.GetSession(entityName, FlushMode.Never))
        {
          if (RepositoryAccess.Instance.IsEntityInOracle(entityName) && Transaction.Current != null)
          {

            LoadInstancesForMetranetEntityInternal(session, entityName, ref mtList, metranetEntity);
          }
          else
          {
            using (var tx = session.BeginTransaction())
            {
              LoadInstancesForMetranetEntityInternal(session, entityName, ref mtList, metranetEntity);
              tx.Commit();
            }
          }
        }
      }
      catch (System.Exception e)
      {
        string message = String.Format("Cannot load items of type '{0}' for metranet entity '{1}",
                                       entityName, metranetEntity.MetraNetEntityConfig.AssemblyQualifiedName);
        throw new LoadDataException(message, e);
      }

      return mtList;
    }

    /// <summary>
    ///   Load the children for the given parentId. The parent entity must have a self relationship.
    /// </summary>
    /// <param name="parentEntityName"></param>
    /// <param name="parentId"></param>
    /// <param name="mtList"></param>
    /// <returns></returns>
    [Obsolete("Self-Relationships as they existed in version 6.2, have been removed. This method will throw a NotImplementedException")]
    public MTList<DataObject> LoadChildren(string parentEntityName, Guid parentId, MTList<DataObject> mtList)
    {
      throw new NotImplementedException("Self-Relationships have been removed.");

      //try
      //{
      //  using (var session = RepositoryAccess.Instance.GetSession(parentEntityName, FlushMode.Never))
      //  using (var tx = session.BeginTransaction())
      //  {
      //    List<ErrorObject> errors;
      //    LoadChildrenInternal(session, parentEntityName, parentId, ref mtList, out errors);
      //    if (errors.Count > 0)
      //    {
      //      string message = String.Format("Cannot load items of children for parent entity type '{0}' and id '{1}'",
      //                                      parentEntityName, parentId);

      //      throw new LoadDataException(message, errors);
      //    }
      //    tx.Commit();
      //  }
      //}
      //catch (LoadDataException)
      //{
      //  throw;
      //}
      //catch (System.Exception e)
      //{
      //  string message = String.Format("Cannot load items of children for parent entity type '{0}' and id '{1}'",
      //                                 parentEntityName, parentId);
      //  throw new LoadDataException(message, e);
      //}

      //return mtList;
    }

    public virtual T LoadEdge<T>(Guid parentId, Guid childId) where T: DataObject
    {
      Check.Require(parentId != Guid.Empty, "parentId cannot be an empty Guid");
      Check.Require(childId != Guid.Empty, "childId cannot be an empty Guid");

      IList<T> edges;
      try
      {
        string entityName = typeof (T).FullName;
        if (RepositoryAccess.Instance.IsEntityInOracle(entityName) && Transaction.Current != null)
        {
          using (var session = RepositoryAccess.Instance.GetSession(typeof(T).FullName, FlushMode.Never))
          {
            edges = session.CreateCriteria<T>()
                           .CreateAlias("Parent", "parent")
                           .CreateAlias("Child", "child")
                           .Add(Expression.Eq("parent.Id", parentId))
                           .Add(Expression.Eq("child.Id", childId))
                           .List<T>();
            
            session.Clear();
          }
        }
        else
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName, FlushMode.Never))
          using (var tx = session.BeginTransaction())
          {
            edges = session.CreateCriteria<T>()
                           .CreateAlias("Parent", "parent")
                           .CreateAlias("Child", "child")
                           .Add(Expression.Eq("parent.Id", parentId))
                           .Add(Expression.Eq("child.Id", childId))
                           .List<T>();
            tx.Commit();
            session.Clear();
          }
        }
      }
      catch (LoadDataException)
      {
        throw;
      }
      catch (System.Exception e)
      {
        string message =
          String.Format("Cannot load item of type '{0}' using parentId = '{1}' and childId = '{2}'",
                        typeof(T).FullName, parentId, childId);
        throw new LoadDataException(message, e);
      }

      if (edges.Count > 1)
      {
        string message =
          String.Format("Found multiple items of type '{0}' with parentId = '{1}' and childId = '{2}'",
                        typeof(T).FullName, parentId, childId);
        throw new LoadDataException(message);
      }

      T edge = edges.Count == 1 ? edges[0] : null;
      if (edge != null)
      {
        edge.SetupRelationships();
      }

      return edge;
    }

    /// <summary>
    ///    (1) Used to load children that are represented via a foreign key to the parent in the same table (trees)
    ///    (2) Used to load children that are represented via edges in a join table (graphs)
    /// 
    /// If there is more than one relationship (e.g. ManagedBy and PaidBy for accounts) a relationshipName must be specified.
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="parentId"></param>
    /// <param name="children"></param>
    /// <param name="relationshipName"></param>
    public virtual void LoadChildren<T>(Guid parentId, ref MTList<T> children, string relationshipName = null) where T : DataObject
    {
      Check.Require(parentId != Guid.Empty, "parentId cannot be an empty Guid");

      List<RelationshipEntity> relationshipEntities = 
        MetadataRepository.Instance.GetSelfRelationshipEntities(typeof (T).FullName, relationshipName);
      Check.Require(relationshipEntities.Count > 0, String.Format("Cannot find a self-relationship for entity '{0}'", typeof(T).FullName));

      if (relationshipEntities.Count == 1)
      {
        Check.Require(relationshipEntities[0].SourceEntityName == relationshipEntities[0].TargetEntityName,
                      String.Format("Found invalid relationship '{0}'", relationshipEntities[0]));
      }
      else if (relationshipEntities.Count == 2)
      {
        Check.Require(relationshipEntities[0].SourceEntityName == relationshipEntities[1].SourceEntityName,
                      String.Format("Found invalid relationships '{0}' and '{1}'", relationshipEntities[0], relationshipEntities[1]));
        Check.Require(relationshipEntities[0].TargetEntityName == relationshipEntities[1].TargetEntityName,
                      String.Format("Found invalid relationships '{0}' and '{1}'", relationshipEntities[0], relationshipEntities[1]));
      }
      else
      {
        string message = String.IsNullOrEmpty(relationshipName)
                           ? String.Format("Found the following multiple self-relationships for entity '{0}' : '{1}'",
                                           typeof (T).FullName,
                                           StringUtil.Join(", ", relationshipEntities, r => r.ToString()))
                           : String.Format("Found the following multiple self-relationships for entity '{0}' and relationship name '{1}' : '{2}'",
                                           typeof (T).FullName,
                                           relationshipName,
                                           StringUtil.Join(", ", relationshipEntities, r => r.ToString()));

        throw new LoadDataException(message);
      }

      try
      {
        children.Items.Clear();
        MTList<DataObject> mtListDataObject = CopyMtList<T, DataObject>(children);

        string entityName = typeof (T).FullName;
        if (RepositoryAccess.Instance.IsEntityInOracle(entityName) && Transaction.Current != null)
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName, FlushMode.Never))
          {
            DetachedCriteria pageCriteria, countCriteria;
            GetQueryCriteria(session, typeof(T).FullName, mtListDataObject, out pageCriteria, out countCriteria);

            if (relationshipEntities.Count == 1)
            {
              pageCriteria.CreateAlias(relationshipEntities[0].TargetPropertyNameForSource, "alias")
                          .Add(Restrictions.Eq("alias.Id", parentId));
            }
            else
            {
              // Must see 'Child'
              RelationshipEntity relationshipEntity = relationshipEntities.Find(r => r.TargetPropertyNameForSource == "Child");
              Check.Require(relationshipEntity != null, String.Format("Cannot find 'Child' property on relationship entity '{0}'",
                                                                       relationshipEntities[0]));

              pageCriteria.CreateAlias(relationshipEntity.SourcePropertyNameForTarget, "alias")
                          .Add(Restrictions.Eq("alias.Parent.Id", parentId));

            }

            // Reset count criteria
            countCriteria = CriteriaTransformer.TransformToRowCount(pageCriteria);
            ExecutePagingQuery(session,
                               pageCriteria,
                               countCriteria,
                               ref mtListDataObject,
                               RepositoryAccess.Instance.IsEntityInOracle(entityName));

            foreach (DataObject dataObject in mtListDataObject.Items)
            {
              children.Items.Add(dataObject as T);
            }
          }
        }
        else
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName, FlushMode.Never))
          using (var tx = session.BeginTransaction())
          {
            DetachedCriteria pageCriteria, countCriteria;
            GetQueryCriteria(session, typeof(T).FullName, mtListDataObject, out pageCriteria, out countCriteria);

            if (relationshipEntities.Count == 1)
            {
              pageCriteria.CreateAlias(relationshipEntities[0].TargetPropertyNameForSource, "alias")
                          .Add(Restrictions.Eq("alias.Id", parentId));
            }
            else
            {
              // Must see 'Child'
              RelationshipEntity relationshipEntity = relationshipEntities.Find(r => r.TargetPropertyNameForSource == "Child");
              Check.Require(relationshipEntity != null, String.Format("Cannot find 'Child' property on relationship entity '{0}'",
                                                                       relationshipEntities[0]));

              pageCriteria.CreateAlias(relationshipEntity.SourcePropertyNameForTarget, "alias")
                          .Add(Restrictions.Eq("alias.Parent.Id", parentId));

            }

            // Reset count criteria
            countCriteria = CriteriaTransformer.TransformToRowCount(pageCriteria);
            ExecutePagingQuery(session,
                               pageCriteria,
                               countCriteria,
                               ref mtListDataObject,
                               RepositoryAccess.Instance.IsEntityInOracle(entityName));

            foreach (DataObject dataObject in mtListDataObject.Items)
            {
              children.Items.Add(dataObject as T);
            }

            tx.Commit();
          }
        }
      }
      catch (System.Exception e)
      {
        string message =
          String.IsNullOrEmpty(relationshipName)
            ? String.Format("Cannot load children for type '{0}'", typeof (T).FullName)
            : String.Format("Cannot load children for type '{0}' and relationship '{1}'", typeof (T).FullName,
                            relationshipName);

        throw new LoadDataException(message, e);
      }
    }

    public virtual T LoadParent<T>(Guid childId, string relationshipName = null) where T: DataObject
    {
      var mtList = new MTList<T>();
      LoadParents<T>(childId, ref mtList, relationshipName);

      if (mtList.Items.Count > 1)
      {
        throw new LoadDataException(String.Format("Found multiple parents for child entity '{0}' with Id '{1}'. Use LoadParents.",
                                                  typeof(T).FullName, childId));
      }

      return mtList.Items.Count == 1 ? mtList.Items[0] : null;
    }

    public virtual void LoadParents<T>(Guid childId, ref MTList<T> parents, string relationshipName = null) where T: DataObject
    {
      Check.Require(childId != Guid.Empty, "childId cannot be an empty Guid");

      List<RelationshipEntity> relationshipEntities =
        MetadataRepository.Instance.GetSelfRelationshipEntities(typeof(T).FullName, relationshipName);
      Check.Require(relationshipEntities.Count > 0, String.Format("Cannot find a self-relationship for entity '{0}'", typeof(T).FullName));

      if (relationshipEntities.Count == 1)
      {
        Check.Require(relationshipEntities[0].SourceEntityName == relationshipEntities[0].TargetEntityName,
                      String.Format("Found invalid relationship '{0}'", relationshipEntities[0]));
      }
      else if (relationshipEntities.Count == 2)
      {
        Check.Require(relationshipEntities[0].SourceEntityName == relationshipEntities[1].SourceEntityName,
                      String.Format("Found invalid relationships '{0}' and '{1}'", relationshipEntities[0], relationshipEntities[1]));
        Check.Require(relationshipEntities[0].TargetEntityName == relationshipEntities[1].TargetEntityName,
                      String.Format("Found invalid relationships '{0}' and '{1}'", relationshipEntities[0], relationshipEntities[1]));
      }
      else
      {
        string message = String.IsNullOrEmpty(relationshipName)
                           ? String.Format("Found the following multiple self-relationships for entity '{0}' : '{1}'",
                                           typeof(T).FullName,
                                           StringUtil.Join(", ", relationshipEntities, r => r.ToString()))
                           : String.Format("Found the following multiple self-relationships for entity '{0}' and relationship name '{1}' : '{2}'",
                                           typeof(T).FullName,
                                           relationshipName,
                                           StringUtil.Join(", ", relationshipEntities, r => r.ToString()));

        throw new LoadDataException(message);
      }

      try
      {
        parents.Items.Clear();
        MTList<DataObject> mtListDataObject = CopyMtList<T, DataObject>(parents);

        if (RepositoryAccess.Instance.IsEntityInOracle(typeof(T).FullName) && Transaction.Current != null)
        {
          using (var session = RepositoryAccess.Instance.GetSession(typeof(T).FullName, FlushMode.Never))
          {
            DetachedCriteria pageCriteria, countCriteria;
            GetQueryCriteria(session, typeof(T).FullName, mtListDataObject, out pageCriteria, out countCriteria);

            if (relationshipEntities.Count == 1)
            {
              pageCriteria.CreateAlias(relationshipEntities[0].SourcePropertyNameForTarget, "alias")
                          .Add(Restrictions.Eq("alias.Id", childId));
            }
            else
            {
              // Must see 'Parent'
              RelationshipEntity relationshipEntity = relationshipEntities.Find(r => r.TargetPropertyNameForSource == "Parent");
              Check.Require(relationshipEntity != null, String.Format("Cannot find 'Parent' property on relationship entity '{0}'",
                                                                       relationshipEntities[0]));

              pageCriteria.CreateAlias(relationshipEntity.SourcePropertyNameForTarget, "alias")
                          .Add(Restrictions.Eq("alias.Child.Id", childId));

            }

            // Reset count criteria
            countCriteria = CriteriaTransformer.TransformToRowCount(pageCriteria);
            ExecutePagingQuery(session,
                               pageCriteria,
                               countCriteria,
                               ref mtListDataObject,
                               RepositoryAccess.Instance.IsEntityInOracle(typeof(T).FullName));

            foreach (DataObject dataObject in mtListDataObject.Items)
            {
              parents.Items.Add(dataObject as T);
            }
          }
        }
        else
        {
          using (var session = RepositoryAccess.Instance.GetSession(typeof(T).FullName, FlushMode.Never))
          using (var tx = session.BeginTransaction())
          {
            DetachedCriteria pageCriteria, countCriteria;
            GetQueryCriteria(session, typeof(T).FullName, mtListDataObject, out pageCriteria, out countCriteria);

            if (relationshipEntities.Count == 1)
            {
              pageCriteria.CreateAlias(relationshipEntities[0].SourcePropertyNameForTarget, "alias")
                          .Add(Restrictions.Eq("alias.Id", childId));
            }
            else
            {
              // Must see 'Parent'
              RelationshipEntity relationshipEntity = relationshipEntities.Find(r => r.TargetPropertyNameForSource == "Parent");
              Check.Require(relationshipEntity != null, String.Format("Cannot find 'Parent' property on relationship entity '{0}'",
                                                                       relationshipEntities[0]));

              pageCriteria.CreateAlias(relationshipEntity.SourcePropertyNameForTarget, "alias")
                          .Add(Restrictions.Eq("alias.Child.Id", childId));

            }

            // Reset count criteria
            countCriteria = CriteriaTransformer.TransformToRowCount(pageCriteria);
            ExecutePagingQuery(session,
                               pageCriteria,
                               countCriteria,
                               ref mtListDataObject,
                               RepositoryAccess.Instance.IsEntityInOracle(typeof(T).FullName));

            foreach (DataObject dataObject in mtListDataObject.Items)
            {
              parents.Items.Add(dataObject as T);
            }

            tx.Commit();
          }
        }
      }
      catch (System.Exception e)
      {
        string message =
          String.IsNullOrEmpty(relationshipName)
            ? String.Format("Cannot load children for type '{0}'", typeof (T).FullName)
            : String.Format("Cannot load children for type '{0}' and relationship '{1}'", typeof (T).FullName,
                            relationshipName);

        throw new LoadDataException(message, e);
      }
    }

    
    /// <summary>
    ///   Load the instance with the given Id with values that existed for the specified effectiveDate.
    ///   This will return null for the following cases:
    ///     - if the specified entityName does not record history.
    ///     - if no history row is found with effectiveDate between start and end dates
    /// </summary>
    /// <param name="entityName"></param>
    /// <param name="Id"></param>
    /// <param name="effectiveDate"></param>
    /// <returns></returns>
    public virtual DataObject LoadInstanceHistory(string entityName, Guid id, DateTime effectiveDate)
    {
      DataObject dataObject = null;

      Entity entity = MetadataRepository.Instance.GetEntity(entityName);

      if (entity == null)
      {
        logger.Debug(String.Format("Cannot find entity '{0}'", entityName));
        return dataObject;
      }

      if (entity.RecordHistory == false)
      {
        logger.Debug(String.Format("Entity '{0}' has not been setup to record history", entityName));
        return dataObject;
      }

      string historyTypeName = Name.GetEntityHistoryTypeName(entityName);
      Entity historyEntity = MetadataRepository.Instance.GetEntity(historyTypeName);

      if (historyEntity == null)
      {
        logger.Debug(String.Format("Cannot find history entity '{0}' for entity '{1}'", historyTypeName, entityName));
        return dataObject;
      }

      try
      {
        IList historyList;

        if (RepositoryAccess.Instance.IsEntityInOracle(entityName) && Transaction.Current != null)
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName, FlushMode.Never))
          {
            historyList =
              session.CreateCriteria(historyTypeName)
              .Add(Expression.Lt(BaseHistory.StartDatePropertyName, effectiveDate.ToUniversalTime()))
              .Add(Expression.Gt(BaseHistory.EndDatePropertyName, effectiveDate.ToUniversalTime()))
              .Add(Expression.Eq(entity.ClassName + "Id", id))
              .List();
          }
        }
        else
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName, FlushMode.Never))
          using (var tx = session.BeginTransaction())
          {
            historyList =
              session.CreateCriteria(historyTypeName)
              .Add(Expression.Lt(BaseHistory.StartDatePropertyName, effectiveDate.ToUniversalTime()))
              .Add(Expression.Gt(BaseHistory.EndDatePropertyName, effectiveDate.ToUniversalTime()))
              .Add(Expression.Eq(entity.ClassName + "Id", id))
              .List();

            tx.Commit();
          }
        }

        if (historyList.Count > 1)
        {
          logger.Warn(String.Format("Found more than one history row for entity '{0}' with id '{1}' for date '{2}'",
                                    historyTypeName, id, effectiveDate));
        }

        if (historyList.Count > 0)
        {
          var history = historyList[0] as BaseHistory;
          Check.Require(history != null, String.Format("Cannot cast history entity '{0}' to BaseHistory", historyTypeName));
          dataObject = history.GetDataObject();
        }
      }
      catch (System.Exception e)
      {
        string message = String.Format("Cannot load history for entity '{0}' with id '{1}' for date '{2}'",
                                       historyTypeName, id, effectiveDate);

        throw new LoadDataException(message, e);
      }

      return dataObject;
    }

    public virtual T LoadInstanceHistory<T>(Guid id, DateTime effectiveDate) where T : DataObject
    {
      return LoadInstanceHistory(typeof (T).FullName, id, effectiveDate) as T;
    }

    /// <summary>
    ///   Returns history rows for the specified type based on filter criteria.
    /// </summary>
    public virtual MTList<DataObject> LoadHistoryInstances(string entityName, MTList<DataObject> mtList)
    {
      Check.Require(mtList != null, "mtList cannot be null", SystemConfig.CallerInfo);
      MTList<DataObject> dataObjects = null;

      Entity entity = MetadataRepository.Instance.GetEntity(entityName);

      if (entity == null)
      {
        logger.Debug(String.Format("Cannot find entity '{0}'", entityName));
        return dataObjects;
      }

      if (entity.RecordHistory == false)
      {
        logger.Debug(String.Format("Entity '{0}' has not been setup to record history", entityName));
        return dataObjects;
      }

      string historyTypeName = Name.GetEntityHistoryTypeName(entityName);
      Entity historyEntity = MetadataRepository.Instance.GetEntity(historyTypeName);

      if (historyEntity == null)
      {
        logger.Debug(String.Format("Cannot find history entity '{0}' for entity '{1}'", historyTypeName, entityName));
        return dataObjects;
      }

      return LoadInstances(historyEntity.FullName, mtList);
    }

    #endregion

    #region Delete
    public virtual void DeleteInstance(DataObject dataObject)
    {
      Check.Require(dataObject != null, "dataObject cannot be null", SystemConfig.CallerInfo);
      Check.Require(dataObject.Id != Guid.Empty, "dataObject cannot have an empty Id", SystemConfig.CallerInfo);

      Delete(dataObject.GetType().FullName, dataObject.Id);
    }

    public void DeleteRelationship(DataObject source, DataObject target)
    {
      var relationshipInstanceDataList = new List<RelationshipInstanceData>();
      relationshipInstanceDataList.Add(new RelationshipInstanceData() { Source = source, Target = target });
      DeleteRelationships(relationshipInstanceDataList);
    }

    /// <summary>
    ///   If there is no direct relationship defined between source type and target type, return error.
    ///   If source or target have not been persisted, return error.
    /// 
    ///   If source and target have a relationship (i.e. a row in the relationship table)
    ///   delete the relationship, otherwise do nothing.
    /// </summary>
    /// <param name="relationshipInstanceDataList"></param>
    public void DeleteRelationships(List<RelationshipInstanceData> relationshipInstanceDataList)
    {
      Check.Require(relationshipInstanceDataList != null, "relationshipInstanceDataList cannot be null");
      if (relationshipInstanceDataList.Count == 0)
      {
        return;
      }

      Check.Require(relationshipInstanceDataList[0].Source != null, "source cannot be null");
   
      using (var session = RepositoryAccess.Instance.GetSession(relationshipInstanceDataList[0].Source.GetType().FullName, FlushMode.Never))
      using (var tx = session.BeginTransaction())
      {
        foreach (RelationshipInstanceData relationshipInstanceData in relationshipInstanceDataList)
        {
          Check.Require(relationshipInstanceData.Source != null, "source cannot be null");
          Check.Require(relationshipInstanceData.Target != null, "target cannot be null");
          Check.Require(relationshipInstanceData.Source.Id != Guid.Empty,
                        String.Format("Cannot delete relationship with non-persisted instance of type '{0}'",
                                      relationshipInstanceData.Source.GetType().FullName));
          Check.Require(relationshipInstanceData.Target.Id != Guid.Empty,
                        String.Format("Cannot delete relationship with non-persisted instance of type '{0}'",
                                      relationshipInstanceData.Target.GetType().FullName));

          RelationshipEntity relationshipEntity =
           MetadataRepository.Instance.GetRelationshipEntity(relationshipInstanceData.Source.GetType().FullName,
                                                             relationshipInstanceData.Target.GetType().FullName);

          Check.Require(relationshipEntity != null,
                        String.Format("Failed to find relationship between '{0}' and '{1}'",
                                      relationshipInstanceData.Source.GetType().FullName,
                                      relationshipInstanceData.Target.GetType().FullName));

          DataObject actualSource, actualTarget;
          if (relationshipInstanceData.Source.GetType().FullName == relationshipEntity.SourceEntityName)
          {
            actualSource = relationshipInstanceData.Source;
            actualTarget = relationshipInstanceData.Target;
          }
          else
          {
            actualSource = relationshipInstanceData.Target;
            actualTarget = relationshipInstanceData.Source;
          }

          // No join tables
          if (!relationshipEntity.HasJoinTable)
          {
            if (relationshipEntity.RelationshipType == RelationshipType.OneToMany ||
                relationshipEntity.RelationshipType == RelationshipType.OneToOne)
            {
              var dbActualTarget = (DataObject)session.Get(actualTarget.GetType().FullName, actualTarget.Id);
              dbActualTarget.SetValue(null, relationshipEntity.TargetPropertyNameForSource);
              session.SaveOrUpdate(dbActualTarget);
              session.Flush();
            }

            continue;
          }

          if (RepositoryAccess.Instance.IsEntityInOracle(actualSource.GetType().FullName) && Transaction.Current != null)
          {
            IList relationshipInstances =
              session.CreateCriteria(relationshipEntity.FullName)
                .Add(Expression.Eq(actualSource.GetType().Name + ".Id", actualSource.Id))
                .Add(Expression.Eq(actualTarget.GetType().Name + ".Id", actualTarget.Id))
                .List();

            if (relationshipInstances.Count > 0)
            {
              logger.Debug(String.Format("Deleting relationship between '{0}' and '{1}'", actualSource, actualTarget));
              session.Delete(relationshipInstances[0]);
            }
            else
            {
              logger.Debug(String.Format("No relationship exists between '{0}' and '{1}'", actualSource, actualTarget));
            }

            session.Flush();
            
          }
          else
          {
            IList relationshipInstances =
              session.CreateCriteria(relationshipEntity.FullName)
                .Add(Expression.Eq(actualSource.GetType().Name + ".Id", actualSource.Id))
                .Add(Expression.Eq(actualTarget.GetType().Name + ".Id", actualTarget.Id))
                .List();

            if (relationshipInstances.Count > 0)
            {
              logger.Debug(String.Format("Deleting relationship between '{0}' and '{1}'", actualSource, actualTarget));
              session.Delete(relationshipInstances[0]);
            }
            else
            {
              logger.Debug(String.Format("No relationship exists between '{0}' and '{1}'", actualSource, actualTarget));
            }

            session.Flush();
          }
        }

        tx.Commit();
      }
    }

    /// <summary>
    ///   If there is no direct relationship defined between source type and target type, return error.
    ///   Delete all relationships between sourceEntityName and targetEntityName
    /// </summary>
    /// <param name="sourceEntityName"></param>
    /// <param name="targetEntityName"></param>
    public void DeleteAllRelationships(string sourceEntityName, string targetEntityName)
    {
      Check.Require(!String.IsNullOrEmpty(sourceEntityName), "sourceEntityName cannot be null or empty");
      Check.Require(!String.IsNullOrEmpty(targetEntityName), "targetEntityName cannot be null or empty");
     
      RelationshipEntity relationshipEntity =
        MetadataRepository.Instance.GetRelationshipEntity(sourceEntityName, targetEntityName);

      Check.Require(relationshipEntity != null,
                    String.Format("Failed to find relationship between '{0}' and '{1}'",
                                  sourceEntityName, targetEntityName));

      if (RepositoryAccess.Instance.IsEntityInOracle(sourceEntityName) && Transaction.Current != null)
      {
        using (var session = RepositoryAccess.Instance.GetSession(sourceEntityName))
        {
          logger.Debug(String.Format("Deleting all relationships between '{0}' and '{1}'", sourceEntityName, targetEntityName));
          string hql = "delete from " + relationshipEntity.FullName;
          session.CreateQuery(hql).ExecuteUpdate();
        }
      }
      else
      {
        using (var session = RepositoryAccess.Instance.GetSession(sourceEntityName))
        using (var tx = session.BeginTransaction())
        {
          logger.Debug(String.Format("Deleting all relationships between '{0}' and '{1}'", sourceEntityName, targetEntityName));
          string hql = "delete from " + relationshipEntity.FullName;
          session.CreateQuery(hql).ExecuteUpdate();
          tx.Commit();
        }
      }
    }

    /// <summary>
    ///   Delete the specified instance
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="instance"></param>
    public virtual void Delete<T>(T instance) where T : DataObject
    {
      Check.Require(instance != null, "instance cannot be null");
      DeleteInternal(typeof(T).FullName, instance.Id);
    }

    public virtual void Delete<T>(Guid id) where T : DataObject
    {
      DeleteInternal(typeof(T).FullName, id);
    }

    /// <summary>
    ///   Delete all items of the specifed entityName
    /// </summary>
    /// <param name="entityName"></param>
    // [Obsolete("Only valid for product version 6.2 and earlier")]
    public virtual void Delete(string entityName)
    {
      Check.Require(Name.IsValidEntityTypeName(entityName), "entityName is not valid", SystemConfig.CallerInfo);

      try
      {
        logger.Debug(String.Format("Deleting all entities of type '{0}'", entityName));

        List<RelationshipEntity> relationshipEntities =
          MetadataRepository.Instance.GetRelationshipEntities(entityName);

        if (RepositoryAccess.Instance.IsEntityInOracle(entityName) && Transaction.Current != null)
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName))
          {
            // Delete the relationship instances
            foreach (RelationshipEntity relationshipEntity in relationshipEntities)
            {
              if (relationshipEntity.HasJoinTable)
              {
                session.CreateQuery("delete from " + relationshipEntity.FullName).ExecuteUpdate();
              }
            }

            // Using HQL which looks like: "delete from Order"
            string hql = "delete from " + entityName;
            session.CreateQuery(hql).ExecuteUpdate();
            
          }
        }
        else
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName))
          using (var tx = session.BeginTransaction())
          {
            // Delete the relationship instances
            foreach (RelationshipEntity relationshipEntity in relationshipEntities)
            {
              if (relationshipEntity.HasJoinTable)
              {
                session.CreateQuery("delete from " + relationshipEntity.FullName).ExecuteUpdate();
              }
            }

            // Using HQL which looks like: "delete from Order"
            string hql = "delete from " + entityName;
            session.CreateQuery(hql).ExecuteUpdate();

            tx.Commit();
          }
        }
      }
      catch (System.Exception e)
      {
        string message = String.Format("Failed to delete all entities of type '{0}'", entityName);
        throw new DataAccessException(message, e, SystemConfig.CallerInfo);
      }
    }

    /// <summary>
    ///   Delete the item of the specified type with the specified id.
    ///   Given:
    ///      A ---< B ---< C
    ///         A-B   B-C
    ///   
    ///   DFS on graph starting with A will always start with A's out edges. 
    ///   Each edge represents a relationship table (eg. A-B)
    ///   
    ///   (1) Get B id's for A. Store. [relationship A-B  --  List<Guid> for B]
    ///   (2) Delete A-B for B id's (List<Guid> for B)
    ///   (3) Get C id's for B id's. Expect to find B id's in Store as [A-B List<Guid> for B]
    ///       Store. [relationship B-C -- List<Guid> for C]
    ///   (4) Delete B-C for C id's (List<Guid> for C)
    /// 
    ///   (5) Foreach stored [relationship(from - to) -- List<Guid>]
    ///       Delete items from 'to' for List<Guid>
    /// 
    ///   (6) Finally, delete A
    ///   
    /// </summary>
    /// <param name="entityName"></param>
    /// <param name="id"></param>
    [Obsolete("Only valid for product version 6.2 and earlier")]
    public virtual void Delete(string entityName, Guid id)
    {
      Check.Require(Name.IsValidEntityTypeName(entityName), "entityName is not valid", SystemConfig.CallerInfo);
      Check.Require(id != Guid.Empty, "id cannot be empty", SystemConfig.CallerInfo);

      try
      {
        logger.Debug(String.Format("Deleting entity of type '{0}' with id '{1}'", entityName, id));

        using (var session = RepositoryAccess.Instance.GetSession(entityName, FlushMode.Never))
        using (var tx = session.BeginTransaction())
        {
          var dataObject = session.Get(entityName, id) as DataObject;
          if (dataObject == null)
          {
            throw new DeleteDataException
              (String.Format("Cannot delete entity '{0}' with id '{1}' because it was not found", entityName, id));
          }

          // Chain of cascade relationships
          List<RelationshipEntity> cascadeRelationships =
            MetadataRepository.Instance.GetCascadeRelationships(entityName);

          cascadeRelationships.RemoveAll(r => !r.HasJoinTable);

          // Direct relationships (may or may not be cascade)
          List<RelationshipEntity> incidentRelationships =
            MetadataRepository.Instance.GetRelationshipEntities(entityName);

          incidentRelationships.RemoveAll(r => !r.HasJoinTable);

          // Remove incidents that are a part of the cascade chain. Cascade's are handled separately
          incidentRelationships.RemoveAll(cascadeRelationships.Contains);

          // Delete items from the incident tables
          foreach (RelationshipEntity relationshipEntity in incidentRelationships)
          {
            if (!relationshipEntity.HasJoinTable) continue;

            string columnName =
              relationshipEntity.SourceEntityName == entityName ?
              relationshipEntity.SourceKeyColumnName :
              relationshipEntity.TargetKeyColumnName;


            session.CreateSQLQuery("delete from " +
                                   relationshipEntity.TableName +
                                   " where " +
                                   columnName + " = '" + id + "'").ExecuteUpdate();
          }

          var deleteIdentifiers = new Dictionary<RelationshipEntity, IList<Guid>>();

          foreach (RelationshipEntity relationshipEntity in cascadeRelationships)
          {
            if (!relationshipEntity.HasJoinTable) continue;

            // Select the target id's
            // Create the predicate
            string predicate = null;
            if (relationshipEntity.SourceEntityName == entityName)
            {
              predicate = "where " + relationshipEntity.SourceKeyColumnName + " = '" + id + "'";
            }
            else
            {
              // Get the relationship edge where the target entity name matches SourceEntityName
              RelationshipEntity deleteRelationshipEntity = null;
              foreach (RelationshipEntity edge in deleteIdentifiers.Keys)
              {
                if (edge.TargetEntityName == relationshipEntity.SourceEntityName)
                {
                  deleteRelationshipEntity = edge;
                  break;
                }

              }

              if (deleteRelationshipEntity == null)
              {
                continue;
              }

              IList<Guid> identifiers = deleteIdentifiers[deleteRelationshipEntity];
              Check.Require(identifiers != null, "identifiers cannot be null", SystemConfig.CallerInfo);

              predicate = "where " +
                           relationshipEntity.SourceKeyColumnName +
                           " in (" +
                           String.Join(",", (from g in identifiers select "'" + g + "'").ToArray()) +
                           ")";
            }

            string query = "select * from " +
                           Entity.GetTableName(relationshipEntity.FullName) + " " +
                           predicate;

            IList results =
              session.CreateSQLQuery(query)
              .AddScalar(relationshipEntity.TargetKeyColumnName, NHibernateUtil.Guid)
              .List();

            if (results.Count > 0)
            {
              IList<Guid> identifiers = ListToGenericListConverter<Guid>.ConvertToGenericList(results);
              deleteIdentifiers.Add(relationshipEntity, identifiers);

              // Delete the join table data
              query = "delete from " +
                      Entity.GetTableName(relationshipEntity.FullName) +
                      " where " +
                      relationshipEntity.TargetKeyColumnName +
                      " in (" +
                      String.Join(",", (from g in identifiers select "'" + g + "'").ToArray()) +
                      ")";

              session.CreateSQLQuery(query).ExecuteUpdate();
            }
          }

          foreach (RelationshipEntity deleteRelationshipEntity in deleteIdentifiers.Keys)
          {
            // Delete related entity data
            IList<Guid> identifiers = deleteIdentifiers[deleteRelationshipEntity];
            var query = "delete from " +
                        Entity.GetTableName(deleteRelationshipEntity.TargetEntityName) +
                        " where " +
                        deleteRelationshipEntity.TargetKeyColumnName +
                        " in (" +
                        String.Join(",", (from g in identifiers select "'" + g + "'").ToArray()) +
                        ")";

            session.CreateSQLQuery(query).ExecuteUpdate();
          }

          // Delete the original data
          session.Delete(dataObject);
          session.Flush();
          tx.Commit();
        }
      }
      catch (DeleteDataException)
      {
        throw;
      }
      catch (System.Exception e)
      {
        string message = String.Format("Failed to delete entity of type '{0}' with id '{1}'", entityName, id);
        throw new DeleteDataException(message, e);
      }
    }
    #endregion

    #endregion

    #endregion

    #region Methods for entities in Core.Common

    /// <summary>
    ///   localeKeys = concatenation of nm_enum_data from id_enum_data, separated by 'separator'
    /// </summary>
    /// <param name="localeKeys"></param>
    /// <param name="separator"></param>
    /// <returns></returns>
    public virtual List<LocalizedEntry> GetLocalizedEntries(string localeKeys, string separator)
    {
      List<LocalizedEntry> localizedEntries = null;

      try
      {
        logger.Debug(String.Format("Getting localized entries for keys '{0}'", localeKeys));

        using (var session = RepositoryAccess.Instance.GetNetMeterSession(FlushMode.Never))
        using (var tx = session.BeginTransaction())
        {
          string queryName = NHibernateConfig.IsOracle("NetMeter") ? LocalizedEntry.OracleQuery : LocalizedEntry.SqlQuery;
          IList results = session.GetNamedQuery(queryName)
                                 .SetString(LocalizedEntry.LocaleKeysParameter, localeKeys)
                                 .SetString(LocalizedEntry.SeparatorParameter, separator)
                                 .SetResultTransformer(Transformers.AliasToBean(typeof(LocalizedEntry)))
                                 .List();
          localizedEntries = ListToGenericListConverter<LocalizedEntry>.ConvertToGenericList(results);
          tx.Commit();
        }
      }
      catch (System.Exception e)
      {
        string message = String.Format("Failed to get localized entries with key '{0}'", localeKeys);
        throw new DataAccessException(message, e, SystemConfig.CallerInfo);
      }

      return localizedEntries;
    }

    public virtual bool TableHasRows(string databaseName, string tableName)
    {
      Check.Require(!String.IsNullOrEmpty(databaseName), "databaseName cannot be null or empty");
      Check.Require(!String.IsNullOrEmpty(tableName), "tableName cannot be null or empty");

      bool hasRows = false;

      try
      {
        logger.Debug(String.Format("Checking if table '{0}' has any rows", tableName));

        using (var session = RepositoryAccess.Instance.GetNetMeterSession(FlushMode.Never))
        using (var tx = session.BeginTransaction())
        {
          if (NHibernateConfig.IsOracle(databaseName))
          {
            IList results = session.GetNamedQuery("TableHasRowsOracle")
                            .SetString("tableName", tableName)
                            .List();

            hasRows = (int)results[0] == 0 ? false : true;
          }
          else
          {
            var rowCountSql =
              "\n " +
              " if exists (select * from dbo.sysobjects where id = object_id(N'" + tableName + "')" +
              " and OBJECTPROPERTY(id, N'IsUserTable') = 1) \n" +
              "   select count(*) from " + tableName + "\n" +
              " else \n" +
              "   select 0";

            IQuery query = session.CreateSQLQuery(rowCountSql);
            int rowCount = (int)query.UniqueResult();
            hasRows = rowCount == 0 ? false : true;
          }

          tx.Commit();
        }
      }
      catch (System.Exception e)
      {
        string message = String.Format("Failed to check if table '{0}' has rows", tableName);
        throw new DataAccessException(message, e, SystemConfig.CallerInfo);
      }

      return hasRows;
    }

    public virtual List<EntitySyncData> LoadEntitySyncData()
    {
      List<EntitySyncData> entitySyncDataList = null;

      try
      {
        logger.Debug(String.Format("Loading EntitySyncData"));

        using (var session = RepositoryAccess.Instance.GetNetMeterSession(FlushMode.Never))
        using (var tx = session.BeginTransaction())
        {
          entitySyncDataList =
           (List<EntitySyncData>)session.CreateCriteria(typeof(EntitySyncData)).List<EntitySyncData>();

          tx.Commit();
        }
      }
      catch (System.Exception e)
      {
        string message = String.Format("Failed to load EntitySyncData");
        throw new DataAccessException(message, e, SystemConfig.CallerInfo);
      }

      return entitySyncDataList;
    }

    public virtual void SaveEntitySyncData(EntitySyncData entitySyncData)
    {
      Check.Require(entitySyncData != null, "entitySyncData cannot be null");

      try
      {
        logger.Debug(String.Format("Saving EntitySyncData '{0}'", entitySyncData));

        using (var session = RepositoryAccess.Instance.GetNetMeterSession())
        using (var tx = session.BeginTransaction())
        {
          session.SaveOrUpdate(entitySyncData);
          tx.Commit();
        }
      }
      catch (System.Exception e)
      {
        string message = String.Format("Failed to save EntitySyncData '{0}'", entitySyncData);
        throw new DataAccessException(message, e, SystemConfig.CallerInfo);
      }
    }

    public virtual List<string> GetTableNames(string databaseName)
    {
      List<string> tableNames = null;

      try
      {
        logger.Debug("Getting table names");

        using (var session = RepositoryAccess.Instance.GetSessionForDb(databaseName, FlushMode.Never))
        using (var tx = session.BeginTransaction())
        {
          string queryName = NHibernateConfig.IsOracle("NetMeter") ? "GetTableNamesForOracle" : "GetTableNamesForSql";
          IList results = session.GetNamedQuery(queryName).List();
          tableNames = ListToGenericListConverter<string>.ConvertToGenericList(results);
          tx.Commit();
        }
      }
      catch (System.Exception e)
      {
        string message = "Failed to get tables names";
        throw new DataAccessException(message, e);
      }

      return tableNames;
    }

    public virtual List<DbColumnMetadata> GetColumnMetadata(string databaseName, List<string> tableNames)
    {
      Check.Require(!String.IsNullOrEmpty(databaseName), "databaseName cannot be null or empty");
      Check.Require(tableNames != null && tableNames.Count > 0, "tableNames cannot be null or empty");
      List<DbColumnMetadata> columnMetadataList = null;

      string separator = ",";
      string tableNamesParamValue = String.Join(separator, tableNames.ToArray());

      try
      {
        logger.Debug(String.Format("Getting column metadata for tables '{0}'", tableNamesParamValue));

        using (var session = RepositoryAccess.Instance.GetSessionForDb(databaseName, FlushMode.Never))
        using (var tx = session.BeginTransaction())
        {
          string queryName = NHibernateConfig.IsOracle(databaseName) ? DbColumnMetadata.OracleQuery : DbColumnMetadata.SqlQuery;
          IList results = session.GetNamedQuery(queryName)
                                 .SetString(DbColumnMetadata.TableNamesParameter, tableNamesParamValue)
                                 .SetString(DbColumnMetadata.SeparatorParameter, separator)
                                 .SetResultTransformer(Transformers.AliasToBean(typeof(DbColumnMetadata)))
                                 .List();

          columnMetadataList = 
            ListToGenericListConverter<DbColumnMetadata>.ConvertToGenericList(results).Distinct().ToList();

          columnMetadataList.AsParallel().ForEach(c => c.InitPropertyName());
          tx.Commit();
        }
      }
      catch (System.Exception e)
      {
        string message = String.Format("Failed to load column metadata for tables '{0}'", tableNamesParamValue);
        throw new DataAccessException(message, e);
      }

      return columnMetadataList;
    }
    /// <summary>
    ///    Return IEnumType given the assembly qualified name of the C# enum.
    /// </summary>
    /// <param name="assemblyQualifiedName"></param>
    /// <returns></returns>
    // public virtual IEnumType GetEnumType(QualifiedName assemblyQualifiedName)
    // {
    //Check.Require(assemblyQualifiedName != null, "Argument 'assemblyQualifiedName' cannot be null", SystemConfig.CallerInfo);

    //string enumSpace;
    //string enumName;

    //EnumUtil.GetEnumSpaceAndName(assemblyQualifiedName.NamespaceQualifiedTypeName, out enumSpace, out enumName);

    //IList enumEntries =
    //  Session.CreateCriteria(typeof(EnumEntry))
    //    .Add(SqlExpression.Like<EnumEntry>(p => p.DbEnumEntry, String.Format("%{0}/{1}%", enumSpace, enumName)))
    //    .List();

    //EnumType enumType =
    //    new EnumType()
    //      {
    //        Name = assemblyQualifiedName.TypeName,
    //        Namespace = assemblyQualifiedName.Namespace,
    //        Entries = ListToGenericListConverter<IEnumEntry>.ConvertToGenericList(enumEntries)
    //      };

    //return enumType;
    // }


    #endregion

    #region Misc

    #endregion

    #region Private Property

    #endregion

    #region Private Methods
    private StandardRepository()
    {
    }

    public DataObject ConvertEntityInstanceToDataObject(EntityInstance entityInstance,
                                                        Dictionary<string, object> currentObjects = null)
    {
      return entityInstance.CreateDataObject();
    }

    public EntityInstance ConvertDataObjectToEntityInstance(DataObject dataObject,
                                                            bool addMetadata,
                                                            Dictionary<Guid, EntityInstance> currentEntityInstances = null)
    {
      Check.Require(dataObject != null, "dataObject cannot be null", SystemConfig.CallerInfo);

      Entity entity = MetadataRepository.Instance.GetEntity(dataObject.GetType().FullName);
      Check.Require(entity != null, 
                    String.Format("Cannot find entity '{0}' in metadata repository", 
                                  dataObject.GetType().FullName));

      EntityInstance entityInstance = entity.GetEntityInstance();
      entityInstance.Id = dataObject.Id;

      foreach(PropertyInstance propertyInstance in entityInstance.Properties)
      {
        if (propertyInstance.IsBusinessKey)
        {
          propertyInstance.Value = dataObject.GetBusinessKeyPropertyValue(propertyInstance.Name);
        }
        else
        {
          propertyInstance.Value = dataObject.GetValue(propertyInstance.Name);
        }
      }

      entityInstance.ForeignKeyProperties.AddRange(dataObject.GetForeignKeyData());

      return entityInstance;

      
      #region Obsolete Code
      //IClassMetadata classMetadata = SessionFactory.GetClassMetadata(dataObject.GetType().FullName);
      //Check.Assert(classMetadata != null,
      //             String.Format("Cannot find session factory metadata for type '{0}'",
      //                           dataObject.GetType().FullName),
      //             SystemConfig.CallerInfo);

      //PersistentClass persistentClass = Configuration.GetClassMapping(dataObject.GetType().FullName);
      //Check.Assert(persistentClass != null,
      //             String.Format("Cannot find peristent class in session factory for type '{0}'",
      //                           dataObject.GetType().FullName),
      //             SystemConfig.CallerInfo);

      //IType[] propertyTypes = classMetadata.PropertyTypes;
      //string[] propertyNames = classMetadata.PropertyNames;

      //entityInstance.Id = (Guid)classMetadata.GetIdentifier(dataObject, EntityMode.Poco);
      //string extensionName, entityGroupName, entityClassName;
      //Name.GetExtensionAndEntityGroupAndClass(dataObject.GetType().FullName,
      //                                        out extensionName,
      //                                        out entityGroupName,
      //                                        out entityClassName);

      //entityInstance.ExtensionName = extensionName;
      //entityInstance.EntityGroupName = entityGroupName;
      //entityInstance.EntityFullName = dataObject.GetType().FullName;
      //entityInstance.EntityName = entityClassName;
      //entityInstance.AssemblyQualifiedTypeName = dataObject.GetType().AssemblyQualifiedName;

      //currentEntityInstances.Add(entityInstance.Id, entityInstance);

      //for (int i = 0; i < propertyNames.Length; i++)
      //{
      //  string propertyName = propertyNames[i];
      //  IType propertyType = propertyTypes[i];

      //  // Handle BusinessKey component
      //  if (propertyType.IsComponentType)
      //  {
      //    NHibernate.Mapping.Property property = persistentClass.GetProperty(propertyName);
      //    Check.Require(property != null, "property cannot be null", SystemConfig.CallerInfo);
      //    NHibernate.Mapping.MetaAttribute metaAttribute = property.GetMetaAttribute(Metadata.Property.BusinessKeyAttribute);
      //    if (metaAttribute != null && metaAttribute.Value == "true")
      //    {
      //      object businessKey = classMetadata.GetPropertyValue(dataObject, propertyName, EntityMode.Poco);
      //      Check.Require(businessKey != null, String.Format("Cannot find business key for DataObject '{0}'", dataObject.GetType().FullName));
      //      PropertyInfo[] propertyInfos = businessKey.GetType().GetProperties();

      //      foreach (PropertyInfo propertyInfo in propertyInfos)
      //      {
      //        var propertyInstance =
      //          new PropertyInstance(propertyInfo.Name, propertyInfo.PropertyType.AssemblyQualifiedName, true);
      //        propertyInstance.Name = propertyInfo.Name;
      //        propertyInstance.Value = propertyInfo.GetValue(businessKey, null);

      //        entityInstance.Properties.Add(propertyInstance);
      //      }
      //    }
      //  }
      //  else if (propertyType.IsAnyType == false &&
      //           propertyType.IsAssociationType == false &&
      //           propertyType.IsCollectionType == false &&
      //           propertyType.IsEntityType == false)
      //  {
      //    var propertyInstance = 
      //      new PropertyInstance(propertyName, 
      //                           propertyType.ReturnedClass.FullName + ", " + propertyType.ReturnedClass.Assembly.GetName().Name,
      //                           false);

      //    propertyInstance.Value =
      //      classMetadata.GetPropertyValue(dataObject, propertyName, EntityMode.Poco);

      //    entityInstance.Properties.Add(propertyInstance);
      //  }
      //  else if (propertyType.IsAssociationType && !propertyType.IsCollectionType)
      //  {
      //    // Handle relationships when EntityUnit is defined
      //    continue;

      //    #region Need requirements
      //    //DataObject associatedObject = classMetadata.GetPropertyValue(dataObject, propertyName, EntityMode.Poco) as DataObject;
      //    //// NHibernateUtil.IsInitialized filters out proxies
      //    //if (associatedObject == null || !NHibernateUtil.IsInitialized(associatedObject))
      //    //{
      //    //  continue;
      //    //}

      //    //Guid associatedObjectId = (Guid)classMetadata.GetIdentifier(associatedObject, EntityMode.Poco);
      //    //EntityInstance associationInstance;
      //    //currentEntityInstances.TryGetValue(associatedObjectId, out associationInstance);

      //    //if (associationInstance == null)
      //    //{
      //    //  associationInstance =
      //    //    ConvertDataObjectToEntityInstance(associatedObject, addMetadata, currentEntityInstances);

      //    //  Check.Assert(associationInstance != null,
      //    //               String.Format("associationInstance cannot be null for type '{0}'",
      //    //                             associatedObject.GetType().FullName),
      //    //               SystemConfig.CallerInfo);
      //    //}

      //    //Association association = new Association();
      //    //association.PropertyName = propertyName;
      //    //association.EntityInstance = associationInstance;
      //    //entityInstance.Associations.Add(association);
      //    #endregion
      //  }
      //  else if (propertyType.IsAssociationType && propertyType.IsCollectionType)
      //  {
      //    // Handle relationships when EntityUnit is defined
      //    continue;

      //    #region Need requirements
      //    //object associatedObjectCollection =
      //    //  classMetadata.GetPropertyValue(dataObject, propertyName, EntityMode.Poco);
      //    //if (associatedObjectCollection == null)
      //    //{
      //    //  continue;
      //    //}

      //    //IList list = associatedObjectCollection as IList;
      //    //Check.Assert(list != null,
      //    //             String.Format("Cannot convert property '{0}' of type '{1}' to IList",
      //    //             propertyName, dataObject.GetType().FullName),
      //    //             SystemConfig.CallerInfo);

      //    //foreach (DataObject item in list)
      //    //{
      //    //  CollectionAssociation collectionAssociation = new CollectionAssociation();
      //    //  collectionAssociation.PropertyName = propertyName;
      //    //  EntityInstance instance = ConvertDataObjectToEntityInstance(item, addMetadata, currentEntityInstances);
      //    //  Check.Assert(instance != null, "Cannot convert item to entity instance", SystemConfig.CallerInfo);
      //    //  collectionAssociation.EntityInstances.Add(instance);
      //    //  if (collectionAssociation.EntityTypeName == null)
      //    //  {
      //    //    collectionAssociation.EntityTypeName = item.GetType().FullName;
      //    //  }

      //    //  entityInstance.CollectionAssociations.Add(collectionAssociation);
      //    //}
      //    #endregion
      //  }

      //}
      

      //Check.Ensure(entityInstance.Id != null && entityInstance.Id != Guid.Empty,
      //             String.Format("Cannot find id for entity instance of type '{0}'", dataObject.GetType().FullName));

      //return entityInstance;
      #endregion
    }

    private AbstractCriterion GetCriterion(MTFilterElement mtFilterElement, 
                                           string entityName,
                                           Dictionary<string, PropertyInstance> businessKeyPropertyMap,
                                           string alias)
    {
      Check.Require(mtFilterElement != null, "mtFilterElement cannot be null", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(mtFilterElement.PropertyName),
                      "Filter element cannot have a null or empty PropertyName",
                      SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);

      object filterValue = mtFilterElement.Value;
      AbstractCriterion criterion = null;

      Entity entity = MetadataRepository.Instance.GetEntity(entityName);
      Check.Require(entity != null, String.Format("Cannot find entity '{0}'", entityName));

      string propertyName = mtFilterElement.PropertyName;

      string columnName = null;
      
      Property property = null;
      if (propertyName == "InternalKey")
      {
        property = new Property(entity, "Dummy", "Guid");
        property.Name = "InternalKey";
        property.ColumnName = "c_internal_key";
      }
      else if (propertyName.ToLower() == "id")
      {
        property = new Property(entity, "Dummy", "Guid");
        property.Name = "Id";
        property.ColumnName = entity.GetIdColumnName();
      }
      else
      {
        property = entity.Properties.Find(p => p.Name == propertyName);
        Check.Require(property != null, String.Format("Cannot find metadata for property '{0}' in type '{1}'", mtFilterElement.PropertyName, entityName));
      }

      // If the filterElement is a business key, modify the property name
      PropertyInstance propertyInstance;
      businessKeyPropertyMap.TryGetValue(propertyName, out propertyInstance);

      if (propertyInstance != null)
      {
        propertyName = entity.ClassName + "BusinessKey." + propertyName;
      }

      if (property.IsEnum)
      {
        filterValue = GetDbEnumValue(mtFilterElement, property);
        columnName = property.ColumnName;
      }
      else if (property.PropertyType == PropertyType.Boolean)
      {
        if (filterValue.ToString() == "1")
          filterValue = "true";
        else if (filterValue.ToString() == "0")
          filterValue = "false";

        Check.Require
          (filterValue.ToString().ToLower() == "false" || filterValue.ToString().ToLower() == "true",
           String.Format("Incorrect filter value '{0}' specified for boolean property '{1}' " + 
                         "on entity '{2}'. Must be 'true' or 'false'",
                         filterValue, propertyName, entityName));

        filterValue = Convert.ToBoolean(filterValue);
      }
      else if (property.PropertyType == PropertyType.DateTime)
      {
        filterValue = Convert.ToDateTime(filterValue);
      }
      else if (property.PropertyType == PropertyType.Decimal)
      {
        filterValue = Convert.ToDecimal(filterValue);
      }
      else if (property.PropertyType == PropertyType.Double)
      {
        filterValue = Convert.ToDouble(filterValue);
      }
      else if (property.PropertyType == PropertyType.Guid)
      {

        // Bug: CORE-3015 - Hack until UI handles Guid data types
        if (filterValue.ToString().EndsWith("%"))
        {
          filterValue = filterValue.ToString().Remove(filterValue.ToString().Length - 1);
        }

        filterValue = new Guid(filterValue.ToString());
        mtFilterElement = new MTFilterElement(property.Name, MTFilterElement.OperationType.Equal, filterValue);
      }
      else if (property.PropertyType == PropertyType.Int32)
      {
        filterValue = Convert.ToInt32(filterValue);
      }
      else if (property.PropertyType == PropertyType.Int64)
      {
        filterValue = Convert.ToInt64(filterValue);
      }
      string op = null;

      switch (mtFilterElement.Operation)
      {
        case MTFilterElement.OperationType.Equal:
          {
            op = " = ";
            criterion = string.IsNullOrEmpty(filterValue.ToString())
                          ? Expression.Or(Expression.Eq(alias + propertyName, filterValue),
                                          Expression.IsNull(alias + propertyName))
                          : Expression.Eq(alias + propertyName, filterValue);
            break;
          }
        case MTFilterElement.OperationType.NotEqual:
          {
            op = " != ";
            criterion = string.IsNullOrEmpty(filterValue.ToString())
                          ? Expression.Or(Expression.Not(Expression.Eq(alias + propertyName, filterValue)),
                                          Expression.IsNotNull(alias + propertyName))
                          : Expression.Not(Expression.Eq(alias + propertyName, filterValue));
            break;
          }
        case MTFilterElement.OperationType.Greater:
          {
            op = " > ";
            Check.Require(property.PropertyType != PropertyType.Boolean,
                          String.Format("Cannot specify comparator '{0}' for boolean property '{1}' on entity '{2}'",
                                        MTFilterElement.OperationType.Greater, propertyName, entityName));

            criterion = Expression.Gt(alias + propertyName, filterValue);
            break;
          }
        case MTFilterElement.OperationType.GreaterEqual:
          {
            op = " >= ";
            Check.Require(property.PropertyType != PropertyType.Boolean,
                          String.Format("Cannot specify comparator '{0}' for boolean property '{1}' on entity '{2}'",
                                        MTFilterElement.OperationType.GreaterEqual, propertyName, entityName));

            criterion = Expression.Ge(alias + propertyName, filterValue);
            break;
          }
        case MTFilterElement.OperationType.Less:
          {
            op = " < ";
            Check.Require(property.PropertyType != PropertyType.Boolean,
                          String.Format("Cannot specify comparator '{0}' for boolean property '{1}' on entity '{2}'",
                                        MTFilterElement.OperationType.Less, propertyName, entityName));

            criterion = Expression.Lt(alias + propertyName, filterValue);
            break;
          }
        case MTFilterElement.OperationType.LessEqual:
          {
            op = " <= ";
            Check.Require(property.PropertyType != PropertyType.Boolean,
                          String.Format("Cannot specify comparator '{0}' for boolean property '{1}' on entity '{2}'",
                                        MTFilterElement.OperationType.LessEqual, propertyName, entityName));


            criterion = Expression.Le(alias + propertyName, filterValue);
            break;
          }
        case MTFilterElement.OperationType.Like_W:
        case MTFilterElement.OperationType.Like:
          {
            Check.Require(property.PropertyType != PropertyType.Boolean,
                          String.Format("Cannot specify comparator '{0}' for boolean property '{1}' on entity '{2}'",
                                        MTFilterElement.OperationType.Like, propertyName, entityName));

            bool error = false;
            string propertyTypeName = String.Empty;

            // Check that the property type is string
            if (propertyInstance != null)
            {
              if (propertyInstance.Type != typeof(String))
              {
                error = true;
                propertyTypeName = propertyInstance.TypeName;
              }
            }
            else 
            {
              if (property.PropertyType != PropertyType.String)
              {
                error = true;
                propertyTypeName = propertyInstance.TypeName;
              }
            }

            if (error)
            {
              string message =
                String.Format(
                  "Cannot use Like filter on property '{0}' for entity '{1}' because it is not a String. The property type is '{2}'.",
                  mtFilterElement.PropertyName, entityName, propertyTypeName);
              throw new DataAccessException(message, SystemConfig.CallerInfo);
            }

            criterion = Expression.Like(alias + propertyName, filterValue);

            break;
          }
        default:
          {
            break;
          }
      }

      Check.Ensure(criterion != null,
                   String.Format("Cannot create query expression for property '{0}' on type '{1}'",
                                 propertyName, entityName),
                   SystemConfig.CallerInfo);

      // Use EnumFilterCriteria for non compound enums
      if (property.IsEnum && !property.IsCompound)
      {
        // Cannot use a SimpleExpression for enums - because NHibernate throws a type mismatch
        // exception when an int (id_enum_data) is specified instead of the enum instance.
        criterion = new EnumFilterCriteria(propertyName, filterValue, op, columnName, alias);
      }
      else if (property.PropertyType == PropertyType.Guid && 
               RepositoryAccess.Instance.IsEntityInOracle(entityName))
      {
        // Oracle stores Guids differently from SQL Server. The Oracle storage maps 
        // to the Byte array of the Guid. The OracleGuidCriteria class allows us to specify
        // the Guid filter criteria as a string by converting the Guid to the byte array representation.
        // Example: The Guid '32929302-2cc9-40a6-ac5a-f620d0fc17db' is stored in Oracle as
        //                   '02939232C92CA640AC5AF620D0FC17DB' 
        // 
        criterion = new OracleGuidCriteria(alias + propertyName, filterValue, op, property.ColumnName);
      }

      return criterion;
    }

    /// <summary>
    ///    Return the database enum value for the specified filterElement and the specified property.
    ///    Pre-req: property represents an Enum data type (property.IsEnum == true)
    ///             filterElement.Value can only be one of the following three types:
    ///               - Enum 
    ///               - string 
    ///               - int
    ///                   
    ///    If filterElement.Value is an Enum
    ///      - return the db enum value for the corresponding enum instance
    ///    
    ///    If filterElement.Value is a string
    ///      - see if the string is a valid enum e.g. the <value> element below could be a string
    ///      - otherwise, try to cast string to an int and follow logic for filterElement.Value == int
    ///      - otherwise, throw an exception
    /// 
    ///    If filterElement.Value is an int
    ///      - the int could be the C# enum 'value' as shown below or the db enum value
    ///        <enum name="PaymentMethod">
    ///          <description>Payment method</description>
    ///          <entries>
    ///            <entry name="CreditOrACH">
    ///              <value>1</value>
    ///            </entry>
    ///            <entry name="CashOrCheck">
    ///              <value>2</value>
    ///            </entry>
    ///          </entries>
    ///        </enum>
    ///      - if the int can be converted to the C# enum instance (via EnumHelper.GetGeneratedEnumByValue) 
    ///        then use the C# enum instance to get the db enum value
    ///      - otherwise, assume that int is the db enum value 
    ///
    /// 
    /// </summary>
    /// <param name="filterElement"></param>
    /// <param name="property"></param>
    /// <returns></returns>
    private int GetDbEnumValue(MTFilterElement filterElement, Property property)
    {
      Check.Require(filterElement != null, "filterElement cannot be null");
      Check.Require(filterElement.Value != null, "filterElement.Value cannot be null");
      Check.Require(property != null, "property cannot be null");
      Check.Require(property.IsEnum, String.Format("Property '{0}' must have en Enum datatype", property.FullName));
      Check.Require(filterElement.Value.GetType().IsEnum ||
                    filterElement.Value.GetType() == typeof(string) ||
                    filterElement.Value.GetType() == typeof(int),
                    String.Format("The filter value '{0}' for enum property '{1}' on entity '{2}' must be either an Enum or a string or an int",
                                   filterElement.Value, property.Name, property.Entity.FullName));

      if (filterElement.Value.GetType().IsEnum)
      {
        Check.Require(Enum.IsDefined(Type.GetType(property.AssemblyQualifiedTypeName), filterElement.Value),
                      String.Format("The filter value '{0}' for enum property '{1}' on entity '{2}' is not an instance of enum type '{3}'",
                                     filterElement.Value, property.Name, property.Entity.FullName, property.AssemblyQualifiedTypeName));
        return property.GetDbEnumValue((int)filterElement.Value);
      }

      int enumValue, dbEnumValue;
      Type enumType = Type.GetType(property.AssemblyQualifiedTypeName, true);

      if (filterElement.Value.GetType() == typeof(string))
      {
        if (!Int32.TryParse((string)filterElement.Value, out enumValue))
        {
          // It's not an int. Is it a string value for an enum?
          var enumInstance = EnumHelper.GetGeneratedEnumByValue(enumType, (string)filterElement.Value);
          if (enumInstance != null)
          {
            dbEnumValue = property.GetDbEnumValue((int)enumInstance);
            return dbEnumValue;
          }

          // Not an enum
          throw new DataAccessException(String.Format("The filter value '{0}' for enum type '{1}' and enum property '{2}' on entity '{3}' cannot be converted to a valid enum",
                                                      filterElement.Value, enumType.FullName, property.Name, property.Entity.FullName));
        }
      }
      else
      {
        enumValue = (int)filterElement.Value;
      }

      // Have the int. It could either be the value of the C# enum or the db enum value.
      // If it's a C# enum instance value, we must be able to convert it into the corresponding C# enum instance
      try
      {
        var enumInstance = EnumHelper.GetGeneratedEnumByValue(enumType, enumValue.ToString());
        dbEnumValue = property.GetDbEnumValue((int)enumInstance);
      }
      catch (System.Exception)
      {
        // Could not convert the filter value to an enum, must be the db enum value
        dbEnumValue = enumValue;
      }

      return dbEnumValue;
    }

    private void GetPageData(MTList<DataObject> mtList, out int firstPage, out int pageSize)
    {
      firstPage = 0;
      pageSize = 0;

      if (mtList.PageSize > 0)
      {
        pageSize = mtList.PageSize;
      }

      if (mtList.CurrentPage > 0 && pageSize > 0)
      {
        firstPage = (pageSize * (mtList.CurrentPage - 1)) + 1;
      }
    }

    private List<SortElement> GetSortData(MTList<DataObject> mtList)
    {
      List<SortElement> sortElements = new List<SortElement>();

      if (mtList.SortCriteria != null && mtList.SortCriteria.Count > 0)
      {
          foreach (SortCriteria sc in mtList.SortCriteria)
      {
              sortElements.Add(new SortElement { PropertyName = sc.SortProperty, SortType = sc.SortDirection });
          }
      }

      return sortElements;
    }

    private void ExecutePagingQuery(ISession session,
                                    DetachedCriteria pageCriteria,
                                    DetachedCriteria countCriteria,
                                    ref MTList<DataObject> mtList,
                                    bool isOracle)
    {
      mtList.Items.Clear();

      IList value;
      int rowCount;

      if (isOracle)
      {
        value = pageCriteria.GetExecutableCriteria(session).List();
        rowCount = (int)countCriteria.GetExecutableCriteria(session).List()[0];
      }
      else
      {
        IMultiCriteria multiCriteria = session.CreateMultiCriteria();
        multiCriteria.Add(pageCriteria);
        multiCriteria.Add(countCriteria);

        IList results = multiCriteria.List();
        Check.Ensure(results.Count == 2, "Expected two results from query", SystemConfig.CallerInfo);

        value = (IList)results[0];
        rowCount = (int)((IList)results[1])[0];
      }

      mtList.TotalRows = rowCount;

      foreach (DataObject dataObject in value)
      {
        dataObject.SetupRelationships();
        mtList.Items.Add(dataObject);
        if (session.Contains(dataObject))
        {
          session.Evict(dataObject);
        }
      }
    }

    // 
    private static Dictionary<string, PropertyInstance> GetBusinessKeyPropertyMap
      (string entityName, List<MTBaseFilterElement> mtFilters) 
    {
      var businessKeyPropertyMap = new Dictionary<string, PropertyInstance>();
      var businessKey = BusinessKey.GetBusinessKey(entityName);

      List<PropertyInstance> businessKeyProperties = businessKey.GetPropertyData();
      
      foreach(MTFilterElement mtFilterElement in mtFilters)
      {
        PropertyInstance propertyInstance =
          businessKeyProperties.FirstOrDefault(b => b.Name == mtFilterElement.PropertyName);

        if (propertyInstance != null)
        {
          businessKeyPropertyMap.Add(mtFilterElement.PropertyName, propertyInstance);
        }
      }

      return businessKeyPropertyMap;
    }

    private void GetQueryCriteria(ISession session,
                                   string entityName,
                                   MTList<DataObject> mtList,
                                   out DetachedCriteria pageCriteria,
                                   out DetachedCriteria countCriteria,
                                   string alias = null)
    {
      Check.Require(session != null, "session cannot be null", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be empty or null", SystemConfig.CallerInfo);
      Check.Require(mtList != null, "mtList cannot be null", SystemConfig.CallerInfo);

      pageCriteria = alias == null
                       ? DetachedCriteria.ForEntityName(entityName, "e")
                       : DetachedCriteria.ForEntityName(entityName, alias.Replace(".", ""));

      Dictionary<string, PropertyInstance>
        businessKeyPropertyMap = GetBusinessKeyPropertyMap(entityName, mtList.Filters);

      Entity entity = MetadataRepository.Instance.GetEntity(entityName);
      Check.Require(entity != null, String.Format("Cannot find entity '{0}' in metadata repository", entityName));

      // Criteria for specify properties on LegacyObject
      DetachedCriteria legacyCriteria = null;

      // If entity is Compound, then the filter/sort criteria may pertain to columns
      // in the legacy table
      if (entity.EntityType == EntityType.Compound)
      {
        #region Handle Compound Filters

        List<Property> legacyProperties = entity.Properties.FindAll(p => p.IsCompound);
        var legacyFilters = new List<MTFilterElement>();
        var entityFilters = new List<MTFilterElement>();

        foreach(MTFilterElement mtFilterElement in mtList.Filters)
        {
          if (legacyProperties.Exists(lp => lp.Name == mtFilterElement.PropertyName))
          {
            legacyFilters.Add(mtFilterElement);
          }
          else
          {
            entityFilters.Add(mtFilterElement);
          }
        }

        foreach (MTFilterElement entityFilter in entityFilters)
        {
          pageCriteria.Add(GetCriterion(entityFilter, entityName, businessKeyPropertyMap, alias));
        }

        if (legacyFilters.Count > 0)
        {
          // Example: 
          // session.CreateCriteria(typeof(EntitySyncData))
          //                        .CreateAlias("LegacyObject", "l")
          //                        .Add(Expression.Eq("l.IsEnabled", "T"))
          //                        .List();

          legacyCriteria = pageCriteria.CreateAlias("LegacyObject", "l");
          foreach (MTFilterElement legacyFilter in legacyFilters)
          {
            legacyCriteria.Add(GetCriterion(legacyFilter, entityName, businessKeyPropertyMap, "l."));
          }
        }
        #endregion
      }
      else
      {
        foreach (MTFilterElement mtFilterElement in mtList.Filters)
        {
          pageCriteria.Add(GetCriterion(mtFilterElement, entityName, businessKeyPropertyMap, alias));
        }
      }
     

      // Handle Paging
      int firstPage, pageSize;
      GetPageData(mtList, out firstPage, out pageSize);
      // Handle Paging
      if (firstPage > 0)
      {
        // Paging is 1 based. The first page will always be 1 and not 0.
        // NHibernate paging is 0 based.
        // Decrement page
        pageCriteria.SetFirstResult(firstPage - 1).SetMaxResults(pageSize);
      }

      // Handle Sorting
      List<SortElement> sortElements = GetSortData(mtList);
      foreach (SortElement sortElement in sortElements)
      {
        // Sort property must be sortable
        // Check.Require(entity.IsPropertySortable(sortElement.PropertyName),
        //              String.Format("Cannot sort on property '{0}' for type '{1}' because it is not marked as sortable",
        //                            sortElement.PropertyName,
        //                            entityName),
        //              SystemConfig.CallerInfo);

        if (entity.IsCompoundProperty(sortElement.PropertyName))
        {
          if (legacyCriteria == null)
          {
            legacyCriteria = pageCriteria.CreateAlias("LegacyObject", "l");
          }
 
          var order = new Order("l." + sortElement.PropertyName, sortElement.SortType == SortType.Ascending ? true : false);
          legacyCriteria.AddOrder(order);
        }
        else
        {
          // If the sortElement is a business key, modify the property name
          string propertyName = sortElement.PropertyName;

          if (entity.IsBusinessKeyProperty(propertyName))
          {
            propertyName = Name.GetEntityBusinessKeyClassName(entity.FullName) + "." + sortElement.PropertyName;
          }

          var order = new Order(propertyName, sortElement.SortType == SortType.Ascending ? true : false);
          pageCriteria.AddOrder(order);
        }
      }

      countCriteria = CriteriaTransformer.TransformToRowCount(pageCriteria);
    }

    private MTList<DataObject> ConvertToDataObjectMtList(MTList<EntityInstance> original)
    {
      MTList<DataObject> mtList = new MTList<DataObject>();
      foreach (MTBaseFilterElement mtFilterElement in original.Filters)
      {
        mtList.Filters.Add(mtFilterElement);
      }

      mtList.CurrentPage = original.CurrentPage;
      mtList.PageSize = original.PageSize;

      mtList.SortCriteria.AddRange(original.SortCriteria);

      return mtList;
    }

    private MTList<T> CopyMtList<T>(MTList<T> original)
    {
      MTList<T> mtList = new MTList<T>();
      foreach (MTBaseFilterElement mtFilterElement in original.Filters)
      {
        mtList.Filters.Add(mtFilterElement);
      }

      mtList.CurrentPage = original.CurrentPage;
      mtList.PageSize = original.PageSize;

      mtList.SortCriteria.AddRange(original.SortCriteria);

      return mtList;
    }

    private static MTList<TTarget> CopyMtList<TOriginal, TTarget>(MTList<TOriginal> original)
      where TOriginal : DataObject
      where TTarget : DataObject
    {
      var mtList = new MTList<TTarget>();
      foreach (MTBaseFilterElement mtFilterElement in original.Filters)
      {
        mtList.Filters.Add(mtFilterElement);
      }

      mtList.CurrentPage = original.CurrentPage;
      mtList.PageSize = original.PageSize;

      mtList.SortCriteria.AddRange(original.SortCriteria);

      return mtList;
    }

    private DataObject LoadInternal(string entityName, ISession session, Guid id)
    {
      Check.Require(session != null, "session cannot be null");
      var dataObject = session.Get(entityName, id) as DataObject;
      if (dataObject != null)
      {
        dataObject.SetupRelationships();
        if (session.Contains(dataObject))
        {
          session.Evict(dataObject);
        }
      }
      return dataObject;
    }

    private void LoadInstancesInternal(string entityName, ISession session, ref MTList<DataObject> mtList)
    {
      Check.Require(session != null, "session cannot be null", SystemConfig.CallerInfo);
      Check.Require(mtList != null, "mtList cannot be null", SystemConfig.CallerInfo);

      DetachedCriteria pageCriteria, countCriteria;
      GetQueryCriteria(session, entityName, mtList, out pageCriteria, out countCriteria, null);

      ExecutePagingQuery(session, 
                         pageCriteria, 
                         countCriteria, 
                         ref mtList, 
                         RepositoryAccess.Instance.IsEntityInOracle(entityName));
    }


    private void LoadInstancesForInternal(ISession session,
                                          string entityName,
                                          string forEntityName,
                                          Guid forEntityId,
                                          ref MTList<DataObject> mtList,
                                          out List<ErrorObject> errors,
                                          string relationshipName = null,
                                          bool related = true)
    {
      Check.Require(entityName != forEntityName,
                    String.Format("ForEntity '{0}' cannot be the same as Entity '{1}'. Use LoadChildren or LoadParent instead.", 
                                  forEntityName, entityName));

      errors = new List<ErrorObject>();

      // Get the relationship entity between entityName and forEntityName 
      // (doesn't matter if entityName is source and forEntityName is target or vice versa)
      RelationshipEntity relationshipEntity = 
        MetadataRepository.Instance.GetRelationshipEntity(entityName, forEntityName, relationshipName);

      if (relationshipEntity == null)
      {
        logger.Debug(String.Format("Cannot find a relationship between entity '{0}' and entity '{1}'",
                                   forEntityName, entityName));
        return;
      }

      Check.Require(!relationshipEntity.HasSameSourceAndTarget, 
                    String.Format("Relationship '{0}' is a self relationship. Use LoadChildren or LoadParent.", relationshipEntity));

      DetachedCriteria pageCriteria, countCriteria;
      GetQueryCriteria(session, entityName, mtList, out pageCriteria, out countCriteria, "this_.");

      if (!relationshipEntity.HasJoinTable)
      {
        string criteriaProperty = String.Empty;

        if (relationshipEntity.RelationshipType == RelationshipType.OneToOne &&
            relationshipEntity.SourceEntityName == entityName)
        {
          DetachedCriteria forEntityCriteria;

          if (related)
          {
            forEntityCriteria =
              DetachedCriteria.ForEntityName(forEntityName)
                .Add(Restrictions.IdEq(forEntityId))
                .SetProjection(Projections.Property(relationshipEntity.TargetPropertyNameForSource));

            pageCriteria.Add(Subqueries.PropertyIn("Id", forEntityCriteria));
          }
          else
          {
            pageCriteria.Add(Restrictions.IsEmpty(relationshipEntity.TargetPropertyNameForSource));
          }
        }
        else
        {
          criteriaProperty =
            relationshipEntity.SourceEntityName == entityName
              ? relationshipEntity.SourcePropertyNameForTarget
              : relationshipEntity.TargetPropertyNameForSource;

          if (related)
          {
            pageCriteria.CreateAlias(criteriaProperty, "alias")
                        .Add(Restrictions.Eq("alias.Id", forEntityId));
          }
          else
          {
            pageCriteria.Add(Restrictions.IsNull(criteriaProperty));
          }
        }
      }
      else
      {
        // Found a relationship between entityName and forEntityName
        string joinPropertyName = RelationshipEntity.GetPluralName(relationshipEntity.FullName);

        if (related)
        {
          pageCriteria.CreateAlias(joinPropertyName, "alias")
                      .Add(Expression.Eq("alias." + Name.GetEntityClassName(forEntityName) + ".Id", forEntityId));
        }
        else
        {
          var notCriteria = DetachedCriteria.ForEntityName(relationshipEntity.FullName)
                                            .SetProjection(Projections.Property(Name.GetEntityClassName(entityName) + ".Id")) 
                                            .Add(Expression.Eq(Name.GetEntityClassName(forEntityName) + ".Id", forEntityId));
                                           
          pageCriteria.Add(Subqueries.PropertyNotIn("Id", notCriteria));
        }
      }

      // Reset count criteria
      countCriteria = CriteriaTransformer.TransformToRowCount(pageCriteria);

      ExecutePagingQuery(session,
                         pageCriteria,
                         countCriteria,
                         ref mtList,
                         RepositoryAccess.Instance.IsEntityInOracle(entityName));
    }

    private void LoadConnectedInstancesForPath(ISession session,
                                               string entityName,
                                               Guid forEntityId,
                                               List<RelationshipEntity> path,
                                               ref MTList<DataObject> mtList,
                                               out List<ErrorObject> errors)
    {
      errors = new List<ErrorObject>();

      DetachedCriteria pageCriteria, countCriteria;
      GetQueryCriteria(session, entityName, mtList, out pageCriteria, out countCriteria);

      // As an example, we're going to create the following aliases and expressions given three entities
      // Dashboard --< Column --< Widget

      // The goal is to find all Widget's for a given Dashboard. 
      // The path will contain the following RelationshipEntity items:
      // Dashboard->Column, Column->Widget

      // Working backwards from Widget, we create aliases for the joins and finally
      // add the Dashboard.Id as a part of the where clause

      // pageCriteria.CreateAlias("Column_WidgetList", "column_widgetList")
      //             .CreateAlias("column_widgetList.Column", "column")
      //             .CreateAlias("column.Dashboard_ColumnList", "dashboard_ColumnList")
      //             .CreateAlias("dashboard_ColumnList.Dashboard", "dashboard")
      //             .Add(Expression.Eq("dashboard.Id", forEntityId));

      string sourceAlias = String.Empty;

      for (int i = path.Count - 1; i >= 0; i--)
      {
        RelationshipEntity relationshipEntity = path[i];

        // "Column_WidgetList" for i = 1          // counting downwards
        // "Dashboard_ColumnList" for i = 0
        string collectionPropertyName = RelationshipEntity.GetPluralName(relationshipEntity.FullName);

        // "column_widgetList" for i = 1
        // "dashboard_ColumnList" for i = 0
        string collectionAlias = collectionPropertyName.LowerCaseFirst();

        string associationPath;

        if (String.IsNullOrEmpty(sourceAlias))
        {
          associationPath = collectionPropertyName;
        }
        else
        {
          associationPath = sourceAlias + "." + collectionPropertyName;
        }

        // .CreateAlias("Column_WidgetList", "column_widgetList") for i = 1
        // .CreateAlias("column.Dashboard_ColumnList", "dashboard_ColumnList") for i = 0
        pageCriteria.CreateAlias(associationPath, collectionAlias);

        // "Column" for i = 1
        // "Dashboard" for i = 0
        string sourceEntityName = Name.GetEntityClassName(relationshipEntity.SourceEntityName);

        // "column_widgetList.Column" for i = 1
        // "dashboard_ColumnList.Dashboard" for i = 0
        string collectionPropertySource = collectionAlias + "." + sourceEntityName;

        // "column" for i = 1
        // "dashboard" for i = 0
        sourceAlias = sourceEntityName.LowerCaseFirst();

        // .CreateAlias("column_widgetList.Column", "column") for i = 1
        // .CreateAlias("dashboard_ColumnList.Dashboard", "dashboard") for i = 0
        pageCriteria.CreateAlias(collectionPropertySource, sourceAlias);

        if (i == 0)
        {
          // .Add(Expression.Eq("dashboard.Id", forEntityId));
          pageCriteria.Add(Expression.Eq(sourceAlias + ".Id", forEntityId));
        }
      }

      countCriteria = CriteriaTransformer.TransformToRowCount(pageCriteria);

      ExecutePagingQuery(session, 
                         pageCriteria, 
                         countCriteria, 
                         ref mtList, 
                         RepositoryAccess.Instance.IsEntityInOracle(entityName));
    }

    private void LoadChildrenInternal(ISession session,
                                      string parentEntityName,
                                      Guid parentId,
                                      ref MTList<DataObject> mtList,
                                      out List<ErrorObject> errors)
    {
      throw new NotImplementedException("Self-Relationships have been removed");
      //errors = new List<ErrorObject>();

      //Entity entity = MetadataRepository.Instance.GetEntity(parentEntityName);

      //if (entity == null)
      //{
      //  string errorMessage =
      //    String.Format("Cannot find entity '{0}'", parentEntityName);
      //  errors.Add(new ErrorObject(errorMessage));
      //  return;
      //}

      ////if (!entity.HasSelfRelationship)
      ////{
      ////  string errorMessage =
      ////    String.Format("Entity '{0}' does not support self relationships", parentEntityName);
      ////  errors.Add(new ErrorObject(errorMessage));
      ////  return;
      ////}

      //Check.Require(parentId != Guid.Empty, "parentId cannot be empty", SystemConfig.CallerInfo);

      //string joinPropertyName = entity.SelfRelationshipEntity.GetChildPluralName();

      //DetachedCriteria pageCriteria, countCriteria;
      //GetQueryCriteria(session, parentEntityName, mtList, out pageCriteria, out countCriteria);

      //pageCriteria.CreateAlias(joinPropertyName, "alias")
      //            .Add(Expression.Eq("alias.Parent.Id", parentId));

      //ExecutePagingQuery(session, pageCriteria, countCriteria, ref mtList, RepositoryAccess.Instance.IsEntityInOracle(parentEntityName));

      #region Experiments with FlatTable Schema
      //criteria.Add(Subqueries.Exists(DetachedCriteria.ForEntityName(typeof(T).FullName)))
      //  .SetProjection(Projections.Id())
      //  .CreateAlias("Orders", "order")
      //  .Add(Expression.Eq("order.Id", parentId));
      //                               .Add(Expression.Eq("indx.EntityGroupName", entityGroupName))
      //                               .Add(Expression.Eq("indx.EntityName", entityName))
      //                               .Add(Expression.Eq("indx.PropertyName", mtFilterElement.PropertyName))
      //                               .Add(GetSimpleExpression(mtFilterElement, type.FullName, "indx." + indexPropertyName))
      //                               .Add(Restrictions.EqProperty("e1.Id", "e.Id"))));
      // Create a filter for the parent
      //string parentPropertyName = GetParentPropertyName(typeof(T).FullName, parentTypeName);
      //// Load the parent
      //object parent = session.Load(parentTypeName, parentId);
      //Check.Require(parent != null,
      //              String.Format("Cannot load item with type '{0}' and id '{1}' from the database", parentTypeName, parentId),
      //              SystemConfig.CallerInfo);

      //criteria.Add(Expression.Eq(parentPropertyName, parent));

      //IList results = multiCriteria.List();
      //Check.Ensure(results.Count == 2, "Expected two results from query", SystemConfig.CallerInfo);

      //IList value = (IList)results[0];
      //rowCount = (int)((IList)results[1])[0];
      //rowCount = 0;
      //return value;
      #endregion
    }

    private void LoadInstancesForMetranetEntityInternal(ISession session,
                                                        string entityName,
                                                        ref MTList<DataObject> mtList,
                                                        IMetranetEntity metranetEntity)
    {
      Check.Require(session != null, "session cannot be null", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(mtList != null, "mtList cannot be null", SystemConfig.CallerInfo);
      Check.Require(metranetEntity != null, "metranetEntity cannot be null", SystemConfig.CallerInfo);

      DetachedCriteria pageCriteria, countCriteria;
      GetQueryCriteria(session, entityName, mtList, out pageCriteria, out countCriteria);

      // Create criteria for metranetEntity properties
      foreach (MetranetEntityProperty metranetEntityProperty in metranetEntity.Properties)
      {
        pageCriteria.Add(Expression.Eq(metranetEntityProperty.Name, metranetEntityProperty.Value));
      }

      ExecutePagingQuery(session, pageCriteria, countCriteria, ref mtList, RepositoryAccess.Instance.IsEntityInOracle(entityName));
    }

    private void SaveInstances(ref List<DataObject> dataObjects)
    {
      if (dataObjects == null || dataObjects.Count == 0)
      {
        return;
      }

      try
      {
        string entityName = dataObjects[0].GetType().FullName;

        using (var session = RepositoryAccess.Instance.GetSession(entityName))
        {
          if (RepositoryAccess.Instance.IsEntityInOracle(entityName) && Transaction.Current != null)
          {            
              foreach (DataObject dataObject in dataObjects)
              {
                SaveOrUpdateInternal(dataObject, session);
              }            
          }
          else
          {
            using (var transaction = session.BeginTransaction())
            {
              foreach (DataObject dataObject in dataObjects)
              {
                SaveOrUpdateInternal(dataObject, session);
              }

              transaction.Commit();
              session.Clear();
            }
          }
        }
      }
      catch (StaleObjectStateException e)
      {
        string message = String.Format("Cannot save entity instance '{0}' with Id '{1}' because it has " +
                                       "been updated by another transaction. Refresh your data and try again.",
                                       e.EntityName, e.Identifier);
        throw new OptimisticConcurrencyException(message);
      }
      catch (System.Exception e)
      {
        var message = String.Format("Cannot save data objects of type '{0}' with Id'{1}'", dataObjects[0].GetType().FullName, dataObjects[0].Id.ToString());
        //Need two error message checks, one for SQL server, one for Oracle.  Their errors are different.  The Oracle message is actually useful, unlike the SQL server one, so
        // if we see that error, we'll append the message to exception.
        if (e.Message.Contains("value too large for column"))
        {
          message = message + "The string length exceeds the maximum number of characters for one of your entries";
        }
        else if (e.InnerException != null)
        {
          if (e.InnerException.Message.Contains("String or binary data would be truncated"))
          {
            message = String.Format("Cannot save data in object of type '{0}'; The string length exceeds the maximum number of characters for one of your entries",
                                    dataObjects[0].GetType().FullName);
          }
          else if (e.InnerException.Message.Contains("Cannot insert duplicate key"))
          {
            message = message + "; unique key constraint violated.";
            throw new UniqueKeyViolationException(message, e);
          }
        }
          //CORE-4640 error message for Oracle unique constraint.
        if (e.Message.Contains("unique constraint"))
        {
            message = message + "; unique key constraint violated.";
            throw new UniqueKeyViolationException(message, e);
        }
        throw new SaveDataException(message, e);
      }
    }

    private void CreateInstancesFor(string forEntityName, Guid forEntityId, ref IList<DataObject> dataObjects, string relationshipName = null)
    {
      try
      {
        List<ErrorObject> errors;

        if (RepositoryAccess.Instance.IsEntityInOracle(forEntityName) && Transaction.Current != null)
        {
          using (var session = RepositoryAccess.Instance.GetSession(forEntityName, FlushMode.Never))
          {
            CreateForInternal(session, forEntityName, forEntityId, ref dataObjects, out errors, relationshipName);
          }
        }
        else
        {
          using (var session = RepositoryAccess.Instance.GetSession(forEntityName, FlushMode.Never))
          {
            CreateForInternalTransactional(session, forEntityName, forEntityId, ref dataObjects, out errors, relationshipName);
          }
        }

        if (errors.Count > 0)
        {
          string message = String.Format("Cannot save items for related type '{0}' and id '{1}'", forEntityName, forEntityId);
          throw new SaveDataException(message, errors);
        }
        
      }
      catch (SaveDataException)
      {
        throw;
      }
      catch (System.Exception e)
      {
        string message = String.Format("Cannot save items for related type '{0}' and id '{1}'", forEntityName, forEntityId);
        if (e.InnerException != null && e.InnerException.Message.Contains("Cannot insert duplicate key"))
        {
          message = String.Format("Cannot save data of type '{0}'; unique key constraint violated.", forEntityName);
          throw new UniqueKeyViolationException(message, e);
        }
        
        throw new SaveDataException(message, e);
      }
    }

    private void CreateForInternal(ISession session,
                                   string forEntityName,
                                   Guid forEntityId,
                                   ref IList<DataObject> dataObjects,
                                   out List<ErrorObject> errors,
                                   string relationshipName = null)
    {
      errors = new List<ErrorObject>();

      if (dataObjects == null || dataObjects.Count == 0)
      {
        return;
      }

      RelationshipEntity relationshipEntity =
        MetadataRepository.Instance.GetRelationshipEntity(dataObjects[0].GetType().FullName, forEntityName, relationshipName);

      if (relationshipEntity == null)
      {
        string errorMessage = String.IsNullOrEmpty(relationshipName)
                                ? String.Format("Cannot find a relationship between entity '{0}' and entity '{1}'",
                                                dataObjects[0].GetType().FullName, forEntityName)
                                : String.Format(
                                  "Cannot find a relationship between entity '{0}' and entity '{1}' using relationship name '{2}'",
                                  dataObjects[0].GetType().FullName, forEntityName, relationshipName);

        errors.Add(new ErrorObject(errorMessage));
        return;
      }

      if (relationshipEntity.RelationshipType == RelationshipType.OneToOne && dataObjects.Count > 1)
      {
        string errorMessage =
          String.Format("Cannot handle more than one instance of entity '{0}' for entity '{1}' " +
                        "because they have a One-To-One relationship",
                        dataObjects[0].GetType().FullName, forEntityName);
        errors.Add(new ErrorObject(errorMessage));
        return;
      }

      Check.Require(!String.IsNullOrEmpty(forEntityName), "forEntityName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(forEntityId != Guid.Empty, "forEntityId cannot be empty", SystemConfig.CallerInfo);

      DataObject parent = session.Load(forEntityName, forEntityId) as DataObject;
      if (parent == null)
      {
        string errorMessage = String.Format("Cannot load item with type '{0}' and id '{1}'.", forEntityName, forEntityId);
        errors.Add(new ErrorObject(errorMessage));
        return;
      }

      // Create rows 
      foreach (DataObject dataObject in dataObjects)
      {
        if (dataObject.Id != Guid.Empty)
        {
          string errorMessage =
            String.Format("Cannot create instance of type '{0}', because it has a valid id '{1}' ",
                          dataObject.GetType().FullName, dataObject.Id);
          errors.Add(new ErrorObject(errorMessage));
          return;
        }

        //#region Check for duplicate for One-To-One
        //if (relationshipEntity.RelationshipType == RelationshipType.OneToOne)
        //{
        //  // Check that the row does not exist 
        //  IList results =
        //    session.CreateCriteria(relationshipEntity.FullName)
        //           .Add(Expression.Eq(Name.GetEntityClassName(forEntityName), parent)).List();
        //  session.Flush();
        //  if (results.Count > 0)
        //  {
        //    string errorMessage =
        //      String.Format("Cannot create a One-To-One relationship between '{0}' and '{1}' because one already exists",
        //                    forEntityName, dataObjects[0].GetType().FullName);
        //    errors.Add(new ErrorObject(errorMessage));
        //    return;
        //  }
        //}
        //#endregion

        if (!relationshipEntity.HasJoinTable)
        {
          string relationshipPropertyName = 
            relationshipEntity.SourceEntityName == forEntityName
              ? relationshipEntity.TargetPropertyNameForSource
              : relationshipEntity.SourcePropertyNameForTarget;

          dataObject.SetValue(parent, relationshipPropertyName);
        }

        SaveOrUpdateInternal(dataObject, session);
        session.Flush();
      }

      if (relationshipEntity.HasJoinTable)
      {
        // Create rows in the relationship table. 
        Type relationshipType = Type.GetType(relationshipEntity.AssemblyQualifiedName, true);


        string parentClassName = Name.GetEntityClassName(forEntityName);
        string childClassName = Name.GetEntityClassName(dataObjects[0].GetType().FullName);
        Check.Require(!String.IsNullOrEmpty(childClassName),
                      String.Format("Cannot find class name for type '{0}'", dataObjects[0].GetType().FullName));


        foreach (DataObject dataObject in dataObjects)
        {
          var relationshipInstance = Activator.CreateInstance(relationshipType, false) as DataObject;
          Check.Require(relationshipInstance != null,
                        String.Format("Cannot create relationship instance for for type '{0}'",
                                      dataObjects[0].GetType().FullName));

          relationshipInstance.SetValue(parent, parentClassName);
          relationshipInstance.SetValue(dataObject, childClassName);

          session.SaveOrUpdate(relationshipInstance);
          session.Flush();
        }
      }

      #region Sample Code
      //foreach (DataObject dataObject in dataObjects)
      //{
      //  var o = new global::Core.OrderManagement.Order_OrderItem();
      //  ((global::Core.OrderManagement.OrderItem)dataObject).Order_OrderItemList.Add(o);
      //  o.BusinessKey = new global::Core.OrderManagement.Order_OrderItemBusinessKey() {BusinessKey = Guid.NewGuid()};
      //  o.Order = parent as global::Core.OrderManagement.Order;
      //  o.OrderItem = dataObject as global::Core.OrderManagement.OrderItem;
      //  session.SaveOrUpdate(o);
      //}
      #endregion
    }

    private void CreateForInternalTransactional(ISession session,
                                   string forEntityName,
                                   Guid forEntityId,
                                   ref IList<DataObject> dataObjects,
                                   out List<ErrorObject> errors,
                                   string relationshipName = null)
    {
      errors = new List<ErrorObject>();

      if (dataObjects == null || dataObjects.Count == 0)
      {
        return;
      }

      RelationshipEntity relationshipEntity = MetadataRepository.Instance.GetRelationshipEntity(dataObjects[0].GetType().FullName, forEntityName, relationshipName);

      if (relationshipEntity == null)
      {
        string errorMessage = String.IsNullOrEmpty(relationshipName)
                                ? String.Format("Cannot find a relationship between entity '{0}' and entity '{1}'", dataObjects[0].GetType().FullName, forEntityName)
                                : String.Format(
                                "Cannot find a relationship between entity '{0}' and entity '{1}' using relationship name '{2}'",
                                dataObjects[0].GetType().FullName,
                                forEntityName,
                                relationshipName);

        errors.Add(new ErrorObject(errorMessage));
        return;
      }

      if (relationshipEntity.RelationshipType == RelationshipType.OneToOne && dataObjects.Count > 1)
      {
        string errorMessage =
          String.Format("Cannot handle more than one instance of entity '{0}' for entity '{1}' " +
                        "because they have a One-To-One relationship",
                        dataObjects[0].GetType().FullName, forEntityName);
        errors.Add(new ErrorObject(errorMessage));
        return;
      }

      Check.Require(!String.IsNullOrEmpty(forEntityName), "forEntityName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(forEntityId != Guid.Empty, "forEntityId cannot be empty", SystemConfig.CallerInfo);

      DataObject parent = session.Load(forEntityName, forEntityId) as DataObject;
      if (parent == null)
      {
        string errorMessage = String.Format("Cannot load item with type '{0}' and id '{1}'.", forEntityName, forEntityId);
        errors.Add(new ErrorObject(errorMessage));
        return;
      }

      Type relationshipType = null;
      string parentClassName = null;
      string childClassName = null;

      if (relationshipEntity.HasJoinTable)
      {
        // Identify the relationship entity type.
        relationshipType = Type.GetType(relationshipEntity.AssemblyQualifiedName, true);

        parentClassName = Name.GetEntityClassName(forEntityName);
        childClassName = Name.GetEntityClassName(dataObjects[0].GetType().FullName);
        Check.Require(!String.IsNullOrEmpty(childClassName),
                      String.Format("Cannot find class name for type '{0}'", dataObjects[0].GetType().FullName));
      }

      // Create rows 
      foreach (DataObject dataObject in dataObjects)
      {
        DataObject relationshipInstance = null;
        if (dataObject.Id != Guid.Empty)
        {
          string errorMessage =
            String.Format("Cannot create instance of type '{0}', because it has a valid id '{1}' ",
                          dataObject.GetType().FullName, dataObject.Id);
          errors.Add(new ErrorObject(errorMessage));
          return;
        }

        if (!relationshipEntity.HasJoinTable)
        {
          string relationshipPropertyName =
            relationshipEntity.SourceEntityName == forEntityName
              ? relationshipEntity.TargetPropertyNameForSource
              : relationshipEntity.SourcePropertyNameForTarget;

          dataObject.SetValue(parent, relationshipPropertyName);
        }
        else
        {
          // Create rows in the relationship table. 
          System.Diagnostics.Debug.Assert(relationshipType != null, "relationshipType != null");
          relationshipInstance = Activator.CreateInstance(relationshipType, false) as DataObject;
          Check.Require(relationshipInstance != null,
                        String.Format("Cannot create relationship instance for for type '{0}'",
                                      dataObjects[0].GetType().FullName));

          System.Diagnostics.Debug.Assert(relationshipInstance != null, "relationshipInstance != null");
          relationshipInstance.SetValue(parent, parentClassName);
          relationshipInstance.SetValue(dataObject, childClassName);
        }

        using (var tx = session.BeginTransaction(IsolationLevel.ReadCommitted))
        {
          // session.SetBatchSize(100);
          System.Diagnostics.Stopwatch watch = new Stopwatch();
          watch.Start();

          try
          {
            SaveOrUpdateInternal(dataObject, session);
            if (relationshipInstance != null)
            {
              session.SaveOrUpdate(relationshipInstance);
            }
            session.Flush();

            tx.Commit();
          }
          catch (System.Exception)
          {
            tx.Rollback();
            throw;
          }
          finally
          {
            watch.Stop();
            logger.Debug(string.Format("Elapsed transaction duration to create entity \"{0}\": {1} ms", forEntityName, (double)watch.ElapsedTicks / 10000.0));
          }
        }
      }
    }

    private IList<DataObject> CreateChildrenInternal(ISession session,
                                                     Guid parentId,
                                                     IList<DataObject> childDataObjects,
                                                     out List<ErrorObject> errors)
    {
      throw new NotImplementedException("Self relationships have been removed");

      //errors = new List<ErrorObject>();

      //IList<DataObject> savedDataObjects = new List<DataObject>();

      //if (childDataObjects == null || childDataObjects.Count == 0)
      //{
      //  return savedDataObjects;
      //}

      //Entity entity = MetadataRepository.Instance.GetEntity(childDataObjects[0].GetType().FullName);

      //if (entity == null)
      //{
      //  string errorMessage =
      //    String.Format("Cannot find entity '{0}'", childDataObjects[0].GetType().FullName);
      //  errors.Add(new ErrorObject(errorMessage));
      //  return null;
      //}

      ////if (!entity.HasSelfRelationship)
      ////{
      ////  string errorMessage =
      ////    String.Format("Entity '{0}' does not support self relationships", entity.FullName);
      ////  errors.Add(new ErrorObject(errorMessage));
      ////  return null;
      ////}

      //Check.Require(parentId != Guid.Empty, "parentId cannot be empty", SystemConfig.CallerInfo);

      //DataObject parent = session.Load(entity.FullName, parentId) as DataObject;
      //if (parent == null)
      //{
      //  string errorMessage = String.Format("Cannot load parent of type '{0}' and id '{1}'.", entity.FullName, parentId);
      //  errors.Add(new ErrorObject(errorMessage));
      //  return savedDataObjects;
      //}

      //// Create rows 
      //foreach (DataObject dataObject in childDataObjects)
      //{
      //  if (dataObject.Id != Guid.Empty)
      //  {
      //    string errorMessage =
      //      String.Format("Cannot create instance of type '{0}', because it has a valid id '{1}' ",
      //                    entity.FullName, dataObject.Id);
      //    errors.Add(new ErrorObject(errorMessage));
      //    return savedDataObjects;
      //  }

      //  UpdateCompound(dataObject);
      //  session.SaveOrUpdate(dataObject);
      //  savedDataObjects.Add(dataObject);
      //}

      //// Create rows in the relationship table. See 'Sample Code' region for more info.
      //// Expect to find an AddChild method on parent
      //MethodInfo methodInfo = parent.GetType().GetMethod("AddChild");
    
      //Check.Require(methodInfo != null,
      //              String.Format("Cannot find method 'AddChild' for type '{0}'", entity.FullName));

      //foreach (DataObject dataObject in childDataObjects)
      //{
      //  var relationshipInstance = methodInfo.Invoke(parent, new object[] { dataObject }) as DataObject;
      //  Check.Require(relationshipInstance != null,
      //                String.Format("Cannot create relationship instance using method 'AddChild' for type '{0}'",
      //                              entity.FullName));

      //  session.SaveOrUpdate(relationshipInstance);
      //}

      //#region Sample Code
      ////foreach (DataObject dataObject in dataObjects)
      ////{
      ////  var o = new global::Core.OrderManagement.Order_OrderItem();
      ////  ((global::Core.OrderManagement.OrderItem)dataObject).Order_OrderItemList.Add(o);
      ////  o.BusinessKey = new global::Core.OrderManagement.Order_OrderItemBusinessKey() {BusinessKey = Guid.NewGuid()};
      ////  o.Order = parent as global::Core.OrderManagement.Order;
      ////  o.OrderItem = dataObject as global::Core.OrderManagement.OrderItem;
      ////  session.SaveOrUpdate(o);
      ////}
      //#endregion

      //session.Flush();

      //return savedDataObjects;
    }

    private void CreateRelationshipInternal(List<RelationshipInstanceData> relationshipInstanceDataList)
    {
      Check.Require(relationshipInstanceDataList != null, "relationshipInstanceDataList cannot be null");
      if (relationshipInstanceDataList.Count == 0)
      {
        return;
      }

      Check.Require(relationshipInstanceDataList[0].Source != null, "source cannot be null");

      using (var session = RepositoryAccess.Instance.GetSession(relationshipInstanceDataList[0].Source.GetType().FullName, FlushMode.Never))
      using (var tx = session.BeginTransaction())
      {
        foreach(RelationshipInstanceData relationshipInstanceData in relationshipInstanceDataList)
        {
          Check.Require(relationshipInstanceData.Source != null, "source cannot be null");
          Check.Require(relationshipInstanceData.Target != null, "target cannot be null");
          Check.Require(relationshipInstanceData.Source.Id != Guid.Empty,
                        String.Format("Cannot create relationship with non-persisted instance of type '{0}'",
                                      relationshipInstanceData.Source.GetType().FullName));
          Check.Require(relationshipInstanceData.Target.Id != Guid.Empty,
                        String.Format("Cannot create relationship with non-persisted instance of type '{0}'",
                                      relationshipInstanceData.Target.GetType().FullName));

          RelationshipEntity relationshipEntity =
            MetadataRepository.Instance.GetRelationshipEntity(relationshipInstanceData.Source.GetType().FullName,
                                                              relationshipInstanceData.Target.GetType().FullName);

          Check.Require(relationshipEntity != null,
                        String.Format("Failed to find relationship between '{0}' and '{1}'",
                                      relationshipInstanceData.Source.GetType().FullName,
                                      relationshipInstanceData.Target.GetType().FullName));

          DataObject actualSource, actualTarget;
          if (relationshipInstanceData.Source.GetType().FullName == relationshipEntity.SourceEntityName)
          {
            actualSource = relationshipInstanceData.Source;
            actualTarget = relationshipInstanceData.Target;
          }
          else
          {
            actualSource = relationshipInstanceData.Target;
            actualTarget = relationshipInstanceData.Source;
          }

          // No join tables
          if (!relationshipEntity.HasJoinTable)
          {
            if (relationshipEntity.RelationshipType == RelationshipType.OneToMany ||
                relationshipEntity.RelationshipType == RelationshipType.OneToOne)
            {
              actualTarget.SetValue(actualSource, relationshipEntity.TargetPropertyNameForSource);
              SaveInstance(ref actualTarget);
            }

            continue;
          }
          
          IList relationshipInstances =
            session.CreateCriteria(relationshipEntity.FullName)
              .Add(Expression.Eq(actualSource.GetType().Name + ".Id", actualSource.Id))
              .Add(Expression.Eq(actualTarget.GetType().Name + ".Id", actualTarget.Id))
              .List();

          if (relationshipInstances.Count > 0)
          {
            logger.Debug(String.Format("A relationship already exists between '{0}' and '{1}'", actualSource,
                                       actualTarget));
            continue;
          }

          #region Handle One-To-One

          if (relationshipEntity.RelationshipType == RelationshipType.OneToOne)
          {
            relationshipInstances =
              session.CreateCriteria(relationshipEntity.FullName)
                .Add(Expression.Eq(actualSource.GetType().Name + ".Id", actualSource.Id))
                .List();

            Check.Require(relationshipInstances.Count <= 1,
                          String.Format("Found more than one relationship for object '{0}'. " +
                                        "The relationship type between '{1}' and '{2}' is One-To-One",
                                        actualSource,
                                        actualSource.GetType().FullName,
                                        actualTarget.GetType().FullName));


            if (relationshipInstances.Count > 0)
            {
              // Delete the relationship
              logger.Debug(String.Format("Deleting existing relationship '{0}'", relationshipInstances[0]));
              session.Delete(relationshipInstances[0]);
              session.Flush();
            }

            session.Clear();

            relationshipInstances =
              session.CreateCriteria(relationshipEntity.FullName)
                .Add(Expression.Eq(actualTarget.GetType().Name + ".Id", actualTarget.Id))
                .List();

            Check.Require(relationshipInstances.Count <= 1,
                          String.Format("Found more than one relationship for object '{0}'. " +
                                        "The relationship type between '{1}' and '{2}' is One-To-One",
                                        actualTarget,
                                        actualSource.GetType().FullName,
                                        actualTarget.GetType().FullName));

            if (relationshipInstances.Count > 0)
            {
              // Delete the relationship
              logger.Debug(String.Format("Deleting existing relationship '{0}'", relationshipInstances[0]));
              session.Delete(relationshipInstances[0]);
              session.Flush();
            }

            session.Clear();
          }

          #endregion

          Type relationshipType = Type.GetType(relationshipEntity.AssemblyQualifiedName, true);
          var relationshipInstance = Activator.CreateInstance(relationshipType, false) as DataObject;

          Check.Require(relationshipInstance != null,
                        String.Format("Cannot create relationship instance for type '{0}'",
                                      relationshipEntity.AssemblyQualifiedName));

          relationshipInstance.SetValue(actualSource, actualSource.GetType().Name);
          relationshipInstance.SetValue(actualTarget, actualTarget.GetType().Name);

          logger.Debug(String.Format("Creating a relationship between '{0}' and '{1}'", actualSource, actualTarget));
          session.SaveOrUpdate(relationshipInstance);
          session.Flush();
        }

        
        tx.Commit();
      }
    }
    
    private void DeleteInternal(string entityName, Guid id)
    {
      Check.Require(id != Guid.Empty, String.Format("Cannot delete instance '{0}' because it has an invalid identifier", entityName));
      try
      {
        logger.Debug(String.Format("Deleting entity '{0}' with Id '{1}'", entityName, id));

        if (RepositoryAccess.Instance.IsEntityInOracle(entityName) && Transaction.Current != null)
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName))
          {
            // Using HQL which looks like: "session.Delete("from Customer cst where cst._id = ?", crit.ID, NHibernateUtil.Guid)"
            string hql = "from " + entityName + " instance where instance.Id = ?";
            session.Delete(hql, id, NHibernateUtil.Guid);
            session.Clear();
          }
        }
        else
        {
          using (var session = RepositoryAccess.Instance.GetSession(entityName))
          using (var tx = session.BeginTransaction())
          {
            // Using HQL which looks like: "session.Delete("from Customer cst where cst._id = ?", crit.ID, NHibernateUtil.Guid)"
            string hql = "from " + entityName + " instance where instance.Id = ?";
            session.Delete(hql, id, NHibernateUtil.Guid);

            tx.Commit();

            session.Clear();
          }
        }
        
      }
      catch (System.Exception e)
      {
        string message = String.Format("Failed to delete instance '{0}'", entityName);
        throw new DeleteDataException(message, e);
      }
    }

    private void SaveOrUpdateInternal(DataObject dataObject, ISession session)
    {
      if (!dataObject.IsTransient())
      {
        Entity entity = MetadataRepository.Instance.GetEntity(dataObject.GetType().FullName);
        Check.Require(entity != null, String.Format("Cannot find entity for type '{0}'", dataObject.GetType().FullName));

        if (entity.HasForeignKeyProperties)
        {
          UpdateCompound(dataObject);

          var dbDataObject = session.Get(dataObject.GetType().FullName, dataObject.Id) as DataObject;
          Check.Require(dbDataObject != null, String.Format("Cannot find instance of type '{0}' with Id '{1}'", dataObject.GetType().FullName, dataObject.Id));
          dbDataObject.CopyPropertiesFrom(dataObject);

          session.SaveOrUpdate(dbDataObject);

          return;
        }
      }

      UpdateCompound(dataObject);
      session.SaveOrUpdate(dataObject);
    }
    #endregion

    #region Internal Static
    /// <summary>
    /// 
    /// </summary>
    /// <param name="invocationInfo"></param>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    internal static void GetExtensionAndEntityGroup(IInvocationInfo invocationInfo,
                                                   out string extensionName,
                                                   out string entityGroupName)
    {
      Check.Require(invocationInfo != null, "invocationInfo cannot be null", SystemConfig.CallerInfo);

      extensionName = null;
      entityGroupName = null;

      switch (invocationInfo.TargetMethod.Name)
      {
        case "CreateChild":
          {
            Check.Require(invocationInfo.Arguments.Length == 2,
                          "Expected 2 argumenst for 'CreateChild'", SystemConfig.CallerInfo);

            var dataObject = invocationInfo.Arguments[1] as DataObject;
            Check.Require(dataObject != null,
                          "Cannot convert the second argument to 'CreateChild' to 'DataObject'",
                          SystemConfig.CallerInfo);

            Name.GetExtensionAndEntityGroup(dataObject.GetType().FullName, out extensionName, out entityGroupName);
            break;
          }
        case "CreateChildren":
          {
            Check.Require(invocationInfo.Arguments.Length == 2,
                          "Expected 2 arguments for 'CreateChildren'", SystemConfig.CallerInfo);

            var dataObjects = invocationInfo.Arguments[1] as IList<DataObject>;
            Check.Require(dataObjects != null,
                          "Cannot convert the second argument to 'CreateChildren' to 'IList<DataObject>'",
                          SystemConfig.CallerInfo);

            Name.GetExtensionAndEntityGroup(dataObjects[0].GetType().FullName, out extensionName, out entityGroupName);
            break;
          }
        case "SaveInstance":
        case "DeleteInstance":
        case "CreateRelationship":
        case "DeleteRelationship":
          {
            Check.Require(invocationInfo.Arguments.Length >= 1,
                          "Expected 1 argument", SystemConfig.CallerInfo);

            var dataObject = invocationInfo.Arguments[0] as DataObject;
            Check.Require(dataObject != null,
                          "Cannot convert the argument to 'DataObject'",
                          SystemConfig.CallerInfo);

            Name.GetExtensionAndEntityGroup(dataObject.GetType().FullName, out extensionName, out entityGroupName);
            break;
          }
        case "SaveInstances":
          {
            Check.Require(invocationInfo.Arguments.Length == 1,
                          "expected 1 argument for 'SaveInstances'", SystemConfig.CallerInfo);

            var instances = invocationInfo.Arguments[0] as List<DataObject>;
            Check.Require(instances != null,
                          "Cannot convert the argument to 'SaveInstances' to List<DataObject>",
                          SystemConfig.CallerInfo);

            Name.GetExtensionAndEntityGroup(instances[0].GetType().FullName, out extensionName, out entityGroupName);

            break;
          }
        case "SaveEntityInstance":
        case "DeleteEntityInstance":
          {
            Check.Require(invocationInfo.Arguments.Length == 1,
                          "expected 1 argument for 'SaveEntityInstance'", SystemConfig.CallerInfo);

            var entityInstance = invocationInfo.Arguments[0] as EntityInstance;
            Check.Require(entityInstance != null,
                          "Cannot convert the argument to 'SaveEntityInstance' to EntityInstance",
                          SystemConfig.CallerInfo);

            Name.GetExtensionAndEntityGroup(entityInstance.EntityFullName, out extensionName, out entityGroupName);

            break;
          }
        case "SaveEntityInstances":
          {
            Check.Require(invocationInfo.Arguments.Length == 1,
                          "expected 1 argument for 'SaveEntityInstances'", SystemConfig.CallerInfo);

            var entityInstances = invocationInfo.Arguments[0] as List<EntityInstance>;
            Check.Require(entityInstances != null,
                          "Cannot convert the argument to 'SaveEntityInstances' to List<EntityInstance>",
                          SystemConfig.CallerInfo);

            Name.GetExtensionAndEntityGroup(entityInstances[0].EntityFullName, out extensionName, out entityGroupName);

            break;
          }

        case "CreateEntityInstanceFor":
        case "CreateEntityInstancesFor":
        case "CreateInstanceFor":
        case "CreateInstancesFor":
        case "LoadEntityInstance":
        case "LoadEntityInstanceByBusinessKey":
        case "LoadEntityInstances":
        case "LoadEntityInstanceFor":
        case "LoadEntityInstancesFor":
        case "LoadEntityInstancesForMetranetEntity":
        case "LoadInstance":
        case "LoadInstanceByBusinessKey":
        case "LoadInstanceByBusinessKeyProperties":
        case "LoadInstances":
        case "LoadInstanceFor":
        case "LoadInstancesFor":
        case "LoadInstancesForMetranetEntity":
        case "LoadInstanceHistory":
        case "LoadHistoryInstances":
        case "Delete":
        case "LoadChildren":
        case "DeleteAllRelationships":
          {
            Check.Require(invocationInfo.Arguments.Length >= 1,
                          String.Format("Incorrect number of arguments specified for method '{0}'",
                                        invocationInfo.TargetMethod.Name),
                          SystemConfig.CallerInfo);

            // First argument must be a string
            var entityName = invocationInfo.Arguments[0] as string;
            Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);
            Name.GetExtensionAndEntityGroup(entityName, out extensionName, out entityGroupName);
            break;
          }
        case "GetLocalizedEntries":
        case "LoadEntitySyncData":
        case "SaveEntitySyncData":
        case "TableHasRows":
        case "GetColumnMetadata":
        case "GetTableNames":
          {
            extensionName = "Core";
            entityGroupName = "Common";
            break;
          }
        default:
          {
            throw new DataAccessException(String.Format("Cannot handle method '{0}'", invocationInfo.TargetMethod.Name),
                                          SystemConfig.CallerInfo);
          }
      }

    }

    internal static void UpdateCompound(DataObject dataObject)
    {
      if (dataObject is ICompound)
      {
        var compound = dataObject as ICompound;
        compound.TransferDataToLegacy();
      }
    }
    #endregion

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("StandardRepository");
    private static volatile StandardRepository instance;
    private static object syncRoot = new Object();
    #endregion
  }

  [Serializable]
  [DataContract(IsReference = true)]
  public class RelationshipInstanceData
  {
    [DataMember]
    public DataObject Source { get; set; }
    [DataMember]
    public DataObject Target { get; set; }
  }

  [Serializable]
  [DataContract(IsReference = true)]
  public class RelationshipEntityInstanceData
  {
    [DataMember]
    public EntityInstance Source { get; set; }
    [DataMember]
    public EntityInstance Target { get; set; }
  }
}
