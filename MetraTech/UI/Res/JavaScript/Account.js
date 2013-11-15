////////////////////////////////////////////////////////////////////
// Account Class
////////////////////////////////////////////////////////////////////

var accountJSON;
var accountTemplate;
var TempGrid;
var jsonDataSet;
var tempData;
var strUrl;
var tempds;
var tp;
var bDisplayHierarchy = true;
var currentAccountNode;

Account = {

    // Returns managed account in JSON or null if none is being managed.
    GetManagedAccount: function () {
        if (accountJSON == "" || accountJSON == null) {
            return null;
        }
        else {
            return accountJSON;
        }
    },



    GetHierarchyPath: function (accountID) {
        var crumb = Ext.get("path1");
        bDisplayHierarchy = true;
        var html = "";


        tp = new Ext.tree.TreePanel({
            useArrows: false,
            autoScroll: true,
            animate: true,
            lines: true,
            title: TEXT_ACCOUNT_SNAPSHOT,
            collapsible: true,
            style: { marginBottom: '10px', marginTop: '10px', marginLeft: '10px', marginRight: '10px' },
            frame: false,
            enableDD: false,
            containerScroll: true,
            //renderTo: crumb,
            border: true,
            loader: new Ext.tree.TreeLoader(),
            root: new Ext.tree.TreeNode({
                text: '',
                expanded: true,
                leaf: false,
                id: 'root'
            })
        });
        
        Ext.Ajax.request({
            url: '/MetraNet/AjaxServices/AncestorList.aspx',
            params: { id: accountID },
            timeout: 10000,
            success: function (response) {
                var result = Ext.decode(response.responseText);
                if (result.VisibleInHierarchy == false) {
                    tp.setVisible(false);
                    return;
                }
                else {
                    tp.setVisible(true);
                }

                var rootNode = new Ext.tree.TreeNode({
                    text: result.records[0].nm_login,
                    //qtip: result.records[0].nm_login + ' (' + result.records[0].id_ancestor + ')',
                    expandable: isExpandable,
                    expanded: true,
                    leaf: false,
                    //icon:rootIconString,
                    id: result.records[0].id_ancestor
                });

                rootNode.on('click', function (node, e) {
                    var nodeID = result.records[0].id_ancestor;
                    getFrameMetraNet().MainContentIframe.location.href = "/MetraNet/AdvancedFind.aspx?AncestorAccountID=" + nodeID;
                });

                tp.setRootNode(rootNode);

                var appendNode = tp.getRootNode();

                if (result.VisibleInHierarchy == false) {
                    bDisplayHierarchy = false;
                }
                tp.setVisible(bDisplayHierarchy);

                var childID;
                for (i = 1; i < result.records.length; i++) {

                    var isExpandable = (i == (result.records.length - 1)) ? false : true;

                    var isFolder = (result.records[i].folder == '1') ? 'True' : 'False';

                    var iconString = String.format("/ImageHandler/images/Account/{0}/account.gif?State={1}&Folder={2}&Payees={3}",
            result.records[i].accounttype,
            result.records[i].accountstatus,
            isFolder,
            "0");

                    var treeNode = new Ext.tree.TreeNode({
                        text: result.records[i].nm_login,
                        //qtip: result.records[i].nm_login + ' (' + result.records[i].id_ancestor + ')',
                        expandable: isExpandable,
                        expanded: true,
                        leaf: true,
                        draggable: true,
                        icon: iconString,
                        allowDrag: true,
                        id: result.records[i].id_ancestor
                    });

                    treeNode.on('click', function (node, e) {
                        //Account.Load(node.id);
                        var nodeID = node.id;
                        getFrameMetraNet().MainContentIframe.location.href = "/MetraNet/ManageAccount.aspx?id=" + nodeID + "&page=" + "/MetraNet/AdvancedFind.aspx?AncestorAccountID=" + nodeID;

                    });

                    appendNode.appendChild(treeNode)
                    appendNode = treeNode;
                    childID = result.records[i].id_ancestor;
                }
                
            },
            failure: function () {
                var crumb = Ext.get("path1");
                if (crumb != null) {
                    if (crumb.dom != null) {
                        crumb.dom.innerHTML = "root";
                    }
                }
                //hide hierarchy tree panel
                tp.setVisible(false);

            },
            scope: this
        });

    },

    MenuItemIsDisabled: function (account, menuItem) {
        var result = false;
        if (IsMenuItemDisabledForNode != null && typeof (IsMenuItemDisabledForNode) == 'function')
            result = IsMenuItemDisabledForNode(account, menuItem);
        return result;
    },

    ShowHCMenu: function (node, e) {
        var position = e.getXY();
        var itemMask = new Ext.LoadMask(Ext.Element.get(node.ui.getEl()), { msg: "Loading menu..." });
        itemMask.show();

        Ext.Ajax.request({
            url: '/MetraNet/AjaxServices/AccountContextMenu.aspx',
            params: {
                id_acc: node.id,
                canManage: node.attributes.canBeManaged
            },
            timeout: 10000,
            success: function (response) {
                itemMask.hide();
                var result = eval(response.responseText);
                if (typeof (result) !== 'undefined')
                    result.showAt(position);
            },
            failure: function () {
                itemMask.hide();
                alert("Error getting the menu for account");
            },
            scope: this
        });
    },

    LoadMenuPage: function (item, e) {
        if (getFrameMetraNet()) {
            var index = item.defaultHref.indexOf("?");
            var separator = index < 0 ? "?" : "&";
            getFrameMetraNet().MainContentIframe.location.href = "/MetraNet/ManageAccount.aspx?id=" + currentAccountNode.id + "&page=" + item.defaultHref;
        }
    },

    RefreshNode: function (node) {
        Ext.Ajax.request({
            url: '/MetraNet/AjaxServices/Hierarchy.aspx',
            params: {
                type: 'system_mps',
                node: node.id
            },
            timeout: 10000,
            success: function (response) {
                var parentNode = node;
                if (parentNode.hasChildNodes()) {
                    parentNode.removeAll(true);
                }
                var result = Ext.decode(response.responseText);
                if (result.length > 0) {
                    parentNode.removeAll(true);
                    for (i = 0; i < result.length; i++) {

                        var newNode = Account.CreateNode(result[i]);

                        parentNode.appendChild(newNode);
                    }
                }


                Ext.Ajax.request({
                    url: '/MetraNet/AjaxServices/Hierarchy.aspx',
                    params: {
                        type: 'system_mps',
                        node: parentNode.parentNode.id,
                        usernameFilter: parentNode.text
                    },
                    timeout: 10000,
                    success: function (resp) {
                        var res = Ext.decode(resp.responseText);
                        if (res.length == 1) {

                            parentNode.attributes.HasLogonCapability = res[0].HasLogonCapability;
                        }
                    }
                });



                parentNode.expand();
            },
            failure: function () {
                alert('failure');
            }
        });
    },

    CreateNode: function (source) {
        var newNode = source.leaf ?
                  new Ext.tree.TreeNode(source)
                              :
                  new Ext.tree.AsyncTreeNode(source);

        return newNode;
    },

    // Close active account 
    Close: function () {
        // make the call back to the server to close account
        Ext.Ajax.request({
            url: '/MetraNet/AjaxServices/CloseActiveAccount.aspx',
            scope: this,
            disableCaching: true,
            callback: function (options, success, response) {
                if (success) {
                    if (response.responseText == "OK") {
                        accountJSON = "";
                        accountTemplate = "";

                        // Remove currently selected subscriber at the top
                        var sub = getFrameMetraNet().Ext.get("subscriberInfo");
                        sub.dom.innerHTML = "";

                        //Remove find in hierarchy icon
                        var findHierarchybtn = getFrameMetraNet().Ext.get("btnFindHierarchy");
                        findHierarchybtn.hide();

                        // Clear tabs  
                        if (getFrameMetraNet().document.getElementById("AccountProps")) {
                            getFrameMetraNet().document.getElementById("AccountProps").innerHTML = '<p><i>' + TEXT_NO_ACCOUNT_LOADED + '</i></p>';
                        }
                        if (getFrameMetraNet().document.getElementById("AccountProps2")) {
                            getFrameMetraNet().document.getElementById("AccountProps2").innerHTML = '<p><i>' + TEXT_NO_ACCOUNT_LOADED + '</i></p>';
                        }
                        Ext.UI.LoadDashboard();
                    }
                }
            }
        });
        //  getFrameMetraNet().Ext.get("searchField").dom.value = "";
    },

    // Refresh active account 
    RefreshWithMenu: function () {
        if (getFrameMetraNet()) {
            getFrameMetraNet().hidden.location.href = "/MetraNet/ManageAccount.aspx";
        }
    },

    // Refresh active account without refreshing the main page.
    Refresh: function () {
        if (getFrameMetraNet() && getFrameMetraNet().hidden) {
            getFrameMetraNet().hidden.location.href = "/MetraNet/ManageAccount.aspx?page=NOP";
        }
    },

    // Load a new active account
    Load: function (id) {
        // Close any previous loaded account
        // Account.Close();
        if (getFrameMetraNet()) {
            getFrameMetraNet().hidden.location.href = "/MetraNet/ManageAccount.aspx?id=" + id;
        }
    },

    // Loads account, and when it is ready, loads a page for that account.
    LoadPage: function (id, page) {
        // Close any previous loaded account
        // Account.Close();
        if (getFrameMetraNet()) {
            getFrameMetraNet().hidden.location.href = "/MetraNet/ManageAccount.aspx?id=" + id + "&page=" + page;
        }
    },

    FindAccount: function () {
        Ext.UI.NewWindow("MetraNet Find Account", "FindAccount", "/MetraNet/AccountNavigation.aspx");
    },

    LinkAccount: function () {
        if (accountJSON != null && accountJSON._AccountID != null) {
            Account.ShowHierarchyTab(accountJSON._AccountID);
        }
    },

    // Manage Account
    Manage: function (url) {
        var jsonData = accountJSON;
        var templateData = accountTemplate;

        if (jsonData === undefined)
            return;

        // show currently selected subscriber at the top
        var sub = getFrameMetraNet().Ext.get("subscriberInfo");
        //SECENG:
        //var subUserName = jsonData.UserName;
        //var subId = jsonData._AccountID;
        var subUserName = Ext.util.Format.htmlEncode(jsonData.UserName);
        var subId = Ext.util.Format.htmlEncode(jsonData._AccountID);
        var findButton = getFrameMetraNet().Ext.get("btnFindHierarchy");
        findButton.show();

        Account.GetHierarchyPath(subId);

        sub.dom.innerHTML = String.format("{0} ({1})", subUserName, subId);
        sub.highlight('#c3daf9', { block: true });

        var propDiv = document.getElementById("AccountProps");
        if (propDiv != null) {
            propDiv.innerHTML = "";

            var addressPanel = new Ext.Panel({
                layout: 'form',
                id: 'addressPanel',
                collapsible: true,
                title: TEXT_PROPERTIES,
                frame: true,
                //renderTo:'addressDiv',
                html: '',
                style: { marginBottom: '10px', marginTop: '10px', marginLeft: '10px', marginRight: '10px' }
            });

            var p = new Ext.Panel({
                width: '100%',
                //html: '<p><i>' + TEXT_NO_ACCOUNT_LOADED + '</i></p>',
                items: [addressPanel, tp],
                layout: 'form',
                tbar: [{
                    text: TEXT_RELOAD_ACCOUNT,
                    iconCls: 'refresh',
                    handler: function () { Account.Refresh(); }
                },
         new Ext.Toolbar.Fill(),
         {
             text: TEXT_CLOSE_ACCOUNT,
             iconCls: 'close',
             handler: function () { Account.Close(); }
         },
         new Ext.Toolbar.Fill(),
         {
             text: 'Hierarchy Search',
             iconCls: 'hierarchyFind',
             handler: function () { Account.ShowHierarchyTab(subId); }
         }],
                renderTo: propDiv
            });

            if (jsonData != null || jsonData != "") {


                try {
                    if (templateData && templateData != "") {
                        templateData.overwrite(addressPanel.body, jsonData);
                        //p.body.highlight('#c3daf9', { block: true });
                        getFrameMetraNet().Account.ShowPropertyGrid(jsonData);
                    }
                }
                catch (e) {
                    getFrameMetraNet().Ext.UI.msg("Error1", e.message);
                }
            }
        }

        // if the url is specified as NOP we do not load a page
        if (url == "NOP")
            return;

        // we could redirect to the account summary page here... for now we reload the dashboard.
        if ((url == "") || (url == null)) {
            Ext.UI.LoadDashboard();
        }
        else {
            Ext.UI.LoadPage(url);
        }

    },

    ShowPropertyGrid: function (jsonData) {
        var PropGrid = getFrameMetraNet().document.getElementById("AccountProps2");
        if (PropGrid != null) {
            PropGrid.innerHTML = "";

            TempGrid = new Ext.grid.GridPanel({
                enableColumnMove: false,
                stripeRows: false,
                trackMouseOver: false,
                clicksToEdit: 1,
                enableHdMenu: false,
                viewConfig: {
                    forceFit: true
                },
                autoHeight: true,

                source: new Object(),
                loadingMask: true,
                columns: [
            { header: TEXT_NAME, width: 90, sortable: true, dataIndex: 'name', id: 'name', menuDisabled: true },
            { header: TEXT_VALUE, width: 90, resizable: true, dataIndex: 'value', id: 'value', menuDisabled: true,
                renderer: function (value, meta, record, rowIndex, colIndex, store) {
                    if (Ext.isDate(value)) {
                        return value.dateFormat(DATE_FORMAT);
                    }
                    return value;
                }
            }
          ],
                store: new Ext.data.Store({
                    recordType: Ext.grid.PropertyRecord
                }),
                renderTo: PropGrid
            });

            FillPropertyGrid(jsonData, "");
            //TempGrid.store.sort(TempGrid.store.fields.keys[0], "ASC");
        }

    },
    ShowHierarchyTab: function (accountID) {
      Account.ShowHierarchyTabWithHighlight(accountID, true);
    },
    ShowHierarchyTabWithHighlight: function (accountID, highlight) {
      var east = Ext.getCmp('east-panel');
      if (east != null) {
      east.expand();
      }
      var tabs = AcctTabPanel;
      if (tabs != null) {
      tabs.setActiveTab(tabs.items.items[0]);
      }
      Ext.Ajax.request({
        url: '/MetraNet/AjaxServices/HierarchyPath.aspx',
        params: { node: accountID, type: 'system_mps' },
        timeout: 10000,
        success: function (response) {
          var tree = GlobalTree;
          if (tree != null) {
            var result = Ext.decode(response.responseText);
            var c = tree.root;
            if (c != null && !c.expanded) {
              tree.setRootNode(new Ext.tree.TreeNode(c.attributes));
              c = tree.root;
              tree.root.reload = function () {
                GlobalTree.setRootNode(new Ext.tree.AsyncTreeNode(GlobalTree.root.attributes));
                GlobalTree.root.reload();
              }
            }
            for (i = 0; i < result.length; i++) {
              var nId = result[i].id;
              var n = tree.getNodeById(nId);
              if (n == null) {
                var pId = result[i].parentid;
                var p = tree.getNodeById(pId);
                if (p != null) {
                  if (p != null && p.loaded != null && !p.loaded) {
                    var newp = new Ext.tree.TreeNode(p.attributes);
                    newp.reload = function () {
                      var oldp = new Ext.tree.AsyncTreeNode(this.attributes);
                      this.parentNode.replaceChild(oldp, this);
                      oldp.ensureVisible();
                      if (this.is_highlight) {
                        oldp.getUI().addClass('x-tree-highlighted');
                      }
                      Account.ShowHierarchyTabWithHighlight(this.id, this.highlight);
                    }
                    p.parentNode.replaceChild(newp, p);
                    newp.ensureVisible();
                    if (p.is_highlight != null && p.is_highlight == true) {
                      newp.is_highlight = true;
                      var ui = newp.getUI();
                      if (ui != null) {
                        ui.addClass('x-tree-highlighted');
                      }
                    }
                    p = newp;
                  }
                  if (result[i].leaf || i < result.length - 1) {
                    result[i].is_static = true;
                    var x = new Ext.tree.TreeNode(result[i]); //Account.CreateNode(result[i]);
                    p.appendChild(x);
                    c = n = x;
                    x.reload = function () {
                      var newp = new Ext.tree.AsyncTreeNode(this.attributes);
                      this.parentNode.replaceChild(newp, this);
                      newp.ensureVisible();
                      if (this.is_highlight) {
                        newp.getUI().addClass('x-tree-highlighted');
                      }
                      Account.ShowHierarchyTabWithHighlight(this.id, this.highlight);
                    }
                  }
                  else {
                    var x = new Ext.tree.AsyncTreeNode(result[i]); //Account.CreateNode(result[i]);
                    p.appendChild(x);
                    c = n = x;
                  }
                  if (Account.SortHierarchyChildre != undefined) {
                    p.sort(Account.SortHierarchyChildren);
                  }
                }
              }
              else {
                var pId = result[i].parentid;
                if (n.parentNode.id != pId) {
                  n.parentNode.removeChild(n);
                  var p = tree.getNodeById(pId);
                  p.appendChild(n);
                  p.sort(Account.SortHierarchyChildren);
                }
                c = n;
              }
            }
            if (c != null) {
              if (highlight) {
                c.is_highlight = true;
                c.ensureVisible();
                var ui = c.getUI();
                if (ui != null) {
                  ui.addClass('x-tree-highlighted');
                }
              }
              if (tree.getSelectionModel() != null) {
                tree.getSelectionModel().select(c, null, true);
              }
            }
          }
        },
        failure: function () {
          alert('failed to load hierarchy');
        }
      });
    },

    HierarchyLoaded: function (bSuccess, oLastNode) {
        if (bSuccess) {
            if (oLastNode != null) {
                var ui = oLastNode.getUI();
                if (ui != null) {
                    ui.addClass('x-tree-highlighted');
                }
            }
            var tree = GlobalTree;
            if (tree != null) {
                tree.getSelectionModel().select(oLastNode, null, true);
            }
        }
    },
    NodeLoaded: function (node) {
        if (node != null) {
            var ui = node.getUI();
            if (ui != null) {
                ui.addClass('x-tree-highlighted');
            }
        }
        var tree = GlobalTree;
        if (tree != null) {
            tree.getSelectionModel().select(node, null, true);
        }
    },
    SortHierarchyChildren: function (n1, n2) {
        var i1 = n1.id;
        var i2 = n2.id;
        var x1 = n1.attributes['n_folder'];
        var x2 = n2.attributes['n_folder'];
        var y1 = n1.attributes['nm_type'];
        var y2 = n2.attributes['nm_type'];
        var z1 = n1.attributes['nm_name'];
        var z2 = n2.attributes['nm_name'];
        if (x1 != null) {
            x1 = parseInt(x1);
        }
        else if (x2 == null) {
            return 0;
        }
        else {
            return 1;
        }
        if (x2 != null) {
            x2 = parseInt(x2);
        }
        else {
            return -1;
        }
        if (x1 < x2) {
            return -1;
        }
        else if (x1 > x2) {
            return 1;
        }
        if (y1 != null) {
            y1 = y1.toUpperCase();
        }
        else {
            y1 = "";
        }
        if (y2 != null) {
            y2 = y2.toUpperCase();
        }
        else {
            y2 = "";
        }
        if (y1 < y2) {
            return -1;
        }
        else if (y1 > y2) {
            return 1;
        }
        if (z1 != null) {
            z1 = z1.toUpperCase();
        }
        else {
            z1 = "";
        }
        if (z2 != null) {
            z2 = z2.toUpperCase();
        }
        else {
            z2 = "";
        }
        if (z1 < z2) {
            return -1;
        }
        else if (z1 > z2) {
            return 1;
        }
        if (i1 != null) {
            i1 = parseInt(i1);
        }
        else if (i2 == null) {
            return 0;
        }
        else {
            return 1;
        }
        if (i2 != null) {
            i2 = parseInt(i2);
        }
        else {
            return -1;
        }
        if (i1 < i2) {
            return -1;
        }
        else if (i1 > i2) {
            return 1;
        }
        return 0;
    },
    ShowHierarchyTab: function (accountID) {
        Account.ShowHierarchyTabWithHighlight(accountID, true);
    },
    ShowHierarchyTabWithHighlight: function (accountID, highlight) {
        var east = Ext.getCmp('east-panel');
        if (east != null) {
            east.expand();
        }
        var tabs = AcctTabPanel;
        if (tabs != null) {
            tabs.setActiveTab(tabs.items.items[0]);
        }
        Ext.Ajax.request({
            url: '/MetraNet/AjaxServices/HierarchyPath.aspx',
            params: { node: accountID, type: 'system_mps' },
            timeout: 10000,
            success: function (response) {
                var tree = GlobalTree;
                /*      if (tree != null) {
                var path = "/1" + response.responseText;
                tree.expandPath(path, null, Account.HierarchyLoaded);
                }*/
                if (tree != null) {
                    var result = Ext.decode(response.responseText);
                    var c = tree.root;
                    if (c != null && !c.expanded) {
                        tree.setRootNode(new Ext.tree.TreeNode(c.attributes));
                        c = tree.root;
                        tree.root.reload = function () {
                            GlobalTree.setRootNode(new Ext.tree.AsyncTreeNode(GlobalTree.root.attributes));
                            GlobalTree.root.reload();
                        }
                    }
                    for (i = 0; i < result.length; i++) {
                        var nId = result[i].id;
                        var n = tree.getNodeById(nId);
                        if (n == null) {
                            var pId = result[i].parentid;
                            var p = tree.getNodeById(pId);
                            if (p != null) {
                                if (p != null && p.loaded != null && !p.loaded) {
                                    var newp = new Ext.tree.TreeNode(p.attributes);
                                    newp.reload = function () {
                                        var oldp = new Ext.tree.AsyncTreeNode(this.attributes);
                                        this.parentNode.replaceChild(oldp, this);
                                        oldp.ensureVisible();
                                        if (this.is_highlight) {
                                            oldp.getUI().addClass('x-tree-highlighted');
                                        }
                                        Account.ShowHierarchyTabWithHighlight(this.id, this.highlight);
                                    }
                                    p.parentNode.replaceChild(newp, p);
                                    newp.ensureVisible();
                                    if (p.is_highlight != null && p.is_highlight == true) {
                                        newp.is_highlight = true;
                                        var ui = newp.getUI();
                                        if (ui != null) {
                                            ui.addClass('x-tree-highlighted');
                                        }
                                    }
                                    p = newp;
                                }
                                if (result[i].leaf || i < result.length - 1) {
                                    result[i].is_static = true;
                                    var x = new Ext.tree.TreeNode(result[i]); //Account.CreateNode(result[i]);
                                    p.appendChild(x);
                                    c = n = x;
                                    x.reload = function () {
                                        var newp = new Ext.tree.AsyncTreeNode(this.attributes);
                                        this.parentNode.replaceChild(newp, this);
                                        newp.ensureVisible();
                                        if (this.is_highlight) {
                                            newp.getUI().addClass('x-tree-highlighted');
                                        }
                                        Account.ShowHierarchyTabWithHighlight(this.id, this.highlight);
                                    }
                                }
                                else {
                                    var x = new Ext.tree.AsyncTreeNode(result[i]); //Account.CreateNode(result[i]);
                                    p.appendChild(x);
                                    c = n = x;
                                }
                                p.sort(Account.SortHierarchyChildren);
                            }
                        }
                        else {
                            var pId = result[i].parentid;
                            if (n.parentNode.id != pId) {
                                n.parentNode.removeChild(n);
                                var p = tree.getNodeById(pId);
                                p.appendChild(n);
                                p.sort(Account.SortHierarchyChildren);
                            }
                            c = n;
                        }
                    }
                    if (c != null) {
                        if (highlight) {
                            c.is_highlight = true;
                            c.ensureVisible();
                            var ui = c.getUI();
                            if (ui != null) {
                                ui.addClass('x-tree-highlighted');
                            }
                        }
                        if (tree.getSelectionModel() != null) {
                            tree.getSelectionModel().select(c, null, true);
                        }
                    }
                }
            },
            failure: function () {
                alert('failed to load hierarchy');
            }
        });
    },

    RetrieveGridData: function (jsonds, templateData, url) {
        tempds = jsonds;
        tempData = templateData;
        strUrl = url;
    },

    RetrieveGridValues: function () {
        return tempds;
    },

    RetrieveTemplateData: function () {
        return tempData;
    },

    RetrieveUrl: function () {
        return strUrl;
    }

}

function StringEndsWith(source, endString)
{
  var pos = source.indexOf(endString);
  if(pos <= 0)
  {
    return false;
  }
  
  if(pos == (source.length - endString.length))
  {
    return true;
  }
  
  return false;
}

function FillPropertyGrid(jsonDataColl, ParentPath)
{
  for(var AcctProp in jsonDataColl)
    {    
      //if the property's value is a function, do not display it
       if (typeof(jsonDataColl[AcctProp]) == 'function')  
          continue;      
          
          
       //skip DisplayName and ValueDisplayName properties
       if(StringEndsWith(AcctProp,"ValueDisplayName"))
       {
        continue;
       }
       
       if(StringEndsWith(AcctProp,"DisplayName"))
       {
        continue;
       }
       
       var PropName; 
       if((ParentPath != "") && (ParentPath != "Internal"))
       {        
           PropName = ParentPath + '.' + AcctProp;
       }
       else
       {
           PropName = AcctProp;
       }      
                 
      if ((jsonDataColl[AcctProp] == null) || (typeof(jsonDataColl[AcctProp]) != 'object'))
      {    
         var PropRecord;
         var PropValue = jsonDataColl[AcctProp];
         if (PropValue == '&nbsp;') 
            PropValue = '';
       
            
        //remove dirty fields  
         if(PropName.indexOf("Is") == 0)
         {
           if(StringEndsWith(AcctProp,"Dirty"))
           {
              continue;
           }      
         }       
          var propertyDisplayName = eval("jsonDataColl." + AcctProp + "DisplayName") + '';
          
          if((ParentPath != ""))
          {
            //for contact views, parent path would be in form LDAP.X 
            if(ParentPath.indexOf('LDAP') == 0)
            {
              ParentPath = jsonDataColl.ContactTypeValueDisplayName;
            }
            propertyDisplayName = ParentPath + '.' + propertyDisplayName;
          }
               
         if(typeof(PropValue) == 'string')
         {            
              var DateMatch = PropValue.match(/\/Date[(](\d+)[)]/);
              if(DateMatch != null)
              {
                PropValue = DateMatch[1];
                var DispDate = new Date(parseInt(PropValue));               
                PropRecord = new Ext.grid.PropertyRecord({
                             name: propertyDisplayName,
                             value: DispDate
                      });
                      
              }
              else
              {
                PropRecord = new Ext.grid.PropertyRecord({
                             name: propertyDisplayName,
                             value: PropValue
                      });
               
              }        
         } 
         else
         {   
              var value = PropValue;
              
              //handle enums
              if (eval("jsonDataColl." + AcctProp + "ValueDisplayName") != undefined)
              {
                value = eval("jsonDataColl." + AcctProp + "ValueDisplayName");
              }
                                           
              PropRecord = new Ext.grid.PropertyRecord({
                             name: propertyDisplayName,
                             value: value
                      });             
                      
         }                 
        TempGrid.store.add(PropRecord);   
                     
      }
      else
      {        
       FillPropertyGrid(jsonDataColl[AcctProp], PropName);
      }
      
    }

}