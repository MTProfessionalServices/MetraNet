namespace MetraTech.ICE.ExpressionEngine
{
  using System;
  using System.Collections.Generic;
  using System.Linq;
  using System.Text;
  using System.Collections;
using MetraTech.ICE.Layout;
  using System.Text.RegularExpressions;
  using System.IO;

  /// <summary>
  /// TODO: Update summary.
  /// </summary>
  public class RefactorProperties
  {

    public void RefactorPropertyNames(List<Entity> entites, string oldName, string newName)
    {
      foreach (var entity in entites)
      {
        foreach (var property in entity.Properties)
        {
          if (oldName.Equals(property.Name, StringComparison.InvariantCultureIgnoreCase))
            property.Name = newName;
        }
      }
    }

    public List<Entity> GetEntitiesMatchingProperty(string propertyName)
    {
      var allEntities = GetEntities();
      var entities = new List<Entity>();
      foreach (var entity in allEntities)
      {
        foreach (var property in entity.Properties)
        {
          if (propertyName.Equals(property.Name, StringComparison.InvariantCultureIgnoreCase))
            entities.Add(entity);
        }
      }
      return entities;
    }

    public List<Entity> GetEntities()
    {
      var entities = new List<Entity>();
      entities.AddRange(GetEntities(ElementType.AccountView));
      entities.AddRange(GetEntities(ElementType.ParameterTable));
      entities.AddRange(GetEntities(ElementType.ProductView));
      entities.AddRange(GetEntities(ElementType.ServiceDefinition));
      return entities;
    }

    public List<Entity> GetEntities(ElementType elementType)
    {
      var entities = new List<Entity>();
      SortedList elements = Config.Instance.GetElementList(elementType);
      foreach (ElementBase elementBase in elements.Values)
      { 
        var entity = new Entity(elementBase);
        entities.Add(entity);
      }
      return entities;
    }

    public void GetAllPluginMatches(string propertyName)
    {
      var plugins = GetAllPlugins();
      var regex = new Regex(propertyName, RegexOptions.IgnoreCase);
      
      var matches = new List<string>();
      foreach (var pluginInstance in plugins)
      {
        var lines = File.ReadAllLines(pluginInstance.FilePath);
        for (int index = 0; index > lines.Length; index++)
        {
          var line = lines[index];
          if (regex.IsMatch(line))
            matches.Add(string.Format("Line{0}: {1}", index + 1, line));
        }
      }
    }

    public List<PlugInInstance> GetAllPlugins()
    {
      var plugins = new List<PlugInInstance>();
      foreach (Stage stage in Config.Instance.Stages.Values)
      {
        for (int index=0; index < stage.PlugInInstances.Count; index++)
        {
          plugins.Add((PlugInInstance)stage.PlugInInstances[index]);
        }
      }
      return plugins;
    }

    public void GetLayouts()
    {
      foreach(LayoutPage page in Config.Instance.PageLayouts.Values)
      {
        var fields = page.LayoutModule.GetFields();
      }
    }
  }
}
