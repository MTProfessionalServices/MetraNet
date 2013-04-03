using System;
using System.Collections;
using MetraTech.ICE.ExpressionEngine.Enumerations;
namespace MetraTech.ICE.ExpressionEngine
{
  using System.Collections.Generic;
  
  public class RefactorEngine
  {
    #region Properties 
    public RefactorMode RefactorMode { get; set; }
    public string OldPropertyName { get; set; }
    public string NewPropertyName { get; set; }
    public string OldEnumSpace { get; set; }
    public string NewEnumSpace { get; set; }
    public string OldEnumType { get; set; }
    public string NewEnumType { get; set; }
    #endregion

    #region Methods

    public void Validate(bool isSearch)
    {
      switch (RefactorMode)
      {
        case RefactorMode.PropertyName:
          if (string.IsNullOrEmpty(OldPropertyName))
            throw new Exception("Old Property Name isn't specified");
          if (!isSearch && string.IsNullOrEmpty(NewPropertyName))
            throw new Exception("New Property Name isn't specified");
          break;
        case RefactorMode.Enum:
          if (string.IsNullOrEmpty(OldEnumSpace))
            throw new Exception("OldEnumSpace isn't specified");
          if (!isSearch && string.IsNullOrEmpty(NewEnumSpace))
            throw new Exception("NewEnumSpace isn't specified");
          break;
      }
    }

    public List<RefactorItem> GetRefactorItems()
    {
      Validate(true);
      var refactorItems = new List<RefactorItem>();

      //Process all of the elements with property collections
      var elements = GetElementsWithPropertyCollections();
      foreach (var element in elements)
      {
        var refactorItem = new RefactorItem(this, element);
        refactorItem.UpdateAllProperties();
        refactorItem.UpdateMatches();
        if (refactorItem.PropertyMatches.Count > 0)
          refactorItems.Add(refactorItem);
      }

      //Process plug-ins
      var plugins = GetAllPlugins();
      foreach (var plugin in plugins)
      {
        switch (plugin.ProgID)
        {
          case "MetraPipeline.MTSQLInterpreter.1":
          case "MetraPipeline.MTSQLBatchQuery.1":
            var refactorItem = new RefactorItem(this, plugin);
            refactorItem.UpdateMtsqlMatches();
            if (refactorItem.Matches.Count > 0)
              refactorItems.Add(refactorItem);
            break;
          default:
            //We only refactor property names in general plugin files
            if (OldPropertyName != null)
            {
              var matches = RefactorHelper.GetInnerXmlMatchs(plugin.FilePath, OldPropertyName);
              if (matches.Count > 0)
              {
                var rItem = new RefactorItem(this, matches, plugin.FilePath);
                refactorItems.Add(rItem);
              }
            }
            break;
        }
      }

      //Process C# files
      //Process PageLayouts
      //Process GridLayouts

      return refactorItems;
    }

    public void RefactorItem(List<RefactorItem> refactorItems)
    {
      Validate(false);
      foreach (var refactorItem in refactorItems)
      {
        refactorItem.Refactor();
        refactorItem.Save();
      }
    }

    public List<ElementBase> GetElementsWithPropertyCollections()
    {
      var elements = new List<ElementBase>();
      elements.AddRange(GetElements(ElementType.AccountView).ToArray());
      elements.AddRange(GetElements(ElementType.ParameterTable).ToArray());
      elements.AddRange(GetElements(ElementType.ProductView).ToArray());
      elements.AddRange(GetElements(ElementType.ServiceDefinition).ToArray());
      return elements;
    }

    private List<ElementBase> GetElements(ElementType elementType)
    {
      var elements = new List<ElementBase>();
      SortedList list = Config.Instance.GetElementList(elementType);
      foreach (ElementBase element in list.Values)
      {
        elements.Add(element);
      }
      return elements;
    }

    public List<PlugInInstance> GetAllPlugins()
    {
      var plugins = new List<PlugInInstance>();
      foreach (Stage stage in Config.Instance.Stages.Values)
      {
        for (int index = 0; index < stage.PlugInInstances.Count; index++)
        {
          plugins.Add((PlugInInstance)stage.PlugInInstances[index]);
        }
      }
      return plugins;
    }

    public void RenameAndSaveActualEnumType()
    {
      throw new NotImplementedException();
    }
    #endregion
  }
}
