using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using QuickGraph;
using QuickGraph.Algorithms;
using QuickGraph.Algorithms.ConnectedComponents;
using QuickGraph.Algorithms.Observers;
using QuickGraph.Algorithms.Search;

namespace MetraTech.BusinessEntity.DataAccess.Metadata.Graph
{
  /// <summary>
  ///   A graph derived from BaseGraph will have the vertex type set to EntityNode. The edge type can be
  ///   specified via the parameter TEdge. Each edge type must derive from BaseEdge.
  /// 
  ///   This base class provides functionality that can be defined in terms of the vertex and BaseEdge. e.g. loop detection
  ///   Functionality that depends on the edge type must be defined in the derived classes.
  /// </summary>
  /// <typeparam name="TEdge"></typeparam>
  [Serializable]
  public class BaseGraph<TEdge> : BidirectionalGraph<EntityNode, BaseEdge>
                                  where TEdge : BaseEdge
  {
    #region Public Methods
    public virtual bool HasEntity(string entityName)
    {
      EntityNode entityNode = Vertices.Where(v => v.Entity.FullName == entityName).SingleOrDefault();
      return entityNode != null;
    }

    public virtual bool HasCycle(out List<string> loopEdges)
    {
      loopEdges = new List<string>();

      // Variable to hold loop edges in anonymous method. Cannot use out parameter in anonymous method
      var internalLoopEdges = new List<string>();

      var dfs = new DepthFirstSearchAlgorithm<EntityNode, BaseEdge>(this);
      var predecessorRecorder = new VertexPredecessorRecorderObserver<EntityNode, BaseEdge>();
      bool foundCycle = false;
      EntityNode lastNode = null;
      BaseEdge lastEdge;

      using (predecessorRecorder.Attach(dfs))
      {
        dfs.BackEdge += args =>
        {
          logger.Debug("Found cycle in graph");
          lastEdge = args;
          dfs.Abort();
          IEnumerable<BaseEdge> edges;
          predecessorRecorder.TryGetPath(lastNode, out edges);

          if (edges != null)
          {
            foreach (BaseEdge edge in edges)
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

    public virtual Entity GetEntity(string entityName)
    {
      Entity entity = null;
      EntityNode entityNode = Vertices.Where(v => v.Entity.FullName == entityName).SingleOrDefault();
      if (entityNode != null)
      {
        entity = entityNode.Entity;
      }

      return entity;
    }
    #endregion

    #region Internal Methods

    internal virtual EntityNode GetEntityNode(string entityName)
    {
      return Vertices.Where(v => v.Entity.FullName == entityName).SingleOrDefault();
    }

    internal virtual void AddEntity(Entity entity)
    {
      Check.Require(entity != null, "entity cannot be null");
      Entity existingEntity = GetEntity(entity.FullName);
      Check.Require(existingEntity == null, String.Format("The specified entity '{0}' already exists in the graph", entity.FullName));
      AddVertex(new EntityNode() { Entity = entity });
    }

    #endregion

    #region Data
    internal static ILog logger = LogManager.GetLogger("BaseGraph");
    #endregion
  }
}
