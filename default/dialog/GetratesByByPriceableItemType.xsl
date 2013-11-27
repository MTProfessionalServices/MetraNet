<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl">
 
  <xsl:template match="/">
   <TABLE border="0" cellpadding="1" cellspacing="0" width="100%">
     <tr>
       <td Class="CaptionBar">View All Rates By Priceable Item Type</td>
     </tr>
   </TABLE>
    
    <!-- Apply PriceableItemType Template -->
    <xsl:for-each select="/rates/PriceableItemType">
      <xsl:apply-templates select="." />
    </xsl:for-each>

  </xsl:template>

    <!-- PriceableItemType Template -->
    <xsl:template match="PriceableItemType">
      <table width="100%">
        <tr>
          <td class="clsRateText"><b><xsl:value-of select="name" /></b></td>
        </tr>
      </table>
      <table width="100%">
        <tr>
          <td width="5"></td>
          <td>
            <!-- Apply pt Template -->
            <xsl:for-each select="parameterTable">
              <xsl:apply-templates select="." />
            </xsl:for-each>
						<!-- Apply pi Template -->
						<xsl:for-each select="PriceableItemType">
							<xsl:apply-templates select="." />
						</xsl:for-each>
					</td>
        </tr>
      </table>
    </xsl:template>
      

  <!-- Parameter Table Template -->
  <xsl:template match="parameterTable">
    <table width="100%">
      <tr>
        <td class="clsRateTableTextEven"><xsl:value-of select="name" /></td>
      </tr>
    </table>
    
    <table width="100%">
      <tr>
        <td width="5"></td>
        <td>
          <!-- Apply Rate Schedule Template -->
          <xsl:for-each select="rateSchedule">
            <xsl:apply-templates select="." />
          </xsl:for-each>
        </td>
      </tr>
    </table>    

  </xsl:template>
  
  <!-- Rate Schedule Template -->
  <xsl:template match="rateSchedule">
    <table width="100%">
      <tr>
        <td class="clsRateTableTextOdd"><xsl:value-of select="PriceListName" /> - <xsl:value-of select="name" /></td>
      </tr>
    </table>

    <table width="100%">
      <tr>
        <td width="5"></td>
        <td>
        <!-- Apply Rates Template -->
          <xsl:for-each select="configdata">
            <xsl:apply-templates select="." />
          </xsl:for-each>
          
         <!-- Apply Calendar Template --> 
          <xsl:for-each select="Calendar">
            <xsl:apply-templates select="." />
          </xsl:for-each>          
        </td>
      </tr>
    </table>    
  </xsl:template>
    
  <!-- Rates Template -->
  <xsl:template match="configdata">
    <table cellpadding="2" cellspacing="2" border="0">
      
      <!-- Apply constraint_set -->
      <xsl:for-each select="constraint_set">
        <xsl:apply-templates select="." />
      </xsl:for-each>
      
      <!-- Apply default actions -->
      <xsl:for-each select="default_actions">
        <xsl:apply-templates select="." />
      </xsl:for-each>
            
    </table>      
  </xsl:template>  
  
  <!-- default actions Template -->
  <xsl:template match="default_actions">
      

      <xsl:for-each select="action">
      <tr>      
        <td class="clsRateTableText" align="right"><xsl:value-of select="prop_name" /></td>
        <td class="clsRateTableText" align="right">
            <xsl:eval>myFormat(this.selectSingleNode('prop_value').text);</xsl:eval>
        </td>
      </tr>        
      </xsl:for-each>

  </xsl:template>
  

  <!-- Constraint Set Template -->
  <xsl:template match="constraint_set">
      
      <xsl:if expr="CheckNumber(this)">
        <!-- Conditions / Actions Headers -->
        <tr>
          <td class="clsRateConstraintTableHeader" align="right"><xsl:attribute name="colspan"><xsl:eval>GetConditionsSpan(this)</xsl:eval></xsl:attribute>Conditions</td>
          <td class="clsRateConstraintTableHeader" align="right"><xsl:attribute name="colspan"><xsl:eval>GetActionsSpan(this)</xsl:eval></xsl:attribute>Actions</td>
        </tr>
  
        <tr>
          <xsl:for-each select="constraint">
            <td class="clsRateTableSubHeader" align="right"><xsl:value-of select="prop_name" /></td>
          </xsl:for-each>
          <xsl:for-each select="actions/action">
            <td class="clsRateTableSubHeader" align="right"><xsl:value-of select="prop_name" /></td>
          </xsl:for-each>
        </tr>
      </xsl:if>
      
      <!-- Properties -->
      <tr>
        <xsl:for-each select="constraint">
          <td class="clsRateTableText" align="right"><xsl:value-of select="condition" /> <xsl:value-of select="prop_value" /></td>
        </xsl:for-each>

        <xsl:for-each select="actions/action">
          <td class="clsRateTableText" align="right">
            <xsl:eval>myFormat(this.selectSingleNode('prop_value').text);</xsl:eval>
          </td>
        </xsl:for-each>
      </tr>


  </xsl:template>
	
		  <!-- Calendar Template -->
  <xsl:template match="Calendar">
    <table cellpadding="2" cellspacing="2" border="0">
			<tr>
				<td class="clsRateConstraintTableHeader">Name</td>
				<td class="clsRateConstraintTableHeader">Description</td>
			</tr>
			<tr>
      	<!-- Name -->
      	<td class="clsRateTableText" align="right"><xsl:value-of select="name" /></td>
      	<td class="clsRateTableText" align="right"><xsl:value-of select="description" /></td>      
    	</tr>
		</table>      
  </xsl:template>  
 
  <xsl:script><![CDATA[
    function GetConditionsSpan(objNode) {
      var objNodeList;
      
      objNodeList = objNode.selectNodes("constraint");

      return(objNodeList.length);
    }
    
    function GetActionsSpan(objNode) {
      var objNodeList;
      
      objNodeList = objNode.selectNodes("actions/action");

      return(objNodeList.length);
    }    
    
    function CheckNumber(objNode) {
      if(childNumber(objNode) == 1)
        return(true);
      else
        return(false);
        
    }		
		
		function myFormat(strText) {
		
			if (strText == '') {
				return('');
			}
			else if (isNaN(strText)) {
         return(strText);
      }
			else { 
      	return(formatNumber(strText, '###,##0.00'));
			}
    }

		    

  ]]></xsl:script>
</xsl:stylesheet>
