using System;
using System.Collections.Generic;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.UI.Controls;
using MetraTech.OnlineBill;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using System.Web.UI.WebControls;

public partial class OperationsDashboard : MTPage
{

  public int failedUdrCleanupThreshold = 30;
  public int udrBatchFrequencyThreshold = 60;
  protected string primaryCurrency = "USD";
  protected int softCloseThreshold = 40;
  public string puppetMasterUrl = "https://puppet-corp1";
  private  string queryPath = @"..\Extensions\SystemConfig\config\SqlCustom\Queries\UI\Dashboard";
  private const int MAX_DD_COUNT = 50;

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      // TODO:  Get data to bind to and place in viewstate
     
      // TODO:  Set binding properties and template on MTGenericForm control
      // MTGenericForm1.RenderObjectType = Data.GetType();
      // MTGenericForm1.RenderObjectInstanceName = "Data";
      // MTGenericForm1.TemplatePath = TemplatePath;
      // MTGenericForm1.ReadOnly = false;
        lblOverXDays.Text = "Over " + failedUdrCleanupThreshold.ToString() + " Days";
        lblLastBatch.Text = "Last Batch";
        
       
    }
  }

  protected override void OnLoadComplete(EventArgs e)
  {

      try
      {
          loadGrids();
          loadDropDowns();

            
      }
      catch (Exception ex)
      {
          Response.Write(ex.StackTrace);
      }
      base.OnLoadComplete(e);
  }


  private void loadGrids()
  {
     Dictionary<string, object> paramDict = new Dictionary<string, object>();
     string querydir = "..\\Extensions\\SystemConfig\\config\\SqlCustom\\Queries\\UI\\Dashboard";


     ConfigureAndLoadGrid(grdFailedAdapters, "__GET_FAILED_ADAPTERS__", querydir, null);
     ConfigureAndLoadGrid(grdRunningAdapters, "__GET_RUNNING_ADAPTERS__", querydir, null);
     ConfigureAndLoadGrid(grdPendingBillClose, "__GET_PENDINGBILLCLOSE_INFORMATION__", querydir, null);
      
  }


  private void loadDropDowns()
  {
      Dictionary<string, object> paramDict = new Dictionary<string, object>();

      ConfigureAndLoadDropDowns(ddBillCloses, "dt_end", "id_usage_interval", "__GET_BILLCLOSESYNOPSIS_AVAILABLEINTERVALS__", queryPath, paramDict);
      ConfigureAndLoadDropDowns(ddActiveBillRun, "dt_end", "id_usage_interval", "__GET_ACTIVEBILLRUN_AVAILABLEINTERVALS__", queryPath, paramDict);
   
  }
  

  private void ConfigureAndLoadGrid(MTFilterGrid grid, string queryName, string queryPath, Dictionary<string, object> paramDict)
  {
      try
      {
          SQLQueryInfo sqi = new SQLQueryInfo();
          sqi.QueryName = queryName;
          sqi.QueryDir = queryPath;

          if (paramDict != null)
          {
              foreach (var pair in paramDict)
              {
                  SQLQueryParam param = new SQLQueryParam();
                  param = new SQLQueryParam();
                  param.FieldName = pair.Key;
                  param.FieldValue = pair.Value;
                  sqi.Params.Add(param);
              }
          }

          string qsParam = MetraTech.UI.Common.SQLQueryInfo.Compact(sqi);
          grid.DataSourceURLParams.Add("q", qsParam);

      }
      catch
      {
          throw;
      }
  }


  private void ConfigureAndLoadDropDowns(MTDropDown dropDown, string colDisplay, string colValue, string queryName, string queryPath, Dictionary<string, object> paramDict)
  {


      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {

          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(queryPath, queryName))
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
                  ListItem[] items = new ListItem[MAX_DD_COUNT];
                  int count = 0;
                  int displayOrdinal = 0;
                  int valueOrdinal = 0;

                  // process the results
                  while (reader.Read())
                  {

                      items[count] = new ListItem();


                      if (count == 0)
                      {
                          for (int i = 0; i < reader.FieldCount; i++)
                          {
                              if (reader.GetName(i).Equals(colDisplay))
                                  displayOrdinal = i;
                              if (reader.GetName(i).Equals(colValue))
                                  valueOrdinal = i;
                          }

                          items[count].Selected = true;
                      }

                      items[count].Text = reader.GetValue(displayOrdinal).ToString();
                      items[count].Value = reader.GetValue(valueOrdinal).ToString();




                      dropDown.Items.Add(items[count]);
                      count = count + 1;
                  }

              }

          }

          conn.Close();
      }

  }


}
