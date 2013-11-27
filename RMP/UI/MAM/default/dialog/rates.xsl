<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl">

  <xsl:template match="/">
    <!-- <table>
      <tr>
         <td class="clsRateText" align="right">Account ID:</td>     
        <td class="clsRateText" align="left"><xsl:value-of select="/rates/accountID" /></td>
      </tr>
    </table>
    -->
    <!-- Apply Subscription Template -->
    <xsl:for-each select="/rates/subscription">
      <xsl:apply-templates select="." />
    </xsl:for-each>

    <!-- Apply Group Subscription Template -->
    <xsl:for-each select="/rates/groupsubscription">
      <xsl:apply-templates select="." />
    </xsl:for-each>
    
     <!-- Default Pricelist Caption -->
    <xsl:for-each select="/rates/defaultpricelist">
       <table width="100%">
        <tr>
          <td class="clsRateCaptionBar"><xsl:value-of select="." /></td>
        </tr>
       </table>  
    </xsl:for-each>
    
    <!-- Apply Default Pricelist Template -->
    <xsl:for-each select="/rates/Default">
      <xsl:apply-templates select="." />
    </xsl:for-each>
    
         
  </xsl:template>
    
<!-- Default Pricelist Template -->
  <xsl:template match="Default">
    <table width="100%">
      <tr>
        <td class="clsRateText">Default:  <xsl:value-of select="name" /></td>
      </tr>
    </table>
    <table width="100%">
      <tr>
        <td width="5"></td>
        <td>
          <!-- Apply Parameter Table Template -->
          <xsl:for-each select="parameterTable">
            <xsl:apply-templates select="." />
          </xsl:for-each>
        </td>
      </tr>
    </table>
  </xsl:template>
        
  <!-- Subscription Template -->  
  <xsl:template match="subscription">
    <table width="100%">
      <tr>
        <td class="clsRateCaptionBar"><xsl:value-of select="name" /></td>
      </tr>
    </table>

    <table width="100%">
      <tr>
        <td width="5"></td>
        <td>
          <!-- Apply Priceable Item Template -->
          <xsl:for-each select="priceableItem">
            <xsl:apply-templates select="." />
          </xsl:for-each>    
        </td>
     </tr>
    </table>
  </xsl:template>

  <!-- Group Subscription Template -->  
  <xsl:template match="groupsubscription">
    <table width="100%">
      <tr>
        <td class="clsRateCaptionBar">
          <xsl:value-of select="name" /><BR />
          <span class="clsRateCaptionBarSubText">
            Group Subscription: <xsl:value-of select="groupdesc" /> 
            <xsl:value-of select="start" /> - <xsl:value-of select="end" />
          </span>
        </td>
      </tr>
    </table>

    <table width="100%">
      <tr>
        <td width="5"></td>
        <td>
          <!-- Apply Priceable Item Template -->
          <xsl:for-each select="priceableItem">
            <xsl:apply-templates select="." />
          </xsl:for-each>    
        </td>
     </tr>
    </table>
  </xsl:template>
  
<!-- Priceable Item Template -->
  <xsl:template match="priceableItem">
    <table width="100%">
      <tr>
        <td class="clsRateText"><xsl:value-of select="name" /></td>
      </tr>
    </table>
    <table width="100%">
      <tr>
        <td width="5"></td>
        <td>
          <!-- Apply Parameter Table Template -->
          <xsl:for-each select="parameterTable">
            <xsl:apply-templates select="." />
          </xsl:for-each>
   
          <!-- Apply Priceable Item Template -->
          <xsl:for-each select="priceableItem">
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
