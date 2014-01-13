<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_ThemeIncludes" CodeFile="ThemeIncludes.ascx.cs" %>
<link rel="stylesheet" type="text/css" href="/Res/Ext/resources/css/xtheme-gray.css?v=6.5" />
<link href="<%= Request.ApplicationPath %>/Styles/common.css?v=6.5" rel="stylesheet" type="text/css" />
<link href="<%= Request.ApplicationPath %>/Styles/<%= GetTheme() %>.css" rel="stylesheet" type="text/css" />