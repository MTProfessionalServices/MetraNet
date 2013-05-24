using System;
using System.Collections.Generic;
using System.Reflection;
using System.Threading;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using System.Web.UI.WebControls;
using System.ComponentModel;
using MetraTech.Interop.MTAuth;
using MetraTech.Debug.Diagnostics;
using RCD = MetraTech.Interop.RCD;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.Service.ClientProxies;
using System.Text;

namespace MetraTech.UI.CDT
{
  public class GenericObjectRenderer
  {
    private bool enableChrome = true;
    static private Dictionary<string, PageLayout> pageLayouts;
    static private readonly Logger logger = new Logger("[GenericObjectRenderer]");

    public const string DEFAULT_SECTION_ID_TEMPLATE = "PageLayoutSection{0}";

    public GenericObjectRenderer()
    {
      if (pageLayouts == null)
      {
        lock (typeof(PageLayout))
        {
          if (pageLayouts == null)
          {
            Init();
          }
        }
      }
    }

    public static void Init() // only used directly for demo mode
    {
      pageLayouts = new Dictionary<string, PageLayout>();
      RCD.IMTRcd rcd = new RCD.MTRcd();
      RCD.IMTRcdFileList fileList = rcd.RunQuery(@"config\PageLayouts\*.xml", true);

      foreach (string fileName in fileList)
      {
        try
        {
          PageLayout pageLayout = PageLayout.Load(fileName);
          pageLayouts.Add(fileName.ToLower(), pageLayout);
        }
        catch (Exception exp)
        {
          logger.LogInfo(string.Format("Error loading PageLayout {0}", fileName), exp);
        }
      }
    }

    /// <summary>
    /// Returns a PageLayout instance if one exists for the specified type otherwise null.
    /// </summary>
    /// <param name="objectType"></param>
    /// <returns></returns> 
    public PageLayout GetPageLayoutForType(string objectType)
    {
      foreach (KeyValuePair<string, PageLayout> pair in pageLayouts)
      {
        if(pair.Value.ObjectName.ToLower() == objectType.ToLower())
        {
          return pair.Value;
        }
      }
      return null;
    }

    /// <summary>
    /// Returns a PageLayout instance if one exists for the specified template name otherwise null.
    /// </summary>
    /// <param name="templateName"></param>
    /// <returns></returns>
    public PageLayout GetPageLayoutByName(string templateName)
    {
      foreach (KeyValuePair<string, PageLayout> pair in pageLayouts)
      {
        if (pair.Value.Name.ToLower() == templateName.ToLower())
        {
          return pair.Value;
        }
      }
      return null;
    }

    /// <summary>
    /// Generates the list of optional additional javascript includes that are included at the end
    /// of the control rendering so that they may override control generated javascript
    /// </summary>
    /// <returns></returns>
    protected string GenerateAdditionalIncludesFromLayout(string customOverrideJavascriptIncludes)
    {
      if (customOverrideJavascriptIncludes == null)
      {
        return "";
      }
      
      var result = new StringBuilder();
      foreach (var includePath in customOverrideJavascriptIncludes.Split(';'))
      {
        result.AppendFormat(@"<script type=""text/javascript"" src=""{0}""></script>", includePath);
      }

      return result.ToString();
    }

    /// <summary>
    /// Renders dynamic controls based on type and template into the supplied PlaceHolder control (usually MTGenericForm).
    /// Also configures bindings in the passed in MTDataBinder.
    /// </summary>
    /// <param name="objectType"></param>
    /// <param name="baseBindingObjectName"></param>
    /// <param name="placeHolder1"></param>
    /// <param name="MTDataBinder1"></param>
    /// <param name="skipProperties"></param>
    /// <param name="readOnly"></param>
    /// <param name="tabIndex"></param>
    /// <param name="templatePath">used if no template is found for object, or template name</param>
    /// <param name="templateName">used to lookup template if not null</param>
    /// <param name="sc"></param>
    /// <param name="helpName"></param>
    /// <param name="enableChrome"></param>
    /// <param name="width"></param>
    public List<MTPanel> RenderDynamicControls(Type objectType, string baseBindingObjectName, 
                                             PlaceHolder placeHolder1, MTDataBinder MTDataBinder1,
                                             List<string> skipProperties, bool readOnly, short tabIndex, string templatePath, string templateName, 
                                             IMTSecurityContext sc, ref string helpName, bool enableChrome, int width = 360)
    {
      this.enableChrome = enableChrome;
      List<MTPanel> panelList = new List<MTPanel>();

      using (new HighResolutionTimer("RenderDynamicControls", 1000))
      {
        if (placeHolder1 == null) throw new ArgumentNullException("placeHolder1");
        if (sc == null) throw new ArgumentNullException("sc");

        PageLayout template;
        if (String.IsNullOrEmpty(templateName))
        {
          // TODO: check for null object type
          template = GetPageLayoutForType(objectType.ToString());
        }
        else
        {
          template = GetPageLayoutByName(templateName);
        }

        // build a dictionary for property lookup, when not dealing with a business entity 
        List<PropertyInfo> fullPropList = new List<PropertyInfo>();
        List<string> propListNames = new List<string>();
        Dictionary<string, PropertyInfo> typeLookup = new Dictionary<string, PropertyInfo>(StringComparer.InvariantCultureIgnoreCase);

        if (objectType != null)
        {
          // Non-Business Entity
          GenericObjectParser.ParseType(objectType, "", fullPropList, propListNames);

          int i = 0;
          foreach (PropertyInfo pi in fullPropList)
          {
            typeLookup.Add(propListNames[i], pi);
            i++;
          }
        }

        if (template == null && objectType != null)
        {
          throw new ApplicationException(String.Format("No page layout was found for {0}.", objectType));
          
          // Uncomment to auto generate a layout file with all properties... Turns out to not be so useful and causes confusion for SIs... 
          // panelList = CreateControls(baseBindingObjectName, fullPropList, propListNames, placeHolder1, MTDataBinder1, skipProperties,
          //               readOnly, templatePath, objectType.ToString());
        }
        else
        {
          // add page title
          if (!String.IsNullOrEmpty(template.Header.PageTitle))
          {
            MTTitle titleControl = new MTTitle();
            titleControl.Text = template.Header.PageTitle;
            //titleControl.ID = template.Header.PageTitle;
            placeHolder1.Controls.Add(titleControl);
          }

          // add help page overrride
          if (!String.IsNullOrEmpty(template.Help.Name))
          {
            helpName = template.Help.Name;
          }

          int sectionCount = 0;
          foreach (Section section in template.Sections)
          {
            sectionCount++;
            // render header, and add place holders
            MTPanel mtPanel = new MTPanel();
            mtPanel.EnableChrome = enableChrome;

            //Set the section title
            if (!String.IsNullOrEmpty(section.Title))
            {
              mtPanel.Text = section.Title;
            }

            //Set the section id
            mtPanel.ID = placeHolder1.ID + "_" + ((!String.IsNullOrEmpty(section.Name))
                            ? section.Name
                            : string.Format(DEFAULT_SECTION_ID_TEMPLATE, sectionCount));


            // default width will be 360 for 1 column panel or 720 for two column panel
            mtPanel.Width = Unit.Pixel(width * section.Columns.Count);

            panelList.Add(mtPanel);
            placeHolder1.Controls.Add(mtPanel);
            
            int j = 0;
            foreach (Column col in section.Columns)
            {
              Panel panel = new Panel();

              if (section.Columns.Count > 2)
              {
                // if we have more than 2 columns we float everything left.
                panel.CssClass = "LeftColumn";
              }
              else
              {
                panel.CssClass = (j == 0) ? "LeftColumn" : "RightColumn";
              }
              mtPanel.Controls.Add(panel);

              foreach (Field field in col.Fields)
              {
                PropertyInfo pi = null;
                if (typeLookup.Count > 0)
                {
                  try
                  {
                    pi = typeLookup[field.Name];
                  }
                  catch (Exception exp)
                  {
                    string msg = string.Format("Unable to retrieve field '{0}' specified in the layout file '{1}' from object", field.Name, "");
                    logger.LogException(msg, exp);
                  }

                }

                // render item
                if (FieldHasAccess(sc, field))
                {
                  CreateControl(panel, MTDataBinder1, baseBindingObjectName, pi, readOnly, tabIndex, field, template, width);
                  tabIndex++;
                }
              }

              j++;
            }

            if (section.Columns.Count > 1)
            {
              Literal lit = new Literal();
              lit.Text = "<div style='clear:both'></div>";
              placeHolder1.Controls.Add(lit);
            }                        
          }
          //add custom JS includes
          if (!String.IsNullOrEmpty(template.CustomOverrideJavascriptIncludes))
          {
            var lit = new Literal
            {
              Text = GenerateAdditionalIncludesFromLayout(template.CustomOverrideJavascriptIncludes)
            };
            placeHolder1.Controls.Add(lit);
          }
        }
      }

      return panelList;
    }

    static private bool FieldHasAccess(IMTSecurityContext sc, Field field)
    {
      IMTSecurity security = new MTSecurityClass();
      bool hasAccess = true;
      foreach (string cap in field.RequiredCapabilities.Capabilities)
      {
        IMTCompositeCapability requiredCap = security.GetCapabilityTypeByName(cap).CreateInstance();
        if (sc.CoarseHasAccess(requiredCap)) continue;
        hasAccess = false;
        break;
      }
      return hasAccess;
    }

    /// <summary>
    /// Left column?  Right column?  (We go down onside then the other, instead of left to right.)
    /// </summary>
    /// <param name="curPos"></param>
    /// <param name="totalItems"></param>
    /// <returns></returns>
    static private int GetPanelByPosition(int curPos, int totalItems)
    {
      int half = (int)Math.Ceiling(((decimal)totalItems / 2));
      int nResult = curPos < half ? 1 : 2;
      return nResult;
    } 


    /// <summary>
    /// Create and bind controls based on property lists and create INITIAL template.
    /// </summary>
    /// <param name="baseBinding"></param>
    /// <param name="fullPropList"></param>
    /// <param name="propListNames"></param>
    /// <param name="placeHolder1"></param>
    /// <param name="MTDataBinder1"></param>
    /// <param name="skipProperties"></param>
    /// <param name="readOnly"></param>
    /// <param name="templatePath"></param>
    /// <param name="templateName"></param>
    static public List<MTPanel> CreateControls(string baseBinding, List<PropertyInfo> fullPropList, 
                                      List<string> propListNames, PlaceHolder placeHolder1, 
                                      MTDataBinder MTDataBinder1, List<string> skipProperties, bool readOnly, string templatePath, string templateName)
    {
      List<MTPanel> panelList = new List<MTPanel>();

      PageLayout newTemplate = new PageLayout();
      newTemplate.ObjectName = templateName;
      newTemplate.Name = templateName;
      newTemplate.Description = "Auto generated template for " + templateName;
      newTemplate.Help.Name = templateName;
      newTemplate.Help.Mode = "Name";
      //newTemplate.Header.PageTitle = templateName;
      Section newSection = new Section();
      newSection.Name = templateName;
      newSection.Title = "Properties";
      Column col1 = new Column();
      Column col2 = new Column();
      newSection.Columns.Add(col1);
      newSection.Columns.Add(col2);
      newTemplate.Sections.Add(newSection);

      // render header, and add place holders
      MTPanel mtPanel = new MTPanel();
      mtPanel.Text = "Properties";
      mtPanel.ID = templateName;
      panelList.Add(mtPanel);
      placeHolder1.Controls.Add(mtPanel);

      Panel panel1 = new Panel();
      panel1.CssClass = "LeftColumn";

      Panel panel2 = new Panel();
      panel2.CssClass = "RightColumn";

      mtPanel.Controls.Add(panel1);
      mtPanel.Controls.Add(panel2);

      Literal lit = new Literal();
      lit.Text = "<div style='clear:both'></div>";
      placeHolder1.Controls.Add(lit);

      int i = 0;
      int j = 0;
      short tabIndex = 10;
      foreach (PropertyInfo pi in fullPropList)
      {
        // Skip properties that are directly on the designer
        if (skipProperties != null)
        {
          if(skipProperties.Contains(propListNames[i].ToLower()))
          {
            i++;
            continue;
          }
        }

        Field itm = new Field();
        itm.Name = propListNames[i];
        itm.Label = "";// pi.Name;

        // two columns
        Panel panel;
        int skipCount = 0;
        if(skipProperties != null)
        {
          skipCount = skipProperties.Count;
        }

        if (GetPanelByPosition(j, propListNames.Count - skipCount) == 1)
        {
          panel = panel1;
          newSection.Columns[0].Fields.Add(itm);
        }
        else
        {
          panel = panel2;
          newSection.Columns[1].Fields.Add(itm);
        }
        j++;

        CreateControl(panel, MTDataBinder1, baseBinding, pi, readOnly, tabIndex, itm, newTemplate);
        tabIndex++;
        i++;
      }

      string templateFilename = templatePath + templateName + ".xml";
      newTemplate.Save(templateFilename);

      return panelList;
    }

    /// <summary>
    /// Creates a control off the propertyInfo object, binds it, and adds it to the panel.
    /// </summary>
    /// <param name="panel"></param>
    /// <param name="MTDataBinder1"></param>
    /// <param name="baseBinding"></param>
    /// <param name="pi"></param>
    /// <param name="readOnly"></param>
    /// <param name="tabIndex"></param>
    /// <param name="field"></param>
    /// <param name="template"></param>
    /// <param name="width"></param>
    static public void CreateControl(Panel panel, MTDataBinder MTDataBinder1, string baseBinding, PropertyInfo pi, bool readOnly, short tabIndex, Field field, PageLayout template, int width = 360)
    {
      if (template == null) throw new ArgumentNullException("template");
      MTDataBindingItem dbItem = new MTDataBindingItem();
      string fullPropName = field.Name;

      // set binding source and binding source member
      string bindingSource;
      string bindingSourceMember; // baseBinding + "." + propListNames[i];

      bool isDecimalBEProperty = false;

      string[] names = fullPropName.Split(new char[] {'.'});
      if (names.Length > 1)
      {
        bindingSource = baseBinding + "." + fullPropName.Substring(0, fullPropName.LastIndexOf("."));
        bindingSourceMember = fullPropName.Substring(fullPropName.LastIndexOf(".") + 1);
      }
      else
      {
        bindingSource = baseBinding;
        bindingSourceMember = fullPropName;
      }

      // Set label localization from domain model if it exists
      // ESR-5408. Issue with mixed languages on Account Summary, Account Update, Add Account screens.
      // Removed conditional that never allowed updating label value, even if localization had changed.
      // No localization value is retrieved everytime.
      if (pi != null)
      {
        try
        {
          string displayName = pi.Name + "DisplayName";
          PropertyInfo propertyInfo = pi.DeclaringType.GetProperty(displayName);
          if (propertyInfo != null)
          {
            object obj = Activator.CreateInstance(propertyInfo.DeclaringType);
            string lbl = propertyInfo.GetValue(obj, null).ToString();
            if (field.Label != null)
            {
              field.Label.Value = lbl;
            }
          }
        }
        catch (Exception exp)
        {
          logger.LogException("Error getting display name", exp);
        }
      }
      else  
      {
        // Business Entity
        if (template.IsBusinessEntityLayout)
        {
          // Make call to get entity and retrieve display name
          //Entity entity = MetadataAccess.Instance.GetEntity(template.ObjectName);
          var metadataService = new MetadataService_GetEntity_Client();
          var page = MTDataBinder1.Page as MTPage;
          if (page != null)
          {
            metadataService.UserName = page.UI.User.UserName;
            metadataService.Password = page.UI.User.SessionPassword;
          }
          metadataService.In_entityName = template.ObjectName;
          metadataService.Invoke();
          var entity = metadataService.Out_entity;

          if (entity != null)
          {
            Property prop = entity[bindingSourceMember];

            if (field.Label != null)
            {
              if (prop != null)
              {
                field.Label.Value = prop.GetLocalizedLabel();
              }
            }

            // Check IsRequired and TypeName values in BE metadata for the property.
            if (prop != null)
            {
              field.EditorValidation.Required = prop.IsRequired;
              isDecimalBEProperty = ((prop.TypeName == "System.Decimal") || (prop.TypeName == "System.Decimal?"));
            }
          }
        }
      }

      //if (readOnly || field.ReadOnly)
      //{
      //  field.ReadOnly = true;
      //}

      if (String.IsNullOrEmpty(field.ControlType) && pi != null)
      {
        // Text box
        field.ControlType = "MetraTech.UI.Controls.MTTextBox";
          
        // checkbox
        if ((pi.PropertyType == typeof(bool)) || (pi.PropertyType == typeof(bool?)))
        {
          field.ControlType = "MetraTech.UI.Controls.MTCheckBox";
        }

        // number field - integer or decimal
        if ((pi.PropertyType == typeof(Int32)) || (pi.PropertyType == typeof(Int32?)) ||
            (pi.PropertyType == typeof(System.Decimal)) || (pi.PropertyType == typeof(System.Decimal?))
           )
        {
          field.ControlType = "MetraTech.UI.Controls.MTNumberField";
        }

        // date picker
        if ((pi.PropertyType == typeof(DateTime)) || (pi.PropertyType == typeof(DateTime?)))
        {
          field.ControlType = "MetraTech.UI.Controls.MTDatePicker";
        }

        // drop down
        if (pi.PropertyType.IsGenericType &&
            pi.PropertyType.GetGenericTypeDefinition().Equals(typeof(Nullable<>)))
        {
          NullableConverter nullableConverter = new NullableConverter(pi.PropertyType);
          if (nullableConverter.UnderlyingType.BaseType == typeof(Enum))
          {
            field.ControlType = "MetraTech.UI.Controls.MTDropDown";
          }
        }
      }

      fullPropName = fullPropName.Replace(".", "_");
      fullPropName = fullPropName.Replace("[", "_");
      fullPropName = fullPropName.Replace("]", "_");
      switch (field.ControlType)
      {
        case "MetraTech.UI.Controls.MTNumberField":
          MTNumberField tbTemp2 = new MTNumberField();
          tbTemp2.ID = "tb" + fullPropName;
          tbTemp2.Label = field.Label;
          if (string.IsNullOrEmpty(tbTemp2.Label))
            tbTemp2.Label = "{" + fullPropName + "}";

          tbTemp2.AllowDecimals = false;
          if (
              ((pi != null) && 
               ((pi.PropertyType == typeof(System.Decimal?)) || (pi.PropertyType == typeof(System.Decimal)))
              )
               ||
              ((pi == null) && isDecimalBEProperty)
             )
          {
            tbTemp2.AllowDecimals = true;
          }
          
          tbTemp2.ReadOnly = (readOnly || field.ReadOnly);
          tbTemp2.TabIndex = tabIndex;

          //Validation
          tbTemp2.AllowBlank = !field.EditorValidation.Required;
          tbTemp2.VType = field.EditorValidation.ValidationType;
          tbTemp2.ValidationFunction = field.EditorValidation.ValidationFunction;
          tbTemp2.ValidationRegex = field.EditorValidation.Regex;
          tbTemp2.MinLength = field.EditorValidation.MinLength;
          tbTemp2.MaxLength = field.EditorValidation.MaxLength;
          tbTemp2.MinValue = field.EditorValidation.MinValue;
          tbTemp2.MaxValue = field.EditorValidation.MaxValue;
          int mtNumberFieldWidth = width - 160;
          tbTemp2.ControlWidth = mtNumberFieldWidth.ToString();

          tbTemp2.OptionalExtConfig = field.OptionalExtConfig;
          panel.Controls.Add(tbTemp2);

          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = bindingSourceMember;
          dbItem.ControlId = "tb" + fullPropName;
          dbItem.BindingProperty = "Text";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);
          break;

        case "MetraTech.UI.Controls.MTInlineSearch":
          MTInlineSearch tbSearch = new MTInlineSearch();
          tbSearch.ID = "tb" + fullPropName;
          tbSearch.Label = field.Label;
          if (string.IsNullOrEmpty(tbSearch.Label))
            tbSearch.Label = "{" + fullPropName + "}";

          tbSearch.AllowBlank = !field.EditorValidation.Required;
          tbSearch.ReadOnly = (readOnly || field.ReadOnly);
          tbSearch.TabIndex = tabIndex;

          panel.Controls.Add(tbSearch);

          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = bindingSourceMember;
          dbItem.ControlId = "tb" + fullPropName;
          dbItem.BindingProperty = "AccountID";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);
          break;

        case "MetraTech.UI.Controls.MTCheckBox":
          MTCheckBoxControl cbTemp = new MTCheckBoxControl();
          cbTemp.ID = "cb" + fullPropName;
          cbTemp.BoxLabel = field.Label;
          if (string.IsNullOrEmpty(cbTemp.BoxLabel))
            cbTemp.BoxLabel = "{" + fullPropName + "}";

          cbTemp.Text = fullPropName;
          cbTemp.Value = fullPropName;
          cbTemp.AllowBlank = !field.EditorValidation.Required;
          cbTemp.VType = field.EditorValidation.ValidationType;
          cbTemp.ReadOnly = (readOnly || field.ReadOnly);
          cbTemp.TabIndex = tabIndex;
          cbTemp.OptionalExtConfig = field.OptionalExtConfig;
          panel.Controls.Add(cbTemp);

          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = bindingSourceMember;
          dbItem.ControlId = "cb" + fullPropName;
          dbItem.BindingProperty = "Checked";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);
          break;

        case "MetraTech.UI.Controls.MTDatePicker":
          MTDatePicker tbTemp3 = new MTDatePicker();
          tbTemp3.ID = "tb" + fullPropName;
          tbTemp3.Label = field.Label;
          if (string.IsNullOrEmpty(tbTemp3.Label))
            tbTemp3.Label = "{" + fullPropName + "}";

          tbTemp3.ReadOnly = (readOnly || field.ReadOnly);
          tbTemp3.TabIndex = tabIndex;

          //Validation
          tbTemp3.AllowBlank = !field.EditorValidation.Required;
          tbTemp3.VType = field.EditorValidation.ValidationType;
          tbTemp3.ValidationRegex = field.EditorValidation.Regex;
          tbTemp3.ValidationFunction = field.EditorValidation.ValidationFunction;
          tbTemp3.MinValue = field.EditorValidation.MinValue;
          tbTemp3.MaxValue = field.EditorValidation.MaxValue;

          tbTemp3.OptionalExtConfig = field.OptionalExtConfig;
          panel.Controls.Add(tbTemp3);

          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = bindingSourceMember;
          dbItem.ControlId = "tb" + fullPropName;
          dbItem.BindingProperty = "Text";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);
          break;
        
        case "MetraTech.UI.Controls.MTDropDown":
          MTDropDown ddTemp = new MTDropDown();
          ddTemp.ID = "dd" + fullPropName;
          ddTemp.Label = field.Label;
          ddTemp.AllowBlank = !field.EditorValidation.Required;
          int mtDropDownWidth = width - 160;
          ddTemp.ControlWidth = mtDropDownWidth.ToString();
          ddTemp.ListWidth = mtDropDownWidth.ToString();
          
          ddTemp.ReadOnly = (readOnly || field.ReadOnly);
          ddTemp.TabIndex = tabIndex;
          ddTemp.OptionalExtConfig = field.OptionalExtConfig;
          panel.Controls.Add(ddTemp);

          //Validation
          ddTemp.AllowBlank = !field.EditorValidation.Required;
          ddTemp.VType = field.EditorValidation.ValidationType;
          
          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = bindingSourceMember;
          dbItem.ControlId = "dd" + fullPropName;
          dbItem.BindingProperty = "SelectedValue";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);
          break;

        case "MetraTech.UI.Controls.MTTextBox":
          MTTextBoxControl tbTemp = new MTTextBoxControl();
          tbTemp.ID = "tb" + fullPropName;
          tbTemp.Label = field.Label;
          if (string.IsNullOrEmpty(tbTemp.Label))
            tbTemp.Label = "{" + fullPropName + "}";
          
          
          tbTemp.ReadOnly = (readOnly || field.ReadOnly);
          tbTemp.TabIndex = tabIndex;

          //validation
          tbTemp.MinLength = field.EditorValidation.MinLength;
          tbTemp.MaxLength = field.EditorValidation.MaxLength;
          tbTemp.ValidationFunction = field.EditorValidation.ValidationFunction;
          tbTemp.AllowBlank = !field.EditorValidation.Required;
          tbTemp.VType = field.EditorValidation.ValidationType;
          int mtTextBoxControlWidth0 = width - 160;
          tbTemp.ControlWidth = mtTextBoxControlWidth0.ToString();

          tbTemp.OptionalExtConfig = field.OptionalExtConfig;
          panel.Controls.Add(tbTemp);

          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = bindingSourceMember;
          dbItem.ControlId = "tb" + fullPropName;
          dbItem.BindingProperty = "Text";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);
          break;

        case "MetraTech.UI.Controls.MTTitle":
          MTTitle mtTitle = new MTTitle();
          mtTitle.ID = "tb" + fullPropName;
          panel.Controls.Add(mtTitle);

          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = bindingSourceMember;
          dbItem.ControlId = "tb" + fullPropName;
          dbItem.BindingProperty = "Text";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);
          break;
        
        case "MetraTech.UI.Controls.MTExtControl":
          MTExtControl mtExtControl = new MTExtControl();
          mtExtControl.ID = "tb" + fullPropName;
          mtExtControl.Label = field.Label;
          if (string.IsNullOrEmpty(mtExtControl.Label))
            mtExtControl.Label = "{" + fullPropName + "}";

          mtExtControl.AllowBlank = !field.EditorValidation.Required;
          mtExtControl.VType = field.EditorValidation.ValidationType;
          mtExtControl.ReadOnly = (readOnly || field.ReadOnly);
          mtExtControl.TabIndex = tabIndex;
          mtExtControl.OptionalExtConfig = field.OptionalExtConfig;
          panel.Controls.Add(mtExtControl);

          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = bindingSourceMember;
          dbItem.ControlId = "tb" + fullPropName;
          dbItem.BindingProperty = "Text";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);
          break;

        case "MetraTech.UI.Controls.MTHtmlEditor":
          MTHtmlEditor htmlEditor = new MTHtmlEditor();
          htmlEditor.ControlWidth = "500";
          htmlEditor.ControlHeight = "100";
          htmlEditor.ID = "tb" + fullPropName;
          htmlEditor.Label = field.Label;
          if (string.IsNullOrEmpty(htmlEditor.Label))
            htmlEditor.Label = "{" + fullPropName + "}";

          htmlEditor.AllowBlank = !field.EditorValidation.Required;
          htmlEditor.VType = field.EditorValidation.ValidationType;
          htmlEditor.ReadOnly = (readOnly || field.ReadOnly);
          htmlEditor.TabIndex = tabIndex;
          htmlEditor.OptionalExtConfig = field.OptionalExtConfig;             
          panel.Controls.Add(htmlEditor);

          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = bindingSourceMember;
          dbItem.ControlId = "tb" + fullPropName;
          dbItem.BindingProperty = "Text";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);
          break;

        case "MetraTech.UI.Controls.MTLabel":
          MTLabel mtLabel = new MTLabel();
          mtLabel.ID = "tb" + fullPropName;
          panel.Controls.Add(mtLabel);

          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = bindingSourceMember;
          dbItem.ControlId = "tb" + fullPropName;
          dbItem.BindingProperty = "Text";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);
          break;

        case "MetraTech.UI.Controls.MTLiteral":
          MTLiteralControl mtLiteral = new MTLiteralControl();
          mtLiteral.ID = "tb" + fullPropName;
          mtLiteral.Label = field.Label;
          mtLiteral.AllowBlank = !field.EditorValidation.Required;
          mtLiteral.VType = field.EditorValidation.ValidationType;
          mtLiteral.OptionalExtConfig = field.OptionalExtConfig;
          panel.Controls.Add(mtLiteral);

          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = bindingSourceMember;
          dbItem.ControlId = "tb" + fullPropName;
          dbItem.BindingProperty = "Text";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);
          break;

        case "MetraTech.UI.Controls.MTRadio":
          MTRadioControl mtRadio = new MTRadioControl();
          mtRadio.ID = "cb" + fullPropName;
          mtRadio.BoxLabel = field.Label;
          mtRadio.Text = fullPropName;
          mtRadio.Value = fullPropName;
          mtRadio.AllowBlank = !field.EditorValidation.Required;
          mtRadio.VType = field.EditorValidation.ValidationType;
          mtRadio.ReadOnly = (readOnly || field.ReadOnly);
          mtRadio.TabIndex = tabIndex;
          mtRadio.OptionalExtConfig = field.OptionalExtConfig;
          panel.Controls.Add(mtRadio);

          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = bindingSourceMember;
          dbItem.ControlId = "cb" + fullPropName;
          dbItem.BindingProperty = "Checked";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);
          break;

        case "MetraTech.UI.Controls.MTTextArea":
          MTTextArea mtTextArea = new MTTextArea();
          mtTextArea.ID = "tb" + fullPropName;
          mtTextArea.Label = field.Label;
          mtTextArea.ReadOnly = (readOnly || field.ReadOnly);
          mtTextArea.TabIndex = tabIndex;

          //Validation
          mtTextArea.AllowBlank = !field.EditorValidation.Required;
          mtTextArea.VType = field.EditorValidation.ValidationType;
          mtTextArea.MinLength = field.EditorValidation.MinLength;
          mtTextArea.MaxLength = field.EditorValidation.MaxLength;
          mtTextArea.ValidationRegex = field.EditorValidation.Regex;

          mtTextArea.OptionalExtConfig = field.OptionalExtConfig;
          int mtTextAreaWidth = width - 160;
          mtTextArea.ControlWidth = mtTextAreaWidth.ToString();
          mtTextArea.ControlHeight = "60";
          panel.Controls.Add(mtTextArea);

          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = bindingSourceMember;
          dbItem.ControlId = "tb" + fullPropName;
          dbItem.BindingProperty = "Text";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);
          break;

        case "MetraTech.UI.Controls.MTBillingCycleControl":
          MTBillingCycleControl bcControl = new MTBillingCycleControl();
          string billingCycleId = "MTBillingCycleControl1";
          bcControl.ID = billingCycleId;
          bcControl.ReadOnly = (readOnly || field.ReadOnly);
          bcControl.TabIndex = tabIndex;
          bcControl.AllowBlank = !field.EditorValidation.Required;
          panel.Controls.Add(bcControl);

          dbItem = new MTDataBindingItem();
          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = "UsageCycleType";
          dbItem.ControlId = billingCycleId + ".CycleList";
          dbItem.BindingProperty = "SelectedValue";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);

          bindingSource = bindingSource.Replace(".Internal", "");

          dbItem = new MTDataBindingItem();
          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = "DayOfWeek";
          dbItem.ControlId = billingCycleId + ".Weekly";
          dbItem.BindingProperty = "SelectedValue";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);

          dbItem = new MTDataBindingItem();
          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = "StartMonth";
          dbItem.ControlId = billingCycleId + ".Quarterly_Month";
          dbItem.BindingProperty = "SelectedValue";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);

          dbItem = new MTDataBindingItem();
          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = "StartDay";
          dbItem.ControlId = billingCycleId + ".Quarterly_Day";
          dbItem.BindingProperty = "SelectedValue";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);

          dbItem = new MTDataBindingItem();
          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = "StartYear";
          dbItem.ControlId = billingCycleId + ".StartYear";
          dbItem.BindingProperty = "Text";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);

          dbItem = new MTDataBindingItem();
          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = "DayOfMonth";
          dbItem.ControlId = billingCycleId + ".Monthly";
          dbItem.BindingProperty = "SelectedValue";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);

          dbItem = new MTDataBindingItem();
          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = "FirstDayOfMonth";
          dbItem.ControlId = billingCycleId + ".SemiMonthly_First";
          dbItem.BindingProperty = "SelectedValue";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);

          dbItem = new MTDataBindingItem();
          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = "SecondDayOfMonth";
          dbItem.ControlId = billingCycleId + ".SemiMonthly_Second";
          dbItem.BindingProperty = "SelectedValue";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);
          break;

        case "MetraTech.UI.Controls.MTPasswordMeter":
          MTPasswordMeter passwordMeter = new MTPasswordMeter();
          passwordMeter.ID = "tb" + fullPropName;
          passwordMeter.Label = field.Label;
          passwordMeter.AllowBlank = !field.EditorValidation.Required;
          passwordMeter.VType = field.EditorValidation.ValidationType;
          passwordMeter.ReadOnly = (readOnly || field.ReadOnly);
          passwordMeter.TabIndex = tabIndex;
          passwordMeter.OptionalExtConfig = field.OptionalExtConfig;
          panel.Controls.Add(passwordMeter);

          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = bindingSourceMember;
          dbItem.ControlId = "tb" + fullPropName;
          dbItem.BindingProperty = "Text";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);
          break;
        
        case "MetraTech.UI.Controls.MTBEList":
          MTBEList mtBEList = new MTBEList();
          mtBEList.ID = "listLink" + fullPropName;
          mtBEList.Text = field.Label;
          mtBEList.ObjectName = field.ObjectName;
          mtBEList.ParentName = field.Name;
          mtBEList.Extension = "Account"; // todo: parse from object name or metadata
          panel.Controls.Add(mtBEList);

          dbItem.BindingSource = "this";
          dbItem.BindingSourceMember = "Id";
          dbItem.ControlId = "listLink" + fullPropName;
          dbItem.BindingProperty = "ParentId";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);
          break;

        default:
          MTTextBoxControl tbTemp4 = new MTTextBoxControl();
          tbTemp4.ID = "tb" + fullPropName;
          tbTemp4.Label = field.Label;
          tbTemp4.AllowBlank = !field.EditorValidation.Required;
          tbTemp4.VType = field.EditorValidation.ValidationType;
          tbTemp4.ReadOnly = (readOnly || field.ReadOnly);
          tbTemp4.TabIndex = tabIndex;
          int mtTextBoxControlWidth1 = width - 160;
          tbTemp4.ControlWidth = mtTextBoxControlWidth1.ToString();

          tbTemp4.OptionalExtConfig = field.OptionalExtConfig;
          panel.Controls.Add(tbTemp4);

          dbItem.BindingSource = bindingSource;
          dbItem.BindingSourceMember = bindingSourceMember;
          dbItem.ControlId = "tb" + fullPropName;
          dbItem.BindingProperty = "Text";
          dbItem.ErrorMessageLocation = BindingErrorMessageLocations.None;
          MTDataBinder1.DataBindingItems.Add(dbItem);
          break;
      }

    }

    /*/// <summary>
    /// Determine if PropertyInfo is an enum or a nullable enum
    /// </summary>
    /// <param name="pi"></param>
    /// <returns></returns>
    private static bool IsEnum(PropertyInfo pi)
    {
      if(pi.DeclaringType.IsEnum)
        return true;

      if(pi.PropertyType.IsGenericType && (pi.PropertyType.GetGenericTypeDefinition() == 
        typeof(Nullable<>))&& pi.PropertyType.GetGenericArguments().Length>0) {
        if(pi.PropertyType.GetGenericArguments()[0].IsEnum) {
          // Type is a Nullable<enum>
          return true;
        }
      }

      return false;
    }
     */ 
  }
}
