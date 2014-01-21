using System;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;

public partial class Charts_TopUsage : MTPage
{

  protected void Page_Load(object sender, EventArgs e)
  {
    // Setup Pie Chart
    Chart3.ChartType = MTChart.ChartXTypes.Piechart;
    Chart3.Fields = "'category', 'total'";
    Chart3.DataField = "total";
    Chart3.CategoryField = "category";

    // Setup Query and Parameters
    SQLQueryInfo sqi = new SQLQueryInfo();
    sqi.QueryName = "__CHART_TOP_HIERARCHIES__";
    sqi.QueryDir = "Queries\\Charts";

    SQLQueryParam param = new SQLQueryParam();
    param.FieldName = "%%NUMBER_OF_ACCOUNTS%%";
    param.FieldValue = "10";
    sqi.Params.Add(param);
    Chart3.Params = SQLQueryInfo.Compact(sqi);


    // Setup Column Chart
    Chart2.ChartType = MTChart.ChartXTypes.Columnchart;
    Chart2.Fields = "'category', 'total'";
    Chart2.XField = "category";
    Chart2.YField = "total";
    Chart2.XLabel = "Account";
    Chart2.YLabel = "Usage";
    Chart2.YFormat = "Ext.util.Format.usMoney";

    // Setup Query and Parameters
    sqi = new SQLQueryInfo();
    sqi.QueryName = "__CHART_TOP_USAGE__";
    sqi.QueryDir = "Queries\\Charts";

    param = new SQLQueryParam();
    param.FieldName = "%%NUMBER_OF_ACCOUNTS%%";
    param.FieldValue = "10";
    sqi.Params.Add(param);
    Chart2.Params = SQLQueryInfo.Compact(sqi);




  }

}
