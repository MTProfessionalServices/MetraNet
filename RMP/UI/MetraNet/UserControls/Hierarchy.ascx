<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_Hierarchy" CodeFile="Hierarchy.ascx.cs" %>

<script type="text/javascript">
  Ext.onReady(function () {

    var selectedNode;
    var metraTimeToday = Date.parseDate("<%= MetraTimeToday %>", DATE_FORMAT);

    //define calendar that is placed in the tbar of the tree panel
    var treeCalendar = new Ext.form.DateField({
      format: DATE_FORMAT,
      //editable: false,
	   hideMode: 'visibility',
	  hidden: true,
      name: 'treeCalendar',
      id: 'treeCalendar',
      width: 100,
      value: metraTimeToday
    });

    //company filter
    var companyFilter = new Ext.form.TextField({
      name: 'companyFilter',
	   hideMode: 'visibility',
	  hidden: true,
      id: 'companyFilter',
      width: 130,
      value: '',
      emptyText: TEXT_CORP_COMPANY_NAME
    });

    //username filter
    var usernameFilter = new Ext.form.TextField({
      name: 'usernameFilter',
	   hideMode: 'visibility',
	  hidden: true,
      id: 'usernameFilter',
      width: 135,
      value: '',
      emptyText: TEXT_CORP_COMPANY_USERNAME
    });

    //Capture 'select' event of the datePicker, and use the selected date to refresh the tree
    treeCalendar._old_onTriggerClick = treeCalendar.onTriggerClick
    treeCalendar.onTriggerClick = function () {
      var doset = (this.menu == null);
      this._old_onTriggerClick();
      if (doset && this.menu != null) {
        this.menu.on({
          'select': function (m, d) {
            this.setValue(d);
            RefreshTree(companyFilter.el.dom.value, usernameFilter.el.dom.value, d);
          },
          scope: this

        });
      }
    };

    //Enter key handler to refresh the tree
    companyFilter.on('specialkey', function (f, e) {
      if (e.getKey() == e.ENTER) {
        RefreshTree(companyFilter.el.dom.value, usernameFilter.el.dom.value, treeCalendar.el.dom.value);
        return false;
      }
    }, this);

    //Enter key handler to refresh the tree
    usernameFilter.on('specialkey', function (f, e) {
      if (e.getKey() == e.ENTER) {
        RefreshTree(companyFilter.el.dom.value, usernameFilter.el.dom.value, treeCalendar.el.dom.value);
        return false;
      }
    }, this);

    treeCalendar.on('specialkey', function (f, e) {
      if (e.getKey() == e.ENTER) {
        RefreshTree(companyFilter.el.dom.value, usernameFilter.el.dom.value, treeCalendar.el.dom.value);
        return false;
      }
    }, this);


    //sets up the toolbar of the tree panel that has the dateField in it.
    var tbTree = new Ext.Toolbar({
      layout: 'toolbar',
      border: false,
      items: [{
        xtype: 'button',
        iconCls: 'x-tbar-loading',
        handler: function () {
          RefreshTree(companyFilter.el.dom.value, usernameFilter.el.dom.value, treeCalendar.el.dom.value);
        }
      }, companyFilter, usernameFilter, treeCalendar]
    });
   
    // shorthand
    var Tree = Ext.tree;

    var tree = new Tree.TreePanel({
      tbar: tbTree,
      useArrows: true,
      autoScroll: false,
      animate: false,
      enableDD: false,
      containerScroll: false,
      border: false,
      timeout: 10000,
      // auto create TreeLoader
      dataUrl: '/MetraNet/AjaxServices/Hierarchy.aspx?type=<%=StartAccountType%>',
      listeners:
      {
        click: function (n) {
          //"-111" is id of node which load siblings from dataUrl.
          if (n.id < 0) {

            var nextPageNumber = parseInt(n.previousSibling.attributes.pageNumber) + parseInt(1);
            var myDate;
            if (typeof (treeCalendar.el.dom.value) == "string") {
              //attempt parsing the string
              myDate = Date.parseDate(treeCalendar.el.dom.value, DATE_FORMAT);

              // if parsing failed, default to today
              if (myDate == null) {
                myDate = metraTimeToday;
                treeCalendar.setValue(myDate);
              }
            }
            else {
              myDate = treeCalendar.el.dom.value;
            }
            var companyString = companyFilter.el.dom.value;
            if (companyString == TEXT_CORP_COMPANY_NAME) companyString = '';

            var usernameString = usernameFilter.el.dom.value;
            if (usernameString == TEXT_CORP_COMPANY_USERNAME) usernameString = '';
            Ext.Ajax.request({
              url: '/MetraNet/AjaxServices/Hierarchy.aspx',
              params: {
                type: 'system_mps',
                startAccountNameInPage: n.previousSibling.attributes.text,
                node: n.parentNode.id,
                pageNumber: nextPageNumber,

                companyFilter: companyString,
                usernameFilter: usernameString,
                day: myDate.getDate(),
                month: (myDate.getMonth() + 1),
                year: myDate.getFullYear()
              },
              timeout: 10000,
              success: function (response) {
                var result = Ext.decode(response.responseText);
                for (i = 0; i < result.length; i++) {
                  var newNode = Account.CreateNode(result[i]);
                  n.parentNode.insertBefore(newNode, n.parentNode.lastChild);

                }

                if (result.length == 0) {
                  n.parentNode.removeChild(n.parentNode.lastChild);
                }
              },
              failure: function () {
                alert('failure');
              }
            });
          }
          else {
            HierarhyNodeId = n.id;
          }
        }
      },

      root: {
        nodeType: 'async',
        text: TEXT_ACCOUNT_HIERARCHY,
        draggable: false,
        id: '1'
      }
    });

    // render the tree
    tree.render('tree-div');
    tree.getRootNode().expand
    GlobalTree = tree;

    /*
    * This function takes in either a date, or a string representation of a date.
    * In case of string representation, it gets converted into the date object, defaulting
    * to todays date if it is in either wrong format, or before 1970.  Then, based on the 
    * date, the tree panel is refreshed by forwarding the formatted date into dataURL of the loader.
    */
    function RefreshTree(companyString, usernameString, newDate) {
      var myDate;
      if (companyString == TEXT_CORP_COMPANY_NAME) companyString = '';
      if (usernameString == TEXT_CORP_COMPANY_USERNAME) usernameString = '';

      if (typeof (newDate) == "string") {
        //attempt parsing the string
        myDate = Date.parseDate(newDate, DATE_FORMAT);

        // if parsing failed, default to today
        if (myDate == null) {
          myDate = metraTimeToday;
          treeCalendar.setValue(myDate);
        }
      }
      else {
        myDate = newDate;
      }

      //reload the tree based on calendar information
      tree.getLoader().dataUrl = '/MetraNet/AjaxServices/Hierarchy.aspx?companyFilter=' + companyString + '&usernameFilter=' + usernameString + '&type=<%=StartAccountType%>&day='
			  + myDate.getDate() + '&month=' + (myDate.getMonth() + 1) + '&year=' + myDate.getFullYear();
      tree.getRootNode().reload();
    }
  });

  function IsMenuItemDisabledForNode(node, menuItem) {
    var result = false;
    if (node != null && node.attributes != null) {
      switch (menuItem.id)
      {
        case "UpdateAccount":
          result = (node.attributes.canBeManaged == 'False');
          break;
        case "UpdateContact":
          result = (node.attributes.canBeManaged == 'False');
          break;
      }
    }
    return result;
  }

</script>

<div id="tree-div" style="overflow:auto; height:98%;width:99%;border:0px;"></div>
