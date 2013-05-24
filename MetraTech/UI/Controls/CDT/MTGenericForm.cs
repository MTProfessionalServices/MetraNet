using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Threading;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.CDT;
using MetraTech.UI.Common;

[assembly: TagPrefix("MetraTech.UI.Controls.CDT", "MTCDT")]
namespace MetraTech.UI.Controls.CDT
{

  /// <summary>
  /// MTGenericForm is a PlaceHolder control that will render a form of MT controls based on a template and reflection of an object type.
  /// The inital template is auto generated.  Or comes from ICE.
  /// You must set the RenderObjectType, RenderObjectInstanceName, and TemplatePath (usually Page.TemplatePath).
  /// You can optionally set DataBinderInstanceName (defaults to MTDataBinder1), ReadOnly, and a list of IgnoreProperties.
  /// </summary>
  [DefaultProperty("Text")]
  [ToolboxData("<{0}:MTGenericForm runat=server></{0}:MTGenericForm>")]
  public class MTGenericForm : PlaceHolder
  {

    [Bindable(true)]
    [Category("Accessibility")]
    [Localizable(true)]
    [DefaultValue("")]
    public virtual string TabIndex
    {
      get
      {
        String s = (String)ViewState["TabIndex"];
        return (s ?? "10");
      }

      set
      {
        ViewState["TabIndex"] = value;
      }
    }

    /// <summary>
    /// Object type to render.
    /// </summary>
    [Bindable(true)]
    [Category("GenericForm")]
    [DefaultValue("")]
    [NotifyParentProperty(true)]
    public Type RenderObjectType
    {
      get
      {
        if (ViewState["RenderObjectType"] == null)
        {
          return null;
        }

        Type t = (Type)ViewState["RenderObjectType"];
        return t;
      }

      set
      {
        ViewState["RenderObjectType"] = value;
      }
    }

    /// <summary>
    /// The name of the instance variable to bind to
    /// </summary>
    [Bindable(true)]
    [Category("GenericForm")]
    [DefaultValue("")]
    [NotifyParentProperty(true)]
    public string RenderObjectInstanceName
    {
      get
      {
        string o = (string)ViewState["RenderObjectInstanceName"];
        return o;
      }

      set
      {
        ViewState["RenderObjectInstanceName"] = value;
      }
    }

    /// <summary>
    /// The name of the instance variable that hold the MTDataBinder
    /// </summary>
    [Bindable(true)]
    [Category("GenericForm")]
    [DefaultValue("")]
    [NotifyParentProperty(true)]
    public string DataBinderInstanceName
    {
      get
      {
        string db = (string)ViewState["DataBinderInstanceName"];
        
        return String.IsNullOrEmpty(db) ? "MTDataBinder1" : db;
      }

      set
      {
        ViewState["DataBinderInstanceName"] = value;
      }
    }

    /// <summary>
    ///The path to the rendering template.  (The name of the file is generated based on the type information, but can be anything if you create it in ICE.)
    ///By not specifying an exact template name the renderer will look through all filenames and pick the one with the matching ObjectName.  This allows us to have one page and one control that can render differently at runtime based on the type information.
    ///If you want to have different templates for a single type, then we simply organize them in sub directories.
    /// </summary>
    [Bindable(true)]
    [Category("GenericForm")]
    [DefaultValue("")]
    [NotifyParentProperty(true)]
    public string TemplatePath
    {
      get
      {
        string s = (string)ViewState["TemplatePath"];
        return s;
      }

      set
      {
        ViewState["TemplatePath"] = value;
      }
    }

    /// <summary>
    /// The name inside a template if a specific one should be used, and not just based off the object type.
    /// </summary>
    [Bindable(true)]
    [Category("GenericForm")]
    [DefaultValue("")]
    [NotifyParentProperty(true)]
    public string TemplateName
    {
      get
      {
        string s = (string)ViewState["TemplateName"];
        return s;
      }

      set
      {
        ViewState["TemplateName"] = value;
      }
    }

    /// <summary>
    /// True if 'ALL' properties should be rendered in read only mode  (Like for a summary page).
    /// </summary>
    [Bindable(true)]
    [Category("GenericForm")]
    [DefaultValue(false)]
    [NotifyParentProperty(true)]
    public bool ReadOnly
    {
      get
      {
        bool b = false;
        if (ViewState["ReadOnly"] != null)
        {
          b = (bool)ViewState["ReadOnly"];
        }
        return b;
      }

      set
      {
        ViewState["ReadOnly"] = value;
      }
    }

    /// <summary>
    /// If the section panel should render chrome or not
    /// </summary>
    [Bindable(true)]
    [Category("GenericForm")]
    [DefaultValue(false)]
    [NotifyParentProperty(true)]
    public bool EnableChrome
    {
      get
      {
        bool b = true;
        if (ViewState["EnableChrome"] != null)
        {
          b = (bool)ViewState["EnableChrome"];
        }
        return b;
      }

      set
      {
        ViewState["EnableChrome"] = value;
      }
    }

    /// <summary>
    /// Generic list of strings containing the lowercase representation of properties you want to ignore during rendering.
    /// </summary>
    [Bindable(true)]
    [Category("GenericForm")]
    [DefaultValue("")]
    [NotifyParentProperty(true)]
    public List<string> IgnoreProperties
    {
      get
      {
        List<string> ignoreProps = (List<string>)ViewState["IgnoreProperties"];
        return ignoreProps;
      }

      set
      {
        ViewState["IgnoreProperties"] = value;
      }
    }

    /// <summary>
    /// Width of the Control. Defaults to 360 if not set.
    /// </summary>
    [Bindable(true)]
    [Category("GenericForm")]
    [DefaultValue(360)]
    [NotifyParentProperty(true)]
    public int Width
    {
      get
      {
        int i = 360;
        if (ViewState["Width"] != null)
        {
          i = (int)ViewState["Width"];
        }
        return i;
      }

      set
      {
        ViewState["Width"] = value;
      }
    }

    private List<MTPanel> panelList;
    public List<MTPanel> PanelList
    {
      get
      {
        if (panelList == null)
        {
          panelList = new List<MTPanel>();
        }
        return panelList;
      }
    }

    /// <summary>
    /// returns a PageLayout for the specified templateName
    /// </summary>
    /// <param name="templateName"></param>
    /// <returns></returns>
    public PageLayout GetPageLayoutByName(string templateName)
    {
      GenericObjectRenderer gob = new GenericObjectRenderer();
      if (ConfigurationManager.AppSettings["DemoMode"].ToLower() == "true") { GenericObjectRenderer.Init(); }
      return gob.GetPageLayoutByName(templateName.ToLower());
    }

    /// <summary>
    /// Create dynamic controls when not postback
    /// </summary>
    /// <param name="e"></param>
    protected override void OnLoad(EventArgs e)
    {
      base.OnLoad(e);

      if (!Page.IsPostBack)
      {
        MTDataBinder binder = NamingContainer.FindControl(DataBinderInstanceName) as MTDataBinder;
        MTPage page = Page as MTPage;
        string helpName = "";
        if (page != null)
        {
          GenericObjectRenderer gob = new GenericObjectRenderer();
          if(ConfigurationManager.AppSettings["DemoMode"].ToLower() == "true") { GenericObjectRenderer.Init(); } 
          panelList = gob.RenderDynamicControls(RenderObjectType, RenderObjectInstanceName,
                                                      this, binder,
                                                      IgnoreProperties, ReadOnly, short.Parse(TabIndex), TemplatePath, TemplateName, 
                                                      page.UI.SessionContext.SecurityContext, ref helpName, EnableChrome, Width);
          if (!String.IsNullOrEmpty(helpName))
          {
            page.HelpPage = string.Format("/{0}/{1}.hlp.htm", Thread.CurrentThread.CurrentCulture, helpName);
          }
        }

        if (binder != null) binder.DataBind();
      }
    }

    /// <summary>
    /// Create dynamic controls durring postback (preserve viewstate)
    /// </summary>
    /// <param name="savedState"></param>
    protected override void LoadViewState(object savedState)
    {
      base.LoadViewState(savedState);  

      if (Page.IsPostBack)
      {
        MTDataBinder binder = FindControl(DataBinderInstanceName) as MTDataBinder;
        MTPage page = Page as MTPage;
        string helpName = "";
        if (page != null)
        {
          GenericObjectRenderer gob = new GenericObjectRenderer();
          if (ConfigurationManager.AppSettings["DemoMode"].ToLower() == "true") { GenericObjectRenderer.Init(); } 
          panelList = gob.RenderDynamicControls(RenderObjectType, RenderObjectInstanceName,
                                                      this, binder,
                                                      IgnoreProperties, ReadOnly, short.Parse(TabIndex), TemplatePath, TemplateName,
                                                      page.UI.SessionContext.SecurityContext, ref helpName, EnableChrome);
          if (!String.IsNullOrEmpty(helpName))
          {
            page.HelpPage = string.Format("/{0}/{1}.hlp.htm", Thread.CurrentThread.CurrentCulture, helpName);
          }
        }
      }
    }
  

  }
}
