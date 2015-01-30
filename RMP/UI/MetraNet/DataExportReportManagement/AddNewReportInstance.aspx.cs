using System;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;
using MetraTech.Security.Crypto;
using MetraTech.UI.Controls;


public partial class DataExportReportManagement_AddNewReportInstance : MTPage
{
  public ExportReportInstance exportreportinstance
  {
    get { return ViewState["exportreportinstance"] as ExportReportInstance; } //The ViewState labels are immaterial here..
    set { ViewState["exportreportinstance"] = value; }
  }

  public string strincomingReportId { get; set; } //so we can read it any time in the session 
  public int intincomingReportID { get; set; }
  public string strincomingReportTitle { get; set; }

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
    strincomingReportId = Request.QueryString["reportid"];
    intincomingReportID = Convert.ToInt32(strincomingReportId);
    strincomingReportTitle = Request.QueryString["reporttitle"];

    if (!IsPostBack)
    {
      exportreportinstance = new ExportReportInstance();

      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
      MTGenericForm1.RenderObjectType = exportreportinstance.GetType(); //This should be same as the public property defined above 
      MTGenericForm1.RenderObjectInstanceName = "exportreportinstance";//This should be same as the public property defined above
      MTGenericForm1.TemplateName = "DataExportFramework.CreateReportInstance"; //This should be the <Name> tag from the page layout config file, not the file name itself
      MTGenericForm1.ReadOnly = false;


      //Set some default values for Dates
      exportreportinstance.InstanceActivationDate = DateTime.Today;
      exportreportinstance.InstanceDeactivationDate = DateTime.Today.AddYears(20);
      exportreportinstance.LastRunDate = DateTime.Today.AddDays(-1);
      exportreportinstance.NextRunDate = DateTime.Today;

      //Load the blank page for creating a new report instance

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

      var cryptoManager = new CryptoManager();

      // Hard Coded value for testing purpose only. This value has to come from the calling page
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

      if (reportdistributiontype == "Disk")
      {
        if (reportdestination.Length > 2)
        {
          string slash = "\\";
          if (reportdestination.Substring(reportdestination.Length - 1) != slash)
          {
            reportdestination = reportdestination + '\\';
          }
        }
      }
      string reportexecutiontype;
      if (exportreportinstance.ReportExecutionType == ReportExecutionTypeEnum.EOP)
      {
        reportexecutiontype = "EOP";
      }
      else
      {
        reportexecutiontype = "Scheduled";
      }


      DateTime reportactivationdate = exportreportinstance.InstanceActivationDate;
      DateTime reportdeactivationdate = exportreportinstance.InstanceDeactivationDate;
      string destinationaccessuser = exportreportinstance.FTPAccessUser;
      string destinationaccesspassword = exportreportinstance.FTPAccessPassword;
      destinationaccesspassword = cryptoManager.Encrypt(CryptKeyClass.DatabasePassword, destinationaccesspassword);

      int compressreport;
      if (!exportreportinstance.bCompressReport)
      //if (exportreportinstance.CompressReport == CompressReportEnum.No)
      {
        compressreport = 0;
      }
      else
      {
        compressreport = 1;
      }

      int compressthreshold = exportreportinstance.CompressThreshold;

      string eopinstancename = "NA";

      if (reportexecutiontype == "EOP")
      {
        eopinstancename = "QueueEOPExportReports";
      }

      int dsid = 1;

      int createcontrolfile;

      if (!exportreportinstance.bGenerateControlFile)
      //if (exportreportinstance.GenerateControlFile == GenerateControlFileEnum.No)
      {
        createcontrolfile = 0;
      }
      else
      {
        createcontrolfile = 1;
      }

      string controlfiledestination = exportreportinstance.ControlFileDeliveryLocation;

      int outputexecutionparameters;
      if (!exportreportinstance.bOutputExecParameters)
      //if (exportreportinstance.OutputExecParameters == WriteExecParamsToReportEnum.No)
      {
        outputexecutionparameters = 0;
      }
      else
      {
        outputexecutionparameters = 1;
      }

      int usequotedidentifiers;
      if (!exportreportinstance.bUseQuotedIdentifiers)
      //if (exportreportinstance.UseQuotedIdentifiers == UseQuotedIdentifiersEnum.No)
      {
        usequotedidentifiers = 0;
      }
      else
      {
        usequotedidentifiers = 1;
      }

      DateTime lastundatetime = exportreportinstance.LastRunDate;
      DateTime nextrundatetime = exportreportinstance.NextRunDate;
      string parameterdefaultnamevalues = "";
      string outputfilename = exportreportinstance.OutputFileName;

      //Call Create New Report Instance Method

      client.CreateNewReportInstance(intincomingReportID, instancedescr, reportoutputtype, reportdistributiontype, reportdestination,
      reportexecutiontype, reportactivationdate, reportdeactivationdate, destinationaccessuser, destinationaccesspassword,
      compressreport, compressthreshold, dsid, eopinstancename, createcontrolfile, controlfiledestination, outputexecutionparameters, usequotedidentifiers, lastundatetime,
      nextrundatetime, parameterdefaultnamevalues, outputfilename);

      //Response.Redirect("ManageReportInstances.aspx?reportid=" + strincomingReportId, false);
      Response.Redirect("ReportInstanceCreated.aspx?reportid=" + strincomingReportId, false);
      client.Close();

    }

    catch (Exception ex)
    {
      SetError(ex.Message);
      Logger.LogError(ex.Message);
      if (client != null) client.Abort();
    }

  }


  /*
   protected void ddDistributionType_SelectedIndexChanged(object sender, EventArgs e)
   {

     if (ddDistributionType.SelectedValue == "FTP")
     {
       tbFTPUser.Visible = true;
       pmFTPPassword.Visible = true;
       chkGenerateControlFile.Visible = true;
       tbControlFileLocation.Visible = true;
       tbReportDestination.Visible = true;
     }
     else
     {
       tbFTPUser.Visible = false;
       pmFTPPassword.Visible = false;
       chkGenerateControlFile.Visible = false;
       tbControlFileLocation.Visible = false;
       tbReportDestination.Visible = true;

     }

   }
 */
  protected void btnCancel_Click(object sender, EventArgs e)
  {

    Response.Redirect("ManageReportInstances.aspx?reportid=" + strincomingReportId, false);

  }

  #region
  private void PopulateReportDistributionTypeDropDownControls()
  {
    var ddReportDistributionType = FindControlRecursive(MTGenericForm1, "ddReportDistributionType") as MTDropDown;

    if (ddReportDistributionType != null)
    {
      ddReportDistributionType.Listeners = "{select:ddReportDistributionTypeSelected}";
    }

  }

  #endregion

}

