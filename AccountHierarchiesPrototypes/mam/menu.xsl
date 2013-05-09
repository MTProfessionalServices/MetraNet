<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:mt="http://www.metratech.com" version="1.0">

  <xsl:template match="/hierarchy">
    <table cellspacing="0" cellpadding="0" border="0">
      <tr>
        <td>
          <table cellspacing="0" cellpadding="0" border="0">
            <tr valign="middle">
              <td class="clsMenuRootText" nowrap="true"><img src="images/menu_new_root.gif" /></td>
              <td class="clsMenuRootText">localhost</td>
            </tr>
          </table>
        </td>
      </tr>
      <tr>
        <td>
          <xsl:apply-templates select="entity" />
        </td>
      </tr>
    </table>          
  </xsl:template>
  
  <xsl:template match="entity">
    <table cellspacing="0" cellpadding="0" border="0">
    <xsl:attribute name="id">shadow<xsl:value-of select="id" /></xsl:attribute>
      <tr valign="middle">
        <!-- If a parent, draw the + and - boxes -->
        <xsl:if test="mt:IsFolder(.) = 1">
          <td class="clsMenuGroupText" nowrap="true" width="1%">
            <img>
              <xsl:attribute name="src"><xsl:value-of select="mt:GetMenuConnectorImage(., position())" /></xsl:attribute>
              <xsl:attribute name="id">image<xsl:value-of select="id" /></xsl:attribute>
              <xsl:attribute name="onClick"><xsl:value-of select="mt:GetClickEvent(.)" /></xsl:attribute>
            </img></td>

          <td class="clsMenuGroupText" nowrap="true" width="1%">
            <img>
              <xsl:attribute name="src"><xsl:value-of select="mt:GetIconImage(.)" /></xsl:attribute>
              <xsl:attribute name="id">image<xsl:value-of select="id" />folder</xsl:attribute>
              <xsl:attribute name="onClick"><xsl:value-of select="mt:GetClickEvent(.)" /></xsl:attribute>
            </img></td>

          <td nowrap="true">
            <xsl:if test="@disabled = 'true'">
              <xsl:attribute name="disabled">true</xsl:attribute>
            </xsl:if>

            <xsl:attribute name="class">clsDragDrop</xsl:attribute>
            <xsl:attribute name="dropEvent"><xsl:value-of select="mt:GetDropEvent(.)" /></xsl:attribute>
            <xsl:attribute name="id"><xsl:value-of select="name" /></xsl:attribute>
            <xsl:attribute name="onClick"><xsl:value-of select="mt:GetClickEvent(.)" /></xsl:attribute>
            <xsl:attribute name="dragID"><xsl:value-of select="id" /></xsl:attribute>
            <xsl:attribute name="onMouseDown">SelectMe('<xsl:value-of select="id" />');</xsl:attribute>
            <xsl:attribute name="onMouseOver">window.status='<xsl:value-of select="mt:GetFQN(.)" />';</xsl:attribute>
            <xsl:value-of select="name" /></td>
        </xsl:if>
        <xsl:if test="mt:IsFolder(.) = 0">
          <td class="clsMenuGroupText" nowrap="true" width="1%">
            <img>
              <xsl:attribute name="src"><xsl:value-of select="mt:GetMenuItemConnectorImage(., position())" /></xsl:attribute>
            </img></td>

          <td class="clsMenuGroupText" nowrap="true" width="1%"></td>

          <td nowrap="true" dropEvent="HandleDrop">
            <xsl:if test="@disabled = 'true'">
              <xsl:attribute name="disabled">true</xsl:attribute>
            </xsl:if>
            <xsl:attribute name="class"><xsl:value-of select="mt:GetClass(.)" /></xsl:attribute>
            <xsl:attribute name="id"><xsl:value-of select="name" /></xsl:attribute>
            <xsl:attribute name="dragID"><xsl:value-of select="id" /></xsl:attribute>
            <xsl:attribute name="onMouseDown">SelectMe('<xsl:value-of select="id" />');</xsl:attribute>
            <xsl:attribute name="onMouseOver">window.status='<xsl:value-of select="mt:GetFQN(.)" />';</xsl:attribute>
            <xsl:value-of select="name" /></td>
        </xsl:if>
      </tr>

      <tr class="clsMenuRow">
        <xsl:attribute name="id">row<xsl:value-of select="id" /></xsl:attribute>
        <xsl:if test="mt:IsVisible(.) = 0"><xsl:attribute name="style">display:none</xsl:attribute></xsl:if>

        <td>
          <xsl:attribute name="background"><xsl:value-of select="mt:GetMenuConnectorBackground(., position())" /></xsl:attribute>
        </td>
      <!-- If not a parent, draw the end node -->
        <td colspan="2">
          <xsl:apply-templates select="entity">
            <xsl:sort select="name"/>
          </xsl:apply-templates>
        </td>
      </tr>
    </table>
  </xsl:template>

  <msxsl:script language="JScript" implements-prefix="mt">
  <![CDATA[
    function IsFolder(objTmp) {
      var objNode = objTmp.item(0);
      var objAttr;
      
      objAttr = objNode.attributes.getNamedItem('type')
      if(objAttr == null)
        return(0);
        
      if(objAttr.value.toUpperCase() == 'FOLDER')
        return(1);
      else
        return(0);
    }
    /////////////////////////////////////////////////////////////
    function GetFQN(objTmp) {
      var objNode = objTmp.item(0);
      var strFQN = "";

      if(objNode.parentNode == null)
         return(objNode.selectSingleNode('name').text);

      if(objNode.parentNode.nodeName == 'entity')
        strFQN = GetFQN(objNode.parentNode.selectNodes('.')) + '/' + objNode.selectSingleNode('name').text; 
      else 
        return('/' + objNode.selectSingleNode('name').text);

      return(strFQN);
    }
    /////////////////////////////////////////////////////////////
    function IsParent(objTmp) {
      var objNode = objTmp.item(0);
      var objAttr;

      objAttr = objNode.attributes.getNamedItem('HasChildren');
      
      if(objAttr == null)
        return(0);
        
      if(objAttr.value.toUpperCase() == "FALSE")
        return(0);
      else
        return(true);
    }
    ////////////////////////////////////////////////////////////
    function IsVisible(objTmp) {
      var objNode = objTmp.item(0);
      var objAttr;


      objAttr = objNode.attributes.getNamedItem('visible');
      
      if(objAttr == null)
        return(0);
        
      if(objAttr.value.toUpperCase() == "FALSE")
        return(0);
      else
        return(1);
    }
    /////////////////////////////////////////////////////////////
    function GetMenuConnectorImage(objTmp, intPos) {
      var objNode = objTmp.item(0);
      var objAttr;
      var bVisible;
      var bLast;

      var strPostFix;
      
      bVisible = IsVisible(objTmp)

      if(intPos == objNode.parentNode.selectNodes('entity').length)
        bLast = true;
      else
        bLast = false;
        
      if(bVisible)
        strPostFix = '_minus.gif';
      else
        strPostFix = '_plus.gif';
      
      
      //If this has children, then don't return plusses or minusses
      objAttr = objNode.attributes.getNamedItem('HasChildren');
      
      if(objAttr == null) {
        strPostFix = '.gif';
      } else {
        if(objAttr.value.toUpperCase() == 'FALSE')
          strPostFix = '.gif';
      }
      
      if(bLast)
        return('images/menu_corner' + strPostFix);
      else
        return('images/menu_tee' + strPostFix);
    }
    ////////////////////////////////////////////////////////////
    function GetClickEvent(objTmp) {
      var objNode = objTmp.item(0);    
      var objIDAttr;
      var objIDNode;

      var strVal;
      
      if(objNode.attributes == null)
        return('');
      
      objIDAttr = objNode.attributes.getNamedItem('visible');
      objIDNode = objNode.selectSingleNode('id');
      
      if(objIDNode == null)
        return('');
        
      if(objIDAttr == null)
        strVal = 'false';
      else
        strVal = objIDAttr.value.toLowerCase();
        
      if(strVal == 'true')
        return('UnLoadID("' + objIDNode.text + '");');
      else
        return('LoadID("' + objIDNode.text + '");');
    }
    ///////////////////////////////////////////////////////////
    function GetIconImage(objTmp) {
      var objNode = objTmp.item(0);    
      if(IsVisible(objTmp))
        return('images/menu_folder_open.gif');
      else
        return('images/menu_folder_closed.gif');
    }
    //////////////////////////////////////////////////////////
    function GetClass(objTmp) {
      var objNode = objTmp.item(0);
      var objAttr;
      
      objAttr = objNode.attributes.getNamedItem('highlight');
      
      if(objAttr == null)
        return('clsDrag');
        
      if(objAttr.value == 'true')
        return('clsDragHighlight');
      else
        return('clsDrag');
    }
    //////////////////////////////////////////////////////////
    function GetDropEvent(objTmp) {
      var objNode = objTmp.item(0);    
      return('HandleDrop');
    }
    //////////////////////////////////////////////////////////
    function GetMenuConnectorBackground(objTmp, intPos) {
      var objNode = objTmp.item(0);    

      if(intPos == objNode.parentNode.selectNodes('entity').length)
        return('');
      else
        return('images/menu_bar.gif');
    }
    //////////////////////////////////////////////////////////
    function GetMenuItemConnectorImage(objTmp, intPos) {
      var objNode = objTmp.item(0);    
      if(intPos == objNode.parentNode.selectNodes('entity').length)
        return('images/menu_corner.gif');
      else
        return('images/menu_tee.gif');
    }

  ]]>  
  </msxsl:script>
</xsl:stylesheet>
