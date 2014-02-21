<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="IntervalManagementList.aspx.cs" Inherits="MetraControl_BillingManagement_IntervalManagementList" %>
<%@ Register TagPrefix="MT" Namespace="MetraTech.UI.Controls" Assembly="MetraTech.UI.Controls" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
 
 <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Billable Intervals" ></asp:Label>   
 </div>


 <div style="padding-left:5px;">
   <MT:MTFilterGrid ID="IntervalListGrid" runat="server" TemplateFileName="IntervalManagementList" ExtensionName="Core">
   </MT:MTFilterGrid>
</div>

<script type="text/javascript">
  OverrideRenderer_<%= IntervalListGrid.ClientID %> = function(cm) {
    cm.setRenderer(cm.getIndexById('ID'), iDColRenderer);
    cm.setRenderer(cm.getIndexById('Status'), statusColRenderer);
  }

  function iDColRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = "";
    str += String.format("<a style='cursor:pointer;' id='View'  href='/MetraNet/TicketToMOM.aspx?URL=/MOM/default/dialog/IntervalManagement.asp?ID={0}'>{1}</a>",value,value)    
    return str;
  }
  
  function statusColRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = "";    
    value == "0" ? str += TEXT_OPEN_INTERVAL_STATUS : value == "1" ? str += TEXT_SOFT_CLOSED_INTERVAL_STATUS : value == "2" ? str += TEXT_HARD_CLOSED_INTERVAL_STATUS : str += TEXT_UNKNOWN_INTERVAL_STATUS;
    return str;
  }
  </script>
</asp:Content>