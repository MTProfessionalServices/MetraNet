using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Xml.Serialization;
using System.Web;
using System.Resources;
using MetraTech.UI.Common;
using System.ComponentModel;

namespace MetraTech.UI.Controls.MTLayout
{
  /// <summary>
  /// Configuration class for the grid layout
  /// </summary>
  [Serializable]
  public class GridLayout
  {
    #region Properties

    [XmlArrayItem("Element")]
    public List<ElementLayout> Elements = new List<ElementLayout>();

    [XmlArrayItem("Section")]
    public List<Section> ExpanderTemplate = new List<Section>();

    public bool IsBusinessEntityLayout = false;
    public String Height = "300";
    public String Width = "600";
    public LocalizableString NoRecordsText = null;
    public String TotalProperty = null;
    public String RootElement = null;
    public String FilterPanelLayout = null;
    public String CustomImplementationFilePath = null;
    public bool FilterPanelCollapsed = false;
    public bool EnableFilterConfig = true;
    public bool EnableColumnConfig = true;
    public bool EnableSaveSearch = false;
    public bool EnableLoadSearch = false;
    public bool ShowTopBar = true;
    public bool ShowBottomBar = true;
    public bool ShowGridFrame = true;
    public bool ShowGridHeader = true;
    public bool ShowColumnHeaders = true;
    public bool ShowFilterPanel = true;
    public bool Exportable = false;
    public bool Resizable = true;
    public bool Expandable = false;
    public String ExpansionCssClass = null;
    public bool MultiSelect = false;
    public String SelectionModel = null;
    public String ButtonAlignment = null;
    public String Buttons = null;
    public String DefaultGroupField = null;
    public String DefaultSortField = null;
    public String DefaultSortDirection = null;
    public LocalizableString Title = null;
    public bool DisplayCount = true;
    public String DataSourceURL = null;
    public String UpdateURL = null;
    public int PageSize;
    public int FilterInputWidth;
    public int FilterLabelWidth; 
    public int FilterColumnWidth;
    public string Name;
    public string ExpanderGridLayoutTemplatePath;
    public bool SearchOnLoad = true;

    public RequiredCapabilityList QuickEditCapabilities = new RequiredCapabilityList();

    public ChildGridDefinition SubGrid = new ChildGridDefinition();

    [XmlArrayItem("NestedGridParameter")]
    public List<NestedGridParameterLayout> NestedGridParameters = new List<NestedGridParameterLayout>();

    [XmlArrayItem("URLParameter")]
    public List<URLParameterLayout> URLParameters = new List<URLParameterLayout>();

    [XmlArrayItem("Button")]
    public List<GridButtonLayout> GridButtons = new List<GridButtonLayout>();

    [XmlArrayItem("Button")]
    public List<GridButtonLayout> ToolbarButtons = new List<GridButtonLayout>();

    [XmlArrayItem("Field")]
    public List<Field> DefaultColumnOrder = new List<Field>();

    [XmlArrayItem("Field")]
    public List<Field> DefaultFilterOrder = new List<Field>();

    //public List<string> CustomOverrideJavascriptIncludes = new List<string>();
    public string CustomOverrideJavascriptIncludes = null;

    public bool SupportExportSelected = false;

    public GridDataBindingLayout DataBinder = new GridDataBindingLayout();

    #endregion
  }

  [Serializable]
  public class ChildGridDefinition
  {
    public string Id;
    public string GridLayoutFile;
    public bool LoadSubGridAutomaticallyWhenParentRowSelected = true;
    [XmlArrayItem("ParentGridParameter")]
    public List<NestedGridParameterLayout> ParentGridParameters = new List<NestedGridParameterLayout>();

  }

  [Serializable]
  public class Section
  {
    public string Name = "";
    public LocalizableString Title = new LocalizableString();
    public string TabOrder = "LeftToRight";
    public List<Column> Columns = new List<Column>();
  }
  [Serializable]
  public class Column
  {
    public List<Field> Fields = new List<Field>();
  }

  [Serializable] 
  public class Field
  {
    public string Name = "";
    public LocalizableString Label = new LocalizableString();
    public bool Required;
    public bool ReadOnly;
    public string ValidationType = "";
    public string ValidationRegEx = "";
    public string ControlType = "";
    public string Alignment = "Left";
    public string OptionalExtConfig = "";
    public RequiredCapabilityList RequiredCapabilities = new RequiredCapabilityList();
  }

  [Serializable]
  public class RequiredCapabilityList
  {
    [XmlElement("Capability")]
    public List<string> Capabilities = new List<string>();
  }

  [Serializable]
  public class URLParameterLayout
  {
    public string ParameterName;
    public string ParameterValue;
    public SQLQueryInfoLayout SQLQuery;
  }
}
