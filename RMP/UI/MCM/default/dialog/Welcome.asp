<%
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<%
Session("HelpContext") = "Welcome.hlp.htm"
%>
<html>
<head>
  <LINK rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH")%>/styles/styles.css">
</head>
<body>
<div class="CaptionBar"><%=FrameWork.GetDictionary("TEXT_APPLICATION_WELCOME")%></div>
<!-- This whole thing needs to support localization and key term substitution.
     Commenting it out until someone has time to do it.

  The MetraTech Catalog Manager application allows you to perform the 
   following tasks:</P>
  <UL>
   <LI CLASS="mvd-P-BulletList">
   <P CLASS="BulletList">
    <SPAN STYLE="font-weight : bold;"><B><FONT COLOR="BLACK">Search for 
    Catalog Manager Data</FONT></B></SPAN> &#151; You can search for Catalog 
    Manager data, such as:</P>
   </UL>
  <P>
   <TABLE WIDTH="100%" CELLPADDING="2" CELLSPACING="0" BORDER="0">
    <TR>
     <TD WIDTH="9%" VALIGN=TOP>&nbsp;</TD>
     <TD WIDTH="91%" VALIGN=TOP>
      <UL>
       <LI CLASS="mvd-P-BulletList">
       <P CLASS="BulletList">
        <SPAN STYLE="font-weight : bold;"><B>Rating Information</B></SPAN> &#151; <SPAN STYLE="font-weight : normal;">Locate
         rates associated with different priceable items, product offerings, and price lists.</SPAN></P>
       <LI CLASS="mvd-P-BulletList">
       <P CLASS="BulletList">
        <SPAN STYLE="font-weight : bold;"><B>Product Offering Properties</B></SPAN> 
        &#151; <SPAN STYLE="font-weight : normal;">View properties for 
        specific product offerings, including associated priceable items, 
        effective and available start dates, end dates, subscriber 
        self-subscription and unsubscription.</SPAN></P>
       <LI CLASS="mvd-P-BulletList">
       <P CLASS="BulletList">
        <SPAN STYLE="font-weight : bold;"><B>Priceable Item Properties</B></SPAN> 
        &#151; <SPAN STYLE="font-weight : normal;">View properties for 
        specific priceable items, including date cycle information and 
        triggering events.</SPAN></P>
       <LI CLASS="mvd-P-BulletList">
       <P CLASS="BulletList">
        <SPAN STYLE="font-weight : bold;"><B>Discount Properties</B></SPAN> &#151;<SPAN STYLE="font-weight : normal;"> 
        View properties for specific discounts, including date cycle 
        information and counter types and properties.</SPAN></TD>
    </TR>
   </TABLE></P>
  <UL>
   <LI CLASS="mvd-P-BulletList">
   <P CLASS="BulletList">
    <SPAN STYLE="font-weight : bold;"><B><FONT COLOR="BLACK">Add a New 
    Product Offering</FONT></B></SPAN> &#151; You can add a new product 
    offering to the MetraTech Catalog Manager system. </P>
   <LI CLASS="mvd-P-BulletList">
   <P CLASS="BulletList">
    <SPAN STYLE="font-weight : bold;"><B><FONT COLOR="BLACK">Add a New 
    Priceable Item</FONT></B></SPAN><FONT COLOR="BLACK"> </FONT>&#151; You 
    can add a new priceable item to the MetraTech Catalog Manager system. </P>
   <LI CLASS="mvd-P-BulletList">
   <P CLASS="BulletList">
    <SPAN STYLE="font-weight : bold;"><B><FONT COLOR="BLACK">Add a New Discount</FONT></B></SPAN> 
    &#151; You can add a new discount to the MetraTech Catalog Manager system. A discount is a line item on 
    a bill that reduces the total amount of a subscriber's bill. Discount 
    templates can be created in Discounts.</P>
   <LI CLASS="mvd-P-BulletList">
   <P CLASS="BulletList">
    <SPAN STYLE="font-weight : bold;"><B><FONT COLOR="BLACK">Edit Rate Schedules</FONT></B></SPAN><FONT COLOR="BLACK"> </FONT>&#151;
     You can add/change rates associated with different priceable items, 
    product offerings, and price lists.</P>
   <LI CLASS="mvd-P-BulletList">
   <P CLASS="BulletList">
    <SPAN STYLE="font-weight : bold;"><B><FONT COLOR="BLACK">Edit Calendar 
    Parameter Tables </FONT></B></SPAN>&#151; You can add/change dates and 
    times in that have been entered into different categories in calendar
     parameter tables.</P>
   <LI CLASS="mvd-P-BulletList">
   <P CLASS="BulletList">
    <SPAN STYLE="font-weight : bold;"><B><FONT COLOR="BLACK">Edit 
    Non-Rate-Schedule Parameter Tables</FONT></B></SPAN> &#151; You can 
    add/change rules in parameter tables that write information to the database that is not 
    immediately rate-related.</P>
   </UL>
-->
</body>
</html>
