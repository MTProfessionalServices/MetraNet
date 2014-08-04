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
using MetraTech;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.ActivityServices.Common;
using System.ServiceModel;
using MetraTech.Debug.Diagnostics;
using System.Web.Script.Serialization;
using System.Threading;


// Loads all the Generated Charges into a grid.
public partial class AjaxServices_GeneratedChargeSvc : MTListServicePage
{
  private const int MAX_RECORDS_PER_BATCH = 50;

  private Logger logger = new Logger("[AmpWizard]");

  private String _ajaxSvcCommand = String.Empty;
  private String _ampDecisionName = String.Empty;
  private String _ddSourceType = String.Empty;
  private String _numericSource = String.Empty;
  private String _ddSource = String.Empty;
  private String _whenGenerate = String.Empty;
  private String _howApply_v = String.Empty;
  private String _howApply_cn = String.Empty;

  protected bool ExtractDataInternal(AmpServiceClient client, ref MTList<GeneratedCharge> items, int batchID, int limit)
  {
    try
    {
      items.Items.Clear();
      items.PageSize = limit;
      items.CurrentPage = batchID;

      client.GetGeneratedCharges(ref items);
    }
    catch (Exception ex)
    {
      Response.StatusCode = 500; // right status code?
      logger.LogException("An error occurred while retrieving Generated Charges data.  Please check system logs.", ex);
      return false;
    }

    return true;
  }

  protected bool ExtractData(AmpServiceClient client, ref MTList<GeneratedCharge> items)
  {
    if (Page.Request["mode"] == "csv")
    {
      Response.BufferOutput = false;
      Response.ContentType = "application/csv";
      Response.AddHeader("Content-Disposition", "attachment; filename=export.csv");
      Response.BinaryWrite(BOM);
    }

    //if there are more records to process than we can process at once, we need to break up into multiple batches
    if ((items.PageSize > MAX_RECORDS_PER_BATCH) && (Page.Request["mode"] == "csv"))
    {
      int advancePage = (items.PageSize%MAX_RECORDS_PER_BATCH != 0) ? 1 : 0;

      int numBatches = advancePage + (items.PageSize/MAX_RECORDS_PER_BATCH);
      for (int batchID = 0; batchID < numBatches; batchID++)
      {
        if (!ExtractDataInternal(client, ref items, batchID + 1, MAX_RECORDS_PER_BATCH))
        {
          //unable to extract data
          return false;
        }

        string strCSV = ConvertObjectToCSV(items, (batchID == 0));
        Response.Write(strCSV);
      }
    }
    else
    {
      if (!ExtractDataInternal(client, ref items, items.CurrentPage, items.PageSize))
      {
        //unable to extract data
        return false;
      }

      if (Page.Request["mode"] == "csv")
      {
        string strCSV = ConvertObjectToCSV(items, true);
        Response.Write(strCSV);
      }
    }

    return true;
  }

  private void GetRequestParameters()
  {
    _ajaxSvcCommand = String.Empty;
    _ampDecisionName = String.Empty;
    _ddSourceType = String.Empty;
    _numericSource = String.Empty;
    _ddSource = String.Empty;
    _whenGenerate = String.Empty;
    _howApply_v = String.Empty;
    _howApply_cn = String.Empty;

    if (Request["command"] != null)
    {
      _ajaxSvcCommand = Request["command"];
    }

    if (Request["ampDecisionName"] != null)
    {
      _ampDecisionName = Request["ampDecisionName"];
    }

    if (Request["ddSourceType"] != null)
    {
      _ddSourceType = Request["ddSourceType"];
    }

    if (Request["numericSource"] != null)
    {
      _numericSource = Request["numericSource"];
    }

    if (Request["ddSource"] != null)
    {
      _ddSource = Request["ddSource"];
    }

    if (Request["whenGenerate"] != null)
    {
      _whenGenerate = Request["whenGenerate"];
    }

    if (Request["howApply_v"] != null)
    {
      _howApply_v = Request["howApply_v"];
    }
    if (Request["howApply_cn"] != null)
    {
      _howApply_cn = Request["howApply_v"];
    }
  }

  private void ModifyDecision()
  {
    AmpServiceClient ampSvcClient = null;
    Decision decisionInstance = null;
    try
    {
      ampSvcClient = new AmpServiceClient();
      if (ampSvcClient.ClientCredentials != null)
      {
        ampSvcClient.ClientCredentials.UserName.UserName = UI.User.UserName;
        ampSvcClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      ampSvcClient.GetDecision(_ampDecisionName, out decisionInstance);

      if (decisionInstance != null)
      {
        // update the decision with values passed to the ajax service
        if (_ddSourceType == GetGlobalResourceObject("AmpWizard", "TEXT_FIXED_VALUE").ToString() && !String.IsNullOrEmpty(_numericSource))
        {
          decisionInstance.ChargeValue = Convert.ToDecimal(_numericSource);
          decisionInstance.ChargeColumnName = null;
        }
        else if (_ddSourceType == GetGlobalResourceObject("AmpWizard", "TEXT_GET_FROM_PARAM_TABLE_COLUMN").ToString() && !String.IsNullOrEmpty(_ddSource))
        {
          decisionInstance.ChargeColumnName = _ddSource;
          decisionInstance.ChargeValue = null;
        }

        Decision.ChargeConditionEnum selectedChargeCondition;
        Enum.TryParse(_whenGenerate, out selectedChargeCondition);
        decisionInstance.ChargeCondition = selectedChargeCondition;

        Decision.ChargeAmountTypeEnum selectedAmountType;
        Enum.TryParse(_howApply_v, out selectedAmountType);
        decisionInstance.ChargeAmountTypeValue = selectedAmountType;
        if(selectedAmountType.Equals(Decision.ChargeAmountTypeEnum.CHARGE_FROM_PARAM_TABLE))
            decisionInstance.ChargeAmountTypeColumnName = _howApply_cn;

        ampSvcClient.SaveDecision(decisionInstance);
        Logger.LogDebug(String.Format("Successfully saved Decision '{0}'", _ampDecisionName));
      }

      // Clean up client.
      ampSvcClient.Close();
      ampSvcClient = null;

    }
    catch (Exception ex)
    {
      SetError(String.Format(Resources.AmpWizard.TEXT_ERROR_SAVE_DECISION, _ampDecisionName));
      Logger.LogException(String.Format("An error occurred while saving Decision '{0}'", _ampDecisionName), ex);
    }
    finally
    {
      if (ampSvcClient != null)
      {
        ampSvcClient.Abort();
      }
    }
  }

  private void LoadGrid()
  {
    AmpServiceClient client = null;

    // Load the GeneratedCharge grid.
    try
    {
      // Set up client.
      client = new AmpServiceClient();
      if (client.ClientCredentials != null)
      {
        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      MTList<GeneratedCharge> items = new MTList<GeneratedCharge>();

      SetPaging(items);
      SetSorting(items);
      SetFilters(items);

      if (ExtractData(client, ref items))
      {
        if (items.Items.Count == 0)
        {
          Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
          HttpContext.Current.ApplicationInstance.CompleteRequest();
        }
        else if (Page.Request["mode"] != "csv")
        {
          JavaScriptSerializer jss = new JavaScriptSerializer();
          string json = jss.Serialize(items);
          Response.Write(json);
        }
      }

      // Clean up client.
      client.Close();
      client = null;
    }
    catch (Exception ex)
    {
      logger.LogException("An error occurred while processing GeneratedCharges data.  Please check system logs.", ex);
      throw;
    }
    finally
    {
      Response.End();
      if (client != null)
      {
        client.Abort();
      }
    }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    // Extra check that user has permission to configure AMP decisions.
    if (!UI.CoarseCheckCapability("ManageAmpDecisions"))
    {
      Response.End();
      return;
    }

    using (new HighResolutionTimer("GeneratedChargeSvcAjax", 5000))
    {
      GetRequestParameters();
      switch (_ajaxSvcCommand)
      {
        case "UpdateDecision":
          ModifyDecision();
          break;

        case "LoadGrid":
          LoadGrid();
          break;
      }

      Response.End();
    } // using

  } // Page_Load
}
