using System;
using System.Collections.Generic;
using MetraTech.UI.Controls.MTLayout;
using System.IO;
using System.Xml.Serialization;
using MetraTech.UI.Common;
using System.Reflection;
using MetraTech.UI.Tools;
using System.Web;
using System.Configuration;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.Service.ClientProxies;

namespace MetraTech.UI.Controls
{
  public class MTGridSerializer
  {
    #region utility methods
    private readonly Logger _mtLog = new Logger("[MTGridSerializer]");
    private readonly Dictionary<string, object> _objectCache = new Dictionary<string, object>();
    private MTPage _pageReference;

    /// <summary>
    /// Creates and returns an object instance of type objectName from assembly specified by asmFilename
    /// </summary>
    /// <param name="asmFilename"></param>
    /// <param name="objectName"></param>
    /// <returns></returns>
    private object CreateObject(string asmFilename, string objectName)
    {
      if (String.IsNullOrEmpty(objectName))
      {
        _mtLog.LogWarning("Object name is empty. Unable to create object");
        return null;
      }

      if (String.IsNullOrEmpty(asmFilename))
      {
        _mtLog.LogWarning("Assembly Name is missing. Unable to create object");
        return null;
      }

      try
      {
        String binFolder = Utils.GetBinDir();
        String asmPath = Path.Combine(binFolder, Path.GetFileName(asmFilename));

        Type genType = Assembly.LoadFrom(asmPath).GetType(objectName);
                
        object genObj = Activator.CreateInstance(genType);

        return genObj;
      }
      catch (Exception ex)
      {
        _mtLog.LogInfo("Unable to create object " + objectName + ": " + ex.Message);
        return null;
      }
    }

    protected object GetObject(string assemblyFilename, string objectName)
    {
      if (String.IsNullOrEmpty(assemblyFilename) || String.IsNullOrEmpty(objectName))
      {
        return null;
      }

      //if item is in cache, return it
      string key = assemblyFilename + "|" + objectName;
      if (_objectCache.ContainsKey(key))
      {
        return _objectCache[key];
      }

      //item not in cache
      object dynObj = CreateObject(assemblyFilename, objectName);
      _objectCache.Add(key, dynObj);

      return dynObj;
    }

    /// <summary>
    /// Returns the localized display name of the property
    /// </summary>
    /// <param name="layoutElement"></param>
    /// <param name="masterObject"></param>
    /// <returns></returns>
    public string GetElementDisplayName(ElementLayout layoutElement, object masterObject)
    {
      var strValue = string.Empty;
      //in case of product views we'll get the master object corresponding to the PV
      if (masterObject != null)
      {
        var rawElementId = layoutElement.ID;
        if ((rawElementId.EndsWith("ValueDisplayName")) && (rawElementId.Length > "ValueDisplayName".Length))
        {
          //strip ValueDisplayName from the string
          rawElementId = rawElementId.Replace("ValueDisplayName", "");
        }

        var propName = rawElementId + "DisplayName";
        var property = Utils.GetPropertyInfo(masterObject, propName);
        if (property != null)
        {
          try
          {
            var propValue = Utils.GetPropertyEx(masterObject, property.Name);
            return propValue.ToString();
          }
          catch (Exception ex)
          {
            _mtLog.LogException("Unable to extract display name for property " + propName, ex);
            return string.Empty;
          }
        }
      }

      if (!String.IsNullOrEmpty(layoutElement.ObjectName))
      {
        var dynamicObject = GetObject(layoutElement.AssemblyFilename, layoutElement.ObjectName);
        if (dynamicObject != null)
        {
          var rawElementId = layoutElement.ID;
          if ((rawElementId.EndsWith("ValueDisplayName")) && (rawElementId.Length > "ValueDisplayName".Length))
          {
            //strip ValueDisplayName from the string
            rawElementId = rawElementId.Replace("ValueDisplayName", "");
          }

          var propName = rawElementId + "DisplayName";

          //strip everything before last . or /
          var separatorPos = propName.LastIndexOfAny(new[] {'.', '/'});
          if ((separatorPos >= 0) && (separatorPos != propName.Length))
          {
            propName = propName.Substring(separatorPos + 1);
          }

          try
          {
            //property exists in the dynamic object
            var property = Utils.GetPropertyInfo(dynamicObject, propName);
            if (property != null)
            {
              var propValue = Utils.GetPropertyEx(dynamicObject, property.Name);
              return propValue == null ? String.Empty : propValue.ToString();
            }

            //attempt to get it from BE's
            if (_pageReference != null)
            {
              // If we are dealing with a Business Entity, then we need to get the label differently
              // we call the metadata service.

              if (dynamicObject is DataObject)
              {
                var metadataService = new MetadataService_GetEntity_Client();
                metadataService.UserName = _pageReference.UI.User.UserName;
                metadataService.Password = _pageReference.UI.User.SessionPassword;
                metadataService.In_entityName = layoutElement.ObjectName;
                metadataService.Invoke();
                var entity = metadataService.Out_entity;

                if (entity != null)
                {
                  //retrieve the property of the object by the ID field of the element
                  Property prop = entity[layoutElement.ID];
                  if (prop == null)
                  {
                    return layoutElement.ID;
                  }

                  return prop.GetLocalizedLabel();
                }
              }
              else
              {
                return string.Empty;
              }
            }
          }
          catch (Exception ex)
          {
            _mtLog.LogException("Error getting property value", ex);
            _mtLog.LogInfo("Unable to retrieve property " + propName);
            return strValue;
          }
        }

        else
        {
          return layoutElement.ID;
        }
      }
      else
      {
        strValue = "{" + layoutElement.ID + "}";
      }
      return strValue;
    }

    #endregion

    #region Serialization Methods

    protected GridLayout GetCachedLayout(string layoutFile, HttpApplicationState app)
    {
      if ((app == null) || (app.Keys == null) || (app.Keys.Count <= 0))
      {
        return null;
      }

      Dictionary<string, GridLayout> layoutDictionary;
      GridLayout gl = null;

      try
      {
        layoutDictionary = (Dictionary<string, GridLayout>)app.Get("GridLayouts");
      }
      catch
      {
        return null;
      }

      if (layoutDictionary == null)
      {
        return null;
      }

      if (layoutDictionary.ContainsKey(layoutFile))
      {
        if (!layoutDictionary.TryGetValue(layoutFile, out gl))
        {
          return null;
        }
      }

      return gl;
    }

    protected void SaveLayoutToCache(string layoutFile, GridLayout gl, HttpApplicationState app)
    {
      Dictionary<string, GridLayout> layoutDictionary = new Dictionary<string,GridLayout>();

      if ((app == null) || (app.Keys == null) || (app.Keys.Count <= 0))
      {
        app.Add("GridLayouts", layoutDictionary);
      }

      layoutDictionary = (Dictionary<string, GridLayout>)app.Get("GridLayouts");
      if (layoutDictionary == null)
      {
        lock (typeof(Dictionary<string, GridLayout>))
        {
          layoutDictionary = new Dictionary<string, GridLayout>();
        }
      }

      lock (layoutDictionary)
      {
        //update the value in dictionary by resetting it
        if (layoutDictionary.ContainsKey(layoutFile))
        {
          layoutDictionary.Remove(layoutFile);
        }
        layoutDictionary.Add(layoutFile, gl);

        //update the app variable by setting the updated dictionary
        app.Set("GridLayouts", layoutDictionary);
      }
    }

    public void PopulateGridFromLayout(MTFilterGrid grid, string layoutFile, MTPage page)
    {
      _pageReference = page;
      HttpApplicationState app = page.Application;
      
      GridLayout gl;

      //load from cache only if not in demo mode.  If demo mode, always load from file.
      String isDemoMode = ConfigurationManager.AppSettings["DemoMode"];

      if (!String.IsNullOrEmpty(isDemoMode) && (isDemoMode.ToLower() == "true"))
      {
        gl = Load(layoutFile);
      }
        //load from cache
      else
      {
        gl = this.GetCachedLayout(layoutFile, app);
        if (gl == null)
        {
          gl = Load(layoutFile);
          SaveLayoutToCache(layoutFile, gl, app);
        }
      }
      if (gl == null)
      {
        return;
      }

      LoadBaseObjectFromLayout(grid, gl);
    }

    protected void LoadNestedGridParametersFromLayout(MTGridNestedParameter param, NestedGridParameterLayout pl)
    {
      param.ElementID = pl.ElementID;
      param.ParamName = pl.ParameterName;
      param.ParamValue = pl.ParameterValue;
      param.UseParamAsFilter = pl.UseParamAsFilter;
    }

    protected void LoadBaseObjectFromLayout(MTFilterGrid grid, GridLayout gl)
    {
      // If we are rendering a ProductView we get the object name and the assembly passed into the grid.
      LoadProductViewFromLayout(grid, gl);

      if (gl.NoRecordsText != null)
        grid.NoRecordsText = gl.NoRecordsText.GetValue();

      if (gl.TotalProperty != null)
        grid.TotalProperty = gl.TotalProperty;

      if (gl.RootElement != null)
        grid.RootElement = gl.RootElement;

      if (gl.FilterPanelLayout != null)
      {
        grid.FilterPanelLayout = (MTFilterPanelLayout)
          Enum.Parse(typeof(MTFilterPanelLayout), gl.FilterPanelLayout, true);
      }

      if (gl.CustomImplementationFilePath != null)
      {
        grid.CustomImplementationFilePath = grid.AdjustAbsoluteURL(gl.CustomImplementationFilePath);
      }

      if (gl.CustomOverrideJavascriptIncludes != null)
      {
        grid.CustomOverrideJavascriptIncludes = new List<string>();
        string[] includePaths = gl.CustomOverrideJavascriptIncludes.Split(';');
        foreach (string includePath in includePaths)
        {
          grid.CustomOverrideJavascriptIncludes.Add(grid.AdjustAbsoluteURL(includePath));
        }
      }

      grid.FilterPanelCollapsed = gl.FilterPanelCollapsed;
      grid.EnableFilterConfig = gl.EnableFilterConfig;
      grid.EnableColumnConfig = gl.EnableColumnConfig;
      grid.EnableSaveSearch = gl.EnableSaveSearch;
      grid.EnableLoadSearch = gl.EnableLoadSearch;
      grid.ShowTopBar = gl.ShowTopBar;
      grid.ShowBottomBar = gl.ShowBottomBar;
      grid.ShowGridFrame = gl.ShowGridFrame;
      grid.ShowGridHeader = gl.ShowGridHeader;
      grid.ShowColumnHeaders = gl.ShowColumnHeaders;
      grid.ShowFilterPanel = gl.ShowFilterPanel;
      grid.Exportable = gl.Exportable;
      grid.Expandable = gl.Expandable;
      grid.Resizable = gl.Resizable;
      grid.DisplayCount = gl.DisplayCount;

      grid.SupportExportSelected = gl.SupportExportSelected;

      if (gl.ExpansionCssClass != null)
      {
        grid.ExpansionCssClass = gl.ExpansionCssClass;
      }

      grid.ExpanderGridLayoutTemplatePath = gl.ExpanderGridLayoutTemplatePath;

      grid.MultiSelect = gl.MultiSelect;

      if (gl.SelectionModel != null)
      {
        grid.SelectionModel = (MTGridSelectionModel)
          Enum.Parse(typeof(MTGridSelectionModel), gl.SelectionModel, true);
      }

      if (gl.ButtonAlignment != null)
      {
        grid.ButtonAlignment = (MTAlignmentType)
          Enum.Parse(typeof(MTAlignmentType), gl.ButtonAlignment, true);
      }

      if (gl.Buttons != null)
      {
        grid.Buttons = (MTButtonType)
          Enum.Parse(typeof(MTButtonType), gl.Buttons, true);
      }

      if (gl.DefaultGroupField != null)
      {
        grid.DefaultGroupField = gl.DefaultGroupField;
      }

      if (gl.DefaultSortField != null)
      {
        grid.DefaultSortField = gl.DefaultSortField;
      }

      if (gl.DefaultSortDirection != null)
      {
        grid.DefaultSortDirection = (MTGridSortDirection)
          Enum.Parse(typeof(MTGridSortDirection), gl.DefaultSortDirection, true);
      }

      if (gl.Title != null)
      {
        grid.Title = gl.Title;
      }

      if (gl.DataBinder != null)
      {
        grid.DataBinder = new MTGridDataBinding();
        LoadDataBindingFromLayout(grid.DataBinder, gl.DataBinder);
      }

      if (gl.DataSourceURL != null)
      {
        grid.DataSourceURL = gl.DataSourceURL;
      }

      if (!String.IsNullOrEmpty(gl.UpdateURL))
      {
        grid.UpdateURL = gl.UpdateURL;
      }

      if (gl.PageSize != 0)
      {
        grid.PageSize = gl.PageSize;
      }

      if (gl.FilterInputWidth != 0)
      {
        grid.FilterInputWidth = gl.FilterInputWidth;
      }

      if (gl.FilterLabelWidth != 0)
      {
        grid.FilterLabelWidth = gl.FilterLabelWidth;
      }

      if (gl.FilterColumnWidth != 0)
      {
        grid.FilterColumnWidth = gl.FilterColumnWidth;
      }

      grid.SearchOnLoad = gl.SearchOnLoad;

      if (!String.IsNullOrEmpty(gl.Height))
      {
        int nHeight;
        if (Int32.TryParse(gl.Height, out nHeight))
        {
          grid.Height = nHeight;
        }
      }

      if (!String.IsNullOrEmpty(gl.Width))
      {
        int nWidth;
        if (Int32.TryParse(gl.Width, out nWidth))
        {
          grid.Width = nWidth;
        }
      }

      //capabilities
      String allCaps = String.Empty;
      foreach (String cap in gl.QuickEditCapabilities.Capabilities)
      {
        //skip empty capabilities
        if (String.IsNullOrEmpty(cap))
        {
          continue;
        }

        //add separator before every item, other than the first one
        if (!String.IsNullOrEmpty(allCaps))
        {
          allCaps += ",";
        }

        //append capability
        allCaps += cap;
      }
      grid.QuickEditCapability = allCaps;

      //add default column sorting
      foreach (MetraTech.UI.Controls.MTLayout.Field layoutSortColumn in gl.DefaultColumnOrder)
      {
        Field gridSortColumn = new Field();
        gridSortColumn.Name = layoutSortColumn.Name;

        grid.DefaultColumnOrder.Add(gridSortColumn);
      }

      //add default filter sorting
      foreach (MetraTech.UI.Controls.MTLayout.Field layoutSortFilter in gl.DefaultFilterOrder)
      {
        Field gridSortFilter = new Field();
        gridSortFilter.Name = layoutSortFilter.Name;

        grid.DefaultFilterOrder.Add(gridSortFilter);
      }

      //process elements
      grid.Elements.Clear();

      foreach (ElementLayout el in gl.Elements)
      {
        MTGridDataElement gridElement = new MTGridDataElement();
        LoadElementFromLayout(gridElement, el, false, gl, grid);
        grid.Elements.Add(gridElement);

        // for enums, create the value display name nodes
        if (IsEnumField(gl, el, el.ID) && (gridElement.DataType == MTDataType.List))
        {
          gridElement = new MTGridDataElement();
          LoadElementFromLayout(gridElement, el, true, gl, grid);
          grid.Elements.Add(gridElement);
        }
      }

      foreach (Section layoutSection in gl.ExpanderTemplate)
      {
        MTGridExpanderSection gridSection = new MTGridExpanderSection();
        LoadSectionFromLayout(gridSection, layoutSection, gl);
        grid.ExpanderTemplate.Add(gridSection);
      }

      //add toolbar buttons
      grid.ToolbarButtons.Clear();
      foreach (GridButtonLayout layoutButton in gl.ToolbarButtons)
      {
        MTGridButton gridButton = new MTGridButton();
        LoadButtonFromLayout(gridButton, layoutButton);
        grid.ToolbarButtons.Add(gridButton);
      }

      //add grid bottom buttons
      grid.GridButtons.Clear();
      foreach (GridButtonLayout layoutButton in gl.GridButtons)
      {
        MTGridButton gridButton = new MTGridButton();
        LoadButtonFromLayout(gridButton, layoutButton);
        grid.GridButtons.Add(gridButton);
      }

      //add nested grid params
      grid.NestedGridParams.Clear();
      foreach (NestedGridParameterLayout layoutParam in gl.NestedGridParameters)
      {
        MTGridNestedParameter param = new MTGridNestedParameter();
        LoadNestedGridParametersFromLayout(param, layoutParam);
        grid.NestedGridParams.Add(param);
      }

      //add sub grid configuration
      ProcessSubGridConfiguration(grid, gl);

      //add URL parameters
      grid.DataSourceURLParams.Clear();
      ProcessURLParameters(grid, gl);
    }

    /// <summary>
    /// Loads the base object from a product view layout
    /// </summary>
    /// <param name="grid"></param>
    /// <param name="gl"></param>
    protected void LoadProductViewFromLayout(MTFilterGrid grid, GridLayout gl)
    {
      if (!String.IsNullOrEmpty(grid.ProductViewObjectName) && !String.IsNullOrEmpty(grid.ProductViewAssemblyName))
      {
        foreach (var el in gl.Elements)
        {
          el.ObjectName = grid.ProductViewObjectName;
          el.AssemblyFilename = grid.ProductViewAssemblyName;
          //el.HeaderText = null;
        }

        // TODO: loop over available properties and add them as elements if not already there
        // Type viewType = Type.GetType(String.Format("{0}, MetraTech.DomainModel.Billing.Generated.dll", grid.ProductViewObjectName), true, true);
      }
    }

    protected void ProcessSubGridConfiguration(MTFilterGrid grid, GridLayout gl)
    {
      grid.SubGridDefinition = gl.SubGrid;
    }

    protected void ProcessURLParameters(MTFilterGrid grid, GridLayout gl)
    {
      foreach (URLParameterLayout layoutURLParam in gl.URLParameters)
      {
        string paramName = layoutURLParam.ParameterName;

        //skip invalid names
        if (String.IsNullOrEmpty(paramName))
        {
          Utils.CommonLogger.LogWarning("URL Parameter name cannot be empty, skipping parameter");
          continue;
        }

        string paramValue = layoutURLParam.ParameterValue;
        if (!String.IsNullOrEmpty(paramValue))
        {
          try
          {
            grid.DataSourceURLParams.Add(paramName, paramValue);
          }
          catch(Exception e)
          {
            Utils.CommonLogger.LogException("Unable to add parameter " + paramName + " with value " + paramValue.ToString() + ". Check for duplicates", e);
            continue;
          }
        }

        //paramValue is null, attempt to evaluate query parameters
        SQLQueryInfoLayout sqlQuery = layoutURLParam.SQLQuery;
        if (sqlQuery == null)
        {
          continue;
        }

        string sqlString = sqlQuery.SQLString;
        string queryName = sqlQuery.QueryName;
        string queryDir = sqlQuery.QueryDir;

        SQLQueryInfo queryInfo = new SQLQueryInfo();
        if (!String.IsNullOrEmpty(sqlString))
        {
          queryInfo.SQLString = sqlString;
        }
        else
        {
          queryInfo.QueryDir = queryDir;
          queryInfo.QueryName = queryName;
        }

        //iterate through the params to the sql query, if any
        foreach (SQLQueryParamLayout sqlParamLayout in sqlQuery.QueryParameters)
        {
          SQLQueryParam sqlParam = new SQLQueryParam();
          sqlParam.FieldName = sqlParamLayout.Name;
          sqlParam.FieldValue = sqlParamLayout.Value;
          sqlParam.FieldDataType = null; //TODO: Fix data types

          queryInfo.Params.Add(sqlParam);
        }

        //set param value to compacted version of query info
        paramValue = SQLQueryInfo.Compact(queryInfo);

        try
        {
          grid.DataSourceURLParams.Add(paramName, paramValue);
        }
        catch(Exception e)
        {
          Utils.CommonLogger.LogException("Unable to add parameter " + paramName + " with value " + paramValue.ToString() + ". Check for duplicates",e);
          continue;
        }
      }
    }

    protected ElementLayout ElementLayoutLookup(string ElementID, GridLayout gl)
    {
      if (gl == null)
      {
        return null;
      }

      foreach (ElementLayout curElementLayout in gl.Elements)
      {
        if (curElementLayout.ID.ToLower() == ElementID.ToLower())
        {
          return curElementLayout;
        }
      }
      return null;
    }
    
    public bool IsEnumField(GridLayout gridLayout, ElementLayout eltLayout, string elementID)
    {

      ElementLayout elementLayout = eltLayout;
      if (elementLayout == null)
      {
        elementLayout = ElementLayoutLookup(elementID, gridLayout);
      }
      
      if (elementLayout == null)
      {
        return false;
      }

      if (String.IsNullOrEmpty(elementLayout.AssemblyFilename) || (String.IsNullOrEmpty(elementLayout.ObjectName)))
      {
        return false;
      }

      // For BE's we look at the datatype to see if it is a list, if it is, it "must" be a an enum
      if (gridLayout.IsBusinessEntityLayout)
      {
        if (!String.IsNullOrEmpty(elementLayout.DataType))
        {
          return elementLayout.DataType.ToLower() == "list";
        }
      }

      var dynObject = GetObject(elementLayout.AssemblyFilename, elementLayout.ObjectName);
      if (dynObject == null)
      {
        return false;
      }

      //if elementID contains the object path, strip it, so we only have the actual property part of it
      var elementIdLeaf = elementID;
      if ((elementIdLeaf.LastIndexOf(".") > 0) && (elementIdLeaf.LastIndexOf(".") < elementIdLeaf.Length - 1))
      {
        elementIdLeaf = elementIdLeaf.Substring(elementIdLeaf.LastIndexOf(".") + 1);
      }

      var property = Utils.GetPropertyInfo(dynObject, elementIdLeaf);
      if (property == null)
      {
        return false;
      }

      if (property.PropertyType.IsEnum)
      {
        return true;
      }

      var types = property.PropertyType.GetGenericArguments();
      return types.Length > 0 && types[0].IsEnum;
    }

    protected void LoadSectionFromLayout(MTGridExpanderSection gridSection, Section layoutSection, GridLayout gridLayout)
    {
      gridSection.Name = layoutSection.Name;
      gridSection.Title = layoutSection.Title;

      foreach (MetraTech.UI.Controls.MTLayout.Column layoutColumn in layoutSection.Columns)
      {
        Column gridColumn = new Column();

        foreach (MetraTech.UI.Controls.MTLayout.Field layoutField in layoutColumn.Fields)
        {
          Field gridField = new Field();
          gridField.Name = layoutField.Name;

          //If this is an enum, we need to use ValueDisplayName field
          if (IsEnumField(gridLayout, null, layoutField.Name))
          {
            gridField.Name = layoutField.Name + "ValueDisplayName";
          }

          gridField.Label = layoutField.Label;
          gridColumn.Fields.Add(gridField);
        }
        gridSection.Columns.Add(gridColumn);
      }
    }

    protected void LoadDataBindingFromLayout(MTGridDataBinding gridBinding, GridDataBindingLayout layoutBinding)
    {
      gridBinding.AccountID = layoutBinding.AccountID;
      foreach (DataBindingArgumentLayout layoutArgument in layoutBinding.Arguments)
      {
        MTGridDataBindingArgument arg = new MTGridDataBindingArgument();
        arg.Name = layoutArgument.Name;
        arg.Value = layoutArgument.Value.GetValue();

        gridBinding.Arguments.Add(arg);
      }

      gridBinding.Binding = layoutBinding.Binding;
      gridBinding.Operation = layoutBinding.Operation;
      gridBinding.OutPropertyName = layoutBinding.OutPropertyName;
      gridBinding.ProcessorID = layoutBinding.ProcessorID;
      gridBinding.ServiceMethodName = layoutBinding.ServiceMethodName;

      foreach (ServiceMethodParameterLayout layoutParam in layoutBinding.ServiceMethodParameters)
      {
        MTServiceParameter param = new MTServiceParameter();
        LoadServiceMethodParamsFromLayout(param, layoutParam);
        gridBinding.ServiceMethodParameters.Add(param);
      }

      gridBinding.ServicePath = layoutBinding.ServicePath;
    }

    protected void LoadServiceMethodParamsFromLayout(MTServiceParameter svcParam, ServiceMethodParameterLayout layoutParam)
    {
      svcParam.DataType = layoutParam.DataType;
      svcParam.ParamName = layoutParam.ParamName;
      svcParam.ParamValue = layoutParam.ParamValue.GetValue();
    }

    protected void LoadEnumFromLayout(MTFilterEnum filterEnum, EnumValueLayout layoutEnum)
    {
      filterEnum.UseEnumValue = layoutEnum.UseEnumValue;

      if (!String.IsNullOrEmpty(layoutEnum.EnumClassName))
      {
        filterEnum.EnumClassName = layoutEnum.EnumClassName;
      }

      if (!String.IsNullOrEmpty(layoutEnum.EnumSpace))
      {
        filterEnum.EnumSpace = layoutEnum.EnumSpace;
      }

      if (!String.IsNullOrEmpty(layoutEnum.EnumType))
      {
        filterEnum.EnumType = layoutEnum.EnumType;
      }

      if (!String.IsNullOrEmpty(layoutEnum.DefaultValue))
      {
        filterEnum.DefaultValue = layoutEnum.DefaultValue;
      }

      //copy black list of enum values
      if (layoutEnum.HideEnumValues != null)
      {
        filterEnum.HideEnumValues = new List<string>();
        foreach (string curHideEnumValue in layoutEnum.HideEnumValues)
        {
          if (!filterEnum.HideEnumValues.Contains(curHideEnumValue))
          {
            filterEnum.HideEnumValues.Add(curHideEnumValue);
          }
        }
      }
    }

    protected void LoadDropdownFromLayout(MTFilterDropdownItem filterDropdown, DropdownItemLayout layoutDropdown)
    {
      if (!String.IsNullOrEmpty(layoutDropdown.Key))
      {
        filterDropdown.Key = layoutDropdown.Key;
      }

      if (layoutDropdown.Value != null)
      {
        filterDropdown.Value = layoutDropdown.Value.GetValue();
      }
    }

    protected void LoadButtonFromLayout(MTGridButton button, GridButtonLayout layoutButton)
    {
      button.ButtonID = layoutButton.ButtonID;
      button.ButtonText = layoutButton.ButtonText.GetValue();
      //button.Capability = layoutButton.Capability;
      button.IconClass = layoutButton.IconClass;
      button.JSHandlerFunction = layoutButton.JSHandlerFunction;
      button.ToolTip = layoutButton.ToolTip.GetValue();

      String allCaps = String.Empty;
      foreach (String cap in layoutButton.RequiredCapabilities.Capabilities)
      {
        //skip empty capabilities
        if (String.IsNullOrEmpty(cap))
        {
          continue;
        }

        //add separator before every item, other than the first one
        if (!String.IsNullOrEmpty(allCaps))
        {
          allCaps += ",";
        }

        //append capability
        allCaps += cap;
      }
      button.Capability = allCaps;
    }

    protected void LoadEditorValidationFromLayout(GridInputValidation gridValidation, InputValidationLayout layoutValidation)
    {
      gridValidation.Required = layoutValidation.Required;
      gridValidation.MaxLength = layoutValidation.MaxLength;
      gridValidation.MinLength = layoutValidation.MinLength;
      gridValidation.MinValue = layoutValidation.MinValue;
      gridValidation.MaxValue = layoutValidation.MaxValue;
      gridValidation.Regex = layoutValidation.Regex;
      gridValidation.ValidationFunction = layoutValidation.ValidationFunction;
      gridValidation.ValidationType = layoutValidation.ValidationType;
    }

    protected void LoadElementFromLayout(MTGridDataElement gridElement, ElementLayout layoutElement, 
      bool bIsValueDisplayMode, GridLayout gridLayout, MTFilterGrid grid)
    {
      bool bIsEnumField = IsEnumField(gridLayout, layoutElement, layoutElement.ID);

      gridElement.IsIdentity = layoutElement.IsIdentity;
      gridElement.Editable = !layoutElement.ReadOnly; // corresponding layout property name is ReadOnly

      if (gridElement.Editable)
      {
        if (layoutElement.EditorValidation != null)
        {
          GridInputValidation gridEditorValidation = new GridInputValidation();
          LoadEditorValidationFromLayout(gridEditorValidation, layoutElement.EditorValidation);
          gridElement.EditorValidation = gridEditorValidation;
        }
      }

      gridElement.ShowInExpander = layoutElement.ShowInExpander;
      gridElement.Exportable = layoutElement.Exportable;
      gridElement.ID = layoutElement.ID;
      gridElement.RecordElement = layoutElement.RecordElement;
      gridElement.Sortable = layoutElement.Sortable;
      gridElement.Resizable = layoutElement.Resizable;
      gridElement.Filterable = layoutElement.Filterable;
      gridElement.IsColumn = layoutElement.IsColumn;
      gridElement.DefaultColumn = layoutElement.DefaultColumn;
      gridElement.ColumnHideable = layoutElement.ColumnHideable;
      gridElement.FilterHideable = layoutElement.FilterHideable;
      gridElement.DefaultFilter = layoutElement.DefaultFilter;
      gridElement.RequiredFilter = layoutElement.RequiredFilter;
      gridElement.FilterReadOnly = layoutElement.FilterReadOnly;
      gridElement.LabelSource = layoutElement.LabelSource;
      gridElement.Formatter = layoutElement.Formatter;
      gridElement.RangeFilter = layoutElement.RangeFilter;
      gridElement.MultiValue = layoutElement.MultiValue;

      object masterObject = null;
      if (!string.IsNullOrEmpty(grid.ProductViewAssemblyName) && !string.IsNullOrEmpty(grid.ProductViewObjectName))
      {
        masterObject = GetObject(grid.ProductViewAssemblyName, grid.ProductViewObjectName);
      }
      string elementLocalizedDisplayName = GetElementDisplayName(layoutElement, masterObject);

      if (!LocalizableString.IsEmpty(layoutElement.HeaderText))
      {
        gridElement.HeaderText = layoutElement.HeaderText.GetValue();
      }
      else
      {
        gridElement.HeaderText = elementLocalizedDisplayName;
      }

      if (!LocalizableString.IsEmpty(layoutElement.FilterLabel))
      {
        gridElement.FilterLabel = layoutElement.FilterLabel.GetValue();
      }
      else
      {
        gridElement.FilterLabel = gridElement.HeaderText;
      }

      if (!String.IsNullOrEmpty(layoutElement.DataIndex))
      {
        gridElement.DataIndex = layoutElement.DataIndex;
      }

      if (layoutElement.DataType != null)
      {
        gridElement.DataType = (MTDataType)Enum.Parse(typeof(MTDataType), layoutElement.DataType);
      }

      if (layoutElement.ElementValue != null)
      {
        gridElement.ElementValue = layoutElement.ElementValue;
      }
      if (layoutElement.ElementValue2 != null)
      {
        gridElement.ElementValue2 = layoutElement.ElementValue2;
      }

      if (layoutElement.FilterOperation != null)
      {
        gridElement.FilterOperation = (MTFilterOperation)Enum.Parse(typeof(MTFilterOperation), layoutElement.FilterOperation);
      }

      if (layoutElement.FilterEnum != null)
      {
        if (!bIsValueDisplayMode)
        {
          LoadEnumFromLayout(gridElement.FilterEnum, layoutElement.FilterEnum);
        }
      }

      gridElement.Width = layoutElement.Width;

      //if enum field, then in normal mode(ValueDisplayMode=false)
      //Filterable=true and IsColumn=false
      //and if ValueDisplayMode=true, then filterable=false and IsColumn=true
      // ShowInExpander and Exportable is false when bValueDisplayMode=false
      if (bIsEnumField && (gridElement.DataType == MTDataType.List))
      {
        gridElement.Filterable = layoutElement.Filterable && !bIsValueDisplayMode;
        gridElement.IsColumn = layoutElement.IsColumn && bIsValueDisplayMode;
        gridElement.ShowInExpander = layoutElement.ShowInExpander && bIsValueDisplayMode;
        gridElement.Exportable = layoutElement.Exportable && bIsValueDisplayMode;
        gridElement.IsIdentity = layoutElement.IsIdentity && !bIsValueDisplayMode;
        if (bIsValueDisplayMode)
        {
          gridElement.DataType = MTDataType.String;
          gridElement.DataIndex = layoutElement.DataIndex + "ValueDisplayName";
          gridElement.ID = layoutElement.ID + "ValueDisplayName";
        }
      }

      foreach (DropdownItemLayout layoutDropdownItem in layoutElement.DropdownItems)
      {
        MTFilterDropdownItem fdi = new MTFilterDropdownItem();
        LoadDropdownFromLayout(fdi, layoutDropdownItem);
        gridElement.FilterDropdownItems.Add(fdi);
      }
    }

    public GridLayout Load(string layoutFile)
    {
      GridLayout gl = null;

      if (String.IsNullOrEmpty(layoutFile))
      {
        return gl;
      }

      if (!File.Exists(layoutFile))
      {
        return gl;
      }

      using (FileStream fileStream = File.Open(layoutFile, FileMode.Open, FileAccess.Read, FileShare.Read))
      {
        XmlSerializer s = new XmlSerializer(typeof(GridLayout));
        gl = (GridLayout)s.Deserialize(fileStream);
      }

      //When debugging a loading issue, useful to see the serialization out; this code intentionally left and commented out to aid debugging
      //This code intentionally left here commented out to avoid recreating it again; to use uncomment, build, load a gridlayout and then compare
      //with the serialized out version to know what the product expects
      // XmlSerializer serializer = new XmlSerializer(typeof(GridLayout));
      // TextWriter textWriter = new StreamWriter(layoutFile + ".debug_out");
      // serializer.Serialize(textWriter, gl);
      // textWriter.Close();

      return gl;
    }

    #endregion
  }
}
