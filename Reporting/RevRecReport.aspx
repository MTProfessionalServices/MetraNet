<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="RevRecReport.aspx.cs" Inherits="RevRecReport" Title="MetraNet - Update Account"
  meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT"
  TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <%--<link rel="stylesheet" type="text/css" href="/Res/Styles/jquery.dataTables.min.css" />
  <script type="text/javascript" src="/Res/JavaScript/jquery.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/jquery.dataTables.min.js"></script>--%>
  <%--<div id="container">
    <div id="demo">
      <h2>
        Index</h2>
      <table id="myDataTable" class="display">
        <thead>
          <tr>
            <th>Currency</th>
            <th>Revenue Code</th>
            <th>Deferred Revenue Code</th>
            <th>Revenue Part</th>
            <th><%=month1 %></th>
            <th><%=month2 %></th>
            <th><%=month3 %></th>
            <th><%=month4 %></th>
            <th><%=month5 %></th>
            <th><%=month6 %></th>
            <th><%=month7 %></th>
            <th><%=month8 %></th>
            <th><%=month9 %></th>
            <th><%=month10 %></th>
            <th><%=month11 %></th>
            <th><%=month12 %></th>
            <th><%=month13 %></th>
          </tr>
        </thead>
        <tbody>
        </tbody>
      </table>
    </div>
  </div>--%>
  
  <MT:MTTitle ID="MTTitle1" Text="Revenue Recognition Report" runat="server" meta:resourcekey="MTTitle1Resource1" />
  <br />
  <div style="position: relative; margin-top: 50px;">
    <MT:MTFilterGrid ID="grdRevRecReport" runat="server" ExtensionName="Reporting" TemplateFileName="RevRecReportGrid"
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

  <%--<script language="javascript" type="text/javascript">
    $(document).ready(function () {
      $('#myDataTable').dataTable({
        "bServerSide": true,
        "sAjaxSource": "../Report/RevRec",
        "bProcessing": true,
        "aoColumns": [
      { "sName": "CURRENCY" },
      { "sName": "REVENUECODE" },
      { "sName": "DEFERREDREVENUECODE" },
      { "sName": "REVENUEPART" },
      { "sName": "AMOUNT1" },
      { "sName": "AMOUNT2" },
      { "sName": "AMOUNT3" },
      { "sName": "AMOUNT4" },
      { "sName": "AMOUNT5" },
      { "sName": "AMOUNT6" },
      { "sName": "AMOUNT7" },
      { "sName": "AMOUNT8" },
      { "sName": "AMOUNT9" },
      { "sName": "AMOUNT10" },
      { "sName": "AMOUNT11" },
      { "sName": "AMOUNT12" },
      { "sName": "AMOUNT13" }
      ]
      });
    }); 
  </script>--%>
</asp:Content>
