using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MetraTech.UI.Controls
{

  [DefaultProperty("Text")]
  [ToolboxData("<{0}:MTChart runat=server></{0}:MTChart>")]
  public class MTChart : WebControl
  {
    #region Chart Types
    public enum ChartXTypes
    {
      Piechart,           // Ext.chart.PieChart
      Chart,              // Ext.chart.Chart
      Barchart,           // Ext.chart.BarChart
      Cartesianchart,     // Ext.chart.CartesianChart
      Columnchart,        // Ext.chart.ColumnChart
      Linechart           // Ext.chart.LineChart
    };
    #endregion

    #region JavaScript
    private string JavaScript = @"
          <div id=""chartContainer_%%CONTROL_ID%%""></div>

          <script>
          Ext.chart.Chart.CHART_URL = '/Res/Ext/resources/charts.swf';
          Ext.FlashComponent.EXPRESS_INSTALL_URL = '/Res/Ext/resources/expressinstall.swf';

          Ext.onReady(function() {

            var store_%%CONTROL_ID%% = new Ext.data.JsonStore({
              url: '%%URL%%',
              baseParams: { 'urlparam_q': '%%PARAMS%%', start: 0, limit: 10 },
              autoLoad: true,
              root: 'Items',
              fields: [%%FIELDS%%]
            });

            var chart_%%CONTROL_ID%% = new Ext.Panel({
              width: %%WIDTH%%,
              height: %%HEIGHT%%,
              title: '%%TEXT%%',
              border: false,
              renderTo: 'chartContainer_%%CONTROL_ID%%',
              items: {
                store: store_%%CONTROL_ID%%,
                xtype: '%%CHART_TYPE%%',
                expressInstall: true,
                %%CHART_SPECIFIC_CONFIG%%
                %%OPTIONAL_EXT_CONFIG%%
                extraStyle: {
                         %%LEGEND%%
                         xAxis: {
                              labelRotation: -75
                         }
                         %%EXTRA_STYLE%%
                }
              }
            });
            
          });
          </script>";
    #endregion

    #region Properties
    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public new string Width
    {
      get
      {
        String s = (String)ViewState["Width"];
        return ((s == null) ? "400" : s);
      }

      set
      {
        ViewState["Width"] = value;
      }
    }
    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public new string Height
    {
      get
      {
        String s = (String)ViewState["Height"];
        return ((s == null) ? "400" : s);
      }

      set
      {
        ViewState["Height"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string LegendLocation
    {
      get
      {
        String s = (String)ViewState["LegendLocation"];
        return ((s == null) ? "right" : s);
      }

      set
      {
        ViewState["LegendLocation"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string Text
    {
      get
      {
        String s = (String)ViewState["Text"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["Text"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string Params
    {
      get
      {
        String s = (String)ViewState["Params"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["Params"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string ExtraStyle
    {
      get
      {
        String s = (String)ViewState["ExtraStyle"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["ExtraStyle"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string Url
    {
      get
      {
        String s = (String)ViewState["Url"];
        return ((s == null) ? "../AjaxServices/QueryService.aspx" : s);
      }

      set
      {
        ViewState["Url"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public ChartXTypes ChartType
    {
      get
      {
        ChartXTypes c = (ChartXTypes)ViewState["ChartType"];
        return c;
      }

      set
      {
        ViewState["ChartType"] = value;
      }
    }


    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string DataField
    {
      get
      {
        String s = (String)ViewState["DataField"];
        return ((s == null) ? "total" : s);
      }

      set
      {
        ViewState["DataField"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string CategoryField
    {
      get
      {
        String s = (String)ViewState["CategoryField"];
        return ((s == null) ? "category" : s);
      }

      set
      {
        ViewState["CategoryField"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string XField
    {
      get
      {
        String s = (String)ViewState["XField"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["XField"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string YField
    {
      get
      {
        String s = (String)ViewState["YField"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["YField"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Description("Comma separated fields: 'category', 'total'")]
    [Localizable(true)]
    public string Fields
    {
      get
      {
        String s = (String)ViewState["Fields"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["Fields"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string XLabel
    {
      get
      {
        String s = (String)ViewState["XLabel"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["XLabel"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string YLabel
    {
      get
      {
        String s = (String)ViewState["YLabel"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["YLabel"] = value;
      }
    }

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string OptionalExtConfig
    {
      get
      {
        String s = (String)ViewState["OptionalExtConfig"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["OptionalExtConfig"] = value;
      }
    }
    

    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string YFormat
    {
      get
      {
        String s = (String)ViewState["YFormat"];
        return ((s == null) ? "Ext.util.Format.number" : s);
      }

      set
      {
        ViewState["YFormat"] = value;
      }
    }
    #endregion

    #region Events
    protected override void RenderContents(HtmlTextWriter output)
    {
      string chartConfig;
      string legend;
      if(ChartType == ChartXTypes.Piechart)
      {
        chartConfig =  @"dataField: '%%DATA_FIELD%%',
                         categoryField: '%%CATEGORY_FIELD%%',";
        legend =
          @"legend: {
                            display: '%%LEGEND_LOCATION%%',
                            padding: 5,
                            font:
                              {
                                family: 'Tahoma',
                                size: 10
                              }
                         },";
      }
      else
      {
        chartConfig = @"xField: '%%XFIELD%%',
                        yField: '%%YFIELD%%',
                        xAxis: new Ext.chart.CategoryAxis({
                          title: '%%XLABEL%%'
                        }),
                        yAxis: new Ext.chart.NumericAxis({
                          title: '%%YLABEL%%',
                          labelRenderer : %%YFormat%%
                        }),";
        legend = "";
      }
      
      JavaScript = JavaScript.Replace("%%CHART_SPECIFIC_CONFIG%%", chartConfig);
      JavaScript = JavaScript.Replace("%%LEGEND%%", legend);

      JavaScript = JavaScript.Replace("%%YFormat%%", YFormat.Replace("'", "\'"));
      JavaScript = JavaScript.Replace("%%CONTROL_ID%%", this.ClientID);
      JavaScript = JavaScript.Replace("%%TEXT%%", Text.Replace("'", "\'"));
      JavaScript = JavaScript.Replace("%%PARAMS%%", Params.Replace("'", "\'"));
      JavaScript = JavaScript.Replace("%%URL%%", Url.Replace("'", "\'"));
      JavaScript = JavaScript.Replace("%%CHART_TYPE%%", ChartType.ToString().ToLower());
      JavaScript = JavaScript.Replace("%%DATA_FIELD%%", DataField.Replace("'", "\'"));
      JavaScript = JavaScript.Replace("%%CATEGORY_FIELD%%", CategoryField.Replace("'", "\'"));
      JavaScript = JavaScript.Replace("%%XFIELD%%", XField.Replace("'", "\'"));
      JavaScript = JavaScript.Replace("%%YFIELD%%", YField.Replace("'", "\'"));
      JavaScript = JavaScript.Replace("%%FIELDS%%", Fields.Replace("'", "\'"));
      JavaScript = JavaScript.Replace("%%WIDTH%%", Width.Replace("'", "\'"));
      JavaScript = JavaScript.Replace("%%HEIGHT%%", Height.Replace("'", "\'"));
      JavaScript = JavaScript.Replace("%%XLABEL%%", XLabel.Replace("'", "\'"));
      JavaScript = JavaScript.Replace("%%YLABEL%%", YLabel.Replace("'", "\'"));
      JavaScript = JavaScript.Replace("%%LEGEND_LOCATION%%", LegendLocation.Replace("'", "\'"));
      JavaScript = JavaScript.Replace("%%OPTIONAL_EXT_CONFIG%%", OptionalExtConfig);
      JavaScript = JavaScript.Replace("%%EXTRA_STYLE%%", ExtraStyle);
      output.Write(JavaScript);
    }
    #endregion

  }
}
