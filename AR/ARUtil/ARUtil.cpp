#include "StdAfx.h"
#include "ARUtil.h"
#include "ARShared.h"
#include <string>
#include <mtcomerr.h>
#include <ConfigDir.h>
#include <XMLParser.h>


using std::wstring;
using std::string;


#define AR_XSL_DOC_PATH           "\\AR\\config\\AR\\MTARInterface\\RowsetXMLToARDoc.xsl"


// loads the XSL document that transforms an ADO recordset's XML to the AR interface format
//  <ARDocuments> with an <ARDocument> per row
MSXML2::IXMLDOMDocumentPtr ARUtil::LoadRowsetTransformXSL(const _bstr_t& aARDocumentType )
{
  MSXML2::IXMLDOMDocumentPtr xslDoc(AR_DOMDOC_PROGID);

  string docPath;
  
  try
  {
    GetExtensionsDir(docPath);
    docPath += AR_XSL_DOC_PATH; 

    
    if (!xslDoc->load(docPath.c_str()))
    { MT_THROW_COM_ERROR("Can not load xml document");
    }

    // style sheet generates <ARDocumentType> elements be default,
    // change it to generate elements with name aARDocumentType instead
    MSXML2::IXMLDOMNodePtr node = xslDoc->selectSingleNode("//*[@name = 'ARDocumentType']");
    node->attributes->item[0]->text = aARDocumentType;
  }
  catch(_com_error& err)
  {
    MT_THROW_COM_ERROR( L"LoadRowsetTransformXSL() failed to load: %S: [%X] %s",
                        docPath.c_str(), err.Error(), (const wchar_t*) err.Description());
  }

  return xslDoc;
}


// Converts rowset to an XML document of the following form:
//   <ARDocuments>
//     <ARDocument>
//       <aARDocumentType>
//         <col1>value1</col1>
//         <col2>value2</col2>
//       </aARDocumentType>
//     </ARDocument>
//     <ARDocument>
//       <aARDocumentType>
//         <col1>value1</col1>
//         <col2>value2</col2>
//       </aARDocumentType>
//     </ARDocument>
//   </ARDocuments>
// aARDocumentType is passed in.
// aMaxItems is the maximum number of items to add.
// The rowset is assumed to be positioned at the first row, when the
// function returns the rowset will be positioned at the row after the
// last item included or EOF
_bstr_t ARUtil::ConvertRowsetToARDocument( ROWSETLib::IMTSQLRowsetPtr aRowset, //IN OUT
                                           const _bstr_t& aARDocumentType, //IN
                                           long    aMaxItems) //IN
{
	XMLWriter xmlWriter;
	xmlWriter.SetPrettyPrint(TRUE);

  xmlWriter.OutputOpeningTag("ARDocuments");
  
  for (long numItems = 0;
       numItems < aMaxItems && ! aRowset->GetRowsetEOF().boolVal;
       numItems ++)
  {
    xmlWriter.OutputOpeningTag("ARDocument");
    xmlWriter.OutputOpeningTag(aARDocumentType);
    
    //iterate over all columns
    long numColumns = aRowset->Count;
    for (long iCol = 0; iCol < numColumns; iCol++)
    {
      _variant_t varValue = aRowset->GetValue(iCol);

      //convert variant based on type
      _bstr_t bstrValue;
      switch (varValue.vt)
      {
        case VT_NULL:
        case VT_EMPTY:
          bstrValue = "";
          break;

        case VT_DATE:
        {
          time_t tmValue;
          DATE dateValue = varValue;
          ::TimetFromOleDate(&tmValue, dateValue);

           string str;
          ::MTFormatISOTime(tmValue, str);
          bstrValue = str.c_str();
          break;
        }

        default:
          //use the default variant conversion
          bstrValue = varValue;
          break;
      }

      _bstr_t strColName = aRowset->GetName(iCol);

      // convert bstr into an XML string (wstring) so that
      // OutputSimpleAggregate writes multibyte chars
      XMLString xmlStr = bstrValue;
      
      xmlWriter.OutputSimpleAggregate(strColName, xmlStr);
    }

    xmlWriter.OutputClosingTag(aARDocumentType);
    xmlWriter.OutputClosingTag("ARDocument");

    aRowset->MoveNext();
  }

  xmlWriter.OutputClosingTag("ARDocuments");

	const char * buffer;
	int len;
	xmlWriter.GetData(&buffer, len);
	return _bstr_t(buffer);
}


