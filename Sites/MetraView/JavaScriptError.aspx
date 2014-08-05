<%@ Page Language="C#" AutoEventWireup="true" CodeFile="JavaScriptError.aspx.cs" Inherits="MetraNet.JavaScriptError" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
  <head>
      <title>JavaScript is disabled</title>
  </head>
  <body>
    <link href="/Res/Styles/mtpanel.css?v=6.5" rel="stylesheet" type="text/css" />
    <link href="/Res/Styles/Styles.css?v=6.5" rel="stylesheet" type="text/css" />
    <div id="LoginDiv" class="transparent-container borders-on shadow-on rounded-lg">
      <div>
        <img alt="MetraNet" height="100" width="400" src="/Res/Images/Header/metranet_Logo_Web.png"
          style="display: block; margin: 0 auto;">
      </div>
      <div class="clsWelcomeTitle">
        <div class="x-panel-btns-ct">
          <div class="x-panel-btns x-panel-btns-center">
            <%=GetLocalResourceObject("ERROR_TEXT") %>
          </div>
        </div>
      </div>
      <a href="http://www.enable-javascript.com/"><%=GetLocalResourceObject("HOWTO_TEXT") %></a>
    </div>
  </body>
</html>
