<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" CodeFile="IntervalManagementList.aspx.cs" Inherits="MetraControl_BillingManagement_IntervalManagementList" %>
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
    value == "0" ? str += '<%=GetLocalResourceObject("TEXT_OPEN").ToString()%>' : value == "2" ? str += '<%=GetLocalResourceObject("TEXT_HARD_CLOSED").ToString()%>' : value == "1" ? str += '<%=GetLocalResourceObject("TEXT_SOFT_CLOSED").ToString()%>' : str += '<%=GetLocalResourceObject("TEXT_UNKNOWN").ToString()%>';
    return str;
  }
  </script>
</asp:Content>