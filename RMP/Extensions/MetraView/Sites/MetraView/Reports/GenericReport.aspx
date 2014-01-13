<%@ Page Language="C#" MasterPageFile="~/MasterPages/ReportsPageExt.master" AutoEventWireup="true" Inherits="GenericReport" CodeFile="GenericReport.aspx.cs" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <MT:MTFilterGrid  ID="MyGrid1" runat="Server" ></MT:MTFilterGrid>
    
    <script type="text/javascript" language="javascript">

      function onNew_ctl00_ContentPlaceHolder1_MyGrid1()
      {
      }
      
    </script>
</asp:Content>

