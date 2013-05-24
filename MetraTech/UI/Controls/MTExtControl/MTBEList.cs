using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MetraTech.UI.Controls
{
  [DefaultProperty("Text")]
  [ToolboxData("<{0}:MTBEList runat=server></{0}:MTBEList>")]
  public class MTBEList : WebControl 
  {
    #region JavaScript
    #endregion

    #region Properties

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string ObjectName
    {
      get
      {
        String s = (String)ViewState["ObjectName"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["ObjectName"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string Extension
    {
      get
      {
        String s = (String)ViewState["Extension"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["Extension"] = value;
      }
    }

    
    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string ParentName
    {
      get
      {
        String s = (String)ViewState["ParentName"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["ParentName"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string ParentId
    {
      get
      {
        String s = (String)ViewState["ParentId"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["ParentId"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string Association
    {
      get
      {
        String s = (String)ViewState["Association"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["Association"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string Text
    {
      get
      {
        String s = (String)ViewState["Text"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["Text"] = value;
      }
    }
    #endregion

    #region Events
    protected override void RenderContents(HtmlTextWriter output)
    {
      string rootPathToPage = HttpContext.Current.Request.ApplicationPath + "/BE/";
      string html = @"<a href=""{0}BEList.aspx?Name={1}&Extension={2}&ParentId={3}&ParentName={4}&Association={5}""><img border=""0"" src=""/Res/Images/Icons/grid.png"" />&nbsp;{6}</a>";
      html = String.Format(html, rootPathToPage, ObjectName, Extension, ParentId, ParentName, Association, Text);
      output.Write(html);
    }
    #endregion

  }
}
