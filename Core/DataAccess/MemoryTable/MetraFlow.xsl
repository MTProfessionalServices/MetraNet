<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- This is just a temporary comment to test win32ext Mercurial extension -->
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 
<xsl:template match="/">
  <html>
  <body>
  <h1>MetraFlow Operators</h1>

  <h2>Operators by Category</h2>
  <table cellpadding="10">
    <tr>
      <td valign="top">
        <b>Database Interface</b><br/>
        <a href="#select">select</a><br/>
        <a href="#insert">insert</a><br/>
        <a href="#sql_exec_direct">sql_exec_direct</a><br/>
        <a href="#id_generator">id_generator</a><br/>
      </td>
      <td valign="top">
        <b>File Interface</b><br/>
        <a href="#sequential_file_delete">sequential_file_delete</a><br/>
        <a href="#sequential_file_rename">sequential_file_rename</a><br/>
        <a href="#sequential_file_scan">sequential_file_scan</a><br/>
        <a href="#sequential_file_write">sequential_file_write</a><br/>
        <a href="#import">import</a><br/>
        <a href="#export">export</a><br/>
      </td>
      <td valign="top">
        <b>Queue Interface</b><br/>
        <a href="#import_queue">import_queue</a><br/>
        <a href="#export_queue">export_queue</a><br/>
      </td>
      <td valign="top">
        <b>Rating Related</b><br/>
        <a href="#account_lookup">account_lookup</a><br/>
        <a href="#usageIntervalResolution">usageIntervalResolution</a><br/>
        <a href="#subscription_lookup">subscription_lookup</a><br/>
        <a href="#rate_schedule_lookup">rate_schedule_lookup</a><br/>
        <a href="#parameter_table_lookup">parameter_table_lookup</a><br/>
        <a href="#writeProductView">writeProductView</a><br/>
        <a href="#meter">meter</a><br/>
        <a href="#load_error">load_error</a><br/>
      </td>
      <td valign="top">
        <b>Record Descriptions</b><br/>
        <a href="#usageRecord">Usage Record</a><br/>
        <a href="#subscriberRecord">Subscription Record</a><br/>
        <a href="#childUsageEventRecord">ChildUsageEvent Record</a><br/>
      </td>
    </tr>
    <tr>
      <td valign="top">
        <b>Relational Operations</b><br/>
        <a href="#inner_hash_join">inner_hash_join</a><br/>
        <a href="#inner_merge_join">inner_merge_join</a><br/>
        <a href="#multi_hash_join">multi_hash_join</a><br/>
        <a href="#right_merge_anti_semi_join">right_merge_anti_semi_join</a><br/>
        <a href="#right_merge_semi_join">right_merge_semi_join</a><br/>
        <a href="#right_outer_hash_join">right_outer_hash_join</a><br/>
        <a href="#right_outer_merge_join">right_outer_merge_join</a><br/>
      </td>
      <td valign="top">
        <b>Sequential Processing</b><br/>
        <a href="#hash_running_total">hash_running_total</a><br/>
        <a href="#sort_running_total">sort_running_total</a><br/>
        <a href="#sort_merge">sort_merge</a><br/>
        <a href="#union_all">union_all</a><br/>
        <a href="#unroll">unroll</a><br/>
      </td>
      <td valign="top">
        <b>Aggregation</b><br/>
        <a href="#hash_group_by">hash_group_by</a><br/>
        <a href="#sort_group_by">sort_group_by</a><br/>
      </td>
      <td valign="top">
        <b>Miscellaneous</b><br/>
        <a href="#project">project</a><br/>
        <a href="#rename">rename</a><br/>
        <a href="#sort">sort</a><br/>
        <a href="#assert_sort_order">assert_sort_order</a><br/>
        <a href="#print">print</a><br/>
        <a href="#devNull">devNull</a><br/>
      </td>
    </tr>
    <tr>
      <td valign="top">
        <b>Expression</b><br/>
        <a href="#expr">expr</a><br/>
        <a href="#generate">generate</a><br/>
        <a href="#filter">filter</a><br/>
      </td>
      <td valign="top">
        <b>Partitioning</b><br/>
        <a href="#hash_part">hash_part</a><br/>
        <a href="#rangepart">rangepart</a><br/>
        <a href="#coll">coll</a><br/>
        <a href="#sort_merge_coll">sort_merge_coll</a><br/>
        <a href="#broadcast">broadcast</a><br/>
      </td>
      <td valign="top">
        <b>Branching</b><br/>
        <a href="#copy">copy</a><br/>
        <a href="#switch">switch</a><br/>
        <a href="#union_all">union_all</a><br/>
      </td>
      <td valign="top">
        <b>Parent/Child (Multipoint)</b><br/>
        <a href="#sort_nest">sort_nest</a><br/>
        <a href="#unnest">unnest</a><br/>
        <a href="#inner_merge_join">inner_merge_join</a><br/>
        <a href="#right_outer_merge_join">right_outer_merge_join</a><br/>
        <a href="#meter">meter</a><br/>
      </td>
    </tr>
  </table>

  <h2>Alphabetic Operator Index</h2>
<xsl:for-each select="operators/operator">
  <a href="#{metraflowname}">
  <xsl:value-of select="metraflowname"/>
</a>
  <br/>
</xsl:for-each>

    <xsl:for-each select="operators/operator">
      <hr/>
      <font color="#0000ff"><h1>
      <a name="{metraflowname}">
        <xsl:value-of select="metraflowname"/>
      </a>
    </h1>
  </font>
      <xsl:value-of select="description"/>

      <p/>
<table width="576" cellpadding="5" cellspacing="0" border="0" style="border-collapse:collapse">

<tr align="left" valign="top">
  <td bgcolor="#D5E2F1" align="center" style = "border:1px solid #BFBFBF;" colspan="5" width="582"><p class="bodytextcentered"><strong class="strong"><h2>Arguments</h2></strong></p>
</td>
</tr>

<tr align="left" valign="top">
  <td bgcolor="#9EC8F4" style = "border:1px solid #BFBFBF;" ><b>Name</b>
</td>
<td bgcolor="#9EC8F4" style = "border:1px solid #BFBFBF;" ><b>Type</b>
</td>
<td bgcolor="#9EC8F4" style = "border:1px solid #BFBFBF;" ><b>Repeatable</b>
</td>
<td bgcolor="#9EC8F4" style = "border:1px solid #BFBFBF;" width="306"><b>Description</b>
</td>
</tr>

<xsl:for-each select="argument">
<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" ><xsl:value-of select="argname"/>
</td>
<td style = "border:1px solid #BFBFBF;" ><xsl:value-of select="argtype"/>
</td>
<td style = "border:1px solid #BFBFBF;" >
  <xsl:choose>
    <xsl:when test="contains(argunlimited, 'true')">
      yes
    </xsl:when>
    <xsl:otherwise>
      no
    </xsl:otherwise>
  </xsl:choose>
</td>
<td style = "border:1px solid #BFBFBF;" width="306"><xsl:value-of select="argdescription"/>
  <xsl:if test="value">
     Acceptable values are: 
     <xsl:for-each select="value">
          "<xsl:value-of select="."/>"
             <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
     </xsl:for-each>

  </xsl:if>
  <xsl:choose>
    <xsl:when test="argvalue">
      <p/> Acceptable Values:
     </xsl:when>
  </xsl:choose>
  <table cellpadding="5" cellspacing="0" border="1" style="border-collapse:collapse">
    <xsl:for-each select="argvalue">
	    <tr><td><font color="#0000ff"><xsl:value-of select="argvaluename"/> </font></td>
		    <td><xsl:value-of select="argvaluedescription"/></td>
	    </tr>
    </xsl:for-each>
  </table>
</td>
</tr>
    </xsl:for-each>

</table>

<p/>

<table width="576" cellpadding="5" cellspacing="0" border="0" style="border-collapse:collapse">
<tr align="left" valign="top">
  <td bgcolor="#D5E2F1" align="center" style = "border:1px solid #BFBFBF;" colspan="5" width="582"><p class="bodytextcentered"><strong class="strong"><h2>Ports</h2></strong></p>
</td>
</tr>

<tr align="left" valign="top">
  <td bgcolor="#9EC8F4" style = "border:1px solid #BFBFBF;" ><b>Name</b>
</td>
<td bgcolor="#9EC8F4" style = "border:1px solid #BFBFBF;" ><b>Type</b>
</td>
<td bgcolor="#9EC8F4" style = "border:1px solid #BFBFBF;" ><b>Number</b>
</td>
<td bgcolor="#9EC8F4" style = "border:1px solid #BFBFBF;" ><b>Repeatable</b>
</td>
<td bgcolor="#9EC8F4" style = "border:1px solid #BFBFBF;" width="306"><b>Description</b>
</td>
</tr>

<xsl:for-each select="inputs/input">
<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" ><xsl:value-of select="inputname"/>
</td>
<td style = "border:1px solid #BFBFBF;" >input
</td>
<td style = "border:1px solid #BFBFBF;" ><xsl:value-of select="inputnumber"/>
</td>
<td style = "border:1px solid #BFBFBF;" >no
</td>
<td style = "border:1px solid #BFBFBF;" width="306"><xsl:value-of select="inputdescription"/>
  <xsl:choose>
    <xsl:when test="inputfield">
      <p/> Required Input Fields:
     </xsl:when>
  </xsl:choose>
  <table cellpadding="5" cellspacing="0" border="1" style="border-collapse:collapse">
    <xsl:for-each select="inputfield">
	    <tr><td><font color="#0000ff"><xsl:value-of select="inputfieldname"/> </font></td>
		    <td><xsl:value-of select="inputfielddescription"/></td>
	    </tr>
    </xsl:for-each>
  </table>
</td>
</tr>

    </xsl:for-each>

<xsl:for-each select="inputs/inputlimited">
<tr align="left" valign="top">
  <td style = "border:1px solid #BFBFBF;" >
    <xsl:value-of select="inputname"/>(0),
    <xsl:value-of select="inputname"/>(1),
    <xsl:value-of select="inputname"/>(2)...
</td>
<td style = "border:1px solid #BFBFBF;" >input
</td>
<td style = "border:1px solid #BFBFBF;" >*
</td>
<td style = "border:1px solid #BFBFBF;" >yes
</td>
<td style = "border:1px solid #BFBFBF;" >
    <xsl:if test="contains(@singlename, 'true')">
      If there is a single port, the name should be
      <xsl:value-of select="inputname"/>
      (rather than 
      <xsl:value-of select="inputname"/>(0)).

    </xsl:if>
    The number of ports is limited to the number of times the
    <xsl:value-of select="@mustequal"/> 
    <xsl:text></xsl:text>
    argument appears.
    <xsl:value-of select="inputdescription"/>
</td>
</tr>
    </xsl:for-each>

<xsl:for-each select="inputs/inputunbounded">
<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" ><xsl:value-of select="inputname"/>
</td>
<td style = "border:1px solid #BFBFBF;" >input
</td>
<td style = "border:1px solid #BFBFBF;" >*
</td>
<td style = "border:1px solid #BFBFBF;" >yes
</td>
<td style = "border:1px solid #BFBFBF;" >
    <xsl:if test="contains(@singlename, 'true')">
      If there is a single port, the name should be
      <xsl:value-of select="inputname"/>
      (rather than 
      <xsl:value-of select="inputname"/>(0)).

    </xsl:if>
<xsl:value-of select="inputdescription"/>
</td>
</tr>
    </xsl:for-each>

<xsl:for-each select="outputs/output">
<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" ><xsl:value-of select="outputname"/>
</td>
<td style = "border:1px solid #BFBFBF;" >output
</td>
<td style = "border:1px solid #BFBFBF;" ><xsl:value-of select="outputnumber"/>
</td>
<td style = "border:1px solid #BFBFBF;" >no
</td>
<td style = "border:1px solid #BFBFBF;" width="306"><xsl:value-of select="outputdescription"/>
  <xsl:choose>
    <xsl:when test="outputfield">
      <p/> Added Output Fields
     </xsl:when>
  </xsl:choose>
  <table cellpadding="5" cellspacing="0" border="1" style="border-collapse:collapse">
    <xsl:for-each select="outputfield">
	    <tr><td><font color="#0000ff"><xsl:value-of select="outputfieldname"/> </font></td>
		    <td><xsl:value-of select="outputfielddescription"/></td>
	    </tr>
    </xsl:for-each>
  </table>
</td>
</tr>
    </xsl:for-each>

<xsl:for-each select="outputs/outputlimited">
<tr align="left" valign="top">
  <td style = "border:1px solid #BFBFBF;" >
    <xsl:value-of select="outputname"/>(0),
    <xsl:value-of select="outputname"/>(1),
    <xsl:value-of select="outputname"/>(2)...
</td>
<td style = "border:1px solid #BFBFBF;" >output
</td>
<td style = "border:1px solid #BFBFBF;" >*
</td>
<td style = "border:1px solid #BFBFBF;" >yes
</td>
<td style = "border:1px solid #BFBFBF;" >
    <xsl:if test="contains(@singlename, 'true')">
      If there is a single port, the name should be
      <xsl:value-of select="outputname"/>
      (rather than 
      <xsl:value-of select="outputname"/>(0)).

    </xsl:if>
    The number of ports is limited to the number of times the
    <xsl:value-of select="@mustequal"/> 
    <xsl:text></xsl:text>
    argument appears.
    <xsl:value-of select="outputdescription"/>
</td>
</tr>
    </xsl:for-each>

<xsl:for-each select="outputs/outputunbounded">
<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" ><xsl:value-of select="outputname"/>
</td>
<td style = "border:1px solid #BFBFBF;" >output
</td>
<td style = "border:1px solid #BFBFBF;" >*
</td>
<td style = "border:1px solid #BFBFBF;" >yes
</td>
<td style = "border:1px solid #BFBFBF;" >
    <xsl:if test="contains(@singlename, 'true')">
      If there is a single port, the name should be
      <xsl:value-of select="outputname"/>
      (rather than 
      <xsl:value-of select="outputname"/>(0)).

    </xsl:if>
<xsl:value-of select="outputdescription"/>
</td>
</tr>

    </xsl:for-each>

</table>
<xsl:if test="example">
      <font color="#0000ff"><h2>
          Examples</h2>
          <p/>
        </font>
          <xsl:value-of select="example/comment()" disable-output-escaping="yes"/>
      
</xsl:if>
      
    </xsl:for-each>

<hr/>
<a name="usageRecord">
  <font color="#0000ff"><h1>Usage Record</h1></font>
</a>
The Usage Record is used by the usageIntervalResolution operator.
The Usage Record holds an event that occured that will
result in a usage charge.
<table width="576" cellpadding="5" cellspacing="0" border="0" style="border-collapse:collapse">

<tr align="left" valign="top">
  <td bgcolor="#D5E2F1" align="center" style = "border:1px solid #BFBFBF;" colspan="5" width="582"><p class="bodytextcentered"><strong class="strong"><h2>Fields</h2></strong></p>
</td>
</tr>

<tr align="left" valign="top">
<td bgcolor="#9EC8F4" style = "border:1px solid #BFBFBF;" ><b>Name</b>
</td>
<td bgcolor="#9EC8F4" style = "border:1px solid #BFBFBF;" ><b>Type</b>
</td>
<td bgcolor="#9EC8F4" style = "border:1px solid #BFBFBF;" width="306"><b>Description</b>
</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > Timestamp</td>
<td style = "border:1px solid #BFBFBF;" > date</td>
<td style = "border:1px solid #BFBFBF;" > A timestamp used as the effective date for a usage event.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > AccountID</td>
<td style = "border:1px solid #BFBFBF;" > integer</td>
<td style = "border:1px solid #BFBFBF;" > The identifier of the account associated with the usage event.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > PayingAccountID</td>
<td style = "border:1px solid #BFBFBF;" > integer</td>
<td style = "border:1px solid #BFBFBF;" >The identifier of an account with a payer relationship to the account associated with the usage event. </td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > Currency</td>
<td style = "border:1px solid #BFBFBF;" > nvarchar</td>
<td style = "border:1px solid #BFBFBF;" >The units of the Amount property, which holds the ISO code for the currency. (Example value: USD.) </td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > SubscriptionEntity</td>
<td style = "border:1px solid #BFBFBF;" > integer</td>
<td style = "border:1px solid #BFBFBF;" > An optional property that overrides the property set with the resolved subscription ID.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > ProductOfferingID</td>
<td style = "border:1px solid #BFBFBF;" > integer</td>
<td style = "border:1px solid #BFBFBF;" > The identifier of the product offering associated with the usage event.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > PriceableItemInstanceID</td>
<td style = "border:1px solid #BFBFBF;" > integer</td>
<td style = "border:1px solid #BFBFBF;" > The identifier of the priceable item instance associated with the  usage event.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > PriceableItemTemplateID</td>
<td style = "border:1px solid #BFBFBF;" > integer</td>
<td style = "border:1px solid #BFBFBF;" > The identifier of the priceable item template associated the usage event.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > Amount</td>
<td style = "border:1px solid #BFBFBF;" > decimal</td>
<td style = "border:1px solid #BFBFBF;" >The amount calculated by processing the session. (The amount can be negative to represent a credit.) </td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > FedTax</td>
<td style = "border:1px solid #BFBFBF;" > decimal</td>
<td style = "border:1px solid #BFBFBF;" > Federal tax.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > StateTax</td>
<td style = "border:1px solid #BFBFBF;" > decimal</td>
<td style = "border:1px solid #BFBFBF;" > State tax.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > CountyTax</td>
<td style = "border:1px solid #BFBFBF;" > decimal</td>
<td style = "border:1px solid #BFBFBF;" > County tax.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > LocalTax</td>
<td style = "border:1px solid #BFBFBF;" > decimal</td>
<td style = "border:1px solid #BFBFBF;" > Local tax.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > OtherTax</td>
<td style = "border:1px solid #BFBFBF;" > decimal</td>
<td style = "border:1px solid #BFBFBF;" > Other tax.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > IntervalID</td>
<td style = "border:1px solid #BFBFBF;" > integer</td>
<td style = "border:1px solid #BFBFBF;" > The identifier of the usage interval in which the usage was processed.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > SessionID</td>
<td style = "border:1px solid #BFBFBF;" > binary</td>
<td style = "border:1px solid #BFBFBF;" > An internal identifier for a session representing the usage event.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > CollectionID</td>
<td style = "border:1px solid #BFBFBF;" > binary</td>
<td style = "border:1px solid #BFBFBF;" > An internal identifier that can be used as a guide to associate a group of sessions.</td>
</tr>

</table>


<hr/>
<a name="subscriberRecord">
  <font color="#0000ff"><h1>Subscriber Record</h1></font>
</a>
A subscription record contains the details of a subscriber's
subscription to a particular priceable item. Typically, the MetraFlow 
operator subscription_lookup (given a subscriber, priceable item,
date) is used to fill in the fields of this record.
<table width="576" cellpadding="5" cellspacing="0" border="0" style="border-collapse:collapse">

<tr align="left" valign="top">
  <td bgcolor="#D5E2F1" align="center" style = "border:1px solid #BFBFBF;" colspan="5" width="582"><p class="bodytextcentered"><strong class="strong"><h2>Fields</h2></strong></p>
</td>
</tr>

<tr align="left" valign="top">
<td bgcolor="#9EC8F4" style = "border:1px solid #BFBFBF;" ><b>Name</b>
</td>
<td bgcolor="#9EC8F4" style = "border:1px solid #BFBFBF;" ><b>Type</b>
</td>
<td bgcolor="#9EC8F4" style = "border:1px solid #BFBFBF;" width="306"><b>Description</b>
</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > SubscriptionID</td>
<td style = "border:1px solid #BFBFBF;" > integer</td>
<td style = "border:1px solid #BFBFBF;" >Identifier of the subscription used to retrieve the subscription data from the database. </td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > SubscriptionStart</td>
<td style = "border:1px solid #BFBFBF;" > date</td>
<td style = "border:1px solid #BFBFBF;" >A calendar date or the next start date of the payer's billing period. </td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > SubscriptionEnd</td>
<td style = "border:1px solid #BFBFBF;" > date</td>
<td style = "border:1px solid #BFBFBF;" >An optional calendar date or the next end date of the payer's billing period.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > ProductOfferingID</td>
<td style = "border:1px solid #BFBFBF;" > integer</td>
<td style = "border:1px solid #BFBFBF;" >The identifier of the product offering associated with the usage event. </td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > PriceableItemInstanceID</td>
<td style = "border:1px solid #BFBFBF;" > integer</td>
<td style = "border:1px solid #BFBFBF;" > The identifier of the priceable item instance associated with the usage event. </td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > PriceableItemTemplateID</td>
<td style = "border:1px solid #BFBFBF;" > integer</td>
<td style = "border:1px solid #BFBFBF;" >The identifier associated with the priceable item template. </td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > PriceableItemTypeID</td>
<td style = "border:1px solid #BFBFBF;" > integer</td>
<td style = "border:1px solid #BFBFBF;" >The identifier associated with the priceable item type. </td>
</tr>
</table>

<hr/>
<a name="childUsageEventRecord">
  <font color="#0000ff"><h1>ChildUsageEvent Record</h1></font>
</a>
The ChildUsageEvent Record.
<table width="576" cellpadding="5" cellspacing="0" border="0" style="border-collapse:collapse">

<tr align="left" valign="top">
  <td bgcolor="#D5E2F1" align="center" style = "border:1px solid #BFBFBF;" colspan="5" width="582"><p class="bodytextcentered"><strong class="strong"><h2>Fields</h2></strong></p>
</td>
</tr>

<tr align="left" valign="top">
<td bgcolor="#9EC8F4" style = "border:1px solid #BFBFBF;" ><b>Name</b>
</td>
<td bgcolor="#9EC8F4" style = "border:1px solid #BFBFBF;" ><b>Type</b>
</td>
<td bgcolor="#9EC8F4" style = "border:1px solid #BFBFBF;" width="306"><b>Description</b>
</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > PriceableItemInstanceID</td>
<td style = "border:1px solid #BFBFBF;" > integer</td>
<td style = "border:1px solid #BFBFBF;" > The identifier of the priceable item instance associated with the child usage event.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > PriceableItemTemplateID</td>
<td style = "border:1px solid #BFBFBF;" > integer</td>
<td style = "border:1px solid #BFBFBF;" > The identifier of the priceable item template associated the child usage event.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > Amount</td>
<td style = "border:1px solid #BFBFBF;" > decimal</td>
<td style = "border:1px solid #BFBFBF;" >The amount calculated by processing the child session. (The amount can be negative to represent a credit.) </td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > FedTax</td>
<td style = "border:1px solid #BFBFBF;" > decimal</td>
<td style = "border:1px solid #BFBFBF;" > An output property for Federal tax if any on the child usage event.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > StateTax</td>
<td style = "border:1px solid #BFBFBF;" > decimal</td>
<td style = "border:1px solid #BFBFBF;" > An output property for State tax if any on the child usage event.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > CountyTax</td>
<td style = "border:1px solid #BFBFBF;" > decimal</td>
<td style = "border:1px solid #BFBFBF;" > An output property for County tax if any on the child usage event.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > LocalTax</td>
<td style = "border:1px solid #BFBFBF;" > decimal</td>
<td style = "border:1px solid #BFBFBF;" > An output property for Local tax if any on the child usage event.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > OtherTax</td>
<td style = "border:1px solid #BFBFBF;" > decimal</td>
<td style = "border:1px solid #BFBFBF;" > An output property for Other tax if any on the child usage event.</td>
</tr>

<tr align="left" valign="top">
<td style = "border:1px solid #BFBFBF;" > SessionID</td>
<td style = "border:1px solid #BFBFBF;" > binary</td>
<td style = "border:1px solid #BFBFBF;" > An internal identifier for a session representing the child usage event.</td>
</tr>

</table>


  </body>
  </html>
</xsl:template>

</xsl:stylesheet>
