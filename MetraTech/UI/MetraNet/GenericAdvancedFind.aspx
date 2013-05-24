<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="GenericAdvancedFind" Title="Untitled Page" CodeFile="GenericAdvancedFind.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    
  
  <div class="CaptionBar">
    <asp:Label ID="Label1" runat="server" Text="Advanced Find"></asp:Label>
  </div>
  <MT:MTPanel ID="MyPanel1" runat="Server">
    <MT:MTTextBoxControl ID="txt1" runat="server" Label="Text1" />
  </MT:MTPanel>
  
        <MT:MTFilterGrid ID="MyGrid1" 
          XMLPath="c:\tempconfig\GenericAccountSearch.xml" 
          runat="Server">
          
       
        </MT:MTFilterGrid>

<script language="javascript" type="text/javascript">
  onOK_<%=MyGrid1.ClientID %> = function()
  {
    alert('hello world');
  }; 





  OverrideRenderer_<%= MyGrid1.ClientID %> = function(cm)
  {
    cm.setRenderer(cm.getIndexById('UserName'), UsernameRenderer);
       
  }
  function UsernameRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = String.format("<a href='/MetraNet/ManageAccount.aspx?id={0}'>{1} ({0})</a>",
                                 
                                  record.data._AccountID,
                                  record.data.UserName);
    return str;
  }
  
  
  </script>
</asp:Content>


