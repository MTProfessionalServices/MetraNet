using System;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;
using MetraTech.Security.Crypto;
using MetraTech.UI.Controls;


public partial class DataExportReportManagement_ShowReportInstanceDetails : MTPage
{
  public ExportReportInstance exportreportinstance
  {
    get { return ViewState["exportreportinstance"] as ExportReportInstance; } //The ViewState labels are immaterial here..
    set { ViewState["exportreportinstance"] = value; }
  }

  public string strincomingReportInstanceId { get; set; } //so we can read it any time in the session 
  public int intincomingReportInstanceID { get; set; }

  public string strincomingReportId { get; set; } //so we can read it any time in the session 
  public int intincomingReportID { get; set; }
  public string strincomingAction { get; set; } //so we can read it any time in the session 


  protected void Page_LoadComplete(object sender, EventArgs e)
  {
    PopulateReportDistributionTypeDropDownControls();

  }
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage DataExportFramework"))
    {
      Response.End();
      return;
    }
    strincomingReportInstanceId = Request.QueryString["idreportinstance"];
    intincomingReportInstanceID = Convert.ToInt32(strincomingReportInstanceId);

    strincomingReportId = Request.QueryString["idreport"];
    intincomingReportID = Convert.ToInt32(strincomingReportId);
    strincomingAction = Request.QueryString["action"];

    Logger.LogDebug("The report instance id is {0} ..", strincomingReportInstanceId);

    btnManageInstanceParameterValues.Visible = false;// This button may be completely removed later

    if (strincomingAction == "Update")
    {
      var title = GetLocalResourceObject("MTTitle1Resource1.Text"); //"Update Report Instance";
      if (title != null)
        MTTitle1.Text = title.ToString();
    }
    else
    {
      var title = GetLocalResourceObject("TEXT_Delete_Report_Instance"); //"Delete Report Instance";
      if (title != null)
        MTTitle1.Text = title.ToString();

      title = GetLocalResourceObject("TEXT_Delete_Report_Instance"); //"Delete Report Instance"
      if (title != null)
        btnOK.Text = title.ToString();
    }

    if (!IsPostBack)
    {
      exportreportinstance = new ExportReportInstance();

      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
      MTGenericForm1.RenderObjectType = exportreportinstance.GetType(); //This should be same as the public property defined above 
      MTGenericForm1.RenderObjectInstanceName = "exportreportinstance";//This should be same as the public property defined above
      MTGenericForm1.TemplateName = "DataExportFramework.ShowReportInstanceDetails"; //This should be the <Name> tag from the page layout config file, not the file name itself
      MTGenericForm1.ReadOnly = false;

      //Gather Report Instance Details
      try
      {
        GetReportInstanceInfo();
      }
      catch (Exception ex)
      {
        SetError(ex.Message);
        Logger.LogError(ex.Message);
        //client.Abort();
      }

      if (!MTDataBinder1.DataBind())
      {
        Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
      }
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    if (!MTDataBinder1.Unbind())
    {
      Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
    }

    DataExportReportManagementServiceClient client = null;

    try
    {
      client = new DataExportReportManagementServiceClient();

      if (client.ClientCredentials != null)
      {
        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      //Call Instance Update Proc here
      var cryptoManager = new CryptoManager();

      int idreport = intincomingReportID;
      //int idreport = exportreportinstance.IDReport;
      int idreportinstance = intincomingReportInstanceID;// exportreportinstance.IDReportInstance;
      string instancedescr = exportreportinstance.ReportInstanceDescription;
      string reportoutputtype;
      if (exportreportinstance.ReportOutputType == ReportOutputTypeEnum.CSV)
      {
        reportoutputtype = "CSV";
      }
      else
      {
        if (exportreportinstance.ReportOutputType == ReportOutputTypeEnum.TXT)
        {
          reportoutputtype = "TXT";
        }
        else
        {
          reportoutputtype = "XML";
        }
      }

      string reportdistributiontype;
      if (exportreportinstance.ReportDistributionType == ReportDeliveryTypeEnum.Disk)
      {
        reportdistributiontype = "Disk";
      }
      else
      {
        reportdistributiontype = "FTP";
      }

      string reportdestination = exportreportinstance.ReportDestination;

      string reportexecutiontype = exportreportinstance.ReportExecutionType == ReportExecutionTypeEnum.EOP ? "EOP" : "Scheduled";

      DateTime reportactivationdate = exportreportinstance.InstanceActivationDate;
      DateTime reportdeactivationdate = exportreportinstance.InstanceDeactivationDate;
      string destinationaccessuser = exportreportinstance.FTPAccessUser;
      string destinationaccesspassword = exportreportinstance.FTPAccessPassword;
      destinationaccesspassword = cryptoManager.Encrypt(CryptKeyClass.DatabasePassword, destinationaccesspassword);

      int compressreport = !exportreportinstance.bCompressReport ? 0 : 1;

      int compressthreshold = exportreportinstance.CompressThreshold;

      string eopinstancename = "NA";

      if (reportexecutiontype == "EOP")
      {
        eopinstancename = "QueueEOPExportReports";
      }

      int dsid = 1;

      int createcontrolfile = !exportreportinstance.bGenerateControlFile ? 0 : 1;

      string controlfiledestination = exportreportinstance.ControlFileDeliveryLocation;

      int outputexecutionparameters = !exportreportinstance.bOutputExecParameters ? 0 : 1;

      int usequotedidentifiers = !exportreportinstance.bUseQuotedIdentifiers ? 0 : 1;

      DateTime lastundatetime = exportreportinstance.LastRunDate;
      DateTime nextrundatetime = exportreportinstance.NextRunDate;
      string parameterdefaultnamevalues = "";//"%%NM_LOGIN";
      string outputfilename = exportreportinstance.OutputFileName;

      if (strincomingAction == "Update")
      {
        client.UpdateExistingReportInstance(idreport, idreportinstance, instancedescr, reportoutputtype, reportdistributiontype, reportdestination,
        reportexecutiontype, reportactivationdate, reportdeactivationdate, destinationaccessuser, destinationaccesspassword,
        compressreport, compressthreshold, eopinstancename, dsid, createcontrolfile, controlfiledestination, outputexecutionparameters, usequotedidentifiers, lastundatetime,
        nextrundatetime, parameterdefaultnamevalues, outputfilename);

      }
      else
      {
        client.DeleteExistingReportInstance(idreportinstance);
      }

      if (strincomingAction == "Update")
      {
        //Response.Redirect("ShowReportInstanceDetails.aspx?idreportinstance="+strincomingReportInstanceId, false);
        //Response.Redirect("ManageReportInstances.aspx?reportid=" + strincomingReportId, false);
        Response.Redirect("ReportInstanceUpdated.aspx?reportid=" + strincomingReportId, false);
      }
      else
      {
        Response.Redirect("ReportInstanceDeleted.aspx?reportid=" + strincomingReportId, false);
      }
      client.Close();
    }

    catch (Exception ex)
    {
      SetError(ex.Message);
      Logger.LogError(ex.Message);
      if (client != null) client.Abort();
    }

  }

  protected void GetReportInstanceInfo()
  {
    DataExportReportManagementServiceClient client = null;

    try
    {
      client = new DataExportReportManagementServiceClient();

      if (client.ClientCredentials != null)
      {
        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      int idreportinstance = intincomingReportInstanceID; //hardcoded for timebeing 
      ExportReportInstance exportReportInstance;
      client.GetAReportInstance(idreportinstance, out exportReportInstance);
      exportreportinstance = exportReportInstance;
      client.Close();

    }

    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
      if (client != null) client.Abort();
      throw;
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    //Response.Redirect("ShowReportInstanceDetails.aspx?idreportinstance="+strincomingReportInstanceId, false);
    Response.Redirect("ManageReportInstances.aspx?reportid=" + strincomingReportId, false);
  }

  protected void btnManageInstanceParameterValues_Click(object sender, EventArgs e)
  {
    //Response.Redirect("ShowReportInstanceDetails.aspx?idreportinstance="+strincomingReportInstanceId, false);
    Response.Redirect("ManageReportInstanceParameterValues.aspx?reportinstanceid=" + strincomingReportInstanceId, false);
  }

  #region
  private void PopulateReportDistributionTypeDropDownControls()
  {
    var ddReportDistributionType = FindControlRecursive(MTGenericForm1, "ddReportDistributionType") as MTDropDown;

    if (ddReportDistributionType != null)
    {
      ddReportDistributionType.Listeners = "{select:ddReportDistributionTypeSelected}";
    }

    //Bind the database values to the drop down selected values
    //ddReportDistributionType.SelectedValue = exportreportinstance.ReportDistributionType.ToString();
  }

  #endregion



}


