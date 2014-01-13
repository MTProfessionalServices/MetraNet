<%
    'SECENG: CORE-4774 CLONE - MSOL BSS 27970 Unauthenticated Info Disclosure on /MOM/help.asp (post-pb)
    Response.Redirect Session("mdm_LOCALIZATION_DICTIONARY").Item("APP_HTTP_PATH") & "/../MetraNetHelp/en-US/index.htm"
%>
