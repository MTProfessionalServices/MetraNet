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
    str += String.format("<a style='cursor:pointer;' id='View'  href='/MetraNet/TicketToMOM.aspx?URL=/MOM/default/dialog/IntervalManagement.asp?ID={0}&ReturnURL={2}'>{1}</a>", value, value, encodeURIComponent("/MetraNet/MetraControl/BillingManagement/IntervalManagementList.aspx?Intervals=<%=statusFilterValue%>"));
    return str;
  }
  
  function statusColRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = "";
    switch(value) {
      case 0:
        str += "<img src='/Res/Images/icons/IntervalStateOpen.gif' align='absmiddle' width='14px' height='14px'/>" + '<%=GetLocalResourceObject("TEXT_OPEN").ToString()%>';
        break;
      case 1:
        str += "<img src='/Res/Images/icons/IntervalStateSoftClosed.gif' align='absmiddle' width='14px' height='14px'/>" + '<%=GetLocalResourceObject("TEXT_SOFT_CLOSED").ToString()%>';
        break;
      case 2:
        str += "<img src='/Res/Images/icons/IntervalStateHardClosed.gif' align='absmiddle' width='14px' height='14px'/>" + '<%=GetLocalResourceObject("TEXT_HARD_CLOSED").ToString()%>';
        break;
      default:
        str += "<img src='/Res/Images/icons/Interval.gif' align='absmiddle' width='14px' height='14px'/>" + '<%=GetLocalResourceObject("TEXT_UNKNOWN").ToString()%>';
        break;
    }
    return str;
  }
  
  </script>
</asp:Content>