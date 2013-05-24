<%@ Page Language="C#" MasterPageFile="/MetraNet/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="ux_rss_View" Title="Untitled Page" CodeFile="View.aspx.cs" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

    <script type="text/javascript" src="TabCloseMenu.js"></script>
    <script type="text/javascript" src="FeedViewer.js"></script>
    <script type="text/javascript" src="FeedWindow.js"></script>
    <script type="text/javascript" src="FeedGrid.js"></script>
    <script type="text/javascript" src="MainPanel.js"></script>
    <script type="text/javascript" src="FeedPanel.js"></script>
    <link rel="stylesheet" type="text/css" href="feed-viewer.css" />
    
    <div class="CaptionBar">
      <asp:Label ID="Label1" runat="server" Text="Feeds"></asp:Label>
    </div>
  
    <div id="header"><div style="float:right;margin:5px;" class="x-small-editor"></div></div>

    <!-- Template used for Feed Items -->
    <textarea id="preview-tpl" style="display:none;">
        <div class="post-data">
            <span class="post-date">{pubDate:date("M j, Y, g:i a")}</span>
            <h3 class="post-title">{title}</h3>
            <h4 class="post-author">by {author:defaultValue("Unknown")}</h4>
        </div>
        <div class="post-body">{content:this.getBody}</div>
    </textarea>
    
</asp:Content>

