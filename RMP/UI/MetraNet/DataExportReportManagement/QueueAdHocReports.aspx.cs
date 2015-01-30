using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
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



public partial class DataExportReportManagement_QueueAdHocReports : MTPage
{
  public ExportReportDefinition queueadhocreports
  {
    get { return ViewState["queueadhocreports"] as ExportReportDefinition; } //The ViewState labels are immaterial here..
    set { ViewState["queueadhocreports"] = value; }
  }

  public string strincomingReportId { get; set; } //so we can read it any time in the session 
  public int intincomingReportID { get; set; }
  public string strincomingReportTitle { get; set; }

  public int intnumberofparametersassigned {get; set;}
  public string strParameterName1 { get; set; }
  public string strParameterName2 { get; set; }
  public string strParameterName3 { get; set; }
  public string strParameterName4 { get; set; }
  public string strParameterName5 { get; set; }
  
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage DataExportFramework"))
    {
      Response.End();
      return;
    }
    strincomingReportId = Request.QueryString["reportid"];
    intincomingReportID = System.Convert.ToInt32(strincomingReportId);
    strincomingReportTitle = Request.QueryString["reporttitle"];

    strParameterName1 = "";
    strParameterName2 = "";
    strParameterName3 = "";
    strParameterName4 = "";
    strParameterName5 = "";
    //intnumberofparametersassigned = 3;

   if (!IsPostBack)
    {
      queueadhocreports = new ExportReportDefinition();

      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
      MTGenericForm1.RenderObjectType = queueadhocreports.GetType(); //This should be same as the public property defined above 
      MTGenericForm1.RenderObjectInstanceName = "queueadhocreports";//This should be same as the public property defined above
      MTGenericForm1.TemplateName = "DataExportFramework.QueueAdHocReports"; //This should be the <Name> tag from the page layout config file, not the file name itself
      MTGenericForm1.ReadOnly = false;

      queueadhocreports.ReportTitle = strincomingReportTitle;
      queueadhocreports.AdhocReportDestination = "";
      queueadhocreports.AdhocFTPAccessUser = "";
      queueadhocreports.AdhocFTPAccessPassword = "";
      queueadhocreports.AdhocControlFileDeliveryLocation = "";

     //Get all parameters assigned to this report and display on the page load

      tbMTParam1.Visible = false;
      tbMTParam2.Visible = false;
      tbMTParam3.Visible = false;
      tbMTParam4.Visible = false;
      tbMTParam5.Visible = false;

      loadparameters();
     
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

         var cryptoManager = new CryptoManager();
        
        
        string strreportoutputtype;
      if (queueadhocreports.AdhocReportOutputType == ReportOutputTypeEnum.CSV)
      {
      strreportoutputtype="CSV";
      }
      else 
      {
      if (queueadhocreports.AdhocReportOutputType == ReportOutputTypeEnum.TXT)
      {
      strreportoutputtype="TXT";
      }
      else 
      {
      strreportoutputtype="XML";
      }
      }

      string strreportdistributiontype;
      if (queueadhocreports.AdhocReportDistributionType == ReportDeliveryTypeEnum.Disk)
      {
      strreportdistributiontype="Disk";
      }
      else 
      {
      strreportdistributiontype="FTP";
      }
        
      string reportdestination = queueadhocreports.AdhocReportDestination;

      if (strreportdistributiontype == "Disk"){
        if (reportdestination.Length > 2)
        {
          string slash = "\\";
          if (reportdestination.Substring(reportdestination.Length - 1) != slash)
          {
            reportdestination = reportdestination + '\\';
          } 
        }
      }
      
      int compressreport;
             
      if (!queueadhocreports.bAdhocCompressReport)
      //if (queueadhocreports.AdhocCompressReport == CompressReportEnum.No)
        //if (queueadhocreports.AdhocOutputExecParameters.checked == false) 
      {
      compressreport=0;
      }
      else 
      {
      compressreport=1;
      }
       
      int compressthreshold=queueadhocreports.AdhocCompressThreshold;
      int intidentity = 1;
      string parameterdefaultnamevalues="";
        
      //Code to form Parameter Deault Name Value String
      Logger.LogDebug("Number of parameters in this report at the time of OK are {0}", intnumberofparametersassigned);

      Logger.LogDebug("Number of parameters while page load in this report are {0}", queueadhocreports.ParamCount);

     //for (int i = 1; i < queueadhocreports.ParamCount; i++)

      //{

       // parameterdefaultnamevalues = parameterdefaultnamevalues + queueadhocreports.ParameterName + (i.ToString()) + queueadhocreports.ParameterValue+ (i.ToString());
      
      //}


        if (queueadhocreports.ParamCount == 5)
      {
        parameterdefaultnamevalues = queueadhocreports.ParameterName1 + queueadhocreports.ParameterValue1 + "," + queueadhocreports.ParameterName2  + queueadhocreports.ParameterValue2 + "," + queueadhocreports.ParameterName3  + queueadhocreports.ParameterValue3 + "," + queueadhocreports.ParameterName4  + queueadhocreports.ParameterValue4 + "," + queueadhocreports.ParameterName5  + queueadhocreports.ParameterValue5 + "^^";
      }
     if (queueadhocreports.ParamCount == 4)
        {
          parameterdefaultnamevalues = queueadhocreports.ParameterName1 + queueadhocreports.ParameterValue1 + "," + queueadhocreports.ParameterName2  + queueadhocreports.ParameterValue2 + "," + queueadhocreports.ParameterName3  + queueadhocreports.ParameterValue3 + "," + queueadhocreports.ParameterName4  + queueadhocreports.ParameterValue4;
        }
      if (queueadhocreports.ParamCount == 3)
          {
            parameterdefaultnamevalues = queueadhocreports.ParameterName1 + queueadhocreports.ParameterValue1 + "," + queueadhocreports.ParameterName2  + queueadhocreports.ParameterValue2 + "," + queueadhocreports.ParameterName3  + queueadhocreports.ParameterValue3;
          }
      if (queueadhocreports.ParamCount == 2)
            {
              parameterdefaultnamevalues = queueadhocreports.ParameterName1 + queueadhocreports.ParameterValue1 + "," + queueadhocreports.ParameterName2  + queueadhocreports.ParameterValue2;
            }
      if (queueadhocreports.ParamCount == 1)
              {
                parameterdefaultnamevalues = queueadhocreports.ParameterName1 + queueadhocreports.ParameterValue1;
              }
      
      //parameterdefaultnamevalues = "^^"+ strParameterName1 + "^^ =" + queueadhocreports.ParameterValue1; //^^NM_SPACE^^=mt";
      string destinationaccessuser = queueadhocreports.AdhocFTPAccessUser;
      string destinationaccesspassword = queueadhocreports.AdhocFTPAccessPassword;
      destinationaccesspassword = cryptoManager.Encrypt(CryptKeyClass.DatabasePassword, destinationaccesspassword);

      int createcontrolfile;

      if (!queueadhocreports.bAdhocGenerateControlFile) 
      //if (queueadhocreports.AdhocGenerateControlFile == GenerateControlFileEnum.No)
      {
      createcontrolfile=0;
      }
      else 
      {
      createcontrolfile =1;
      }
      
      string controlfiledestination=queueadhocreports.AdhocControlFileDeliveryLocation;
      
      int outputexecutionparameters;
      if (!queueadhocreports.bAdhocOutputExecParameters) 
      //if (queueadhocreports.AdhocOutputExecParameters == WriteExecParamsToReportEnum.No)
      {
      outputexecutionparameters=0;
      }
      else 
      {
      outputexecutionparameters =1;
      }
        
      string outputfilename = queueadhocreports.AdhocOutputFileName;
      int dsid=1;
      
      int usequotedidentifiers;
      if (!queueadhocreports.bAdhocUseQuotedIdentifiers)
      //if (queueadhocreports.AdhocUseQuotedIdentifiers == UseQuotedIdentifiersEnum.No)
      {
      usequotedidentifiers=0;
      }
      else 
      {
      usequotedidentifiers =1;
      }
        //Call Queue Adhoc Report Method here.. 
        client.QueueAdHocReport(intincomingReportID, strreportoutputtype, strreportdistributiontype, reportdestination, compressreport, 
          compressthreshold, intidentity, parameterdefaultnamevalues, destinationaccessuser, destinationaccesspassword, createcontrolfile, controlfiledestination,
          outputexecutionparameters, outputfilename, dsid, usequotedidentifiers);
        
        client.Close();
        Response.Redirect("AdHocReportManagement.aspx", false);
        //Response.Redirect("QueueAdHocReports.aspx?reportid=" + strincomingReportId + "&reporttitle=" + strincomingReportTitle, false);
      }

      catch (Exception ex)
      {
        SetError(ex.Message);
        this.Logger.LogError(ex.Message);
        client.Abort();
      }

    }

    protected void ddDistributionType_SelectedIndexChanged(object sender, EventArgs e)
    {

      //loadparameters();

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

    public void loadparameters()
      {
      
       DataExportReportManagementServiceClient client1 = null;

      client1 = new DataExportReportManagementServiceClient();

      client1.ClientCredentials.UserName.UserName = UI.User.UserName;
      client1.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      MTList<ExportReportParameters> paramlist = new MTList<ExportReportParameters>();

      client1.GetAssignedReportDefinitionParametersInfo(intincomingReportID, ref paramlist);

      client1.Close();

      intnumberofparametersassigned = paramlist.Items.Count;
      
      if (intnumberofparametersassigned == 0)
      {
        MTPanel1.Visible = false;
      }
      else
      {
        MTPanel1.Visible = true;
    
        if (intnumberofparametersassigned == 5)
        {
          queueadhocreports.ParameterName1 = "^^"+paramlist.Items[0].ParameterName + "^^=";
          queueadhocreports.ParameterName2 = "^^" + paramlist.Items[1].ParameterName + "^^=";
          queueadhocreports.ParameterName3 = "^^" + paramlist.Items[2].ParameterName + "^^=";
          queueadhocreports.ParameterName4 = "^^" + paramlist.Items[3].ParameterName + "^^=";
          queueadhocreports.ParameterName5 = "^^" + paramlist.Items[4].ParameterName + "^^=";
          tbMTParam1.Visible = true;
          tbMTParam2.Visible = true;
          tbMTParam3.Visible = true;
          tbMTParam4.Visible = true;
          tbMTParam5.Visible = true;
          tbMTParam1.Label = paramlist.Items[0].ParameterName;
          tbMTParam1.Text = paramlist.Items[0].ParameterDescription;
          tbMTParam2.Label = paramlist.Items[1].ParameterName;
          tbMTParam2.Text = paramlist.Items[1].ParameterDescription;
          tbMTParam3.Label = paramlist.Items[2].ParameterName;
          tbMTParam3.Text = paramlist.Items[2].ParameterDescription;
          tbMTParam4.Label = paramlist.Items[3].ParameterName;
          tbMTParam4.Text = paramlist.Items[3].ParameterDescription;
          tbMTParam5.Label = paramlist.Items[4].ParameterName;
          tbMTParam5.Text = paramlist.Items[4].ParameterDescription;
        }
    
        if (intnumberofparametersassigned == 4)
          {
            queueadhocreports.ParameterName1 = "^^" + paramlist.Items[0].ParameterName + "^^=";
            queueadhocreports.ParameterName2 = "^^" + paramlist.Items[1].ParameterName + "^^=";
            queueadhocreports.ParameterName3 = "^^" + paramlist.Items[2].ParameterName + "^^=";
            queueadhocreports.ParameterName4 = "^^" + paramlist.Items[3].ParameterName + "^^=";

            tbMTParam1.Visible = true;
            tbMTParam2.Visible = true;
            tbMTParam3.Visible = true;
            tbMTParam4.Visible = true;

            tbMTParam1.Label = paramlist.Items[0].ParameterName;
            tbMTParam1.Text = paramlist.Items[0].ParameterDescription;

            tbMTParam2.Label = paramlist.Items[1].ParameterName;
            tbMTParam2.Text = paramlist.Items[1].ParameterDescription;

            tbMTParam3.Label = paramlist.Items[2].ParameterName;
            tbMTParam3.Text = paramlist.Items[2].ParameterDescription;

            tbMTParam4.Label = paramlist.Items[3].ParameterName;
            tbMTParam4.Text = paramlist.Items[3].ParameterDescription;
          }

        if (intnumberofparametersassigned == 3)
            {
              queueadhocreports.ParameterName1 = "^^" + paramlist.Items[0].ParameterName + "^^=";
              queueadhocreports.ParameterName2 = "^^" + paramlist.Items[1].ParameterName + "^^=";
              queueadhocreports.ParameterName3 = "^^" + paramlist.Items[2].ParameterName + "^^=";

              tbMTParam1.Visible = true;
              tbMTParam2.Visible = true;
              tbMTParam3.Visible = true;

              tbMTParam1.Label = paramlist.Items[0].ParameterName;
              tbMTParam1.Text = paramlist.Items[0].ParameterDescription;

              tbMTParam2.Label = paramlist.Items[1].ParameterName;
              tbMTParam2.Text = paramlist.Items[1].ParameterDescription;

              tbMTParam3.Label = paramlist.Items[2].ParameterName;
              tbMTParam3.Text = paramlist.Items[2].ParameterDescription;
             }

        if (intnumberofparametersassigned == 2)
              {
                queueadhocreports.ParameterName1 = "^^" + paramlist.Items[0].ParameterName + "^^=";
                queueadhocreports.ParameterName2 = "^^" + paramlist.Items[1].ParameterName + "^^=";

                tbMTParam1.Visible = true;
                tbMTParam2.Visible = true;

                tbMTParam1.Label = paramlist.Items[0].ParameterName;
                tbMTParam1.Text = paramlist.Items[0].ParameterDescription;

                tbMTParam2.Label = paramlist.Items[1].ParameterName;
                tbMTParam2.Text = paramlist.Items[1].ParameterDescription;

              }
        if    (intnumberofparametersassigned == 1)   
              {
                queueadhocreports.ParameterName1 = "^^" + paramlist.Items[0].ParameterName + "^^=";
                tbMTParam1.Visible = true;
                tbMTParam1.Label = paramlist.Items[0].ParameterName;
                tbMTParam1.Text = paramlist.Items[0].ParameterDescription;

              }
        }

     queueadhocreports.ParamCount = paramlist.Items.Count;

     Logger.LogDebug("Number of parameters while page load in this report are {0}", paramlist.Items.Count);

  }
    
    protected void btnCancel_Click(object sender, EventArgs e)
    {
      Response.Redirect("AdHocReportManagement.aspx", false);
      //Response.Redirect("QueueAdHocReports.aspx?reportid=" + strincomingReportId + "&reporttitle=" + strincomingReportTitle, false);
    }
    }