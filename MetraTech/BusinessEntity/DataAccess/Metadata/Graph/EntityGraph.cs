using System;
using System.Collections.Generic;
using System.Linq;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Exception;
using QuickGraph;
using QuickGraph.Algorithms;
using QuickGraph.Algorithms.ConnectedComponents;
using QuickGraph.Algorithms.Observers;
using QuickGraph.Algorithms.Search;

using MetraTech.Basic;
using QuickGraph.Algorithms.TopologicalSort;
using QuickGraph.Algorithms.RankedShortestPath;
using QuickGraph.Predicates;

namespace MetraTech.BusinessEntity.DataAccess.Metadata.Graph
{
  [Serializable]
  public class EntityGraph : BidirectionalGraph<EntityNode, RelationshipEdge>
  {
    #region Public Properties
    #endregion

    #region Public Static Methods
    /// <summary>
    ///   Create and return a graph based on the specified entities
    /// </summary>
    /// <param name="entities"></param>
    /// <returns></returns>
    public static EntityGraph GetEntityGraph(List<Entity> entities)
    {
      var entityGraph = new EntityGraph();

      // Add the vertices
      foreach (Entity existingEntity in entities)
      {
        entityGraph.AddVertex(new EntityNode() { Entity = existingEntity });
      }

      // Add the edges
      foreach (Entity existingEntity in entities)
      {
        foreach (Relationship relationship in existingEntity.Relationships)
        {
          Check.Require(relationship.RelationshipEntity != null,
                        "Cannot find relationship entity for Relationship '{0}'", relationship.ToString());

          if (relationship.RelationshipEntity.HasSameSourceAndTarget)
          {
            entityGraph.SelfRelationships.Add(relationship.RelationshipEntity);
            continue;
          }

          if (!entityGraph.HasRelationship(relationship.RelationshipEntity.FullName))
          {
            EntityNode sourceNode = entityGraph.GetEntityNode(relationship.RelationshipEntity.SourceEntityName);
            Check.Require(sourceNode != null, String.Format("Cannot find entity '{0}' in graph", relationship.RelationshipEntity.SourceEntityName));

            EntityNode targetNode = entityGraph.GetEntityNode(relationship.RelationshipEntity.TargetEntityName);
            Check.Require(sourceNode != null, String.Format("Cannot find entity '{0}' in graph", relationship.RelationshipEntity.TargetEntityName));

            RelationshipEdge relationshipEdge =
              entityGraph.GetRelationshipEdgeForSourceAndTarget(relationship.RelationshipEntity.SourceEntityName,
                                                    relationship.RelationshipEntity.TargetEntityName);

            if (relationshipEdge == null)
            {
              relationshipEdge = new RelationshipEdge(sourceNode, targetNode);
              entityGraph.AddEdge(relationshipEdge);
            }

            if (!relationshipEdge.RelationshipEntities.Contains(relationship.RelationshipEntity))
            {
              relationshipEdge.RelationshipEntities.Add(relationship.RelationshipEntity);
            }
          }
        }
      }

      return entityGraph;
    }
    #endregion

    #region Public Methods
    public EntityGraph()
    {
      SelfRelationships = new List<RelationshipEntity>();
      HistoryEntities = new List<HistoryEntity>();
    }

    public new EntityGraph Clone()
    {
      var entityGraph = new EntityGraph();
      foreach(EntityNode entityNode in Vertices)
      {
        entityGraph.AddVertex(entityNode.Clone());
      }

      foreach (RelationshipEdge relationshipEdge in Edges)
      {
        var newSource = entityGraph.Vertices.First(v => v.Equals(relationshipEdge.Source));
        var newTarget = entityGraph.Vertices.First(v => v.Equals(relationshipEdge.Target));

        var newRelEdge = new RelationshipEdge(newSource, newTarget);
        foreach (var relEnt in relationshipEdge.RelationshipEntities)
          newRelEdge.RelationshipEntities.Add((RelationshipEntity)relEnt.Clone());

        entityGraph.AddEdge(newRelEdge);
      }

      entityGraph.SelfRelationships.AddRange(SelfRelationships);
      HistoryEntities.ForEach(h => entityGraph.HistoryEntities.Add(h.Clone() as HistoryEntity));

      return entityGraph;
    }

    public EntityGraph RestrictByDb(string databaseName)
    {
      Check.Require(!String.IsNullOrEmpty(databaseName), "databaseName cannot be null or empty");
      var entityGraph = Clone();

      entityGraph.RemoveVertexIf(e => e.Entity.DatabaseName.ToLower() != databaseName.ToLower());

      entityGraph.RemoveEdgeIf(e => e.RelationshipEntity.DatabaseName.ToLower() != databaseName.ToLower());

      entityGraph.SelfRelationships.RemoveAll(r => r.DatabaseName.ToLower() != databaseName.ToLower());

      return entityGraph;
    }

    public EntityGraph RestrictByDbAndExtension(string databaseName, string extensionName)
    {
      Check.Require(!String.IsNullOrEmpty(databaseName), "databaseName cannot be null or empty");
      Check.Require(!String.IsNullOrEmpty(extensionName), "databaseName cannot be null or empty");

      var entityGraph = RestrictByDb(databaseName);

      entityGraph.RemoveVertexIf(e => e.Entity.ExtensionName.ToLower() != extensionName.ToLower());

      entityGraph.RemoveEdgeIf(e => e.RelationshipEntity.ExtensionName.ToLower() != extensionName.ToLower());

      entityGraph.SelfRelationships.RemoveAll(r => r.ExtensionName.ToLower() != extensionName.ToLower());

      return entityGraph;
    }

    public bool HasCycle(out List<string> loopEdges)
    {
      loopEdges = new List<string>();
      
      // Variable to hold loop edges in anonymous method. Cannot use out parameter in anonymous method
      var internalLoopEdges = new List<string>();

      var dfs = new DepthFirstSearchAlgorithm<EntityNode, RelationshipEdge>(this);
      var predecessorRecorder = new VertexPredecessorRecorderObserver<EntityNode, RelationshipEdge>();
      bool foundCycle = false;
      EntityNode lastNode = null;
      RelationshipEdge lastEdge = null;

      using (predecessorRecorder.Attach(dfs))
      {
        dfs.BackEdge += args => 
        { 
          logger.Debug("Found cycle in entity graph");
          lastEdge = args;
          dfs.Abort();
          IEnumerable<RelationshipEdge> edges;
          predecessorRecorder.TryGetPath(lastNode, out edges);

          if (edges != null)
          {
            foreach (RelationshipEdge relationshipEdge in edges)
            {
              internalLoopEdges.Add(relationshipEdge.RelationshipEntity.SourceEntityName + "-->" +
                            relationshipEdge.RelationshipEntity.TargetEntityName);
            }
          }

          internalLoopEdges.Add(lastEdge.RelationshipEntity.SourceEntityName + "-->" +
                                lastEdge.RelationshipEntity.TargetEntityName);

          foundCycle = true;
        };

        if (!foundCycle)
        {
          dfs.DiscoverVertex += args => lastNode = args;
          dfs.Compute();
        }
      }

      if (foundCycle)
      {
        loopEdges.AddRange(internalLoopEdges);
        return true;
      }

      return false;
    }

    public List<RelationshipEntity> GetCascadeRelationships(string entityName)
    {
      var relationshipEntities = new List<RelationshipEntity>();
      EntityNode entityNode = GetEntityNode(entityName);
      if (entityNode == null)
      {
        return relationshipEntities;
      }

      var dfs = new DepthFirstSearchAlgorithm<EntityNode, RelationshipEdge>(this);
      
      dfs.ExamineEdge += args => {
                                   logger.Debug("Found edge " + args.ToString());
                                   if (args.RelationshipEntity.Cascade)
                                   {
                                     relationshipEntities.Add(args.RelationshipEntity);
                                   }
                                 };

      dfs.DiscoverVertex += args => logger.Debug("Found vertex " + args.Entity.FullName);

      dfs.Compute(entityNode);

      return relationshipEntities;
    }

    public void GetChildEntitiesAndRelationships(string entityName, 
                                                 bool includeSelf,
                                                 out List<Entity> childEntities,
                                                 out List<RelationshipEntity> relationshipEntities)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty");
      
      childEntities = new List<Entity>();
      relationshipEntities = new List<RelationshipEntity>();

      // Local collections because we can't use out/ref parameters in anonymous methods
      var localChildEntities = new List<Entity>();
      var localRelationshipEntities = new List<RelationshipEntity>();

      EntityNode entityNode = GetEntityNode(entityName);
      if (entityNode == null)
      {
        return;
      }

      var dfs = new DepthFirstSearchAlgorithm<EntityNode, RelationshipEdge>(this);

      dfs.ExamineEdge += args =>
      {
        localRelationshipEntities.Add(args.RelationshipEntity);
      };

      dfs.DiscoverVertex += args =>
      {
        localChildEntities.Add(args.Entity);
      };

      dfs.FinishVertex += args =>
      {
        if (args.Entity.FullName == entityName)
        {
          dfs.Abort();
        }
      };

      dfs.Compute(entityNode);

      if (!includeSelf)
      {
        localChildEntities.RemoveAll(e => e.FullName == entityName);
      }

      childEntities.AddRange(localChildEntities);
      relationshipEntities.AddRange(localRelationshipEntities);
      relationshipEntities.RemoveAll(r => r.HasJoinTable == false);
    }

    public Dictionary<int, List<RelationshipEntity>> GetAllPaths(string sourceEntityName, string targetEntityName)
    {
      var allPaths = new Dictionary<int, List<RelationshipEntity>>();

      EntityNode sourceEntityNode = GetEntityNode(sourceEntityName);
      if (sourceEntityNode == null)
      {
        return allPaths;
      }

      EntityNode targetEntityNode = GetEntityNode(targetEntityName);
      if (targetEntityNode == null)
      {
        return allPaths;
      }

      var hoffmanPavleyRankedShortestPathAlgorithm = 
        new HoffmanPavleyRankedShortestPathAlgorithm<EntityNode, RelationshipEdge>(this, e => 1.0);

      hoffmanPavleyRankedShortestPathAlgorithm.ShortestPathCount = 10;
      hoffmanPavleyRankedShortestPathAlgorithm.SetRootVertex(sourceEntityNode);
      hoffmanPavleyRankedShortestPathAlgorithm.SetGoalVertex(targetEntityNode);
      hoffmanPavleyRankedShortestPathAlgorithm.Compute();

      int i = 0;
      foreach (IEnumerable<RelationshipEdge> path in hoffmanPavleyRankedShortestPathAlgorithm.ComputedShortestPaths)
      {
        var relationshipEntities = new List<RelationshipEntity>();
        allPaths.Add(i, relationshipEntities);
        i++;

        foreach (RelationshipEdge relationshipEdge in path)
        {
          relationshipEntities.Add(relationshipEdge.RelationshipEntity);
        }
      }
     
      return allPaths;
    }

    public bool PathExists(string sourceEntityName, string targetEntityName)
    {
      EntityNode sourceEntityNode = GetEntityNode(sourceEntityName);
      if (sourceEntityNode == null)
      {
        return false;
      }

      EntityNode targetEntityNode = GetEntityNode(targetEntityName);
      if (targetEntityNode == null)
      {
        return false;
      }

      var dfs = new DepthFirstSearchAlgorithm<EntityNode, RelationshipEdge>(this);
      var predecessorRecorder = new VertexPredecessorRecorderObserver<EntityNode, RelationshipEdge>();

      dfs.FinishVertex += args =>
      {
        // if we have finished the source vertex (marked black) i.e. traversed all reachable vertices, stop the dfs
        if (args.Entity.FullName == sourceEntityName)
        {
          dfs.Abort();
        }
      };

      // Start dfs from the source vertex, recording preceding vertices
      using (predecessorRecorder.Attach(dfs))
      {
        dfs.Compute(sourceEntityNode);
      }

      // If we have a path to the target, return true
      IEnumerable<RelationshipEdge> pathEdges;
      if (predecessorRecorder.TryGetPath(targetEntityNode, out pathEdges))
      {
        return true;
      }

      return false;
    }

    public bool HasPersistedEntity(string entityName)
    {
      EntityNode entityNode = Vertices.Where(v => v.Entity.FullName == entityName && v.Entity.IsPersisted).SingleOrDefault();
      if (entityNode == null)
      {
        return false;
      }

      return true;
    }

    public bool HasEntity(string entityName)
    {
      EntityNode entityNode = Vertices.Where(v => v.Entity.FullName == entityName).SingleOrDefault();
      return entityNode != null;
    }

    public bool HasRelationship(string relationshipEntityName)
    {
      RelationshipEdge relationshipEdge =
        Edges.Where(e => e.RelationshipEntities.Find(r => r.FullName == relationshipEntityName) != null).SingleOrDefault();

      return relationshipEdge != null;
    }

    public bool AreRelated(string entityName1, string entityName2)
    {
      RelationshipEdge edge = GetRelationshipEdge(entityName1, entityName2);

      if (edge == null)
      {
        return false;
      }

      return true;
    }

    /// <summary>
    ///    Return the RelationshipEntity for each of the incoming and outgoing edges
    ///    for the specified entity
    /// </summary>
    /// <param name="entityName"></param>
    /// <returns></returns>
    public List<RelationshipEntity> GetRelationshipEntities(string entityName)
    {
      var relationshipEntities = new List<RelationshipEntity>();

      EntityNode entityNode = GetEntityNode(entityName);
      if (entityNode != null)
      {
        IEnumerable<RelationshipEdge> outEdges = OutEdges(entityNode);
        foreach(RelationshipEdge relationshipEdge in outEdges)
        {
          relationshipEntities.AddRange(relationshipEdge.RelationshipEntities);
        }

        IEnumerable<RelationshipEdge> inEdges = InEdges(entityNode);
        foreach (RelationshipEdge relationshipEdge in inEdges)
        {
          relationshipEntities.AddRange(relationshipEdge.RelationshipEntities);
        }
      }

      return relationshipEntities;
    }

    public RelationshipEdge GetRelationshipEdge(string entityName1, string entityName2)
    {
      RelationshipEdge edge =
        Edges.Where(e => (e.RelationshipEntity.SourceEntityName == entityName1 &&
                          e.RelationshipEntity.TargetEntityName == entityName2)
                          ||
                         (e.RelationshipEntity.TargetEntityName == entityName1 &&
                          e.RelationshipEntity.SourceEntityName == entityName2)).SingleOrDefault();

      return edge;
    }

    public RelationshipEdge GetRelationshipEdgeForSourceAndTarget(string sourceEntityName, string targetEntityName)
    {
      RelationshipEdge relationshipEdge = null;
      foreach(RelationshipEdge re in Edges)
      {
        foreach(RelationshipEntity relationshipEntity in re.RelationshipEntities)
        {
          if (relationshipEntity.SourceEntityName == sourceEntityName &&
              relationshipEntity.TargetEntityName == targetEntityName)
          {
            relationshipEdge = re;
            break;
          }
        }
      }

      return relationshipEdge;
    }

    public Entity GetEntity(string entityName)
    {
      Entity entity = null;
      EntityNode entityNode = Vertices.Where(v => v.Entity.FullName == entityName).SingleOrDefault();
      if (entityNode != null)
      {
        entity = entityNode.Entity;
      }
      else
      {
        foreach(RelationshipEdge relationshipEdge in Edges)
        {
          foreach(RelationshipEntity relationshipEntity in relationshipEdge.RelationshipEntities)
          {
            if (relationshipEntity.FullName == entityName)
            {
              entity = relationshipEdge.RelationshipEntity;
              break;
            }
          }
        }
      }

      return entity;
    }

    public Entity GetEntityByTableName(string tableName)
    {
      logger.Debug(String.Format("Retrieving entity for table name '{0}'", tableName));
      Entity entity = null;
      EntityNode entityNode = Vertices.Where(v => v.Entity.TableName.ToLower() == tableName.ToLower()).SingleOrDefault();
      if (entityNode != null)
      {
        entity = entityNode.Entity;
      }
      else
      {
        RelationshipEdge relationshipEdge = 
          Edges.Where(e => e.RelationshipEntity != null && 
                           !String.IsNullOrEmpty(e.RelationshipEntity.TableName) && 
                           e.RelationshipEntity.TableName.ToLower() == tableName.ToLower()).SingleOrDefault();

        if (relationshipEdge != null)
        {
          entity = relationshipEdge.RelationshipEntity;
        }
      }

      return entity;
    }

    public List<Entity> GetEntities(bool includeRelationshipEntities)
    {
      var entities = new List<Entity>();

      entities.AddRange(Vertices.Select(v => v.Entity));
     
      if (includeRelationshipEntities)
      {
        entities.AddRange((from relationshipEdge in Edges
                           from relationshipEntity in relationshipEdge.RelationshipEntities
                           where relationshipEntity.HasJoinTable
                           select relationshipEntity));
      }

      return entities;
    }

    public List<Entity> GetEntities(string extensionName, bool includeRelationshipEntities)
    {
      var entities = new List<Entity>();
      entities.AddRange(Vertices.Where(v => v.Entity.ExtensionName.ToLower() == extensionName.ToLower())
                                .Select(v => v.Entity));

      if (includeRelationshipEntities)
      {
        entities.AddRange((from relationshipEdge in Edges
                           from relationshipEntity in relationshipEdge.RelationshipEntities
                           where relationshipEntity.HasJoinTable &&
                                 relationshipEntity.ExtensionName.ToLower() == extensionName.ToLower()
                           select relationshipEntity));

      }

      return entities;
    }

    public List<Entity> GetEntities(string extensionName, string entityGroupName, bool includeRelationshipEntities)
    {
      var entities = new List<Entity>();
      entities.AddRange(Vertices.Where(v => v.Entity.ExtensionName.ToLower() == extensionName.ToLower() &&
                                            v.Entity.EntityGroupName.ToLower() == entityGroupName.ToLower())
                                .Select(v => v.Entity));

      if (includeRelationshipEntities)
      {
        entities.AddRange((from relationshipEdge in Edges
                           from relationshipEntity in relationshipEdge.RelationshipEntities
                           where relationshipEntity.HasJoinTable &&
                                 relationshipEntity.ExtensionName.ToLower() == extensionName.ToLower() &&
                                 relationshipEntity.EntityGroupName.ToLower() == entityGroupName.ToLower()
                           select relationshipEntity));

      }

      return entities;
    }


    public List<Entity> GetRelationshipCandidates(Entity sourceEntity, List<Entity> currentEntities)
    {
      Check.Require(sourceEntity != null, "sourceEntity cannot be null");
     
      var candidates = new List<Entity>();
      List<Entity> sourceDbEntities =
        currentEntities.FindAll(e => e.DatabaseName.ToLower() == sourceEntity.DatabaseName.ToLower());

      // Create a copy of the current graph and restrict by database
      EntityGraph graph = RestrictByDbAndExtension(sourceEntity.DatabaseName, sourceEntity.ExtensionName);
      List<string> loopEdges;
      if (graph.HasCycle(out loopEdges))
      {
        string message = String.Format("The entity graph has the following cycle. '{0}'",
                                       String.Join(", ", loopEdges.ToArray()));

        graph.Render(true);
        throw new MetadataException(message);
      }

      if (!graph.HasEntity(sourceEntity.FullName))
      {
        graph.AddVertex(new EntityNode() { Entity = sourceEntity });
      }

      // Add all entities from currentEntities that are missing from the graph
      foreach (Entity entity in sourceDbEntities)
      {
        if (entity.DatabaseName.ToLower() != sourceEntity.DatabaseName.ToLower()) continue;

        if (!graph.HasEntity(entity.FullName))
        {
          graph.AddVertex(new EntityNode() {Entity = entity});
        }
      }

      // Add the relationships that are missing from the graph
      foreach (Entity entity in sourceDbEntities)
      {
        foreach(Relationship relationship in entity.Relationships)
        {
          if (relationship.RelationshipEntity.HasSameSourceAndTarget) continue;

          if (!graph.HasRelationship(relationship.RelationshipEntity.FullName))
          {
            graph.AddRelationship(relationship.RelationshipEntity);
          }
        }
      }

      EntityNode entityNode = graph.GetEntityNode(sourceEntity.FullName);
      Check.Require(entityNode != null, String.Format("Cannot find entity '{0}' in graph", sourceEntity.FullName));

      // Do a topological sort on the graph.
      var sortedVertices = new List<EntityNode>();
      try
      {
        var topologicalSort = new TopologicalSortAlgorithm<EntityNode, RelationshipEdge>(graph);
        topologicalSort.Compute();
        sortedVertices.AddRange(topologicalSort.SortedVertices as List<EntityNode>);
      }
      catch (System.Exception e)
      {
        throw new MetadataException("Failed to sort entities in graph", e);
      }
    

      IEnumerable<RelationshipEdge> outEdges = graph.OutEdges(entityNode);
      foreach (RelationshipEdge relationshipEdge in outEdges)
      {
        sortedVertices.RemoveAll(v => v.Entity.FullName == relationshipEdge.RelationshipEntity.TargetEntityName);
      }

      // Given A -> B -> C -> D 
      // sortedVertices[0] = A and sortedVertices[3] = D

      // Given B: D is a candidate (because creating a link to it would not cause a cycle)
      //          C has already been removed in the previous step

      // All entities that sort ahead of the specified entity are candidates
      int index = sortedVertices.FindIndex(v => v.Entity.FullName == sourceEntity.FullName);
      Check.Require(index != -1, String.Format("Cannot find entity '{0}'", sourceEntity.FullName));

      // Do this only if the 'B' is not the last item
      if (index < sortedVertices.Count - 1)
      {
        for (int i = index + 1; i < sortedVertices.Count; i++)
        {
          Entity entity = sourceDbEntities.Find(e => e.FullName == sortedVertices[i].Entity.FullName);
          if (entity != null && !candidates.Contains(entity))
          {
            candidates.Add(entity);
          }
        }
      }

      // Do this if 'B' is not the first item
      if (index > 0)
      {
        // For the entities that sort behind the specified entity, if there is no path from
        // any of those entities to the specified entity, then add them as candidates
        for (int i = 0; i < index; i++)
        {
          if (!graph.PathExists(sortedVertices[i].Entity.FullName, sourceEntity.FullName))
          {
            Entity entity = sourceDbEntities.Find(e => e.FullName == sortedVertices[i].Entity.FullName);
            if (entity != null && !candidates.Contains(entity))
            {
              candidates.Add(entity);
            }
          }
        }
      }

      // Remove self
      candidates.RemoveAll(e => e.FullName == sourceEntity.FullName);

      // Remove entities from other extensions
      candidates.RemoveAll(e => e.ExtensionName.ToLowerInvariant() != sourceEntity.ExtensionName.ToLowerInvariant());

      return candidates;
    }
    
    /// <summary>
    ///    Return the list of extensions that the entity groups in the specified extensionData depend on.
    ///    i.e. in order to build the interface and entities in the specified ExtensionData, the 
    ///    interface assemblies associated with the returned list of extensions must be available as reference assemblies.
    /// </summary>
    /// <param name="extensionData"></param>
    /// <returns></returns>
    public List<string> GetBuildDependencies(ExtensionData extensionData)
    {
      var extensionNames = new List<string>();

      foreach(EntityGroupData entityGroupData in extensionData.EntityGroupDataList)
      {
        List<EntityGroupData> entityGroupDependencies = GetBuildDependencies(entityGroupData);
        
        foreach(EntityGroupData entityGroupDependency in entityGroupDependencies)
        {
          if (!extensionNames.Contains(entityGroupDependency.ExtensionName.ToLowerInvariant()))
          {
            extensionNames.Add(entityGroupDependency.ExtensionName.ToLowerInvariant());
          }
        }
      }

      return extensionNames;
    }

    /// <summary>
    ///   Return all the entity assemblies
    /// </summary>
    /// <returns></returns>
    public List<string> GetAssembliesForBuildingSessionFactory()
    {
      var assemblyNames = new List<string>();
      List<Entity> entities = GetEntities(false);
      
      foreach(Entity entity in entities)
      {
        string assemblyName = Name.GetEntityAssemblyName(entity.ExtensionName, entity.EntityGroupName);
        if (!assemblyNames.Contains(assemblyName.ToLowerInvariant()))
        {
          assemblyNames.Add(assemblyName.ToLowerInvariant());
        }
      }

      return assemblyNames;
    }
    /// <summary>
    ///   (1) Get the connected entities for all entities in the specified extension/entitygroup
    ///   (2) Get the unique set of assembly names for each entity obtained in step (1)
    /// </summary>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    /// <returns></returns>
    public List<string> GetRequiredAssemblies(string extensionName, string entityGroupName)
    {
      var assemblyNames = new List<string>();

      List<Entity> entities = GetEntities(extensionName, entityGroupName, false);
      List<Entity> connectedEntities = GetConnectedEntitiesWithRelationships(entities);

      string assemblyName;
      foreach(Entity entity in connectedEntities)
      {
        assemblyName = Name.GetEntityAssemblyName(entity.FullName).ToLower();
        if (!assemblyNames.Contains(assemblyName))
        {
          assemblyNames.Add(assemblyName);
        }
      }

      assemblyName = Name.GetEntityAssemblyName(extensionName, entityGroupName).ToLower(); 
      if (!assemblyNames.Contains(assemblyName))
      {
        assemblyNames.Add(assemblyName);
      }

      return assemblyNames;
    }

    public List<string> GetBuildDependencies(string extensionName, string entityGroupName)
    {
      var assemblyNames = new List<string>();
      List<EntityGroupData> buildDependencies = GetBuildDependencies(new EntityGroupData(extensionName, entityGroupName));

      foreach(EntityGroupData entityGroupData in buildDependencies)
      {
        assemblyNames.Add(entityGroupData.EntityAssemblyName.Replace(".dll", ""));
      }

      return assemblyNames;
    }

    /// <summary>
    ///   Return the EntityGroup's which the specified entityGroup depends on, in order for it to build
    /// </summary>
    /// <param name="entityGroupData"></param>
    /// <returns></returns>
    public List<EntityGroupData> GetBuildDependencies(EntityGroupData entityGroupData)
    {
      var buildDependencies = new List<EntityGroupData>();

      // Get the entityNodes for the specified entityGroupData
      List<EntityNode> entityNodes = 
        GetEntityNodes(entityGroupData.ExtensionName, entityGroupData.EntityGroupName);

      foreach(EntityNode entityNode in entityNodes)
      {
        if (OutEdges(entityNode).Count() == 0) continue;

        var dfs = new DepthFirstSearchAlgorithm<EntityNode, RelationshipEdge>(this);

        dfs.FinishVertex += args =>
        {
          // if we have finished the source vertex (marked black) i.e. traversed all reachable vertices, stop the dfs
          if (args.Entity.FullName == entityNode.Entity.FullName)
          {
            dfs.Abort();
          }
        };

        dfs.TreeEdge += args =>
                          {
                            string targetExtensionName, targetEntityGroupName;
                            Name.GetExtensionAndEntityGroup(args.RelationshipEntity.TargetEntityName,
                                                            out targetExtensionName, out targetEntityGroupName);
                            
                            // If the target extension is different, then add the target to the build dependency
                            if (targetExtensionName.ToLowerInvariant() != entityGroupData.ExtensionName.ToLower())
                            {
                              if (!buildDependencies.Exists(e => e.ExtensionName.ToLowerInvariant() == targetExtensionName.ToLowerInvariant()))
                              {
                                buildDependencies.Add(new EntityGroupData(targetExtensionName, targetEntityGroupName));
                              }
                            }
                          };

        dfs.Compute(entityNode);
      }

      return buildDependencies;
    }

    public void Render()
    {
      Render(false);
    }

    public void Render(bool hasCycle)
    {
      GraphRenderer.Render(this, hasCycle);
    }

    /// <summary>
    ///   Given the model A->B->C where -> represent relationship(s)
    ///   Return C B A
    /// </summary>
    /// <param name="entities"></param>
    public void OrderForDroppingTables(List<Entity> entities)
    {
      List<Entity> topologicalSort = this.TopologicalSort().Reverse().ToList().ConvertAll(e => e.Entity);

      entities.Sort(delegate(Entity entity1, Entity entity2)
      {
        int index1 = topologicalSort.FindIndex(a => a.FullName == entity1.FullName);
        if (index1 == -1)
        {
          return 0;
        }

        int index2 = topologicalSort.FindIndex(a => a.FullName == entity2.FullName);
        if (index2 == -1)
        {
          return 0;
        }

        return index1.CompareTo(index2);
      });
    }

    /// <summary>
    ///   Given the model A->B->C where -> represent relationship(s)
    ///   Return A B C
    /// </summary>
    /// <param name="entities"></param>
    public void SortByDependency(List<Entity> entities)
    {
      List<Entity> topologicalSort = this.TopologicalSort().ToList().ConvertAll(e => e.Entity);

      List<Entity> nonGraphEntities = 
        entities.FindAll(e => !topologicalSort.Exists(te => te.FullName == e.FullName));

      entities.RemoveAll(e => nonGraphEntities.Exists(ne => ne.FullName == e.FullName));

      entities.Sort(delegate(Entity entity1, Entity entity2)
      {
        int index1 = topologicalSort.FindIndex(a => a.FullName == entity1.FullName);
        int index2 = topologicalSort.FindIndex(a => a.FullName == entity2.FullName);

        return index1.CompareTo(index2);
      });

      entities.AddRange(nonGraphEntities);
    }
    /// <summary>
    ///   Sort the items in entityGroupDataList using the current data and the new relationships.
    ///   (1) Clone the graph
    ///   (2) Add the new entities for each new relationship (if necessary)
    ///   (3) Add the new relationships
    ///   (4) Do a topological sort on the graph
    ///   (5) Sort the items in entityGroupDataList based on the reverse topological sort order
    /// </summary>
    /// <param name="entityGroupDataList"></param>
    public void SortByDependency(List<EntityGroupData> entityGroupDataList)
    {
      // Topological sort
      var topologicalSort = new TopologicalSortAlgorithm<EntityNode, RelationshipEdge>(this);
      topologicalSort.Compute();
      IList<EntityNode> sortedVertices = topologicalSort.SortedVertices;

      // Reduce to EntityGroupData
      var sortedEntityGroupDataList = new List<EntityGroupData>();
      foreach(EntityNode entityNode in sortedVertices)
      {
        if (sortedEntityGroupDataList.Contains(entityNode.Entity.EntityGroupData)) continue;
        sortedEntityGroupDataList.Add(entityNode.Entity.EntityGroupData);
      }

      // Sort the items in entityGroupDataList (using the reverse order of the items in
      // sortedEntityGroupDataList). 
      entityGroupDataList.Sort(delegate(EntityGroupData eg1, EntityGroupData eg2)
      {
        int index1 = sortedEntityGroupDataList.IndexOf(eg1);
        int index2 = sortedEntityGroupDataList.IndexOf(eg2);

        int compareValue = 0;
        if (index2 > index1)
        {
          compareValue = 1;
        }
        else if (index2 < index1)
        {
          compareValue = -1;
        }

        return compareValue;
      });
    }

    public bool CheckCycles(List<RelationshipEntity> newRelationshipEntities, out List<string> loopEdges)
    {
      EntityGraph graph = Clone();

      foreach(RelationshipEntity relationshipEntity in newRelationshipEntities)
      {
        EntityNode sourceNode = graph.Vertices.Where(v => v.Entity.FullName == relationshipEntity.SourceEntityName).SingleOrDefault();
        if (sourceNode == null)
        {
          sourceNode = new EntityNode() {Entity = new Entity(relationshipEntity.SourceEntityName)};
          graph.AddVertex(sourceNode);
        }

        EntityNode targetNode = graph.Vertices.Where(v => v.Entity.FullName == relationshipEntity.TargetEntityName).SingleOrDefault();
        if (targetNode == null)
        {
          targetNode = new EntityNode() { Entity = new Entity(relationshipEntity.TargetEntityName) };
          graph.AddVertex(targetNode);
        }

        graph.AddRelationship(relationshipEntity);
      }

      return graph.HasCycle(out loopEdges);
    }

    /// <summary>
    ///   return 0 - if drop order does not matter
    ///   return -1 - if tableName1 must be dropped before tableName2
    ///   return 1 - if tableName2 must be dropped before tableName1
    /// </summary>
    /// <param name="tableName1"></param>
    /// <param name="tableName2"></param>
    /// <returns></returns>
    public int GetDropOrder(string tableName1, string tableName2)
    {
      if (tableName1.ToLower() == tableName2.ToLower())
      {
        return 0;
      }

      if (IsHistoryTable(tableName1) || IsHistoryTable(tableName2))
      {
        return 0;
      }

      Entity entity1 = GetEntityByTableName(tableName1);
      Check.Require(entity1 != null, "Cannot find entity for tableName '{0}'", tableName1);

      Entity entity2 = GetEntityByTableName(tableName2);
      Check.Require(entity2 != null, "Cannot find entity for tableName '{0}'", tableName2);

      var entities = new List<Entity> {entity1, entity2};

      OrderForDroppingTables(entities);

      return entities[0].TableName.ToLower() == tableName1.ToLower() ? -1 : 1;
    }

    #endregion

    #region Internal Methods
    internal bool IsHistoryTable(string tableName)
    {
      return HistoryEntities.Exists(h => h.TableName.ToLower() == tableName.ToLower());
    }

    internal void AddEntity(Entity entity)
    {
      Check.Require(entity != null, "entity cannot be null");
      Entity existingEntity = GetEntity(entity.FullName);
      Check.Require(existingEntity == null, String.Format("The specified entity '{0}' already exists in the graph", entity.FullName));
      AddVertex(new EntityNode() { Entity = entity });
    }

    /// <summary>
    ///   Return true, if the entity was deleted.
    /// </summary>
    /// <param name="entityName"></param>
    /// <returns></returns>
    internal bool DeleteEntity(string entityName)
    {
      EntityNode entityNode = GetEntityNode(entityName);
      if (entityNode != null)
      {
        RemoveVertex(entityNode);
        return true;
      }

      return false;
    }

    /// <summary>
    ///   Return true, if the relationship was deleted
    /// </summary>
    /// <param name="relationshipEntity"></param>
    /// <returns></returns>
    internal bool DeleteRelationship(RelationshipEntity relationshipEntity)
    {
      if (relationshipEntity == null)
      {
        return false;
      }

      RelationshipEdge relationshipEdge =
        GetRelationshipEdge(relationshipEntity.SourceEntityName, relationshipEntity.TargetEntityName);
      if (relationshipEdge != null)
      {
        relationshipEdge.RelationshipEntities.Remove(relationshipEntity);
        if (relationshipEdge.RelationshipEntities.Count == 0)
        {
          RemoveEdge(relationshipEdge);
        }

        return true;
      }

      return false;
    }

    internal void AddRelationship(RelationshipEntity relationshipEntity)
    {
      Check.Require(relationshipEntity != null, "relationshipEntity cannot be null");
      Entity existingRelationshipEntity = GetEntity(relationshipEntity.FullName);
      Check.Require(existingRelationshipEntity == null, String.Format("The specified relationship '{0}' already exists in the graph", relationshipEntity));

      EntityNode sourceEntityNode = GetEntityNode(relationshipEntity.SourceEntityName);
      Check.Require(sourceEntityNode != null, String.Format("Cannot find entity '{0}' in the graph", relationshipEntity.SourceEntityName));

      if (relationshipEntity.IsSelfRelationship && !SelfRelationships.Contains(relationshipEntity))
      {
        SelfRelationships.Add(relationshipEntity);
      }

      // Cannot add this as an edge, would create a cycle
      if (relationshipEntity.HasSameSourceAndTarget)
      {
        return;
      }

      EntityNode targetEntityNode = GetEntityNode(relationshipEntity.TargetEntityName);
      Check.Require(targetEntityNode != null, String.Format("Cannot find entity '{0}' in the graph", relationshipEntity.TargetEntityName));

      RelationshipEdge relationshipEdge =
         GetRelationshipEdgeForSourceAndTarget(relationshipEntity.SourceEntityName,
                                               relationshipEntity.TargetEntityName);

      if (relationshipEdge == null)
      {
        relationshipEdge = new RelationshipEdge(sourceEntityNode, targetEntityNode);
        AddEdge(relationshipEdge);
      }

      if (!relationshipEdge.RelationshipEntities.Contains(relationshipEntity))
      {
        relationshipEdge.RelationshipEntities.Add(relationshipEntity);
      }
    }

    internal void ReplaceEntity(Entity entity)
    {
      Check.Require(entity != null, "entity cannot be null");
      EntityNode entityNode = GetEntityNode(entity.FullName);
      if (entityNode != null)
      {
        entityNode.Entity = entity;
      }
    }

    internal void ReplaceRelationship(RelationshipEntity relationshipEntity, bool throwIfNotFound)
    {
      Check.Require(relationshipEntity != null, "relationshipEntity cannot be null");
      RelationshipEdge relationshipEdge = GetRelationshipEdge(relationshipEntity.SourceEntityName, relationshipEntity.TargetEntityName);
      if (throwIfNotFound && relationshipEdge == null)
      {
        throw new MetadataException(String.Format("Cannot find relationship '{0}' in graph", relationshipEntity));
      }

      if (relationshipEdge != null)
      {
        relationshipEdge.RelationshipEntities.Remove(relationshipEntity);
        relationshipEdge.RelationshipEntities.Add(relationshipEntity);
      }
    }

    internal EntityNode GetEntityNode(string entityName)
    {
      return Vertices.Where(v => v.Entity.FullName == entityName).SingleOrDefault();
    }

    internal List<EntityNode> GetEntityNodes(string extensionName, string entityGroupName)
    {
      return Vertices.Where(v => v.Entity.ExtensionName.ToLowerInvariant() == extensionName.ToLowerInvariant() &&
                                 v.Entity.EntityGroupName.ToLowerInvariant() == entityGroupName.ToLowerInvariant()).ToList();

    }

    internal List<Entity> GetConnectedEntities(Entity entity, bool includeRelationships)
    {
      Check.Require(entity != null, "entity cannot be null");

      List<Entity> connectedEntities = GetConnectedEntitiesWithRelationships(new List<Entity> {entity});
      if (includeRelationships == false)
      {
        connectedEntities.RemoveAll(e => e is RelationshipEntity);
      }

      // Remove this entity
      connectedEntities.RemoveAll(e => e.FullName == entity.FullName);

      return connectedEntities;
    }

    /// <summary>
    ///   Return the list of connected entities and the relationships between those entities for
    ///   the specified entities
    /// </summary>
    /// <param name="entities"></param>
    /// <returns></returns>
    internal List<Entity> GetConnectedEntitiesWithRelationships(List<Entity> entities)
    {
      var connectedEntitiesWithRelationships = new List<Entity>();

      var undirectedGraph = new UndirectedGraph<EntityNode, RelationshipEdge>();
      undirectedGraph.AddVerticesAndEdgeRange(Edges);

      var connectedComponentsAlgorithm =
        new ConnectedComponentsAlgorithm<EntityNode, RelationshipEdge>(undirectedGraph);
      connectedComponentsAlgorithm.Compute();

      var indices = new List<int>();

      foreach(Entity entity in entities)
      {
        if (entity is RelationshipEntity) continue;

        EntityNode entityNode = GetEntityNode(entity.FullName);
        
        if (entityNode == null) continue;
        
        if (connectedComponentsAlgorithm.Components.ContainsKey(entityNode))
        {
          int componentIndex = connectedComponentsAlgorithm.Components[entityNode];

          if (indices.Contains(componentIndex)) continue;

          foreach (EntityNode componentNode in connectedComponentsAlgorithm.Components.Keys)
          {
            // Add those entities which are not specified in the input argument
            if (connectedComponentsAlgorithm.Components[componentNode] == componentIndex)
            {
              connectedEntitiesWithRelationships.Add(componentNode.Entity);
            }
          }

          indices.Add(componentIndex);
        }
      }

      // Filter the graph to the items in entities and use the filtered graph to get the necessary
      // relationships
      var filteredGraph =
          new FilteredBidirectionalGraph<EntityNode, 
                                         RelationshipEdge, 
                                         IBidirectionalGraph<EntityNode, RelationshipEdge>>
           (
             this,
             // Filter for those vertices which have been added to connectedEntitiesWithRelationships 
             v => connectedEntitiesWithRelationships.Exists(e => e.FullName == v.Entity.FullName),
             e => true
           );

      foreach(RelationshipEdge relationshipEdge in filteredGraph.Edges)
      {
        connectedEntitiesWithRelationships.AddRange(relationshipEdge.GetJoinTableRelationshipEntities());
      }

      // Remove the items in entities from connectedEntitiesWithRelationships
      foreach(Entity entity in entities)
      {
        connectedEntitiesWithRelationships.RemoveAll(e => e.FullName == entity.FullName);
      }

      return connectedEntitiesWithRelationships;
    }

    internal List<Entity> GetJoinTableRelationshipEntities()
    {
      return (from relationshipEdge in Edges
              from relationshipEntity in relationshipEdge.RelationshipEntities
              where relationshipEntity.HasJoinTable
              select relationshipEntity).Cast<Entity>().ToList();
    }

    internal List<Entity> GetJoinTableRelationshipEntitiesForExtension(string extensionName)
    {
      Check.Require(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null or empty");

      return (from relationshipEdge in Edges
              from relationshipEntity in relationshipEdge.RelationshipEntities
              where relationshipEntity.HasJoinTable && relationshipEntity.ExtensionName.ToLower() == extensionName
              select relationshipEntity).Cast<Entity>().ToList();
    }

    #endregion

    #region Internal Properties
    internal List<RelationshipEntity> SelfRelationships { get; set; }
    internal List<HistoryEntity> HistoryEntities { get; set; }
    #endregion

    #region Data
    internal static ILog logger = LogManager.GetLogger("EntityGraph");
    #endregion
  }
}
