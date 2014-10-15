using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;
using MetraTech;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.Auth.Capabilities;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DataAccess;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.Interop.MTAuth;
using MetraTech.UI.Common;
using System.ServiceModel;
using MetraTech.Debug.Diagnostics;
using MetraTech.UI.Controls;
using MetraTech.DomainModel.Billing;


public partial class DataExportReportManagement_AddNewReportParameters :  MTPage
{
  // This property must be declared public at the beginning so that it can be used in any event on the form. This should be created of type of the
  //Domain Model Object tied to this page 

  public ExportReportParameters exportreportparameters 
  {
    get { return ViewState["exportreportparameters"] as ExportReportParameters; } //The ViewState labels are immaterial here..
     set { ViewState["exportreportparameters"] = value; }
  }

  public string strincomingReportId { get; set; } //so we can read it any time in the session 
  public int intincomingReportID { get; set; }

  protected void Page_Load(object sender, EventArgs e)
    {

      if (!UI.CoarseCheckCapability("Manage DataExportFramework"))
      {
        Response.End();
        return;
      }
      strincomingReportId = Request.QueryString["reportid"];
      intincomingReportID = System.Convert.ToInt32(strincomingReportId);
      Session["intSessionReportID"] = intincomingReportID;

    if (!IsPostBack)
      {
        exportreportparameters = new ExportReportParameters();

        MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
        MTGenericForm1.RenderObjectType = exportreportparameters.GetType(); //This should be same as the public property defined above 
        MTGenericForm1.RenderObjectInstanceName = "exportreportparameters";//This should be same as the public property defined above
        MTGenericForm1.TemplateName = "DataExportFramework.CreateParameters"; //This should be the <Name> tag from the page layout config file, not the file name itself
        MTGenericForm1.ReadOnly = false;

        //Hard Coded values were used just for testing purpose 
        //exportreportparameters.IDParameter = 12;
        //exportreportparameters.ParameterDescription = "TestDescription";
        //exportreportparameters.ParameterName = "TestName";

        if (!MTDataBinder1.DataBind())
        {
          Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
        }
      }
  }

    protected void btnOK_Click(object sender, EventArgs e)
    {
      if (!this.MTDataBinder1.Unbind())
      {
        this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
      }

      DataExportReportManagementServiceClient client = null;

      try
      {
        client = new DataExportReportManagementServiceClient();

        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

        //Call Service to add new paremeter 
        client.AddNewReportParameters(exportreportparameters.ParameterName, exportreportparameters.ParameterDescription);
        
        //Response.Redirect("AddNewReportParameters.aspx", false);
        //Response.Redirect("ShowAllReportParameters.aspx?reportid=" + strincomingReportId, false);
        Response.Redirect("NewReportParameterCreated.aspx?reportid=" + strincomingReportId, false);
        
        client.Close();
      }

      catch (Exception ex)
      {
        SetError(ex.Message);
        this.Logger.LogError(ex.Message);
        client.Abort();
      }

    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
      Response.Redirect("ShowAllReportParameters.aspx?reportid=" + strincomingReportId, false);
      //Response.Redirect("AddNewReportParameters.aspx", false);
    }
    
}