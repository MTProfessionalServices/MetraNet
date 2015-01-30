<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >
  <xsl:template match="/">
    
    <xsl:for-each select="/priceableitems">
      <div class="clsFindTab">
      <table class="NavigationPaneItem" border="0" cellpadding="0" cellspacing="0" width="270px">

      <xsl:choose>
      <xsl:when test="count(priceableitem) &gt; 0">
        <!--<tr class="NavigationPaneItem"><td style="color:darkblue;font-size:10px;padding-left:4px;padding-top:4px;">This Price List contains rates or configuration information for the following items</td></tr>-->
        <xsl:for-each select="priceableitem">
          <tr class="NavigationPaneItem"><td style="padding-left:4px;padding-top:4px;"><xsl:apply-templates select="." /><br /></td></tr>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
                <tr class="NavigationPaneItem"><td style="padding-left:4px;padding-top:4px;">[TEXT_PO_WITHOUT_PI_MESSAGE3]</td></tr>
      </xsl:otherwise>
      </xsl:choose>
      </table> <!-- End Of Product Offering -->
     </div>       
    </xsl:for-each>
  
  </xsl:template>
 
 
 
 
  <xsl:template match="priceableitem">
  <table border="0" cellspacing="0" cellpadding="0">
    <tr class="NavigationPaneItem">
      <xsl:attribute name="title"><xsl:value-of select="description" /></xsl:attribute>
      <td class="NavigationPaneItem" style="text-align:left;" colspan="2">
        <!--<a class="NavigationPaneItemA">
        <xsl:attribute name="href">javascript:NavigateToItem(<xsl:value-of select="id" />,<xsl:value-of select="kind" />);</xsl:attribute>-->
        <img src="/mcm/default/localized/en-us/images/Icons/sectionContract.gif" alt="" border="0" align="absmiddle">
          <xsl:attribute name="id">img:<xsl:value-of select="id" /></xsl:attribute>
          <xsl:attribute name="onClick">ToggleRow('row:<xsl:value-of select="id" />', 'img:<xsl:value-of select="id" />');</xsl:attribute>
        </img>
<!--   <xsl:choose>
  <xsl:when test="@kind='40'">
        <img src="/mcm/default/localized/en-us/images/productcatalog/discount.gif" alt="" border="0" align="absmiddle" />
  </xsl:when>
  <xsl:otherwise> -->
        <img alt="" border="0" align="absmiddle">
          <xsl:attribute name="src">/ImageHandler/images/productcatalog/priceableitem/<xsl:value-of select="kind"/>/<xsl:call-template name="EscapeForImageHandler">
          <xsl:with-param name="path" select="name" />
        </xsl:call-template>/priceableitem.gif</xsl:attribute>
        </img>
<!--   </xsl:otherwise>
  </xsl:choose>  --> 
        <xsl:value-of select="displayname" />
       </td>
    </tr>
    
    <TR>
      <xsl:attribute name="id">row:<xsl:value-of select="id" /></xsl:attribute>
		  <TD colspan="2">
        <TABLE>            
    <xsl:for-each select="parametertables">
       <xsl:apply-templates select="." />
    </xsl:for-each> 
        
    <xsl:for-each select="priceableitems/priceableitem">
      <xsl:sort select="displayname"/>
        <tr>
          <td style="padding-left:15px;" colspan="2"><xsl:apply-templates select="." /></td>
        </tr>
    </xsl:for-each>

    </TABLE></TD></TR>
    
    </table>
  </xsl:template>
  
  
  
  <xsl:template match="parametertables">
      <tr><td colspan="2">
      <table class="clsTable" cellspacing="1" cellpadding="0" border="0">
        <xsl:for-each select="parametertable">
          <xsl:apply-templates select="." />
        </xsl:for-each>
      </table>
      </td></tr>
  </xsl:template>

  <xsl:template match="parametertable">
    <tr><td style="padding-left:5px;" >&#160;</td>
      <td nowrap="">
        <input name="SelectedParamTable" type="radio">
          <xsl:attribute name="value"><xsl:value-of select="id" /></xsl:attribute>
          <xsl:attribute name="onClick">javascript:onParamTableSelected(<xsl:value-of select="id" />,<xsl:value-of select="../../id" />,this);</xsl:attribute>
        </input>
    <!--<xsl:choose>
    
       <xsl:when test="contains(paramtable_displayname, 'xxxRules')">
        <img src="/mcm/default/localized/en-us/images/productcatalog/condition.gif" alt="" border="0" align="absmiddle" />
       </xsl:when>
       <xsl:when test="contains(paramtable_displayname, 'xxParameters')">
        <img src="/mcm/default/localized/en-us/images/productcatalog/condition.gif" alt="" border="0" align="absmiddle" />
       </xsl:when>
       <xsl:when test="contains(paramtable_displayname, 'xxxBand')">
        <img src="/mcm/default/localized/en-us/images/productcatalog/condition.gif" alt="" border="0" align="absmiddle" />
       </xsl:when>       
       <xsl:when test="contains(paramtable_displayname, 'xxxCalendar')">
        <img src="/mcm/default/localized/en-us/images/productcatalog/calendar.gif" alt="" border="0" align="absmiddle" />
       </xsl:when>
  <xsl:otherwise>-->
        <img alt="" border="0" align="absmiddle">
          <xsl:attribute name="src">/ImageHandler/images/productcatalog/paramtable/<xsl:call-template name="EscapeForImageHandler">
          <xsl:with-param name="path" select="name" />
        </xsl:call-template>/paramtable.gif</xsl:attribute>
        </img>
  <!--</xsl:otherwise>
  </xsl:choose>--> 
         
                     
        <xsl:value-of select="displayname" />
        
      
            
      </td>
    </tr>  
  </xsl:template>

<xsl:template name="EscapeForImageHandler">
   <xsl:param name="path" />
   <xsl:variable name="quot">"</xsl:variable>
   <xsl:variable name="apos">'</xsl:variable>
   <xsl:value-of select="translate(translate(translate($path, '.:&amp;', '___'), $apos, '_'), $quot, '_')" />
</xsl:template>
   
  
</xsl:stylesheet>