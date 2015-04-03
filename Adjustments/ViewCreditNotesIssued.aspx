<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="ViewCreditNotesIssued.aspx.cs" Inherits="Adjustments_ViewCreditNotesIssued"
  meta:resourcekey="PageResource1" Culture="auto" UICulture="auto"%>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>


<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
   <div class="CaptionBar">
    <asp:Label ID="lblViewCreditNotesTitle" runat="server" meta:resourcekey="lblViewCreditNotesTitle"></asp:Label>
  </div>
  <MT:MTFilterGrid ID="CreditNotesGrid" runat="server" ExtensionName="Core" 
    TemplateFileName="CreditNotesIssued.xml">
  </MT:MTFilterGrid>
  <div id="results-win" class="x-hidden"> 
      <div class="x-window-header"></div> 
    <div id="result-content"></div> 
  </div> 
  <script type="text/javascript" language="javascript">
    var win;
    var selectedRowIndex;
    var isRegeneratePdfRequestSent;
    
    OverrideRenderer_<%= CreditNotesGrid.ClientID %> = function(cm) {
      if (cm.getIndexById('CreditNotePDFStatusInformation')  != -1) {
        cm.setRenderer(cm.getIndexById('CreditNotePDFStatusInformation'), statusInformationColRenderer);
      }
      if (cm.getIndexById('CreditNotePDFStatusLocalized')  != -1) {
        cm.setRenderer(cm.getIndexById('CreditNotePDFStatusLocalized'), statusColRenderer);
      }
    }

    function statusInformationColRenderer(value, meta, record, rowIndex, colIndex, store) {
      meta.attr = 'style="white-space:normal"';
      var str = String.format("<span id='StatusInformation' >{0}</span>", value);
      return str;
    }

    function statusColRenderer(value, meta, record, rowIndex, colIndex, store)
    {
      var str, columnText = "";
      var selectedRecord = grid_<%=CreditNotesGrid.ClientID %>.getStore().getAt(rowIndex);
      var status = selectedRecord.data.CreditNotePDFStatus.toLowerCase();
      
      if ( status == "failed" || status == "notgenerated")
      {
        columnText = (status == "failed") ? "<%= Convert.ToString(GetLocalResourceObject("TEXT_RETRY_COLUMN")) %>" : "<%= Convert.ToString(GetLocalResourceObject("TEXT_GENERATE_COLUMN")) %>";
        str = String.format("<span id='Status' >{0}</span>&nbsp;&nbsp;<a title='{1}' style='cursor:pointer; text-decoration:underline !important' id='Retry' href='JavaScript:onRetryClick(\"{2}\");' >{1}</a>", value, columnText, rowIndex);
      }
      else
      {
        str = String.format("{0}&nbsp;", value); 
      }   
      return str;
    }
    
    function onRetryClick(rowIndex) {
      var selectedRecord = this.grid_<%=CreditNotesGrid.ClientID %>.getStore().getAt(rowIndex);
      selectedRowIndex = rowIndex; //store the rowIndex to update the status if callback is successful 
      Ext.Ajax.request({
        url: 'AjaxServices/CreateCreditNotePDF.aspx',
        params: {
          CreditNoteID:  selectedRecord.data.CreditNoteID,
          AccountID: selectedRecord.data.AccountID,
          CreditNotePrefix: selectedRecord.data.CreditNotePrefix,
          CreditNoteString: selectedRecord.data.CreditNoteString,
          TemplateName: selectedRecord.data.TemplateName,
          LanguageCode: selectedRecord.data.TemplateLanguageCode,
        },
        timeout: 10000,
        callback: function (options, success, response) {
          var responseJSON = Ext.decode(response.responseText);
          if(responseJSON) {
             isRegeneratePdfRequestSent = responseJSON.Success; //store whether callback was successful to update the status on ok button click
             var tpl = new Ext.XTemplate(
              '<tpl for=".">',
              '<tpl if="Success == false">',
              '<img src="/Res/images/icons/error.png" />  ' + TEXT_ERROR,
              '</tpl>',
              '<tpl if="Success == true">',
              '<img src="/Res/images/icons/accept.png" />  ' + TEXT_SUCCESS,
              '</tpl>',
              '<p>{Message}</p>',
              '</tpl>'
            );
            if(!win) {
              win = new Ext.Window({
                  applyTo:'results-win',
                  layout:'fit',
                  width:550,
                  height:150,
                  closeAction:'hide',
                  plain: true,
                  buttons: [{
                    text: TEXT_CLOSE,
                    handler: function() {
                      if (isRegeneratePdfRequestSent) {
                        updateRetryTextOnSelectedRow(selectedRowIndex);
                      }
                      win.hide();
                    }
                  }]
              });
            }
            tpl.overwrite(win.body, responseJSON);
            win.show(this);  
          }
          else
          {
            Ext.UI.msg(TEXT_ERROR, responseJSON.Message);
          }
        }    
      });
    }
    
    function updateRetryTextOnSelectedRow(rowIndex) {
      var selectedRow = grid_<%=CreditNotesGrid.ClientID %>.getView().getRow(rowIndex);
      var selectedRecord = this.grid_<%=CreditNotesGrid.ClientID %>.getStore().getAt(rowIndex);
      var currentStatus = selectedRecord.data.CreditNotePDFStatus.toLowerCase(); 
      
      selectedRow.getElementsByTagName("a").Retry.style.display = "none";
      selectedRow.getElementsByTagName("span").Status.textContent = (currentStatus.toLowerCase() == "notgenerated") ? "<%= Convert.ToString(GetLocalResourceObject("TEXT_REQUEST_SUBMITTED")) %>" : "<%= Convert.ToString(GetLocalResourceObject("TEXT_REQUEST_RESUBMITTED")) %>";
    }
   
  </script>

</asp:Content>

