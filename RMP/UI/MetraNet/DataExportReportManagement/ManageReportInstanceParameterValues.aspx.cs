using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel;
using MetraTech.UI.Controls;
using System.Globalization;
using System.Reflection;
using System.Resources;
using MetraTech.Interop.IMTAccountType;
using MetraTech.Accounts.Type;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.Interop.MTProductCatalog;


public partial class DataExportReportManagement_ManageReportInstanceParameterValues : MTPage
{
  public string strincomingReportInstanceId { get; set; } //so we can read it any time in the session 
  public int intincomingReportInstanceID { get; set; }
  //static string prevPage { get; set; } 
  public string strincomingReportId { get; set; } //so we can read it any time in the session 

  protected void Page_Load(object sender, EventArgs e)
  {
    //prevPage = string.Empty;
    if (!UI.CoarseCheckCapability("Manage DataExportFramework"))
    {
      Response.End();
      return;
    }

    if( !IsPostBack )
 
     {
          //prevPage = Request.UrlReferrer.ToString();
      }

    
    //strincomingReportInstanceId = Request.QueryString["idreportinstance"];
    strincomingReportInstanceId = Request.QueryString["reportinstanceid"];
    intincomingReportInstanceID = System.Convert.ToInt32(strincomingReportInstanceId);
    Session["intSessionReportInstanceID"] = intincomingReportInstanceID;

    strincomingReportId = Request.QueryString["idreport"];
  
  }

  /* protected void btnCancel_Click(object sender, EventArgs e)
  {
    //Response.Redirect(prevPage);
    //Response.Redirect(prevPage, false);
    string strincomingReportID="1";
    Response.Redirect("ShowReportInstanceDetails.aspx?idreportinstance=" + strincomingReportInstanceId + "&idreport=" + strincomingReportID, false);
    //it should go here ShowReportInstanceDetails.aspx?idreportinstance=1&idreport=1
  }
  */
}