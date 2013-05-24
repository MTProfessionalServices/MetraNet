#ifndef __IMPORTER_H__
#define __IMPORTER_H__

#include <boost/format.hpp>

#include "ImportFunction.h"

// The following for import spec parsing 
#include <sstream>
#include "LogAdapter.h"
#include "RecordFormatLexer.hpp"
#include "RecordFormatParser.hpp"
#include "RecordFormatTreeParser.hpp"
#include "RecordFormatGenerator.hpp"
#include "AST.hpp"
#include "CommonAST.hpp"
#include "ASTFactory.hpp"
#include "TokenStreamHiddenTokenFilter.hpp"
#include "CommonHiddenStreamToken.hpp"
#include "Token.hpp"

template <class _InputBuffer>
class UTF8_Import_Function_Builder_2 : public Import_Function_Builder, public Record_Metadata_Builder
{
public:
  typedef fastdelegate::FastDelegate2< 
    _InputBuffer &,
    record_t,
    ParseDescriptor::Result> importer_delegate;
 
  typedef fastdelegate::FastDelegate0<void> delete_delegate;

private:
  // Our importers
  typedef Direct_Field_Importer_2<ISO8601_DateTime_2, _InputBuffer> iso8601_importer;
  typedef Direct_Field_Importer_2<DateString_DateTime_2, _InputBuffer> date_time_importer;
  typedef Direct_Field_Importer_2<UTF8_Base10_Signed_Integer_Int32_2, _InputBuffer> base10_int32_importer;
  typedef Direct_Field_Importer_2<UTF8_Base10_Signed_Integer_Int64_2, _InputBuffer> base10_int64_importer;
  typedef Direct_Field_Importer_2<UTF8_Base10_Decimal_DECIMAL_2, _InputBuffer> base10_decimal_importer;
  typedef Field_Action_Importer_2<UTF8_Terminated_UTF8_Null_Terminated_2, _InputBuffer, Set_Value_Action_Type> varchar_importer;
  typedef Field_Action_Importer_2<UTF8_Terminated_UTF16_Null_Terminated_2, _InputBuffer, Set_Value_Action_Type> nvarchar_importer;
  typedef Field_Action_Importer_2<ISO_8859_1_Terminated_UTF16_Null_Terminated_2, _InputBuffer, Set_Value_Action_Type> iso_8859_1_nvarchar_importer;
  typedef Direct_Field_Importer_2<UTF8_Terminated_Enum_2, _InputBuffer> enum_importer;
  typedef Direct_Field_Importer_2<UTF8_String_Literal_Terminated_Boolean_2, _InputBuffer> boolean_importer;
  typedef Direct_Field_Importer_2<UTF8_Fixed_Length_Hex_Binary_2, _InputBuffer> binary_importer;

  typedef UTF8_Nullable_Terminated_Field_Importer_2<iso8601_importer> nullable_iso8601_importer;
  typedef UTF8_Nullable_Terminated_Field_Importer_2<date_time_importer> nullable_date_time_importer;
  typedef UTF8_Nullable_Terminated_Field_Importer_2<base10_int32_importer> nullable_base10_int32_importer;
  typedef UTF8_Nullable_Terminated_Field_Importer_2<base10_int64_importer> nullable_base10_int64_importer;
  typedef UTF8_Nullable_Terminated_Field_Importer_2<base10_decimal_importer> nullable_base10_decimal_importer;
  typedef UTF8_Nullable_Terminated_Field_Importer_2<varchar_importer> nullable_varchar_importer;
  typedef UTF8_Nullable_Terminated_Field_Importer_2<nvarchar_importer> nullable_nvarchar_importer;
  typedef UTF8_Nullable_Terminated_Field_Importer_2<iso_8859_1_nvarchar_importer> nullable_iso_8859_1_nvarchar_importer;
  typedef UTF8_Nullable_Terminated_Field_Importer_2<enum_importer> nullable_enum_importer;
  typedef UTF8_Nullable_Terminated_Field_Importer_2<boolean_importer> nullable_boolean_importer;
  typedef UTF8_Nullable_Terminated_Field_Importer_2<binary_importer> nullable_binary_importer;

  typedef Field_Action_Importer_2<UTF8_String_Literal_UTF8_Null_Terminated_2, _InputBuffer, Nop_Action_Type> delimiter_importer;
 
  Import_Format_Error_Sink& mOp;
  std::vector<boost::uint8_t *> mBuffers;
  boost::uint8_t * mBuffer;
  boost::uint8_t * mBufferEnd;

  std::vector<importer_delegate> mImporters;
  std::vector<delete_delegate> mDelete;
  
  RecordMetadata mMetadata;
  LogicalRecord mMetadataMembers;
  MetraFlowLoggerPtr mLogger;

  void get_buffer(std::size_t sz, boost::uint8_t *& ptr)
  {
    // Check to see if we need a new chunk.
    if (mBuffer + sz > mBufferEnd)
    {
      mBuffers.push_back(new boost::uint8_t [sz < 1024 ? 1024 : sz]);
      mBuffer = mBuffers.back();
      mBufferEnd = mBuffers.back() + (sz < 1024 ? 1024 : sz);
    }
    // Guaranteed success.
    ASSERT(mBuffer + sz <= mBufferEnd);
    ptr = mBuffer;
    mBuffer += sz;
  }
public:

  UTF8_Import_Function_Builder_2(Import_Format_Error_Sink& op,
                                 const std::wstring& importSpec)
    :
    mOp(op),
    mBuffer(NULL),
    mBufferEnd(NULL)
  {
    mLogger = MetraFlowLoggerManager::GetLogger("[RecordImport]");

    std::string utf8Format;
    ::WideStringToUTF8(importSpec, utf8Format);
    std::stringstream importStream(utf8Format);

    RecordFormatLexer lexer(importStream);
    lexer.setTokenObjectFactory(&antlr::CommonHiddenStreamToken::factory);
    lexer.setLog(mLogger);
  
    antlr::TokenStreamHiddenTokenFilter filter(lexer);
    filter.hide(RecordFormatParser::WS);
    filter.hide(RecordFormatParser::SL_COMMENT);
    filter.hide(RecordFormatParser::ML_COMMENT);
  
    RecordFormatParser parser(filter);
    antlr::ASTFactory ast_factory;
    parser.initializeASTFactory(ast_factory);
    parser.setASTFactory(&ast_factory);
    parser.setLog(mLogger);
    parser.setNumFields(0);
    try
    {
      parser.program();
    } 
    catch (antlr::ANTLRException& antlrException) 
    {
      mLogger->logError(antlrException.toString());
      mOp.ThrowError(L"Importer Specification error");
    }

    if (parser.getHasError())
    {
      mOp.ThrowError(L"Importer Specification error");
    }

    // Set builder iterator
    RecordFormatTreeParser analyze;
    analyze.initializeASTFactory(ast_factory);
    analyze.setASTFactory(&ast_factory);
    analyze.setLog(mLogger);
    analyze.setBuilder(this);
    try
    {
      analyze.program(parser.getAST());
    } 
    catch (antlr::ANTLRException& antlrException) 
    {
      mLogger->logError(antlrException.toString());
      mOp.ThrowError(L"Importer Specification error");
    }
    if (analyze.getHasError())
    { 
      mOp.ThrowError(L"Importer Specification error");
    }  
    mMetadata = RecordMetadata(mMetadataMembers);

    // Reset builder iterator
    RecordFormatGenerator generate;
    generate.initializeASTFactory(ast_factory);
    generate.setASTFactory(&ast_factory);
    generate.setLog(mLogger);
    generate.setBuilder(this);
    try
    {
      generate.program(parser.getAST());
    } 
    catch (antlr::ANTLRException& antlrException) 
    {
      mLogger->logError(antlrException.toString());
      mOp.ThrowError(L"Importer Specification error");
    }
    if (generate.getHasError())
    { 
      mOp.ThrowError(L"Importer Specification error");
    }
  }

  ~UTF8_Import_Function_Builder_2()
  {
    // Call "destructors" on importers.
    for(std::vector<delete_delegate >::iterator it = mDelete.begin();
        it != mDelete.end();
        ++it)
    {
      (*it)();
    }

    for(std::vector<boost::uint8_t *>::iterator it = mBuffers.begin();
        it != mBuffers.end();
        ++it)
    {
      delete [] (*it);
    }
  }

  record_t Import(_InputBuffer & input, std::string& outErrMessage)
  {
    record_t recordBuffer = mMetadata.Allocate();
    for(std::vector<importer_delegate>::iterator it = mImporters.begin();
        it != mImporters.end();
        ++it)
    {
      ParseDescriptor::Result r = (*it)(input, recordBuffer);
      if (r != ParseDescriptor::PARSE_OK)
      {
        // Return in OUT parameter outErrMessage an error message
        // describing where the parsing error occurred in the record.
        // For debugging, include a "window" around the failure point.
        std::string buf((char *)input.buffer()+(input.size() >= 10 ? input.size()-10 : 0), 
                        (char *)input.buffer()+(input.size()+10<=input.capacity() ? input.size()+10 : input.capacity()));

        // Replace any newlines in buf with '\\n' to prevent outErrMessage from getting split across multiple lines.
        std::string bufOneLine(buf);
        std::string fromSubstr("\r\n");
        std::string toSubstr("\\n");
        size_t start_pos = 0;
        while((start_pos = bufOneLine.find(fromSubstr, start_pos)) != std::string::npos) {
          bufOneLine.replace(start_pos, fromSubstr.length(), toSubstr);
          start_pos += toSubstr.length(); // In case 'toSubstr' contains 'fromSubstr', like replacing 'x' with 'yx'
        }

        outErrMessage = 
          (boost::format("A MetraFlow parsing error occurred at FIELD: %1% (1-based), "
                         "in or near this portion of text: \"%2%\".  "
                         "Try comparing the format parameter of the MetraFlow script with "
                         "the format of this record and field in the input file to find the exact error.  "
                         "Parsed output so far: [%3%]")
            % ((it-mImporters.begin())/2 + 1)
            % bufOneLine
            % mMetadata.PrintMessage(recordBuffer)
           ).str();

        mMetadata.Free(recordBuffer);
        return NULL;
      }
    }
    return recordBuffer;
  }

  void add_base_type(const std::wstring& fieldName,
                     const std::string& baseType, 
                     bool isRequired,
                     const std::string& nullValue,
                     const std::string& delimiter,
                     const std::string& enum_space,
                     const std::string& enum_type,
                     const std::string& true_value,
                     const std::string& false_value)

  {
    if (delimiter.size() == 0)
    {
      mOp.ThrowError((boost::wformat(L"Empty delimiter specified on field %1%") % fieldName).str());
    }

    if (baseType == "iso8601_datetime")
    {
      // TODO: Handle null value
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        typename iso8601_importer::base_importer baseImporter;
        iso8601_importer importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_iso8601_importer), ptr);
        nullable_iso8601_importer * nullableImporter = 
          new (ptr) nullable_iso8601_importer(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);

        importer_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_iso8601_importer::Import);
        mImporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_iso8601_importer::destroy));
      }
      else
      {
        typename iso8601_importer::base_importer baseImporter;

        boost::uint8_t * ptr;
        get_buffer(sizeof(iso8601_importer), ptr);
        iso8601_importer * importer =
          new (ptr) iso8601_importer(baseImporter, *mMetadata.GetColumn(fieldName));

        importer_delegate id = fastdelegate::MakeDelegate(importer,
                                                          &iso8601_importer::Import);
        mImporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(importer,
                                                     &iso8601_importer::destroy));
      }
    }
    else if (baseType == "text_datetime")
    {
      // TODO: Handle null value
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        typename date_time_importer::base_importer baseImporter;
        date_time_importer importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_date_time_importer), ptr);
        nullable_date_time_importer * nullableImporter = 
          new (ptr) nullable_date_time_importer(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);

        importer_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_date_time_importer::Import);
        mImporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_date_time_importer::destroy));
      }
      else
      {
        typename date_time_importer::base_importer baseImporter;

        boost::uint8_t * ptr;
        get_buffer(sizeof(date_time_importer), ptr);
        date_time_importer * importer =
          new (ptr) date_time_importer(baseImporter, *mMetadata.GetColumn(fieldName));

        importer_delegate id = fastdelegate::MakeDelegate(importer,
                                                          &date_time_importer::Import);
        mImporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(importer,
                                                     &date_time_importer::destroy));
      }
    }
    else if (baseType == "text_delimited_base10_int32")
    {
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        typename base10_int32_importer::base_importer baseImporter;
        base10_int32_importer importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_base10_int32_importer), ptr);
        nullable_base10_int32_importer * nullableImporter = 
          new (ptr) nullable_base10_int32_importer(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);


        importer_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_base10_int32_importer::Import);
        mImporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_base10_int32_importer::destroy));
      }
      else
      {
        typename base10_int32_importer::base_importer baseImporter;

        boost::uint8_t * ptr;
        get_buffer(sizeof(base10_int32_importer), ptr);
        base10_int32_importer * importer =
          new (ptr) base10_int32_importer(baseImporter, *mMetadata.GetColumn(fieldName));

        importer_delegate id = fastdelegate::MakeDelegate(importer,
                                                          &base10_int32_importer::Import);
        mImporters.push_back(id);

        mDelete.push_back(fastdelegate::MakeDelegate(importer,
                                                     &base10_int32_importer::destroy));
      }
    }
    else if (baseType == "text_delimited_base10_int64")
    {
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        typename base10_int64_importer::base_importer baseImporter;
        base10_int64_importer importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_base10_int64_importer), ptr);
        nullable_base10_int64_importer * nullableImporter = 
          new (ptr) nullable_base10_int64_importer(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);

        importer_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_base10_int64_importer::Import);
        mImporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_base10_int64_importer::destroy));
      }
      else
      {
        typename base10_int64_importer::base_importer baseImporter;

        boost::uint8_t * ptr;
        get_buffer(sizeof(base10_int64_importer), ptr);
        base10_int64_importer * importer =
          new (ptr) base10_int64_importer(baseImporter, *mMetadata.GetColumn(fieldName));

        importer_delegate id = fastdelegate::MakeDelegate(importer,
                                                          &base10_int64_importer::Import);
        mImporters.push_back(id);

        mDelete.push_back(fastdelegate::MakeDelegate(importer,
                                                     &base10_int64_importer::destroy));
      }
    }
    else if (baseType == "text_delimited_base10_decimal")
    {
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        typename base10_decimal_importer::base_importer baseImporter;
        base10_decimal_importer importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_base10_decimal_importer), ptr);
        nullable_base10_decimal_importer * nullableImporter = 
          new (ptr) nullable_base10_decimal_importer(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);

        importer_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_base10_decimal_importer::Import);
        mImporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_base10_decimal_importer::destroy));
      }
      else
      {
        typename base10_decimal_importer::base_importer baseImporter;

        boost::uint8_t * ptr;
        get_buffer(sizeof(base10_decimal_importer), ptr);
        base10_decimal_importer * importer =
          new (ptr) base10_decimal_importer(baseImporter, *mMetadata.GetColumn(fieldName));

        importer_delegate id = fastdelegate::MakeDelegate(importer,
                                                          &base10_decimal_importer::Import);
        mImporters.push_back(id);

        mDelete.push_back(fastdelegate::MakeDelegate(importer,
                                                     &base10_decimal_importer::destroy));
      }
    }
    else if (baseType == "text_delimited_varchar")
    {
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        typename varchar_importer::base_importer baseImporter(delimiter);
        varchar_importer importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_varchar_importer), ptr);
        nullable_varchar_importer * nullableImporter = 
          new (ptr) nullable_varchar_importer(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);

        importer_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_varchar_importer::Import);
        mImporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_varchar_importer::destroy));
      }
      else
      {
        typename varchar_importer::base_importer baseImporter(delimiter);

        boost::uint8_t * ptr;
        get_buffer(sizeof(varchar_importer), ptr);
        varchar_importer * importer =
          new (ptr) varchar_importer(baseImporter, *mMetadata.GetColumn(fieldName));

        importer_delegate id = fastdelegate::MakeDelegate(importer,
                                                          &varchar_importer::Import);
        mImporters.push_back(id);
        mDelete.push_back(fastdelegate::MakeDelegate(importer,
                                                     &varchar_importer::destroy));
      }
    }
    else if (baseType == "text_delimited_nvarchar")
    {
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        typename nvarchar_importer::base_importer baseImporter(delimiter);
        nvarchar_importer importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_nvarchar_importer), ptr);
        nullable_nvarchar_importer * nullableImporter = 
          new (ptr) nullable_nvarchar_importer(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);

        importer_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_nvarchar_importer::Import);
        mImporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_nvarchar_importer::destroy));
      }
      else
      {
        typename nvarchar_importer::base_importer baseImporter(delimiter);

        boost::uint8_t * ptr;
        get_buffer(sizeof(nvarchar_importer), ptr);
        nvarchar_importer * importer =
          new (ptr) nvarchar_importer(baseImporter, *mMetadata.GetColumn(fieldName));

        importer_delegate id = fastdelegate::MakeDelegate(importer,
                                                          &nvarchar_importer::Import);
        mImporters.push_back(id);
        mDelete.push_back(fastdelegate::MakeDelegate(importer,
                                                     &nvarchar_importer::destroy));
      }
    }
    else if (baseType == "iso_8859_1_delimited_nvarchar")
    {
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        typename iso_8859_1_nvarchar_importer::base_importer baseImporter(delimiter);
        iso_8859_1_nvarchar_importer importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_iso_8859_1_nvarchar_importer), ptr);
        nullable_iso_8859_1_nvarchar_importer * nullableImporter = 
          new (ptr) nullable_iso_8859_1_nvarchar_importer(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);

        importer_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_iso_8859_1_nvarchar_importer::Import);
        mImporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_iso_8859_1_nvarchar_importer::destroy));
      }
      else
      {
        typename iso_8859_1_nvarchar_importer::base_importer baseImporter(delimiter);

        boost::uint8_t * ptr;
        get_buffer(sizeof(iso_8859_1_nvarchar_importer), ptr);
        iso_8859_1_nvarchar_importer * importer =
          new (ptr) iso_8859_1_nvarchar_importer(baseImporter, *mMetadata.GetColumn(fieldName));

        importer_delegate id = fastdelegate::MakeDelegate(importer,
                                                          &iso_8859_1_nvarchar_importer::Import);
        mImporters.push_back(id);
        mDelete.push_back(fastdelegate::MakeDelegate(importer,
                                                     &iso_8859_1_nvarchar_importer::destroy));
      }
    }
    else if (baseType == "text_delimited_enum")
    {
      if (enum_space.size() == 0 || enum_type.size() == 0)
      {
        mOp.ThrowError(L"'text_delimited_enum' requires 'enum_space' and 'enum_type' properties"); 
      }
      std::wstring wstr_enum_space;
      ::ASCIIToWide(wstr_enum_space, enum_space);
      std::wstring wstr_enum_type;
      ::ASCIIToWide(wstr_enum_type, enum_type);
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        typename enum_importer::base_importer baseImporter(delimiter, wstr_enum_space, wstr_enum_type);
        enum_importer importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_enum_importer), ptr);
        nullable_enum_importer * nullableImporter = 
          new (ptr) nullable_enum_importer(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);

        importer_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_enum_importer::Import);
        mImporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_enum_importer::destroy));
      }
      else
      {
        typename enum_importer::base_importer baseImporter(delimiter, wstr_enum_space, wstr_enum_type);

        boost::uint8_t * ptr;
        get_buffer(sizeof(enum_importer), ptr);
        enum_importer * importer =
          new (ptr) enum_importer(baseImporter, *mMetadata.GetColumn(fieldName));

        importer_delegate id = fastdelegate::MakeDelegate(importer,
                                                          &enum_importer::Import);
        mImporters.push_back(id);
        mDelete.push_back(fastdelegate::MakeDelegate(importer,
                                                     &enum_importer::destroy));
      }
    }
    else if (baseType == "text_delimited_boolean")
    {
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        typename boolean_importer::base_importer baseImporter(true_value, false_value, delimiter);
        boolean_importer importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_boolean_importer), ptr);
        nullable_boolean_importer * nullableImporter = 
          new (ptr) nullable_boolean_importer(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);

        importer_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_boolean_importer::Import);
        mImporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_boolean_importer::destroy));
      }
      else
      {
        typename boolean_importer::base_importer baseImporter(true_value, false_value, delimiter);

        boost::uint8_t * ptr;
        get_buffer(sizeof(boolean_importer), ptr);
        boolean_importer * importer =
          new (ptr) boolean_importer(baseImporter, *mMetadata.GetColumn(fieldName));

        importer_delegate id = fastdelegate::MakeDelegate(importer,
                                                          &boolean_importer::Import);
        mImporters.push_back(id);
        mDelete.push_back(fastdelegate::MakeDelegate(importer,
                                                     &boolean_importer::destroy));
      }
    }
    else if (baseType == "text_fixed_hex_binary")
    {
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        typename binary_importer::base_importer baseImporter;
        binary_importer importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_binary_importer), ptr);
        nullable_binary_importer * nullableImporter = 
          new (ptr) nullable_binary_importer(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);


        importer_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_binary_importer::Import);
        mImporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_binary_importer::destroy));
      }
      else
      {
        typename binary_importer::base_importer baseImporter;

        boost::uint8_t * ptr;
        get_buffer(sizeof(binary_importer), ptr);
        binary_importer * importer =
          new (ptr) binary_importer(baseImporter, *mMetadata.GetColumn(fieldName));

        importer_delegate id = fastdelegate::MakeDelegate(importer,
                                                          &binary_importer::Import);
        mImporters.push_back(id);

        mDelete.push_back(fastdelegate::MakeDelegate(importer,
                                                     &binary_importer::destroy));
      }
    }
    else
    {
      mOp.ThrowError(L"Invalid importer specification");
    }

    if (delimiter.size() > 0)
    {
    typename delimiter_importer::base_importer baseImporter(delimiter);

    boost::uint8_t * ptr;
    get_buffer(sizeof(delimiter_importer), ptr);
    delimiter_importer * importer =
      new (ptr) delimiter_importer(baseImporter, *mMetadata.GetColumn(fieldName));

    importer_delegate id = fastdelegate::MakeDelegate(importer,
                                                      &delimiter_importer::Import);
    mImporters.push_back(id);

    mDelete.push_back(fastdelegate::MakeDelegate(importer,
                                                 &delimiter_importer::destroy));
      
    }
  }

  void add_field(const std::wstring& fieldName, const std::string& baseType, bool isRequired)
  {
    if (baseType == "iso8601_datetime")
    {
      mMetadataMembers.push_back(fieldName, LogicalFieldType::Datetime(isRequired));
    }
    else if (baseType == "text_datetime")
    {
      mMetadataMembers.push_back(fieldName, LogicalFieldType::Datetime(isRequired));
    }
    else if (baseType == "text_delimited_base10_int32")
    {
      mMetadataMembers.push_back(fieldName, LogicalFieldType::Integer(isRequired));
    }
    else if (baseType == "text_delimited_base10_int64")
    {
      mMetadataMembers.push_back(fieldName, LogicalFieldType::BigInteger(isRequired));
    }
    else if (baseType == "text_delimited_base10_decimal")
    {
      mMetadataMembers.push_back(fieldName, LogicalFieldType::Decimal(isRequired));
    }
    else if (baseType == "text_delimited_varchar")
    {
      mMetadataMembers.push_back(fieldName, LogicalFieldType::UTF8String(isRequired));
    }
    else if (baseType == "text_delimited_nvarchar")
    {
      mMetadataMembers.push_back(fieldName, LogicalFieldType::String(isRequired));
    }
    else if (baseType == "iso_8859_1_delimited_nvarchar")
    {
      mMetadataMembers.push_back(fieldName, LogicalFieldType::String(isRequired));
    }
    else if (baseType == "text_delimited_enum")
    {
      mMetadataMembers.push_back(fieldName, LogicalFieldType::Enum(isRequired));
    }
    else if (baseType == "text_delimited_boolean")
    {
      mMetadataMembers.push_back(fieldName, LogicalFieldType::Boolean(isRequired));
    }
    else if (baseType == "text_fixed_hex_binary")
    {
      mMetadataMembers.push_back(fieldName, LogicalFieldType::Binary(isRequired));
    }
    else
    {
      mOp.ThrowError(L"Invalid importer specification");
    }
  }

  const RecordMetadata& GetMetadata() const
  {
    return mMetadata;
  }
};

#endif
