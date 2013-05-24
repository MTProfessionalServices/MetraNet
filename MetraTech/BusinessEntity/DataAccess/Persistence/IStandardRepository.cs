using System;
using System.Collections.Generic;
using Core.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.Core.Persistence;
using MetraTech.BusinessEntity.DataAccess.Metadata;

namespace MetraTech.BusinessEntity.DataAccess.Persistence
{
  #pragma warning disable 618
  /// <summary>
  /// </summary>
  public interface IStandardRepository : IRepository
  {
    #region EntityInstance Methods

    #region Create/Update
    /// <summary>
    /// </summary>
    /// <param name="instance"></param>
    EntityInstance SaveEntityInstance(EntityInstance instance);

    void SaveEntityInstanceVoid(EntityInstance instance);

    /// <summary>
    /// </summary>
    /// <param name="instances"></param>
    List<EntityInstance> SaveEntityInstances(List<EntityInstance> instances);

    /// <summary>
    ///   Save the specified EntityInstance for the given related type (forEntityName) and id (forEntityId).
    /// </summary>
    EntityInstance CreateEntityInstanceFor(string forEntityName, Guid forEntityId, EntityInstance instance);
    
    /// <summary>
    ///   Saves EntityInstances for the given related type (forEntityName) and id (forEntityId).
    /// </summary>
    IList<EntityInstance> CreateEntityInstancesFor(string forEntityName, Guid forEntityId, IList<EntityInstance> instances);

    void CreateEntityInstanceRelationships(List<RelationshipEntityInstanceData> relationshipEntityInstanceDataList);
    void DeleteEntityInstanceRelationships(List<RelationshipEntityInstanceData> relationshipEntityInstanceDataList);

    #endregion

    #region Load
    /// <summary>
    ///   Returns null if a row is not found matching the provided Id.
    /// </summary>
    /// <param name="id"></param>
    /// <param name="entityName"></param>
    /// <returns></returns>
    EntityInstance LoadEntityInstance(string entityName, Guid id);
    
    /// <summary>
    ///    Returns null if a row is not found matching the specified business key.
    ///    The specified businessKey must match the business key for the given entityName.
    /// </summary>
    /// <param name="entityName"></param>
    /// <param name="businessKeyProperties"></param>
    /// <returns></returns>
    EntityInstance LoadEntityInstanceByBusinessKey(string entityName, List<PropertyInstance> businessKeyProperties);

    /// <summary>
    ///   Returns all rows for the specified type.
    /// </summary>
    /// <param name="entityName"></param>
    /// <param name="mtList"></param>
    /// <returns></returns>
    MTList<EntityInstance> LoadEntityInstances(string entityName, MTList<EntityInstance> mtList);

    /// <summary>
    ///   Returns rows for the specified type with specified IDs.
    /// </summary>
    /// <param name="id"></param>
    /// <param name="entityName"></param>
    /// <returns></returns>
    MTList<EntityInstance> LoadEntityInstances(string entityName, Guid[] id);

    /// <summary>
    ///   Returns the row of type [entityName] for the given related type (forEntityName) and id (forEntityId).
    ///   typeName and forTypeName must have a one-to-one relationship
    /// </summary>
    EntityInstance LoadEntityInstanceFor(string entityName,
                                          string forEntityName,
                                          Guid forEntityId);

    /// <summary>
    ///   Returns rows of type [entityName] for the given related type (forEntityName) and id (forEntityId).
    /// </summary>
    MTList<EntityInstance> LoadEntityInstancesFor(string entityName,
                                                  string forEntityName,
                                                  Guid forEntityId,
                                                  MTList<EntityInstance> mtList,
                                                  String relationshipName = null,
                                                  bool related = true);

    /// <summary>
    /// 
    /// </summary>
    /// <param name="entityName"></param>
    /// <param name="mtList"></param>
    /// <param name="metranetEntity"></param>
    MTList<EntityInstance> LoadEntityInstancesForMetranetEntity(string entityName,
                                                                IMetranetEntity metranetEntity,
                                                                 MTList<EntityInstance> mtList);
    #endregion

    #region Delete
    /// <summary>
    ///    Delete the specified entityInstance. 
    ///    entityInstance must have a non-empty Id.
    /// </summary>
    /// <param name="entityInstance"></param>
    void DeleteEntityInstance(EntityInstance entityInstance);
    #endregion

    #endregion

    #region Instance Methods

    #region Create/Update
    /// <summary>
    ///   Create the specified dataObject or update it if it has a non-empty Id.
    /// </summary>
    /// <param name="dataObject"></param>
    DataObject SaveInstance(DataObject dataObject);
    void SaveInstance<T>(ref T dataObject) where T : DataObject;
    
    /// <summary>
    ///   
    /// </summary>
    List<DataObject> SaveInstances(List<DataObject> dataObjects);
    void SaveInstances<T>(ref List<T> dataObjects) where T : DataObject;

    /// <summary>
    ///   Saves the specified dataObject for the given related type (forEntityName) and id (forEntityId).
    /// </summary>
    DataObject CreateInstanceFor(string forEntityName, Guid forEntityId, DataObject dataObject);
    void CreateInstanceFor<TForEntity, TInstance>(Guid forEntityId, ref TInstance dataObject, string relationshipName = null)
      where TForEntity : DataObject
      where TInstance : DataObject;

    /// <summary>
    ///   Saves dataObjects for the given related type (forEntityName) and id (forEntityId).
    /// </summary>
    IList<DataObject> CreateInstancesFor(string forEntityName, Guid forEntityId, IList<DataObject> dataObjects);
    void CreateInstancesFor<TForEntity, TInstances>(Guid forEntityId, ref List<TInstances> dataObjects, string relationshipName = null)
      where TForEntity : DataObject
      where TInstances : DataObject;

    /// <summary>
    ///    Create the specified child for the given parentId. The entity must have a Self-Relationship
    /// </summary>
    /// <param name="parentId"></param>
    /// <param name="child"></param>
    /// <returns></returns>
    DataObject CreateChild(Guid parentId, DataObject child);

    /// <summary>
    ///   Create the specified children for the given parentId. The entity must have a Self-Relationship
    /// </summary>
    IList<DataObject> CreateChildren(Guid parentId, IList<DataObject> children);

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
    void CreateRelationship(DataObject source, DataObject target);

    void CreateRelationship<TSource, TTarget>(TSource source, TTarget target)
      where TSource : DataObject
      where TTarget : DataObject;

    void CreateRelationships(List<RelationshipInstanceData> relationshipInstanceDataList);
    #endregion

    #region Load
    /// <summary>
    ///   Returns null if a row is not found matching the provided Id.
    /// </summary>
    DataObject LoadInstance(string entityName, Guid id);
    T LoadInstance<T>(Guid id) where T : DataObject;

    /// <summary>
    ///    Returns null if a row is not found matching the specified business key.
    ///    The specified businessKey must match the business key for the given entityName.
    /// </summary>
    /// <param name="entityName"></param>
    /// <param name="businessKey"></param>
    /// <returns></returns>
    DataObject LoadInstanceByBusinessKey(string entityName, BusinessKey businessKey);
    TDataObject LoadInstanceByBusinessKey<TDataObject, TBusinessKey>(TBusinessKey businessKey) 
      where TDataObject : DataObject where TBusinessKey : BusinessKey;

    /// <summary>
    ///    Returns null if a row is not found matching the specified business key properties.
    /// </summary>
    /// <param name="entityName"></param>
    /// <param name="businessKeyProperties"></param>
    /// <returns></returns>
    DataObject LoadInstanceByBusinessKeyProperties(string entityName, List<PropertyInstance> businessKeyProperties);

    /// <summary>
    ///   Returns all rows for the specified type.
    /// </summary>
    MTList<DataObject> LoadInstances(string entityName, MTList<DataObject> mtList);
    void LoadInstances<T>(ref MTList<T> mtList) where T : DataObject;

    /// <summary>
    ///   Returns a row of type [entityName] for the given related type [forEntityName] and id [forEntityId]. 
    ///   [entityName] and [forEntityName] must have a One-To-One relationship.
    /// </summary>
    DataObject LoadInstanceFor(string entityName, string forEntityName, Guid forEntityId, string relationshipName = null);

    TInstance LoadInstanceFor<TForEntity, TInstance>(Guid forEntityId, string relationshipName = null)
      where TForEntity : DataObject
      where TInstance : DataObject;

    /// <summary>
    ///   Returns rows of type [entityName] for the given related type (forEntityName) and id (forEntityId).
    /// </summary>
    MTList<DataObject> LoadInstancesFor(string entityName, 
                                        string forEntityName, 
                                        Guid forEntityId,
                                        MTList<DataObject> mtList,
                                        string relationshipName = null,
                                        bool related = true);

    /// <summary>
    /// 
    /// </summary>
    /// <typeparam name="TForEntity"></typeparam>
    /// <typeparam name="TInstance"></typeparam>
    /// <param name="forEntityId"></param>
    /// <param name="mtList"></param>
    /// <param name="relationshipName"></param>
    /// <param name="related"></param>
    void LoadInstancesFor<TForEntity, TInstance>(Guid forEntityId, 
                                                 ref MTList<TInstance> mtList,
                                                 string relationshipName = null, 
                                                 bool related = true)
      where TForEntity : DataObject
      where TInstance : DataObject;

    /// <summary>
    /// 
    /// </summary>
    /// <typeparam name="TForEntity"></typeparam>
    /// <typeparam name="TInstance"></typeparam>
    /// <param name="forEntity"></param>
    /// <param name="mtList"></param>
    /// <param name="relationshipName"></param>
    /// <param name="related"></param>
    void LoadInstancesFor<TForEntity, TInstance>(TForEntity forEntity,
                                                 ref MTList<TInstance> mtList,
                                                 string relationshipName = null,
                                                 bool related = true)
      where TForEntity : DataObject
      where TInstance : DataObject;

    MTList<DataObject> LoadInstancesForMetranetEntity(string entityName,
                                                      IMetranetEntity metranetEntity,
                                                      MTList<DataObject> mtList);


    /// <summary>
    ///   Load the children for the given parentId. The parent entity must have a self relationship.
    /// </summary>
    /// <param name="parentEntityName"></param>
    /// <param name="parentId"></param>
    /// <param name="mtList"></param>
    /// <returns></returns>
    [Obsolete("Self-Relationships as they existed in vresion 6.2, have been removed.")]
    MTList<DataObject> LoadChildren(string parentEntityName, Guid parentId, MTList<DataObject> mtList);

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
    void LoadChildren<T>(Guid parentId, ref MTList<T> children, string relationshipName = null) where T : DataObject;

    /// <summary>
    ///    (1) Used to load parents that are represented via a foreign key to the parent in the same table (trees)
    ///    (2) Used to load parents that are represented via edges in a join table (graphs)
    /// 
    /// If there is more than one relationship (e.g. ManagedBy and PaidBy for accounts) a relationshipName must be specified.
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="childId"></param>
    /// <param name="parents"></param>
    /// <param name="relationshipName"></param>
    void LoadParents<T>(Guid childId, ref MTList<T> parents, string relationshipName = null) where T : DataObject;

    T LoadParent<T>(Guid childId, string relationshipName = null) where T : DataObject;

    /// <summary>
    ///   Prerequisite: Type T must have a property called 'Parent' and a property called 'Child'
    ///   Load the entity which has a Parent property with a value of parentId and a Child property of childId
    /// </summary>
    T LoadEdge<T>(Guid parentId, Guid childId) where T : DataObject;

    /// <summary>
    ///   Load the instance with the given Id with values that existed for the specified effectiveDate.
    ///   This will return null if any of the following is true:
    ///     - The specified entityName is not found
    ///     - The specified entityName has not been configured to record history.
    ///     - No history row is found with effectiveDate between start and end dates
    /// </summary>
    /// <param name="entityName"></param>
    /// <param name="id"></param>
    /// <param name="effectiveDate"></param>
    /// <returns></returns>
    DataObject LoadInstanceHistory(string entityName, Guid id, DateTime effectiveDate);
    T LoadInstanceHistory<T>(Guid id, DateTime effectiveDate) where T : DataObject;

    /// <summary>
    ///   Returns all history rows for the specified type. The returned DataObjects will be of
    ///   the corresponding history type. Hence, if the entityName is Training.SchoolSystem.Teacher,
    ///   the returned DataObjects will be of type Training.SchoolSystem.TeacherHistory.
    /// 
    ///   This will return null if any of the following is true:
    ///     - The specified entityName is not found
    ///     - The specified entityName has not been configured to record history.
    /// </summary>
    MTList<DataObject> LoadHistoryInstances(string entityName, MTList<DataObject> mtList);

    #endregion

    #region Delete

    void Delete<T>(Guid id) where T : DataObject;
    void Delete<T>(T instance) where T : DataObject;

    /// <summary>
    ///    Delete the specified dataObject. 
    ///    dataObject must have a non-empty Id.
    /// </summary>
    /// <param name="dataObject"></param>
    void DeleteInstance(DataObject dataObject);

    /// <summary>
    ///   If there is no direct relationship defined between source type and target type, return error.
    ///   If source or target have not been persisted, return error.
    /// 
    ///   If source and target have a relationship (i.e. a row in the relationship table)
    ///   delete the relationship, otherwise do nothing.
    /// </summary>
    /// <param name="source"></param>
    /// <param name="target"></param>
    void DeleteRelationship(DataObject source, DataObject target);

    void DeleteRelationships(List<RelationshipInstanceData> relationshipInstanceDataList);

    /// <summary>
    ///   If there is no direct relationship defined between source type and target type, return error.
    ///   Delete all relationships between sourceEntityName and targetEntityName
    /// </summary>
    /// <param name="sourceEntityName"></param>
    /// <param name="targetEntityName"></param>
    void DeleteAllRelationships(string sourceEntityName, string targetEntityName);

    #endregion

    #endregion

    /// <summary>
    ///   Delete all items of the specified type.
    /// </summary>
    /// <param name="entityName"></param>
    void Delete(string entityName);

    /// <summary>
    ///   Delete the item of the specified entityName with the specified id.
    /// </summary>
    /// <param name="entityName"></param>
    /// <param name="id"></param>
    void Delete(string entityName, Guid id);

    #region Methods for entities in Core.Common

    /// <summary>
    ///    Return a list of LocalizedEntry items for the specified localized entry key.
    /// </summary>
    /// <param name="localeKeys"></param>
    /// <param name="separator"></param>
    /// <returns></returns>
    List<LocalizedEntry> GetLocalizedEntries(string localeKeys, string separator);

    /// <summary>
    ///   Load all EntitySyncData
    /// </summary>
    /// <returns></returns>
    List<EntitySyncData> LoadEntitySyncData();

    /// <summary>
    ///   Save the specified entitySyncData
    /// </summary>
    /// <param name="entitySyncData"></param>
    void SaveEntitySyncData(EntitySyncData entitySyncData);

    /// <summary>
    ///   Return true, if the specified tableName exists and has atleast one row.
    /// </summary>
    /// <param name="databaseName"></param>
    /// <param name="tableName"></param>
    /// <returns></returns>
    bool TableHasRows(string databaseName, string tableName);

    /// <summary>
    ///   Return the table names from NetMeter. Ignore t_be and t_svc tables.
    /// </summary>
    /// <returns></returns>
    List<string> GetTableNames(string databaseName);

    /// <summary>
    ///   Return metadata for each column for the specified tables
    /// </summary>
    /// <returns></returns>
    List<DbColumnMetadata> GetColumnMetadata(string databaseName, List<string> tableNames);

    #endregion

    #region Misc

    // Cannot use ref parameter. 
    // Logged issue (No. 31) with LinFu: http://code.google.com/p/linfu/issues/list

    // void SaveOrUpdate<T>(ref T data);
    #endregion
  }
}
