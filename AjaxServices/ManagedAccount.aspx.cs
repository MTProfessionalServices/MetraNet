using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.Threading;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using MetraTech.Debug.Diagnostics;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;

public partial class AjaxServices_ManagedAccount : MTListServicePage
{
  const string sqlQueriesPath = @"Queries\Account";

  #region Field Index constants prefixed by operation name; used when retrieving value from SqlFields collection
  const int balanceSummary_Balance_Index = 0;
  const int balanceSummary_Currency_Index = 1;
  const int balanceSummary_BalanceDate_Index = 2;
  const int salesSummary_Ltv_Index = 1;
  const int salesSummary_Mrr_Index = 2;
  const int salesSummary_Currency_Index = 3;
  const int billingSummary_Order_Index = 0;
  const int billingSummary_Type_Index = 1;
  const int billingSummary_TransactionId_Index = 3;
  const int billingSummary_TransactionDate_Index = 4;
  const int billingSummary_Amount_Index = 5;
  const int billingSummary_InvoiceAmount_Index = 6;
  const int billingSummary_MrrAmount_Index = 10;
  const int billingSummary_Currency_Index = 11;
  const int subscriptionSummary_Type_Index = 0;
  const int subscriptionSummary_POName_Index = 1;
  const int subscriptionSummary_PODesc_Index = 2;
  const int subscriptionSummary_StartDt_Index = 3;
  const int subscriptionSummary_EndDt_Index = 4;
  const int subscriptionSummary_POId_Index = 5;
  const int subscriptionSummary_SubscriptionId_Index = 6;
  const int subscriptionSummary_RecurringCharge_Index = 7;
  const int subscriptionSummary_Currency_Index = 8;
  const int subscriptionSummary_Promocode_Index = 9;
  const int subscriptionSummary_GroupSubName_Index = 10;
  const int subscriptionSummary_GroupSubDesc_Index = 11;
  const int failedtransactionsummary_TotalCount_Index = 0;
  const int failedtransactionsummary_PayerCount_Index = 1;
  const int failedtransactionsummary_PayeeCount_Index = 2;

  #endregion

  protected void Page_Load(object sender, EventArgs e)
  {
    //parse query name
    String operation = Request["operation"];
    if (string.IsNullOrEmpty(operation))
    {
      Logger.LogWarning("No query specified");
      Response.Write("{\"Items\":[]}");
      Response.End();
      return;
    }

    Logger.LogInfo("operation : " + operation);

    using (new HighResolutionTimer("ManagedAccount", 5000))
    {
      try
      {
        MTList<SQLRecord> items = new MTList<SQLRecord>();
        Dictionary<string, object> paramDict = new Dictionary<string, object>();

        if (!String.IsNullOrEmpty(UI.Subscriber["_AccountID"]))
        {
          paramDict.Add("%%ACCOUNT_ID%%", int.Parse(UI.Subscriber["_AccountID"]));
        }
        else
        {
          Logger.LogWarning("No account currently managed");
          Response.Write("{\"Items\":[]}");
          Response.End();
          return;
        }

        GetDataForOperation(operation, paramDict, ref items);

        if (items.Items.Count == 0)
        {
          Response.Write("{\"Items\":[]}");
          Response.End();
        }
        else
        {
          string json = ConstructJson(items, operation); 
          Logger.LogInfo("Returning " + json);
          Response.Write(json);
          Response.End();
        }

      }
      catch (ThreadAbortException ex)
      {
        //Looks like Response.End is deprecated/changed
        //Might have a lot of unhandled exceptions in product from when we call response.end
        //http://support.microsoft.com/kb/312629
        //Logger.LogError("Thread Abort Exception: {0} {1}", ex.Message, ex.ToString());
      }
      catch (Exception ex)
      {
        Logger.LogError("Exception: {0} {1}", ex.Message, ex.ToString());
        Response.Write("{\"Items\":[]}");
        Response.End();
      }
    }

  }

  private void GetDataForOperation(string operation, Dictionary<string, object> paramDict, ref MTList<SQLRecord> items)
  {
    string sqlQuery = string.Empty;
    switch (operation)
    {
      case "subscriptionsummary":
        sqlQuery = "__ACCOUNT_SUBSCRIPTIONSUMMARY__";
        break;
      case "paymentsummary":
        sqlQuery = "__ACCOUNT_PAYMENTSUMMARY__";
        break;
      //case "invoicesummary":
      //  sqlQuery = "__ACCOUNT_INVOICESUMMARY__";
      //  break;
      case "balancesummary":
        sqlQuery = "__ACCOUNT_BALANCESUMMARY__";
        break;
      case "billingsummary":
        sqlQuery = "__ACCOUNT_BILLINGSUMMARY__";
        break;
      //case "discountcommitmentsummary":
      //  sqlQuery = "__ACCOUNT_DISCOUNTANDCOMMITMENTSUMMARY__";
      //  break;
      case "salessummary":
        sqlQuery = "__ACCOUNT_SALESSUMMARY__";
        break;
      case "failedtransactionsummary":
        sqlQuery = "__ACCOUNT_FAILEDTRANSACTION_COUNT__";
        break;
    }
    GetData(sqlQuery, paramDict, ref items);
  }

  private void GetData(string sqlQueryTag, Dictionary<string, object> paramDict, ref MTList<SQLRecord> items)
  {

    using (IMTConnection conn = ConnectionManager.CreateConnection())
    {

      using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(sqlQueriesPath, sqlQueryTag))
      {
        if (paramDict != null)
        {
          foreach (var pair in paramDict)
          {
            stmt.AddParam(pair.Key, pair.Value);
          }
        }

        using (IMTDataReader reader = stmt.ExecuteReader())
        {

          ConstructItems(reader, ref items);
        }
      }

      conn.Close();
    }



  }

  protected void ConstructItems(IMTDataReader rdr, ref MTList<SQLRecord> items)
  {
    items.Items.Clear();

    // process the results
    while (rdr.Read())
    {
      SQLRecord record = new SQLRecord();


      for (int i = 0; i < rdr.FieldCount; i++)
      {
        SQLField field = new SQLField();
        field.FieldDataType = rdr.GetType(i);
        field.FieldName = rdr.GetName(i);

        if (!rdr.IsDBNull(i))
        {
          field.FieldValue = rdr.GetValue(i);
        }

        record.Fields.Add(field);
      }

      items.Items.Add(record);
    }
  }

  private string ConstructJson(MTList<SQLRecord> items, string operation)
  {
    var json = new StringBuilder();
    string item = string.Empty;
    //format dates/amounts used as data in client side for formatting or plotting graphs using invaraint culture otherwise culture specific decimal/group seperators mess up with json returned
    var invariantCulture = CultureInfo.InvariantCulture;

    json.Append("{\"Items\":[");

    for (int i = 0; i < items.Items.Count; i++)
    {
      SQLRecord record = items.Items[i];

      if (i > 0)
      {
        json.Append(",");
      }

      json.Append("{");

      if (record.Fields.Count > 0)
      {
        switch (operation)
        {
          case "balancesummary":
            item = string.Format("\"current_balanceAsString\":{0},", FormatCurrencyValue(record.Fields[balanceSummary_Balance_Index], record.Fields[balanceSummary_Currency_Index].FieldValue.ToString()));
            json.Append(item);
            item = string.Format("\"currentbalancedate\":{0}", FormatFieldValue(record.Fields[balanceSummary_BalanceDate_Index], invariantCulture));
            json.Append(item);
            break;
          case "salessummary":
            item = string.Format("\"ltv\":{0},", FormatCurrencyValue(record.Fields[salesSummary_Ltv_Index], record.Fields[salesSummary_Currency_Index].FieldValue.ToString())); 
            json.Append(item);
            item = string.Format("\"mrr\":{0}", FormatCurrencyValue(record.Fields[salesSummary_Mrr_Index], record.Fields[salesSummary_Currency_Index].FieldValue.ToString())); 
            json.Append(item);
            break;
          case "billingsummary":
            item = string.Format("\"n_order\":{0},", FormatFieldValue(record.Fields[billingSummary_Order_Index]));
            json.Append(item);
            item = string.Format("\"nm_type\":{0},", FormatFieldValue(record.Fields[billingSummary_Type_Index])); 
            json.Append(item);
            item = string.Format("\"id_transaction\":{0},", FormatFieldValue(record.Fields[billingSummary_TransactionId_Index])); 
            json.Append(item);
            item = string.Format("\"dt_transaction\":{0},", FormatFieldValue(record.Fields[billingSummary_TransactionDate_Index]));
            json.Append(item);
            item = string.Format("\"dt_transactionGraph\":{0},", FormatFieldValue(record.Fields[billingSummary_TransactionDate_Index], invariantCulture)); 
            json.Append(item);
            item = string.Format("\"dt_transactionGraphTooltip\":{0},", FormatDateTime(record.Fields[billingSummary_TransactionDate_Index], "MMMM dd, yyyy")); 
            json.Append(item);
            item = string.Format("\"n_amount\":{0},", FormatFieldValue(record.Fields[billingSummary_Amount_Index], invariantCulture));
            json.Append(item);
            item = string.Format("\"n_amountAsString\":{0},", FormatCurrencyValue(record.Fields[billingSummary_Amount_Index], record.Fields[billingSummary_Currency_Index].FieldValue.ToString())); 
            json.Append(item);
            item = string.Format("\"n_invoice_amount\":{0},", FormatFieldValue(record.Fields[billingSummary_InvoiceAmount_Index], invariantCulture));
            json.Append(item);
            item = string.Format("\"n_invoiceamountAsString\":{0},", FormatCurrencyValue(record.Fields[billingSummary_InvoiceAmount_Index], record.Fields[billingSummary_Currency_Index].FieldValue.ToString()));
            json.Append(item);
            item = string.Format("\"n_mrr_amount\":{0},", FormatFieldValue(record.Fields[billingSummary_MrrAmount_Index], invariantCulture));
            json.Append(item);
            item = string.Format("\"n_mrramountAsString\":{0}", FormatCurrencyValue(record.Fields[billingSummary_MrrAmount_Index], record.Fields[billingSummary_Currency_Index].FieldValue.ToString()));
            json.Append(item);
            break;
          case "subscriptionsummary":
            item = string.Format("\"subscriptiontype\":{0},", FormatFieldValue(record.Fields[subscriptionSummary_Type_Index]));
            json.Append(item);
            item = string.Format("\"productofferingname\":{0},", FormatFieldValue(record.Fields[subscriptionSummary_POName_Index]));
            json.Append(item);
            item = string.Format("\"productofferingdescription\":{0},", FormatFieldValue(record.Fields[subscriptionSummary_PODesc_Index]));
            json.Append(item);
            item = string.Format("\"subscriptionstart\":{0},", FormatFieldValue(record.Fields[subscriptionSummary_StartDt_Index]));
            json.Append(item);
            item = string.Format("\"subscriptionend\":{0},", FormatFieldValue(record.Fields[subscriptionSummary_EndDt_Index]));
            json.Append(item);
            item = string.Format("\"productofferingid\":{0},", FormatFieldValue(record.Fields[subscriptionSummary_POId_Index]));
            json.Append(item);
            item = string.Format("\"subscriptionid\":{0},", FormatFieldValue(record.Fields[subscriptionSummary_SubscriptionId_Index]));
            json.Append(item);
            item = string.Format("\"recurringchargeAsString\":{0},", FormatCurrencyValue(record.Fields[subscriptionSummary_RecurringCharge_Index], record.Fields[subscriptionSummary_Currency_Index].FieldValue.ToString()));
            json.Append(item);
            item = string.Format("\"promocode\":{0},", FormatFieldValue(record.Fields[subscriptionSummary_Promocode_Index]));
            json.Append(item);
            item = string.Format("\"groupsubscriptionname\":{0},", FormatFieldValue(record.Fields[subscriptionSummary_GroupSubName_Index]));
            json.Append(item);
            item = string.Format("\"groupsubscriptiondescription\":{0}", FormatFieldValue(record.Fields[subscriptionSummary_GroupSubDesc_Index]));
            json.Append(item);
            break;
          case "failedtransactionsummary":
            item = string.Format("\"totalcount\":{0},", FormatFieldValue(record.Fields[failedtransactionsummary_TotalCount_Index]));
            json.Append(item);
            item = string.Format("\"payercount\":{0},", FormatFieldValue(record.Fields[failedtransactionsummary_PayerCount_Index]));
            json.Append(item);
            item = string.Format("\"payeecount\":{0}", FormatFieldValue(record.Fields[failedtransactionsummary_PayeeCount_Index]));
            json.Append(item);
            break;
        }
      }
      json.Append("}");
    }

    json.Append("]");

    json.Append("}");

    return json.ToString();
  }

  private string FormatFieldValue(SQLField field, CultureInfo formatCulture = null)
  {
    if (field.FieldValue == null) return "null";
    string fieldValue = "0";
    fieldValue = (formatCulture == null) ? field.FieldValue.ToString() : Convert.ToString(field.FieldValue, formatCulture);// field.ToString();

    // CORE-5487 HtmlEncode the field so XSS tags don't show up in UI.
    //StringBuilder sb = new StringBuilder(HttpUtility.HtmlEncode(value));
    // CORE-5938: Audit log: incorrect character encoding in Details row 
    var sb = new StringBuilder((fieldValue ?? string.Empty).EncodeForHtml());
    sb = sb.Replace("\"", "\\\"");
    //CORE-5320: strip all the new line characters. They are not allowed in jason
    // Oracle can return them and breeak our ExtJs grid with an ugly "Session Time Out" catch all error message
    // TODO: need to find other places where JSON is generated and strip new line characters.
    sb = sb.Replace("\n", "<br />");
    sb = sb.Replace("\r", "");
    
    return ((typeof (String) == field.FieldDataType || typeof (DateTime) == field.FieldDataType ||
             typeof (Guid) == field.FieldDataType || typeof (Byte[]) == field.FieldDataType))
             ? string.Format("\"{0}\"", sb)
             : string.Format("{0}", sb);

  }

  private string FormatCurrencyValue(SQLField field, string currency)
  {
    return string.Format("\"{0}\"", (field.FieldValue == null) ? "" : CurrencyFormatter.Format(field.FieldValue, currency));
  }

  private string FormatDateTime(SQLField field, string format)
  {
    return (field.FieldValue == null) ? "null" : string.Format("\"{0}\"", Convert.ToDateTime(field.FieldValue).ToString(format));
  }

  //protected string SerializeItems(MTList<SQLRecord> items)
  //{
  //  StringBuilder json = new StringBuilder();

  //  //json.Append("{\"TotalRows\":");
  //  //json.Append(items.TotalRows.ToString());

  //  json.Append("{\"Items\":[");

  //  for (int i = 0; i < items.Items.Count; i++)
  //  {
  //    SQLRecord record = items.Items[i];

  //    if (i > 0)
  //    {
  //      json.Append(",");
  //    }

  //    json.Append("{");

  //    //iterate through fields
  //    for (int j = 0; j < record.Fields.Count; j++)
  //    {
  //      SQLField field = record.Fields[j];
  //      if (j > 0)
  //      {
  //        json.Append(",");
  //      }

  //      json.Append("\"");
  //      json.Append(field.FieldName);
  //      json.Append("\":");

  //      if (field.FieldValue == null)
  //      {
  //        json.Append("null");
  //      }
  //      else
  //      {

  //        if (typeof(String) == field.FieldDataType || typeof(DateTime) == field.FieldDataType || typeof(Guid) == field.FieldDataType || typeof(Byte[]) == field.FieldDataType)
  //        {
  //          json.Append("\"");
  //        }


  //        string value = "0";
  //        if (typeof(Byte[]) == field.FieldDataType)
  //        {
  //          System.Text.Encoding enc = System.Text.Encoding.ASCII;
  //          value = enc.GetString((Byte[])(field.FieldValue));
  //        }
  //        else
  //        {
  //          value = field.FieldValue.ToString();
  //        }


  //        // CORE-5487 HtmlEncode the field so XSS tags don't show up in UI.
  //        //StringBuilder sb = new StringBuilder(HttpUtility.HtmlEncode(value));
  //        // CORE-5938: Audit log: incorrect character encoding in Details row 
  //        StringBuilder sb = new StringBuilder((value ?? string.Empty).EncodeForHtml());
  //        sb = sb.Replace("\"", "\\\"");
  //        //CORE-5320: strip all the new line characters. They are not allowed in jason
  //        // Oracle can return them and breeak our ExtJs grid with an ugly "Session Time Out" catch all error message
  //        // TODO: need to find other places where JSON is generated and strip new line characters.
  //        sb = sb.Replace("\n", "<br />");
  //        sb = sb.Replace("\r", "");
  //        string fieldvalue = sb.ToString();

  //        json.Append(fieldvalue);

  //        if (typeof(String) == field.FieldDataType || typeof(DateTime) == field.FieldDataType || typeof(Guid) == field.FieldDataType || typeof(Byte[]) == field.FieldDataType)
  //        {
  //          json.Append("\"");
  //        }

  //      }
  //    }

  //    json.Append("}");
  //  }

  //  json.Append("]");

  //  json.Append("}");

  //  return json.ToString();
  //}
}

