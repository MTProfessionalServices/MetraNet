<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="ChargeCreditDirectives.aspx.cs" Inherits="AmpChargeCreditDirectivesPage" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    
  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Charge/Credit: Directives" meta:resourcekey="lblTitleResource1"></asp:Label>
  </div>

  <br/>

	<div style="padding-left:12px">
	
	    <table>
			<tr>
				<td>
					<MT:MTTextBoxControl ID="tbChargeCreditName" runat="server" LabelSeparator="Charge/Credit:"
							ControlWidth="185" ControlHeight="18"
							LabelWidth="78" meta:resourcekey="tbChargeCreditNameResource1" ReadOnly="True"
							XType="TextField" XTypeNameSpace="form"/>
				</td>
                <td>
					<div style="padding-top:4px;padding-left:10px;">
						<img id="Img2" src='/Res/Images/icons/cog_error_32x32.png' runat="server" title="<%$ Resources:AmpWizard,TEXT_ADVANCED_FEATURE %>" />
					</div>                    
				</td>			
			</tr>
		</table>
	
		<MT:MTTextBoxControl ID="tbProductViewName" runat="server" LabelSeparator="Product View:"
							ControlWidth="185" ControlHeight="18"
							LabelWidth="85" meta:resourcekey="tbProductViewNameResource1" ReadOnly="True"
							XType="TextField" XTypeNameSpace="form"/>
	
		<br/>
  
		<asp:Label ID="lbDescription" style="line-height:20px;" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
					Font-Size="9pt" meta:resourcekey="lbDescription" Text="From resource" Width="390" />
        
		<br/>
<!--
		<span style="color: blue; text-decoration: underline; cursor: pointer" onclick="displayInfo(TITLE_AMPWIZARD_MORE_INFO, TEXT_AMPWIZARD_MORE_DIRECTIVES, 300, 80)"
			id="DirectivesMoreLink">
			<asp:Literal ID="MoreInfoLiteral" runat="server" Text="<%$ Resources:AmpWizard,TEXT_MORE %>" />
		</span>
-->
        </div>
		
		<br/>
		<br/>

        <MT:MTFilterGrid ID="DirectivesGrid" runat="server" TemplateFileName="AmpWizard.Directives" ExtensionName="MvmAmp" />

		<br/>
		<br/>
		<asp:Label style="padding-left:12px" ID="lbGrid2Title" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
					Font-Size="9pt" meta:resourcekey="lbGrid2TitleResource1" Text="Product View and t_acc_usage fields:" />
        
        <span style="color:blue;text-decoration:underline;cursor:pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_DIRECTIVES, TEXT_AMPWIZARD_HELP_DIRECTIVES, 350, 90)">
            <img id="Img1" src='/Res/Images/icons/help.png' />
        </span>
        		
        <MT:MTFilterGrid ID="PVGrid" runat="server" TemplateFileName="AmpWizard.ProdViewPopulated" ExtensionName="MvmAmp" />
        
    <div style="padding-left:0.58in; padding-top:0.22in;">   
        <table>
        <col style="width:150px"/>
        <col style="width:150px"/>
        <tr>
            <td align="left">
            <MT:MTButton ID="btnBack" runat="server" Text="<%$Resources:Resource,TEXT_BACK%>"
                            OnClientClick="setLocationHref(ampPreviousPage); return false;"
                            CausesValidation="false" TabIndex="230" />
            </td>
            <td align="right">
            <MT:MTButton ID="btnContinue" runat="server" Text="<%$Resources:Resource,TEXT_CONTINUE%>"   
                            OnClientClick="MPC_setNeedToConfirm(false);"                          
                            OnClick="btnContinue_Click"
                            CausesValidation="False" TabIndex="240"/>
            </td>
        </tr>
        </table>
    </div>
		
    <script type="text/javascript" language="javascript">
    
    OverrideRenderer_<%= DirectivesGrid.ClientID %> = function(cm)
    {
        cm.setRenderer(cm.getIndexById('Type'), typeColRenderer); 
        cm.setRenderer(cm.getIndexById('Details'), detailsColRenderer); 
        
        if (cm.getIndexById('Actions') != -1)
        {
            cm.setRenderer(cm.getIndexById('Actions'), actionsColRenderer);
        }
    }
    
    function typeColRenderer(value, meta, record, rowIndex, colIndex, store) 
    {
        if (record.data.IncludeTableName != null) {
            return 'Table Inclusion';
        }
        
        if (record.data.FieldName != null) {
            return 'Field Population';
        }
        
        if (record.data.MvmProcedure != null) {
            return 'Procedure';
        }
        
        return '';
    }
    
    function detailsColRenderer(value, meta, record, rowIndex, colIndex, store) 
    {
        if (record.data.IncludeTableName != null) {
            return record.data.IncludeTableName;
        }
        
        if (record.data.FieldName != null) {
            return record.data.FieldName;
        }
        
        if (record.data.MvmProcedure != null) {
            return record.data.MvmProcedure;
        }
        
        return '';
    }
    
    // Event handler for Add button in AmpWizard.GeneratedCharges gridlayout
    function onAdd_<%=DirectivesGrid.ClientID %>()
    {
    location.href = "ChargeCreditDirective.aspx?DirectiveAction=Create";
    }

    function actionsColRenderer(value, meta, record, rowIndex, colIndex, store) {
      var str = "";

      // View
      str += String.format("&nbsp;&nbsp;<a style='cursor:pointer;' id='View' title='{1}' href='JavaScript:onViewDirective(\"{0}\");'><img src='/Res/Images/icons/view.gif' alt='{1}' /></a>", record.data.UniqueId, TEXT_AMPWIZARD_VIEW);

      if ("<%=AmpChargeCreditAction%>" != 'View') {
        //Edit
        str += String.format("&nbsp;&nbsp;<a style='cursor:pointer;' id='Edit' title='{1}' href='JavaScript:onEditDirective(\"{0}\");'><img src='/Res/Images/icons/pencil.png' alt='{1}' /></a>", record.data.UniqueId, TEXT_EDIT);

        //Delete
        str += String.format("&nbsp;&nbsp;<a style='cursor:pointer;' id='Delete' title='{1}' href='JavaScript:onDeleteDirective(\"{0}\");'><img src='/Res/Images/icons/cross.png' alt='{1}' /></a>", record.data.UniqueId, TEXT_DELETE);

        //Raise priority
        str += String.format("&nbsp;&nbsp;<a style='cursor:pointer;' id='RaisePriority' title='{1}' href='JavaScript:onRaisePriority(\"{0}\");'><img src='/Res/Images/icons/arrow_up.png' alt='{1}' /></a>", record.data.UniqueId, '<%= GetLocalResourceObject("TEXT_RAISE_PRIORITY") %>');

        //Reduce priority
        str += String.format("&nbsp;&nbsp;<a style='cursor:pointer;' id='ReducePriority' title='{1}' href='JavaScript:onReducePriority(\"{0}\");'><img src='/Res/Images/icons/arrow_down.png' alt='{1}' /></a>", record.data.UniqueId, '<%= GetLocalResourceObject("TEXT_REDUCE_PRIORITY") %>');
      }

      return str;
    }
    
    function onViewDirective(id)
    {
        location.href= "ChargeCreditDirective.aspx?DirectiveAction=View&DirectiveID=" + id;
    }
  
    function onEditDirective(id)
    {
        location.href= "ChargeCreditDirective.aspx?DirectiveAction=Edit&DirectiveID=" + id; 
    }
    
    function onRaisePriority(id)
    {
        var parameters = { ampCommand: "RaisePriorityDirective", chargeName: "<%= AmpChargeCreditName %>", directiveId: id };
        // make the call back to the server
        Ext.Ajax.request({
                url: '/MetraNet/MetraOffer/AmpGui/AjaxServices/AmpSvc.aspx',
                params: parameters,
                scope: this,
                disableCaching: true,
                callback: function(options, success, response) {
                    if (success) {
                        if (response.responseText == "OK") {
                            dataStore_<%= DirectivesGrid.ClientID %> .reload();
                        }
                        else
                        {
                            Ext.UI.SystemError('<%= GetLocalResourceObject("TEXT_ERROR_RAISE_PRIORITY") %>' + " " + id);
                        }
                    }
                    else
                    {
                        Ext.UI.SystemError('<%= GetLocalResourceObject("TEXT_ERROR_RAISE_PRIORITY") %>' + " " + id);
                    }
                }
            });
    }

    function onReducePriority(id)
    {
        var parameters = { ampCommand: "ReducePriorityDirective", chargeName: "<%= AmpChargeCreditName %>", directiveId: id };
        // make the call back to the server
        Ext.Ajax.request({
                url: '/MetraNet/MetraOffer/AmpGui/AjaxServices/AmpSvc.aspx',
                params: parameters,
                scope: this,
                disableCaching: true,
                callback: function(options, success, response) {
                    if (success) {
                        if (response.responseText == "OK") {
                            dataStore_<%= DirectivesGrid.ClientID %> .reload();
                        }
                        else
                        {
                            Ext.UI.SystemError('<%= GetLocalResourceObject("TEXT_ERROR_REDUCE_PRIORITY") %>' + " " + id);
                        }
                    }
                    else
                    {
                        Ext.UI.SystemError('<%= GetLocalResourceObject("TEXT_ERROR_REDUCE_PRIORITY") %>' + " " + id);
                    }
                }
            });
    }
    
    function onDeleteDirective(id)
    {
       top.Ext.MessageBox.show({
               title: TITLE_AMPWIZARD_DELETE_DIRECTIVE_CONFIRM,
               msg: String.format(TEXT_AMPWIZARD_DELETE_DIRECTIVE_CONFIRM, id),
               buttons: Ext.MessageBox.OKCANCEL,
               fn: function(btn){
                 if (btn == 'ok')
                 {
                    var parameters = {ampCommand: "DeleteDirective", chargeName: "<%= AmpChargeCreditName %>", directiveId: id}; 
                    // make the call back to the server
                    Ext.Ajax.request({
                        url: '/MetraNet/MetraOffer/AmpGui/AjaxServices/AmpSvc.aspx',
                        params: parameters,
                        scope: this,
                        disableCaching: true,
                        callback: function(options, success, response) {
                          if (success) {
                            if(response.responseText == "OK") {
                              dataStore_<%= DirectivesGrid.ClientID %>.reload();
                              dataStore_<%= PVGrid.ClientID %>.reload();                             
                            }
                            else
                            {
                              Ext.UI.SystemError(TEXT_ERROR_DELETING + " " + id);
                            }
                          }
                          else
                          {
                            Ext.UI.SystemError(TEXT_ERROR_DELETING + " " + id);
                          }
                        }
                     });
                 }
               },
               animEl: 'elId',
               icon: Ext.MessageBox.QUESTION
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

