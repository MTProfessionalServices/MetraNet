<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_Messages" CodeFile="Messages.ascx.cs"%>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<div>
 <MT:MTFilterGrid runat="Server" ID="MessagesGrid" ExtensionName="Messaging" TemplateFileName="Messaging.MessageGroup.Message.MetraView">
  </MT:MTFilterGrid>
  </div>