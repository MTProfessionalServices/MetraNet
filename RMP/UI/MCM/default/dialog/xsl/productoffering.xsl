<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >
  <xsl:template match="/">
    
    <xsl:for-each select="/productoffering">
                    <a>
                    <xsl:attribute name="href">javascript:NavigateToPreviousSearchResults();</xsl:attribute>
                    [TEXT_RETURN_TO_PREVIOUS_SEARCH]
                    </a>
                    <img src="/MCM/default/localized/en-us/images/Icons/goback.gif" alt="[TEXT_RETURN_TO_PREVIOUS_SEARCH]" border="0" align="absmiddle" style="cursor:hand;">
                    <xsl:attribute name="OnClick">javascript:NavigateToPreviousSearchResults();</xsl:attribute>
                    </img>
      <!-- PO Properties -->
      <br/>
      <div class="clsFindTab">
      <table class="TabContainer" border="0" cellpadding="0" cellspacing="0" width="270px">
      <tr> 
        <td width="100%">
          <table width="100%" cellspacing="0" cellpadding="0">
            <td class="NavigationPaneHeader" colspan="1" style="font-size:10;padding-left:8px;">[TEXT_SELECTED_PO]</td>
            <td class="NavigationPaneHeader" align="right" style='padding-top:4px;'>

              <img src="/MCM/default/localized/en-us/images/Icons/refresh.gif" alt="" border="0" align="bottom" style="cursor:hand;">
                    <xsl:attribute name="OnClick">window.location=window.location</xsl:attribute>
              </img>
            </td>
          </table>
        </td>
      </tr>

      <!--<table border="0" cellspacing="0" cellpadding="0">-->      
        <tr class="NavigationPaneHeader">
          <td class="" style="font-size:12;font-weight:bold;padding-left:4px;padding-top:5px;"><b>
           <a class="NavigationPaneItemA" style="font-size:14;font-weight:bold;">
              <xsl:attribute name="id"><xsl:value-of select="id" /></xsl:attribute>
              <xsl:attribute name="href">javascript:NavigateToItem(<xsl:value-of select="id" />,-1);</xsl:attribute>
              <xsl:value-of select="name" disable-output-escaping="yes" />
            </a></b>
          </td>
        </tr>


      <xsl:choose>
      <xsl:when test="count(priceableitems/priceableitem) &gt; 0">
        <xsl:for-each select="priceableitems/priceableitem">
          <tr class="NavigationPaneItem"><td style="padding-left:4px;padding-top:4px;"><xsl:apply-templates select="." /><br /></td></tr>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
                <tr class="NavigationPaneItem"><td style="padding-left:4px;padding-top:4px;">[TEXT_PO_WITHOUT_PI_MESSAGE]</td></tr>
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
      <td class="NavigationPaneItem" colspan="2">

        <img src="/mcm/default/localized/en-us/images/Icons/sectionContract.gif" alt="" border="0" align="absmiddle">
          <xsl:attribute name="id">img:<xsl:value-of select="id" /></xsl:attribute>
          <xsl:attribute name="onClick">ToggleRow('row:<xsl:value-of select="id" />', 'img:<xsl:value-of select="id" />');</xsl:attribute>
        </img>
              
        <a class="NavigationPaneItemA">
        <xsl:attribute name="href">javascript:NavigateToItem(<xsl:value-of select="id" />,<xsl:value-of select="kind" />);</xsl:attribute>
  <!--<xsl:choose>
  <xsl:when test="@kind='40'">
        <img src="/ImageHandler/images/productcatalog/priceableitem/discount.gif" alt="" border="0" align="absmiddle" />
  </xsl:when>
  <xsl:otherwise>-->
        <img alt="" border="0" align="absmiddle">
          <xsl:attribute name="src">/ImageHandler/images/productcatalog/priceableitem/<xsl:value-of select="kind"/>/<xsl:call-template name="EscapeForImageHandler">
          <xsl:with-param name="path" select="name" />
        </xsl:call-template>/priceableitem.gif</xsl:attribute>
        </img>
  <!--</xsl:otherwise>
  </xsl:choose>-->  
        </a>
        
        <a class="NavigationPaneItemA">
        <xsl:attribute name="href">javascript:NavigateToItem(<xsl:value-of select="id" />,<xsl:value-of select="kind" />);</xsl:attribute>
        <xsl:attribute name="id"><xsl:value-of select="id" /></xsl:attribute>
        <xsl:value-of select="name" />
        </a>
      </td>
    </tr>
 
     <TR>
      <xsl:attribute name="id">row:<xsl:value-of select="id" /></xsl:attribute>
		  <TD colspan="2">
        <TABLE>    
           
          <xsl:for-each select="pricelistmappings">
             <tr><td style="padding-left:15px;" colspan="2"><xsl:apply-templates select="." /></td></tr>
          </xsl:for-each> 
              
          <xsl:for-each select="priceableitems/priceableitem">
            <xsl:sort select="name"/>
              <tr><td style="padding-left:15px;" colspan="2"><xsl:apply-templates select="." /></td></tr>
          </xsl:for-each>
          
         </TABLE>
       </TD>
     </TR>

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
      <td>
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

        
  <xsl:choose>        
   <xsl:when test="not(string(pricelist_id))">
        <a class="ParamTableA">
        <xsl:attribute name="title">[TEXT_PARAMETER_NOT_MAPPED_MESSAGE]</xsl:attribute>
        <xsl:attribute name="href">javascript:alert('TEXT_PARAMETER_NOT_MAPPED_MESSAGE');</xsl:attribute>
       <xsl:value-of select="paramtable_displayname" />
       <xsl:text>&#160;</xsl:text>
       <img src="/mcm/default/localized/en-us/images/icons/warningSmall.gif" alt="" border="0" align="absmiddle" />
          <xsl:attribute name="alt">[TEXT_PARAMETER_NOT_MAPPED_MESSAGE]</xsl:attribute>
        </a> 
                                    
   </xsl:when>
   <xsl:otherwise>                          
        <a class="ParamTableA">
        <xsl:attribute name="id"><xsl:value-of select="paramtable_id" />_<xsl:value-of select="../../id" /></xsl:attribute>
        <xsl:attribute name="title"><xsl:value-of select="paramtable" /></xsl:attribute>
        <xsl:attribute name="href">javascript:NavigateToRates(<xsl:value-of select="paramtable_id" />,<xsl:value-of select="../../id" />);</xsl:attribute>
        <xsl:value-of select="paramtable_displayname" />
        </a> 
   </xsl:otherwise>         
 </xsl:choose>        
            
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