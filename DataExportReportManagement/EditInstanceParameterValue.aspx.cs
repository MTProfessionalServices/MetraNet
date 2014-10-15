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



public partial class DataExportReportManagement_EditInstanceParameterValue : MTPage
{
  public ExportReportInstance exportreportinstancevalue
  {
    get { return ViewState["exportreportinstancevalue"] as ExportReportInstance; } //The ViewState labels are immaterial here..
    set { ViewState["exportreportinstancevalue"] = value; }
  }

  public string strincomingIDParameterValueInstance { get; set; } //so we can read it any time in the session 
  public int intincomingIDParameterValueInstance { get; set; }
  public string strincomingParameterValueInstance { get; set; } //so we can read it any time in the session 
  public string strincomingReportInstanceID { get; set; }
  public string strincomingReportID { get; set; }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage DataExportFramework"))
    {
      Response.End();
      return;
    }
    strincomingIDParameterValueInstance = Request.QueryString["idparametervalueinstance"];
    intincomingIDParameterValueInstance = System.Convert.ToInt32(strincomingIDParameterValueInstance);
    strincomingParameterValueInstance = Request.QueryString["parametervalueinstance"];
    strincomingReportInstanceID = Request.QueryString["reportinstanceid"];
    strincomingReportID = Request.QueryString["idreport"];

    if (!IsPostBack)
    {
      exportreportinstancevalue = new ExportReportInstance();

      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
      MTGenericForm1.RenderObjectType = exportreportinstancevalue.GetType(); //This should be same as the public property defined above 
      MTGenericForm1.RenderObjectInstanceName = "exportreportinstancevalue";//This should be same as the public property defined above
      MTGenericForm1.TemplateName = "DataExportFramework.EditInstanceParameterValue"; //This should be the <Name> tag from the page layout config file, not the file name itself
      MTGenericForm1.ReadOnly = false;

      //Populate the current parameter value 

      exportreportinstancevalue.IDParameterValueInstance = intincomingIDParameterValueInstance;
      exportreportinstancevalue.ParameterValueInstance = strincomingParameterValueInstance;
      
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

        client.UpdateReportInstanceParameterValue(exportreportinstancevalue.IDParameterValueInstance, exportreportinstancevalue.ParameterValueInstance);

        client.Close();

        Response.Redirect("ManageReportInstanceParameterValues.aspx?reportinstanceid=" + strincomingReportInstanceID + "&idreport=" + strincomingReportID, false);
              
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
      Response.Redirect("ManageReportInstanceParameterValues.aspx?reportinstanceid=" + strincomingReportInstanceID + "&idreport=" + strincomingReportID, false);
    }

 }