using System;
using System.Collections.Generic;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.UI.Controls;

public partial class OperationsDashboard : MTPage
{

  protected int failedUdrCleanupThreshold = 30;
  protected int udrBatchFrequencyThreshold = 60;
  protected string primaryCurrency = "USD";
  protected int softCloseThreshold = 40;
  protected string puppetMasterUrl;

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
        txtLastBatch.Text = DateTime.UtcNow.ToString();
        
    }
  }

  protected override void OnLoadComplete(EventArgs e)
  {

      try
      {
          loadGrids();

      }
      catch (Exception ex)
      {
          Response.Write(ex.StackTrace);
      }
      base.OnLoadComplete(e);
  }


  private void loadGrids()
  {
      string queryPath = "..\\Extensions\\SystemConfig\\config\\Queries";
      Dictionary<string, object> paramDict = new Dictionary<string, object>();


       ConfigureAndLoadGrid(grdFailedAdapters, "__GET_FAILED_ADAPTERS__", queryPath, paramDict);
      //ConfigureAndLoadGrid(grdRunningAdapters, "__GET_RUNNING_ADAPTERS__", queryPath, paramDict);
        
  }


  private void ConfigureAndLoadGrid(MTFilterGrid grid, string queryName, string queryPath, Dictionary<string, object> paramDict)
  {
      try
      {
          SQLQueryInfo sqi = new SQLQueryInfo();
          sqi.QueryName = queryName;
          sqi.QueryDir = queryPath;

          foreach (var pair in paramDict)
          {
              SQLQueryParam param = new SQLQueryParam();
              param = new SQLQueryParam();
              param.FieldName = pair.Key;
              param.FieldValue = pair.Value;
              sqi.Params.Add(param);
          }

          string qsParam = SQLQueryInfo.Compact(sqi);

          grid.DataSourceURLParams.Add("q", qsParam);
      }
      catch
      {
          throw;
      }
  }

}
