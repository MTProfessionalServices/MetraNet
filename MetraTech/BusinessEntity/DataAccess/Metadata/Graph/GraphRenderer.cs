using System;
using MetraTech.BusinessEntity.Core;
using QuickGraph;
using QuickGraph.Graphviz;
using QuickGraph.Graphviz.Dot;

namespace MetraTech.BusinessEntity.DataAccess.Metadata.Graph
{
  public static class GraphRenderer 
  {
    public static void Render(EntityGraph graph)
    {
      Render(graph, false);
    }

    public static void Render(EntityGraph graph, bool hasCycle)
    {
      var graphviz = new GraphvizAlgorithm<EntityNode, RelationshipEdge>(graph);
      graphviz.ImageType = GraphvizImageType.Png;

      graphviz.FormatEdge += delegate(object sender, FormatEdgeEventArgs<EntityNode, RelationshipEdge> e)
      {
        string label = String.Empty;
        if (e.Edge.IsExtension)
        {
          label = "Extends";
        }
        else
        {
          label = e.Edge.RelationshipEntity.RelationshipType.ToString();
        }

        //if (e.Edge.RelationshipEntity.IsInterGroup)
        //{
        //  label += " *";
        //}

        e.EdgeFormatter.Label.Value = label;
      };

      graphviz.FormatVertex += delegate(object sender, FormatVertexEventArgs<EntityNode> e)
      {
        e.VertexFormatter.Label = e.Vertex.Entity.FullName;
      };

      // render
      var dotEngine = new DotEngine();
      dotEngine.DotFile = Name.GetEntityGraphDotFileName(hasCycle);
      graphviz.Generate(dotEngine, null);
    }

    public static void Render(InheritanceGraph graph)
    {
      Render(graph, false);
    }

    public static void Render(InheritanceGraph graph, bool hasCycle)
    {
      var graphviz = new GraphvizAlgorithm<EntityNode, BaseEdge>(graph);
      graphviz.ImageType = GraphvizImageType.Png;

      graphviz.FormatVertex += delegate(object sender, FormatVertexEventArgs<EntityNode> e)
      {
        e.VertexFormatter.Label = e.Vertex.Entity.FullName; 
      };


      // render
      var dotEngine = new DotEngine();
      dotEngine.DotFile = Name.GetInheritanceGraphDotFileName(hasCycle);
      graphviz.Generate(dotEngine, null);
    }

    public static void Render(BuildGraph graph)
    {
      Render(graph, false);
    }

    public static void Render(BuildGraph graph, bool hasCycle)
    {
      var graphviz = new GraphvizAlgorithm<AssemblyNode, DependsOnEdge>(graph);
      graphviz.ImageType = GraphvizImageType.Png;

      graphviz.FormatVertex += delegate(object sender, FormatVertexEventArgs<AssemblyNode> e)
      {
        e.VertexFormatter.Label = e.Vertex.AssemblyName;
      };


      // render
      var dotEngine = new DotEngine();
      dotEngine.DotFile = Name.GetBuildGraphDotFileName(hasCycle);
      graphviz.Generate(dotEngine, null);
    }
  }
}
