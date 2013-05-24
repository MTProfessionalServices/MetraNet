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
  [ToolboxData("<{0}:Portal runat=server></{0}:Portal>")]
  public class Portal : WebControl, IPostBackDataHandler
  {
    private MetraTech.Logger mtLog = new Logger("[Portal]");
       
    public string Title { get; set; }
    public new string CssClass { get; set; }
    public string CssPath { get; set; }
    private string xmlPath;
    public string  XMLPath {
      get { return xmlPath; }
      set { xmlPath = value; }
    }

    private string extensionName;
    public string ExtensionName
    {
      get { return extensionName; }
      set { extensionName = value; }
    }

    private string templateFileName;
    public string TemplateFileName
    {
      get { return templateFileName; }
      set { templateFileName = value; }
    }
    private List<PortalSection> sections;
    public List<PortalSection> Sections
    {
      get
      {
        if (sections == null)
        {
          sections = new List<PortalSection>();
        }
        return sections;
      }
    }

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
    {
      if (!string.IsNullOrEmpty(CssPath))
      {
        if (!Page.ClientScript.IsClientScriptBlockRegistered(Page.GetType(), "css"))
        {
          string script = string.Format("<link rel='stylesheet' type='text/css' href='{0}' id='theme' />", CssPath);
          Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "css", script);
        }
      }
    }
    protected void LoadControl()
    {
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
    }


    protected void CreateWidgets(PortalRow row)
    {
      foreach (BaseWidget widget in row.Widgets)
      {
        widget.EnableViewState = true;

        string widgetWrapper = "<div class='widget_wrapper'";
        if (!String.IsNullOrEmpty(widget.ID))
        {
          widgetWrapper += String.Format(" id='{0}' ", widget.ID);
        }
        widgetWrapper += ">";
        Controls.Add(new LiteralControl(widgetWrapper));

        if (!String.IsNullOrEmpty(widget.Title))
        {
          string widgetTitle = String.Format("<div class='widget_title'>{0}</div>", HttpUtility.HtmlEncode(widget.Title));
          Controls.Add(new LiteralControl(widgetTitle));
        }

        string widgetHTML = "<div class='portal_widget";
        if (!String.IsNullOrEmpty(widget.CssClass))
        {
          widgetHTML += " " + widget.CssClass;
        }
        widgetHTML += "'";

        if (!String.IsNullOrEmpty(widget.ID))
        {
          widgetHTML += " id='" + ClientID + "_" + widget.ID + "'";
        }
        widgetHTML += ">";

        Controls.Add(new LiteralControl(widgetHTML));

        Controls.Add(widget);

        Controls.Add(new LiteralControl("</div></div>")); //end widget and widget wrapper
      }

      //last widget in row
      Controls.Add(new LiteralControl("<div class='space-line'></div>"));
    }


    protected void CreateRows(PortalColumn column)
    {
      //display rows
      foreach (PortalRow row in column.Rows)
      {
        //row wrapper
        Controls.Add(new LiteralControl("<div class='row_wrapper'>"));

        if (!String.IsNullOrEmpty(row.Title))
        {
          string rowTitle = String.Format("<div class='portal_row_title'>{0}</div>", HttpUtility.HtmlEncode(row.Title));
          Controls.Add(new LiteralControl(rowTitle));
        }

        string rowHTML = "<div class='portal_row";
        if (!String.IsNullOrEmpty(row.CssClass))
        {
          rowHTML += " " + row.CssClass;
        }
        rowHTML += "'";

        if (!String.IsNullOrEmpty(row.ID))
        {
          rowHTML += " id='" + ClientID + "_" + row.ID + "' ";
        }

        rowHTML += ">";

        Controls.Add(new LiteralControl(rowHTML));

        CreateWidgets(row);

        //end row
        Controls.Add(new LiteralControl("</div>"));

        Controls.Add(new LiteralControl("<div class='space-line'></div>"));

        //end wrapper
        Controls.Add(new LiteralControl("</div>"));
      }
    }

    protected void CreateColumns(PortalSection section)
    {
      //display columns
      foreach (PortalColumn column in section.Columns)
      {
        Controls.Add(new LiteralControl("<div class='column_wrapper'>"));
        if (!String.IsNullOrEmpty(column.Title))
        {
          string columnTitle = String.Format("<div class='column_title'>{0}</div>", HttpUtility.HtmlEncode(column.Title));
          Controls.Add(new LiteralControl(columnTitle));

        }
        //string columnHTML = string.Format("<div class='{0}' ", column.CssClass);
        string columnHTML = "<div class='portal_column";
        if (!String.IsNullOrEmpty(column.CssClass))
        {
          columnHTML += " " + column.CssClass ;
        }
        columnHTML += "'";

        if (!String.IsNullOrEmpty(section.ID))
        {
          columnHTML += " id='" + ClientID + "_" + column.ID + "' ";
        }

        columnHTML += ">";
        Controls.Add(new LiteralControl(columnHTML));

        CreateRows(column);

        //end column
        Controls.Add(new LiteralControl("</div>"));

        //end column wrapper
        Controls.Add(new LiteralControl("</div>"));
      }
    }
    protected override void CreateChildControls()
    {
      CreateSections();
    }

    protected void CreateSections()
    {
      //draw sections
      foreach (PortalSection section in this.Sections)
      {
        Controls.Add(new LiteralControl("<div class='section_wrapper'>"));
        if (!String.IsNullOrEmpty(section.Title))
        {
          string sectionTitle = String.Format("<div class='section_title'>{0}</div>", HttpUtility.HtmlEncode(section.Title));
          Controls.Add(new LiteralControl(sectionTitle));
        }

        string sectionHTML = "<div class='portal_section";
        if (!String.IsNullOrEmpty(section.CssClass))
        {
          sectionHTML += " " + section.CssClass;
        }
        sectionHTML += "'";

        if (!String.IsNullOrEmpty(section.ID))
        {
          sectionHTML += " id='" + ClientID + "_" + section.ID + "'";
        }
        sectionHTML += ">";
        Controls.Add(new LiteralControl(sectionHTML));


        CreateColumns(section);
        
        //end section and wrapper
        Controls.Add(new LiteralControl("</div></div>"));

      }
    }

    public void LoadFromLayout(PortalLayout layout)
    {
      ID = layout.ID;
      Title = layout.Title;
      CssClass = layout.CssClass;
      CssPath = layout.CssPath;

      foreach (PortalSectionLayout pl in layout.Sections)
      {
        PortalSection ps = new PortalSection();
        ps.LoadFromLayout(pl);

        Sections.Add(ps);
      }
    }

    #region search functions
    public BaseWidget FindWidget(string widgetID)
    {
      if (string.IsNullOrEmpty(widgetID))
      {
        return null;
      }

      foreach (PortalSection section in Sections)
      {
        foreach (PortalColumn column in section.Columns)
        {
          foreach (PortalRow row in column.Rows)
          {
            foreach (BaseWidget widget in row.Widgets)
            {
              if (widget.ID.ToLower() == widgetID.ToLower())
              {
                return widget;
              }
            }
          }
        }
      }

      return null;
    }

    public PortalRow FindRow(string rowID)
    {
      if (string.IsNullOrEmpty(rowID))
      {
        return null;
      }

      foreach (PortalSection section in Sections)
      {
        foreach (PortalColumn column in section.Columns)
        {
          foreach (PortalRow row in column.Rows)
          {
            if (row.ID.ToLower() == rowID.ToLower())
            {
              return row;
            }
          }
        }
      }

      return null;
    }

    public PortalColumn FindColumn(string columnID)
    {
      if (string.IsNullOrEmpty(columnID))
      {
        return null;
      }

      foreach (PortalSection section in Sections)
      {
        foreach (PortalColumn column in section.Columns)
        {
          if (column.ID.ToLower() == columnID.ToLower())
          {
            return column;
          }
        }
      }

      return null;
    }

    public PortalSection FindSection(string sectionID)
    {
      if (string.IsNullOrEmpty(sectionID))
      {
        return null;
      }

      foreach (PortalSection section in Sections)
      {
        if (section.ID.ToLower() == sectionID.ToLower())
        {
          return section;
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
