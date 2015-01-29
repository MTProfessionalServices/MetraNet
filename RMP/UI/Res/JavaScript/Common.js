// Functions for ticketing to old MAM
var bShownHierarchy = false;
var bShownUserHierarchy = false;

function resizeIt(){}
function resizeHierarchy(){}
function showHierarchy(){}
function showUserHierarchy(){}
function showSearch(bForceLoad){}
function showMenu(){}
function hideHierarchy(){}
function hideUserHierarchy(){}
function hideGuide(){}
function showGuide(){ 
  top.Ext.UI.NewWindowGuide("Error", "ErrorResolution", "/mam/default/dialog/ErrorResolutionRoadmap.asp");
}
function showLastAccounts(){}

function getFrameMetraNet()
{
  if(top.frameMetraNet)
    return top.frameMetraNet;
  else
    return top;  
}

var start = false;

var accountSelectorWin = null;
var accountSelectorWin2 = null;
var lastTarget = '';
var lastTarget2 = '';
var lastFunctionName = '';
var lastFunctionName2 = '';
var helpwin = null;
var oldurl = null;
var desktopwin = null;

function getSelection(functionName, target)
{
  Ext.UI.ShowAccountSelector(functionName, target);
}

function getMultiSelection(functionName, target)
{
  Ext.UI.ShowMultiAccountSelector(functionName, target);
}

// setSelection - is used to replace drag and drop in the new MetraCare
function setSelection(ids, records, target)
{
    //document.getElementById(target).value = records[0].data.UserName + " (" + records[0].data._AccountID + ")";
	// Using correct setValue method for all Ext.ComboBox controls instead of setting dom.value directly then fire appropriate event.
    if (typeof (cBoxes) != 'undefined') {
        var cmp = cBoxes[target];
        if (cmp != null) {
            cmp.setValue(records[0].data.UserName + " (" + records[0].data._AccountID + ")");
            cmp.fireEvent('selected');
        }
        else {
  document.getElementById(target).value = records[0].data.UserName + " (" + records[0].data._AccountID + ")";
}
    }
    else {
        document.getElementById(target).value = records[0].data.UserName + " (" + records[0].data._AccountID + ")";
    }
}

// setMultiSelection - is used to replace a multi drag and drop in the new MetraCare
function setMultiSelection(ids, records, target)
{
  document.getElementById('Child').value = ids;
  mdm_RefreshDialog(document.getElementById(target));
}

// drag and drop handlers
function handleOnDrag() {
  var srcElementId = event.srcElement.id;
  //alert(window.event.dataTransfer.getData("Text"));
}

function handleOnDrop() {
  var dropID = window.event.dataTransfer.getData("Text");
  var destElementId = event.srcElement.id;

  Ext.Ajax.request({
    url: '/MetraNet/AjaxServices/Hierarchy.aspx?DropID=' + dropID,
    scope: this,
    disableCaching: true,
    callback: function (options, success, response) {
      if (success) {
        var displayName = response.responseText;
        Ext.fly(destElementId).dom.value = displayName;
      }
    }
  });
}

function cancelEvent() {
  window.event.returnValue = false;
}

////////////////////////////////////////////////////////////////////
// Start Ext commands that exist on both viewport and page masters
////////////////////////////////////////////////////////////////////
Ext.onReady(function () {

  // Global Ajax events can be handled on every request!
  Ext.Ajax.on('beforerequest', function (conn, options) {
    // reset timeout
    if(top.resetSessionTimer)
    {
      top.resetSessionTimer();
    }
  }, this);

  // Start the hot key handler 
  try { Ext.UI.GlobalKeyHandler(); } catch (e) { /* todo: make work with grid */ }
});

////////////////////////////////////////////////////////////////////
// Common UI Related Functions
////////////////////////////////////////////////////////////////////
Ext.UI = function () {
    var msgCt;

    function createBox(t, s) {
        return ['<div class="msg">',
                '<div class="x-box-tl"><div class="x-box-tr"><div class="x-box-tc"></div></div></div>',
                '<div class="x-box-ml"><div class="x-box-mr"><div class="x-box-mc"><h3>', t, '</h3>', s, '</div></div></div>',
                '<div class="x-box-bl"><div class="x-box-br"><div class="x-box-bc"></div></div></div>',
                '</div>'].join('');
    }
    return {
        // Load a requested page into an element's innerHTML   (TEST)
        loadPage: function (url, target) {
            Ext.get(target).load({
                url: url,
                callback: function (el, success, response) {
                    if (success) {
                        Ext.UI.msg(TEXT_LOADING, TEXT_SUCCESS_LOADING);
                    } else {
                        Ext.UI.msg(TEXT_LOADING, TEXT_FAILED_LOADING);
                    }
                },
            });
                scripts: true
        },

        startLoading: function (id, msg) {
            Ext.get(id).mask(msg, 'x-mask-loading');
        },

        doneLoading: function (id) {
            Ext.get(id).unmask();
        },

        // Return the short name for a string with elipse...
        shortName: function (name) {
            if (name.length > 15) {
                return String.escape(name.substr(0, 12) + '...');
            }
            return String.escape(name);
        },

        // Display and then hide an animated message box  
        msg: function (title, format) {
            if (!msgCt) {
                msgCt = Ext.DomHelper.insertFirst(document.body, { id: 'msg-div' }, true);
            }
            msgCt.alignTo(document, 't-t');
            var s = String.format.apply(String, Array.prototype.slice.call(arguments, 1));
            var m = Ext.DomHelper.append(msgCt, { html: createBox(title, s) }, true);
            m.slideIn('t').pause(2).ghost("t", { remove: true });
        },

        // Load the Dashboard page
        LoadDashboard: function () {
            getFrameMetraNet().MainContentIframe.location.href = "/MetraNet/Welcome.aspx";
        },

        LoadHelp: function () {
            Ext.UI.NewWindow(TEXT_HELP_TITLE, "HelpWin", helpPage);
        },

        // Load a page to the main iframe
        LoadPage: function (url) {
            getFrameMetraNet().MainContentIframe.location.href = url;
        },

        // Show or hide part of the viewport
        Toggle: function (panel) {
            if (getFrameMetraNet().viewport.items.get(panel).hidden) {
                getFrameMetraNet().viewport.items.get(panel).show();
            }
            else {
                getFrameMetraNet().viewport.items.get(panel).hide();
            }
            getFrameMetraNet().viewport.doLayout();
        },

        // Logout of application session
        Logout: function () {
            var req = Ext.Ajax.request({
                url: "AjaxServices/Logout.aspx",
                method: 'GET',
                scope: this,
                disableCaching: true,
                success: function (result, request) {
					if (selectedLanguage && selectedLanguage != 'undefined')
						document.location.href = 'Login.aspx?l=' + selectedLanguage;
					else
						document.location.href = 'Login.aspx';
                }
            });
        },

            /*
            top.Ext.MessageBox.show({
            title: TEXT_LOGOUT,
            msg: TEXT_LOGOUT_QUESTION,
            buttons: Ext.MessageBox.OKCANCEL,
            fn: function(btn) {
            if (btn == 'ok') {
            var req = Ext.Ajax.request({
            url: "AjaxServices/Logout.aspx",
            method: 'GET',
            scope: this,
            disableCaching: true,
            success: function(result, request) {
            if (result.responseText == "LOGOUT_MAM") {
            var reqOld = Ext.Ajax.request({
            url: "/MAM/Default/Dialog/logout.asp",
            method: 'GET',
            scope: this,
            disableCaching: true,
            success: function(result, request) {
            document.location.href = 'Login.aspx';
            }
            });
            }
            document.location.href = 'Login.aspx';
            }
            });
            }
            },
            animEl: 'elId',
            icon: Ext.MessageBox.QUESTION
            });
            */

        SessionTimeout: function () {
            top.Ext.MessageBox.show({
                title: TEXT_SESSION_TIMEOUT_TITLE,
                msg: TEXT_SESSION_TIMEOUT_TEXT,
                buttons: Ext.MessageBox.OK,
                fn: function (btn) {
                    if (btn == 'ok') {
                        document.location.href = '/MetraNet/Login.aspx';
                    }
                },
                animEl: 'elId',
                icon: Ext.MessageBox.INFO
            });
        },

        SystemError: function (str) {

            var errMessage;
            if ((str != null) &&
          (str !== undefined) &&
          (str != "")) {
                errMessage = str;
            }
            else {
                errMessage = TEXT_ERROR_RECEIVING_DATA;
            }

            top.Ext.MessageBox.show({
                title: TEXT_ERROR,
                msg: errMessage,
                buttons: Ext.MessageBox.OK,
                animEl: 'elId',
                icon: Ext.MessageBox.ERROR
            });
        },

        ShowAccountSelector: function (functionName, target) {
            if (accountSelectorWin == null || accountSelectorWin === undefined ||
             target != lastTarget || functionName != lastFunctionName) {
                accountSelectorWin = new top.Ext.Window({
                    title: TEXT_SELECT_ACCOUNT,
                    width: 450,
                    height: 750,
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
                    html: '<iframe id="accountSelectorWindow" src="/MetraNet/AccountSelector.aspx?multi=false&t=' + target + '&f=' + functionName + '" width="100%" height="100%" frameborder="0" scrolling="no" />'
                });
            }

            if (accountSelectorWin2 != null) {
                accountSelectorWin2.hide();
            }
            lastTarget = target;
            lastFunctionName = functionName;
            accountSelectorWin.show();

            accountSelectorWin.on('close', function () {
                accountSelectorWin = null;
            });

        },



        ShowMultiAccountSelector: function (functionName, target) {
            if (accountSelectorWin2 == null || accountSelectorWin2 === undefined ||
             target != lastTarget2 || functionName != lastFunctionName2) {
                accountSelectorWin2 = new top.Ext.Window({
                    title: TEXT_SELECT_ACCOUNTS,
                    width: 400,
                    height: 700,
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
                    html: '<iframe id="accountSelectorWindow2" src="/MetraNet/AccountSelector.aspx?t=' + target + '&f=' + functionName + '" width="100%" height="100%" frameborder="0" scrolling="no"/>'
                });
            }
            if (accountSelectorWin != null) {
                accountSelectorWin.hide();
            }
            lastTarget2 = target;
            lastFunctionName2 = functionName;
            accountSelectorWin2.show();

            accountSelectorWin2.on('close', function () {
                accountSelectorWin2 = null;
            });
        },



        NewWindow: function (winTitle, id, url) {

            if (helpwin == null) {
                helpwin = new top.Ext.Window({
                    title: winTitle,
                    width: 1100,
                    height: 800,
                    minWidth: 600,
                    minHeight: 400,
                    pageX: 50,
                    pageY: 50,
                    layout: 'fit',
                    plain: true,
                    bodyStyle: 'padding:5px;',
                    buttonAlign: 'center',
                    collapsible: true,
                    resizeable: true,
                    maximizable: true,
                    closeAction: 'hide',
                    html: '<iframe id="' + id + '" src=' + url + ' width="100%" height="100%" frameborder="0" />'
                });
            }
            else {
                helpwin.body.update('<iframe id="' + id + '" src=' + url + ' width="100%" height="100%" frameborder="0" />')
            }
            helpwin.show();

        },

        NewDesktopWindow: function (winTitle, id, url) {

            if (desktopwin == null) {
                desktopwin = new top.Ext.Window({
                    title: winTitle,
                    width: 600,
                    height: 480,
                    minWidth: 300,
                    minHeight: 200,
                    pageX: 50,
                    pageY: 50,
                    layout: 'fit',
                    plain: true,
                    shim: false,
                    bodyStyle: 'padding:5px;',
                    buttonAlign: 'center',
                    collapsible: true,
                    resizeable: true,
                    maximizable: true,
                    closeAction: 'hide',
                    html: '<iframe id="' + id + '" src=' + url + ' width="100%" height="100%" frameborder="0" />'
                });
            }
            else {
                desktopwin.body.update('<iframe id="' + id + '" src=' + url + ' width="100%" height="100%" frameborder="0" />')
            }
            desktopwin.show();

        },

        NewWindowGuide: function (winTitle, id, url) {
            var win = new top.Ext.Window({
                title: winTitle,
                width: 600,
                height: 300,
                minWidth: 300,
                minHeight: 200,
                layout: 'fit',
                plain: true,
                bodyStyle: 'padding:5px;',
                buttonAlign: 'center',
                collapsible: true,
                resizeable: true,
                maximizable: true,
                html: '<iframe id="' + id + '" src=' + url + ' width="100%" height="100%" frameborder="0" />'
            });
            win.show();
        },

        GlobalKeyHandler: function () {

            var map = new Ext.KeyMap(document, [
              {
                  key: [10, 13],
                  ctrl: true,
                  alt: true,
                  fn: function () { alert("Return, ctrl, and alt was pressed"); }
              }, {
                  key: "f",
                  ctrl: true,
                  alt: true,
                  fn: function () {
                      var s = getFrameMetraNet().Ext.get("search");
                      s.highlight();
                      s.focus();
                  }
              }, {
                  key: "g",
                  ctrl: true,
                  alt: true,
                  fn: function () { Account.FindAccount(); }
              }, {
                  key: "d",
                  ctrl: true,
                  alt: true,
                  fn: function () { Ext.UI.LoadDashboard(); }
              }, {
                  key: "1",
                  ctrl: true,
                  alt: true,
                  fn: function () {
                      getFrameMetraNet().Ext.getCmp("tabAcctInfo").setActiveTab(0);
                  }
              }, {
                  key: "2",
                  ctrl: true,
                  alt: true,
                  fn: function () {
                      getFrameMetraNet().Ext.getCmp("tabAcctInfo").setActiveTab(1);
                  }
              }, {
                  key: "3",
                  ctrl: true,
                  alt: true,
                  fn: function () {
                      getFrameMetraNet().Ext.getCmp("tabAcctInfo").setActiveTab(2);
                  }
              }, {
                  key: "4",
                  ctrl: true,
                  alt: true,
                  fn: function () {
                      getFrameMetraNet().Ext.getCmp("tabAcctInfo").setActiveTab(3);
                  }
              }, {
                  key: "h",
                  ctrl: true,
                  alt: true,
                  fn: function () { Ext.UI.LoadHelp(); }
              }, {
                  key: "l",
                  ctrl: true,
                  alt: true,
                  fn: function () { Ext.UI.Logout(); }
              }, {
                  key: "m",
                  ctrl: true,
                  alt: true,
                  fn: function () { Ext.UI.Toggle("west-panel"); }
              }, {
                  key: "a",
                  ctrl: true,
                  alt: true,
                  fn: function () {
                      getFrameMetraNet().Ext.getCmp("tabAcctInfo").setActiveTab(2);
                  }
              }, {
                  key: "c",
                  ctrl: true,
                  alt: true,
                  fn: function () { Ext.UI.Toggle("east-panel"); }
              }
          ]);
        }

    };
} ();

// If you need some text to see how something looks
Ext.UI.shortBogusMarkup = '<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Sed metus nibh, sodales a, porta at, vulputate eget, dui. Pellentesque ut nisl. Maecenas tortor turpis, interdum non, sodales non, iaculis ac, lacus. Vestibulum auctor, tortor quis iaculis malesuada, libero lectus bibendum purus, sit amet tincidunt quam turpis vel lacus. In pellentesque nisl non sem. Suspendisse nunc sem, pretium eget, cursus a, fringilla vel, urna.';
Ext.UI.bogusMarkup = '<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Sed metus nibh, sodales a, porta at, vulputate eget, dui. Pellentesque ut nisl. Maecenas tortor turpis, interdum non, sodales non, iaculis ac, lacus. Vestibulum auctor, tortor quis iaculis malesuada, libero lectus bibendum purus, sit amet tincidunt quam turpis vel lacus. In pellentesque nisl non sem. Suspendisse nunc sem, pretium eget, cursus a, fringilla vel, urna.<br/><br/>Aliquam commodo ullamcorper erat. Nullam vel justo in neque porttitor laoreet. Aenean lacus dui, consequat eu, adipiscing eget, nonummy non, nisi. Morbi nunc est, dignissim non, ornare sed, luctus eu, massa. Vivamus eget quam. Vivamus tincidunt diam nec urna. Curabitur velit.</p>';

// Set Ext blank image
Ext.BLANK_IMAGE_URL = '/Res/Ext/resources/images/default/s.gif';

////////////////////////////////////////////////////////////////////
// Cookie Management
////////////////////////////////////////////////////////////////////
var Cookies = {};
Cookies.set = function(name, value){
     var argv = arguments;
     var argc = arguments.length;
     var expires = (argc > 2) ? argv[2] : null;
     var path = (argc > 3) ? argv[3] : '/';
     var domain = (argc > 4) ? argv[4] : null;
     var secure = (argc > 5) ? argv[5] : false;
     if(expires == null)
     {
        var futureDate = new Date();
        var futDateTicks = futureDate.getTime() + 1000 * 60 * 60 * 24 * 30;//a month from now
        futureDate.setTime(futDateTicks);
        expires = futureDate;
     }
     
     document.cookie = name + "=" + escape (value) +
       ((expires == null) ? "" : ("; expires=" + expires.toGMTString())) +
       ((path == null) ? "" : ("; path=" + path)) +
       ((domain == null) ? "" : ("; domain=" + domain)) +
       ((secure == true) ? "; secure" : "");
};

Cookies.get = function(name){
	var arg = name + "=";
	var alen = arg.length;
	var clen = document.cookie.length;
	var i = 0;
	var j = 0;
	while(i < clen){
		j = i + alen;
		if (document.cookie.substring(i, j) == arg)
			return Cookies.getCookieVal(j);
		i = document.cookie.indexOf(" ", i) + 1;
		if(i == 0)
			break;
	}
	return null;
};

Cookies.clear = function(name) {
  if(Cookies.get(name)){
    document.cookie = name + "=" +
    "; expires=Thu, 01-Jan-70 00:00:01 GMT";
  }
};

Cookies.getCookieVal = function(offset){
   var endstr = document.cookie.indexOf(";", offset);
   if(endstr == -1){
       endstr = document.cookie.length;
   }
   return unescape(document.cookie.substring(offset, endstr));
};



////////////////////////////////////////////////////////////////////
// Server Side State Management
////////////////////////////////////////////////////////////////////

var ServerState = {};

// Clears the state on the server asyncronously
ServerState.set = function(name, value){
  if(name == "")
    return;
  
  var parameters = {Name: name, Value: value, Action : "set"}; 

  // make the call back to the server
  Ext.Ajax.request({
      url: '/MetraNet/AjaxServices/ServerState.aspx',
      params: parameters,
      scope: this,
      disableCaching: true,
      callback: function(options, success, response) {
        if (success) {
          if(response.responseText == "OK") {
            // everything is good
          }    
          else
          {
            //Ext.UI.msg("Error Setting State", "Error setting " + name + " to " + value );
          }
        }
        else
        {
          //Ext.UI.msg("Error Setting State", "Error setting " + name + " to " + value );
        }
      }
   });
};

// Get state with the given name off the server.
// The callback function will be called with the response.responseText containing 
// the state value.
// The callback signature is: function(options, success, response)
ServerState.get = function(name, cb){
  if(name == "")
    return;
    
  var parameters = {Name: name, Value: "", Action : "get"}; 

  // make the call back to the server
  Ext.Ajax.request({
      url: '/MetraNet/AjaxServices/ServerState.aspx',
      params: parameters,
      scope: this,
      disableCaching: true,
      callback: cb
   });
};

// Clears the state on the server asyncronously
ServerState.clear = function(name) {
  var parameters = {Name: name, Value: value, Action : "clear"}; 

  // make the call back to the server
  Ext.Ajax.request({
      url: '/MetraNet/AjaxServices/ServerState.aspx',
      params: parameters,
      scope: this,
      disableCaching: true,
      callback: function(options, success, response) {
        if (success) {
          if(response.responseText == "OK") {
            // everything is good
          }    
          else
          {
            //Ext.UI.msg("Error Clearing State", "Error clearing " + name);
          }
        }
        else
        {
           //Ext.UI.msg("Error Clearing State", "Error clearing " + name);
        }
      }
   });
  };

  var checkTimeOut;
  var oldUrl = null;

  /* 
  Check that document in inner frame is loaded or this function is called by onPageLoad event in document in inner frame (forceClose == true).
  In this case hide mask and interrupt checking loop. Otherwise call this function again after small timeout.
  */
  function checkInnerFrameLoading(forceClose) {
    var f = document.getElementById('MainContentIframe');
    var el = document.getElementById('hideAllDiv');
    try {
      if (forceClose || oldUrl == null || f.contentDocument.readyState == "complete" || (f.contentDocument.readyState != "loading" && f.contentWindow.location.href != oldUrl)) {
        if (el) {
          el.style.display = 'none';
          clearTimeout(checkTimeOut);
          oldUrl = null;
        }
      } else {
        checkTimeOut = setTimeout('checkInnerFrameLoading(false)', 1000);
      }
    } catch (e) {
      if (el) {
        /* 
        In case of error hide mask and interrupt checking loop. Probably there is external site url in inner frame.
        */
        el.style.display = 'none';
        clearTimeout(checkTimeOut);
        oldUrl = null;
      }
    }
  }

  /**
  * Masks the main MetraNet document window to disable all UI actions while document in inner frame is in "loading" state.
  */
  function reloadInnerFrame() {
    var f = document.getElementById('MainContentIframe');
    if (f && f.contentWindow) {
      oldUrl = f.contentWindow.location.href;
      var elm = document.getElementById('hideAllDivMsg');
      if (elm) {
        var el = document.getElementById('hideAllDiv');
        if (el) {
          el.style.display = 'block';
          checkTimeOut = setTimeout('checkInnerFrameLoading(false)', 1000);
        }
        elm.innerHTML = '<DIV STYLE="z-index: 32000">' + TEXT_LOADING + '</DIV>';
        elm.style.position = 'absolute';
        var t = document.body.clientHeight / 2 - elm.clientHeight / 2;
        var l = document.body.clientWidth / 2 - elm.clientWidth / 2;
        elm.style.top = t + 'px';
        elm.style.left = l + 'px';
      }
    }
  }

  Ext.onReady(
    function() {
      checkFrameLoading();
    });

  function checkFrameLoading() {
    var t = getFrameMetraNet();
    if (t && t.checkInnerFrameLoading !== undefined) {
      t.checkInnerFrameLoading(true);
    }
    if (window.opener && window.opener.top && window.opener.top.checkInnerFrameLoading !== undefined) {
      window.opener.top.checkInnerFrameLoading(true);
    }
  }

  window.addEventListener(
    'beforeunload', 
    function() {
      var t = getFrameMetraNet();
      if (t && t.reloadInnerFrame !== undefined) {
        t.reloadInnerFrame();
      }
    },
    true
  );
