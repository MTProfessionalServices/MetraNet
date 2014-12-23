<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" Inherits="welcome" Title="MetraNet" CodeFile="Welcome.aspx.cs" %>
<%@ Register src="./UserControls/Notifications/Notifications.ascx" tagname="Notifications" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

	<style>

	    .ApprovalNotification { 
			text-decoration: none; 
			display: block; 
			padding: 5px;
			background: transparent; 
			border-radius: 5px; 
			/*color: white; */
			margin: 5px 5px 5px 5px; 
			/*opacity: 0.5;*/
			
			-webkit-transition: all 0.2s ease;
			-moz-transition: all 0.2s ease;
			-o-transition: all 0.2s ease;
	    }
	    .ApprovalNotification:hover {
			opacity: 1;
			color: white;
			background: lightsteelblue; 
	    }

	</style> 

  <div id="recentAccountContainer" style="width: 400px; padding: 10px;"></div>
  <div id="pendingApprovalsContainer" style="width: 400px; padding: 10px;"></div>
 

  <uc1:Notifications ID="notification" runat="server" />

  <script type="text/javascript">

    // Sometimes when we come back from old MAM or MetraView we may have an extra frame.
    // This code busts out of it.
    if (getFrameMetraNet() && getFrameMetraNet().MainContentIframe) {
      if (getFrameMetraNet().MainContentIframe.location != document.location) {
        getFrameMetraNet().MainContentIframe.location.replace(document.location);
      }
    }

    Ext.onReady(function () {

      var p = new Ext.Panel({
        items: [{
          title: TEXT_RECENT_ACCOUNTS,
          html: '<div id="recentAccountsList"><i>' + TEXT_NO_RECENT_ACCOUNTS + '</i></div>',
          renderTo: 'recentAccountContainer',
          listeners: {
            render: function (panel) {
              var recentAccTpl = new Ext.XTemplate(
                            '<tpl for="ListRecentAccounts">',
                              '<tpl if="AccountId &gt; 1">',
                                  '<tpl if="this.isNull(FirstName, LastName) == true">',
                                    '<p><img src="/ImageHandler/images/Account/{AccountType}/account.gif"><a href="/MetraNet/ManageAccount.aspx?id={AccountId}">{Username:htmlEncode}&nbsp;({AccountId:htmlEncode})</a></p>',
                                  '</tpl>',
                                  '<tpl if="this.isNull(FirstName, LastName) == false">',
                                    '<p><img src="/ImageHandler/images/Account/{AccountType}/account.gif"><a href="/MetraNet/ManageAccount.aspx?id={AccountId}">{FirstName:htmlEncode}&nbsp;{LastName:htmlEncode}&nbsp;({AccountId:htmlEncode})</a>{[this.getDisplay(values.AccountId)]}</p>',
                                  '</tpl>',
                              '</tpl>',
                              '<tpl if="AccountId == 0">',
                                '<p><div id="recentAccountsList"><i>' + TEXT_NO_RECENT_ACCOUNTS + '</i></div></p>',
                              '</tpl>',
                            '</tpl>', {
                              isNull: function (FirstName, LastName) {
                                if ((FirstName == null) || (LastName == null) || (FirstName == '') || (LastName == '')) {
                                  return true;
                                }
                                else {
                                  return false;
                                }

                              },
                              getDisplay: function (acc) {
                                return ""; //hierarchy view todo
                              }
                            }
                          );

              Ext.Ajax.request({
                url: '/MetraNet/AjaxServices/RecentAccounts.aspx',
                timeout: 10000,
                params: {},
                success: function (response) {
                  recentAccTpl.overwrite(this.body, Ext.decode(response.responseText));
                },
                failure: function () {
                },
                scope: panel
              });
            }
          }
        }
                ]
      });

      //var TEXT_APPROVAL_CHANGES_PENDING_YOUR_APPROVAL = "Changes Pending Your Approval";

      var pApprovals = new Ext.Panel({
        items: [{
          title: TEXT_APPROVAL_CHANGES_PENDING_YOUR_APPROVAL,
          html: '<div id="pendingApprovalsList"><i>' + TEXT_APPROVAL_NO_CHANGES_PENDING_YOUR_APPROVAL + '</i></div>',
          renderTo: 'pendingApprovalsContainer',
          listeners: {
            render: function (panel) {
              var pendingApprovalsTpl = new Ext.XTemplate(
                            '<tpl for=".">',
                                '<p style="margin-bottom:10px;"><a href="/MetraNet/ApprovalFrameworkManagement/ShowChangesSummary.aspx?Filter_ChangesSummary_ChangeState=Pending&Filter_ChangesSummary_ChangeType={ChangeType}"><div class="ApprovalNotification"><div style="float:left;margin:5px; margin-right:10px;"><img src="/ImageHandler/images/Approvals/ChangeTypes/{ChangeType}/ChangeType.png"></div><div style="margin:5px;padding-left:10px;"><b>{ChangeTypeDisplayName}</b><br>{PendingCount} '
                                  + TEXT_APPROVAL_PENDING_CHANGES_WAITING_FOR_APPROVAL + ' &nbsp;&nbsp; <b>' + TEXT_AMPWIZARD_VIEW + '</b></div></div></a></p>',
                            '</tpl>', {
                              isNull: function (FirstName, LastName) {
                                if ((FirstName == null) || (LastName == null) || (FirstName == '') || (LastName == '')) {
                                  return true;
                                }
                                else {
                                  return false;
                                }

                              },
                              getDisplay: function (acc) {
                                return ""; //hierarchy view todo
                              }
                            }
                          );

              Ext.Ajax.request({
                url: '/MetraNet/ApprovalFrameworkManagement/AjaxServices/ApprovalsPendingForUser.aspx',
                timeout: 10000,
                params: {},
                success: function (response) {
                  if (response.responseText == '[]') {
                    //Nothing to show, hide the panel
                    pApprovals.hide();
                    Ext.get("pendingApprovalsContainer").hide();
                  }
                  else {
                    pendingApprovalsTpl.overwrite(this.body, Ext.decode(response.responseText));
                    //Ext.get("pendingApprovalsContainer").show();
                    Ext.get("pendingApprovalsContainer").fadeIn({
                      endOpacity: 1, //can be any value between 0 and 1 (e.g. .5)
                      easing: 'easeOut',
                      duration: 2
                    });
                  }

                },
                failure: function () {
                },
                scope: panel
              });
            }
          }
        }
                ]
      });

    });

    Ext.get("pendingApprovalsContainer").hide(); 
  </script>
</asp:Content>
