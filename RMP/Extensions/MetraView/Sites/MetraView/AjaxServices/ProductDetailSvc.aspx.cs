using System;
using System.ServiceModel;
using System.Text.RegularExpressions;
using System.Web.Script.Serialization;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;
using System.Threading;
using Resources;

// ReSharper disable InconsistentNaming
public partial class AjaxServices_ProductDetailSvc : MTListServicePage
// ReSharper restore InconsistentNaming
{
  private const int MaxRecordsPerBatch = 100;

  AccountSlice accountSlice;
  SingleProductSlice productSlice;
  string parentSessionId;

  protected bool ExtractDataInternal(BillManager billManager, ref MTList<BaseProductView> items, int batchId, int limit)
  {
    try
    {
      items.Items.Clear();

      items.PageSize = limit;
      items.CurrentPage = batchId;

      items = billManager.GetUsageDetails(accountSlice, productSlice, items);
    }
    catch (FaultException<MASBasicFaultDetail> ex)
    {
      Response.StatusCode = 500;
      Logger.LogError(ex.Detail.ErrorMessages[0]);
      if(ex.Detail.ErrorMessages[0].Contains("Manage Account Hierarchies"))
      {
        Response.Write(ErrorMessages.AjaxServices_ProductDetailSvc_ExtractDataInternal_You_do_not_have_access_to_view_these_details_);
      }
      else
      {
        Response.Write(ex.Detail.ErrorMessages[0]);
      }
      Response.End();
      return false;
    }
    catch (CommunicationException ex)
    {
      Response.StatusCode = 500;
      Logger.LogError(ex.Message);
      Response.Write(ex.Message);
      Response.End();
      return false;
    }
    catch (Exception ex)
    {
      Response.StatusCode = 500;
      Logger.LogError(ex.Message);
      Response.Write(ex.Message);
      Response.End();
      return false;
    }

    return true;
  }

  protected bool ExtractData(BillManager billManager, ref MTList<BaseProductView> items)
  {
    if (Page.Request["mode"] == "csv")
    {
      Response.BufferOutput = false;
      Response.ContentType = "application/csv";
      Response.AddHeader("Content-Disposition", "attachment; filename=export.csv");
      Response.BinaryWrite(BOM);
    }

    //if there are more records to process than we can process at once, we need to break up into multiple batches
    if ((items.PageSize > MaxRecordsPerBatch) && (Page.Request["mode"] == "csv"))
    {
      int advancePage = (items.PageSize % MaxRecordsPerBatch != 0) ? 1 : 0;

      int numBatches = advancePage + (items.PageSize / MaxRecordsPerBatch);
      for (int batchId = 0; batchId < numBatches; batchId++)
      {
        ExtractDataInternal(billManager, ref items, batchId + 1, MaxRecordsPerBatch);

        string strCsv = ConvertObjectToCSV(items, (batchId == 0));
        Response.Write(strCsv);
      }
    }
    else
    {
      ExtractDataInternal(billManager, ref items, items.CurrentPage, items.PageSize);
      if (Page.Request["mode"] == "csv")
      {
        string strCsv = ConvertObjectToCSV(items, true);
        Response.Write(strCsv);
      }
    }

    return true;
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    using (new HighResolutionTimer("ProductDetailSvc", 5000))
    {
      try
      {
        if (Request["accountSlice"] != null)
        {
          accountSlice = SliceConverter.FromString<AccountSlice>(Request["accountSlice"]);
        }

        if (Request["productSlice"] != null)
        {
          productSlice = SliceConverter.FromString<SingleProductSlice>(Request["productSlice"]);
          if (productSlice == null)
          {
            Logger.LogWarning("No product slice provided.");
            Response.End();
          }
        }

        if (Request["parentSessionID"] != null)
        {
          parentSessionId = Request["parentSessionID"];
        }

        var billManager = new BillManager(UI);
        var items = new MTList<BaseProductView>();
        SetPaging(items);
        SetSorting(items);
        SetFilters(items);

        // If this is child usage add the parent session id as a filter
        if (!String.IsNullOrEmpty(parentSessionId))
        {
          var parentFilter = new MTFilterElement("ParentSessionID", MTFilterElement.OperationType.Equal, parentSessionId);
          items.Filters.Add(parentFilter);
        }

        //unable to extract data
        if (!ExtractData(billManager, ref items))
        {
          return;
        }

        if (items.Items.Count == 0)
        {
          Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
          Response.End();
          return;
        }

        if (Page.Request["mode"] != "csv")
        {
          //convert BaseProductView into JSON
          var jss = new JavaScriptSerializer();
          string json = jss.Serialize(items);

          json = FixJsonDate(json);
          json = FixJsonBigInt(json);

          Response.Write(json);
        }


      }
      catch (ThreadAbortException)
      {
        //no op
      }
      catch (Exception ex)
      {
        Logger.LogException("Error getting product details.", ex);
      }
      Response.End();
    }
  }

  #region Convert DateTimes to user date time
  protected string FixJsonDate(string input, UIManager ui)
  {
    var me = new MatchEvaluator(MTListServicePage.MatchDate);
    string json = Regex.Replace(input, "\\\\/\\Date[(](-?\\d+)[)]\\\\/", me, RegexOptions.None);

    return json;
  }


  public static string MatchDate(Match m, UIManager ui)
  {
    if (m.Groups.Count >= 2)
    {
      long longDate;
      if (long.TryParse(m.Groups[1].Value, out longDate))
      {
        var ticks1970 = new DateTime(1970, 1, 1).Ticks;
        var retVal = new DateTime(longDate*10000 + ticks1970).ToLocalTime();
        return retVal.ToUserDateTimeString(ui);
      }
    }
    return m.Value;
  }
  #endregion

}
