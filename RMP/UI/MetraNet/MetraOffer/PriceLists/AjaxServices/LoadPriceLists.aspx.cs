using System;
using System.ServiceModel;
using System.Web;

using System.Web.Script.Serialization;

using System.Runtime.Serialization.Json;
using System.IO;
using System.Text.RegularExpressions;

using MetraTech.ActivityServices.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;
using MetraTech.UI.Common;

public partial class AjaxServices_LoadPriceLists : MTListServicePage
{
    private const int MAX_RECORDS_PER_BATCH = 50;

    protected bool ExtractDataInternal(PriceListServiceClient client, ref MTList<PriceList> items, int batchID, int limit)
    {
      try
      {
        items.Items.Clear();

        items.PageSize = limit;
        items.CurrentPage = batchID;

        // This logis is to address the issue with filter statement where as the Curreny is stored as currency code instead of ENUM type in t_pricelist table. 
        var currencyFilters = new MTList<MTFilterElement>();
        foreach (MTFilterElement filterElement in items.Filters)
        {
          if (filterElement.PropertyName == "Currency")
          {
            currencyFilters.Items.Add(filterElement);
          }
        }

        foreach (MTFilterElement currencyFilterElement in currencyFilters.Items)
        {
          var currency = EnumHelper.GetEnumByValue(typeof(SystemCurrencies), currencyFilterElement.Value.ToString()) == null
                           ? EnumHelper.GetCSharpEnum(Convert.ToInt32(currencyFilterElement.Value))
                           : EnumHelper.GetEnumByValue(typeof(SystemCurrencies), currencyFilterElement.Value.ToString());

          var newCurrencyFilterElement = new MTFilterElement(currencyFilterElement.PropertyName,
                                                             currencyFilterElement.Operation,
                                                             currency.ToString());
          items.Filters.Remove(currencyFilterElement);
          items.Filters.Add(newCurrencyFilterElement);
        }

        client.GetSharedPriceLists(ref items);
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

    protected bool ExtractData(PriceListServiceClient client, ref MTList<PriceList> items)
    {
        if (Page.Request["mode"] == "csv")
        {
            Response.BufferOutput = false;
            Response.ContentType = "application/csv";
            Response.AddHeader("Content-Disposition", "attachment; filename=export.csv");
            Response.BinaryWrite(BOM);
        }

        if (PartitionLibrary.IsPartition)
        {
          var partitionfilterElement = new MTFilterElement("PLPartitionId",
                                                           MTFilterElement.OperationType.Equal,
                                                           PartitionLibrary.PartitionData.PLPartitionId);
          items.Filters.Add(partitionfilterElement);
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

        return true;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        using (new HighResolutionTimer("GetProductOfferings", 5000))
        {
            PriceListServiceClient client = null;

            try
            {
                client = new PriceListServiceClient();
                if (client.ClientCredentials != null)
                {
                    client.ClientCredentials.UserName.UserName = UI.User.UserName;
                    client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
                }
                var items = new MTList<PriceList>();

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
                    HttpContext.Current.ApplicationInstance.CompleteRequest();
                    return;
                }

                if (Page.Request["mode"] != "csv")
                {
                    string json = "";

                    //convert MTList into JSON
                    /* Using old JavaScriptSerializer -- It seems to be the only one the UI side will accept */
                   
                    JavaScriptSerializer jss = new JavaScriptSerializer();
                    json = jss.Serialize(items);

                    json = FixJsonDate(json);
                   
                    /* Using newer DataContractJsonSerializer */
                    /*
                    System.Runtime.Serialization.Json.DataContractJsonSerializer serializer = new DataContractJsonSerializer(typeof(MTList<PriceList>));
                    using (MemoryStream ms = new MemoryStream())
                    {
                        serializer.WriteObject(ms, items);
                        ms.Position = 0;
                        StreamReader sr = new StreamReader(ms);
                        json = sr.ReadToEnd();
                    }

                    json = FixJsonLocalDate(json);
                    */

                    /* Using newer JSON.NET library */
                  //Commenting for now  
                  
                  
                    //Newtonsoft.Json.JsonSerializerSettings jss = new Newtonsoft.Json.JsonSerializerSettings() { DefaultValueHandling = Newtonsoft.Json.DefaultValueHandling.Include, NullValueHandling = Newtonsoft.Json.NullValueHandling.Include };
                    //jss.DefaultValueHandling = Newtonsoft.Json.DefaultValueHandling.Include;

                    //Console.WriteLine("Default Value Handling = {0}", jss.DefaultValueHandling.ToString());

                    // Dates in plain "ToString()" format
                    //jss.Converters.Add(new MetraTech.Custom.Json.Converters.PlainDateTimeConverter());

                    //json = Newtonsoft.Json.JsonConvert.SerializeObject(items, Newtonsoft.Json.Formatting.None, jss);
                    //*/

                    Response.Write(json);
                }

                client.Close();
                client = null;
            }
            catch (Exception ex)
            {
                Logger.LogException("An unknown exception occurred.  Please check system logs.", ex);
                throw;
            }
            finally
            {
                if (client != null)
                {
                    client.Abort();
                }
                Response.End();
            }
        }
    }


    protected string FixJsonLocalDate(string input)
    {
        MatchEvaluator me = new MatchEvaluator(MatchLocalDate);
        string json = Regex.Replace(input, "\\\\/\\Date[(](-?\\d+)(-?[-+])(-?\\d+)[)]\\\\/", me, RegexOptions.None);
        return json;
    }

    public static string MatchLocalDate(Match m)
    {
        long longDate = 0;
        // int offset = 0;

        if (m.Groups.Count >= 4)
        {
            DateTime dt;
            // Parse date (ticks)
            if (long.TryParse(m.Groups[1].Value, out longDate))
            {
                long ticks1970 = new DateTime(1970, 1, 1).Ticks;
                dt = new DateTime(longDate * 10000 + ticks1970).ToLocalTime();

                // Parse offset
                // if (int.TryParse(m.Groups[3].Value, out offset))
                // {
                //    if (m.Groups[3].Value == "+")
                //    {
                        // dt - offset
                //    }
                //    else
                //    {
                        // dt + offset
                //    }
                // }

                return dt.ToString();
            }
        }
        return m.Value;
    }

}