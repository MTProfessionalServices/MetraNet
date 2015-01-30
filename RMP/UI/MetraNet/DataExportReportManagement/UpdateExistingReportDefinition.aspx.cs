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
using MetraTech.DomainModel.Billing;
using MetraTech.Interop.MTAuth;
using MetraTech.UI.Common;
using System.ServiceModel;
using MetraTech.Debug.Diagnostics;
using System.Xml;
using MetraTech.Interop.RCD;
using MetraTech.UI.MetraNet.App_Code;




public partial class DataExportReportManagement_UpdateExistingReportDefinition : MTPage
{
  public ExportReportDefinition exportreportdefinition
  {
    get { return ViewState["exportreportdefinition"] as ExportReportDefinition; } //The ViewState labels are immaterial here..
    set { ViewState["exportreportdefinition"] = value; }
  }

  public string strincomingReportId { get; set; } //so we can read it any time in the session 
  public int intincomingReportID { get; set; }
  public string strincomingAction { get; set; } //so we can read it any time in the session 


  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage DataExportFramework"))
    {
      Response.End();
      return;
    }

    strincomingReportId = Request.QueryString["reportid"];
    intincomingReportID = System.Convert.ToInt32(strincomingReportId);
    strincomingAction = Request.QueryString["action"];


    MTButton3.Visible = false; // This button may be completely removed later

    if (strincomingAction == "Update")
    {
      MTTitle1.Text = "Update Existing Report Definition";
    }
    else
    {
      MTTitle1.Text = "Delete Existing Report Definition";
      MTButton1.Text = "Delete Report";
    }

    if (!IsPostBack)
    {
      var exportReport = new DataExportReportManagment(Logger);
      exportreportdefinition = new ExportReportDefinition();

      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
      MTGenericForm1.RenderObjectType = exportreportdefinition.GetType();
      MTGenericForm1.RenderObjectInstanceName = "exportreportdefinition";
      MTGenericForm1.TemplateName = "DataExportFramework.ReportDefinition";
      MTGenericForm1.ReadOnly = false;

      exportreportdefinition.ReportType = "Query";

      //Gather the Existing Report Definition Details

      try
      {
        GetExistingReportDefinition();
      }

      catch (Exception ex)
      {
        SetError(ex.Message);
        this.Logger.LogError(ex.Message);
      }

      //Read the query tags from the query file and add those to the drop down
      foreach (var queryTag in exportReport.GetQueryTagList())
      {
        ddQueryTagList.Items.Add(queryTag);
      }


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

    //Initialize some read only values 
    exportreportdefinition.ReportType = "Query";
    exportreportdefinition.ReportDefinitionSource = "Query";
    int preventadhocexec = 0;

    if (!exportreportdefinition.bPreventAdhocExecution)
    {
      preventadhocexec = 0;
    }
    else
    {
      preventadhocexec = 1;
    }

    DataExportReportManagementServiceClient client = null;

    try
    {
      client = new DataExportReportManagementServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;


      if (strincomingAction == "Update")
      {
        client.UpdateReportDefinition(intincomingReportID, exportreportdefinition.ReportDefinitionSource, exportreportdefinition.ReportDescription,
    exportreportdefinition.ReportQueryTag, exportreportdefinition.ReportType, preventadhocexec);
      }
      else
      {
        client.DeleteExistingReportDefinition(intincomingReportID);
      }

      client.Close();

      if (strincomingAction == "Update")
      {
        Response.Redirect("ReportDefinitionUpdated.aspx", false);
      }
      else
      {
        Response.Redirect("ReportDefinitionDeleted.aspx", false);
      }

    }

    catch (Exception ex)
    {
      SetError(ex.Message);
      this.Logger.LogError(ex.Message);
      client.Abort();
    }

  }

  protected void GetExistingReportDefinition()
  {
    DataExportReportManagementServiceClient client = null;

    try
    {
      client = new DataExportReportManagementServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      //int IDReport = intincomingReportID;  
      ExportReportDefinition exportReportDefinition;
      client.GetAReportDef(intincomingReportID, out exportReportDefinition);
      exportreportdefinition = (ExportReportDefinition)exportReportDefinition;
      client.Close();

    }

    catch (Exception ex)
    {
      this.Logger.LogError(ex.Message);
      client.Abort();
      throw;
    }
  }



  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect("ShowAllReportDefinitions.aspx", false);
    //Response.Redirect("UpdateExistingReportDefinition.aspx?reportid="+strincomingReportId, false);
  }

  protected void btnManageReportParameters_Click(object sender, EventArgs e)
  {
    Response.Redirect("ShowAssignedReportParameters.aspx?reportid=" + strincomingReportId, false);
  }
}