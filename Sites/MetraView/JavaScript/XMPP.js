Ext.namespace("Ext.ux");

Ext.ux.XMPP = function(username, password, server) {

  var username = username;
  var password = password;
  var http_base = "http-bind";
  var server = server;

  // Handle Messages
  function handleMessage(aJSJaCPacket) {
    if (aJSJaCPacket.getBody().htmlEnc() != "") {

      var msg = "";
      try {
        msg = Ext.util.JSON.decode(aJSJaCPacket.getBody());

        switch (msg.MessageId) {
          case "TIME_MESSAGE": // for testing
            toast(aJSJaCPacket.getFromJID(), msg.CurrentTime);
            break;

          case "INFO_MESSAGE":
            //toast(msg.Label, msg.Info);
            events.fireEvent('INFO_MESSAGE', msg.Info);
            break;

          default:
            toast(aJSJaCPacket.getFromJID(), aJSJaCPacket.getBody().htmlEnc());
            break;
        }

      }
      catch (err) {
        toast(aJSJaCPacket.getFromJID(), aJSJaCPacket.getBody().htmlEnc());
        return;
      }

    }
  }


  function handleIQ(aIQ) {
    oDbg.log(aIQ.xml().htmlEnc());
    con.send(aIQ.errorReply(ERR_FEATURE_NOT_IMPLEMENTED));
  }


  function handlePresence(aJSJaCPacket) {
    var html = '<div class="msg">';
    if (!aJSJaCPacket.getType() && !aJSJaCPacket.getShow())
      html += '<b>' + aJSJaCPacket.getFromJID() + ' has become available.</b>';
    else {
      html += '<b>' + aJSJaCPacket.getFromJID() + ' has set his presence to ';
      if (aJSJaCPacket.getType())
        html += aJSJaCPacket.getType() + '.</b>';
      else
        html += aJSJaCPacket.getShow() + '.</b>';
      if (aJSJaCPacket.getStatus())
        html += ' (' + aJSJaCPacket.getStatus().htmlEnc() + ')';
    }
    html += '</div>';

    //toast("Presence", html);
    oDbg.log(html);
  }

  function handleError(e) {
    oDbg.log("Code: " + e.getAttribute('code') + "\nType: " + e.getAttribute('type') + "\nCondition: " + e.firstChild.nodeName);

    if (con.connected())
      con.disconnect();
  }

  function handleStatusChanged(status) {
    oDbg.log("status changed: " + status);
  }

  function handleConnected() {
    toast("Connected", "Connected to messaging server...");

    con.send(new JSJaCPresence());
  }

  function handleDisconnected() {

  }

  function handleIqVersion(iq) {
    con.send(iq.reply([
                       iq.buildNode('name', 'MetraNet Desktop'),
                       iq.buildNode('version', JSJaC.Version),
                       iq.buildNode('os', navigator.userAgent)
                       ]));
    return true;
  }

  function handleIqTime(iq) {
    var now = new Date();
    con.send(iq.reply([iq.buildNode('display',
                                    now.toLocaleString()),
                       iq.buildNode('utc',
                                    now.jabberDate()),
                       iq.buildNode('tz',
                                    now.toLocaleString().substring(now.toLocaleString().lastIndexOf(' ') + 1))
                       ]));
    return true;
  }

  function doLogin() {
    try {
      // setup args for contructor
      var oArgs = new Object();
      oArgs.httpbase = http_base;
      oArgs.timerval = 2000;

      if (typeof (oDbg) != 'undefined')
        oArgs.oDbg = oDbg;

      if (true)
        con = new JSJaCHttpBindingConnection(oArgs);
      else
        con = new JSJaCHttpPollingConnection(oArgs);

      setupCon(con);

      // setup args for connect method
      oArgs = new Object();
      oArgs.domain = server;
      oArgs.username = username;
      oArgs.resource = 'MetraNet_Desktop_' + new Ext.ux.GUID();
      oArgs.pass = password;
      oArgs.register = false;
      con.connect(oArgs);
    } catch (e) {
      oDbg.log(e.toString());
    } finally {
      return false;
    }
  }

  function setupCon(con) {
    con.registerHandler('message', handleMessage);
    con.registerHandler('presence', handlePresence);
    con.registerHandler('iq', handleIQ);
    con.registerHandler('onconnect', handleConnected);
    con.registerHandler('onerror', handleError);
    con.registerHandler('status_changed', handleStatusChanged);
    con.registerHandler('ondisconnect', handleDisconnected);

    con.registerIQGet('query', NS_VERSION, handleIqVersion);
    con.registerIQGet('query', NS_TIME, handleIqTime);
  }

  this.sendMsg = function(sendTo, msg) {
    if (sendTo == '' || msg == '')
      return false;

    if (sendTo.indexOf('@') == -1)
      sendTo += '@' + con.domain;

    try {
      var aMsg = new JSJaCMessage();
      aMsg.setTo(new JSJaCJID(sendTo));
      aMsg.setBody(msg);
      con.send(aMsg);

      msg = '';

      return false;
    } catch (e) {
      oDbg.log(e.message);
      return false;
    }
  }

  function quit() {
    var p = new JSJaCPresence();
    p.setType("unavailable");
    con.send(p);
    con.disconnect();
  }

  this.init = function() {
    if (typeof (Debugger) == 'function') {
      oDbg = new Debugger(2, 'simpleclient');
      oDbg.start();
    } else {
      // if you're using firebug or safari, use this for debugging
      //oDbg = new JSJaCConsoleLogger(2);
      // comment in above and remove comments below if you don't need debugging
      oDbg = function() { };
      oDbg.log = function() { };
    }


    try { // try to resume a session
      if (JSJaCCookie.read('btype').getValue() == 'binding')
        con = new JSJaCHttpBindingConnection({ 'oDbg': oDbg });
      else
        con = new JSJaCHttpPollingConnection({ 'oDbg': oDbg });

      setupCon(con);

      if (con.resume()) {

      }
      else {

      }
    } catch (e) { } // reading cookie failed - never mind

    doLogin();
  }

  onerror = function(e) {
    oDbg.log(e);

    if (con && con.connected())
      con.disconnect();
    return false;
  };

  onunload = function() {
    if (typeof con != 'undefined' && con && con.connected()) {
      // save backend type
      if (con._hold) // must be binding
        (new JSJaCCookie('btype', 'binding')).write();
      else
        (new JSJaCCookie('btype', 'polling')).write();
      if (con.suspend) {
        con.suspend();
      }
    }
  };


};