using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using Core.Common;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.Core.Rule;
using MetraTech.BusinessEntity.DataAccess.Common;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Metadata.Graph;

namespace MetraTech.BusinessEntity.DataAccess.Persistence.Sync
{
  [Serializable]
  public class SyncData
  {
    #region Public Methods
    public SyncData(bool overwriteHbm = true)
    {
      OverwriteHbm = overwriteHbm;

      NewEntities = new List<Entity>();
      DeletedEntities = new List<Entity>();
      ModifiedEntities = new List<Entity>();

      NewInheritances = new List<InheritanceData>();
      DeletedInheritances = new List<InheritanceData>();

      NewComputedPropertyDataList = new List<ComputedPropertyData>();
      DeletedComputedPropertyDataList = new List<ComputedPropertyData>();

      RequiredAssemblies = new List<string>();

      EntityChangeSetList = new List<EntityChangeSet>();

      CapabilityEnumValues = new List<string>();

      NewAndModifiedEntitySyncDataList = new List<EntitySyncData>();
      DeletedEntitySyncDataList = new List<EntitySyncData>();
      NewAndModifiedEntitiesAndTheirConnections = new List<Entity>();

      CompoundEntitiesByTableName = new Dictionary<string, Entity>();
      Errors = new List<ErrorObject>();
    }
    
    public void Clear()
    {
      NewEntities.Clear();
      DeletedEntities.Clear();
      ModifiedEntities.Clear();
      NewComputedPropertyDataList.Clear();
      DeletedComputedPropertyDataList.Clear();
      RequiredAssemblies.Clear();
      EntityChangeSetList.Clear();
      CapabilityEnumValues.Clear();
      NewAndModifiedEntitySyncDataList.Clear();
      DeletedEntitySyncDataList.Clear();
      NewAndModifiedEntitiesAndTheirConnections.Clear();
      CompoundEntitiesByTableName.Clear();
    }

    #region Entity
    public void AddNewEntity(Entity entity)
    {
      Check.Require(entity != null, "entity cannot be null");

      Check.Require(!DeletedEntities.Contains(entity),
                    String.Format("Entity '{0}' has already been added to the delete list", entity.FullName));
      Check.Require(!ModifiedEntities.Contains(entity),
                    String.Format("Entity '{0}' has already been added to the modified list", entity.FullName));

      if (!NewEntities.Contains(entity))
      {
        NewEntities.Add(entity);
      }
    }

    public void AddDeletedEntity(Entity entity)
    {
      Check.Require(entity != null, "entity cannot be null", SystemConfig.CallerInfo);

      Check.Require(!NewEntities.Contains(entity),
                    String.Format("Entity '{0}' has already been added to the new list", entity.FullName));
      Check.Require(!ModifiedEntities.Contains(entity),
                    String.Format("Entity '{0}' has already been added to the modified list", entity.FullName));

      if (!DeletedEntities.Contains(entity))
      {
        DeletedEntities.Add(entity);
      }
    }

    public void AddModifiedEntity(Entity entity)
    {
      Check.Require(entity != null, "entity cannot be null", SystemConfig.CallerInfo);

      Check.Require(!NewEntities.Contains(entity),
                    String.Format("Entity '{0}' has already been added to the new list", entity.FullName));
      Check.Require(!DeletedEntities.Contains(entity),
                    String.Format("Entity '{0}' has already been added to the delete list", entity.FullName));

      if (!ModifiedEntities.Contains(entity))
      {
        ModifiedEntities.Add(entity);
      }
    }
    #endregion

    #region Relationship
    public void AddNewRelationship(RelationshipEntity relationshipEntity)
    {
      AddNewEntity(relationshipEntity);
    }

    internal void AddModifiedRelationship(RelationshipEntity relationshipEntity)
    {
      AddModifiedEntity(relationshipEntity);
    }

    public void AddDeletedRelationship(RelationshipEntity relationshipEntity)
    {
      AddDeletedEntity(relationshipEntity);
    }
    #endregion

    #region Inheritance
    public void AddNewInheritance(InheritanceData inheritanceData)
    {
      Check.Require(inheritanceData != null, "inheritanceData cannot be null");
      Check.Require(inheritanceData.ParentEntity != null, "ParentEntity cannot be null on InheritanceData");
      Check.Require(inheritanceData.DerivedEntity != null, "DerivedEntity cannot be null on InheritanceData");
      Check.Require(!DeletedInheritances.Contains(inheritanceData),
                    String.Format("InheritanceData '{0}' has already been added to the deleted list", inheritanceData));
      Check.Require(inheritanceData.DerivedEntity.FullName != inheritanceData.ParentEntity.FullName, 
                    String.Format("DerivedEntity cannot have the same name as the ParentEntity '{0}'", inheritanceData.DerivedEntity.FullName));

      Check.Require(inheritanceData.ParentEntity.ExtensionName.ToLower() == inheritanceData.DerivedEntity.ExtensionName.ToLower(),
                    String.Format("The extension '{0}' for ParentEntity '{1}' must match the extension '{2}' for DerivedEntity '{3}'",
                                  inheritanceData.ParentEntity.ExtensionName, inheritanceData.ParentEntity,
                                  inheritanceData.DerivedEntity.ExtensionName, inheritanceData.DerivedEntity));

      Check.Require(inheritanceData.ParentEntity.DatabaseName.ToLower() == inheritanceData.DerivedEntity.DatabaseName.ToLower(),
                    String.Format("The database '{0}' for ParentEntity '{1}' must match the database '{2}' for DerivedEntity '{3}'",
                                  inheritanceData.ParentEntity.DatabaseName, inheritanceData.ParentEntity,
                                  inheritanceData.DerivedEntity.DatabaseName, inheritanceData.DerivedEntity));

      Check.Require(inheritanceData.DerivedEntity.EntityType == EntityType.Entity ||
                    inheritanceData.DerivedEntity.EntityType == EntityType.Derived,
                    String.Format("Can only convert 'Entity' or 'Derived' to a Derived entity"));

      if (!NewInheritances.Contains(inheritanceData))
      {
        NewInheritances.Add(inheritanceData);
      }
    }
    #endregion

    #region ComputedProperty
    public void AddNewComputedPropertyData(ComputedPropertyData computedPropertyData)
    {
      Check.Require(computedPropertyData != null, "computedPropertyData cannot be null", SystemConfig.CallerInfo);
      Check.Require(!NewComputedPropertyDataList.Contains(computedPropertyData), 
                    String.Format("ComputedPropertyData '{0}' has already been added to the add list", computedPropertyData),
                    SystemConfig.CallerInfo);

      Check.Require(!DeletedComputedPropertyDataList.Contains(computedPropertyData),
                    String.Format("ComputedPropertyData '{0}' has already been added to the delete list", computedPropertyData),
                    SystemConfig.CallerInfo);

      NewComputedPropertyDataList.Add(computedPropertyData);
    }

    public void AddDeletedComputedPropertyData(ComputedPropertyData computedPropertyData)
    {
      Check.Require(computedPropertyData != null, "computedPropertyData cannot be null", SystemConfig.CallerInfo);
      Check.Require(!NewComputedPropertyDataList.Contains(computedPropertyData),
                    String.Format("ComputedPropertyData '{0}' has already been added to the add list", computedPropertyData),
                    SystemConfig.CallerInfo);
      Check.Require(!DeletedComputedPropertyDataList.Contains(computedPropertyData), 
                    String.Format("ComputedPropertyData '{0}' has already been added to the remove list", computedPropertyData),
                    SystemConfig.CallerInfo);

      DeletedComputedPropertyDataList.Remove(computedPropertyData);
    }
    #endregion

    #endregion

    #region Internal Properties

    internal List<Entity> NewEntities { get; set; }
    internal List<Entity> DeletedEntities { get; set; }
    internal List<Entity> ModifiedEntities { get; set; }

    internal List<InheritanceData> NewInheritances { get; set; }
    internal List<InheritanceData> DeletedInheritances { get; set; }

    internal List<ComputedPropertyData> NewComputedPropertyDataList { get; set; }
    internal List<ComputedPropertyData> DeletedComputedPropertyDataList { get; set; }

    internal List<string> RequiredAssemblies { get; set; }

    internal List<EntityChangeSet> EntityChangeSetList { get; set; }

    internal List<string> CapabilityEnumValues { get; set; }

    internal List<EntitySyncData> NewAndModifiedEntitySyncDataList { get; set; }
    internal List<EntitySyncData> DeletedEntitySyncDataList { get; set; }
    internal List<Entity> NewAndModifiedEntitiesAndTheirConnections { get; set; }

    internal EntityGraph EntityGraph { get; set; }
    internal InheritanceGraph InheritanceGraph { get; set; }
    internal BuildGraph BuildGraph { get; set; }

    /// <summary>
    ///   Initialized by SyncManager
    /// </summary>
    internal Dictionary<string, Dictionary<string, string>> LocalizationEntries { get; set; }

    internal Dictionary<string, Entity> CompoundEntitiesByTableName { get; set; }

    internal string Database { get; set; }

    internal List<ErrorObject> Errors { get; set; }

    internal bool OverwriteHbm { get; set; }

    #endregion

    #region Internal Methods
    /// <summary>
    ///    Return the maximum date time for all the hbm files.
    ///    If a hbm file does not exist, return DateTime.MaxValue
    /// </summary>
    /// <returns></returns>
    internal DateTime GetMaxHbmFileDateTime()
    {
      DateTime currentMaxDateTime = DateTime.MinValue;

      List<Entity> entities = GetNewAndModifiedAndDeletedEntities();
      foreach(Entity entity in entities)
      {
        string hbmFile = Name.GetHbmFileNameWithPath(entity.FullName);
        if (!File.Exists(hbmFile))
        {
          return DateTime.MaxValue;
        }

        var fileTime = File.GetLastWriteTime(hbmFile);
        currentMaxDateTime = fileTime > currentMaxDateTime ? fileTime : currentMaxDateTime;
      }

      return currentMaxDateTime;
    }

    internal void AddHistoryEntity(HistoryEntity historyEntity)
    {
      NewEntities.Add(historyEntity);
      EntityGraph.HistoryEntities.Add(historyEntity);
    }

    internal bool IsHistoryTable(string tableName)
    {
      return EntityGraph.IsHistoryTable(tableName);
    }

    internal bool HasEntities()
    {
      if (NewEntities.Count > 0 ||
          DeletedEntities.Count > 0 ||
          ModifiedEntities.Count > 0)
      {
        return true;
      }

      return false;
    }

    internal List<Entity> GetEntities(ChangeType changeType, EntityType entityType)
    {
      List<Entity> entities = null;

      if (changeType == ChangeType.New)
      {
        entities = NewEntities.FindAll(e => (entityType & e.EntityType) == e.EntityType);
      }
      else if (changeType == ChangeType.Modified)
      {
        entities = ModifiedEntities.FindAll(e => (entityType & e.EntityType) == e.EntityType);
      }
      else if (changeType == ChangeType.Deleted)
      {
        entities = DeletedEntities.FindAll(e => (entityType & e.EntityType) == e.EntityType);
      }

      Check.Ensure(entities != null);

      return entities;
    }

    internal bool HasDeletedRelationship(string entityName)
    {
      Entity entity = DeletedEntities.Find(e => e.FullName == entityName);
      return entity != null;
    }

    internal void RemoveFromNewEntities(List<Entity> entities)
    {
      entities.ForEach(e => NewEntities.RemoveAll(ne => ne.FullName == e.FullName));
    }

    internal void AddNewRelationshipsToGraph()
    {
      foreach(Entity entity in NewEntities)
      {
        var relationshipEntity = entity as RelationshipEntity;
        if (relationshipEntity == null) continue;

        EntityGraph.AddRelationship(relationshipEntity);
      }
    }

    internal bool HasEntity(string entityName)
    {
       if (NewEntities.Find(e => e.FullName == entityName) == null &&
           ModifiedEntities.Find(e => e.FullName == entityName) == null &&
           DeletedEntities.Find(e => e.FullName == entityName) == null)
       {
         return false;
       }

      return true;
    }

    internal bool EntityExists(string entityName)
    {
      if (EntityGraph.GetEntity(entityName) != null ||
          DeletedEntities.Find(e => e.FullName == entityName) != null)
      {
        return true;
      }

      return false;
    }

    internal void InitializeRequiredAssemblies()
    {
      // Get the new and modified entities with their connected components
      List<Entity> requiredEntities = GetNewAndModifiedEntities();
      requiredEntities.AddRange(EntityGraph.GetConnectedEntitiesWithRelationships(requiredEntities));

      // Populate syncData.RequiredAssemblies with a unique set of required assembly names 
      RequiredAssemblies.Clear();

      foreach (Entity entity in requiredEntities)
      {
        List<string> entityAssemblies =
          EntityGraph.GetRequiredAssemblies(entity.ExtensionName, entity.EntityGroupName);

        RequiredAssemblies.AddRange
          (entityAssemblies.Where(a => !RequiredAssemblies.Contains(a.ToLowerInvariant()))
                           .Select(a => a.ToLowerInvariant()));
      }
    }

    internal void InitializeLocalizationEntries(List<ExtensionData> extensionDataList)
    {

      LocalizationEntries = new Dictionary<string, Dictionary<string, string>>();

      foreach (ExtensionData extensionData in extensionDataList)
      {
        var Extension = extensionData.ExtensionName.Replace("MetraTech.", string.Empty);

        string localizationDir = SystemConfig.GetBusinessEntityLocalizationDir(Extension);
        if (!Directory.Exists(localizationDir))
        {
          logger.Warn(String.Format("Cannot find localization directory '{0}'", localizationDir));
          continue;
        }

        var files = new List<string>(Directory.GetFiles(localizationDir));

        foreach (EntityGroupData entityGroupData in extensionData.EntityGroupDataList)
        {
          List<Entity> entities = entityGroupData.SyncData.GetNewAndModifiedEntities();
          foreach (Entity entity in entities)
          {
            string localizationFilePrefix = Name.GetEntityLocalizationFilePrefix(entity.FullName);
            List<string> localizationFiles = files.FindAll(f => Path.GetFileName(f).StartsWith(localizationFilePrefix));

            if (localizationFiles.Count == 0) continue;

            foreach (string localizationFile in localizationFiles)
            {
              XElement root = XElement.Load(localizationFile);
              string languageCode = root.Element("language_code").Value.ToLower();

              Dictionary<string, string> localeNameValue;
              LocalizationEntries.TryGetValue(languageCode, out localeNameValue);
              if (localeNameValue == null)
              {
                localeNameValue = new Dictionary<string, string>();
                LocalizationEntries.Add(languageCode, localeNameValue);
              }

              var elements = root.Elements("locale_space").Elements("locale_entry");
              foreach (XElement localeEntry in elements)
              {
                if (String.IsNullOrEmpty(localeEntry.Element("Value").Value))
                {
                  continue;
                }
                localeNameValue.Add(localeEntry.Element("Name").Value, localeEntry.Element("Value").Value);
              }
            }
          }
        }
      }
    }

    internal void PrepareForSchemaUpdate(List<ExtensionData> extensionDataList)
    {
      // Get the connected entities
      GenerateNewAndModifiedEntitiesAndTheirConnections();

      EntityChangeSetList.Clear();

      // Get the modified entities
      List<Entity> modifiedEntities =
        NewAndModifiedEntitiesAndTheirConnections.SkipWhile(e => NewEntities.Contains(e)).ToList();

      // Get the table/column metadata
      Dictionary<string, DbTableMetadata> dbTableMetadataMap =
        RepositoryAccess.Instance.GetDbMetadata(Database, modifiedEntities.ConvertAll(e => e.TableName));

      // Sort modified entities according to their inheritance hierarchy
      // This allows the backup/restore of data (during schema update)
      // to handle parent entities before child entities. Otherwise we get a foreign key violation, if
      // we try enter data into a child table without the data being present in the parent table
      var sortedEntities = new List<Entity>();
      // Start with the non-relationships
      sortedEntities.AddRange(modifiedEntities.FindAll(e => e.EntityType != EntityType.Relationship));
      InheritanceGraph.SortByHierarchy(ref modifiedEntities);

      // Add the relationships - so that they are at the end
      sortedEntities.AddRange(modifiedEntities.FindAll(e => e.EntityType == EntityType.Relationship));

      // Sort by least dependent first (e.g. ARAccount will be before AccountNote)
      EntityGraph.SortByDependency(sortedEntities);

      // Create changesets for modified entities)););
      foreach (Entity entity in sortedEntities)
      {
        DbTableMetadata dbTableMetadata;
        dbTableMetadataMap.TryGetValue(entity.TableName.ToLowerInvariant(), out dbTableMetadata);
        
        // There won't be any tables during the first synchronization
        if (dbTableMetadata == null) continue;

        // No need to create a change set if there's no data
        if (dbTableMetadata.HasData)
        {
          Entity originalEntity = GetOriginalEntity(entity);
          Check.Require(originalEntity != null,
                        String.Format("Cannot find original version of modified entity '{0}'", entity.FullName));

          // Create the changeset based on the original entity and db metadata
          EntityChangeSet entityChangeSet = entity.CreateChangeSet(originalEntity, dbTableMetadata, Database);
          EntityChangeSetList.Add(entityChangeSet);
        }
        
      }

      // If an entity in the entity change set is marked for data backup only, mark the relationships for that entity
      // in the entity change set (if any) to be data backup
      foreach(EntityChangeSet entityChangeSet in EntityChangeSetList)
      {
        if (entityChangeSet.BackupOnly)
        {
          Entity entity = modifiedEntities.Find(e => e.FullName == entityChangeSet.EntityName);
          Check.Require(entity != null, String.Format("Cannot find entity '{0}' in modified entities", entityChangeSet.EntityName));

          if (entity.EntityType == EntityType.Entity || entity.EntityType == EntityType.Compound)
          {
            foreach(Relationship relationship in entity.Relationships)
            {
              EntityChangeSet relationshipEntityChangeSet =
                EntityChangeSetList.Find(ec => ec.EntityName == relationship.RelationshipEntity.FullName);

              if (relationshipEntityChangeSet != null)
              {
                relationshipEntityChangeSet.BackupOnly = true;
              }
            }
          }
        }
      }

      // Initialize the set of assemblies that will be required to create the NHibernate configuration 
      RequiredAssemblies.Clear();
      RequiredAssemblies.AddRange(MetadataRepository.Instance.GetAssembliesForBuildingSessionFactory());
      List<string> newAssemblies = NewEntities.ConvertAll(e => Name.GetEntityAssemblyName(e.FullName).ToLowerInvariant());
      newAssemblies.ForEach(s =>
                              {
                                if (!RequiredAssemblies.Contains(s))
                                {
                                  RequiredAssemblies.Add(s);
                                }
                              });

      // Remove the assemblies which don't exist in RMP\bin
      RequiredAssemblies.RemoveAll(s => !File.Exists(Path.Combine(SystemConfig.GetBinDir(), s + ".dll")));

      // Initialize localization entries
      InitializeLocalizationEntries(extensionDataList);

      // Generate EntitySyncData
      GenerateEntitySyncData(DateTime.Now.ToUniversalTime());

      // Initialize CompoundEntitiesByTableName
      CompoundEntitiesByTableName.Clear();
      List<Entity> entities = GetEntities(ChangeType.New, EntityType.Compound);
      entities.ForEach(e => CompoundEntitiesByTableName.Add(e.TableName.ToLower(), e));
      entities = GetEntities(ChangeType.Modified, EntityType.Compound);
      entities.ForEach(e => CompoundEntitiesByTableName.Add(e.TableName.ToLower(), e));
      entities = EntityGraph.GetEntities(false);
      entities.ForEach(e =>
                         {
                           if (e.EntityType == EntityType.Compound &&
                               !CompoundEntitiesByTableName.ContainsKey(e.TableName.ToLower()))
                           {
                             CompoundEntitiesByTableName.Add(e.TableName.ToLower(), e);
                           }
                         });
    }

    internal void UpdateMetadataRepository()
    {
      #region Update EntityGraph
      var deletedEntities = GetEntities(ChangeType.Deleted, EntityType.Entity | EntityType.Compound | EntityType.History | EntityType.SelfRelationship);
      foreach (Entity entity in deletedEntities)
      {
        MetadataRepository.Instance.DeleteEntity(entity);
      }

      var newEntities = GetEntities(ChangeType.New, EntityType.Entity | EntityType.Compound | EntityType.History | EntityType.SelfRelationship);
      foreach (Entity entity in newEntities)
      {
        entity.IsPersisted = true;
        Entity clone = entity.Clone();
        entity.Relationships.ForEach(r => clone.Relationships.Add(r));
        clone.EntitySyncData = NewAndModifiedEntitySyncDataList.Find(e => e.EntityName == entity.FullName);
        MetadataRepository.Instance.AddEntity(clone);
      }

      var modifiedEntities = GetEntities(ChangeType.Modified, EntityType.Entity | EntityType.Compound | EntityType.History | EntityType.SelfRelationship);
      foreach (Entity entity in modifiedEntities)
      {
        Entity clone = entity.Clone();
        entity.Relationships.ForEach(r => clone.Relationships.Add(r));
        clone.EntitySyncData = NewAndModifiedEntitySyncDataList.Find(e => e.EntityName == entity.FullName);
        MetadataRepository.Instance.ReplaceEntity(clone);
      }

      var deletedRelationships = GetEntities(ChangeType.Deleted, EntityType.Relationship);
      foreach (RelationshipEntity relationshipEntity in deletedRelationships)
      {
        MetadataRepository.Instance.DeleteRelationship(relationshipEntity);
      }

      var newRelationships = GetEntities(ChangeType.New, EntityType.Relationship);
      foreach (RelationshipEntity relationshipEntity in newRelationships)
      {
        relationshipEntity.IsPersisted = true;
        var clone = (RelationshipEntity)relationshipEntity.Clone();
        clone.EntitySyncData = NewAndModifiedEntitySyncDataList.Find(e => e.EntityName == relationshipEntity.FullName);

        MetadataRepository.Instance.AddRelationship(clone);
      }

      var modifiedRelationships = GetEntities(ChangeType.Modified, EntityType.Relationship);
      foreach (RelationshipEntity relationshipEntity in modifiedRelationships)
      {
        var clone = (RelationshipEntity)relationshipEntity.Clone();
        MetadataRepository.Instance.ReplaceRelationship(clone, true);
      }

      MetadataRepository.Instance.RenderEntityGraph();
      #endregion

      #region Update InheritanceGraph
      MetadataRepository.Instance.UpdateInheritanceGraph(InheritanceGraph);
      MetadataRepository.Instance.RenderInheritanceGraph();
      #endregion

      #region Update BuildGraph
      MetadataRepository.Instance.UpdateBuildGraph(BuildGraph);
      MetadataRepository.Instance.RenderBuildGraph();
      #endregion
    }

    internal List<string> GetNewAndModifiedAssemblyNames()
    {
      var assemblyNames = new List<string>();

      GetAssemblyNames(NewEntities, ref assemblyNames);
      GetAssemblyNames(ModifiedEntities, ref assemblyNames);

      return assemblyNames;
    }

    internal List<string> GetDeletedAssemblyNames()
    {
      var assemblyNames = new List<string>();

      GetAssemblyNames(DeletedEntities, ref assemblyNames);
   
      return assemblyNames;
    }

    internal void GetAssemblyNames(List<Entity>entities, ref List<string> assemblyNames)
    {
      foreach(Entity entity in entities)
      {
        string assemblyName = Name.GetEntityAssemblyName(entity.ExtensionName, entity.EntityGroupName) + ".dll";
        if (!assemblyNames.Contains(assemblyName.ToLower()))
        {
          assemblyNames.Add(assemblyName);
        }
      }
    }

    /// <summary>
    ///   Return the list of new/modified entities and new/modified relationships in one collection
    /// </summary>
    /// <returns></returns>
    internal List<Entity> GetNewAndModifiedEntities()
    {
      var entities = new List<Entity>();

      entities.AddRange(NewEntities);
      entities.AddRange(ModifiedEntities);

      return entities;
    }

    internal List<Entity> GetNewAndModifiedAndDeletedEntities()
    {
      var entities = new List<Entity>();

      entities.AddRange(GetNewAndModifiedEntities());
      entities.AddRange(DeletedEntities);

      return entities;
    }

    internal void GenerateNewAndModifiedEntitiesAndTheirConnections()
    {
      NewAndModifiedEntitiesAndTheirConnections.Clear();
      NewAndModifiedEntitiesAndTheirConnections.AddRange(NewEntities);
      NewAndModifiedEntitiesAndTheirConnections.AddRange(ModifiedEntities);

      foreach(Entity entity in ModifiedEntities)
      {
        // Add connections
        List<Entity> connectedEntities = GetConnectedEntities(entity);
        foreach(Entity connectedEntity in connectedEntities)
        {
          if (!NewAndModifiedEntitiesAndTheirConnections.Contains(connectedEntity))
          {
            NewAndModifiedEntitiesAndTheirConnections.Add(connectedEntity);
          }

          // Add history
          if (connectedEntity.HistoryEntity != null &&
              !NewAndModifiedEntitiesAndTheirConnections.Contains(connectedEntity.HistoryEntity))
          {
            NewAndModifiedEntitiesAndTheirConnections.Add(connectedEntity.HistoryEntity);
          }

          // Add self relationship
          if (connectedEntity.SelfRelationshipEntity != null &&
              !NewAndModifiedEntitiesAndTheirConnections.Contains(connectedEntity.SelfRelationshipEntity))
          {
            NewAndModifiedEntitiesAndTheirConnections.Add(connectedEntity.SelfRelationshipEntity);
          }
        }
      }
    }

    internal List<Entity> GetConnectedEntities(Entity entity)
    {
      // These return the entities connected by relationships
      List<Entity> entitiesConnectedByRelationship = EntityGraph.GetConnectedEntities(entity, true);

      // Find the entities connected by inheritance for each of the entities returned in the previous step
      // and the specified entity
      var entitiesConnectedByInheritance = new List<Entity>();
      entitiesConnectedByRelationship.ForEach(e => entitiesConnectedByInheritance.AddRange(InheritanceGraph.GetConnectedEntities(e)));
      entitiesConnectedByInheritance.AddRange(InheritanceGraph.GetConnectedEntities(entity));

      // Return the union
      return entitiesConnectedByRelationship.Union(entitiesConnectedByInheritance).ToList();
    }

    /// <summary>
    ///  Categorize the collections by EntityGroupData (by extension/entity group)
    /// </summary>
    /// <returns></returns>
    internal List<EntityGroupData> GetEntityGroupData()
    {
      var entityGroupDataList = new List<EntityGroupData>();

      CategorizeEntities(NewEntities, entityGroupDataList, ChangeType.New);
      CategorizeEntities(DeletedEntities, entityGroupDataList, ChangeType.Deleted);
      CategorizeEntities(ModifiedEntities, entityGroupDataList, ChangeType.Modified);

      CategorizeComputedProperties(NewComputedPropertyDataList, entityGroupDataList, ChangeType.New);
      CategorizeComputedProperties(DeletedComputedPropertyDataList, entityGroupDataList, ChangeType.Deleted);

      return entityGroupDataList;
    }

    internal void GetFileContents(out Dictionary<string, string> addedOrUpdatedCodeFiles,
                                  out Dictionary<string, string> addedOrUpdatedHbmFiles,
                                  out List<string> deletedCodeFiles,
                                  out List<string> deletedHbmFiles)
    {
      addedOrUpdatedCodeFiles = new Dictionary<string, string>();
      addedOrUpdatedHbmFiles = new Dictionary<string, string>();
      deletedCodeFiles = new List<string>();
      deletedHbmFiles = new List<string>();

      GetCodeFileAndHbmMappingFileContent(NewEntities, ref addedOrUpdatedCodeFiles, ref addedOrUpdatedHbmFiles);
      GetCodeFileAndHbmMappingFileContent(ModifiedEntities, ref addedOrUpdatedCodeFiles, ref addedOrUpdatedHbmFiles);
     
      deletedCodeFiles.AddRange(DeletedEntities.ConvertAll(e => Name.GetCodeFileName(e.FullName)));
      deletedHbmFiles.AddRange(DeletedEntities.ConvertAll(e => Name.GetHbmFileName(e.FullName)));
    }

    internal void GetInterfaceFileContents(ref Dictionary<string, string> addedOrUpdatedFiles,
                                           ref List<string> deletedFiles)
    {
      foreach (Entity entity in NewEntities)
      {
        if (entity.EntityType == EntityType.History || 
            entity.EntityType == EntityType.SelfRelationship ||
            (entity.EntityType == EntityType.Relationship && !((RelationshipEntity)entity).HasJoinTable)) continue;

        string fileContent = EntityInterfaceGenerator.GenerateCode(entity);
        Check.Require(!String.IsNullOrEmpty(fileContent),
                      String.Format("Failed to generate interface code for entity '{0}'", entity.FullName));
        addedOrUpdatedFiles.Add(Name.GetInterfaceCodeFileName(entity.FullName), fileContent);
      }

      foreach (Entity entity in ModifiedEntities)
      {
        if (entity.EntityType == EntityType.History || 
            entity.EntityType == EntityType.SelfRelationship ||
            (entity.EntityType == EntityType.Relationship && !((RelationshipEntity)entity).HasJoinTable)) continue;

        string fileContent = EntityInterfaceGenerator.GenerateCode(entity);
        Check.Require(!String.IsNullOrEmpty(fileContent),
                      String.Format("Failed to generate interface code for entity '{0}'", entity.FullName));
        addedOrUpdatedFiles.Add(Name.GetInterfaceCodeFileName(entity.FullName), fileContent);
      }

      foreach (Entity entity in DeletedEntities)
      {
        if (entity.EntityType == EntityType.History ||
            entity.EntityType == EntityType.SelfRelationship ||
            (entity.EntityType == EntityType.Relationship && !((RelationshipEntity)entity).HasJoinTable)) continue;

        deletedFiles.Add(Name.GetInterfaceCodeFileName(entity.FullName));
      }
    }

    internal void GetTempHbmMappingFileNames(out Dictionary<Entity, string> newHbmMappingFiles,
                                             out Dictionary<Entity, string> deletedHbmMappingFiles,
                                             out Dictionary<Entity, string> modifiedHbmMappingFiles)
    {
      newHbmMappingFiles = new Dictionary<Entity, string>();
      deletedHbmMappingFiles = new Dictionary<Entity, string>();
      modifiedHbmMappingFiles = new Dictionary<Entity, string>();

      foreach(Entity entity in NewEntities)
      {
        newHbmMappingFiles.Add(entity,
                               Path.Combine(Name.GetEntityTempDir(entity.FullName), Name.GetHbmFileName(entity.FullName)));
      }

      foreach (Entity entity in DeletedEntities)
      {
        deletedHbmMappingFiles.Add(entity, 
                                   Path.Combine(Name.GetEntityTempDir(entity.FullName), Name.GetHbmFileName(entity.FullName)));
      }

      foreach (Entity entity in ModifiedEntities)
      {
        modifiedHbmMappingFiles.Add(entity,
                                    Path.Combine(Name.GetEntityTempDir(entity.FullName), Name.GetHbmFileName(entity.FullName)));
      }
    }

    internal void GenerateEntitySyncData(DateTime currentUtc)
    {
      NewAndModifiedEntitySyncDataList.Clear();
      DeletedEntitySyncDataList.Clear();

      foreach (Entity entity in NewAndModifiedEntitiesAndTheirConnections)
      {
        // Skip RelationshipEntities which don't have join tables (new style)
        //Skip entities that are the same in delete entities, for deleting entities with relationship in one group
        if (entity is RelationshipEntity && !((RelationshipEntity)entity).HasJoinTable || DeletedEntities.Contains(entity))
        {
          continue;
        }

        EntitySyncData entitySyncData = null;

        Entity originalEntity = GetOriginalEntity(entity);
        if (originalEntity != null)
        {
          entitySyncData = originalEntity.EntitySyncData;
        }

        if (entitySyncData == null)
        {
          entitySyncData = new EntitySyncData();
          entitySyncData.EntityName = entity.FullName;
          entitySyncData.SyncDate = currentUtc;
        }

        string tempHbmFileNameWithPath = Name.GetTempHbmFileNameWithPath(entity.FullName);
        string hbmFileNameWithPath = Name.GetHbmFileNameWithPath(entity.FullName);

        if (File.Exists(tempHbmFileNameWithPath))
        {
          entitySyncData.HbmChecksum = DirectoryUtil.GetChecksum(tempHbmFileNameWithPath);
        }
        else if (File.Exists(hbmFileNameWithPath))
        {
          entitySyncData.HbmChecksum = DirectoryUtil.GetChecksum(hbmFileNameWithPath);
        }
        else
        {
          throw new MetadataException(String.Format("Cannot find file '{0}' or '{1}'", tempHbmFileNameWithPath, hbmFileNameWithPath));
        }

        NewAndModifiedEntitySyncDataList.Add(entitySyncData);
      }


      foreach (Entity entity in DeletedEntities)
      {
        Entity originalEntity = GetOriginalEntity(entity);
        if (originalEntity != null && originalEntity.EntitySyncData != null)
        {
          // Check.Require(originalEntity.EntitySyncData != null, 
          //               String.Format("Cannot find EntitySyncData for entity '{0}'", originalEntity));
          DeletedEntitySyncDataList.Add(originalEntity.EntitySyncData);
        }
      }
    }
   
    #endregion

    #region Private Methods
    private void CategorizeEntities(List<Entity> entities, 
                                    List<EntityGroupData> entityGroupDataList,
                                    ChangeType changeType)
    {
      foreach (Entity entity in entities)
      {
        EntityGroupData entityGroupData =
          entityGroupDataList.Find(e => e.Equals(entity.EntityGroupData));

        if (entityGroupData == null)
        {
          entityGroupData = new EntityGroupData(entity.ExtensionName, entity.EntityGroupName);
          entityGroupData.BuildGraph = BuildGraph;
          entityGroupDataList.Add(entityGroupData);
          entityGroupData.SyncData = new SyncData(OverwriteHbm);
        }

        if (changeType == ChangeType.New)
        {
          entityGroupData.SyncData.NewEntities.Add(entity);
        }
        else if (changeType == ChangeType.Modified)
        {
          entityGroupData.SyncData.ModifiedEntities.Add(entity);
        }
        else if (changeType == ChangeType.Deleted)
        {
          entityGroupData.SyncData.DeletedEntities.Add(entity);
        }
      }
    }

    private static void CategorizeComputedProperties(List<ComputedPropertyData> computedPropertyDataList,
                                                     List<EntityGroupData> entityGroupDataList,
                                                     ChangeType changeType)
    {
      foreach (ComputedPropertyData computedPropertyData in computedPropertyDataList)
      {
        EntityGroupData entityGroupData =
          entityGroupDataList.Find
            (e => e.ExtensionName.ToLower() == computedPropertyData.ExtensionName.ToLower() &&
                  e.EntityGroupName.ToLower() == computedPropertyData.EntityGroupName.ToLower());

        if (entityGroupData == null)
        {
          entityGroupData = 
            new EntityGroupData(computedPropertyData.ExtensionName, 
                                computedPropertyData.EntityGroupName);

          entityGroupDataList.Add(entityGroupData);
          entityGroupData.SyncData = new SyncData();
        }

        if (changeType == ChangeType.New)
        {
          entityGroupData.SyncData.AddNewComputedPropertyData(computedPropertyData);
        }
        else if (changeType == ChangeType.Deleted)
        {
          entityGroupData.SyncData.AddDeletedComputedPropertyData(computedPropertyData);
        }
        else
        {
          throw new SynchronizationException
            (String.Format("Invalid change type '{0}' specified for computed property '{1}'",
                           changeType, computedPropertyData));
        }
      }
    }

    private void GetCodeFileAndHbmMappingFileContent(List<Entity> entities, 
                                                     ref Dictionary<string, string> codeFileContents, 
                                                     ref Dictionary<string, string> hbmMappingFileContents)
    {

      foreach (Entity entity in entities)
      {
        // Do not create code for RelationshipEntity if there's no join table (new style)
        if (entity is RelationshipEntity && !((RelationshipEntity)entity).HasJoinTable)
        {
          continue;
        }

        codeFileContents.Add(Name.GetCodeFileName(entity.FullName), entity.GetCodeFileContent());
        hbmMappingFileContents.Add(Name.GetHbmFileName(entity.FullName), entity.GetHbmMappingFileContent(OverwriteHbm));
      }
    }

    private Entity GetOriginalEntity(Entity entity)
    {
      Entity originalEntity = null;

      if (entity.EntityType == EntityType.Entity ||
          entity.EntityType == EntityType.Compound ||
          entity.EntityType == EntityType.Relationship ||
          entity.EntityType == EntityType.Derived)
      {
        originalEntity = EntityGraph.GetEntity(entity.FullName);
      }
      else if (entity.EntityType == EntityType.History)
      {
        originalEntity = MetadataRepository.Instance.GetHistoryEntity(entity.FullName);
      }
      else if (entity.EntityType == EntityType.SelfRelationship)
      {
        throw new MetadataException(String.Format("Entity '{0}' is marked as a self-relationship. This feature is not supported", entity));
      }
      
      return originalEntity;
    }
    #endregion

    #region Data
    internal static ILog logger = LogManager.GetLogger("SyncData");
    #endregion
  }

  internal enum ChangeType
  {
    New,
    Modified,
    Deleted
  }
}
