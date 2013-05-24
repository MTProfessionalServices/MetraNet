#ifndef __EXPORTER_H__
#define __EXPORTER_H__

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

template <class _OutputBuffer>
class UTF8_Export_Function_Builder_2 : public Import_Function_Builder, public Record_Metadata_Builder
{
public:
  typedef fastdelegate::FastDelegate2< 
    record_t,
    _OutputBuffer &,
    ParseDescriptor::Result> exporter_delegate;
 
  typedef fastdelegate::FastDelegate0<void> delete_delegate;

private:
  // Our exporters
  typedef Direct_Field_Exporter_2<ISO8601_DateTime_2, _OutputBuffer> iso8601_exporter;
  typedef Direct_Field_Exporter_2<DateString_DateTime_2, _OutputBuffer> date_time_exporter;
  typedef Direct_Field_Exporter_2<UTF8_Base10_Signed_Integer_Int32_2, _OutputBuffer> base10_int32_exporter;
  typedef Direct_Field_Exporter_2<UTF8_Base10_Signed_Integer_Int64_2, _OutputBuffer> base10_int64_exporter;
  typedef Direct_Field_Exporter_2<UTF8_Base10_Decimal_DECIMAL_2, _OutputBuffer> base10_decimal_exporter;
  typedef Indirect_Field_Exporter_2<UTF8_Terminated_UTF8_Null_Terminated_2, _OutputBuffer> varchar_exporter;
  typedef Indirect_Field_Exporter_2<UTF8_Terminated_UTF16_Null_Terminated_2, _OutputBuffer> nvarchar_exporter;
  typedef Indirect_Field_Exporter_2<ISO_8859_1_Terminated_UTF16_Null_Terminated_2, _OutputBuffer> iso_8859_1_nvarchar_exporter;
  typedef Direct_Field_Exporter_2<UTF8_Terminated_Enum_2, _OutputBuffer> enum_exporter;
  typedef Direct_Field_Exporter_2<UTF8_String_Literal_Terminated_Boolean_2, _OutputBuffer> boolean_exporter;
  typedef Direct_Field_Exporter_2<UTF8_Fixed_Length_Hex_Binary_2, _OutputBuffer> binary_exporter;

  typedef UTF8_Non_Nullable_Field_Exporter_2<iso8601_exporter> non_nullable_iso8601_exporter;
  typedef UTF8_Non_Nullable_Field_Exporter_2<date_time_exporter> non_nullable_date_time_exporter;
  typedef UTF8_Non_Nullable_Field_Exporter_2<base10_int32_exporter> non_nullable_base10_int32_exporter;
  typedef UTF8_Non_Nullable_Field_Exporter_2<base10_int64_exporter> non_nullable_base10_int64_exporter;
  typedef UTF8_Non_Nullable_Field_Exporter_2<base10_decimal_exporter> non_nullable_base10_decimal_exporter;
  typedef UTF8_Non_Nullable_Field_Exporter_2<varchar_exporter> non_nullable_varchar_exporter;
  typedef UTF8_Non_Nullable_Field_Exporter_2<nvarchar_exporter> non_nullable_nvarchar_exporter;
  typedef UTF8_Non_Nullable_Field_Exporter_2<iso_8859_1_nvarchar_exporter> non_nullable_iso_8859_1_nvarchar_exporter;
  typedef UTF8_Non_Nullable_Field_Exporter_2<enum_exporter> non_nullable_enum_exporter;
  typedef UTF8_Non_Nullable_Field_Exporter_2<boolean_exporter> non_nullable_boolean_exporter;
  typedef UTF8_Non_Nullable_Field_Exporter_2<binary_exporter> non_nullable_binary_exporter;

  typedef UTF8_Nullable_Field_Exporter_2<iso8601_exporter> nullable_iso8601_exporter;
  typedef UTF8_Nullable_Field_Exporter_2<date_time_exporter> nullable_date_time_exporter;
  typedef UTF8_Nullable_Field_Exporter_2<base10_int32_exporter> nullable_base10_int32_exporter;
  typedef UTF8_Nullable_Field_Exporter_2<base10_int64_exporter> nullable_base10_int64_exporter;
  typedef UTF8_Nullable_Field_Exporter_2<base10_decimal_exporter> nullable_base10_decimal_exporter;
  typedef UTF8_Nullable_Field_Exporter_2<varchar_exporter> nullable_varchar_exporter;
  typedef UTF8_Nullable_Field_Exporter_2<nvarchar_exporter> nullable_nvarchar_exporter;
  typedef UTF8_Nullable_Field_Exporter_2<iso_8859_1_nvarchar_exporter> nullable_iso_8859_1_nvarchar_exporter;
  typedef UTF8_Nullable_Field_Exporter_2<enum_exporter> nullable_enum_exporter;
  typedef UTF8_Nullable_Field_Exporter_2<boolean_exporter> nullable_boolean_exporter;
  typedef UTF8_Nullable_Field_Exporter_2<binary_exporter> nullable_binary_exporter;

  typedef Literal_Field_Exporter_2<UTF8_String_Literal_UTF8_Null_Terminated_2, _OutputBuffer> delimiter_exporter;
 
  Import_Format_Error_Sink& mOp;
  std::vector<boost::uint8_t *> mBuffers;
  boost::uint8_t * mBuffer;
  boost::uint8_t * mBufferEnd;

  std::vector<exporter_delegate> mExporters;
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

  UTF8_Export_Function_Builder_2(Import_Format_Error_Sink& op,
                                 const std::wstring& importSpec)
    :
    mOp(op),
    mBuffer(NULL),
    mBufferEnd(NULL)
  {
    mLogger = MetraFlowLoggerManager::GetLogger("[RecordExport]");

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
      mOp.ThrowError(L"Exporter Specification error");
    }

    if (parser.getHasError())
    {
      mOp.ThrowError(L"Exporter Specification error");
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
      mOp.ThrowError(L"Exporter Specification error");
    }
    if (analyze.getHasError())
    { 
      mOp.ThrowError(L"Exporter Specification error");
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
      mOp.ThrowError(L"Exporter Specification error");
    }
    if (generate.getHasError())
    { 
      mOp.ThrowError(L"Exporter Specification error");
    }
  }

  ~UTF8_Export_Function_Builder_2()
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

  void Export(record_t recordBuffer, _OutputBuffer & output)
  {
    for(std::vector<exporter_delegate>::iterator it = mExporters.begin();
        it != mExporters.end();
        ++it)
    {
      ParseDescriptor::Result r = (*it)(recordBuffer, output);
      if (r != ParseDescriptor::PARSE_OK)
      {
        // For debugging print out a window around the failure point.
        std::string buf((char *)output.buffer()+(output.size() >= 10 ? output.size()-10 : 0), 
                        (char *)output.buffer()+(output.size()+10<=output.capacity() ? output.size()+10 : output.capacity()));
        mLogger->logError((boost::format("Parse Error: Column=%1%; Output Buffer=%2%; Input Record=%3%") % 
                           (it-mExporters.begin()) % 
                           buf %
                           mMetadata.PrintMessage(recordBuffer)).str());
        mMetadata.Free(recordBuffer);
        return;
      }
    }
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
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        iso8601_exporter::base_exporter baseImporter;
        iso8601_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_iso8601_exporter), ptr);
        nullable_iso8601_exporter * nullableImporter = 
          new (ptr) nullable_iso8601_exporter(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);

        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_iso8601_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_iso8601_exporter::destroy));
      }
      else
      {
        iso8601_exporter::base_exporter baseImporter;
        iso8601_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(non_nullable_iso8601_exporter), ptr);
        non_nullable_iso8601_exporter * nonNullableImporter =
          new (ptr) non_nullable_iso8601_exporter(importer);

        exporter_delegate id = fastdelegate::MakeDelegate(nonNullableImporter,
                                                          &non_nullable_iso8601_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nonNullableImporter,
                                                     &non_nullable_iso8601_exporter::destroy));
      }
    }
    else if (baseType == "text_datetime")
    {
      // TODO: Handle null value
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        date_time_exporter::base_exporter baseImporter;
        date_time_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_date_time_exporter), ptr);
        nullable_date_time_exporter * nullableImporter = 
          new (ptr) nullable_date_time_exporter(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);

        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_date_time_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_date_time_exporter::destroy));
      }
      else
      {
        date_time_exporter::base_exporter baseImporter;
        date_time_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(non_nullable_date_time_exporter), ptr);
        non_nullable_date_time_exporter * nullableImporter = 
          new (ptr) non_nullable_date_time_exporter(importer);

        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &non_nullable_date_time_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &non_nullable_date_time_exporter::destroy));
      }
    }
    else if (baseType == "text_delimited_base10_int32")
    {
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        base10_int32_exporter::base_exporter baseImporter;
        base10_int32_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_base10_int32_exporter), ptr);
        nullable_base10_int32_exporter * nullableImporter = 
          new (ptr) nullable_base10_int32_exporter(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);


        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_base10_int32_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_base10_int32_exporter::destroy));
      }
      else
      {
        base10_int32_exporter::base_exporter baseImporter;
        base10_int32_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(non_nullable_base10_int32_exporter), ptr);
        non_nullable_base10_int32_exporter * nullableImporter = 
          new (ptr) non_nullable_base10_int32_exporter(importer);


        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &non_nullable_base10_int32_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &non_nullable_base10_int32_exporter::destroy));
      }
    }
    else if (baseType == "text_delimited_base10_int64")
    {
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        base10_int64_exporter::base_exporter baseImporter;
        base10_int64_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_base10_int64_exporter), ptr);
        nullable_base10_int64_exporter * nullableImporter = 
          new (ptr) nullable_base10_int64_exporter(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);

        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_base10_int64_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_base10_int64_exporter::destroy));
      }
      else
      {
        base10_int64_exporter::base_exporter baseImporter;
        base10_int64_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(non_nullable_base10_int64_exporter), ptr);
        non_nullable_base10_int64_exporter * nullableImporter = 
          new (ptr) non_nullable_base10_int64_exporter(importer);

        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &non_nullable_base10_int64_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &non_nullable_base10_int64_exporter::destroy));
      }
    }
    else if (baseType == "text_delimited_base10_decimal")
    {
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        base10_decimal_exporter::base_exporter baseImporter;
        base10_decimal_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_base10_decimal_exporter), ptr);
        nullable_base10_decimal_exporter * nullableImporter = 
          new (ptr) nullable_base10_decimal_exporter(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);

        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_base10_decimal_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_base10_decimal_exporter::destroy));
      }
      else
      {
        base10_decimal_exporter::base_exporter baseImporter;
        base10_decimal_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(non_nullable_base10_decimal_exporter), ptr);
        non_nullable_base10_decimal_exporter * nullableImporter = 
          new (ptr) non_nullable_base10_decimal_exporter(importer);

        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &non_nullable_base10_decimal_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &non_nullable_base10_decimal_exporter::destroy));
      }
    }
    else if (baseType == "text_delimited_varchar")
    {
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        varchar_exporter::base_exporter baseImporter(delimiter);
        varchar_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_varchar_exporter), ptr);
        nullable_varchar_exporter * nullableImporter = 
          new (ptr) nullable_varchar_exporter(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);

        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_varchar_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_varchar_exporter::destroy));
      }
      else
      {
        ASSERT(delimiter.size() > 0);
        varchar_exporter::base_exporter baseImporter(delimiter);
        varchar_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(non_nullable_varchar_exporter), ptr);
        non_nullable_varchar_exporter * nullableImporter = 
          new (ptr) non_nullable_varchar_exporter(importer);

        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &non_nullable_varchar_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &non_nullable_varchar_exporter::destroy));
      }
    }
    else if (baseType == "text_delimited_nvarchar")
    {
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        nvarchar_exporter::base_exporter baseImporter(delimiter);
        nvarchar_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_nvarchar_exporter), ptr);
        nullable_nvarchar_exporter * nullableImporter = 
          new (ptr) nullable_nvarchar_exporter(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);

        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_nvarchar_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_nvarchar_exporter::destroy));
      }
      else
      {
        ASSERT(delimiter.size() > 0);
        nvarchar_exporter::base_exporter baseImporter(delimiter);
        nvarchar_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(non_nullable_nvarchar_exporter), ptr);
        non_nullable_nvarchar_exporter * nullableImporter = 
          new (ptr) non_nullable_nvarchar_exporter(importer);

        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &non_nullable_nvarchar_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &non_nullable_nvarchar_exporter::destroy));
      }
    }
    else if (baseType == "iso_8859_1_delimited_nvarchar")
    {
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        iso_8859_1_nvarchar_exporter::base_exporter baseImporter(delimiter);
        iso_8859_1_nvarchar_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_iso_8859_1_nvarchar_exporter), ptr);
        nullable_iso_8859_1_nvarchar_exporter * nullableImporter = 
          new (ptr) nullable_iso_8859_1_nvarchar_exporter(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);

        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_iso_8859_1_nvarchar_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_iso_8859_1_nvarchar_exporter::destroy));
      }
      else
      {
        ASSERT(delimiter.size() > 0);
        iso_8859_1_nvarchar_exporter::base_exporter baseImporter(delimiter);
        iso_8859_1_nvarchar_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(non_nullable_iso_8859_1_nvarchar_exporter), ptr);
        non_nullable_iso_8859_1_nvarchar_exporter * nullableImporter = 
          new (ptr) non_nullable_iso_8859_1_nvarchar_exporter(importer);

        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &non_nullable_iso_8859_1_nvarchar_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &non_nullable_iso_8859_1_nvarchar_exporter::destroy));
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
        enum_exporter::base_exporter baseImporter(delimiter, wstr_enum_space, wstr_enum_type);
        enum_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_enum_exporter), ptr);
        nullable_enum_exporter * nullableImporter = 
          new (ptr) nullable_enum_exporter(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);

        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_enum_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_enum_exporter::destroy));
      }
      else
      {
        ASSERT(delimiter.size() > 0);
        enum_exporter::base_exporter baseImporter(delimiter, wstr_enum_space, wstr_enum_type);
        enum_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(non_nullable_enum_exporter), ptr);
        non_nullable_enum_exporter * nullableImporter = 
          new (ptr) non_nullable_enum_exporter(importer);

        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &non_nullable_enum_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &non_nullable_enum_exporter::destroy));
      }
    }
    else if (baseType == "text_delimited_boolean")
    {
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        boolean_exporter::base_exporter baseImporter(true_value, false_value, delimiter);
        boolean_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_boolean_exporter), ptr);
        nullable_boolean_exporter * nullableImporter = 
          new (ptr) nullable_boolean_exporter(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);

        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_boolean_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_boolean_exporter::destroy));
      }
      else
      {
        ASSERT(delimiter.size() > 0);
        boolean_exporter::base_exporter baseImporter(true_value, false_value, delimiter);
        boolean_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(non_nullable_boolean_exporter), ptr);
        non_nullable_boolean_exporter * nullableImporter = 
          new (ptr) non_nullable_boolean_exporter(importer);

        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &non_nullable_boolean_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &non_nullable_boolean_exporter::destroy));
      }
    }
    else if (baseType == "text_fixed_hex_binary")
    {
      if (!isRequired)
      {
        ASSERT(delimiter.size() > 0);
        binary_exporter::base_exporter baseImporter;
        binary_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(nullable_binary_exporter), ptr);
        nullable_binary_exporter * nullableImporter = 
          new (ptr) nullable_binary_exporter(nullValue, delimiter, *mMetadata.GetColumn(fieldName), importer);


        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &nullable_binary_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &nullable_binary_exporter::destroy));
      }
      else
      {
        binary_exporter::base_exporter baseImporter;
        binary_exporter importer(baseImporter, *mMetadata.GetColumn(fieldName));

        boost::uint8_t * ptr;
        get_buffer(sizeof(non_nullable_binary_exporter), ptr);
        non_nullable_binary_exporter * nullableImporter = 
          new (ptr) non_nullable_binary_exporter(importer);


        exporter_delegate id = fastdelegate::MakeDelegate(nullableImporter,
                                                          &non_nullable_binary_exporter::Export);
        mExporters.push_back(id);
      
        mDelete.push_back(fastdelegate::MakeDelegate(nullableImporter,
                                                     &non_nullable_binary_exporter::destroy));
      }
    }
    else
    {
      mOp.ThrowError(L"Invalid importer specification");
    }

    if (delimiter.size() > 0)
    {
    delimiter_exporter::base_exporter baseImporter(delimiter);

    boost::uint8_t * ptr;
    get_buffer(sizeof(delimiter_exporter), ptr);
    delimiter_exporter * importer =
      new (ptr) delimiter_exporter(baseImporter);

    exporter_delegate id = fastdelegate::MakeDelegate(importer,
                                                      &delimiter_exporter::Export);
    mExporters.push_back(id);

    mDelete.push_back(fastdelegate::MakeDelegate(importer,
                                                 &delimiter_exporter::destroy));
      
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
      mOp.ThrowError(L"Invalid exporter specification");
    }
  }

  const RecordMetadata& GetMetadata() const
  {
    return mMetadata;
  }
};

#endif
