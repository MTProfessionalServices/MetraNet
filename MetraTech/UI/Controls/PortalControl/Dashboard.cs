using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using System.IO;
using System.Web.UI.WebControls;
using System.Web.UI;
using MetraTech.UI.Controls.Layouts;
using RCD = MetraTech.Interop.RCD;
using System.Web;
using MetraTech.UI.Common;

namespace MetraTech.UI.Controls
{
  [ToolboxData("<{0}:Dashboard runat=server></{0}:Dashboard>")]
  public class Dashboard : WebControl, IPostBackDataHandler
  {   
    #region Properties
    private MetraTech.Logger mtLog = new Logger("[Dashboard]");
       
    private Guid dashboardID;
    public Guid DashboardID
    {
      get { return dashboardID; }
      set { dashboardID = value; }
    }

    private string name;
    public string Name
    {
      get { return name; }
      set { name = value; }
    }

    private string description;
    public string Description
    {
      get { return description; }
      set { description = value; }
    }

    private string title;
    public string Title
    {
      get { return title; }
      set { title = value; }
    }

    private string cssClass;
    public new string CssClass
    {
      get { return cssClass; }
      set { cssClass = value; }
    }

    private string style;
    public new string Style
    {
      get { return style; }
      set { style = value; }
    }

    private List<DashboardColumn> columns;
    public List<DashboardColumn> Columns
    {
      get
      {
        if (columns == null)
        {
          columns = new List<DashboardColumn>();
        }
        return columns;
      }
    }

    #endregion

    protected override void OnInit(EventArgs e)
    {
      base.OnInit(e);

      //enable the control to receive postbacks
      Page.RegisterRequiresPostBack(this);

      LoadControl();
      //EnsureChildControls();
    }

    protected override void OnLoad(EventArgs e)
    {
      if (Page.IsPostBack)
        EnsureChildControls();
    }

    protected override void OnPreRender(EventArgs e)
    {/*
      if (!string.IsNullOrEmpty(CssPath))
      {
        if (!Page.ClientScript.IsClientScriptBlockRegistered(Page.GetType(), "css"))
        {
          string script = string.Format("<link rel='stylesheet' type='text/css' href='{0}' id='theme' />", CssPath);
          Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "css", script);
        }
      }
      */
    }
    protected void LoadControl()
    {
      /*
            //if XML path is not there, attempt to build it using extension and filename
      if (String.IsNullOrEmpty(XMLPath))
      {
        if (!String.IsNullOrEmpty(extensionName) && !String.IsNullOrEmpty(templateFileName))
        {
          RCD.IMTRcd rcd = new RCD.MTRcd();
          string path = Path.Combine(rcd.ExtensionDir, extensionName + "\\Config\\PortalLayouts");

          xmlPath = path + "\\" + templateFileName;

          if (!templateFileName.EndsWith(".xml", StringComparison.CurrentCultureIgnoreCase))
          {
            xmlPath += ".xml";
          }
        }
      }

      //if xmlPath is available use it to load all the properties
      if (!String.IsNullOrEmpty(XMLPath))
      {
        if (!File.Exists(XMLPath))
        {
          throw new Exception("Layout Template not found.");
        }

        try
        {
          PortalSerializer ser = new PortalSerializer();
          ser.PopulatePortalFromLayout(this, XMLPath, this.Page);
        }
        catch (Exception exp)
        {
          throw new Exception(String.Format("Invalid Layout Template, Details: {0}", exp));
        }
      }

      */


      PortalSerializer ser = new PortalSerializer();
      ser.PopulatePortalFromLayout(this, "", this.Page);
    }


    protected void CreateWidgets(DashboardColumn column)
    {
      foreach (BaseWidget widget in column.Widgets)
      {
        //create wrapper
        string widgetWrapperClass = "dashboard-widget-wrapper";
        if (!string.IsNullOrEmpty(widget.CssClass))
        {
          widgetWrapperClass += (" " + widget.CssClass);
        }

        string wrapperHTML = string.Format("<div class='{0}' id='{1}-wrapper' ",
          widgetWrapperClass, widget.Name.ToString());

        if (!string.IsNullOrEmpty(widget.Style))
        {
          wrapperHTML += " style:'" + widget.Style + "'";
        }

        wrapperHTML += ">";

        Controls.Add(new LiteralControl(wrapperHTML));

        //create title
        if (!string.IsNullOrEmpty(widget.Title))
        {
          Controls.Add(new LiteralControl(string.Format(
            "<div class='dashboard-widget-title' id='{0}-title'>{1}</div>",
            widget.Name.ToString(), widget.Title)
            ));
        }


        //create body
        string widgetHTML = string.Format(
          "<div class='dashboard-widget-body' id='{0}-body'>", widget.Name.ToString());
        Controls.Add(new LiteralControl(widgetHTML));

        Controls.Add(widget);

        Controls.Add(new LiteralControl("</div></div>")); //end widget and widget wrapper
      }

      //new line
      Controls.Add(new LiteralControl("<div class='space-line'></div>"));
    }

    protected void CreateColumns()
    {
      //draw the columns
      foreach (DashboardColumn col in Columns)
      {
        //create wrapper div
        string columnWrapperClass = "dashboard-column-wrapper";
        if (!string.IsNullOrEmpty(col.CssClass))
        {
          columnWrapperClass += (" " + col.CssClass);
        }

        string wrapperHTML = string.Format(
          "<div class='{0}' id='{1}-wrapper' style='width:{2};",
          columnWrapperClass, col.Name, col.Width);

        if (!string.IsNullOrEmpty(col.Style))
        {
          wrapperHTML += col.Style;
        }

        wrapperHTML += "'>";


        Controls.Add(new LiteralControl(wrapperHTML));

        //add title if any
        if (!string.IsNullOrEmpty(col.Title))
        {
          Controls.Add(new LiteralControl(string.Format(
            "<div class='dashboard-column-title' id='{0}-title'>{1}</div>",
            col.Name, col.Title)
            ));
        }

        //column body
        StringBuilder columnHTML = new StringBuilder();
        columnHTML.Append(string.Format(
          "<div class='dashboard-column-body' id='{0}-body'>", col.Name));
        Controls.Add(new LiteralControl(columnHTML.ToString()));

        CreateWidgets(col);

        //end section and wrapper
        Controls.Add(new LiteralControl("</div></div>"));
      }
    }

    protected override void CreateChildControls()
    {
      CreateDashboard();
    }


    protected void CreateDashboard()
    {
      //create wrapper
      string dashboardWrapperClass = "dashboard-wrapper";
      if (!string.IsNullOrEmpty(this.CssClass))
      {
        dashboardWrapperClass += (" " + this.CssClass);
      }

      string wrapperHTML = string.Format(
        "<div class='{0}' id='{1}-wrapper'",
        dashboardWrapperClass, this.Name.ToString());

      if (!string.IsNullOrEmpty(this.Style))
      {
        wrapperHTML += " style:'" + this.Style + "'";
      }

      wrapperHTML += ">";

      Controls.Add(new LiteralControl(wrapperHTML));

      //create title
      if (!string.IsNullOrEmpty(this.Title))
      {
        Controls.Add(new LiteralControl(string.Format(
          "<div class='dashboard-title' id='{0}-title'>{1}</div>",
          this.Name.ToString(), this.Title)
          ));
      }
      //create body
      StringBuilder columnHTML = new StringBuilder();
      columnHTML.Append(string.Format(
        "<div class='dashboard-body' id='{0}-body'>", this.Name.ToString()));
      Controls.Add(new LiteralControl(columnHTML.ToString()));

      CreateColumns();

      Controls.Add(new LiteralControl("</div></div>"));

      // new line
      Controls.Add(new LiteralControl("<div class='space-line'></div>"));
    }

    public void LoadFromLayout(DashboardLayout layout)
    {
      DashboardID = layout.DashboardID;
      Name = layout.Name;
      Description = layout.Description;
      Title = layout.Title;
      CssClass = layout.CssClass;
      Style = layout.Style;

      foreach (DashboardColumnLayout dcl in layout.Columns)
      {
        DashboardColumn col = new DashboardColumn();
        col.LoadFromLayout(dcl);

        Columns.Add(col);
      }
    }

    #region search functions
    public BaseWidget FindWidget(string name)
    {
      if (string.IsNullOrEmpty(name))
      {
        return null;
      }

      foreach (DashboardColumn column in this.Columns)
      {
        foreach (BaseWidget widget in column.Widgets)
        {
          if (widget.Name.ToLower() == name.ToLower())
          {
            return widget;
          }
        }
      }
        
      return null;
    }

    public DashboardColumn FindColumn(string name)
    {
      if (string.IsNullOrEmpty(name))
      {
        return null;
      }

      foreach (DashboardColumn column in this.Columns)
      {
        if (column.Name.ToLower() == name.ToLower())
        {
          return column;
        }
      }

      return null;
    }

    #endregion

    #region IPostBackDataHandler Members

    public bool LoadPostData(string postDataKey, System.Collections.Specialized.NameValueCollection postCollection)
    {
      return false;
    }

    public void RaisePostDataChangedEvent()
    {
      throw new NotImplementedException();
    }

    #endregion
  }
}
