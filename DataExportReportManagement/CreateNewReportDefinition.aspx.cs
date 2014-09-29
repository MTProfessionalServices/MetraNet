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
using MetraTech.UI.MetraNet.App_Code;
using System.ServiceModel;
using MetraTech.Debug.Diagnostics;
using System.Xml;
using MetraTech.Interop.RCD;



public partial class DataExportReportManagement_CreateNewReportDefinition : MTPage
{
  public ExportReportDefinition exportreportdefinition
  {
    get { return ViewState["exportreportdefinition"] as ExportReportDefinition; } //The ViewState labels are immaterial here..
    set { ViewState["exportreportdefinition"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage DataExportFramework"))
    {
      Response.End();
      return;
    }
    if (!IsPostBack)
    {
      try
      {
        var exportReport = new DataExportReportManagment(Logger);
        exportreportdefinition = new ExportReportDefinition();

        MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
        MTGenericForm1.RenderObjectType = exportreportdefinition.GetType();

        //This should be same as the public property defined above 
        MTGenericForm1.RenderObjectInstanceName = "exportreportdefinition";

        //This should be same as the public property defined above
        MTGenericForm1.TemplateName = "DataExportFramework.ReportDefinition";
        MTGenericForm1.ReadOnly = false;

        //Initialize some read only values 
        exportreportdefinition.ReportType = "Query";      

        foreach (var queryTag in exportReport.GetQueryTagList())
        {
          ddQueryTagList.Items.Add(queryTag);
        }

        if (!MTDataBinder1.DataBind())
        {
          Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
        }
      }
      catch (Exception ex)
      {
        Logger.LogError(ex.ToString());
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
    //if (exportreportdefinition.PreventAdhocExecution == PreventAdhocExecutionEnum.No)
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

      client.AddNewReportDefinition(exportreportdefinition.ReportTitle, exportreportdefinition.ReportType, exportreportdefinition.ReportDefinitionSource,
      exportreportdefinition.ReportDescription, exportreportdefinition.ReportQueryTag, preventadhocexec);

      client.Close();
      Response.Redirect("ReportDefinitionCreated.aspx", false);
      //Response.Redirect("ShowAllReportDefinitions.aspx", false);

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
    Response.Redirect("ShowAllReportDefinitions.aspx");
  }

}