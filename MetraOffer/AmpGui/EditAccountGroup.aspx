<%@ Page Title="MetraNet" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="EditAccountGroup.aspx.cs" Inherits="AmpEditAccountGroupPage"  meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Edit Account Group" meta:resourcekey="lblTitleResource1"></asp:Label>   
  </div>

  <br />

  <div style="line-height:20px;padding-top:10px;padding-left:15px;">

    <asp:Label ID="lblEditAccountGroup" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
      Font-Size="9pt" meta:resourcekey="lblEditAccountGroupResource1" 
      Text="Here you will define an Account Group that specifies a particular set of accounts to operate on."/>

    <br />

    <div style="padding-top:5px;">
      <span style="color:blue;text-decoration:underline;cursor:pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_MORE_INFO, TEXT_AMPWIZARD_HELP_EDIT_ACCOUNT_GROUP, 420, 130)" id="moreLink" >
        <asp:Literal ID="Literal1" runat="server" Text="<%$ Resources:AmpWizard,TEXT_MORE %>" Visible="False" />
      </span>
    </div>

    <br />

    <MT:MTTextBoxControl ID="tbAcctGroupName" runat="server" ReadOnly="True" AllowBlank="False"
							ControlWidth="200" ControlHeight="18" TabIndex="200" 
							HideLabel="False" LabelWidth="120" LabelSeparator=":" meta:resourcekey="tbAcctGroupNameResource1" Label="Name"
							XType="TextField" XTypeNameSpace="form" Listeners="{}" />
              
    <div id="editDescriptionDiv" runat="server">
    <MT:MTTextArea ID="tbAcctGroupDescription" runat="server" ReadOnly="False" AllowBlank="True"
              ControlWidth="200" ControlHeight="50" TabIndex="210" 
              HideLabel="False" LabelWidth="120" LabelSeparator=":" meta:resourcekey="tbAcctGroupDescriptionResource1" Label="Description"
              XType="TextArea" XTypeNameSpace="form" Listeners="{}" />
    </div>
    <div id="viewDescriptionDiv" runat="server">
       <table class="EditAccountGroupViewDescription" >
        <tr>
          <td class="EditAccountGroupViewDescriptionCol1">
            <MT:MTLabel ID="ViewDescriptionLabel" runat="server" Text="Description:" meta:resourcekey="ViewDescriptionLabelResource"/>
          </td>
          <td class="EditAccountGroupViewDescriptionCol2">
            <MT:MTLabel ID="ViewDescriptionText" runat="server" />
          </td>
        </tr>
      </table>
    </div>
 
    <br />
    <asp:Label ID="lblAcctQualGrid" runat="server" style="line-height:20px;" Font-Bold="False" ForeColor="DarkBlue" 
      Font-Size="9pt" meta:resourcekey="lblAcctQualGridResource1" 
      Text="You need to specify the steps to take to select the accounts that this Decision Type will operate on.&lt;br/&gt;To do so, you must define an ordered set of Account Qualifications." ></asp:Label>
  </div>  

  <div style="padding-left:5px;">
    <MT:MTFilterGrid ID="AccountQualificationsGrid" runat="server" TemplateFileName="AmpWizard.AccountQualifications" ExtensionName="MvmAmp">
    </MT:MTFilterGrid>
  </div>  

        
  <!-- 
    Regarding positioning of the Back and Continue buttons:
    The br element is needed; leave it there!
    The padding-left and padding-top might change from page to page,
    but leave the col width the same to maintain the same spacing between buttons on every page.
  -->
  <br />
  <div style="padding-left:0.85in; padding-top:0.22in;">   
      <table>
        <col style="width:190px"/>
        <col style="width:190px"/>
        <tr>
          <td align="left">
            <MT:MTButton ID="btnBack" runat="server" Text="<%$ Resources:Resource,TEXT_BACK %>"
                         OnClientClick="setLocationHref(ampPreviousPage); return false;"
                         CausesValidation="False" TabIndex="230" />
          </td>
          <td align="right">
            <MT:MTButton ID="btnContinue" runat="server" 
                         OnClientClick="if (ValidateForm()) { MPC_setNeedToConfirm(false); } else { MPC_setNeedToConfirm(true); return false; }"
                         OnClick="btnContinue_Click" CausesValidation="true" TabIndex="240" />
          </td>
        </tr>
      </table> 
  </div>


  <script type="text/javascript" language="javascript">

    OverrideRenderer_<%= AccountQualificationsGrid.ClientID %> = function(cm)
    {
        cm.setRenderer(cm.getIndexById('TableToInclude'), tableToIncludeColRenderer); 
        
        if (cm.getIndexById('Actions') != -1)
        {
            cm.setRenderer(cm.getIndexById('Actions'), actionsColRenderer);
        }
    }
    
    function tableToIncludeColRenderer(value, meta, record, rowIndex, colIndex, store) 
    {
        if (record.data.TableToInclude != null) {
            return record.data.TableToInclude;
        }
        return '';
    }
    
    // Event handler for Add button in AmpWizard.AccountQualifications gridlayout
    function onAdd_<%=AccountQualificationsGrid.ClientID%>()
    {
        makeAjaxRequest("UpdateAccountGroupDescription", "dummyAcctQualId", 
                        '<%= GetLocalResourceObject("TEXT_ERROR_UPDATING_ACCT_GROUP_DESCRIPTION") %>' + " " + "<%= AmpAccountQualificationGroupNameForJs %>");

        location.href = "AccountQualification.aspx?AcctQualAction=Create";
    }
    
    function actionsColRenderer(value, meta, record, rowIndex, colIndex, store)
    {
        var str = "";    
   
        // View
        str += String.format("&nbsp;&nbsp;<a style='cursor:pointer;' id='View' title='{1}' href='JavaScript:onViewAcctQualification(\"{0}\");'><img src='/Res/Images/icons/view.gif' alt='{1}' /></a>", record.data.UniqueId, TEXT_AMPWIZARD_VIEW);
   
        if ("<%=AmpAccountQualificationGroupAction%>" != "View")
        {
          //Edit
          str += String.format("&nbsp;&nbsp;<a style='cursor:pointer;' id='Edit' title='{1}' href='JavaScript:onEditAcctQualification(\"{0}\");'><img src='/Res/Images/icons/pencil.png' alt='{1}' /></a>",  record.data.UniqueId, TEXT_EDIT);
    
          //Delete
          str += String.format("&nbsp;&nbsp;<a style='cursor:pointer;' id='Delete' title='{1}' href='JavaScript:onDeleteAcctQualification(\"{0}\");'><img src='/Res/Images/icons/cross.png' alt='{1}' /></a>",  record.data.UniqueId, TEXT_DELETE);
        
          //Move earlier
          str += String.format("&nbsp;&nbsp;<a style='cursor:pointer;' id='MoveEarlier' title='{1}' href='JavaScript:onMoveEarlier(\"{0}\");'><img src='/Res/Images/icons/arrow_up.png' alt='{1}' /></a>",  record.data.UniqueId, '<%= GetLocalResourceObject("TEXT_RAISE_PRIORITY") %>' );
        
          //Move later
          str += String.format("&nbsp;&nbsp;<a style='cursor:pointer;' id='MoveLater' title='{1}' href='JavaScript:onMoveLater(\"{0}\");'><img src='/Res/Images/icons/arrow_down.png' alt='{1}' /></a>",  record.data.UniqueId, '<%= GetLocalResourceObject("TEXT_REDUCE_PRIORITY") %>' );
        }

        return str;
    }
    
    function onViewAcctQualification(id)
    {
        makeAjaxRequest("UpdateAccountGroupDescription", id, 
                        '<%= GetLocalResourceObject("TEXT_ERROR_UPDATING_ACCT_GROUP_DESCRIPTION") %>' + " " + "<%= AmpAccountQualificationGroupNameForJs %>");

        setTimeout(function() { location.href = "AccountQualification.aspx?AcctQualAction=View&AcctQualId=" + id; }, 500);
    }
  
    function onEditAcctQualification(id)
    {
        makeAjaxRequest("UpdateAccountGroupDescription", id, 
                        '<%= GetLocalResourceObject("TEXT_ERROR_UPDATING_ACCT_GROUP_DESCRIPTION") %>' + " " + "<%= AmpAccountQualificationGroupNameForJs %>");

        location.href= "AccountQualification.aspx?AcctQualAction=Edit&AcctQualId=" + id; 
    }
    
    function onDeleteAcctQualification(id)
    {
       top.Ext.MessageBox.show({
               title: TITLE_AMPWIZARD_DELETE_ACCOUNT_QUALIFICATION_CONFIRM,
               msg: String.format(TEXT_AMPWIZARD_DELETE_ACCOUNT_QUALIFICATION_CONFIRM, id),
               buttons: Ext.MessageBox.OKCANCEL,
               fn: function(btn){
                 if (btn == 'ok')
                 {
                    // make the call back to the server
                    makeAjaxRequest("DeleteAccountQualification", id, 
                                    '<%= GetLocalResourceObject("TEXT_ERROR_DELETING") %>' + " " + id);
                 }
               },
               animEl: 'elId',
               icon: Ext.MessageBox.QUESTION
            });
    }
    
    function onMoveEarlier(id)
    {
        makeAjaxRequest("MoveAccountQualificationEarlier", id, 
                        '<%= GetLocalResourceObject("TEXT_ERROR_RAISE_PRIORITY") %>' + " " + id);
    }

    function onMoveLater(id)
    {
        makeAjaxRequest("MoveAccountQualificationLater", id, 
                        '<%= GetLocalResourceObject("TEXT_ERROR_REDUCE_PRIORITY") %>' + " " + id);
    }

    function makeAjaxRequest(svcCommand, acctQualId, errorText)
    {
        var parameters = { 
          command: svcCommand, 
          accountGroupName: "<%= AmpAccountQualificationGroupNameForJs %>", 
          accountQualificationId: acctQualId,
          accountGroupDescription: document.getElementById('<%=tbAcctGroupDescription.ClientID %>').value 
        };

        // make the call back to the server
        Ext.Ajax.request({
                url: '/MetraNet/MetraOffer/AmpGui/AjaxServices/AccountQualificationsSvc.aspx',
                params: parameters,
                scope: this,
                disableCaching: true,
                callback: function(options, success, response) {
                    if (success) {
                        if (response.responseText == "OK") {
                            dataStore_<%= AccountQualificationsGrid.ClientID %> .reload();
                        }
                        else
                        {
                            Ext.UI.SystemError(errorText);
                        }
                    }
                    else
                    {
                        Ext.UI.SystemError(errorText);
                    }
                }
        });
    }
    
    Ext.onReady(function () {
        // Record the initial values of the page's controls.
        // (Note:  This is called here, and not on the master page,
        // because the call to document.getElementById() returns null
        // if executed on the master page.)
        MPC_assignInitialValues();
    });
    
  </script>
</asp:Content>


