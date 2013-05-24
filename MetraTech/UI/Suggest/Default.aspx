<%@ Page language="c#" Codebehind="Default.aspx.cs" AutoEventWireup="false" Inherits="Suggest.WebForm1" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
  <HEAD>
    <title>Suggest Test Page</title>
    <meta content="Microsoft Visual Studio .NET 7.1" name="GENERATOR">
    <meta content="C#" name="CODE_LANGUAGE">
    <meta content="JavaScript" name="vs_defaultClientScript">
    <meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
  
    <LINK href="/Suggest/Suggest.css" type="text/css" rel="STYLESHEET">
    <script language="JavaScript" src="/Suggest/Suggest.js"></script>
  
  <script>
    function DoFind()
    {
      alert(document.getElementById("keyword1").value);
    }
  </script>
  </HEAD>
  
  <body onload="SuggestLoad();">
  
    <form name="form1">
    
      <table>
        <tr>
          <td>
            Priceable Item:
          </td>
          <td>
            <input name="keyword1" id="keyword1" onkeyup="SendQuery(this, 'QUERY', '__GET_PRICABLE_ITEM_SUGGESTIONS__', '')" style="WIDTH:200px" autocomplete="off">
            <button onclick="SendQueryClick(document.form1.keyword1, 'QUERY', '__GET_PRICABLE_ITEM_SUGGESTIONS__', '');">...</button>
            <img name="suggestLoading_keyword1" id="suggestLoading_keyword1" class="clsSuggestLoading" src="suggest.gif"><br>
            <div name="autocomplete_keyword1" id="autocomplete_keyword1" class="clsSuggestBox" style="WIDTH:200px" align="left"></div>
            <iframe id="DivShim_keyword1" src="javascript:false;" scrolling="no" frameborder="0" style="position:absolute; width:0px; height:0px; top:0px; left:0px; display:none;"></iframe>
          </td>
        </tr>
      </table>
      
    </form>
    
  </body>
</HTML>
