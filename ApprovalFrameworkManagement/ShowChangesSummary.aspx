<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
    Inherits="ApprovalFrameworkManagement_ShowChangesSummary" Title="Changes Summary"
    Culture="auto" UICulture="auto" CodeFile="ShowChangesSummary.aspx.cs" %>

<%@ Import Namespace="MetraTech.UI.Tools" %>
<%@ Import Namespace="Resources" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<style>
.approveButton
{
  background-image: url(/Res/Images/icons/accept.png) !important;
}
.denyButton
{
  background-image: url(/Res/Images/icons/delete.png) !important;
}
.resubmitButton
{
  background-image: url(/Res/Images/icons/database_refresh.png) !important;
}
.approvalStatus
{
  background-position: left center;
  padding-left: 10px !important;
}
.appliedStatus
{
  background:url(/Res/Images/icons/bullet_green.png) no-repeat !important;
}
.dismissedStatus
{
  background:url(/Res/Images/icons/bullet_delete.png) no-repeat !important;
}
.failedStatus
{
  background:url(/Res/Images/icons/bullet_error.png) no-repeat !important;
}
</style>
    <div class="CaptionBar">
        <asp:Label ID="lblShowChangesSummaryTitle" runat="server" Text="All Changes Summary"
            meta:resourcekey="lblShowAllChangesSummaryTitleResource1"></asp:Label>
    </div>
    <br />
    <MT:MTFilterGrid runat="Server" ID="ChangesSummary" ExtensionName="Core" TemplateFileName="Approvals.ChangesSummary.xml"
        ButtonAlignment="Center" Buttons="None" DefaultSortDirection="Ascending" DisplayCount="True"
        EnableColumnConfig="True" EnableFilterConfig="True" EnableLoadSearch="False"
        EnableSaveSearch="False" Expandable="False" ExpansionCssClass="" Exportable="False"
        FilterColumnWidth="350" FilterInputWidth="220" FilterLabelWidth="75" FilterPanelCollapsed="False"
        FilterPanelLayout="MultiColumn" meta:resourcekey="ChangesSummaryResource1" MultiSelect="False"
        NoRecordsText="No records found" PageSize="10" Resizable="True" RootElement="Items"
        SearchOnLoad="True" SelectionModel="Standard" ShowBottomBar="True" ShowColumnHeaders="True"
        ShowFilterPanel="True" ShowGridFrame="True" ShowGridHeader="True" ShowTopBar="True"
        TotalProperty="TotalRows">
    </MT:MTFilterGrid>
    <MT:MTPanel ID="ChangeDetailsPanel" runat="server" meta:resourcekey="MTSection2Resource1"
        Collapsible="false" Text="Change Details" Width="100%">
        <div id="leftColumn" class="LeftColumn">
        </div>
        <br />
        <iframe id="changedetailsframe" scrolling="no" frameborder="0" src="" width="800"
            height="600" class="iframe"></iframe>
    </MT:MTPanel>
    <script language="javascript" type="text/javascript">

  OverrideRenderer_<%=ChangesSummary.ClientID %> = function(cm)
  {
    cm.setRenderer(cm.getIndexById('Id'), customChangeIdRenderer); 
    cm.setRenderer(cm.getIndexById('Comment'), customCommentRenderer); 
    cm.setRenderer(cm.getIndexById('CurrentStateDisplayName'), customChangeStateRenderer); 
    cm.setRenderer(cm.getIndexById('ChangeType'), customChangeTypeRenderer); 
    cm.setRenderer(cm.getIndexById('ItemDisplayName'), customItemDisplayNameRenderer); 

  }
  
   function getStateValueFromEnumValue(currentStateAsIntegerValue) {
       var currentState = "";
       switch (currentStateAsIntegerValue)
       {
       case 0:
           currentState = "Pending";
           break;
       case 1:
           currentState = "ApprovedWaitingToBeApplied";
           break;
       case 2:
           currentState = "FailedToApply";
           break;
       case 3:
           currentState = "Applied";
           break;
       case 4:
           currentState = "Dismissed";
           break;
       default:
           currentState = "[Unknown]";
       }

       return currentState;
   }

  function customChangeIdRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = "";
    var currentstate = "";
    var submitterid = "";
    var changetype = "";
      
       currentstate = getStateValueFromEnumValue(record.data.CurrentState);
       submitterid = record.data.SubmitterId;
       changetype = record.data.ChangeType;
       
       str += String.format("<span><a style='cursor:hand;' id='manage_{0}' title='{2}' href='JavaScript:showchangeitemhistory(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/database_edit.png' alt='{2}' /></a></span>", record.data.Id, currentstate,"Show History for Change ID "+ Ext.util.Format.htmlEncode(record.data.Id));
  
       //str += String.format("<span><a style='cursor:hand;' id='manage_{0}' title='{4}' href='JavaScript:showchangeitemdetails(\"{0}\", \"{1}\", \"{2}\",\"{3}\");'><img src='/Res/Images/icons/application_form_edit.png' alt='{4}' /></a></span>", record.data.Id, currentstate, submitterid, changetype, "Show Details for Change ID "+ Ext.util.Format.htmlEncode(record.data.Id) + " " + Ext.util.Format.htmlEncode(currentstate));
  
    return str;
  }
  

  function onInvalidateChangeDetails()
  {
    Ext.UI.startLoading('formPanel_ctl00_ContentPlaceHolder1_ChangeDetailsPanel', 'Updating');
  }

  function onDoneLoadingChangeDetails()
  {
    Ext.UI.doneLoading('formPanel_ctl00_ContentPlaceHolder1_ChangeDetailsPanel');
  }
  
  function UserOptions(){}
  UserOptions.prototype = { gotoNextRowAfterStateChanged: true,
                            clearCommentAfterUsed: true };

  var currentUserOptions = new UserOptions();

  function modifyChangeState(idChange, strAction)
  {
    onInvalidateChangeDetails();

      var panelChangeDetails = Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_ChangeDetailsPanel');
      var tbActions = panelChangeDetails.getComponent('approvalsChangeDetailsActions');
      var strComment = tbActions.getComponent('commentField').getValue();

      var parameters = {action: strAction, changeid: idChange, comment: strComment, ReturnUpdatedItem: 'true'}; 

      Ext.Ajax.timeout = 900000;

      // make the call back to the server
      Ext.Ajax.request({
      url: 'AjaxServices/ChangeOperation.aspx',
      params: parameters,
      scope: this,
      disableCaching: true,
      callback: function(options, success, response) {
        if (success) {  
          var responseJSON = Ext.decode(response.responseText);
          if (responseJSON) {
            if (responseJSON.success) {
              //Ext.UI.doneLoading(document.body);
              //refreshAndClose();
              var record = dataStore_ctl00_ContentPlaceHolder1_ChangesSummary.getById(idChange);

              //Ideally I would have time to do something generic, but for now just update the values we know probably changed
              record.set('CurrentStateDisplayName', responseJSON.updatedItem.CurrentStateDisplayName);
              record.set('CurrentState', responseJSON.updatedItem.CurrentState);
              //TODO: Figure out what sort of date adjusting we do for the grid
              //record.set('ChangeLastModifiedDate', responseJSON.updatedItem.ChangeLastModifiedDate);
              record.set('ChangeLastModifiedDate', null);
              record.commit();

              if (currentUserOptions.clearCommentAfterUsed)
                tbActions.getComponent('commentField').setValue('');

             
              if (currentUserOptions.gotoNextRowAfterStateChanged)
              {
                selectNextRow();
              }
              else
              {
                onShowChildPanelForParentGridRow(record);
              }
            }
            else
            {
              Ext.MessageBox.show({  
                title: TEXT_ERROR,  
                msg: responseJSON.message,  
                buttons: Ext.MessageBox.OK,  
                icon: Ext.MessageBox.ERROR  
              });  

              refreshChangeDetailsForSelectedRow();
            }
          }
          else
          {
            Ext.MessageBox.show({  
              title: TEXT_ERROR,  
              msg: response,  
              buttons: Ext.MessageBox.OK,  
              icon: Ext.MessageBox.ERROR  
            });  

            refreshChangeDetailsForSelectedRow();
          }
        }
        else
        {
          Ext.MessageBox.show({  
              title: "Ajax Call Failed",  
              msg: "Call to server timed out.",  
              buttons: Ext.MessageBox.OK,  
              icon: Ext.MessageBox.ERROR  
          });  

          refreshChangeDetailsForSelectedRow();
        }
      }
      }); 

  }

  function selectNextRow()
  {
    var grid = grid_ctl00_ContentPlaceHolder1_ChangesSummary;
    var sm = grid.getSelectionModel();
    var newRowSelected = sm.selectNext();
          
    if (newRowSelected)
    {
      refreshChangeDetailsForSelectedRow();
    }
    else
    {
      //Eventually prompt or otherwise refresh or go to the next page
      //For now just refresh the change details
      refreshChangeDetailsForSelectedRow();
    }
  }

  function refreshChangeDetailsForSelectedRow()
  {
    var record = grid_ctl00_ContentPlaceHolder1_ChangesSummary.getSelectionModel().getSelected();
    onShowChildPanelForParentGridRow(record);
  }

   function showHideApprovalButtons(strChangeCurrentState, strChangeType, row)
   {
      var isSubmitter = (<%= UI.User.AccountId %>== row.data.SubmitterId);
      var hasCapability = userCapabilities[strChangeType];
      if (undefined == hasCapability)
        hasCapability = false;
      
      var showApproveDeny = false;
      var showDismiss = false;
      var showResubmit = false;
      //var showComment = false;
      var notificationText = "";

 
      var panelChangeDetails = Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_ChangeDetailsPanel');

      var tbNotification;
      tbNotification = panelChangeDetails.getComponent('approvalsChangeDetailsNotification');
      if (tbNotification == undefined)
      {
        tbNotification = new Ext.Toolbar({
          itemId: 'approvalsChangeDetailsNotification',
          items: [{
          xtype: 'tbtext',
          itemId: 'currentStatusText',
          text: ''
          }]
          });

        panelChangeDetails.add(tbNotification);
       }

      var tbActionResubmit;
      tbActionResubmit = panelChangeDetails.getComponent('approvalsChangeDetailsActionResubmit');
      if (tbActionResubmit == undefined)
      {
        tbActionResubmit = new Ext.Toolbar({
        itemId: 'approvalsChangeDetailsActionResubmit',
        items: [{
        xtype: 'tbbutton',
        itemId: 'approvalsResubmitButton',
        text: TEXT_APPROVALS_ACTION_RESUBMIT,
        tooltip: TEXT_APPROVALS_ACTION_RESUBMIT_TIP,
        iconCls: 'resubmitButton',
        handler: function(btn) {modifyChangeState(currentlySelectedRow.data.Id,'Resubmit');}  
//        },{
//        xtype: 'tbseparator'
//        },{  
//        xtype: 'tbtext',
//        text: TEXT_APPROVALS_ACTION_RESUBMIT_TIP
        }]
        });

        panelChangeDetails.add(tbActionResubmit);
       }

      var tbActions;
      tbActions = panelChangeDetails.getComponent('approvalsChangeDetailsActions');
      if (tbActions == undefined)
      {
        tbActions = new Ext.Toolbar({
        itemId: 'approvalsChangeDetailsActions',
        items: [{
        xtype: 'tbtext',
        text: TEXT_APPROVALS_COMMENT_LABEL
        },{      
        xtype: 'textfield',
        itemId: 'commentField',
        width: 200,
        grow: true,
        growMin: 200,
        growMax: 800
        },{      
        xtype: 'tbbutton',
        itemId: 'approvalsApproveButton',
        text: TEXT_APPROVALS_ACTION_APPROVE,
        //scale: 'medium',
        iconCls: 'approveButton',
        handler: function(btn)
                  {
                    modifyChangeState(currentlySelectedRow.data.Id,'Approve');
                  }
        },{      
        xtype: 'tbbutton',
        itemId: 'approvalsDenyButton',
        text: TEXT_APPROVALS_ACTION_DENY,
        iconCls: 'denyButton',
        handler: function(btn)
                  {
                    modifyChangeState(currentlySelectedRow.data.Id,'Deny');
                  }
        },{     
        xtype: 'tbbutton',
        itemId: 'approvalsDismissButton',
        text: TEXT_APPROVALS_ACTION_DISMISS,
        iconCls: 'denyButton',
        handler: function(btn)
                  {
                    modifyChangeState(currentlySelectedRow.data.Id,'Dismiss');
                  }
        }]
        });

        panelChangeDetails.add(tbActions);

       
       }

  
    notificationText = eval("TEXT_APPROVALS_STATE_EXPLANATION_" + strChangeCurrentState.toUpperCase());

    //Determine State
    switch(strChangeCurrentState)
    {
      case "Pending":
        if (hasCapability && !isSubmitter) showApproveDeny = true;
        if (isSubmitter)
        {
          showDismiss = true;
          notificationText += TEXT_APPROVALS_STATE_EXPLANATION_SUBMITTER;
        }
        break;
      case "Applied":
        break;
      case "FailedToApply":
        showResubmit = true;
        if (hasCapability) showDismiss = true;
    }

    //Update the toolbars
    tbActionResubmit.setVisible(showResubmit);
    tbActions.setVisible(showApproveDeny || showDismiss);
    tbActions.getComponent('approvalsApproveButton').setVisible(showApproveDeny);
    tbActions.getComponent('approvalsDenyButton').setVisible(showApproveDeny);
    tbActions.getComponent('approvalsDismissButton').setVisible(showDismiss);

    tbNotification.getComponent('currentStatusText').setText(notificationText);
    tbNotification.doLayout();

    panelChangeDetails.doLayout();

   }

  function showchangeitemhistory(Id, currentstate)
  {
       var scs = escape('<%= Utils.EncodeForHtml(strShowChangeState) %>');
       location.href = '/MetraNet/ApprovalFrameworkManagement/ShowChangeItemHistory.aspx?changeid=' + Id + '&currentstate=' + currentstate + '&showchangestate=' + scs;
  }  
  
  <%= GenerateJavascriptForUserChangeTypeCapabilities() %>
  <%= GenerateJavascriptForChangeTypeConfiguration() %>


  function showChangeDetails(id, changeType, currentState)
  {
    //Get the configured URL
    var changeTypeConfig = changeTypesConfiguration[changeType];
    var urlDetails = '';
    if (changeTypeConfig != undefined)
    {
      urlDetails=changeTypeConfig.WebpageForView;
    }

    //If not configured, use the default viewer
    if (0 === urlDetails.length)
      urlDetails='/MetraNet/ApprovalFrameworkManagement/ChangeTypeViewers/DefaultViewChangeDetails.aspx?ChangeId=%%CHANGE_ID%%';

    //Set the parameters
    urlDetails = urlDetails.replace(/%%CHANGE_ID%%/g, id);
    urlDetails = urlDetails.replace(/%%CHANGE_STATE%%/g, currentState);
    
    urlDetails = urlDetails.replace(/%%CHANGE_TYPE%%/g, (changeTypeConfig != undefined) ? changeTypeConfig.GridTitle : "");
    //frames.document is null in Chrome and Firefox
    if (window.frames['changedetailsframe'].document == null) {
      window.frames['changedetailsframe'].contentWindow.document.location.href = urlDetails;
    } else {
      window.frames['changedetailsframe'].document.location.href = urlDetails;
    }
    

    //Make sure to unhide or make the details frame visible
    Ext.get('MyFormDiv_ctl00_ContentPlaceHolder1_ChangeDetailsPanel').dom.style.display = 'block';

  }      

//   function showchangeitemdetails(Id, currentstate, submitterid, changetype)
//        {
//        
//       showorhideapprovalbuttons(currentstate, changetype, submitterid);
//       
//     mychangeid = Id;
//       var scs1 = escape('<%= Utils.EncodeForHtml(strShowChangeState) %>');
//      //Display the Change Details Page in the frame below Show Change Summary Page 
//      if (changetype=='AccountUpdate')
//      {
//          window.frames['changedetailsframe'].document.location.href = '/MetraNet/ApprovalFrameworkManagement/ChangeTypeViewers/ViewAccountChangeDetails.aspx?changeid=' + Id + '&currentstate=' + currentstate + '&showchangestate=' + scs1;
//      }
//      else if (changetype=='ProductOfferingUpdate')
//      {
//          window.frames['changedetailsframe'].document.location.href = '/MetraNet/ApprovalFrameworkManagement/ChangeTypeViewers/ViewProductOfferingChangeDetails.aspx?changeid=' + Id + '&currentstate=' + currentstate + '&showchangestate=' + scs1;
//      }
//      else
//      {
//          if (changetype == 'RateUpdate')
//          {
//              window.frames['changedetailsframe'].document.location.href = '/MetraNet/TicketToMamNoMenu.aspx?URL=/MAM/default/dialog/gotoRuleEditorViewDifference.asp|APPROVAL_ID=' + Id;
//          }
//          else
//          {            
//            if (changetype.substr(0, 8) == "GroupSub")
//            {
//                window.frames['changedetailsframe'].document.location.href = '/MetraNet/ApprovalFrameworkManagement/ChangeTypeViewers/ViewGroupSubscriptionMemberUpdateDetails.aspx?changeid=' + Id + '&currentstate=' + currentstate + '&showchangestate=' + scs1;
//            }            
//            else
//            {
//             //Call Default Viewer
//             window.frames['changedetailsframe'].document.location.href = '/MetraNet/ApprovalFrameworkManagement/ChangeTypeViewers/DefaultViewChangeDetails.aspx?changeid=' + Id + '&currentstate=' + currentstate + '&showchangestate=' + scs1;
//            }
//          }
//      }

//      //Make sure to unhide or make the details frame visible
//      Ext.get('MyFormDiv_ctl00_ContentPlaceHolder1_ChangeDetailsPanel').dom.style.display = 'block';
//      //Ext.get('MyFormDiv_ctl00_ContentPlaceHolder1_ChangeDetailsPanel').dom.style.marginRight = '10px;';

//      }  



     //Hook up row selected to reload details grid
    Ext.onReady(function(){
          
        //Bit of a hack to get the panel to be 100%
        Ext.get('formPanel_ctl00_ContentPlaceHolder1_ChangeDetailsPanel').dom.style.width = '100%';
        //Ext.get('formPanel_ctl00_ContentPlaceHolder1_ChangeDetailsPanel').dom.style.marginRight = '10px;';
        //Ext.get('MyFormDiv_ctl00_ContentPlaceHolder1_ChangeDetailsPanel').dom.style.marginRight = '10px;';

        //Hide the child panel until and item is selected
        //filterPanel_ctl00_ContentPlaceHolder1_SummaryDetailsGrid.setVisible(false);
        Ext.get('MyFormDiv_ctl00_ContentPlaceHolder1_ChangeDetailsPanel').dom.style.display = 'none';

        
        var grid = grid_ctl00_ContentPlaceHolder1_ChangesSummary;
        //Setup the rowclick event
        grid.on('rowclick', function(grid, rowIndex, e) {
        grid.getSelectionModel().selectRow(rowIndex);
        var row = grid.store.getAt(rowIndex);
        if (row != undefined){                        
            onShowChildPanelForParentGridRow(row);
         }
        });


 

    bbar_ctl00_ContentPlaceHolder1_ChangesSummary.on({
      change: function( pagingToolBar, changeEvent ) {
          grid_ctl00_ContentPlaceHolder1_ChangesSummary.getSelectionModel().selectFirstRow();
          grid_ctl00_ContentPlaceHolder1_ChangesSummary.fireEvent('rowclick', grid_ctl00_ContentPlaceHolder1_ChangesSummary, 0);
        }
    });

  });

  var currentlySelectedRow;
  function onShowChildPanelForParentGridRow(row)
  {
    currentlySelectedRow = row;
    showChangeDetails(row.data.Id, row.data.ChangeType, getStateValueFromEnumValue(row.data.CurrentState));
    showHideApprovalButtons(getStateValueFromEnumValue(row.data.CurrentState), row.data.ChangeType, row);

    onDoneLoadingChangeDetails();
  }

  function BeforeSearch_ctl00_ContentPlaceHolder1_ChangesSummary()
  {
    //Hide the details panel when we start a new search
    Ext.get('MyFormDiv_ctl00_ContentPlaceHolder1_ChangeDetailsPanel').dom.style.display = 'none';
  }

  function customCommentRenderer(value, metadata, record, rowIndex, colIndex, store){
    metadata.attr = 'ext:qtip="' + value + '"';
    return value;
  }

  function customItemDisplayNameRenderer(value, metadata, record, rowIndex, colIndex, store){
    metadata.attr = 'ext:qtip="' + value + '"';
    return value;
  }

  function customChangeTypeRenderer(value, metadata, record, rowIndex, colIndex, store){
    metadata.attr = 'ext:qtip="' + value + '"';
    return value;
  }
 
  function customChangeStateRenderer(value, metadata, record, rowIndex, colIndex, store){
    metadata.attr = 'ext:qtip="' + value + '"';
    metadata.css = 'approvalStatus';

    switch (record.data.CurrentState)
    {
      case 0:
          break;
      case 1:
          break;
      case 2:
          metadata.css += ' failedStatus';
          break;
      case 3:
          metadata.css += ' appliedStatus';
          break;
      case 4:
          metadata.css += ' dismissedStatus';
          break;
    }

    return value;
  }

    </script>
</asp:Content>
