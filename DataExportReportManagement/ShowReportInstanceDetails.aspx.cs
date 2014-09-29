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
using MetraTech.Security.Crypto;



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

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage DataExportFramework"))
    {
      Response.End();
      return;
    }
    strincomingReportInstanceId = Request.QueryString["idreportinstance"];
    intincomingReportInstanceID = System.Convert.ToInt32(strincomingReportInstanceId);

    strincomingReportId = Request.QueryString["idreport"];
    intincomingReportID = System.Convert.ToInt32(strincomingReportId);
    strincomingAction = Request.QueryString["action"];

    Logger.LogDebug("The report instance id is {0} ..", strincomingReportInstanceId);

    btnManageInstanceParameterValues.Visible = false;// This button may be completely removed later
    
    if (strincomingAction == "Update")
    {
      MTTitle1.Text = "Update Report Instance";
    }
    else
    {
      MTTitle1.Text = "Delete Report Instance";
      btnOK.Text = "Delete Report Instance";
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
        this.Logger.LogError(ex.Message);
        //client.Abort();
      }
      
      //ddDistributionType_SelectedIndexChanged(object sender, EventArgs e);

      if (!MTDataBinder1.DataBind())
      {
        Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
      }


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

        //Call Instance Update Proc here
        var cryptoManager = new CryptoManager();

        int idreport = intincomingReportID;
      //int idreport = exportreportinstance.IDReport;
      int idreportinstance = intincomingReportInstanceID;// exportreportinstance.IDReportInstance;
      string instancedescr=exportreportinstance.ReportInstanceDescription;
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
      reportdistributiontype="Disk";
      }
      else 
      {
      reportdistributiontype="FTP";
      }
        
      string reportdestination = exportreportinstance.ReportDestination;
      
      string reportexecutiontype;
      if (exportreportinstance.ReportExecutionType == ReportExecutionTypeEnum.EOP)
      {
      reportexecutiontype="EOP";
      }
      else 
      {
      reportexecutiontype="Scheduled";
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
      compressreport=0;
      }
      else 
      {
      compressreport=1;
      }
        
      int compressthreshold=exportreportinstance.CompressThreshold;

      string eopinstancename = "NA";

      if (reportexecutiontype == "EOP")
      {
        eopinstancename = "QueueEOPExportReports";
      }
      
      int dsid=1;
             
      int createcontrolfile;

      if (!exportreportinstance.bGenerateControlFile)
      //if (exportreportinstance.GenerateControlFile == GenerateControlFileEnum.No)
      {
      createcontrolfile=0;
      }
      else 
      {
      createcontrolfile =1;
      }
      
      string controlfiledestination=exportreportinstance.ControlFileDeliveryLocation;
      
      int outputexecutionparameters;
      if (!exportreportinstance.bOutputExecParameters)
      //if (exportreportinstance.OutputExecParameters == WriteExecParamsToReportEnum.No)
      {
      outputexecutionparameters=0;
      }
      else 
      {
      outputexecutionparameters =1;
      }
        
        int usequotedidentifiers;
      if (!exportreportinstance.bUseQuotedIdentifiers)
      //if (exportreportinstance.UseQuotedIdentifiers == UseQuotedIdentifiersEnum.No)
      {
      usequotedidentifiers=0;
      }
      else 
      {
      usequotedidentifiers =1;
      }

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
        this.Logger.LogError(ex.Message);
        client.Abort();
      }

    }

    protected void GetReportInstanceInfo()
    {
      DataExportReportManagementServiceClient client = null;

      try
      {
        client = new DataExportReportManagementServiceClient();

        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

        int idreportinstance = intincomingReportInstanceID; //hardcoded for timebeing 
        ExportReportInstance exportReportInstance;
        client.GetAReportInstance(idreportinstance, out exportReportInstance); 
        exportreportinstance = (ExportReportInstance)exportReportInstance;
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
      //Response.Redirect("ShowReportInstanceDetails.aspx?idreportinstance="+strincomingReportInstanceId, false);
      Response.Redirect("ManageReportInstances.aspx?reportid="+strincomingReportId, false);
    }

    protected void btnManageInstanceParameterValues_Click(object sender, EventArgs e)
    {
      //Response.Redirect("ShowReportInstanceDetails.aspx?idreportinstance="+strincomingReportInstanceId, false);
      Response.Redirect("ManageReportInstanceParameterValues.aspx?reportinstanceid=" + strincomingReportInstanceId, false);
    }

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


}