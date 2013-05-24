using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Exception;
using QuickGraph;
using QuickGraph.Algorithms;
using QuickGraph.Algorithms.ConnectedComponents;
using QuickGraph.Predicates;

namespace MetraTech.BusinessEntity.DataAccess.Metadata.Graph
{
  [Serializable]
  public class InheritanceGraph : BaseGraph<SubClassEdge>
  {
    #region Public Methods
    public new InheritanceGraph Clone()
    {
      var inheritanceGraph = new InheritanceGraph();

      foreach (EntityNode entityNode in Vertices)
      {
        inheritanceGraph.AddVertex(entityNode);
      }

      foreach (BaseEdge edge in Edges)
      {
        inheritanceGraph.AddEdge(edge);
      }

      return inheritanceGraph;
    }

    /// <summary>
    ///   Return a dictionary of property names (property name -> entity name) for those
    ///   properties on entity which are in common with any of the entities
    ///   in the ancestor hierarchy for entityWithHierarchy (including entityWithHierarchy).
    /// </summary>
    /// <param name="entity"></param>
    /// <param name="entityWithHierarchy"></param>
    /// <returns></returns>
    public Dictionary<string, string> GetDuplicatePropertyNames(Entity entity, 
                                                                Entity entityWithHierarchy)
    {
      var duplicatePropertyNames = new Dictionary<string, string>();
      List<Entity> hierarchy = GetAncestors(entityWithHierarchy.FullName);
      hierarchy.Add(entityWithHierarchy);

      foreach(Property property in entity.Properties)
      {
        foreach(Entity hierarchyEntity in hierarchy)
        {
          if (hierarchyEntity.HasProperty(property.Name))
          {
            duplicatePropertyNames.Add(property.Name, hierarchyEntity.FullName);
          } 
        }
      }

      return duplicatePropertyNames;
    }
    /// <summary>
    ///    Return true if the specified entityName is a member of the inheritance hierarchy
    ///    for entityWithHierarchy 
    /// </summary>
    /// <param name="entityName"></param>
    /// <param name="entityWithHierarchy"></param>
    /// <returns></returns>
    public bool IsMemberOfInheritanceHierarchy(string entityName, string entityWithHierarchy)
    {
      List<Entity> inheritanceHierarchy = GetInheritanceHierarchy(entityWithHierarchy);
      Entity entity = inheritanceHierarchy.Find(e => e.FullName == entityName);

      return entity != null;
    }

    /// <summary>
    ///   Return true, if there are no common elements between entityName1's hierarchy and
    ///   entityName2's hierarchy
    /// </summary>
    /// <param name="entityName1"></param>
    /// <param name="entityName2"></param>
    /// <returns></returns>
    public bool AreMembersOfDisconnectedHierarchies(string entityName1, string entityName2)
    {
      List<Entity> hierarchy1 = GetInheritanceHierarchy(entityName1);
      List<Entity> hierarchy2 = GetInheritanceHierarchy(entityName2);

      List<Entity> intersection = hierarchy1.Intersect(hierarchy2).ToList();

      logger.Debug(String.Format("Found '{0}' common entity(s) '{1}' " +
                                 "between hierarchy '{2}' and hierarchy '{3}'",
                                 intersection.Count,
                                 StringUtil.Join(" , ", intersection, e => e.ToString()),
                                 StringUtil.Join(" , ", hierarchy1, e => e.ToString()),
                                 StringUtil.Join(" , ", hierarchy2, e => e.ToString())));

      return intersection.Count == 0;
    }

    public List<Entity> GetAncestors(string entityName)
    {
      List<Entity> inheritanceHierarchy = GetInheritanceHierarchy(entityName);
      var ancestors = new List<Entity>();

      foreach(Entity entity in inheritanceHierarchy)
      {
        if (entity.FullName == entityName)
        {
          break;
        }

        ancestors.Add(entity);
      }

      return ancestors;
    }

    /// <summary>
    ///   Return the inheritance hierarchy for the specified entity sorted such that a derived class
    ///   will always be after its parent class.
    /// </summary>
    /// <param name="entityName"></param>
    /// <returns></returns>
    public List<Entity> GetInheritanceHierarchy(string entityName)
    {
      var inheritanceChain = new List<Entity>();

      EntityNode entityNode = GetEntityNode(entityName);

      if (entityNode == null) return inheritanceChain;

      var undirectedGraph = new UndirectedGraph<EntityNode, BaseEdge>();
      undirectedGraph.AddVerticesAndEdgeRange(Edges);

      var connectedComponentsAlgorithm =
        new ConnectedComponentsAlgorithm<EntityNode, BaseEdge>(undirectedGraph);
      connectedComponentsAlgorithm.Compute();

      // The ComponentCount property on connectedComponentsAlgorithm specifies the number
      // of connected components

      // The Components dictionary maps each vertex to the component index
      // Hence, if there are two components (A<-B<-C and D<-E)
      // Then, ComponentCount = 2
      // Components =
      //   A -- 0
      //   B -- 0
      //   C -- 0
      //   D -- 1
      //   E -- 1

      var connectedEntities = new List<EntityNode>();
      int index = -1;

      if (connectedComponentsAlgorithm.Components.ContainsKey(entityNode))
      {
        index = connectedComponentsAlgorithm.Components[entityNode];
      }

      if (index != -1)
      {
        foreach (KeyValuePair<EntityNode, int> kvp in connectedComponentsAlgorithm.Components)
        {
          if (kvp.Value == index)
          {
            connectedEntities.Add(kvp.Key);
          }
        }
      }

      // Filter the original
      var filteredGraph =
        new FilteredBidirectionalGraph<EntityNode,
                                         BaseEdge,
                                         IBidirectionalGraph<EntityNode, BaseEdge>>
        (
          this,
          // Filter for those vertices which have been added to connectedEntities 
          v => connectedEntities.Exists(e => e.Entity.FullName == v.Entity.FullName),
          e => true
        );

      // Sort
      return filteredGraph.TopologicalSort().Reverse().ToList().ConvertAll(e => e.Entity);
    }

    public void Render()
    {
      GraphRenderer.Render(this);
    }

    public void Render(bool hasCycle)
    {
      GraphRenderer.Render(this, hasCycle);
    }

    public bool IsDerivedEntity(string entityName)
    {
      EntityNode entityNode = GetEntityNode(entityName);

      if (entityNode == null) return false;

      return OutDegree(entityNode) > 0;
    }

    public bool IsDirectSubclass(string parentEntityName, string derivedEntityName)
    {
      Entity parent = GetEntity(parentEntityName);
      if (parent == null) return false;

      Entity subClass = GetEntity(derivedEntityName);
      if (subClass == null) return false;

      BaseEdge edge = 
        Edges.Where(e => e.Source.Entity.FullName == derivedEntityName && 
                         e.Target.Entity.FullName == parentEntityName).SingleOrDefault();

      return edge != null;
    }
    #endregion

    #region Internal Methods

    internal InheritanceGraph GetInheritanceGraph(List<Entity> entities)
    {
      var inheritanceGraph = new InheritanceGraph();
      foreach(Entity derivedEntity in entities)
      {
        // Consider only derived entities that have not already been added to the inheritanceGraph
        if (inheritanceGraph.HasEntity(derivedEntity.FullName) || derivedEntity.EntityType != EntityType.Derived) continue;

        Check.Require(!String.IsNullOrEmpty(derivedEntity.ParentEntityName),
                      String.Format("ParentEntityName must have a value for derived entity '{0}'", derivedEntity));

        inheritanceGraph.AddEntity(derivedEntity);

        // Get the parent
        Entity parentEntity = entities.Find(p => p.FullName == derivedEntity.ParentEntityName);
        Check.Require(parentEntity != null,
                        String.Format("Cannot find parent entity '{0}' for '{1}'", 
                                      derivedEntity.ParentEntityName, derivedEntity));

        // Add parent, if necessary
        if (!inheritanceGraph.HasEntity(derivedEntity.ParentEntityName))
        {
          inheritanceGraph.AddEntity(parentEntity);
        }

        // Add edge, if necessary
        if (!inheritanceGraph.IsDirectSubclass(parentEntity.FullName, derivedEntity.FullName))
        {
          inheritanceGraph.AddInheritance(parentEntity, derivedEntity);
        }
      }

      return inheritanceGraph;
    }

    /// <summary>
    ///   Sort the specified entities according to their inheritance hierarchies. Parents before children.
    /// </summary>
    /// <param name="entities"></param>
    internal void SortByHierarchy(ref List<Entity> entities)
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
    ///   Set the RootEntityName for each of the derived entities in the graph
    /// </summary>
    internal void FixupRoot()
    {
      foreach(EntityNode entityNode in Vertices)
      {
        if (!String.IsNullOrEmpty(entityNode.Entity.RootEntityName)) continue;

        List<Entity> inheritanceHierarchy = GetInheritanceHierarchy(entityNode.Entity.FullName);

        Entity root = null;
        for (int i = 0; i < inheritanceHierarchy.Count; i++)
        {
          if (i == 0)
          {
            root = inheritanceHierarchy[0];
            continue;
          }

          inheritanceHierarchy[i].RootEntityName = root.FullName;
        }
      }
    }

    /// <summary>
    ///   Initialize this graph from the specified inheritanceGraph
    /// </summary>
    /// <param name="inheritanceGraph"></param>
    internal void CopyFrom(InheritanceGraph inheritanceGraph)
    {
      Check.Require(inheritanceGraph != null, "inheritanceGraph cannot be null");

      // Clear vertices and edges
      Clear();

      inheritanceGraph.Vertices.ForEach(v => AddVertex(v.Clone()));
      inheritanceGraph.Edges.ForEach(e => AddEdge(e.Clone()));
    }

    /// <summary>
    ///   Return true, if the specified property (for the specified entity)
    ///   is on a derived entity and if there is a property with
    ///   the same name anywhere up the inheritance hierarchy
    /// </summary>
    /// <returns></returns>
    internal bool IsPropertyOverridable(string propertyName, string entityName)
    {
      if (!IsDerivedEntity(entityName))
        return false;

      bool overridable = false;
      List<Entity> ancestors = GetAncestors(entityName);

      foreach(Entity ancestor in ancestors)
      {
        if (ancestor.HasProperty(propertyName))
        {
          overridable = true;
          break;
        }
      }

      return overridable;
    }

    /// <summary>
    ///   Return false, if there is more than one relationship between the two hierarchies
    ///   for entityName1 and entityName2.
    /// </summary>
    /// <param name="entityName1"></param>
    /// <param name="entityName2"></param>
    /// <param name="entityGraph"></param>
    /// <returns></returns>
    internal bool AtMostOneRelationshipBetweenHierarchies(string entityName1,
                                                          string entityName2,
                                                          EntityGraph entityGraph)
    {
      List<Entity> hierarchy1 = GetInheritanceHierarchy(entityName1);
      List<Entity> hierarchy2 = GetInheritanceHierarchy(entityName2);

      var relationshipEdges = new List<RelationshipEdge>();

      foreach (Entity entity1 in hierarchy1)
      {
        foreach (Entity entity2 in hierarchy2)
        {
          RelationshipEdge relationshipEdge =
            entityGraph.GetRelationshipEdge(entity1.FullName, entity2.FullName);

          if (relationshipEdge != null)
          {
            relationshipEdges.Add(relationshipEdge);
          }
        }
      }

      logger.Debug(String.Format("Found '{0}' relationships '{1}' " +
                                 "between hierarchy '{2}' and hierarchy '{3}'",
                                 relationshipEdges.Count,
                                 StringUtil.Join(" , ", relationshipEdges, r => r.RelationshipEntity.ToString()),
                                 StringUtil.Join(" , ", hierarchy1, e => e.ToString()),
                                 StringUtil.Join(" , ", hierarchy2, e => e.ToString())));


      return relationshipEdges.Count <= 1 ? true : false;
    }

    

    internal void AddInheritance(Entity parentEntity, Entity derivedEntity)
    {
      Check.Require(parentEntity != null, "parentEntity cannot be null");
      Check.Require(derivedEntity != null, "derivedEntity cannot be null");
      Check.Require(derivedEntity.EntityType == EntityType.Derived, 
                    String.Format("Derived entity '{0}' must have an EntityType of Derived", derivedEntity));
      Check.Require(!String.IsNullOrEmpty(derivedEntity.ParentEntityName), 
                    String.Format("Derived entity '{0}' must have a valid parent entity name", derivedEntity));
      Check.Require(derivedEntity.ParentEntityName == parentEntity.FullName, 
                    String.Format("The parent entity name '{0}' for derived entity '{1}' does not match the name of the parent entity '{2}'", 
                                  derivedEntity.ParentEntityName, derivedEntity, parentEntity));

      bool addedParent = false;
      bool addedChild = false;

      EntityNode parentEntityNode = GetEntityNode(parentEntity.FullName);
      if (parentEntityNode == null)
      {
        parentEntityNode = new EntityNode() {Entity = parentEntity};
        AddVertex(parentEntityNode);
        addedParent = true;
      }

      EntityNode derivedEntityNode = GetEntityNode(derivedEntity.FullName);
      if (derivedEntityNode == null)
      {
        derivedEntityNode = new EntityNode() {Entity = derivedEntity};
        AddVertex(derivedEntityNode);
        addedChild = true;
      }

      BaseEdge edge = null;
      if (!IsDirectSubclass(parentEntity.FullName, derivedEntity.FullName))
      {
        edge = new BaseEdge(derivedEntityNode, parentEntityNode);
        AddEdge(edge);
      }

      // Check for cycle
      List<string> loopEdges;
      if (HasCycle(out loopEdges))
      {
        string message = 
          String.Format("Deriving entity '{0}' from entity '{1}' creates the following cycle in the inheritance graph. '{2}' \n" +
                        "An image of the inheritance graph with the cycle is generated in '{3}', if GraphViz is installed",
                        derivedEntity.FullName, 
                        parentEntity.FullName, 
                        String.Join(", ", loopEdges.ToArray()),
                        Name.GetInheritanceGraphDotFileName(true));

        Render(true);

        // Undo
        if (addedParent)
        {
          RemoveVertex(parentEntityNode);
        }

        if (addedChild)
        {
          RemoveVertex(derivedEntityNode);
        }

        if (edge != null)
        {
          RemoveEdge(edge);
        }

        throw new MetadataException(message);
      }
    }

    /// <summary>
    ///   Return the all members of the inheritance chain that this entity is a part of.
    /// </summary>
    /// <param name="entity"></param>
    /// <returns></returns>
    internal List<Entity> GetConnectedEntities(Entity entity)
    {
      var connectedEntities = GetInheritanceHierarchy(entity.FullName);
      connectedEntities.Remove(entity);
      return connectedEntities;
    }

    public InheritanceGraph RestrictByDb(string databaseName)
    {
      Check.Require(!String.IsNullOrEmpty(databaseName), "databaseName cannot be null or empty");
      var graph = new InheritanceGraph();

      foreach (EntityNode entityNode in Vertices)
      {
        if (entityNode.Entity.DatabaseName.ToLower() != databaseName.ToLower()) continue;
        graph.AddVertex(entityNode);
      }

      foreach (BaseEdge edge in Edges)
      {
        if (graph.Vertices.Contains(edge.Source) && graph.Vertices.Contains(edge.Target))
        {
          graph.AddEdge(edge);
        }
      }

      return graph;
    }

    public InheritanceGraph RestrictByDbAndExtension(string databaseName, string extensionName)
    {
      Check.Require(!String.IsNullOrEmpty(databaseName), "databaseName cannot be null or empty");
      Check.Require(!String.IsNullOrEmpty(extensionName), "databaseName cannot be null or empty");

      var graph = new InheritanceGraph();

      foreach (EntityNode entityNode in Vertices)
      {
        if (entityNode.Entity.DatabaseName.ToLower() == databaseName.ToLower() &&
            entityNode.Entity.ExtensionName.ToLower() == extensionName.ToLower())
        {
          graph.AddVertex(entityNode);
        }
      }

      foreach (BaseEdge edge in Edges)
      {
        if (graph.Vertices.Contains(edge.Source) && graph.Vertices.Contains(edge.Target))
        {
          graph.AddEdge(edge);
        }
      }

      return graph;
    }
    #endregion

    #region Private Methods


    #endregion

    #region Data
    #endregion
  }
}
