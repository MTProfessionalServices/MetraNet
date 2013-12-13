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
using MetraTech.DomainModel.Enums;

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
      if (DesignMode)
        return;

      //PortalSerializer ser = new PortalSerializer();
      //ser.PopulatePortalFromLayout(this, "", this.Page);

      // ESR-3643: Allow site config to live at session level.  If it is null use the application.
      var site = ((MTPage)Page).Session["SiteConfig"] as Core.UI.Site ??
                 ((MTPage)Page).Application["SiteConfig"] as Core.UI.Site;

      if (site != null)
      {
        foreach (Core.UI.Dashboard dashboard in site.Dashboards)
        {
          //CORE-3994: Allow to download dashboard for new MetraView site
          this.Name = dashboard.DashboardBusinessKey.Name;
          if (this.Name.Equals(dashboard.DashboardBusinessKey.Name))
          {
            LoadDashboardFromBME(dashboard);
            break;
          }
        }
      }
    }

    #region Loading from BME
    protected void LoadDashboardFromBME(Core.UI.Dashboard dashboard)
    {
      DashboardID = dashboard.Id;
      Description = dashboard.Description;
      Title = dashboard.Title;
      CssClass = dashboard.CssClass;
      Style = dashboard.Style;

      foreach (Core.UI.Column bmeColumn in dashboard.Columns)
      {
        DashboardColumn col = new DashboardColumn();
        col.LoadFromBME(bmeColumn);
        Columns.Add(col);
      }
    }
    #endregion

    protected void CreateWidgets(DashboardColumn column)
    {
      var widgets = column.Widgets.OrderBy(w => w.Position).ToList();

      foreach (BaseWidget widget in widgets)
      {
        //create wrapper
        string widgetWrapperClass = string.Format("box{0}", EnumHelper.GetValueByEnum(column.Width).ToString()); //"dashboard-widget-wrapper";
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

        string shim = "box" + EnumHelper.GetValueByEnum(column.Width).ToString() + "top";
        wrapperHTML += "><div class='" + shim + "'></div>";

        Controls.Add(new LiteralControl(wrapperHTML));

        //create title
        if (!string.IsNullOrEmpty(widget.Title))
        {
          //get the actual title string
          object titleResource = HttpContext.GetGlobalResourceObject("Dashboard", widget.Title);
          string title = (titleResource == null) ? widget.Title : titleResource.ToString();

          Controls.Add(new LiteralControl(string.Format(
            "<div class='boxheader' id='{0}-title'>{1}</div>",
            widget.Name.ToString(), title)
            ));
        }


        //create body
        string widgetHTML = string.Format(
          "<div class='box' id='{0}-body'>", widget.Name.ToString());
        Controls.Add(new LiteralControl(widgetHTML));

        Controls.Add(widget);

        Controls.Add(new LiteralControl("</div></div>")); //end widget and widget wrapper
      }

      //new line
      //   Controls.Add(new LiteralControl("<div class='space-line'></div>"));
    }

    protected void CreateColumns()
    {
      //draw the columns
      foreach (DashboardColumn col in Columns)
      {
        string columnWidth = EnumHelper.GetValueByEnum(col.Width).ToString();
        int colWidth;
        if (!int.TryParse(columnWidth, out colWidth))
        {
          colWidth = 300;
        }

        //create wrapper div
        string columnWrapperClass = "dashboard-column-wrapper";
        if (!string.IsNullOrEmpty(col.CssClass))
        {
          columnWrapperClass += (" " + col.CssClass);
        }

        string wrapperHTML = string.Format(
          "<div class='{0}' id='{1}-wrapper' style='width:{2}px;",
          columnWrapperClass, col.Name, (colWidth + 5).ToString());

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
