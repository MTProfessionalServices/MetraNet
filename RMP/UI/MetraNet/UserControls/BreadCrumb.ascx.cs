using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UI.Tools;

public partial class UserControls_BreadCrumb : System.Web.UI.UserControl
{
  public List<BreadCrumb> BreadCrumbs
  {
    get
    {
      if (Session["BreadCrumbs"] == null)
      {
        Session["BreadCrumbs"] = new List<BreadCrumb>();
      }
      return Session["BreadCrumbs"] as List<BreadCrumb>;
    }
    set { Session["BreadCrumbs"] = value;}
  }

  protected void Page_PreRender(object sender, EventArgs e)
  {
    string title = GetTitle(); 
    if (!IsPostBack)
    {
      InitCrumb();
      AlignCrumbWithCurrentTitle(title);
      AddCurrentPageToCrumb(title);
    }
    RenderCrumb(title);
  }

  private void RenderCrumb(string title)
  {
    litBreadCrumb.Text = GetGlobalResourceObject("Resource", "TEXT_BREAD_CRUMB_SPACER").ToString();
    
    foreach (var buildCrumb in BreadCrumbs)
    {
        //SECENG: CORE-4803 Cross-Site Request Forgery vulnerability in MetraNet
        // write out crumbs
        litBreadCrumb.Text += string.Format("<span><a href=\"{0}\">{1}</a></span>", Utils.EncodeForHtmlAttribute(buildCrumb.Url), Utils.EncodeForHtml(buildCrumb.Title));

      // stop when we get to the current page
      if (buildCrumb.Title == title)
      {
        break;
      }

      litBreadCrumb.Text += GetGlobalResourceObject("Resource", "TEXT_BREAD_CRUMB").ToString();
    }
  }

  private void AddCurrentPageToCrumb(string title)
  {
    BreadCrumb crumb = new BreadCrumb();
    crumb.Title = title;
    crumb.Url = Request.RawUrl;
    BreadCrumbs.Add(crumb);
  }

  private string GetTitle()
  {
    string title = "";
    MTTitle titleControl = MTPage.FindControlRecursive(Page, "MTTitle1") as MTTitle;
    if (titleControl == null)
    {
      title = Request["Name"];
    }
    else
    {
      title = titleControl.Text;
    }
    return title;
  }

  private void AlignCrumbWithCurrentTitle(string title)
  {
    // see if the current title is in the crumb already 
    int i = 0;
    int removeFromHere = -1;
    if (BreadCrumbs != null)
    {
      foreach (BreadCrumb c in BreadCrumbs)
      {
        if (c.Title == title)
        {
          removeFromHere = i;
          break;
        }
        i++;
      }
      if(removeFromHere >= 0)
      {
        BreadCrumbs.RemoveRange(removeFromHere, BreadCrumbs.Count - removeFromHere);
      }
    }
  }

  private void InitCrumb()
  {
    string newCrumb = "false";
    if(Request.QueryString["NewBreadcrumb"] != null)
    {
      newCrumb = Request.QueryString["NewBreadcrumb"].ToString();
    }

    if (newCrumb.ToLower() == "true")
    {
      BreadCrumbs = new List<BreadCrumb>();
      BreadCrumb breadCrumb = new BreadCrumb();
      breadCrumb.Title = "Dashboard";
      breadCrumb.Url = ((MTPage) Page).UI.DictionaryManager["DashboardPage"].ToString();
  //  BreadCrumbs.Add(breadCrumb);
    }
  }
}

public class BreadCrumb
{
  public string Title { get; set; }
  public string Url { get; set; }
}
