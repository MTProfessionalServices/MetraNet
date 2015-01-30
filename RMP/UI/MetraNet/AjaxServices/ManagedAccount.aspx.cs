using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Threading;
using agsXMPP.protocol.x.data;
using MetraTech;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.Core;
using MetraTech.DataAccess;
using MetraTech.Debug.Diagnostics;
using MetraTech.Interop.QueryAdapter;
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
  const int billingSummary_ItemDesc_Index = 12;
  const int subscriptionSummary_Type_Index = 0;
  const int subscriptionSummary_POName_Index = 1;
  const int subscriptionSummary_PODesc_Index = 2;
  const int subscriptionSummary_StartDt_Index = 3;
  const int subscriptionSummary_EndDt_Index = 4;
  const int subscriptionSummary_POId_Index = 5;
  const int subscriptionSummary_SubscriptionId_Index = 6;
  const int subscriptionSummary_GroupSubName_Index = 10;
  const int subscriptionSummary_GroupSubDesc_Index = 11;
  const int failedtransactionsummary_TotalCount_Index = 0;
  const int failedtransactionsummary_PayerCount_Index = 1;
  const int failedtransactionsummary_PayeeCount_Index = 2;

  #endregion

  private struct SqlParameter
  {
    public string ParamName;
    public MTParameterType SqlType;
    public object Value ;
  }

  private bool ShowFinancialData { get; set; }

  protected void Page_Load(object sender, EventArgs e)
  {
    ShowFinancialData = true; //UI.CoarseCheckCapability("View Summary Financial Information");

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
        IList<SqlParameter> paramDict = new List<SqlParameter>();
        
        if (!String.IsNullOrEmpty(UI.Subscriber["_AccountID"]))
        {
          paramDict.Add(new SqlParameter{ParamName = "%%ACCOUNT_ID%%"
                                        , SqlType = MTParameterType.Integer
                                        , Value = int.Parse(UI.Subscriber["_AccountID"])});
        }
        else
        {
          Logger.LogWarning("No account currently managed");
          Response.Write("{\"Items\":[]}");
          Response.End();
          return;
        }

        if (operation == "subscriptionsummary")
        {
          paramDict.Add(new SqlParameter
            { ParamName = "%%LANG_ID%%",
              SqlType = MTParameterType.Integer,
              Value = UI.SessionContext.LanguageID
            });
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
        Logger.LogInfo("Handled Exception from Response.Write() {0} ", ex.Message);
      }
      catch (Exception ex)
      {
        Logger.LogError("Exception: {0} {1}", ex.Message, ex.ToString());
        Response.Write("{\"Items\":[]}");
        Response.End();
      }
    }

  }

  private void GetDataForOperation(string operation, IEnumerable<SqlParameter> paramLst, ref MTList<SQLRecord> items)
  {
    switch (operation)
    {
      case "subscriptionsummary":
        GetData("__ACCOUNT_SUBSCRIPTIONSUMMARY__", paramLst, ref items, true);
        break;
      case "paymentsummary":
        GetData("__ACCOUNT_PAYMENTSUMMARY__", paramLst, ref items);
        break;
      case "balancesummary":
        GetData("__ACCOUNT_BALANCESUMMARY__", paramLst, ref items);
        break;
      case "billingsummary":
        GetData("__ACCOUNT_BILLINGSUMMARY__", paramLst, ref items, true);
        break;
      case "salessummary":
        GetData("__ACCOUNT_SALESSUMMARY__", paramLst, ref items);
        break;
      case "failedtransactionsummary":
        GetData("__ACCOUNT_FAILEDTRANSACTION_COUNT__", paramLst, ref items);
        break;
    }
  }

  private void GetData(string sqlQueryTag, IEnumerable<SqlParameter> paramsList, ref MTList<SQLRecord> items, bool isSortable = false)
  {
    using (IMTConnection conn = ConnectionManager.CreateConnection())
    {
      using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(sqlQueriesPath, sqlQueryTag))
      {
        if (paramsList != null)
        {
          foreach (var pair in paramsList)
          {
            stmt.AddParam(pair.ParamName, pair.Value);
          }
        }

        if (isSortable)
        {
          SetSorting(items);

          using (IMTPreparedFilterSortStatement filterSortStmt =
            conn.CreatePreparedFilterSortStatement(stmt.Query))
          {
           MTListFilterSort.ApplyFilterSortCriteria(filterSortStmt, items);
            using (IMTDataReader reader = filterSortStmt.ExecuteReader())
            {
              ConstructItems(reader, ref items);
            }
            items.TotalRows = filterSortStmt.TotalRows;
          }
        }
        else
        {
          using (IMTDataReader reader = stmt.ExecuteReader())
          {

            ConstructItems(reader, ref items);
          }
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
            item = string.Format("\"n_amountAsString\":{0},", FormatCurrencyValueForGraph(record.Fields[billingSummary_Amount_Index], record.Fields[billingSummary_Currency_Index].FieldValue.ToString())); 
            json.Append(item);
            item = string.Format("\"n_invoice_amount\":{0},", FormatFieldValue(record.Fields[billingSummary_InvoiceAmount_Index], invariantCulture));
            json.Append(item);
            item = string.Format("\"n_invoiceamountAsString\":{0},", FormatCurrencyValueForGraph(record.Fields[billingSummary_InvoiceAmount_Index], record.Fields[billingSummary_Currency_Index].FieldValue.ToString()));
            json.Append(item);
            if (ShowFinancialData)
            {
              item = string.Format("\"n_mrr_amount\":{0},",
                                   FormatFieldValue(record.Fields[billingSummary_MrrAmount_Index], invariantCulture));
              json.Append(item);
              item = string.Format("\"n_mrramountAsString\":{0},",
                                   FormatCurrencyValueForGraph(record.Fields[billingSummary_MrrAmount_Index],
                                                               record.Fields[billingSummary_Currency_Index].FieldValue
                                                                                                           .ToString()));
              json.Append(item);
            }
            item = string.Format("\"item_desc\":{0}", FormatFieldValue(record.Fields[billingSummary_ItemDesc_Index]));
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
    return string.Format("\"{0}\"", (field.FieldValue == null) ? "" : CurrencyFormatter.Format(field.FieldValue, currency).EncodeForJavaScript());
  }

  private string FormatCurrencyValueForGraph(SQLField field, string currency)
  {
    return string.Format("\"{0}\"", (field.FieldValue == null) ? "" : CurrencyFormatter.Format(field.FieldValue, currency));
  }

  private string FormatDateTime(SQLField field, string format)
  {
    return (field.FieldValue == null) ? "null" : string.Format("\"{0}\"", Convert.ToDateTime(field.FieldValue).ToString(format).EncodeForHtml());
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

