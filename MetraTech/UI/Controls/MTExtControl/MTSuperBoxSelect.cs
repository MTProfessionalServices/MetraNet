using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Globalization;


namespace MetraTech.UI.Controls
{
  [DefaultProperty("Text")]
  [ToolboxData("<{0}:MTSuperBoxSelect runat=server></{0}:MTSuperBoxSelect>")]
  public class MTSuperBoxSelect : MTExtControl
  {
     #region JS
     public string SCRIPT_INCLUDES = @"
     <script language=""javascript"">
        var %%STORE%% = new Ext.data.JsonStore({
                  url: '%%URL%%',
                  autoLoad: true,
                  root: 'Items',
                  fields:  [%%FIELDS%%],
                  sortInfo: { field: %%SORT_FIELD%%, direction: 'ASC' }
                });      
       </script>";
      #endregion

     #region SetValue
     public string SET_VALUE = @"
           formField_%%CONTROL_ID%%.store.addListener('load', function ()
           {
            formField_%%CONTROL_ID%%.setValue(%%SELECTED_VALUE%%);
           }, this);";
    
     #endregion

     #region JavaScript

     public string Options =@" xtype:'superboxselect',
                               store:%%STORE%%,
                               fieldLabel: %%FIELD_LABEL%%,
                               emptyText: %%EMPTY_TEXT%%,
                               displayField: %%DISPLAY_FIELD%%,
                               valueField: %%VALUE_FIELD%%,
                               resizable: true,
                               anchor: '100%',
                               mode: 'local',                             
                               forceSelection: true";    


    #endregion

    #region Properties
    
    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    [NotifyParentProperty(true)]
    public string FieldLabel
    {
      get
      {
        String s = (String)ViewState["FieldLabel"];
        return s;
      }

      set
      {
        ViewState["FieldLabel"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    [NotifyParentProperty(true)]
    public string EmptyText
    {
      get
      {
        String s = (String)ViewState["EmptyText"];
        return s;
      }

      set
      {
        ViewState["EmptyText"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    [NotifyParentProperty(true)]
    public string DisplayField
    {
      get
      {
        String s = (String)ViewState["DisplayField"];
        return s;
      }

      set
      {
        ViewState["DisplayField"] = value;
      }
    }


    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    [NotifyParentProperty(true)]
    public string ValueField
    {
      get
      {
        String s = (String)ViewState["ValueField"];
        return s;
      }

      set
      {
        ViewState["ValueField"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string Url
    {
      get
      {
        String s = (String)ViewState["Url"];
        return s;
      }

      set
      {
        ViewState["Url"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Description("Comma separated fields: 'category', 'total'")]
    [Localizable(true)]
    public string Fields
    {
      get
      {
        String s = (String)ViewState["Fields"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["Fields"] = value;
      }
    }


    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Description("To populate the control with this value on page load")]
    [Localizable(true)]
    public string SelectedValue
    {
      get
      {
        String s = (String)ViewState["SelectedValue"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["SelectedValue"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Description("The field by which the list gets sorted")]
    [Localizable(true)]
    public string SortField
    {
      get
      {
        String s = (String)ViewState["SortField"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["SortField"] = value;
      }
    }
   #endregion


    #region Events
    protected override void OnInit(EventArgs e)
    {
      // defaults
      XType = "SuperBoxSelect";
      XTypeNameSpace = "ux.form";

      base.OnInit(e);
    }

    protected override void OnPreRender(EventArgs e)
    {
      base.OnPreRender(e);

      //registers javascript on the page
      if (!Page.ClientScript.IsClientScriptBlockRegistered(Page.GetType(), "JS"))
      {
        SCRIPT_INCLUDES = SCRIPT_INCLUDES.Replace("%%URL%%", Url.Replace("'", "\'"));
        SCRIPT_INCLUDES = SCRIPT_INCLUDES.Replace("%%FIELDS%%", Fields.Replace("'", "\'"));
        SCRIPT_INCLUDES = SCRIPT_INCLUDES.Replace("%%SORT_FIELD%%", DisplayField.Replace("'", "\'"));
        SCRIPT_INCLUDES = SCRIPT_INCLUDES.Replace("%%STORE%%", (String.IsNullOrEmpty(Name) ? "null" : Name));
        Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "JS", SCRIPT_INCLUDES);
      }      
    }

    protected override void RenderContents(HtmlTextWriter output)
    {
      
      // modify js
      ControlScript = ControlScript.Replace("%%CONTROL_ID%%", this.ClientID);
      SET_VALUE = SET_VALUE.Replace("%%SELECTED_VALUE%%", "'" + SelectedValue + "'");
      ControlScript = ControlScript.Replace("%%INLINE_SCRIPT%%", SET_VALUE);
      string options = Options.Replace("%%NAME%%", (String.IsNullOrEmpty(Name) ? "null" : "'" + Name + "'"));
      options = options.Replace("%%FIELD_LABEL%%", (String.IsNullOrEmpty(FieldLabel) ? "null" : "'" + FieldLabel + "'"));
      options = options.Replace("%%EMPTY_TEXT%%", (String.IsNullOrEmpty(EmptyText) ? "null" : EmptyText));
      options = options.Replace("%%DISPLAY_FIELD%%", (String.IsNullOrEmpty(DisplayField) ? "null" : DisplayField));
      options = options.Replace("%%VALUE_FIELD%%", (String.IsNullOrEmpty(ValueField) ? "null" : ValueField));
      options = options.Replace("%%STORE%%", (String.IsNullOrEmpty(Name) ? "null" : Name));
      
            
      //attach options to OptionalExtConfig. NOTE: there is no duplicate resolution
      OptionalExtConfig = (String.IsNullOrEmpty(OptionalExtConfig) ? options : options + "," + OptionalExtConfig);
      
      // call base render
      base.RenderContents(output);
    }
    #endregion

  }
}
