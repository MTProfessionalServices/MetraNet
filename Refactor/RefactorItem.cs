using System;
using System.Text;
using System.Xml;
using MetraTech.ICE.ExpressionEngine.Enumerations;

namespace MetraTech.ICE.ExpressionEngine
{
  using System.Collections.Generic;

  public class RefactorItem
  {
    #region Properties

    public RefactorEngine Engine { get; private set; }

    public RefactorType RefactorType;

    /// <summary>
    /// The element containing something to be refactored
    /// </summary>
    public ElementBase Element;

    public PlugInInstance SqlPlugin;
    private MTSQLScript MtsqlScript;

    public List<XmlNode> XmlNodes;

    /// <summary>
    /// The list of properties, if any, associated with the Element. AVs, PVs, PTs and SDs will have these
    /// </summary>
    public PropertyCollection PropertyMatches = new PropertyCollection();
    private PropertyCollection AllProperties = new PropertyCollection();

    public string FilePath { get; set; }

    /// <summary>
    /// Text matches associated with the element. We expect MTSQL and BatchMTSQL to contain these
    /// </summary>
    public List<string> Matches = new List<string>();
    #endregion

    #region Constructor
    public RefactorItem(RefactorEngine engine, PlugInInstance sqlPlugin)
    {
      Engine = engine;
      SqlPlugin = sqlPlugin;
      RefactorType = RefactorType.Mtsql;
    }
    public RefactorItem(RefactorEngine engine, List<XmlNode> xmlNodes, string filePath)
    {
      Engine = engine;
      XmlNodes = xmlNodes;
      FilePath = filePath;
      RefactorType = RefactorType.XmlFile;
    }
    //public RefactorItem(RefactorEngine engine)
    //{
    //  Engine = engine;
    //}
    public RefactorItem(RefactorEngine engine, string filePath)
    {
      Engine = engine;
      FilePath = filePath;
    }

    public RefactorItem(RefactorEngine engine, ElementBase element)
    {
      Engine = engine;
      Element = element;
      RefactorType = RefactorType.PropertyList;
    }
    #endregion

    #region Methods

    public void UpdateAllProperties()
    {
      switch (Element.ElementType)
      {
        case ElementType.AccountView:
          AppendPropertyReferences(((AccountView)Element).Properties);
          break;
        case ElementType.ParameterTable:
          AppendPropertyReferences(((ParameterTable)Element).Conditions);
          AppendPropertyReferences(((ParameterTable)Element).Actions);
          break;
        case ElementType.ProductView:
          AppendPropertyReferences(((ProductView)Element).Properties);
          break;
        case ElementType.ServiceDefinition:
          AppendPropertyReferences(((ServiceDefinition)Element).Properties);
          break;
      }
    }

    private void AppendPropertyReferences(PropertyCollection sourceProperties)
    {
      foreach (var property in sourceProperties)
      {
        AllProperties.Add(property);
      }
    }

    public void UpdateMatches()
    {
      if (Engine.RefactorMode == RefactorMode.PropertyName)
        UpdatePropertyNameMatches();
      else if (Engine.RefactorMode == RefactorMode.Enum)
        UpdateEnumMatches();
    }

    private void UpdatePropertyNameMatches()
    {
      foreach (var property in AllProperties)
      {
        if (Engine.OldPropertyName.Equals(property.Name, StringComparison.InvariantCultureIgnoreCase))
          PropertyMatches.Add(property);
      }
    }

    public void UpdateEnumMatches()
    {
      foreach (var property in AllProperties)
      {
        if (property.DataTypeInfo.Type != DataType._enum)
          continue;

        if (!string.IsNullOrEmpty(Engine.OldEnumSpace) && Engine.OldEnumSpace.Equals(property.DataTypeInfo.EnumSpace, StringComparison.InvariantCultureIgnoreCase))
          PropertyMatches.Add(property);
        else if (!string.IsNullOrEmpty(Engine.OldEnumType) && Engine.OldEnumType.Equals(property.DataTypeInfo.EnumType, StringComparison.InvariantCultureIgnoreCase))
          PropertyMatches.Add(property);
      }
    }

    public void Refactor()
    {
      if (RefactorType == RefactorType.PropertyList)
      {
        foreach (var property in PropertyMatches)
        {
          if (Engine.RefactorMode == RefactorMode.PropertyName)
            property.Name = Engine.NewPropertyName;
          else if (Engine.RefactorMode == RefactorMode.Enum)
          {
            if (!string.IsNullOrEmpty(Engine.NewEnumSpace))
              property.DataTypeInfo.EnumSpace = Engine.NewEnumSpace;
            if (!string.IsNullOrEmpty(Engine.NewEnumType))
              property.DataTypeInfo.EnumType = Engine.NewEnumType;
          }
        }
      }

      if (RefactorType == RefactorType.Mtsql)
      {
        //Neeed to see if we can do multiline regex to make this faster
        var sb = new StringBuilder();
        foreach (var line in RefactorHelper.SplitStringIntoLines(MtsqlScript.Script))
        {
          if (RefactorType == RefactorType.PropertyList)
            sb.AppendLine(RefactorHelper.ReplaceMtsqlProperty(Engine.OldPropertyName, Engine.NewPropertyName, line));
          else
            sb.AppendLine(RefactorHelper.ReplaceMtsqlEnumType(Engine.OldEnumSpace, Engine.OldEnumType, Engine.NewEnumType, line));
        }
        MtsqlScript.Script = sb.ToString();
      }

      if (RefactorType == RefactorType.XmlFile)
      {
        foreach (var node in XmlNodes)
        {
          node.InnerText = Engine.NewPropertyName;
        }
      }
    }

    public void Save()
    {
      if (Element != null)
        Element.Save();
      if (SqlPlugin != null)
        SqlPlugin.Save();
    }
    public override string ToString()
    {
      var intro = string.Format("{0} Match:", RefactorType);
      switch (RefactorType)
      {
        case RefactorType.PropertyList:
          return string.Format("{0} {1}.{2}", intro, Element.ElementType, Element.Name);
        case RefactorType.Mtsql:
          return string.Format("{0} {1}.{2}", intro, SqlPlugin.GetStage().Name, SqlPlugin.Name);
        case RefactorType.XmlFile:
          return string.Format("{0} {1}", intro, FilePath);
        default:
          return base.ToString();
      }
    }

    public string GetMatchDetails()
    {
      switch (RefactorType)
      {
        case RefactorType.PropertyList:
          return string.Format("Number of matches: {0}", PropertyMatches.Count);
        case RefactorType.Mtsql:
          return string.Join("\r\n", Matches);
        case RefactorType.XmlFile:
          var sb = new StringBuilder();
          foreach (var node in XmlNodes)
          {
            sb.AppendLine("XmlNode: " + node.Name);
          }
          return sb.ToString();
        default:
          return base.ToString();
      }
    }

    #endregion

    public void UpdateMtsqlMatches()
    {
      if (SqlPlugin.ProgID == "MetraPipeline.MTSQLInterpreter.1")
        MtsqlScript = ((plgMTSQL)SqlPlugin.ConfigDataHandler).MTSQLScript;
      else
        MtsqlScript = ((plgBatchMTSQL)SqlPlugin.ConfigDataHandler).MTSQLScript;
      UpdateMtsqlMatches(MtsqlScript.Script);
    }

    private void UpdateMtsqlMatches(string sql)
    {
      var lines = RefactorHelper.SplitStringIntoLines(sql);
      for (int index = 0; index < lines.Length; index++)
      {
        var line = lines[index];
        if (Engine.RefactorMode == RefactorMode.PropertyName)
        {
          if (RefactorHelper.IsMtsqlPropertyMatch(Engine.OldPropertyName, line))
            AddLineMatch(index, line);
        }
        else if (Engine.RefactorMode == RefactorMode.Enum)
        {
          if (RefactorHelper.IsMtsqlEnumTypeMatch(Engine.OldEnumSpace, Engine.OldEnumType, line))
            AddLineMatch(index, line);
        }
      }
    }

    private void AddLineMatch(int lineNumber, string lineText)
    {
      Matches.Add(string.Format("Line {0}: {1}", lineNumber + 1, lineText));
    }

  }
}