<%@ Page Title="MetraNet" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="GeneralInformation.aspx.cs"  Inherits="AmpGeneralInformationPage" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Import Namespace="MetraTech.UI.Tools" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="General Information" meta:resourcekey="lblTitleResource1"></asp:Label>   
  </div>

  <div style="line-height:20px;padding-top:10px;padding-left:15px;">
    <asp:Label ID="lblGenInfo" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
      Font-Size="9pt" meta:resourcekey="lblGenInfoResource1" 
      Text="A Decision is used to analyze usage records (rated billing records) and possibly modify charges on the basis of this analysis.  Decisions are necessary when it is impossible to determine the amount by examining a single isolated record." ></asp:Label>
     <span style="color:blue;text-decoration:underline;cursor:pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_MORE_INFO, TEXT_AMPWIZARD_HELP_GENERAL_INFO, 450, 110)">
       <img id="Img1" src='/Res/Images/icons/help.png' />
    </span>
  </div>

  <br />

  <div style="padding-left:100px">
    <MT:MTTextBoxControl ID="tbGenInfoName" runat="server" AllowBlank="False" Label="Decision Type Name"
        TabIndex="200" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":"
        LabelWidth="120" Listeners="{}" meta:resourcekey="tbGenInfoNameResource1" ReadOnly="False"
        XType="TextField" XTypeNameSpace="form" ValidationRegex="null" VType="decisionRelatedName"/>
    <div id="editDescriptionDiv" runat="server">
    <MT:MTTextArea ID="tbDescription" runat="server" AllowBlank="True" Label="Description"
        TabIndex="210" ControlWidth="200" ControlHeight="80" HideLabel="False" LabelSeparator=":"
        LabelWidth="120" meta:resourcekey="tbDescriptionResource1" ReadOnly="False"
        XType="TextArea" XTypeNameSpace="form" Listeners="{}" />
    </div>
    <div id="viewDescriptionDiv" runat="server">
      <table class="GeneralInformationViewDescription" >
        <tr>
          <td class="GeneralInformationViewDescriptionCol1">
            <MT:MTLabel ID="ViewDescriptionLabel" runat="server" Text="Description:" meta:resourcekey="ViewDescriptionLabelResource"/>
          </td>
          <td class="GeneralInformationViewDescriptionCol2">
            <MT:MTLabel ID="ViewDescriptionText" runat="server" />
          </td>
        </tr>
      </table>
    </div>     
    <div style="float:left; width:325px;">
        <MT:MTDropDown ID="ddParamTable" runat="server" AllowBlank="false" Label="Parameter Table" ReadOnly="false" Editable="true"
           TabIndex="220" ControlWidth="200" ListWidth="200" HideLabel="False" LabelSeparator=":" Listeners="{}"
           meta:resourcekey="ddParamTableResource1" LabelWidth="120" OptionalExtConfig="height:'100px'" CausesValidation="True">    
        </MT:MTDropDown>  
    </div>   
   
    <span style="color:blue;text-decoration:underline;cursor:pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_PARAM_TABLE, TEXT_AMPWIZARD_HELP_PARAM_TABLE, 450, 210)">
       <img id="Img1" src='/Res/Images/icons/help.png' />
    </span>

    <div style="clear:both;padding-left:22px;padding-top:5px" >
    </div>
</div>
  <!-- 
    Regarding positioning of the Back and Continue buttons:
    The br element is needed; leave it there!
    The padding-left and padding-top might change from page to page,
    but leave the col width the same to maintain the same spacing between buttons on every page.
  -->
  <br />
  <div style="padding-left:0.85in; padding-top:1.5in;">   
      <table>
        <col style="width:190px"/>
        <col style="width:190px"/>
        <tr>
          <td align="left">
            <MT:MTButton ID="btnBack" runat="server" Text="<%$Resources:Resource,TEXT_BACK%>"
                         OnClientClick="setLocationHref(ampPreviousPage); return false;"
                         CausesValidation="false" TabIndex="230" />
          </td>
          <td align="right">
            <MT:MTButton ID="btnSaveAndContinue" runat="server" Text="<%$Resources:Resource,TEXT_NEXT%>"
                         OnClientClick="if (ValidateForm()) { MPC_setNeedToConfirm(false); } else { MPC_setNeedToConfirm(true); return false; }"
                         OnClick="btnContinue_Click"
                         CausesValidation="true" TabIndex="240"/>
            <MT:MTButton ID="btnContinue" runat="server" Text="<%$Resources:Resource,TEXT_CONTINUE%>"
                         OnClientClick="MPC_setNeedToConfirm(false);"
                         OnClick="btnContinue_Click"
                         CausesValidation="False" TabIndex="240"/>
          </td>
        </tr>
      </table> 
  </div>


  <script type="text/javascript" language="javascript">
    
    Ext.onReady(function () 
    {
      function invalidParameterTableName()
      {
        var invalidParameterTableNameWindow = new top.Ext.Window({
          id: 'invalidParameterTableNameWindow',
          title: TITLE_AMPWIZARD_ERROR,
          width: 450,
          height: 200,
          minWidth: 450,
          minHeight: 200,
          layout: 'fit',
          plain: true,
          bodyStyle: 'padding:5px;',
          buttonAlign: 'center',
          collapsible: true,
          resizable: false,
          maximizable: false,
          closable: true,
          closeAction: 'close',  
          modal: 'true',       
          html: '<iframe id="invalidParameterTableNameWindow" src="/MetraNet/MetraOffer/AmpGui/InvalidParameterTableName.aspx?DecisionName='+<%="'"+getCurrentDecisionInstanceName()+"'"%>+'&ParameterTableName='+<%="'"+getCurrentDecisionInstanceParameterTableName()+"'"%>+'" width="100%" height="100%" frameborder="0" />'
        });
    
        invalidParameterTableNameWindow.show();
        invalidParameterTableNameWindow.on('close', function() {
        window.parent.location = "/MetraNet/MetraOffer/AmpGui/Start.aspx";
        });
      }

      function invalidParameterTableNameView()
      {
        var invalidParameterTableNameViewWindow = new top.Ext.Window({
          id: 'invalidParameterTableNameWindow',
          title: TITLE_AMPWIZARD_ERROR,
          width: 450,
          height: 200,
          minWidth: 450,
          minHeight: 200,
          layout: 'fit',
          plain: true,
          bodyStyle: 'padding:5px;',
          buttonAlign: 'center',
          collapsible: true,
          resizable: false,
          maximizable: false,
          closable: true,
          closeAction: 'close',  
          modal: 'true',       
          html: '<iframe id="invalidParameterTableNameWindow" src="/MetraNet/MetraOffer/AmpGui/InvalidParameterTableName.aspx?DecisionName='+<%="'"+getCurrentDecisionInstanceName()+"'"%>+'&ParameterTableName='+<%="'"+getCurrentDecisionInstanceParameterTableName()+"'"%>+'" width="100%" height="100%" frameborder="0" />'
        });
    
        invalidParameterTableNameViewWindow.show();
      }

      // Record the initial values of the page's controls.
      // (Note:  This is called here, and not on the master page,
      // because the call to document.getElementById() returns null
      // if executed on the master page.)
      MPC_assignInitialValues();

      if ( <%="'" + (ddParamTable.SelectedValue) + "'"%> == '') {
       invalidParameterTableName();
      }
      
      if ( <%="'" + AmpAction + "'" %> == 'View' ) {
        if ( <%="'" + IsParameterTableInvalid.ToString().ToLower() + "'"%> == 'true' ) {
          invalidParameterTableNameView();
        }
      }

    });

  </script>

</asp:Content>
