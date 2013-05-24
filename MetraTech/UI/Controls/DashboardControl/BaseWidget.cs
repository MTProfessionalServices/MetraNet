using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.UI.Controls.Layouts;
using System.Web.UI.WebControls;
using System.Web;
using MetraTech.UI.Common;

namespace MetraTech.UI.Controls
{
  public abstract class BaseWidget : WebControl
  {
    private Guid id;
    public new Guid ID
    {
      get { return id; }
      set { id = value; }
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

    private string path;
    public string Path
    {
      get { return path; }
      set { path = value; }
    }

    private int position;
    public int Position
    {
      get { return position; }
      set { position = value; }
    }

    private string height;
    public new string Height
    {
      get { return height; }
      set { height = value; }
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

    private string type;
    public string Type
    {
      get { return type; }
      set { type = value; }
    }

    private List<WidgetParameter> parameters = new List<WidgetParameter>();
    public List<WidgetParameter> Parameters {
      get
      {
        if (parameters == null)
        {
          parameters = new List<WidgetParameter>();
        }
        return parameters;
      }
    }

    public static BaseWidget CreateWidget()
    {
      return new CodeWidget();
    }

    public override void RenderBeginTag(System.Web.UI.HtmlTextWriter writer)
    {
      //base.RenderBeginTag(writer);
    }

    public override void RenderEndTag(System.Web.UI.HtmlTextWriter writer)
    {
      //base.RenderEndTag(writer);
    }

    protected string ConstructURLFromParams(bool bSkipDimensionParams)
    {
      string combinedURL = "";
      string queryStringParams = "";

      //one of the parameters must be named URL
      foreach (WidgetParameter param in Parameters)
      {
        if (param.Name.ToUpper() == "URL")
        {
          combinedURL = param.Value.ToString();
        }
      }
      foreach (WidgetParameter param in Parameters)
      {
        if (param.Name.ToUpper() != "URL")
        {
          if (!bSkipDimensionParams ||
            ((param.Name.ToUpper() != "HEIGHT") && (param.Name.ToUpper() != "WIDTH")))
          {
            queryStringParams += HttpUtility.UrlEncode(param.Name)
            + "="
            + HttpUtility.UrlEncode(param.Value.ToString());
          }
        }
      }

      if (!String.IsNullOrEmpty(combinedURL))
      {
        if (!String.IsNullOrEmpty(queryStringParams))
        {
          combinedURL += "?" + queryStringParams;
        }
      }
      return combinedURL;
    }

    public void LoadFromBME(Core.UI.Widget widget)
    {
      ID = widget.Id;
      Name = widget.Name;
      Description = widget.Description;
      Title = widget.Title;
      Path = widget.WidgetPath;
      Position = widget.Position;
      Height = widget.Height;
      CssClass = widget.CssClass;
      Style = widget.Style;
      Type = widget.WidgetType;

      foreach (Core.UI.Parameter paramLayout in widget.Parameters)
      {
        WidgetParameter wp = new WidgetParameter();
        wp.LoadFromBME(paramLayout);

        Parameters.Add(wp);
      }
    }

    public void LoadFromLayout(WidgetLayout layout)
    {
      ID = layout.ID;
      Name = layout.Name;
      Description = layout.Description;
      Title = layout.Title;
      Path = layout.Path;
      Position = layout.Position;
      Height = layout.Height;
      CssClass = layout.CssClass;
      Style = layout.Style;
      Type = layout.Type;

      foreach (WidgetParameterLayout paramLayout in layout.Parameters)
      {
        WidgetParameter wp = new WidgetParameter();
        wp.LoadFromLayout(paramLayout);

        Parameters.Add(wp);
      }
    }

    protected static bool GetHeightParameter(WidgetParameter wp)
    {
      if (wp.Name.ToLower() == "height")
      {
        return true;
      }
      return false;
    }
    protected static bool GetWidthParameter(WidgetParameter wp)
    {
      if (wp.Name.ToLower() == "width")
      {
        return true;
      }
      return false;
    }

  }
}
