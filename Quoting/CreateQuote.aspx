<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="CreateQuote.aspx.cs" Inherits="MetraNet.Quoting.CreateQuote" Title="MetraNet - Create quote"
  Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <asp:PlaceHolder ID="PlaceHolderPOJavaScript" runat="server"></asp:PlaceHolder> 
  <MT:MTTitle ID="CreateQuoteTitle" Text="Create Quote" runat="server" />
  <br />
  <%--<MTCDT:MTGenericForm ID="CreateQuoteForm" runat="server" TemplateName="CreateQuote" DataBinderInstanceName="MTDataBinder1" meta:resourcekey="BMEInstanceForm">
  </MTCDT:MTGenericForm>--%>
  <br />
  
  <MT:MTPanel ID="MTPanelQuoteParameters" runat="server" Text="Quote parameters" Collapsible="True"
    Collapsed="False" meta:resourcekey="MTPanelQuoteParametersResource">
    <div id="leftColumn2" class="LeftColumn">
    <MT:MTTextBoxControl ID="MTtbQuoteDescription" AllowBlank="True" Label = "Quote Description" LabelWidth="120" runat="server"/>
    <MT:MTTextBoxControl ID="MTtbQuoteIdentifier" AllowBlank="True" Label = "Quote Identifier" LabelWidth="120" runat="server"/>
    <MT:MTCheckBoxControl ID="MTcbPdf" BoxLabel = "Generate PDF" runat="server" LabelWidth="120" meta:resourcekey="MTCheckBoxPdfResource" />
    </div>
    <div id="rightColumn2"  class="RightColumn">
    <MT:MTDatePicker AllowBlank="False" Enabled="True" HideLabel="False" ID="MTdpStartDate"
      Label="Start date" LabelWidth="120" meta:resourcekey="dpStartDateResource1" ReadOnly="False"
      runat="server"></MT:MTDatePicker>
    <MT:MTDatePicker AllowBlank="False" Enabled="True" HideLabel="False" ID="MTdpEndDate"
      Label="End date" LabelWidth="120" meta:resourcekey="dpEndDateResource1" ReadOnly="False"
      runat="server"></MT:MTDatePicker>
    </div>
  </MT:MTPanel>
  <br />
  <MT:MTPanel ID="MTPanelQuoteAccounts" runat="server" Text="Accounts and product offerings for quote" Collapsible="True"
    Collapsed="False" meta:resourcekey="MTPanelQuoteAccountsResource">
    <div id="PlaceHolderAccountsGrid" class="LeftColumn"></div>
    <div id="PlaceHolderProductOfferingsGrid" class="RightColumn"></div>   
  </MT:MTPanel>
  <MT:MTPanel ID="MTPanelUDRCMetrics" runat="server" Text="UDRC metrics for quote" Collapsible="True"
    Collapsed="True" meta:resourcekey="MTPanelUDRCResource">
     <asp:PlaceHolder ID="PlaceHolderUDRCMetricsGrid" runat="server"></asp:PlaceHolder> 
     <br />GRID WITH UDRC METRICS (GENERATED DYNAMICALLY ACCORDING TO SET OF POS ABOVE, uses code based on Subscriptions\SetUDRCValues.aspx page<br /> <br />
  </MT:MTPanel>
  <MT:MTPanel ID="MTPanelICBs" runat="server" Text="ICBs for quote" Collapsible="True"
    Collapsed="True" meta:resourcekey="MTPanelICBResource">
    <br />GRID WITH ICB METRICS. (most likely we should create a new screen for rates edit instead of existed ASP page for Rates similar to Subscriptions\SetUDRCValues.aspx< page<br /> <br />
  </MT:MTPanel>
  <div class="x-panel-btns-ct">
    <div style="width: 630px" class="x-panel-btns x-panel-btns-center">
      <div style="text-align: center;">
        <table>
          <tr>
            <td class="x-panel-btn-td">
              <MT:MTCheckBoxControl ID="MTCheckBoxViewResult" Visible="False" BoxLabel = "View result" runat="server" LabelWidth="100" meta:resourcekey="MTCheckBoxPdfResource" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTbtnGenerateQuote" runat="server" OnClientClick="return getDataGrids();" OnClick="btnGenerateQuote_Click"
                TabIndex="150" meta:resourcekey="btnGenerateQuoteResource1" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTbtnCancel" runat="server" OnClick="btnCancel_Click" CausesValidation="False"
                TabIndex="160" meta:resourcekey="btnCancelResource1" />
            </td>
            
          </tr>
        </table>
      </div>
    </div>
  </div>  
  
  <input id="HiddenAccountIds" runat="server" type="hidden" />
  <input id="HiddenGroupId" runat="server" type="hidden" />
  <input id="HiddenPoIdTextBox" runat="server" type="hidden" />

  <script language="javascript" type="text/javascript">
    
    function getDataGrids() {
      return getAccountIds() && getPoIds();
    }

    function getAccountIds() {
      var records = accountStore.data.items;
      if (records.length == 0) {
        window.Ext.Msg.show({
          title: window.TEXT_ERROR,
          msg: window.TEXT_SELECT_GRPSUBMEM_ACCOUNTS,
          buttons: window.Ext.Msg.OK,
          icon: window.Ext.MessageBox.ERROR
        });
        return false;
      } 
      
      var ids = "";
      var gid = "";
      for (var i = 0; i < records.length; i++) {
        if (i > 0) {
          ids += ",";
        }
        ids += records[i].data._AccountID;
        if (records[i].data.IsGroup == "1")
          gid = records[i].data._AccountID;
      }

      window.Ext.get("<%=HiddenAccountIds.ClientID %>").dom.value = ids;
      window.Ext.get("<%=HiddenGroupId.ClientID %>").dom.value = gid;
      return true;
    }

    function getPoIds() {
      var records = poStore.data.items;
      if (records.length == 0) {
        window.Ext.Msg.show({
          title: window.TEXT_ERROR,
          msg: window.TEXT_SELECT_GRPSUBMEM_ACCOUNTS,
          buttons: window.Ext.Msg.OK,
          icon: window.Ext.MessageBox.ERROR
        });
        return false;
      }

      var ids = "";
      for (var i = 0; i < records.length; i++) {
        if (i > 0) {
          ids += ",";
        }
        ids += records[i].data.ProductOfferingId;
      }

      window.Ext.get("<%=HiddenPoIdTextBox.ClientID %>").dom.value = ids;
      return true;
    }
    
    function ShowMultiPoSelector(functionName, target) {
      if (window.poSelectorWin2 == null || window.poSelectorWin2 === undefined ||
        target != window.lastTarget2 || functionName != window.lastFunctionName2) {
          window.poSelectorWin2 = new top.Ext.Window({
              title: 'Select product offerings for quote',
              width: 800,
              height: 500,
              minWidth: 300,
              minHeight: 200,
              layout: 'fit',
              plain: true,
              bodyStyle: 'padding:5px;',
              buttonAlign: 'center',
              collapsible: true,
              resizeable: true,
              maximizable: false,
              closable: true,
              closeAction: 'close',
              html: '<iframe id="poSelectorWindow2" src="/MetraNet/Quoting/SelectPOForQuote.aspx?t=' + target + '&f=' + functionName + '" width="100%" height="100%" frameborder="0" scrolling="no"/>'
          });
      }
      if (window.poSelectorWin != null) {
          window.poSelectorWin.hide();
      }
      window.lastTarget2 = target;
      window.lastFunctionName2 = functionName;
      window.poSelectorWin2.show();

      window.poSelectorWin2.on('close', function() {
        window.poSelectorWin2 = null;
      });
    }
    
  </script>
</asp:Content>