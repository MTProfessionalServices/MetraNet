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
using QuickGraph.Algorithms.Observers;
using QuickGraph.Algorithms.Search;
using QuickGraph.Predicates;

namespace MetraTech.BusinessEntity.DataAccess.Metadata.Graph
{
  [Serializable]
  public class BuildGraph : BidirectionalGraph<AssemblyNode, DependsOnEdge>
  {
    #region Public Methods
    public new BuildGraph Clone()
    {
      var buildGraph = new BuildGraph();

      foreach (AssemblyNode node in Vertices)
      {
        buildGraph.AddVertex(node);
      }

      foreach (DependsOnEdge edge in Edges)
      {
        buildGraph.AddEdge(edge);
      }

      return buildGraph;
    }

    /// <summary>
    ///   Return the list of dependent namespaces 
    /// </summary>
    /// <param name="entityName"></param>
    /// <returns></returns>
    public List<string> GetDependentNamespaces(string entityName)
    {
      AssemblyNode assemblyNode = GetAssemblyNode(entityName);
      if (assemblyNode == null)
      {
        return new List<string>();
      }

      List<AssemblyNode> dependencyHierarchy = GetDependencyHierarchy(assemblyNode.AssemblyName);

      return dependencyHierarchy.TakeWhile(a => a.AssemblyName != assemblyNode.AssemblyName)
                                .ToList()
                                .ConvertAll(a => Name.GetEntityNamespace(a.ExtensionName, a.EntityGroupName));
    }

    /// <summary>
    ///   Return the list of assemblies that need to be built before building the assembly for the specified entity
    /// </summary>
    /// <param name="entity"></param>
    /// <returns></returns>
    public List<string> GetDependentAssemblyNames(Entity entity)
    {
      Check.Require(entity != null, "entity cannot be null");
      return GetDependentAssembliesForEntityGroup(entity.ExtensionName, entity.EntityGroupName);
    }

    public void Render()
    {
      GraphRenderer.Render(this);
    }

    public void Render(bool hasCycle)
    {
      GraphRenderer.Render(this, hasCycle);
    }

    public virtual bool HasCycle(out List<string> loopEdges)
    {
      loopEdges = new List<string>();

      // Variable to hold loop edges in anonymous method. Cannot use out parameter in anonymous method
      var internalLoopEdges = new List<string>();

      var dfs = new DepthFirstSearchAlgorithm<AssemblyNode, DependsOnEdge>(this);
      var predecessorRecorder = new VertexPredecessorRecorderObserver<AssemblyNode, DependsOnEdge>();
      bool foundCycle = false;
      AssemblyNode lastNode = null;
      DependsOnEdge lastEdge;

      using (predecessorRecorder.Attach(dfs))
      {
        dfs.BackEdge += args =>
        {
          logger.Debug("Found cycle in graph");
          lastEdge = args;
          dfs.Abort();
          IEnumerable<DependsOnEdge> edges;
          predecessorRecorder.TryGetPath(lastNode, out edges);

          if (edges != null)
          {
            foreach (DependsOnEdge edge in edges)
            {
              internalLoopEdges.Add(edge.ToString());
            }
          }

          internalLoopEdges.Add(lastEdge.ToString());

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

    #endregion

    #region Internal Methods

    internal void CopyFrom(BuildGraph buildGraph)
    {
      Check.Require(buildGraph != null, "buildGraph cannot be null");

      // Clear vertices and edges
      Clear();
  
      buildGraph.Vertices.ForEach(v => AddVertex(v.Clone()));
      buildGraph.Edges.ForEach(e => AddEdge(e.Clone()));
    }

    /// <summary>
    ///   Create and add an assembly node for the specified entity (if one doesn't exist)
    /// </summary>
    /// <param name="entity"></param>
    internal void AddAssemblyNode(Entity entity)
    {
      Check.Require(entity != null, "Cannot add assembly node for null entity");
      Check.Require(!String.IsNullOrEmpty(entity.ExtensionName),
                    String.Format("ExtensionName cannot be null or empty on entity '{0}'", entity));
      Check.Require(!String.IsNullOrEmpty(entity.EntityGroupName),
                    String.Format("EntityGroupName cannot be null or empty on entity '{0}'", entity));

      AssemblyNode assemblyNode = GetAssemblyNode(entity.FullName);

      if (assemblyNode == null)
      {
        AddVertex(new AssemblyNode(entity.ExtensionName, entity.EntityGroupName));
      }
    }

    /// <summary>
    ///   Make assembly for sourceEntityName depend on assembly for targetEntityName
    /// </summary>
    /// <param name="sourceEntityName"></param>
    /// <param name="targetEntityName"></param>
    internal void AddDependency(string sourceEntityName, string targetEntityName)
    {
      AssemblyNode sourceAssemblyNode = GetAssemblyNode(sourceEntityName);
      Check.Require(sourceAssemblyNode != null, String.Format("Cannot find assembly node for entity '{0}' in build graph", sourceEntityName));

      AssemblyNode targetAssemblyNode = GetAssemblyNode(targetEntityName);
      Check.Require(targetAssemblyNode != null, String.Format("Cannot find assembly node for entity '{0}' in build graph", targetEntityName));

      if (!sourceAssemblyNode.Equals(targetAssemblyNode))
      {
        AddDependency(sourceAssemblyNode, targetAssemblyNode);
      }
    }

    /// <summary>
    ///    Make Source depend on Target ie. target must be built before source. 
    /// </summary>
    /// <param name="source"></param>
    /// <param name="target"></param>
    internal void AddDependency(AssemblyNode source, AssemblyNode target)
    {
      Check.Require(source != null, "source assembly node cannot be null");
      Check.Require(target != null, "target assembly node cannot be null");
      Check.Require(Vertices.Contains(source), String.Format("Cannot find source '{0}' in the build graph", source));
      Check.Require(Vertices.Contains(target), String.Format("Cannot find target '{0}' in the build graph", target));

      DependsOnEdge edge =
       Edges.Where(e => (e.Source.Equals(source) &&
                         e.Target.Equals(target))).SingleOrDefault();

      // edge exists
      if (edge != null)
      {
        return;
      }

      edge = new DependsOnEdge(source, target);
      AddEdge(edge);

      // Check for cycle
      List<string> loopEdges;
      if (HasCycle(out loopEdges))
      {
        string message =
          String.Format(
            "Assembly '{0}' cannot be dependent on assembly '{1}' because it creates the following cycle in the build dependency graph. '{2}' \n" +
            "An image of the build dependency graph with the cycle is generated in '{3}' if GraphViz is installed",
            source,
            target,
            String.Join(", ", loopEdges.ToArray()),
            Name.GetBuildGraphDotFileName(true));

        Render(true);

        RemoveEdge(edge);

        throw new MetadataException(message);
      }
    }
    
    internal AssemblyNode GetAssemblyNode(string entityName)
    {
      string extensionName, entityGroupName;
      Name.GetExtensionAndEntityGroup(entityName, out extensionName, out entityGroupName);
      return GetAssemblyNode(extensionName, entityGroupName);
    }

    /// <summary>
    ///  Return the assembly node with the specified extensionName and entityGroupName
    /// </summary>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    /// <returns></returns>
    internal AssemblyNode GetAssemblyNode(string extensionName, string entityGroupName)
    {
      Check.Require(!String.IsNullOrEmpty(extensionName), "extensionName cannot be null");
      Check.Require(!String.IsNullOrEmpty(entityGroupName), "entityGroupName cannot be null");

      AssemblyNode assemblyNode =
        Vertices.Where(v => v.ExtensionName.ToLower() == extensionName.ToLower() &&
                            v.EntityGroupName.ToLower() == entityGroupName.ToLower()).SingleOrDefault();
      return assemblyNode;
    }

    /// <summary>
    ///    assemblyName must end with ".dll" and cannot have a path
    /// </summary>
    /// <param name="assemblyName"></param>
    /// <returns></returns>
    internal AssemblyNode GetAssemblyNodeForAssembly(string assemblyName)
    {
      Check.Require(!String.IsNullOrEmpty(assemblyName), "assemblyName cannot be null");

      AssemblyNode assemblyNode =
        Vertices.Where(v => v.AssemblyName.ToLower() == assemblyName.ToLower()).SingleOrDefault();

      return assemblyNode;
    }

    /// <summary>
    ///   Return true if the assembly node for the specified entity is in the graph
    /// </summary>
    /// <param name="entityName"></param>
    /// <returns></returns>
    internal bool HasAssemblyNode(string entityName)
    {
      return GetAssemblyNode(entityName) != null;
    }
    
    /// <summary>
    ///   Return the list of dependent assemblies (which must be built first)
    ///   for the specified assembly sorted in build order.
    ///   
    ///   assemblyName must end with ".dll" and cannot have a path
    /// </summary>
    /// <param name="assemblyName"></param>
    /// <returns></returns>
    internal List<AssemblyNode> GetDependencyHierarchy(string assemblyName)
    {
      var dependencyChain = new List<AssemblyNode>();

      AssemblyNode assemblyNode = GetAssemblyNodeForAssembly(assemblyName);

      if (assemblyNode == null) return dependencyChain;

      var undirectedGraph = new UndirectedGraph<AssemblyNode, DependsOnEdge>();
      undirectedGraph.AddVerticesAndEdgeRange(Edges);

      var connectedComponentsAlgorithm =
        new ConnectedComponentsAlgorithm<AssemblyNode, DependsOnEdge>(undirectedGraph);
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

      var connectedAssemblies = new List<AssemblyNode>();
      int index = -1;

      if (connectedComponentsAlgorithm.Components.ContainsKey(assemblyNode))
      {
        index = connectedComponentsAlgorithm.Components[assemblyNode];
      }

      if (index != -1)
      {
        foreach (KeyValuePair<AssemblyNode, int> kvp in connectedComponentsAlgorithm.Components)
        {
          if (kvp.Value == index)
          {
            connectedAssemblies.Add(kvp.Key);
          }
        }
      }

      // Filter the original
      var filteredGraph =
        new FilteredBidirectionalGraph<AssemblyNode, DependsOnEdge, IBidirectionalGraph<AssemblyNode, DependsOnEdge>>
        (
          this,
          // Filter for those vertices which have been added to connectedAssemblies 
          v => connectedAssemblies.Exists(a => a.AssemblyName == v.AssemblyName),
          e => true
        );

      // Sort
      return filteredGraph.TopologicalSort().Reverse().ToList();
    }

    /// <summary>
    ///   Sort the specified entityGroupDataList by build dependency
    /// </summary>
    /// <param name="entityGroupDataList"></param>
    internal void SortByBuildDependency(ref List<EntityGroupData> entityGroupDataList)
    {
      // Topological sort on the assembly nodes, then reverse to get the least dependent nodes first
      List<AssemblyNode> sortedAssemblyNodes = this.TopologicalSort().Reverse().ToList();

      // Sort the items in entityGroupDataList according to the items in sortedAssemblyNodes
      entityGroupDataList.Sort(delegate(EntityGroupData entityGroupData1, EntityGroupData entityGroupData2)
                                 {
                                   int index1 = sortedAssemblyNodes.FindIndex(a => a.AssemblyName.ToLower() == entityGroupData1.EntityAssemblyName.ToLower());
                                   Check.Require(index1 != -1,
                                                 String.Format("Cannot find EntityGroupData '{0}' in the build graph", entityGroupData1));

                                   int index2 = sortedAssemblyNodes.FindIndex(a => a.AssemblyName.ToLower() == entityGroupData2.EntityAssemblyName.ToLower());
                                   Check.Require(index2 != -1,
                                                 String.Format("Cannot find EntityGroupData '{0}' in the build graph", entityGroupData2));

                                   return index1.CompareTo(index2);
                                 });
    }
    
    internal List<string> GetDependentAssembliesForExtension(string extensionName)
    {
      var dependentAssemblies = new List<string>();
      // TODO Implement when we allow dependencies between extensions
      return dependentAssemblies;
    }

    /// <summary>
    ///   Return the list of assemblies that need to be built before building the assembly for
    ///   the specified extensionName/entityGroupName
    /// </summary>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    /// <returns></returns>
    internal List<string> GetDependentAssembliesForEntityGroup(string extensionName, string entityGroupName)
    {
      AssemblyNode assemblyNode = GetAssemblyNode(extensionName, entityGroupName);
      if (assemblyNode == null)
      {
        return new List<string>();
      }

      List<AssemblyNode> dependencyHierarchy = GetDependencyHierarchy(assemblyNode.AssemblyName);

      return dependencyHierarchy.TakeWhile(a => a.AssemblyName != assemblyNode.AssemblyName)
                                .ToList()
                                .ConvertAll(a => a.AssemblyName);
    }

    /// <summary>
    ///    Return the list of AssemblyNodes that that depend on the specified extension/entity group
    /// </summary>
    /// <param name="extensionName"></param>
    /// <param name="entityGroupName"></param>
    /// <returns></returns>
    internal List<AssemblyNode> GetAssembliesThatDependOnEntityGroup(string extensionName, string entityGroupName)
    {
      var assemblyNodes = new List<AssemblyNode>();
      AssemblyNode assemblyNode = GetAssemblyNode(extensionName, entityGroupName);
      if (assemblyNode == null)
      {
        return assemblyNodes;
      }

      List<AssemblyNode> dependencyHierarchy = GetDependencyHierarchy(assemblyNode.AssemblyName);
      return dependencyHierarchy.SkipWhile(a => a.AssemblyName != assemblyNode.AssemblyName).ToList();
    }
    #endregion

    #region Private Methods


    #endregion

    #region Data
    internal static ILog logger = LogManager.GetLogger("BuildGraph");
    #endregion
  }
}
