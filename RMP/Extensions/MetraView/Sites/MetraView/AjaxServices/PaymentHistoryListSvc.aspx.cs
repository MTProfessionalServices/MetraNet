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
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.MetraPay;
using MetraTech.DomainModel.Billing;
using MetraTech.ActivityServices.Common;
using System.ServiceModel;
using MetraTech.Debug.Diagnostics;
using System.Web.Script.Serialization;

public partial class AjaxServices_PaymentHistoryListSvc : MTListServicePage
{
  private const int MAX_RECORDS_PER_BATCH = 50;

  protected void SetFilters(MTList<Payment> mtList)
  {
    int filterID = 0;

    while (!String.IsNullOrEmpty(this.Request["filter[" + filterID.ToString() + "][field]"]))
    {
      string propertyName = this.Request["filter[" + filterID.ToString() + "][field]"];
      propertyName = propertyName.Replace("ValueDisplayName", "");
      if (String.IsNullOrEmpty(propertyName))
      {
        continue;
      }

      
      object value = this.Request["filter[" + filterID.ToString() + "][data][value]"];
      MTFilterElement.OperationType op;

      switch (this.Request["filter[" + filterID.ToString() + "][data][comparison]"])
      {
        case "eq":
          op = MTFilterElement.OperationType.Equal;
          break;

        case "lk":
          op = MTFilterElement.OperationType.Like_W;

          //need to append wildcard if for LIKE operation
          if (Request["filter[" + filterID + "][data][type]"] == "string")
          {
            value = AppendWildcard(value.ToString());
          }
          break;

        //This request returns negative numbers, but the user is expecting positives, so switch < and >, and also take  
        // inverse of the value
        case "lt":
          op = MTFilterElement.OperationType.Less;
          break;

        case "lte":
          op = MTFilterElement.OperationType.LessEqual;
          break;

        case "gt":
          op = MTFilterElement.OperationType.Greater;
          break;

        case "gte":
          op = MTFilterElement.OperationType.GreaterEqual;
          break;

        case "ne":
          op = MTFilterElement.OperationType.NotEqual;
          break;


        case "":
          //if no operation is specified, default to LIKE_W for strings and equals for all other types
          if (this.Request["filter[" + filterID.ToString() + "][data][type]"] == "string")
          {
            op = MTFilterElement.OperationType.Like_W;
            value = AppendWildcard(value.ToString());
          }
          else
          {
            op = MTFilterElement.OperationType.Equal;
          }
          break;

        default:
          //if no operation is specified, default to LIKE_W for strings and equals for all other types
          if (this.Request["filter[" + filterID.ToString() + "][data][type]"] == "string")
          {
            op = MTFilterElement.OperationType.Like_W;
            value = AppendWildcard(value.ToString());
          }
          else
          {
            op = MTFilterElement.OperationType.Equal;
          }
          break;
      }

      if (propertyName.Equals("Amount"))
      {
        //We have a problem: payments are stored in the DB as negative numbers, but we need to treat them as positives.
        // So we take the inverse of the amount, and switch the operation from < to > and vice versa.
        decimal decVal;
        Decimal.TryParse(value.ToString(), out decVal);
        value = 0 - decVal;
        switch (op)
        {
          case MTFilterElement.OperationType.Greater:
            op = MTFilterElement.OperationType.Less;
            break;

          case MTFilterElement.OperationType.GreaterEqual:
            op = MTFilterElement.OperationType.LessEqual;
            break;

          case MTFilterElement.OperationType.Less:
            op = MTFilterElement.OperationType.Greater;
            break;

          case MTFilterElement.OperationType.LessEqual:
            op = MTFilterElement.OperationType.GreaterEqual;
            break;

        }
      }
      //attempt converting to date time
      string dataType = this.Request["filter[" + filterID.ToString() + "][data][type]"];
      if (!String.IsNullOrEmpty(dataType) && (dataType.ToLower() == "date"))
      {
        DateTime tmpDate;
        if (DateTime.TryParse(value.ToString(), out tmpDate))
        {
          value = tmpDate;
        }
      }

      MTFilterElement mtfe = new MTFilterElement(propertyName, op, value);

      mtList.Filters.Add(mtfe);

      filterID++;
    }
  }
  protected bool ExtractDataInternal(UsageHistoryServiceClient client, ref MTList<Payment> items, int batchID, int limit)
  {
    try
    {
      items.Items.Clear();

      items.PageSize = limit;
      items.CurrentPage = batchID;

      AccountIdentifier acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
      var billManager = new BillManager(UI);

      var lang = Session[Constants.SELECTED_LANGUAGE].ToString();
      client.GetPaymentHistoryLocalized(acct, lang, ref items);
    }
    catch (FaultException<MASBasicFaultDetail> ex)
    {
      Response.StatusCode = 500;
      Logger.LogError(ex.Detail.ErrorMessages[0]);
      Response.End();
      return false;
    }
    catch (CommunicationException ex)
    {
      Response.StatusCode = 500;
      Logger.LogError(ex.Message);
      Response.End();
      return false;
    }
    catch (Exception ex)
    {
      Response.StatusCode = 500;
      Logger.LogError(ex.Message);
      Response.End();
      return false;
    }

    return true;
  }

  protected bool ExtractData(UsageHistoryServiceClient client, ref MTList<Payment> items)
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
      int advancePage = (items.PageSize % MAX_RECORDS_PER_BATCH != 0) ? 1 : 0;

      int numBatches = advancePage + (items.PageSize / MAX_RECORDS_PER_BATCH);
      for (int batchID = 0; batchID < numBatches; batchID++)
      {
        ExtractDataInternal(client, ref items, batchID + 1, MAX_RECORDS_PER_BATCH);

        string strCSV = ConvertObjectToCSV(items, (batchID == 0));
        Response.Write(strCSV);
      }
    }
    else
    {
      ExtractDataInternal(client, ref items, items.CurrentPage, items.PageSize);
      if (Page.Request["mode"] == "csv")
      {
        string strCSV = ConvertObjectToCSV(items, true);
        Response.Write(strCSV);
      }
    }

    //Payments are returned as negative numbers, but we want them to be positive.
    foreach (Payment payment in items.Items)
    {
        payment.Amount = Math.Abs(payment.Amount);
        payment.AmountAsString = payment.AmountAsString.Replace('-',' ');
    }

      return true;
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    using (new HighResolutionTimer("PaymentHistoryListSvc", 5000))
    {
      UsageHistoryServiceClient client = null;

      try
      {
        client = new UsageHistoryServiceClient();

        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        MTList<Payment> items = new MTList<Payment>();

        SetPaging(items);
        SetSorting(items);
        SetFilters(items);

        //unable to extract data
        if (!ExtractData(client, ref items))
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
          //convert paymentMethods into JSON
          JavaScriptSerializer jss = new JavaScriptSerializer();
          string json = jss.Serialize(items);
          json = FixJsonDate(json);
          json = FixJsonBigInt(json);
          Response.Write(json);
        }

        Response.End();
      }
      finally
      {
        if (client != null)
        {
          if (client.State == CommunicationState.Opened)
          {
            client.Close();
          }
          else
          {
            client.Abort();
          }
        }
      }
    }
  }
}
