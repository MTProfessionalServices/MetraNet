#ifndef __ARUTIL_H_
#define __ARUTIL_H_

#import <msxml4.dll>
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 

class ARUtil
{
public:
  static MSXML2::IXMLDOMDocumentPtr LoadRowsetTransformXSL(const _bstr_t& aARDocumentType );
  
  static _bstr_t ConvertRowsetToARDocument( ROWSETLib::IMTSQLRowsetPtr aRowset,
                                            const _bstr_t& aARDocumentType,
                                            long    aMaxItems);
};

#endif