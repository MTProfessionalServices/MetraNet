<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_HeaderInfo" CodeFile="HeaderInfo.ascx.cs" %>
<%@ OutputCache Duration="1200" VaryByParam="none" VaryByCustom="username" shared="true" %>
<strong class="strong-field-label"><%= Resources.Resource.TEXT_ACCOUNT_NAME %></strong> <%= UserName %><br />
<strong class="strong-field-label"><%= Resources.Resource.TEXT_ACCOUNT_NUMBER %></strong> <%= AccountId %>