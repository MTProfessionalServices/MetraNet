using System;
using System.ServiceModel;
using System.Text;
using System.Web;

using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Debug.Diagnostics;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;

public partial class MetraControl_FailedTransactions_AjaxServices_FailedTransactionsAjaxService : MTListServicePage
{
    private const int MAX_RECORDS_PER_BATCH = 50;

    #region Protected
    protected void Page_Load(object sender, EventArgs e)
    {
      FailedTransactionServiceClient client = null;
      try
      {
        client = new FailedTransactionServiceClient();
        client.Endpoint.Binding.SendTimeout = new TimeSpan(0, 3, 0);
        if (UI == null)
        {
          return;
        }
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        client.Open();
        var currentAction = GetAction(Request["action"]);
        var queryParam = FailedTransactionServiceAction.GetFailedTransaction;
        switch (currentAction)
        {
          case FailedTransactionServiceAction.ResubmitAll:
            if (!String.IsNullOrEmpty(Request["queryParam"]))
            {
              queryParam = GetAction(Request["queryParam"]);
            }
            ResubmitAllTransactions(client, queryParam);
            break;
          case FailedTransactionServiceAction.Resubmit:
            ResubmitSelectedTransactions(client);
            break;
          case FailedTransactionServiceAction.ChangeStatusAll:
            if (!String.IsNullOrEmpty(Request["queryParam"]))
            {
              queryParam = GetAction(Request["queryParam"]);
            }
            ChangeAllStatuses(client, queryParam);
            break;
          case FailedTransactionServiceAction.ChangeStatus:
            ChangeSelectedStatuses(client);
            break;
          case FailedTransactionServiceAction.UnregisteredAction:
            throw new Exception("UnregisteredAction");
          default:
            GetFailedTransaction(client, currentAction);
            break;
        }
      }
      catch (Exception ex)
      {
        Logger.LogError(String.Format("Exception Message:{0},/n Exception Stack Trace:{1}", ex.Message, ex.StackTrace));
        Response.StatusCode = 500;
        Response.Write(ex.Message);
      }
      finally
      {
        if (client != null)
        {
          client.Close();
          client.Abort();
        }
        Response.End();
      }
    }

    protected bool ExtractData(FailedTransactionServiceClient client, ref MTList<FailedTransactionRecord> items, FailedTransactionServiceAction action)
    {
      if (Page.Request["mode"] == "csv")
      {        
        Response.BufferOutput = false;
        Response.ContentType = "application/csv";
        Response.AddHeader("Content-Disposition", "attachment; filename=export.csv");
        Response.BinaryWrite(BOM);
      }

      if ((items.PageSize > MAX_RECORDS_PER_BATCH) && (Page.Request["mode"] == "csv"))
      {
        int advancePage = (items.PageSize % MAX_RECORDS_PER_BATCH != 0) ? 1 : 0;

        int numBatches = advancePage + (items.PageSize / MAX_RECORDS_PER_BATCH);
        for (int batchID = 0; batchID < numBatches; batchID++)
        {
          ExtractDataInternal(client, ref items, batchID + 1, MAX_RECORDS_PER_BATCH, action);
          string strCSV = ConvertObjectToCSV(items, (batchID == 0));
          Response.Write(strCSV);
        }
      }
      else
      {
        ExtractDataInternal(client, ref items, items.CurrentPage, items.PageSize, action);
        if (Page.Request["mode"] == "csv")
        {
          string strCSV = ConvertObjectToCSV(items, true);
          Response.Write(strCSV);
        }
      }
      return true;
    }

    protected bool ExtractDataInternal(FailedTransactionServiceClient client, ref MTList<FailedTransactionRecord> items, int batchID, int limit, FailedTransactionServiceAction action)
    {
      try
      {
        items.Items.Clear();
        items.PageSize = limit;
        items.CurrentPage = batchID;
        client.GetFailedTransaction(ref items, action);
      }
      catch (FaultException<MASBasicFaultDetail> faultException)
      {
        Response.StatusCode = 500;
        Logger.LogError(faultException.Detail.ErrorMessages[0]);
        Response.End();
        return false;
      }
      catch (CommunicationException comunicationException)
      {
        Response.StatusCode = 500;
        Logger.LogError(comunicationException.Message);
        Response.End();
        return false;
      }
      catch (Exception exeption)
      {
        Response.StatusCode = 500;
        Logger.LogError(exeption.Message);
        Response.End();
        return false;
      }
      return true;
    }

    protected override string ConvertRowToCSV(object curRow)
    {
      if (curRow == null)
      {
        return String.Empty;
      }
      var sb = new StringBuilder();
      int columnIndex = 0;
      while (!String.IsNullOrEmpty(Request["column[" + Convert.ToString(columnIndex) + "][columnID]"]))
      {
        var headerText = Request["column[" + Convert.ToString(columnIndex) + "][headerText]"];
        if (headerText.Equals("&nbsp;", StringComparison.InvariantCultureIgnoreCase))
        {
          columnIndex++;
          continue;
        }
        var curDataIndex = Request["column[" + Convert.ToString(columnIndex) + "][mapping]"];
        string cellValue = null;
        try
        {
          var failedTransactionRecord = curRow as FailedTransactionRecord;
          if (failedTransactionRecord != null)
          {
            var ftRecords = failedTransactionRecord.Fields;
            for (var i = 0; i < ftRecords.Count; i++)
            {
              if (ftRecords[i].FieldName == curDataIndex)
              {
                if (ftRecords[i].FieldDataType == typeof(DateTime).FullName)
                {
                  if (failedTransactionRecord.Fields[i].FieldValue != null)
                  {
                    var dt = Convert.ToDateTime(failedTransactionRecord.Fields[i].FieldValue);
                    cellValue = dt.ToShortDateString();
                  }
                }
                else
                {
                  if (failedTransactionRecord.Fields[i].FieldValue != null)
                  {
                    cellValue = failedTransactionRecord.Fields[i].FieldValue.ToString();
                  }
                }
              }
            }
          }
        }
        catch (Exception ex)
        {
          throw new Exception(ex.Message);
        }
        if (columnIndex > 0 && sb.Length > 0)
        {
          sb.Append(",");
        }
        sb.Append("\"");
        if (cellValue != null)
        {
          sb.Append(cellValue.Replace("\"", "\"\""));
        }
        sb.Append("\"");

        columnIndex++;
      }
      return sb.ToString();
    }
    #endregion

    #region Public
    private void ChangeAllStatuses(FailedTransactionServiceClient client, FailedTransactionServiceAction queryAction)
    {
      using (new HighResolutionTimer("ResubmitAllTransactions", 60000))
      {
        bool flag = true;
        var items = new MTList<int>();
        SetSorting(items);
        SetFilters(items);
        string status = String.IsNullOrEmpty(Request["status"]) ? string.Empty : Request["status"];
        string reason = String.IsNullOrEmpty(Request["reason"]) ? string.Empty : Request["reason"];
        string comment = String.IsNullOrEmpty(Request["comment"]) ? string.Empty : Request["comment"];
        bool doResubmit;
        if (!Boolean.TryParse(Request["doresubmit"], out doResubmit))
        {
          doResubmit = false;
        }
        if (!string.IsNullOrEmpty(status))
          client.ChangeStatusAllItems(items, status, reason, comment, doResubmit, queryAction, ref flag);
        Response.Write(flag);
      }
    }

    private void ChangeSelectedStatuses(FailedTransactionServiceClient client)
    {
      using (new HighResolutionTimer("ResubmitAllTransactions", 60000))
      {
        bool flag = true;
        var items = new MTList<int>();
        string sIds = Request["ids[]"];
        var ids = sIds.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
        foreach (var sid in ids)
        {
          int id = -1;
          if (Int32.TryParse(sid, out id))
          {
            items.Items.Add(id);
          }
        }
        string status = String.IsNullOrEmpty(Request["status"]) ? string.Empty : Request["status"];
        string reason = String.IsNullOrEmpty(Request["reason"]) ? string.Empty : Request["reason"];
        string comment = String.IsNullOrEmpty(Request["comment"]) ? string.Empty : Request["comment"];
        bool doResubmit;
        if (!Boolean.TryParse(Request["doresubmit"], out doResubmit))
        {
          doResubmit = false;
        }
        if (!string.IsNullOrEmpty(status))
          client.ChangeStatusSelectedItems(items, status, reason, comment, doResubmit, ref flag);
        Response.Write(flag);
      }
    }

    private void ResubmitAllTransactions(FailedTransactionServiceClient client, FailedTransactionServiceAction queryAction)
    {
      using (new HighResolutionTimer("ResubmitAllTransactions", 60000))
      {
        bool flag = true;
        var items = new MTList<int>();
        SetSorting(items);
        SetFilters(items);
        client.ResubmitAllItems(items, queryAction, ref flag);
        Response.Write(flag);
      }
    }

    private void ResubmitSelectedTransactions(FailedTransactionServiceClient client)
    {
      using (new HighResolutionTimer("ResubmitSelectedTransactions", 60000))
      {
        bool flag = true;
        if (!string.IsNullOrEmpty(Request["ids[]"]))
        {
          var items = new MTList<int>();
          string sIds = Request["ids[]"];
          var ids = sIds.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
          foreach (var sid in ids)
          {
            int id = -1;
            if (Int32.TryParse(sid, out id))
            {
              items.Items.Add(id);
            }
          }
          client.ResubmitSelectedItems(items, ref flag);
        }
        Response.Write(flag);
      }
    }

    private void GetFailedTransaction(FailedTransactionServiceClient client, FailedTransactionServiceAction action)
    {
      using (new HighResolutionTimer("GetFailedTransactions", 60000))
      {
        var items = new MTList<FailedTransactionRecord>();
        SetPaging(items);
        SetSorting(items);
        SetFilters(items);
        if (!ExtractData(client, ref items, action))
        {
          return;
        }
        if (items.Items.Count == 0)
        {
          Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
          HttpContext.Current.ApplicationInstance.CompleteRequest();
          return;
        }
        if (Page.Request["mode"] != "csv")
        {
          Response.Write(SerializeItems(items));
        }
      }
    }

    private string SerializeItems(MTList<FailedTransactionRecord> items)
    {
      var json = new StringBuilder();
      json.Append("{\"TotalRows\":");
      json.Append(Convert.ToString(items.TotalRows));
      json.Append(", \"Items\":[");
      for (int i = 0; i < items.Items.Count; i++)
      {
        FailedTransactionRecord record = items.Items[i];
        if (i > 0)
        {
          json.Append(",");
        }
        json.Append("{");
        for (int j = 0; j < record.Fields.Count; j++)
        {
          FailedTransactionField field = record.Fields[j];
          if (j > 0)
          {
            json.Append(",");
          }
          json.Append("\"");
          json.Append(field.FieldName);
          json.Append("\":");
          if (field.FieldValue == null)
          {
            json.Append("null");
          }
          else
          {
            if (typeof(String).ToString() == field.FieldDataType || typeof(DateTime).ToString() == field.FieldDataType || typeof(Guid).ToString() == field.FieldDataType || typeof(Byte[]).ToString() == field.FieldDataType)
            {
              json.Append("\"");
            }
            var value = "0";
            if (typeof(Byte[]).ToString() == field.FieldDataType)
            {
              Encoding enc = Encoding.ASCII;
              value = enc.GetString((Byte[])(field.FieldValue));
            }
            else
            {
              value = field.FieldValue.ToString();
            }
            var sb = new StringBuilder((value ?? string.Empty).EncodeForHtml());
            sb = sb.Replace("\"", "\\\"");
            sb = sb.Replace("\n", "<br />");
            sb = sb.Replace("\r", "");
            var fieldvalue = sb.ToString();
            json.Append(fieldvalue);
            if (typeof(String).ToString() == field.FieldDataType || typeof(DateTime).ToString() == field.FieldDataType || typeof(Guid).ToString() == field.FieldDataType || typeof(Byte[]).ToString() == field.FieldDataType)
            {
              json.Append("\"");
            }
          }
        }
        json.Append("}");
      }
      json.Append("]");
      json.Append(", \"CurrentPage\":");
      json.Append(Convert.ToString(items.CurrentPage));
      json.Append(", \"PageSize\":");
      json.Append(Convert.ToString(items.PageSize));
      json.Append(", \"SortProperty\":");
      if (items.SortCriteria == null || items.SortCriteria.Count == 0)
      {
        json.Append("null");
        json.Append(", \"SortDirection\":\"");
        json.Append(SortType.Ascending.ToString());
      }
      else
      {
        json.Append("\"");
        json.Append(items.SortCriteria[0].SortProperty);
        json.Append("\"");
        json.Append(", \"SortDirection\":\"");
        json.Append(items.SortCriteria[0].SortDirection.ToString());
      }
      json.Append("\"}");

      return json.ToString();
    }

    private FailedTransactionServiceAction GetAction(string action)
    {
      FailedTransactionServiceAction serviceAction;
      if ((Enum.TryParse(action, true, out serviceAction) && (Enum.IsDefined(typeof(FailedTransactionServiceAction), serviceAction))))
      {
        return serviceAction;
      }
      return FailedTransactionServiceAction.UnregisteredAction;
    }
    #endregion
}