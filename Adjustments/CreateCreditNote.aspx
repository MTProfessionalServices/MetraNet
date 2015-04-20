<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="CreateCreditNote.aspx.cs" Inherits="Adjustments_CreateCreditNote"
meta:resourcekey="PageResource1" Culture="auto" UICulture="auto"%>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
   <MT:MTPanel ID="MTPanel1" runat="server" Text="Create Credit Note" 
    Collapsible="True" Collapsed="False"  meta:resourcekey="MTPanel1Resource1" Width="820">
     
     &nbsp;&nbsp;&nbsp;
     <MT:MTLabel ID="lblAccount" runat="server" LabelWidth="200"/>
     <br><br/>
     
    <MT:MTDropDown ID="ddTemplateTypes" runat="server" Label="Credit Note Template To Use" 
      LabelWidth="200" AllowBlank="False" HideLabel="False" LabelSeparator=":" Listeners="{}"
      meta:resourcekey="ddTemplateTypesResource1" ReadOnly="False" Enabled="True">
    </MT:MTDropDown>
   
    <MT:MTTextArea ID="CommentTextBox" runat="server" Label="Comment"
      AllowBlank="True" Height="200px" Width="400px" ControlHeight="200" 
      ControlWidth="400" HideLabel="False" LabelSeparator=":" LabelWidth="200" 
      Listeners="{}" MaxLength="255" meta:resourcekey="CommentTextBoxResource1" 
      MinLength="0" ReadOnly="False" Enabled="True" ValidationRegex="null" 
      XType="TextArea" XTypeNameSpace="form"/>
      
    <MT:MTDropDown ID="ddTimeIntervals" runat="server" Label="Adjustments Issued In The Last" 
     LabelWidth="200" AllowBlank="False" HideLabel="False" LabelSeparator=":" Listeners="{'select' : { fn: this.onChange_ddTimeIntervals, scope: this } }" 
     meta:resourcekey="ddTimeIntervalsResource1" ReadOnly="False" Enabled="True" ControlWidth="100">
    </MT:MTDropDown>
     
    <MT:MTFilterGrid ID="MTFilterGrid1" runat="server" ExtensionName="Core" 
     TemplateFileName="CreateCreditNoteDocument.xml">
    </MT:MTFilterGrid>
    <div>
      <MT:MTLabel ID="lblWarning" runat="server" meta:resourcekey="lblWarning" />
    </div>
     <div  class="x-panel-btns-ct">
     <div style="width:630px" class="x-panel-btns x-panel-btns-center"> 
      <center>  
       <table cellspacing="0">
         <tr>
           <td  class="x-panel-btn-td">
             <asp:HiddenField ID="hdSelectedItemsList" runat="server" />
             <MT:MTButton ID="MTButton1"  runat="server" OnClientClick="if(ValidateForm()) {return GetAdjustmentIdsAndType();} else {return false;}"
              OnClick="btnIssueCreditNote_Click" TabIndex="150" meta:resourcekey="btnIssueCreditNoteResource1" />
           </td>
           <td  class="x-panel-btn-td">
             <MT:MTButton ID="MTButton2" runat="server" 
              OnClick="btnCancel_Click" CausesValidation="False" TabIndex="160" meta:resourcekey="btnCancelResource1" />
           </td>
         </tr>
       </table> 
      </center>    
     </div>
   </div>
   </MT:MTPanel>
   
    <script language="javascript" type="text/javascript">
      function getDataSourceUrlParams(paramsBase, timeInterval) {

        var newParams = paramsBase;
        newParams.timeInterval = timeInterval;

        return newParams;
      }

      function onChange_ddTimeIntervals() {
        
        var timeInterval = Ext.getCmp('<%=ddTimeIntervals.ClientID %>').getRawValue();

        //make results pane visible, it could be hidden if not searching on load
        if (!grid_<%= MTFilterGrid1.ClientID %>.isVisible()) {
          grid_<%= MTFilterGrid1.ClientID %>.setVisible(true);
        }
        var paramsDataSource = getDataSourceUrlParams({ start: 0, limit: 10 }, timeInterval);
        dataStore_<%= MTFilterGrid1.ClientID %>.load({ params: paramsDataSource });
      }
      
      Ext.onReady(function() {
        dataStore_<%= MTFilterGrid1.ClientID %>.on("beforeload", function(store) {
          var timeInterval = Ext.getCmp('<%=ddTimeIntervals.ClientID %>').getRawValue();
          store.setBaseParam('timeInterval', timeInterval);
        });

        grid_<%= MTFilterGrid1.ClientID %>.getSelectionModel().on("beforerowselect", function(sm, index, keep, record) {
          if (record.data.CreditNoteIdentifier == "") 
            return true;
          return false;
        });
      });
      
      function checkBoxColRenderer(value, meta, record, rowIndex, colIndex, store) {
        if (record.data.CreditNoteIdentifier == "") {
          return "<div class='x-grid3-cell-inner x-grid3-col-checker x-unselectable' unselectable='on'><div class='x-grid3-row-checker'>&nbsp;</div></div>";
        } else
          return '';
      }

      OverrideRenderer_<%= MTFilterGrid1.ClientID %> = function(cm) {
        cm.setRenderer(0, checkBoxColRenderer);
        if (cm.getIndexById('CreditNoteComment') != -1) {
          cm.setRenderer(cm.getIndexById('CreditNoteComment'), creditNoteCommentColRenderer);
        }
      };

      function creditNoteCommentColRenderer(value, meta, record, rowIndex, colIndex, store) {
        meta.attr = 'style="white-space:normal"';
        var str = String.format("<span id='CreditNoteComment' >{0}</span>", value);
        return str;
      }

      function GetAdjustmentIdsAndType()
      {
        var adjRecords = grid_<%= MTFilterGrid1.ClientID %>.getSelectionModel().getSelections();
        var adjustmentIdsAndType = "";
        for(var i=0; i < adjRecords.length; i++)
        {
          if(i > 0)
          {
            adjustmentIdsAndType += ",";
          }
          adjustmentIdsAndType += (adjRecords[i].data.AdjustmentID + ";" + adjRecords[i].data.AdjustmentType);
          document.getElementById('<%=hdSelectedItemsList.ClientID %>').value = adjustmentIdsAndType;
        }
        return (document.getElementById('<%=hdSelectedItemsList.ClientID %>').value == '') ? false : true;
      }
    </script>
</asp:Content>