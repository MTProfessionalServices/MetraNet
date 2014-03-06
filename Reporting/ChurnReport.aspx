<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="ChurnReport.aspx.cs" Inherits="ChurnReport" Title="MetraNet - Update Account"
  meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <script type="text/javascript" src="../MetraControl/ControlCenter/js/D3Visualize.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/jquery.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/jquery.gridster.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/crossfilter.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/dc.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/Renderers.js"></script>
  <link rel="stylesheet" type="text/css" href="/Res/Styles/jquery.gridster.css">
  <link rel="stylesheet" type="text/css" href="/Res/Styles/dc.css">
  <style>
  </style>
  <MT:MTTitle ID="MTTitle1" Text="Churn Report" runat="server" meta:resourcekey="MTTitle1Resource1" />
  <br />
  <div class="remaining-graphs span8">
    <div class="row-fluid">
      <div id='dc-volume-chart' class="pie-graph span4 dc-chart" style="float: none !important;">
      </div>
    </div>
  </div>
  <br />
  <div style="position: relative; margin-top: 50px;">
    <MT:MTFilterGrid ID="grdChurnReport" runat="server" ExtensionName="Reporting" TemplateFileName="ChurnReportGrid"
      ButtonAlignment="Center" Buttons="None" DefaultSortDirection="Ascending" DisplayCount="True"
      EnableColumnConfig="True" EnableFilterConfig="false" EnableLoadSearch="False" EnableSaveSearch="False"
      Expandable="False" ExpansionCssClass="" Exportable="False" FilterColumnWidth="350"
      FilterInputWidth="0" FilterLabelWidth="0" FilterPanelCollapsed="False" FilterPanelLayout="MultiColumn"
      meta:resourcekey="MTFilterGrid1Resource1" MultiSelect="False" PageSize="10" Resizable="True"
      RootElement="Items" SearchOnLoad="True" SelectionModel="Standard" ShowBottomBar="True"
      ShowColumnHeaders="True" ShowFilterPanel="false" ShowGridFrame="True" ShowGridHeader="True"
      ShowTopBar="True" TotalProperty="TotalRows">
    </MT:MTFilterGrid>
  </div>
  <script type="text/javascript" language="javascript">
    /********************************************************
    *                                                       *
    *   dj.js example using Yelp Kaggle Test Dataset        *
    *   Eamonn O'Loughlin 9th May 2013                      *
    *                                                       *
    ********************************************************/

    /********************************************************
    *                                                       *
    *   Step0: Load data from json file                     *
    *                                                       *
    ********************************************************/
    d3.json("js/data.js", function (yelp_data) {

      /********************************************************
      *                                                       *
      *   Step1: Create the dc.js chart objects & ling to div *
      *                                                       *
      ********************************************************/
      var volumeChart = dc.barChart("#dc-volume-chart");

      /********************************************************
      *                                                       *
      *   Step2:  Run data through crossfilter                *
      *                                                       *
      ********************************************************/
      var ndx = crossfilter(yelp_data);

      /********************************************************
      *                                                       *
      *   Step3:  Create Dimension that we'll need            *
      *                                                       *
      ********************************************************/

      // for volumechart
      var cityDimension = ndx.dimension(function (d) { return d.city; });
      
      // for pieChart
      var startValue = ndx.dimension(function (d) {
        return d.stars * 1.0;
      });
      var startValueGroup = startValue.group();
      
      /********************************************************
      *                                                       *
      *   Step4: Create the Visualisations                    *
      *                                                       *
      ********************************************************/



      volumeChart.width(800)
        .height(300)
            .dimension(startValue)
            .group(startValueGroup)
            .transitionDuration(1500)
            .centerBar(true)
            .gap(100)
            .x(d3.scale.linear().domain([0.5, 5.5]))
            .elasticY(true)
            .xAxis().tickFormat(function (v) { return v; });

      console.log(startValueGroup.top(1)[0].value);
      
      dc.renderAll();
    });
  </script>
</asp:Content>
