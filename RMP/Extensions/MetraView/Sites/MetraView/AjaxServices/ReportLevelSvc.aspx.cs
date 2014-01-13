using System;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;
using MetraTech.ActivityServices.Services.Common;

// accId
// indent
// page

public partial class AjaxServices_ReportLevelSvc : MTPage
{
  private int _pagesize = 100;
  private int _page = 1;
  private string _path;

  public ReportLevel ReportLevel
  {
    get { return ViewState[SiteConstants.ReportLevel] as ReportLevel; }
    set { ViewState[SiteConstants.ReportLevel] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    int accId = int.Parse(Request.Form["id"].Substring(0, Request.Form["id"].IndexOf("_")));
    int indent = int.Parse(Request.Form["indent"]);
    var accEffDate = SliceConverter.FromString<DateRangeSlice>(Request.Form["accEffDate"]);

    if(Request.Form["page"] != null)
    {
      if (!String.IsNullOrEmpty(Request.Form["page"]))
      {
        _page = int.Parse(Request.Form["page"]);
      }
    }

    if (Request.Form["path"] != null)
    {
      if (!String.IsNullOrEmpty(Request.Form["path"]))
      {
        _path = Request.Form["path"]; 
      }
    }

    bool bIsPaging = (_page > 1) ? true : false;

    //do not indent if paging
    if (!bIsPaging)
    {
      indent++;
    }

    if ((string)Session[SiteConstants.View] == "details")
    {
      var billManager = new BillManager(UI);
      ReportLevel = billManager.GetByFolderReport(accId, accEffDate);
    }
    var billManger = new BillManager(UI);
    var sb = new StringBuilder();

    if (ReportLevel != null)
    {
      //only display report level charges on the first page
      if (!bIsPaging)
      {
        sb.Append("<table width=\"100%\" cellspacing=\"0\" cellpadding=\"0\">");
        billManger.RenderReportLevelCharges(ReportLevel, (Session[SiteConstants.View].ToString() == "summary"), indent, ref sb);
        sb.Append("</table>");
      }

      var childrenLevels = new MTList<ReportLevel>();

      childrenLevels = billManger.GetByFolderChildrenReport(accId, ReportLevel.AccountEffectiveDate, _page, _pagesize, childrenLevels);

      foreach (var childrenLevel in childrenLevels.Items)
      {
        sb.Append("<table width=\"100%\" cellspacing=\"0\" cellpadding=\"0\">");
        billManger.RenderReportLevel(childrenLevel,(Session[SiteConstants.View].ToString() == "summary"), indent, ref sb);
        sb.Append("</table>");
      }

      if ((string) Session[SiteConstants.View] == "details")
      {
        if (childrenLevels.TotalRows > 0 && childrenLevels.PageSize > 0)
        {
          int numTotalPages = (int) Math.Ceiling((double) childrenLevels.TotalRows/childrenLevels.PageSize) ;

          if (_page * childrenLevels.PageSize < childrenLevels.TotalRows)
          {
            string uniqueId = accId + "_more_" + Guid.NewGuid();
            string moreString = String.Format("More... (Page {0} of {1})<hr />", _page, numTotalPages);
            sb.Append("<table width=\"100%\" cellspacing=\"0\" cellpadding=\"0\">");
            sb.Append("<tr>");
            sb.Append(
              String.Format(
                "<td colspan=\"2\" style=\"padding-left:{0}px;\"><img id=\"img{1}\" border=\"0\" src=\"images/bullet-gray.gif\" /><a style=\"text-decoration:none;cursor:pointer;\" ext:accId=\"{1}\" ext:accEffDate=\"{5}\" ext:page=\"{4}\" ext:position=\"closed\" ext:indent=\"{2}\">{3}</a></td>",
                indent*10,
                uniqueId, 
                indent,
                moreString,
                ++_page,
                SliceConverter.ToString(ReportLevel.AccountEffectiveDate)));
            sb.Append("</tr>");
            // this is the placeholder for dynamic content to be loaded
            sb.Append(String.Format("<tr><td colspan=\"2\"><div id=\"{0}\"></div></td></tr>", uniqueId));
            sb.Append("</table>");
          }
        }
      }
    }

    Response.Write(sb.ToString());
    Response.End();
  }

}
