using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Linq;
using Core.Common;

using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Config;
using MetraTech.BusinessEntity.Core.Exception;
using MetraTech.BusinessEntity.DataAccess.Common;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Metadata.Graph;
using MetraTech.Debug.Diagnostics;
using Microsoft.Build.BuildEngine;
using QuickGraph.Algorithms;
using QuickGraph.Serialization;

namespace MetraTech.BusinessEntity.DataAccess.Persistence
{
  public class MetadataRepository
  {
    readonly ParallelOptions parallelOptions = new ParallelOptions { MaxDegreeOfParallelism = 900 };

    #region Public Properties
    public static MetadataRepository Instance
    {
      get
      {
        return instance;
      }
    }
    #endregion

    #region Public Methods
    /// <summary>
    ///    Create a graph based on existingEntities and return the entities in the graph
    ///    that are connected to the specified entity.
    /// </summary>
    /// <param name="entity"></param>
    /// <param name="existingEntities"></param>
    /// <returns></returns>
    public List<Entity> GetConnectedEntities(Entity entity, List<Entity> existingEntities)
    {
      // Create a graph based on existingEntities
      EntityGraph graph = EntityGraph.GetEntityGraph(existingEntities);

      return graph.GetConnectedEntities(entity, false);
    }

    public Dictionary<int, List<RelationshipEntity>> GetAllPaths(string sourceEntityName, string targetEntityName)
    {
      return EntityGraph.GetAllPaths(sourceEntityName, targetEntityName);
    }

    /// <summary>
    ///    Return the entities connected to the specified entity. This will also return
    ///    the RelationshipEntity for each connection.
    /// </summary>
    public List<Entity> GetConnectedEntities(Entity entity)
    {
      return EntityGraph.GetConnectedEntities(entity, true);
    }

    public void InitializeFromFileSystemWithEntitySyncData()
    {
      InitializeFromFileSystem();

      IStandardRepository standardRepository = RepositoryAccess.Instance.GetRepository();
      List<EntitySyncData> entitySyncDataList = standardRepository.LoadEntitySyncData();

      foreach(EntitySyncData entitySyncData in entitySyncDataList)
      {
        Entity entity = GetEntity(entitySyncData.EntityName);
        if (entity != null)
        {
          entity.EntitySyncData = entitySyncData;
          continue;
        }

        entity = EntityGraph.HistoryEntities.Find(e => e.FullName == entitySyncData.EntityName);
        if (entity != null)
        {
          entity.EntitySyncData = entitySyncData;
          continue;
        }

        entity = SelfRelationshipEntities.Find(e => e.FullName == entitySyncData.EntityName);
        if (entity != null)
        {
          entity.EntitySyncData = entitySyncData;
          continue;
        }

        logger.Debug(String.Format("Cannot initialize EntitySyncData on entity '{0}' because it was not found", 
                                   entitySyncData.EntityName));
     
      }
    }

    public void Initialize()
    {
      using (var timer = new HighResolutionTimer("MetadataRepository Initialization"))
      {
        InitializeFromFileSystem();
      }
      

      using (var timer = new HighResolutionTimer("Localization Data Initialization"))
      {
        InitLocalizationData();
      }
    }

    public void InitializeFromFileSystem()
    {
      if (InitializedEntityGraph)
      {
        return;
      }

      logger.Debug("Initializing entities from file system");

      // Create the graphs
      EntityGraph = new EntityGraph();
      InheritanceGraph = new InheritanceGraph();
      BuildGraph = new BuildGraph();

      SelfRelationshipEntities.Clear();

      var errors = new List<ErrorObject>();
      Dictionary<string, List<string>> entityGroupsByExtension = SystemConfig.GetEntityGroupsByExtension();
      
      var entities = new List<Entity>();
      var relationshipEntities = new List<RelationshipEntity>();
      var selfRelationshipEntities = new List<SelfRelationshipEntity>();
      var historyEntities = new List<HistoryEntity>();

      // Get the EntitySyncData items from the database

      #region Create the vertices in EntityGraph

      foreach (var extensionName in entityGroupsByExtension.Keys)
      {
        List<string> entityGroupNames = entityGroupsByExtension[extensionName];
        foreach (var entityGroupName in entityGroupNames)
        {
          // Get the mapping files
          List<string> hbmFiles = GetHbmMappingFiles(extensionName, entityGroupName);
          //foreach (string hbmFile in hbmFiles)
          foreach(var hbmFile in hbmFiles)
          {
            // Store the relationship entities. They will be used to create the edges in both graphs.
            Entity entity;
            var fileErrors = Entity.GetEntity(hbmFile, out entity);
            if (fileErrors.Count > 0)
            {
              errors.AddRange(fileErrors);
              continue;
              //return;
            }

            // Create an AssemblyNode in the BuildGraph. We want to use the extension names and entity group names
            // from the entity because we care about case sensitivity
            BuildGraph.AddAssemblyNode(entity);

            // Set the EntitySyncData
            if (entity is RelationshipEntity)
            {
              relationshipEntities.Add(entity as RelationshipEntity);
              continue;
              //return;
            }
            
            if (entity is SelfRelationshipEntity)
            {
              selfRelationshipEntities.Add(entity as SelfRelationshipEntity);
              SelfRelationshipEntities.Add(entity);
              continue;
              //return;
            }

            if (entity is HistoryEntity)
            {
              historyEntities.Add(entity as HistoryEntity);
              continue;
              //return;
            }

            // Check that the entity has not already been created.
            if (EntityGraph.HasEntity(entity.FullName))
            {
              errors.Add(
                new ErrorObject(String.Format("An entity with the name '{0}' already exists", entity.FullName)));
              continue;
              //return;
            }

            var entityNode = new EntityNode() { Entity = entity };
            EntityGraph.AddVertex(entityNode);
            entities.Add(entity);
          }
        }
      }

      #endregion

      #region Create the edges in EntityGraph

      foreach (Entity entity in entities)
      {
        dynamic hbmItem = null;
        Type extensionType;

        if (entity.EntityType == EntityType.Derived)
        {
          Check.Require(entity.HbmJoinedSubclass != null,
                        String.Format("HbmJoinedSubclass cannot be null on derived entity '{0}'", entity));
          hbmItem = entity.HbmJoinedSubclass;
          extensionType = typeof (HbmJoinedSubclassExtension);
        }
        else if (entity.EntityType == EntityType.Entity || entity.EntityType == EntityType.Compound)
        {
          Check.Require(entity.HbmClass != null,
                        String.Format("HbmClass cannot be null on derived entity '{0}'", entity));
          hbmItem = entity.HbmClass;
          extensionType = typeof (HbmClassExtension);
        }
        else
        {
          throw new MetadataException
            (String.Format("Invalid entity '{0}' of type '{1}' found in the entities collection", entity,
                            entity.EntityType));
        }

        // Retrieve the relationships from the hbmItem. 
        // hbmItem will have two kinds of relationships
        //  - legacy : using the join table for all three relationship types
        //  - new    : using join table for only many-to-many

        // The legacy relationships will be returned as a List<string> where each item in the list is the name of the
        // other end of the relationship. For these verify that a RelationshipEntity exists.

        // The new kind of relationship will have all the metadata necessary to create a RelationshipEntity
        // The new relationships will be returned as List<RelationshipEntity>

        MethodInfo methodInfo = extensionType.GetMethod("GetRelationships");
        Check.Require(methodInfo != null,
                      String.Format("Cannot find 'GetRelationships' method on type '{0}'", extensionType.FullName));
        var parameters = new object[] {hbmItem, null};
        var entityRelationships = methodInfo.Invoke(null, parameters) as List<RelationshipEntity>;
        var entityLegacyRelationships = parameters[1] as List<string>;

        // For each new relationship, check that both ends are found in the graph
        foreach (RelationshipEntity relationshipEntity in entityRelationships)
        //Parallel.ForEach(entityRelationships, parallelOptions, relationshipEntity =>
        {
          var sourceEntity = EntityGraph.GetEntity(relationshipEntity.SourceEntityName);
          Check.Require(sourceEntity != null,
                        String.Format(
                          "Cannot find entity '{0}' for relationship '{1}' (obtained from metadata) in the entity graph",
                                       relationshipEntity.SourceEntityName, relationshipEntity));

          var targetEntity = EntityGraph.GetEntity(relationshipEntity.TargetEntityName);
          Check.Require(targetEntity != null,
                        String.Format(
                          "Cannot find entity '{0}' for relationship '{1}' (obtained from metadata) in the entity graph",
                                       relationshipEntity.TargetEntityName, relationshipEntity));

          // Check that both have a database and the database is the same for both
          Check.Require(!String.IsNullOrEmpty(sourceEntity.DatabaseName),
                        String.Format("Cannot find database name for entity '{0}'", sourceEntity));
          Check.Require(!String.IsNullOrEmpty(targetEntity.DatabaseName),
                        String.Format("Cannot find database name for entity '{0}'", targetEntity));

          Check.Require(sourceEntity.DatabaseName.ToLower() == targetEntity.DatabaseName.ToLower(),
                        String.Format(
                          "The database '{0}' for entity '{1}' does not match the database '{2}' on the related entity '{3}'",
                                      sourceEntity.DatabaseName, sourceEntity, targetEntity.DatabaseName, targetEntity));
          

          // Set the database on the relationship entity
          relationshipEntity.DatabaseName = sourceEntity.DatabaseName;

          // Add this relationshipEntity to relationshipEntities, if necessary
          if (!relationshipEntities.Contains(relationshipEntity))
          {
            relationshipEntities.Add(relationshipEntity);
          }
        };

        // For each legacy relationship, check that there's a RelationshipEntity in relationshipEntities
        // that corresponds to the two ends of the relationship
        //foreach (string entityName in entityLegacyRelationships)
        Parallel.ForEach(entityLegacyRelationships, parallelOptions, entityName =>
        {
          RelationshipEntity legacyRelationshipEntiy =
            relationshipEntities.Find(
              r => (r.SourceEntityName == entityName && r.TargetEntityName == entity.FullName) ||
                                           (r.SourceEntityName == entity.FullName && r.TargetEntityName == entityName));
          Check.Require(legacyRelationshipEntiy != null, 
                        String.Format(
                          "Cannot find legacy relationship with '{0}' and '{1}' as the source and target or vice versa",
                                      entityName, entity.FullName));
        });
      }

      foreach (RelationshipEntity relationshipEntity in relationshipEntities)      
      {
        // Add the graph edge
        EntityGraph.AddRelationship(relationshipEntity);

        Entity sourceEntity = EntityGraph.GetEntity(relationshipEntity.SourceEntityName);
        Entity targetEntity = EntityGraph.GetEntity(relationshipEntity.TargetEntityName);

        // Create the relationships
        var relationship = new Relationship(relationshipEntity, sourceEntity, targetEntity, sourceEntity.FullName);
        sourceEntity.Relationships.Add(relationship);

        // If it's a self-relationship and the source and target are the same, then don't add the relationship to the target
        if (!relationshipEntity.IsSelfRelationship || !relationshipEntity.HasSameSourceAndTarget)
        {
          relationship = new Relationship(relationshipEntity, sourceEntity, targetEntity, targetEntity.FullName);
          targetEntity.Relationships.Add(relationship);
        }
        
      }

      #endregion

      #region Setup SelfRelationships and History);)

      foreach (SelfRelationshipEntity selfRelationshipEntity in selfRelationshipEntities)
      //Parallel.ForEach(selfRelationshipEntities, parallelOptions, selfRelationshipEntity =>
      {
        EntityNode entityNode = EntityGraph.GetEntityNode(selfRelationshipEntity.EntityName);
        Check.Require(entityNode != null,
                      String.Format("Cannot find entity '{0}' for self-relationship '{1}' in graph",
                                    selfRelationshipEntity.EntityName, selfRelationshipEntity),
                      SystemConfig.CallerInfo);

        entityNode.Entity.SelfRelationshipEntity = selfRelationshipEntity;
      }

      foreach (HistoryEntity historyEntity in historyEntities)
      //Parallel.ForEach(historyEntities, parallelOptions, historyEntity =>
      {
        EntityNode entityNode = EntityGraph.GetEntityNode(historyEntity.EntityName);
        Check.Require(entityNode != null,
                      String.Format("Cannot find base entity '{0}' for history entity '{1}' in graph",
                                    historyEntity.EntityName, historyEntity),
                      SystemConfig.CallerInfo);

        entityNode.Entity.HistoryEntity = historyEntity;
        historyEntity.Entity = entityNode.Entity;
        EntityGraph.HistoryEntities.Add(historyEntity);
      }

      #endregion

      #region Initialize Inheritance Graph

      foreach (EntityNode entityNode in EntityGraph.Vertices)
      {
        if (entityNode.Entity.EntityType == EntityType.Derived)
        {
          Check.Require(!String.IsNullOrEmpty(entityNode.Entity.ParentEntityName), 
                        String.Format("Parent entity name must be specified for derived entity '{0}'", 
                                      entityNode.Entity.FullName));
          Entity parentEntity = EntityGraph.GetEntity(entityNode.Entity.ParentEntityName);
          Check.Require(parentEntity != null,
                        String.Format("Cannot find parent entity '{0}' for derived entity '{1}'",
                                      entityNode.Entity.ParentEntityName, entityNode.Entity.FullName));

          InheritanceGraph.AddInheritance(parentEntity, entityNode.Entity);

          // If the parent and derived are in different assemblies, add a dependency to the build graph
          BuildGraph.AddDependency(entityNode.Entity.FullName, parentEntity.FullName);
        }
      }

      #endregion


      // Check errors
      if (errors.Count > 0)
      {
        throw new MetadataException("Cannot initialize entity graph due to errors", errors);
      }

      #region Check for cycles in Graphs and Render

      // Check that the graph does not have any cycles
      List<string> loopEdges;
      if (EntityGraph.HasCycle(out loopEdges))
      {
        string message = String.Format("The entity graph has the following cycle. '{0}'",
                                       String.Join(", ", loopEdges.ToArray()));

        EntityGraph.Render(true);
        throw new MetadataException(message);
      }

      EntityGraph.Render();

      if (InheritanceGraph.HasCycle(out loopEdges))
      {
        string message = String.Format("The inheritance graph has the following cycle. '{0}'",
                                       String.Join(", ", loopEdges.ToArray()));

        InheritanceGraph.Render(true);
        throw new MetadataException(message);
      }

      // Fix up roots
      InheritanceGraph.FixupRoot();
      InheritanceGraph.Render();

      if (BuildGraph.HasCycle(out loopEdges))
      {
        string message = String.Format("The build graph has the following cycle. '{0}'",
                                       String.Join(", ", loopEdges.ToArray()));

        BuildGraph.Render(true);
        throw new MetadataException(message);
      }

      BuildGraph.Render();

      #endregion

      InitializedEntityGraph = true;
    }

    public void InitializeFromCache()
    {
      throw new NotSupportedException("InitializeFromCache is no longer supported");
    }

    public void RenderEntityGraph()
    {
      EntityGraph.Render();
    }

    public void RenderInheritanceGraph()
    {
      InheritanceGraph.Render();
    }

    public void RenderBuildGraph()
    {
      BuildGraph.Render();
    }

    public void DeleteCacheFile()
    {
      string cacheFile = Name.GetEntityGraphCacheFileName();

      try
      {
        if (File.Exists(cacheFile))
        {
          File.Delete(cacheFile);
        }
        else
        {
          logger.Warn(String.Format("Cannot find cache file '{0}'", cacheFile));
        }
      }
      catch (System.Exception e)
      {
        throw new MetadataException(String.Format("Cannot delete cache file '{0}'", cacheFile), e);
      }
      
    }

    public void SaveGraph()
    {
      string cacheFile = Name.GetEntityGraphCacheFileName();
      try
      {
        using (FileStream fileStream = new FileStream(cacheFile, FileMode.Create))
        {
          SerializationExtensions.SerializeToBinary(EntityGraph, fileStream);
        }
      }
      catch (System.Exception e)
      {
        throw new MetadataException("Cannot save entity graph to file '{0}'", e);
      }
    }

    public void InitLocalizationData()
    {
      if (InitializedLocalizationData)
      {
        return;
      }

      // Get the localization keys from the localization xml files
      List<string> localizationKeys = GetLocalizationKeys();

      List<Entity> entities = GetEntities();
      ICollection<EnumType> enumTypes = new HashSet<EnumType>();

      // Get the enum type names (will check for duplicates)
      entities.AsParallel().ForEach(e => e.GetEnumTypes(ref enumTypes));

      // Convert enum types to localization keys
      enumTypes.AsParallel().ForEach(e => localizationKeys.AddRange(e.GetLocalizationKeys()));

      IStandardRepository repository = RepositoryAccess.Instance.GetRepository();
      var localizedEntries = new List<LocalizedEntry>();

      int batchSize = 100;

      int numBatches = localizationKeys.Count / batchSize;
      
      string separator = "<~>";

      if (numBatches == 0)
      {
        localizedEntries.AddRange(repository.GetLocalizedEntries(String.Join(separator, localizationKeys.ToArray()), separator));
      }
      else
      {
        int i;
        List<string> batch;

        for (i = 0; i < numBatches; i++)
        {
          batch = localizationKeys.GetRange(i * batchSize, batchSize);
          localizedEntries.AddRange(repository.GetLocalizedEntries(String.Join(separator, batch.ToArray()), separator));
        }

        // remainder
        int remainder = localizationKeys.Count % batchSize;
        if (remainder > 0)
        {
          batch = localizationKeys.GetRange(i*batchSize, remainder);
          localizedEntries.AddRange(repository.GetLocalizedEntries(String.Join(separator, batch.ToArray()), separator));
        }
      }

      Parallel.ForEach(entities, parallelOptions, e => e.InitLocalizationData(localizedEntries));
      EntityGraph.HistoryEntities.AsParallel().ForEach(h => h.InitLocalizationData(localizedEntries));

      InitializedLocalizationData = true;
    }

    public void GetChildEntitiesAndRelationships(string entityName, 
                                                 bool includeSelf,
                                                 out List<Entity> childEntities,
                                                 out List<RelationshipEntity> relationshipEntities)
    {
      EntityGraph.GetChildEntitiesAndRelationships(entityName, includeSelf, out childEntities, out relationshipEntities);
    }

    public RelationshipEntity CreateRelationship(RelationshipData relationshipData)
    {
      var errors = new List<ErrorObject>();

      Check.Require(relationshipData.Source != null, "sourceEntity cannot be null", SystemConfig.CallerInfo);
      Check.Require(relationshipData.Target != null, "targetEntity cannot be null", SystemConfig.CallerInfo);

      #region Validation

      //if (!relationshipData.SourceAndTargetInSameEntityGroup)
      //{
      //  string message =
      //    String.Format("Cannot create a relationship between entity '{0}' " +
      //                  "and entity '{1}' because they are in different extensions or entity groups.",
      //                  relationshipData.Source, relationshipData.Target);

      //  throw new MetadataException(message);
      //}

      if (EntityGraph.AreRelated(relationshipData.Source.FullName, relationshipData.Target.FullName))
      {
        string message = String.Format("A relationship already exists between entity '{0}' and entity '{1}'",
                                        relationshipData.Source.FullName, relationshipData.Target.FullName);
        throw new MetadataException(message);
      }

      #region Validate the two entities
      List<ErrorObject> validationErrors;
      if (!relationshipData.Source.Validate(out validationErrors))
      {
        errors.AddRange(validationErrors);
      }

      if (!relationshipData.Target.Validate(out validationErrors))
      {
        errors.AddRange(validationErrors);
      }

      if (errors.Count > 0)
      {
        throw new MetadataException("Failed to validate relationship entities", errors);
      }
      #endregion

      #endregion

      var relationshipEntity = new RelationshipEntity(relationshipData);

      #region Update the graph
      bool addedSource = false;
      bool addedTarget = false;

      EntityNode sourceEntityNode = EntityGraph.GetEntityNode(relationshipData.Source.FullName);
      if (sourceEntityNode == null)
      {
        sourceEntityNode = new EntityNode() { Entity = relationshipData.Source};
        EntityGraph.AddVertex(sourceEntityNode);
        addedSource = true;
      }

      EntityNode targetEntityNode = EntityGraph.GetEntityNode(relationshipData.Target.FullName);
      if (targetEntityNode == null)
      {
        targetEntityNode = new EntityNode() { Entity = relationshipData.Target};
        EntityGraph.AddVertex(targetEntityNode);
        addedTarget = true;
      }

      EntityGraph.AddRelationship(relationshipEntity);
     
      // Check that we don't have a cycle
      List<string> loopEdges;
      if (EntityGraph.HasCycle(out loopEdges))
      {
        // Render the graph 
        EntityGraph.Render(true);

        // Remove the sourceEntity, if it was added
        if (addedSource)
        {
          EntityGraph.RemoveVertex(sourceEntityNode);
        }
        // Remove the targetEntity, it it was added
        if (addedTarget)
        {
          EntityGraph.RemoveVertex(targetEntityNode);
        }

        // Remove the edge
        EntityGraph.DeleteRelationship(relationshipEntity);

        string message = String.Format("Cannot create a relationship between entity '{0}' and entity '{1}' " +
                                       "because it would create a cycle in the entity graph: '{2}'",
                                       relationshipData.Source.FullName,
                                       relationshipData.Target.FullName, 
                                       String.Join(", ", loopEdges.ToArray()));

        throw new MetadataException(message);
      }
      
  
      #endregion

      relationshipData.Source.Relationships.Add(new Relationship(relationshipEntity, relationshipData.Source, relationshipData.Target, relationshipData.Source.FullName));
      relationshipData.Target.Relationships.Add(new Relationship(relationshipEntity, relationshipData.Source, relationshipData.Target, relationshipData.Target.FullName));

      return relationshipEntity;
    }

    public List<RelationshipEntity> GetCascadeRelationships(string entityName)
    {
      return EntityGraph.GetCascadeRelationships(entityName);
    }

    public List<RelatedEntity> GetTargetEntities(string entityName, bool showRelationSource = false)
    {
      var relatedEntities = new List<RelatedEntity>();

      EntityNode entityNode = EntityGraph.GetEntityNode(entityName);
      if (entityNode == null)
      {
        return relatedEntities;
      }

      IEnumerable<RelationshipEdge> relationshipEdges = EntityGraph.OutEdges(entityNode);

      foreach(RelationshipEdge relationshipEdge in relationshipEdges)
      {
        var relatedEntity =
          new RelatedEntity()
            {
              Entity = relationshipEdge.Target.Entity,
              Multiplicity = relationshipEdge.RelationshipEntity.TargetMultiplicity,
              PropertyName = relationshipEdge.RelationshipEntity.TargetPropertyNameForSource
            };

        relatedEntities.Add(relatedEntity);
      }

      if (showRelationSource)
      {
        relationshipEdges = EntityGraph.InEdges(entityNode);
        foreach (RelationshipEdge relationshipEdge in relationshipEdges)
        {
          //if (relationshipEdge.RelationshipEntity.RelationshipType == RelationshipType.ManyToMany ||
          //  relationshipEdge.RelationshipEntity.RelationshipType == RelationshipType.OneToMany)
          //{
            var relatedEntity = new RelatedEntity()
            {
              Entity = relationshipEdge.Source.Entity,
              Multiplicity = relationshipEdge.RelationshipEntity.SourceMultiplicity,
              PropertyName = relationshipEdge.RelationshipEntity.SourcePropertyNameForTarget
            };

            relatedEntities.Add(relatedEntity);
          //}
          }
      }
      
      return relatedEntities;
    }

    public List<string> GetRequiredAssemblies(string extensionName, string entityGroupName)
    {
      return EntityGraph.GetRequiredAssemblies(extensionName, entityGroupName);
    }

    /// <summary>
    ///   
    /// </summary>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    /// <returns></returns>
    public List<string> GetBuildDependencies(string extensionName, string entityGroupName)
    {
      return EntityGraph.GetBuildDependencies(extensionName, entityGroupName);
    }

    public RelationshipEntity DeleteRelationship(ref Entity entity1, ref Entity entity2)
    {
      Check.Require(entity1 != null, "entity1 cannot be null", SystemConfig.CallerInfo);
      Check.Require(entity2 != null, "entity2 cannot be null", SystemConfig.CallerInfo);

      RelationshipEntity deleteRelationshipEntity = null;

      try
      {
        RelationshipEdge deleteRelationshipEdge = EntityGraph.GetRelationshipEdge(entity1.FullName, entity2.FullName);
        if (deleteRelationshipEdge == null)
        {
          logger.Warn(String.Format("Cannot delete a relationship between entity '{0}' and entity '{1}' " +
                                    "because there is no relationship between the two.",
                                    entity1.FullName, entity2.FullName));

          return deleteRelationshipEntity;
        }

        Entity sourceEntity = null;
        Entity targetEntity = null;

        if (deleteRelationshipEdge.RelationshipEntity.SourceEntityName == entity1.FullName)
        {
          sourceEntity = entity1;
          targetEntity = entity2;
        }
        else
        {
          sourceEntity = entity2;
          targetEntity = entity1;
        }

        sourceEntity.Relationships.RemoveAll(r => r.RelationshipEntity.TargetEntityName == targetEntity.FullName);
        targetEntity.Relationships.RemoveAll(r => r.RelationshipEntity.SourceEntityName == sourceEntity.FullName);

        // Return the RelationshipEntity that needs to be deleted
        deleteRelationshipEntity = deleteRelationshipEdge.RelationshipEntity;

        // Delete the relationship edge from the graph
        EntityGraph.RemoveEdge(deleteRelationshipEdge);
      }
      catch (System.Exception e)
      {
        throw new MetadataException
          (String.Format("Cannot delete relationship between '{0}' and '{1}'", entity1.FullName, entity2.FullName), e);
      }

      return deleteRelationshipEntity;
    }

    public bool HasEntity(string entityName)
    {
      return GetEntity(entityName) != null;
    }

    public Entity GetEntity(string entityName)
    {
      Entity entity = EntityGraph.GetEntity(entityName);
      if (entity == null)
      {
        entity = EntityGraph.HistoryEntities.Find(h => h.FullName == entityName);
        if (entity == null)
        {
          entity = SelfRelationshipEntities.Find(s => s.FullName == entityName);
        }
      }

      return entity;
    }

    public Entity GetEntityByTableName(string tableName)
    {
      Entity entity = EntityGraph.GetEntityByTableName(tableName);
      if (entity == null)
      {
        entity = EntityGraph.HistoryEntities.Find(h => h.TableName.ToLower() == tableName.ToLower());
        if (entity == null)
        {
          entity = SelfRelationshipEntities.Find(s => s.TableName.ToLower() == tableName.ToLower());
        }
      }

      return entity;
    }

    public List<Entity> GetEntities()
    {
      return GetEntities(false);
    }

    public List<Entity> GetEntities(bool includeRelationshipEntities)
    {
      return EntityGraph.GetEntities(includeRelationshipEntities);
    }

    public List<Entity> GetEntities(string extensionName, bool includeRelationshipEntities)
    {
      return EntityGraph.GetEntities(extensionName, includeRelationshipEntities);
    }

    public List<Entity> GetEntities(string extensionName, string entityGroupName, bool includeRelationshipEntities)
    {
      return EntityGraph.GetEntities(extensionName, entityGroupName, includeRelationshipEntities);
    }

    /// <summary>
    ///    If there is a relationship between entityName1 and entityName2, return the RelationshipEntity
    ///    that represents that relationship. Otherwise, return null
    /// </summary>
    /// <param name="entityName1"></param>
    /// <param name="entityName2"></param>
    /// <param name="relationshipName"></param>
    /// <returns></returns>
    public RelationshipEntity GetRelationshipEntity(string entityName1, string entityName2, string relationshipName = null)
    {
      RelationshipEntity relationshipEntity = null;

      RelationshipEdge relationshipEdge = EntityGraph.GetRelationshipEdge(entityName1, entityName2);
      if (relationshipEdge != null)
      {
        
        relationshipEntity = 
          String.IsNullOrEmpty(relationshipName) ? 
          relationshipEdge.RelationshipEntity : 
          relationshipEdge.GetRelationshipEntity(relationshipName);
      }

      if (relationshipEdge == null && entityName1 == entityName2)
      {
        relationshipEntity =
          String.IsNullOrEmpty(relationshipName)
            ? EntityGraph.SelfRelationships.Find(r => r.SourceEntityName == entityName1 && r.IsDefault)
            : EntityGraph.SelfRelationships.Find(r => r.SourceEntityName == entityName1 && r.RelationshipName == relationshipName);
      }

      return relationshipEntity;
    }

    public bool HasRelationshipName(string entityName, string relationshipName)
    {
      Entity entity = GetEntity(entityName);
      if (entity == null) return false;
      return entity.HasRelationship(relationshipName);
    }

    public bool IsEntityNameUnique(string entityName)
    {
      if (EntityGraph.HasPersistedEntity(entityName))
      {
        return false;
      }

      return true;
    }

    public bool AreRelated(string entityName1, string entityName2)
    {
      return EntityGraph.AreRelated(entityName1, entityName2);
    }

    public string GetTableName(string entityName)
    {
      Entity entity = GetEntity(entityName);
      Check.Require(entity != null, String.Format("Cannot find entity with name '{0}'", entityName));
      return entity.TableName;
    }

    public string GetColumnName(string entityName, string propertyName)
    {
      Entity entity = GetEntity(entityName);
      Check.Require(entity != null, String.Format("Cannot find entity with name '{0}'", entityName));

      Property property = entity[propertyName];
      Check.Require(property != null, String.Format("Cannot find property '{0}' for entity '{1}'", propertyName, entityName));

      return property.ColumnName;
    }

    public bool CheckCycles(List<RelationshipEntity> newRelationshipEntities, out List<string> loopEdges)
    {
      return EntityGraph.CheckCycles(newRelationshipEntities, out loopEdges);
    }

    public List<Entity> GetRelationshipCandidates(Entity sourceEntity, List<Entity> currentEntities)
    {
      EntityGraph entityGraph = EntityGraph.GetEntityGraph(currentEntities);
      return entityGraph.GetRelationshipCandidates(sourceEntity, currentEntities);
    }

    public List<Entity> GetParentCandidates(Entity sourceEntity, List<Entity> currentEntities)
    {
      Check.Require(sourceEntity != null, "sourceEntity cannot be null");
      Check.Require(currentEntities != null, "currentEntities cannot be null");

      var parentCandidates = new List<Entity>();

      // Nothing to return, if the sourceEntity is already a subclass
      if (sourceEntity.EntityType == EntityType.Derived)
      {
        return parentCandidates;
      }

      // Restrict entities by extension and database and entity type
      var entities = 
        currentEntities.FindAll(e => e.ExtensionName.ToLower() == sourceEntity.ExtensionName.ToLower() &&
                                     e.DatabaseName.ToLower() == sourceEntity.DatabaseName.ToLower() &&
                                     (e.EntityType == EntityType.Entity || e.EntityType == EntityType.Derived));

      // Eliminate entities which belong to entity groups that depend on the entity group of the sourceEntity
      
      return entities;
    }

    public List<RelationshipEntity> GetRelationshipEntities(string entityName)
    {
      return EntityGraph.GetRelationshipEntities(entityName);
    }

    public List<RelationshipEdge> GetOutgoingRelationshipEdges(string entityName)
    {
      var relationshipEdges = new List<RelationshipEdge>();
      EntityNode entityNode = EntityGraph.GetEntityNode(entityName);
      if (entityNode != null)
      {
        relationshipEdges.AddRange(EntityGraph.OutEdges(entityNode));
      }
      return relationshipEdges;
    }

    public void PerformTopologicalSort(List<Entity> entities)
    {
      EntityGraph.SortByDependency(entities);
    }

    public void PerformReverseTopologicalSort(List<Entity> entities)
    {
      EntityGraph.OrderForDroppingTables(entities);
    }
    #endregion

    #region Internal Methods
    internal List<string> GetAssembliesForBuildingSessionFactory()
    {
      return EntityGraph.GetAssembliesForBuildingSessionFactory();
    }

    internal void AddEntity(Entity entity)
    {
      if (entity.EntityType == EntityType.History)
      {
        ReplaceEntity(entity);
      }
      else if (entity.EntityType == EntityType.SelfRelationship)
      {
        ReplaceEntity(entity);
      }
      else if (entity.EntityType == EntityType.Entity || entity.EntityType == EntityType.Compound)
      {
        EntityGraph.AddEntity(entity);
      }
      else
      {
        logger.Error(String.Format("Entity '{0}' cannot be added to metadata repository", entity));
      }
    }

    internal void AddRelationship(RelationshipEntity relationshipEntity)
    {
      EntityGraph.AddRelationship(relationshipEntity);
    }

    internal void DeleteEntity(Entity entity)
    {
      if (entity.EntityType == EntityType.History)
      {
        EntityGraph.HistoryEntities.Remove(entity as HistoryEntity);
      }
      else if (entity.EntityType == EntityType.SelfRelationship)
      {
        SelfRelationshipEntities.Remove(entity);
      }
      else if (entity.EntityType == EntityType.Entity || entity.EntityType == EntityType.Compound)
      {
        EntityGraph.DeleteEntity(entity.FullName);
      }
      else
      {
        logger.Error(String.Format("Entity '{0}' cannot be deleted from metadata repository", entity));
      }
    }

    internal bool DeleteRelationship(RelationshipEntity relationshipEntity)
    {
      return EntityGraph.DeleteRelationship(relationshipEntity);
    }

    internal void ReplaceEntity(Entity entity)
    {
      if (entity.EntityType == EntityType.History)
      {
        if (EntityGraph.HistoryEntities.Contains(entity))
        {
          EntityGraph.HistoryEntities.Remove((HistoryEntity)entity);
        }

        EntityGraph.HistoryEntities.Add((HistoryEntity)entity);
      }
      else if (entity.EntityType == EntityType.SelfRelationship)
      {
        if (SelfRelationshipEntities.Contains(entity))
        {
          SelfRelationshipEntities.Remove(entity);
        }

        SelfRelationshipEntities.Add(entity);
      }
      else if (entity.EntityType == EntityType.Entity || entity.EntityType == EntityType.Compound)
      {
        EntityGraph.ReplaceEntity(entity);
      }
      else
      {
        logger.Error(String.Format("Entity '{0}' cannot be replaced in metadata repository", entity));
      }
    }

    internal void ReplaceRelationship(RelationshipEntity relationshipEntity)
    {
      ReplaceRelationship(relationshipEntity, false);
    }

    internal void ReplaceRelationship(RelationshipEntity relationshipEntity, bool throwIfNotFound)
    {
      EntityGraph.ReplaceRelationship(relationshipEntity, throwIfNotFound);
    }

    internal EntityGraph GetEntityGraphClone()
    {
      return EntityGraph.Clone();
    }

    internal InheritanceGraph GetInheritanceGraphClone()
    {
      return InheritanceGraph.Clone();
    }

    internal BuildGraph GetBuildGraphClone()
    {
      return BuildGraph.Clone();
    }

    internal Entity GetHistoryEntity(string entityName)
    {
      return EntityGraph.HistoryEntities.Find(e => e.FullName == entityName);
    }

    internal List<RelationshipEntity> GetSelfRelationshipEntities(string entityName, string relationshipName = null)
    {
      var relationshipEntities = new List<RelationshipEntity>();
      if (!String.IsNullOrEmpty(relationshipName))
      {
        relationshipEntities.AddRange(EntityGraph.SelfRelationships.FindAll(r => r.SourceEntityName == entityName && r.RelationshipName == relationshipName));
      }
      else
      {
        relationshipEntities.AddRange(EntityGraph.SelfRelationships.FindAll(r => r.SourceEntityName == entityName));
      }

      return relationshipEntities;
    }

    internal void UpdateBuildGraph(BuildGraph buildGraph)
    {
      BuildGraph.CopyFrom(buildGraph);
    }

    internal void UpdateInheritanceGraph(InheritanceGraph inheritanceGraph)
    {
      InheritanceGraph.CopyFrom(inheritanceGraph);
    }

    /// <summary>
    ///   Return all the entity tables names (including history and self-relationship)
    ///   in the correct order such that they can be dropped sequentially
    /// </summary>
    /// <returns></returns>
    internal List<string> GetTablesNamesInDropOrder(string databaseName, string extensionName)
    {
      EntityGraph entityGraph = 
        String.IsNullOrEmpty(extensionName) ? 
        EntityGraph.RestrictByDb(databaseName) : 
        EntityGraph.RestrictByDbAndExtension(databaseName, extensionName);

      // First relationships
      List<Entity> entities =
        String.IsNullOrEmpty(extensionName) ? 
        EntityGraph.GetJoinTableRelationshipEntities() :
        EntityGraph.GetJoinTableRelationshipEntitiesForExtension(extensionName);
      
      // Next self-relationships
      List<Entity> selfRelationships =
        String.IsNullOrEmpty(extensionName)
        ? SelfRelationshipEntities.FindAll(h => h.DatabaseName.ToLower() == databaseName.ToLower())
        : SelfRelationshipEntities.FindAll(h => h.DatabaseName.ToLower() == databaseName.ToLower() &&
                                                h.ExtensionName.ToLower() == extensionName.ToLower());
      entities.AddRange(selfRelationships);

      // Next history
      List<HistoryEntity> historyList =
        String.IsNullOrEmpty(extensionName)
        ? EntityGraph.HistoryEntities.FindAll(h => h.DatabaseName.ToLower() == databaseName.ToLower())
        : EntityGraph.HistoryEntities.FindAll(h => h.DatabaseName.ToLower() == databaseName.ToLower() &&
                                                h.ExtensionName.ToLower() == extensionName.ToLower());
      entities.AddRange(historyList);

      // Restrict inheritance graph
      InheritanceGraph inheritanceGraph =
        String.IsNullOrEmpty(extensionName) ?
        InheritanceGraph.RestrictByDb(databaseName) :
        InheritanceGraph.RestrictByDbAndExtension(databaseName, extensionName);

      // Next entities in the inheritance graph ordered such that derived classes are before parent classes
      entities.AddRange(inheritanceGraph.TopologicalSort().ToList().ConvertAll(e => e.Entity));

      // Next all other entities ordered topologically 
      List<Entity> otherEntities = entityGraph.GetEntities(false);
      otherEntities.RemoveAll(e => InheritanceGraph.HasEntity(e.FullName));
      entityGraph.OrderForDroppingTables(otherEntities);
      entities.AddRange(otherEntities);
     
      return entities.ConvertAll(e =>
                                   {
                                     Check.Require(!String.IsNullOrEmpty(e.TableName),
                                                   String.Format("Cannot find table name for entity '{0}'", e));
                                     return e.TableName;
                                   });

    }
    #endregion

    #region Private Properties
    private EntityGraph EntityGraph { get; set; }
    private InheritanceGraph InheritanceGraph { get; set; }
    private BuildGraph BuildGraph { get; set; }
    private bool InitializedEntityGraph { get; set; }
    private bool InitializedLocalizationData { get; set; }
    private List<Entity> SelfRelationshipEntities { get; set; }
    #endregion

    #region Private Methods
    static MetadataRepository()
    {
      instance = new MetadataRepository();
      instance.SelfRelationshipEntities = new List<Entity>();
      LogLevel logLevel;
      string nhLogFileWithPath = BusinessEntityConfig.Instance.GetNHibernateLogFileWithPathAndLogLevel(out logLevel);
      Log4NetConfig.Configure(nhLogFileWithPath, logLevel);
    }

    private List<string> GetLocalizationKeys()
    {
      var localizationKeys = new List<string>();

      List<string> localizationFiles = SystemConfig.GetBusinessEntityLocalizationFileNames();

      foreach(string localizationFile in localizationFiles)
      {
        IEnumerable<XElement> localeNameElements =
          from s in XElement.Load(localizationFile).Elements("locale_space").Elements("locale_entry").Elements("Name")
          select s;

        foreach(XElement localeNameElement in localeNameElements)
        {
          localizationKeys.Add(localeNameElement.Value);
        }
      }

      return localizationKeys;
    }

    private void UpdateGraph(List<Entity> entities)
    {
      // Ignore RelationshipEntities in entities.
      foreach(Entity entity in entities)
      {
        entity.IsPersisted = true;

        if (entity is RelationshipEntity) continue;

        EntityNode entityNode = EntityGraph.GetEntityNode(entity.FullName);
        if (entityNode == null)
        {
          entityNode = new EntityNode();
          entityNode.Entity = entity;
          EntityGraph.AddVertex(entityNode);
        }
        else
        {
          entityNode.Entity = entity;
        }
      }
    }

    private List<Entity> GetRelationshipEntities(List<Entity> entities)
    {
      var relationshipEntities = new List<Entity>();

      foreach (Entity entity in entities)
      {
        foreach (Relationship relationship in entity.Relationships)
        {
          if (!relationshipEntities.Contains(relationship.RelationshipEntity))
          {
            relationshipEntities.Add(relationship.RelationshipEntity);
          }
        }
      }
      return relationshipEntities;
    }

    #region Graph Methods

    #endregion

    /// <summary>
    ///    Return the list of hbm files in the specified extension and entity group.
    /// </summary>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    /// <returns></returns>
    public static List<string> GetHbmMappingFiles(string extensionName, 
                                                  string entityGroupName)
    {
      var hbmFiles = new List<string>();

      string entityDir = Name.GetEntityDir(extensionName, entityGroupName);
      if (!Directory.Exists(entityDir))
      {
        return hbmFiles;
      }

      hbmFiles.AddRange(Directory.GetFiles(entityDir, "*.hbm.xml", SearchOption.TopDirectoryOnly));

      return hbmFiles;
    }

    
    #endregion

    #region Data

    private static readonly ILog logger = LogManager.GetLogger("MetadataRepository");
    private static MetadataRepository instance;
   
    #endregion
  }
}
