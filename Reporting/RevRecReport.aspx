<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="RevRecReport.aspx.cs" Inherits="RevRecReport" Title="MetraNet - Update Account"
  meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT"
  TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <link rel="stylesheet" type="text/css" href="/Res/Styles/jquery.dataTables.min.css" />
  <script type="text/javascript" src="/Res/JavaScript/jquery.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/jquery.dataTables.min.js"></script>
  <div id="container">
    <div id="demo">
      <h2>
        Index</h2>
      <table id="myDataTable" class="display">
        <thead>
          <tr>
            <th>Currency</th>
            <th>Revenue Part</th>
            <th>Month 1</th>
            <th>Month 2</th>
            <th>Month 3</th>
            <th>Month 4</th>
            <th>Month 5</th>
            <th>Month 6</th>
            <th>Month 7</th>
            <th>Month 8</th>
            <th>Month 9</th>
            <th>Month 10</th>
            <th>Month 11</th>
            <th>Month 12</th>
          </tr>
        </thead>
        <tbody>
        </tbody>
      </table>
    </div>
  </div>
  <script language="javascript" type="text/javascript">
    $(document).ready(function () {
      $('#myDataTable').dataTable({
        "bServerSide": true,
        "sAjaxSource": "../Report/RevRec",
        "bProcessing": true,
        "aoColumns": [
      { "sName": "CURRENCY" },
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
      { "sName": "AMOUNT12" }
      ]
      });
    }); 
  </script>
</asp:Content>
