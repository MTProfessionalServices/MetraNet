<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >
  <xsl:template match="/">
    
    <xsl:for-each select="/productoffering">
                    
      <!-- PO Properties -->
      <table class="TabContainer" border="0" cellpadding="0" cellspacing="0">
      <tr> 
        <td width="100%">
          <table width="100%" cellspacing="0" cellpadding="0">
            <td class="NavigationPaneHeader" colspan="1" style="font-size:10;padding-left:8px;">[TEXT_PARAMETER_TABLES_PLM_UPDATED]</td>

          </table>
        </td>
      </tr>

        <tr class="NavigationPaneHeader">
          <td class="" style="font-size:12;font-weight:bold;padding-left:0px;padding-top:5px;">
          <input type="checkbox" name="CheckAll" checked="" onClick="updateAllCheckboxes(this.checked);" />
          <b>
            <span class="NavigationPaneItemA" style="font-size:14;font-weight:bold;">
                  <xsl:value-of select="displayname" />
            </span></b>
          </td>
        </tr>


      <xsl:choose>
      <xsl:when test="count(priceableitems/priceableitem) &gt; 0">
        <xsl:for-each select="priceableitems/priceableitem">
          <tr class="NavigationPaneItem"><td style="padding-left:4px;padding-top:4px;"><xsl:apply-templates select="." /><br /></td></tr>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
                <tr class="NavigationPaneItem"><td style="padding-left:4px;padding-top:4px;">[TEXT_PO_WITHOUT_PI_MESSAGE2]</td></tr>
      </xsl:otherwise>
      </xsl:choose>
      </table> <!-- End Of Product Offering -->
            
    </xsl:for-each>
  
  </xsl:template>
 
 
 
 
  <xsl:template match="priceableitem">
    
    <table border="0" cellspacing="0" cellpadding="0">
    <tr class="NavigationPaneItem">
      <xsl:attribute name="title"><xsl:value-of select="description" /></xsl:attribute>
      <td class="NavigationPaneItem">
        <img alt="" border="0" align="absmiddle">
          <xsl:attribute name="src">/ImageHandler/images/productcatalog/priceableitem/<xsl:value-of select="kind"/>/<xsl:call-template name="EscapeForImageHandler">
          <xsl:with-param name="path" select="name" />
        </xsl:call-template>/priceableitem.gif</xsl:attribute>
        </img>&#160;
        <xsl:value-of select="displayname" />
      </td>
    </tr>
    
    <xsl:for-each select="pricelistmappings">
       <tr><td style="padding-left:15px;" colspan="2"><xsl:apply-templates select="." /></td></tr>
    </xsl:for-each> 
        
    <xsl:for-each select="priceableitems/priceableitem">
      <xsl:sort select="priceableitem/displayname"/>
        <tr><td style="padding-left:20px;" colspan="2"><xsl:apply-templates select="." /></td></tr>
    </xsl:for-each>


    </table>
  </xsl:template>
  
  
  
  <xsl:template match="pricelistmappings">
    <div class="clsDiv">
      <xsl:attribute name="id">div<xsl:value-of select="divid" /></xsl:attribute>
      <table class="clsTable" cellspacing="1" cellpadding="0" border="0">
        <xsl:for-each select="pricelistmapping">
          <xsl:apply-templates select="." />
        </xsl:for-each>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="pricelistmapping">
    <tr>
      <td valign="top">
        <!--<xsl:value-of select="paramtable" />-->
        <input type="checkbox" name="paramtable_selected" checked="">
        <xsl:attribute name="value"><xsl:value-of select="../../id" />~<xsl:value-of select="paramtable_id" /></xsl:attribute>
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
          <xsl:with-param name="path" select="paramtable_name" />
        </xsl:call-template>/paramtable.gif</xsl:attribute>
        </img>
  <!--</xsl:otherwise>
  </xsl:choose>--> 
         
       </td>
       <td>
                        
        <!--[<xsl:value-of select="../../id" />~<xsl:value-of select="paramtable_id" />]-->
        <xsl:value-of select="paramtable_displayname" />
        
        <xsl:if test="allowicb='TRUE'">
        &#160;<img src="/mcm/default/localized/en-us/images/icons/icb_allowed.gif" alt="[TEXT_RATES_CAN_BE_SET]" border="0" align="absmiddle" />
        </xsl:if>
        <xsl:if test="allowicb='FALSE'">
        &#160;<img src="/mcm/default/localized/en-us/images/icons/icb_not_allowed.gif" alt="TEXT_RATES_CANNOT_BE_SET" border="0" align="absmiddle" />
        </xsl:if>
        <br />
        <span style="font-size:10px;color:silver;">
        <img src="/mcm/default/localized/en-us/images/icons/pl_mapping_corner.gif" alt="" border="0" align="absmiddle" />
        <xsl:choose>
          <xsl:when test="not(pricelist_name)">
            <img src="/mcm/default/localized/en-us/images/icons/warningSmall.gif" alt="" border="0" align="absmiddle" />
            [TEXT_PARAMETER_TABLE_NOT_MAPPED]
          </xsl:when>
          <xsl:when test="nonsharedpricelist='FALSE'">
            <xsl:value-of select="pricelist_name" />
          </xsl:when>
          <xsl:otherwise>
            [TEXT_NONSHARED_PRICE_LIST]
          </xsl:otherwise>
        </xsl:choose>     
        </span> 
          
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