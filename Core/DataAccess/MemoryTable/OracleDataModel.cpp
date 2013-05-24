#include "OracleDataModel.h"
#include "StringConvert.h"
#include "RecordModel.h"

#include <iostream>

#include <boost/format.hpp>

OCIRecordMetadataVisitor::OCIRecordMetadataVisitor(RecordMetadata& metadata)
  :
  mMetadata(metadata)
{}

OCIRecordMetadataVisitor::~OCIRecordMetadataVisitor()
{}
  
void OCIRecordMetadataVisitor::Visit(ub4 colCount)
{
  mMetadata.Init(colCount);
}

void OCIRecordMetadataVisitor::Visit(ub4 colPos,
                                     text * colName, ub4 colNameLen,
                                     ub2 dtype,
                                     ub2 colWidth,
                                     ub4 charSemantics,
                                     sb2 prec,
                                     sb1 scale,
                                     ub1 nullable,
                                     ub2 charset_id,
                                     ub1 charset_form
  )
{
  std::wstring wstrColName;
  ::UTF8ToWideString(wstrColName, (const char *) colName, (const char *) colName + colNameLen);
  switch(dtype)
  {
    // Treat VARCHAR2 and CHAR the same
  case SQLT_AFC:
  case SQLT_CHR:
    mMetadata.Add(wstrColName, GlobalConstantPoolFactory::Get(),
                  charset_id == 2000 ? PhysicalFieldType::StringDomain() : PhysicalFieldType::UTF8StringDomain(), 
                  nullable != 0, colPos-1, colPos-1);           
    break;
  case SQLT_NUM:
    if (scale != 0)
      mMetadata.Add(wstrColName, GlobalConstantPoolFactory::Get(),
                    PhysicalFieldType::Decimal(), nullable != 0, colPos-1, colPos-1);           
    else if (prec <= 10)
      mMetadata.Add(wstrColName, GlobalConstantPoolFactory::Get(),
                    PhysicalFieldType::Integer(), nullable != 0, colPos-1, colPos-1);           
    else if (prec <= 20)
      mMetadata.Add(wstrColName, GlobalConstantPoolFactory::Get(),
                    PhysicalFieldType::BigInteger(), nullable != 0, colPos-1, colPos-1);           
    else 
      mMetadata.Add(wstrColName, GlobalConstantPoolFactory::Get(),
                    PhysicalFieldType::Decimal(), nullable != 0, colPos-1, colPos-1);           
    break;
  case SQLT_LNG:
    throw std::logic_error("Unsupported Oracle datatype SQLT_LNG");
    break;
  case SQLT_DAT:
    mMetadata.Add(wstrColName, GlobalConstantPoolFactory::Get(),
                  PhysicalFieldType::Datetime(), nullable != 0, colPos-1, colPos-1);           
    break;
  case SQLT_BIN:
    if (colWidth != 16) throw std::logic_error("MetraFlow only supports RAW(16)");
    mMetadata.Add(wstrColName, GlobalConstantPoolFactory::Get(),
                  PhysicalFieldType::Binary(), nullable != 0, colPos-1, colPos-1);           
    break;
  case SQLT_LBI:
    throw std::logic_error("Unsupported Oracle datatype SQLT_LBI");
    break;
  case SQLT_BFLOAT:
  case SQLT_IBFLOAT:
  case SQLT_BDOUBLE:
  case SQLT_IBDOUBLE:
    mMetadata.Add(wstrColName, GlobalConstantPoolFactory::Get(),
                  PhysicalFieldType::Double(), nullable != 0, colPos-1, colPos-1);           
    break;
  default:
    throw std::logic_error("Unsupported Oracle datatype");
  }
}

void OCIBufferVisitor::Visit(ub4 colPos,
                             text * colName, ub4 colNameLen,
                             ub2 dtype,
                             ub2 colWidth,
                             ub4 charSemantics,
                             sb2 prec,
                             sb1 scale,
                             ub1 nullable,
                             ub2 charset_id,
                             ub1 charset_form)
{
  switch(dtype)
  {
    // Treat VARCHAR2 and CHAR the same.
  case SQLT_AFC:
  case SQLT_CHR:
    if (charset_id == 2000)
    {
      mDataOffsets.push_back(mDataOffsets.size() > 0 ? (((mTotalSize+1)>>1)<<1) : 0);
      mDataLengths.push_back((charSemantics ? sizeof(utext)*(colWidth+1) : (colWidth+1)));
      mTotalSize = mDataOffsets.back() + mDataLengths.back();
    }
    else
    {
      mDataOffsets.push_back(mDataOffsets.size() > 0 ? mTotalSize : 0);
      mDataLengths.push_back(colWidth+1);
      mTotalSize = mDataOffsets.back() + mDataLengths.back();
    }
           
    break;
  case SQLT_NUM:
    mDataOffsets.push_back(mDataOffsets.size() > 0 ? mTotalSize : 0);
    mDataLengths.push_back(21);
    mTotalSize = mDataOffsets.back() + mDataLengths.back();
    break;
  case SQLT_LNG:
    throw std::logic_error("Unsupported Oracle datatype SQLT_LNG");
    break;
  case SQLT_DAT:
    // No alignment requirement for dates.
    mDataOffsets.push_back(mDataOffsets.size() > 0 ? mTotalSize : 0);
    mDataLengths.push_back(7);
    mTotalSize = mDataOffsets.back() + mDataLengths.back();
    break;
  case SQLT_BIN:
    mDataOffsets.push_back(mDataOffsets.size() > 0 ? mTotalSize : 0);
    mDataLengths.push_back(colWidth);
    mTotalSize = mDataOffsets.back() + mDataLengths.back();
    break;
  case SQLT_LBI:
    throw std::logic_error("Unsupported Oracle datatype SQLT_LBI");
    break;
  case SQLT_BFLOAT:
  case SQLT_IBFLOAT:
  case SQLT_BDOUBLE:
  case SQLT_IBDOUBLE:
    // 8 byte align doubles
    mDataOffsets.push_back(mDataOffsets.size() > 0 ? (((mTotalSize+7)>>3)<<3) : 0);
    mDataLengths.push_back(8);
    mTotalSize = mDataOffsets.back() + mDataLengths.back();
    break;
  default:
    throw std::logic_error("Unsupported Oracle datatype");
  }
    
  // No mapping of types yet.
  mExternalTypes.push_back(dtype);
  // No translation of character sets yet.
  mCharsetIds.push_back(charset_id);
}

// Dynamically generated Oracle row binding.  The format is the same for
// both binds (input parameters) and defines (output rowsets).
// TODO: Look at the OCI batch error mode.
void BindOCIRecord(OCIEnv * p_env, OCIStmt * p_sql, OCIError * p_err, OCIParamVisitor& visitor)
{
  int rc=0;
  
   ub4 colCount;   
   ::OCIAttrGet((dvoid *)p_sql, OCI_HTYPE_STMT, (dvoid *)&colCount, (ub4 *)0, OCI_ATTR_PARAM_COUNT, p_err);
   visitor.Visit(colCount);
   
   OCIParam * p_param = NULL;
   ub4 counter = 1;
   rc = ::OCIParamGet((dvoid *)p_sql, OCI_HTYPE_STMT, p_err,
                      (dvoid **)&p_param, (ub4) counter);
   if (rc != OCI_SUCCESS) {
     sb4 errcode;
     text errbuf[512];
      ::OCIErrorGet((dvoid *)p_err, (ub4) 1, (text *) NULL, &errcode, errbuf, (ub4) sizeof(errbuf), OCI_HTYPE_ERROR);
      printf("OCIParamGet Error - %.*s\n", 512, errbuf);
   }
   while(rc == OCI_SUCCESS)
   {
     ub2 dtype;
     
     rc = ::OCIAttrGet(p_param, OCI_DTYPE_PARAM, &dtype, 0, OCI_ATTR_DATA_TYPE, p_err);
     text * colName;
     ub4 colNameLen;
     rc = ::OCIAttrGet(p_param, OCI_DTYPE_PARAM, &colName, &colNameLen, OCI_ATTR_NAME, p_err);
     std::string strColName(colName, colName+colNameLen);

     std::string strTypeName;
     text * typeName;
     ub4 typeNameLen;
     rc = ::OCIAttrGet(p_param, OCI_DTYPE_PARAM, &typeName, &typeNameLen, OCI_ATTR_TYPE_NAME, p_err);
     if (rc == OCI_SUCCESS)
     {
       strTypeName = std::string(typeName, typeName+typeNameLen);
     }
     ub4 charSemantics=0;
     rc = ::OCIAttrGet(p_param, OCI_DTYPE_PARAM, &charSemantics, 0, OCI_ATTR_CHAR_USED, p_err);
     ub2 colWidth;
     if (charSemantics)
     {
       rc = ::OCIAttrGet(p_param, OCI_DTYPE_PARAM, &colWidth, 0, OCI_ATTR_CHAR_SIZE, p_err);
     }
     else
     {
       rc = ::OCIAttrGet(p_param, OCI_DTYPE_PARAM, &colWidth, 0, OCI_ATTR_DATA_SIZE, p_err);
     }
     sb2 prec;
     /* ub1 prec; used in explicit describe */
     rc = ::OCIAttrGet(p_param, OCI_DTYPE_PARAM, &prec, 0, OCI_ATTR_PRECISION, p_err);
     sb1 scale;
     rc = ::OCIAttrGet(p_param, OCI_DTYPE_PARAM, &scale, 0, OCI_ATTR_SCALE, p_err);
     ub1 nullable;
     rc = ::OCIAttrGet(p_param, OCI_DTYPE_PARAM, &nullable, 0, OCI_ATTR_IS_NULL, p_err);
     ub2 charset_id;
     rc = ::OCIAttrGet(p_param, OCI_DTYPE_PARAM, &charset_id, 0, OCI_ATTR_CHARSET_ID, p_err);
     oratext charsetName [OCI_NLS_MAXBUFSZ];
     if (rc == OCI_SUCCESS)
     {
       ::OCINlsCharSetIdToName(p_env, charsetName, OCI_NLS_MAXBUFSZ, charset_id);
     }
     else
     {
       charsetName[0] = 0;
     }
     ub1 charset_form;

     
     rc = ::OCIAttrGet(p_param, OCI_DTYPE_PARAM, &charset_form, 0, OCI_ATTR_CHARSET_FORM, p_err);

     
     visitor.Visit(counter,
                   colName, colNameLen,
                   dtype,
                   colWidth,
                   charSemantics,
                   prec,
                   scale,
                   nullable,
                   charset_id,
                   charset_form);
     
     rc = ::OCIParamGet((dvoid *)p_sql, OCI_HTYPE_STMT, p_err,
                        (dvoid **)&p_param, (ub4) ++counter);
   }
}

OCIRowBinding::OCIRowBinding(OCIStmt * stmt, OCIError * error, OCIRowBuffer& buffer, ub4 rows)
  :
  OCIRowBindingBase(buffer, rows)
{
  for(ub4 colPos=1; colPos<=buffer.GetColumns(); ++colPos)
  {
    ub2 csid = OCI_UTF16ID;
    ub1 cform = SQLCS_NCHAR;
    switch(buffer.GetExternalType(colPos))
    {
    case SQLT_AFC:
    case SQLT_CHR:
    {
      OCIBind * p_dfn1=NULL;
      int rc = ::OCIBindByPos(stmt, &p_dfn1, error, colPos, 
                              mBuffer.GetData(mData, colPos), mBuffer.GetDataLength(colPos), SQLT_CHR, 
                              mBuffer.GetIndicator(mData, colPos), 
                              mBuffer.GetLength(mData, colPos), 
                              mBuffer.GetCode(mData, colPos), 
                              0, NULL, OCI_DEFAULT);

//       boost::format logme("::OCIBindByPos(stmt, &p_dfn1, error, %1%, %2%, %3%, %4%, %5%, %6%, %7%, 0, NULL, OCI_DEFAULT)");
//       logme %
//         colPos %
//         mBuffer.GetData(mData, colPos) % 
//         mBuffer.GetDataLength(colPos) % 
//         SQLT_CHR %
//         mBuffer.GetIndicator(mData, colPos) %
//         mBuffer.GetLength(mData, colPos) % 
//         mBuffer.GetCode(mData, colPos);
            
//       std::cout << logme.str().c_str() << std::endl;
            
      // According to Oracle, one must set FORM before ID.
      // OCI_ATTR_CHARSET_FORM describes the client buffer.  
      // Setting SQLCS_NCHAR says interpret the buffer as a NCHAR as defined 
      // in the initial environment (for us UTF16).
      if (mBuffer.GetCharsetId(colPos) == 2000)
      {
        rc = ::OCIAttrSet((void *) p_dfn1, (ub4) OCI_HTYPE_BIND, 
                          (void *) &cform, (ub4) 0,
                          (ub4)OCI_ATTR_CHARSET_FORM, error); 
        rc = ::OCIAttrSet((void *) p_dfn1, (ub4) OCI_HTYPE_BIND, 
                          (void *) &csid, (ub4) 0, 
                          (ub4)OCI_ATTR_CHARSET_ID, error);
      }
      rc = ::OCIBindArrayOfStruct(p_dfn1, error, mBuffer.GetSize(), mBuffer.GetSize(), mBuffer.GetSize(), mBuffer.GetSize());

      mBindHandles.push_back(p_dfn1);
    }
       
    break;
    case SQLT_NUM:
    {
      OCIBind * p_dfn1=NULL;
      int rc = ::OCIBindByPos(stmt, &p_dfn1, error, colPos, 
                              mBuffer.GetData(mData, colPos), mBuffer.GetDataLength(colPos), SQLT_NUM, 
                              mBuffer.GetIndicator(mData, colPos), 
                              mBuffer.GetLength(mData, colPos), 
                              mBuffer.GetCode(mData, colPos), 
                              0, NULL, OCI_DEFAULT);

//       boost::format logme("::OCIBindByPos(stmt, &p_dfn1, error, %1%, %2%, %3%, %4%, %5%, %6%, %7%, 0, NULL, OCI_DEFAULT)");
//       logme %
//         colPos %
//         mBuffer.GetData(mData, colPos) % 
//         mBuffer.GetDataLength(colPos) % 
//         SQLT_NUM %
//         mBuffer.GetIndicator(mData, colPos) %
//         mBuffer.GetLength(mData, colPos) % 
//         mBuffer.GetCode(mData, colPos);
            
//       std::cout << logme.str().c_str() << std::endl;
            
      rc = ::OCIBindArrayOfStruct(p_dfn1, error, mBuffer.GetSize(), mBuffer.GetSize(), mBuffer.GetSize(), mBuffer.GetSize());
           

      mBindHandles.push_back(p_dfn1);
    }
         
    break;
    case SQLT_LNG:
      throw std::logic_error("Unsupported Oracle datatype SQLT_LNG");
      break;
    case SQLT_DAT:
    {
      OCIBind * p_dfn1=NULL;
      int rc = ::OCIBindByPos(stmt, &p_dfn1, error, colPos, 
                              mBuffer.GetData(mData, colPos), mBuffer.GetDataLength(colPos), SQLT_DAT, 
                              mBuffer.GetIndicator(mData, colPos), 
                              mBuffer.GetLength(mData, colPos), 
                              mBuffer.GetCode(mData, colPos), 
                              0, NULL, OCI_DEFAULT);

//       boost::format logme("::OCIBindByPos(stmt, &p_dfn1, error, %1%, %2%, %3%, %4%, %5%, %6%, %7%, 0, NULL, OCI_DEFAULT)");
//       logme %
//         colPos %
//         mBuffer.GetData(mData, colPos) % 
//         mBuffer.GetDataLength(colPos) % 
//         SQLT_DAT %
//         mBuffer.GetIndicator(mData, colPos) %
//         mBuffer.GetLength(mData, colPos) % 
//         mBuffer.GetCode(mData, colPos);
            
//       std::cout << logme.str().c_str() << std::endl;
            
      rc = ::OCIBindArrayOfStruct(p_dfn1, error, mBuffer.GetSize(), mBuffer.GetSize(), mBuffer.GetSize(), mBuffer.GetSize());
           

      mBindHandles.push_back(p_dfn1);
    }
    break;
    case SQLT_BIN:
    {
      OCIBind * p_dfn1=NULL;
      int rc = ::OCIBindByPos(stmt, &p_dfn1, error, colPos, 
                              mBuffer.GetData(mData, colPos), mBuffer.GetDataLength(colPos), SQLT_BIN, 
                              mBuffer.GetIndicator(mData, colPos), 
                              mBuffer.GetLength(mData, colPos), 
                              mBuffer.GetCode(mData, colPos), 
                              0, NULL, OCI_DEFAULT);

//       boost::format logme("::OCIBindByPos(stmt, &p_dfn1, error, %1%, %2%, %3%, %4%, %5%, %6%, %7%, 0, NULL, OCI_DEFAULT)");
//       logme %
//         colPos %
//         mBuffer.GetData(mData, colPos) % 
//         mBuffer.GetDataLength(colPos) % 
//         SQLT_BIN %
//         mBuffer.GetIndicator(mData, colPos) %
//         mBuffer.GetLength(mData, colPos) % 
//         mBuffer.GetCode(mData, colPos);
            
//       std::cout << logme.str().c_str() << std::endl;

      rc = ::OCIBindArrayOfStruct(p_dfn1, error, mBuffer.GetSize(), mBuffer.GetSize(), mBuffer.GetSize(), mBuffer.GetSize());
      mBindHandles.push_back(p_dfn1);
    }
    break;
    case SQLT_LBI:
      throw std::logic_error("Unsupported Oracle datatype SQLT_LBI");
      break;
    case SQLT_BFLOAT:
    case SQLT_IBFLOAT:
    case SQLT_BDOUBLE:
    case SQLT_IBDOUBLE:
    {
      OCIBind * p_dfn1=NULL;
      int rc = ::OCIBindByPos(stmt, &p_dfn1, error, colPos, 
                              mBuffer.GetData(mData, colPos), mBuffer.GetDataLength(colPos), SQLT_BDOUBLE, 
                              mBuffer.GetIndicator(mData, colPos), 
                              mBuffer.GetLength(mData, colPos), 
                              mBuffer.GetCode(mData, colPos), 
                              0, NULL, OCI_DEFAULT);

//       boost::format logme("::OCIBindByPos(stmt, &p_dfn1, error, %1%, %2%, %3%, %4%, %5%, %6%, %7%, 0, NULL, OCI_DEFAULT)");
//       logme %
//         colPos %
//         mBuffer.GetData(mData, colPos) % 
//         mBuffer.GetDataLength(colPos) % 
//         SQLT_BDOUBLE %
//         mBuffer.GetIndicator(mData, colPos) %
//         mBuffer.GetLength(mData, colPos) % 
//         mBuffer.GetCode(mData, colPos);
            
//       std::cout << logme.str().c_str() << std::endl;
            
      rc = ::OCIBindArrayOfStruct(p_dfn1, error, mBuffer.GetSize(), mBuffer.GetSize(), mBuffer.GetSize(), mBuffer.GetSize());
           

      mBindHandles.push_back(p_dfn1);
    }
    break;
    default:
      throw std::logic_error("Unsupported Oracle datatype");
    }
  }
}

OCIRowDefinition::OCIRowDefinition(OCIStmt * stmt, OCIError * error, OCIRowBuffer& buffer, ub4 rows)
  :
  OCIRowBindingBase(buffer, rows)
{
  for(ub4 colPos=1; colPos<=buffer.GetColumns(); ++colPos)
  {
    ub2 csid = OCI_UTF16ID;
    ub1 cform = SQLCS_NCHAR;
    switch(buffer.GetExternalType(colPos))
    {
    case SQLT_AFC:
    case SQLT_CHR:
    {
      OCIDefine * p_dfn1=NULL;
      int rc = ::OCIDefineByPos(stmt, &p_dfn1, error, colPos, 
                                mBuffer.GetData(mData, colPos), mBuffer.GetDataLength(colPos), SQLT_CHR, 
                                mBuffer.GetIndicator(mData, colPos), 
                                mBuffer.GetLength(mData, colPos), 
                                mBuffer.GetCode(mData, colPos), 
                                OCI_DEFAULT);

//       boost::format logme("::OCIDefineByPos(stmt, &p_dfn1, error, %1%, %2%, %3%, %4%, %5%, %6%, %7%, OCI_DEFAULT)");
//       logme %
//         colPos %
//         mBuffer.GetData(mData, colPos) % 
//         mBuffer.GetDataLength(colPos) % 
//         SQLT_CHR %
//         mBuffer.GetIndicator(mData, colPos) %
//         mBuffer.GetLength(mData, colPos) % 
//         mBuffer.GetCode(mData, colPos);
            
//       std::cout << logme.str().c_str() << std::endl;
            
      // According to Oracle, one must set FORM before ID.
      // OCI_ATTR_CHARSET_FORM describes the client buffer.  
      // Setting SQLCS_NCHAR says interpret the buffer as a NCHAR as defined 
      // in the initial environment (for us UTF16).
      if (mBuffer.GetCharsetId(colPos) == 2000)
      {
        rc = ::OCIAttrSet((void *) p_dfn1, (ub4) OCI_HTYPE_DEFINE, 
                          (void *) &cform, (ub4) 0,
                          (ub4)OCI_ATTR_CHARSET_FORM, error); 
        rc = ::OCIAttrSet((void *) p_dfn1, (ub4) OCI_HTYPE_DEFINE, 
                          (void *) &csid, (ub4) 0, 
                          (ub4)OCI_ATTR_CHARSET_ID, error);
      }
      rc = ::OCIDefineArrayOfStruct(p_dfn1, error, mBuffer.GetSize(), mBuffer.GetSize(), mBuffer.GetSize(), mBuffer.GetSize());

      mDefineHandles.push_back(p_dfn1);
    }
       
    break;
    case SQLT_NUM:
    {
      OCIDefine * p_dfn1=NULL;
      int rc = ::OCIDefineByPos(stmt, &p_dfn1, error, colPos, 
                                mBuffer.GetData(mData, colPos), mBuffer.GetDataLength(colPos), SQLT_NUM, 
                                mBuffer.GetIndicator(mData, colPos), 
                                mBuffer.GetLength(mData, colPos), 
                                mBuffer.GetCode(mData, colPos), 
                                OCI_DEFAULT);

//       boost::format logme("::OCIDefineByPos(stmt, &p_dfn1, error, %1%, %2%, %3%, %4%, %5%, %6%, %7%, OCI_DEFAULT)");
//       logme %
//         colPos %
//         mBuffer.GetData(mData, colPos) % 
//         mBuffer.GetDataLength(colPos) % 
//         SQLT_NUM %
//         mBuffer.GetIndicator(mData, colPos) %
//         mBuffer.GetLength(mData, colPos) % 
//         mBuffer.GetCode(mData, colPos);
            
//       std::cout << logme.str().c_str() << std::endl;
            
      rc = ::OCIDefineArrayOfStruct(p_dfn1, error, mBuffer.GetSize(), mBuffer.GetSize(), mBuffer.GetSize(), mBuffer.GetSize());
           

      mDefineHandles.push_back(p_dfn1);
    }
         
    break;
    case SQLT_LNG:
      throw std::logic_error("Unsupported Oracle datatype");
      break;
    case SQLT_DAT:
    {
      OCIDefine * p_dfn1=NULL;
      int rc = ::OCIDefineByPos(stmt, &p_dfn1, error, colPos, 
                                mBuffer.GetData(mData, colPos), mBuffer.GetDataLength(colPos), SQLT_DAT, 
                                mBuffer.GetIndicator(mData, colPos), 
                                mBuffer.GetLength(mData, colPos), 
                                mBuffer.GetCode(mData, colPos), 
                                OCI_DEFAULT);

//       boost::format logme("::OCIDefineByPos(stmt, &p_dfn1, error, %1%, %2%, %3%, %4%, %5%, %6%, %7%, OCI_DEFAULT)");
//       logme %
//         colPos %
//         mBuffer.GetData(mData, colPos) % 
//         mBuffer.GetDataLength(colPos) % 
//         SQLT_DAT %
//         mBuffer.GetIndicator(mData, colPos) %
//         mBuffer.GetLength(mData, colPos) % 
//         mBuffer.GetCode(mData, colPos);
            
//       std::cout << logme.str().c_str() << std::endl;
            
      rc = ::OCIDefineArrayOfStruct(p_dfn1, error, mBuffer.GetSize(), mBuffer.GetSize(), mBuffer.GetSize(), mBuffer.GetSize());
           

      mDefineHandles.push_back(p_dfn1);
    }
    break;
    case SQLT_BIN:
    {
      OCIDefine * p_dfn1=NULL;
      int rc = ::OCIDefineByPos(stmt, &p_dfn1, error, colPos, 
                                mBuffer.GetData(mData, colPos), mBuffer.GetDataLength(colPos), SQLT_BIN, 
                                mBuffer.GetIndicator(mData, colPos), 
                                mBuffer.GetLength(mData, colPos), 
                                mBuffer.GetCode(mData, colPos), 
                                OCI_DEFAULT);

//       boost::format logme("::OCIDefineByPos(stmt, &p_dfn1, error, %1%, %2%, %3%, %4%, %5%, %6%, %7%, OCI_DEFAULT)");
//       logme %
//         colPos %
//         mBuffer.GetData(mData, colPos) % 
//         mBuffer.GetDataLength(colPos) % 
//         SQLT_BIN %
//         mBuffer.GetIndicator(mData, colPos) %
//         mBuffer.GetLength(mData, colPos) % 
//         mBuffer.GetCode(mData, colPos);
            
//       std::cout << logme.str().c_str() << std::endl;
            
      rc = ::OCIDefineArrayOfStruct(p_dfn1, error, mBuffer.GetSize(), mBuffer.GetSize(), mBuffer.GetSize(), mBuffer.GetSize());

      mDefineHandles.push_back(p_dfn1);
    }
    break;
    case SQLT_LBI:
      throw std::logic_error("Unsupported Oracle datatype");
      break;
    case SQLT_BFLOAT:
    case SQLT_IBFLOAT:
    case SQLT_BDOUBLE:
    case SQLT_IBDOUBLE:
    {
      OCIDefine * p_dfn1=NULL;
      int rc = ::OCIDefineByPos(stmt, &p_dfn1, error, colPos, 
                                mBuffer.GetData(mData, colPos), mBuffer.GetDataLength(colPos), SQLT_BDOUBLE, 
                                mBuffer.GetIndicator(mData, colPos), 
                                mBuffer.GetLength(mData, colPos), 
                                mBuffer.GetCode(mData, colPos), 
                                OCI_DEFAULT);

//       boost::format logme("::OCIDefineByPos(stmt, &p_dfn1, error, %1%, %2%, %3%, %4%, %5%, %6%, %7%, OCI_DEFAULT)");
//       logme %
//         colPos %
//         mBuffer.GetData(mData, colPos) % 
//         mBuffer.GetDataLength(colPos) % 
//         SQLT_BDOUBLE %
//         mBuffer.GetIndicator(mData, colPos) %
//         mBuffer.GetLength(mData, colPos) % 
//         mBuffer.GetCode(mData, colPos);
            
//       std::cout << logme.str().c_str() << std::endl;
            
      rc = ::OCIDefineArrayOfStruct(p_dfn1, error, mBuffer.GetSize(), mBuffer.GetSize(), mBuffer.GetSize(), mBuffer.GetSize());
           

      mDefineHandles.push_back(p_dfn1);
    }
    break;
    default:
      throw std::logic_error("Unsupported Oracle datatype");
    }
  }
}

OCIRecordImporter::OCIRecordImporter(const RecordMetadata& metraFlowRecord, const OCIRowBuffer& ociBuffer)
{
  mImporters = (OCIImporter *) new unsigned char [sizeof(OCIImporter)*metraFlowRecord.GetNumColumns()];
  mImportersEnd = mImporters + metraFlowRecord.GetNumColumns();
    
  for(boost::int32_t i=0; i<metraFlowRecord.GetNumColumns(); i++)
  {
    DataAccessor * metraFlowAccessor = metraFlowRecord.GetColumn(i);
      
    switch(metraFlowAccessor->GetPhysicalFieldType()->GetPipelineType())
    {
    case MTPipelineLib::PROP_TYPE_INTEGER:
      mImporters[i].Init(*metraFlowAccessor, 
                         ociBuffer.GetDataAccessor((ub4)(i+1)), 
                         &OCIImporter::ImportIntegerNumber);
      break;            
    case MTPipelineLib::PROP_TYPE_BIGINTEGER:
      mImporters[i].Init(*metraFlowAccessor, 
                         ociBuffer.GetDataAccessor((ub4)(i+1)), 
                         &OCIImporter::ImportInt64Number);
      break;            
    case MTPipelineLib::PROP_TYPE_DATETIME:
      mImporters[i].Init(*metraFlowAccessor, 
                         ociBuffer.GetDataAccessor((ub4)(i+1)), 
                         &OCIImporter::ImportDatetimeDate);
      break;            
    case MTPipelineLib::PROP_TYPE_DECIMAL:
      mImporters[i].Init(*metraFlowAccessor, 
                         ociBuffer.GetDataAccessor((ub4)(i+1)), 
                         &OCIImporter::ImportDecimalNumber);
      break;            
    case MTPipelineLib::PROP_TYPE_STRING:
      mImporters[i].Init(*metraFlowAccessor, 
                         ociBuffer.GetDataAccessor((ub4)(i+1)), 
                         &OCIImporter::ImportStringNVarchar);
      break;
    case MTPipelineLib::PROP_TYPE_ASCII_STRING:
      mImporters[i].Init(*metraFlowAccessor, 
                         ociBuffer.GetDataAccessor((ub4)(i+1)), 
                         &OCIImporter::ImportUTF8StringVarchar);
      break;
    case MTPipelineLib::PROP_TYPE_DOUBLE:
      mImporters[i].Init(*metraFlowAccessor, 
                         ociBuffer.GetDataAccessor((ub4)(i+1)), 
                         &OCIImporter::ImportDoubleBFloat);
      break;
    case MTPipelineLib::PROP_TYPE_OPAQUE:
      mImporters[i].Init(*metraFlowAccessor, 
                         ociBuffer.GetDataAccessor((ub4)(i+1)), 
                         &OCIImporter::ImportBinaryRaw);
      break;
    default:
      throw logic_error("Unsupported MetraFlow type");
            
    }
  }
}

OCIRecordImporter::~OCIRecordImporter()
{
  delete [] ((unsigned char *)mImporters);
}

OCIRecordExporter::OCIRecordExporter(const RecordMetadata& inputMetraFlowRecord,
                                     const RecordMetadata& metraFlowRecord, 
                                     const OCIRowBuffer& ociBuffer)
{
  mExporters = (OCIExporter *) new unsigned char [sizeof(OCIExporter)*metraFlowRecord.GetNumColumns()];
  mExportersEnd = mExporters + metraFlowRecord.GetNumColumns();
    
  for(boost::int32_t i=0; i<metraFlowRecord.GetNumColumns(); i++)
  {
    // TODO: Exception classes.
    if (!inputMetraFlowRecord.HasColumn(metraFlowRecord.GetColumnName(i)))
      throw std::runtime_error("OCIRecordExporter missing input field");
    DataAccessor * metraFlowAccessor = inputMetraFlowRecord.GetColumn(metraFlowRecord.GetColumnName(i));
    // TODO: Exception classes.
    if (metraFlowAccessor->GetPhysicalFieldType()->GetPipelineType() != 
        metraFlowRecord.GetColumn(i)->GetPhysicalFieldType()->GetPipelineType())
      throw std::runtime_error("OCIRecordExporter type mismatch");

    switch(metraFlowAccessor->GetPhysicalFieldType()->GetPipelineType())
    {
    case MTPipelineLib::PROP_TYPE_INTEGER:
      mExporters[i].Init(*metraFlowAccessor, 
                         ociBuffer.GetDataAccessor((ub4)(i+1)), 
                         &OCIExporter::ExportIntegerNumber);
      break;            
    case MTPipelineLib::PROP_TYPE_BIGINTEGER:
      mExporters[i].Init(*metraFlowAccessor, 
                         ociBuffer.GetDataAccessor((ub4)(i+1)), 
                         &OCIExporter::ExportInt64Number);
      break;            
    case MTPipelineLib::PROP_TYPE_DATETIME:
      mExporters[i].Init(*metraFlowAccessor, 
                         ociBuffer.GetDataAccessor((ub4)(i+1)), 
                         &OCIExporter::ExportDatetimeDate);
      break;            
    case MTPipelineLib::PROP_TYPE_DECIMAL:
      mExporters[i].Init(*metraFlowAccessor, 
                         ociBuffer.GetDataAccessor((ub4)(i+1)), 
                         &OCIExporter::ExportDecimalNumber);
      break;            
    case MTPipelineLib::PROP_TYPE_STRING:
      mExporters[i].Init(*metraFlowAccessor, 
                         ociBuffer.GetDataAccessor((ub4)(i+1)), 
                         &OCIExporter::ExportStringNVarchar);
      break;
    case MTPipelineLib::PROP_TYPE_ASCII_STRING:
      mExporters[i].Init(*metraFlowAccessor, 
                         ociBuffer.GetDataAccessor((ub4)(i+1)), 
                         &OCIExporter::ExportUTF8StringVarchar);
      break;
    case MTPipelineLib::PROP_TYPE_DOUBLE:
      mExporters[i].Init(*metraFlowAccessor, 
                         ociBuffer.GetDataAccessor((ub4)(i+1)), 
                         &OCIExporter::ExportDoubleBFloat);
      break;            
    case MTPipelineLib::PROP_TYPE_OPAQUE:
      mExporters[i].Init(*metraFlowAccessor, 
                         ociBuffer.GetDataAccessor((ub4)(i+1)), 
                         &OCIExporter::ExportBinaryRaw);
      break;            
    default:
      throw logic_error("Unsupported MetraFlow type");
            
    }
  }
}

OCIRecordExporter::~OCIRecordExporter()
{
  delete [] ((unsigned char *)mExporters);
}

OraclePreparedStatement::OraclePreparedStatement(OCISvcCtx * svc,
                                                 OCIStmt * stmt, 
                                                 OCIError * error, 
                                                 const RecordMetadata& parameterMetadata, 
                                                 const RecordMetadata& tableMetadata, 
                                                 OCIRowBuffer& buffer,
                                                 ub4 rows)
  :
  mMaxRow(0),
  mCurrentRow(0),
  mData(0),
  mRowSize(0),
  mExporter(parameterMetadata, tableMetadata, buffer),
  mSvc(svc),
  mStmt(stmt),
  mError(error),
  mBinding(stmt, error, buffer, rows)
{
  mData = mBinding.GetDataBuffer();
  mRowSize = buffer.GetSize();

  mCurrentRow = mData;
  mMaxRow = mData + mBinding.GetRows()*mRowSize;


}

OraclePreparedStatement::~OraclePreparedStatement()
{
  if (mStmt != 0) ::OCIHandleFree((dvoid *) mStmt, OCI_HTYPE_STMT);    /* Free handles */
}

void OraclePreparedStatement::InternalExecuteBatch()
{
  int rc;
  rc = ::OCIStmtExecute(mSvc, mStmt, mError, (ub4) ((mCurrentRow-mData)/mRowSize), (ub4) 0,
                        (CONST OCISnapshot *) NULL, (OCISnapshot *) NULL, OCI_DEFAULT);

  if (rc != 0) {
    sb4 errcode;
    text errbuf[512];
    ::OCIErrorGet((dvoid *)mError, (ub4) 1, (text *) NULL, &errcode, errbuf, (ub4) sizeof(errbuf), OCI_HTYPE_ERROR);
    throw std::runtime_error((const char *)errbuf);
  }

  mCurrentRow = mData;
}

void OraclePreparedStatement::AddBatch(const_record_t metraFlowRecord)
{
  if (mCurrentRow >= mMaxRow)
  {
    InternalExecuteBatch();
  }
  mExporter.Export(mCurrentRow, metraFlowRecord);
  mCurrentRow += mRowSize;
}

void OraclePreparedStatement::ExecuteBatch()
{
  InternalExecuteBatch();
}

OracleResultSet::OracleResultSet(OCISvcCtx * svc,
                                 OCIStmt * stmt, 
                                 OCIError * error, 
                                 const RecordMetadata& metadata, 
                                 OCIRowBuffer& buffer,
                                 ub4 rows)
  :
  mMaxRow(0),
  mCurrentRow(0),
  mData(0),
  mRowSize(0),
  mCanFetch(true),
  mImporter(metadata, buffer),
  mStmt(stmt),
  mError(error),
  mMetadata(metadata),
  mDefinition(stmt, error, buffer, rows)
{
  mData = mDefinition.GetDataBuffer();
  mRowSize = buffer.GetSize();

  int rc;
  rc = ::OCIStmtExecute(svc, mStmt, mError, (ub4) mDefinition.GetRows(), (ub4) 0,
                        (CONST OCISnapshot *) NULL, (OCISnapshot *) NULL, OCI_DEFAULT);

  // Remember if we got OCI_NO_DATA to avoid ORA-01002: fetch out of sequence
  mCanFetch = (rc == 0);

  if (rc != 0 && rc != OCI_NO_DATA) {
    sb4 errcode;
    text errbuf[512];
    ::OCIErrorGet((dvoid *)mError, (ub4) 1, (text *) NULL, &errcode, errbuf, (ub4) sizeof(errbuf), OCI_HTYPE_ERROR);
    throw std::runtime_error((const char *)errbuf);
  }
  ub4 rowsFetched=0;
  ub4 sz = sizeof(rowsFetched);
  rc = ::OCIAttrGet(mStmt, OCI_HTYPE_STMT, (dvoid *) &rowsFetched, &sz, OCI_ATTR_ROWS_FETCHED, mError);
  mCurrentRow = mData;
  mMaxRow = mData + rowsFetched*mRowSize;
}

OracleResultSet::~OracleResultSet()
{
  if (mStmt != 0) ::OCIHandleFree((dvoid *) mStmt, OCI_HTYPE_STMT);    /* Free handles */
}

const RecordMetadata& OracleResultSet::Describe() const
{
  return mMetadata;
}

record_t OracleResultSet::Next()
{
  if (mCurrentRow == mMaxRow)
  {
    if (mCanFetch)
    {
      int rc = ::OCIStmtFetch2(mStmt, mError, mDefinition.GetRows(), OCI_DEFAULT, 0, OCI_DEFAULT);

      // If we get OCI_NO_DATA or error then we are done.
      mCanFetch = (rc==0);

      if (rc != 0 && rc != OCI_NO_DATA) {
        sb4 errcode;
        text errbuf[512];
        ::OCIErrorGet((dvoid *)mError, (ub4) 1, (text *) NULL, &errcode, errbuf, (ub4) sizeof(errbuf), OCI_HTYPE_ERROR);
        throw std::runtime_error((const char *)errbuf);
      }
      ub4 rowsFetched = 0;
      ub4 sz = sizeof(rowsFetched);
      rc = ::OCIAttrGet(mStmt, OCI_HTYPE_STMT, (dvoid *) &rowsFetched, &sz, OCI_ATTR_ROWS_FETCHED, mError);
      if (rc != 0) {
        sb4 errcode;
        text errbuf[512];
        ::OCIErrorGet((dvoid *)mError, (ub4) 1, (text *) NULL, &errcode, errbuf, (ub4) sizeof(errbuf), OCI_HTYPE_ERROR);
        throw std::runtime_error((const char *) errbuf);
      }
      mCurrentRow = mData;
      mMaxRow = mData + rowsFetched*mRowSize;

      // Data in the database was an exact integer number of buffers.
      if (0 == rowsFetched)
      {
        return mMetadata.AllocateEOF();
      }
    }
    else
    {
      return mMetadata.AllocateEOF();
    }
  }
  
  ASSERT(mCurrentRow < mMaxRow);
  record_t metraFlowRecord = mMetadata.Allocate();
  mImporter.Import(mCurrentRow, metraFlowRecord);
  mCurrentRow += mRowSize;
  return metraFlowRecord;
}

OracleConnection::OracleConnection(const std::string& username,
                                   const std::string& password,
                                   const std::string& server,
                                   const std::string& trace)
  :
  p_env(NULL),
  p_err(NULL),
  p_svc(NULL)
{
  Init(username, password, server, trace);
}

OracleConnection::OracleConnection(const std::string& username,
                                   const std::string& password,
                                   const std::string& server)
  :
  p_env(NULL),
  p_err(NULL),
  p_svc(NULL)
{
  Init(username, password, server, "");
}

void OracleConnection::Init(const std::string& username,
                            const std::string& password,
                            const std::string& server,
                            const std::string& trace)
{
  int rc;

  rc = ::OCIEnvNlsCreate(&p_env,
                         OCI_DEFAULT, /* should we sue OCI_THREADED */
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0,
                         0);

  if (rc != 0)
  {
    std::cerr << "OCIEnvNlsCreate failed: " << rc << std::endl;
    return;
  }

//   std::cout << "OCIEnvNlsCreate succeeded" << std::endl;
  
  
                         
   /* Initialize handles */
   rc = ::OCIHandleAlloc( (dvoid *) p_env, (dvoid **) &p_err, OCI_HTYPE_ERROR,
           (size_t) 0, (dvoid **) 0);
   rc = ::OCIHandleAlloc( (dvoid *) p_env, (dvoid **) &p_svc, OCI_HTYPE_SVCCTX,
           (size_t) 0, (dvoid **) 0);

   /* Connect to database server */
   rc = ::OCILogon(p_env, p_err, &p_svc, 
                   (const OraText *) username.c_str(), username.size(), 
                   (const OraText *) password.c_str(), password.size(), 
                   (const OraText *) server.c_str(), server.size());

//    std::cout << "Successfully logged on " << std::endl;
   if (trace.size() > 0)
  {
    OCIStmt * pStmt = NULL;
    /* Allocate and prepare SQL statement */
    int rc = ::OCIHandleAlloc( (dvoid *) p_env, (dvoid **) &pStmt,
                           OCI_HTYPE_STMT, (size_t) 0, (dvoid **) 0);
    std::string alter("ALTER SESSION SET timed_statistics=true");
    rc = ::OCIStmtPrepare(pStmt, p_err, 
                          (const OraText *)alter.c_str(), (ub4) alter.size(), 
                          (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT);
    rc = ::OCIStmtExecute(p_svc, pStmt, p_err, (ub4) 1, (ub4) 0,
                          (CONST OCISnapshot *) NULL, (OCISnapshot *) NULL, OCI_DEFAULT);
    alter = "ALTER SESSION SET max_dump_file_size=unlimited";
    rc = ::OCIStmtPrepare(pStmt, p_err, 
                          (const OraText *)alter.c_str(), (ub4) alter.size(), 
                          (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT);
    rc = ::OCIStmtExecute(p_svc, pStmt, p_err, (ub4) 1, (ub4) 0,
                          (CONST OCISnapshot *) NULL, (OCISnapshot *) NULL, OCI_DEFAULT);
    alter = (boost::format("ALTER SESSION SET tracefile_identifier=%1%") % trace).str();
    rc = ::OCIStmtPrepare(pStmt, p_err, 
                          (const OraText *)alter.c_str(), (ub4) alter.size(), 
                          (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT);
    rc = ::OCIStmtExecute(p_svc, pStmt, p_err, (ub4) 1, (ub4) 0,
                          (CONST OCISnapshot *) NULL, (OCISnapshot *) NULL, OCI_DEFAULT);
    alter = "ALTER SESSION SET events '10046 trace name context forever, level 8'";
    rc = ::OCIStmtPrepare(pStmt, p_err, 
                          (const OraText *)alter.c_str(), (ub4) alter.size(), 
                          (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT);
    rc = ::OCIStmtExecute(p_svc, pStmt, p_err, (ub4) 1, (ub4) 0,
                          (CONST OCISnapshot *) NULL, (OCISnapshot *) NULL, OCI_DEFAULT);
    alter = "ALTER SESSION SET SQL_TRACE=TRUE";
    rc = ::OCIStmtPrepare(pStmt, p_err, 
                          (const OraText *)alter.c_str(), (ub4) alter.size(), 
                          (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT);
    rc = ::OCIStmtExecute(p_svc, pStmt, p_err, (ub4) 1, (ub4) 0,
                          (CONST OCISnapshot *) NULL, (OCISnapshot *) NULL, OCI_DEFAULT);
    rc = OCIHandleFree((dvoid *) pStmt, OCI_HTYPE_STMT);    /* Free handles */
  }
}

OracleConnection::~OracleConnection()
{
  int rc;
  if (p_svc && p_err) rc = OCILogoff(p_svc, p_err);                           /* Disconnect */
  if (p_svc) rc = OCIHandleFree((dvoid *) p_svc, OCI_HTYPE_SVCCTX);
  if (p_err) rc = OCIHandleFree((dvoid *) p_err, OCI_HTYPE_ERROR);
}

void OracleConnection::ExecuteNonQuery(const std::string& stmt)
{
  OCIStmt *pStmt=NULL;
  int rc;
  /* Allocate and prepare SQL statement */
  rc = ::OCIHandleAlloc( (dvoid *) p_env, (dvoid **) &pStmt,
                         OCI_HTYPE_STMT, (size_t) 0, (dvoid **) 0);
  rc = ::OCIStmtPrepare(pStmt, p_err, 
                        (const OraText *)stmt.c_str(), (ub4) stmt.size(), 
                        (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT);
  rc = ::OCIStmtExecute(p_svc, pStmt, p_err, (ub4) 1, (ub4) 0,
                        (CONST OCISnapshot *) NULL, (OCISnapshot *) NULL, OCI_DEFAULT);

  rc = ::OCITransCommit(p_svc, p_err, OCI_DEFAULT);
  rc = OCIHandleFree((dvoid *) pStmt, OCI_HTYPE_STMT);    /* Free handles */
}

void OracleConnection::DescribeQuery(const std::string& query, RecordMetadata & metadata)
{
  OCIStmt * p_sql=NULL;
  int rc;
  /* Allocate and prepare SQL statement */
  rc = ::OCIHandleAlloc( (dvoid *) p_env, (dvoid **) &p_sql,
                         OCI_HTYPE_STMT, (size_t) 0, (dvoid **) 0);
  rc = ::OCIStmtPrepare(p_sql, p_err, 
                        (const OraText *) query.c_str(), (ub4) query.size(),
                        (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT);
  rc = ::OCIStmtExecute(p_svc, p_sql, p_err, (ub4) 1, (ub4) 0,
                        (CONST OCISnapshot *) NULL, (OCISnapshot *) NULL, OCI_DESCRIBE_ONLY);
  

  OCIRecordMetadataVisitor metadataVisitor(metadata);
  ::BindOCIRecord(p_env, p_sql, p_err, metadataVisitor);
  
  rc = OCIHandleFree((dvoid *) p_sql, OCI_HTYPE_STMT);    /* Free handles */
}

OraclePreparedStatement * OracleConnection::PrepareInsertStatement(const std::string& table, const RecordMetadata& parameters)
{
  OCIStmt * p_sql=NULL;

  // Enable tracing for inserts
//   {
//     OCIStmt * pStmt = NULL;
//     /* Allocate and prepare SQL statement */
//     int rc = ::OCIHandleAlloc( (dvoid *) p_env, (dvoid **) &pStmt,
//                            OCI_HTYPE_STMT, (size_t) 0, (dvoid **) 0);
//     std::string alter("ALTER SESSION SET timed_statistics=true");
//     rc = ::OCIStmtPrepare(pStmt, p_err, 
//                           (const OraText *)alter.c_str(), (ub4) alter.size(), 
//                           (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT);
//     rc = ::OCIStmtExecute(p_svc, pStmt, p_err, (ub4) 1, (ub4) 0,
//                           (CONST OCISnapshot *) NULL, (OCISnapshot *) NULL, OCI_DEFAULT);
//     alter = "ALTER SESSION SET max_dump_file_size=unlimited";
//     rc = ::OCIStmtPrepare(pStmt, p_err, 
//                           (const OraText *)alter.c_str(), (ub4) alter.size(), 
//                           (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT);
//     rc = ::OCIStmtExecute(p_svc, pStmt, p_err, (ub4) 1, (ub4) 0,
//                           (CONST OCISnapshot *) NULL, (OCISnapshot *) NULL, OCI_DEFAULT);
//     alter = "ALTER SESSION SET tracefile_identifier=PERFTEST";
//     rc = ::OCIStmtPrepare(pStmt, p_err, 
//                           (const OraText *)alter.c_str(), (ub4) alter.size(), 
//                           (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT);
//     rc = ::OCIStmtExecute(p_svc, pStmt, p_err, (ub4) 1, (ub4) 0,
//                           (CONST OCISnapshot *) NULL, (OCISnapshot *) NULL, OCI_DEFAULT);
//     alter = "ALTER SESSION SET events '10046 trace name context forever, level 8'";
//     rc = ::OCIStmtPrepare(pStmt, p_err, 
//                           (const OraText *)alter.c_str(), (ub4) alter.size(), 
//                           (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT);
//     rc = ::OCIStmtExecute(p_svc, pStmt, p_err, (ub4) 1, (ub4) 0,
//                           (CONST OCISnapshot *) NULL, (OCISnapshot *) NULL, OCI_DEFAULT);
// //      alter = "ALTER SESSION SET timed_os_statistics=5";
// //      rc = ::OCIStmtPrepare(pStmt, p_err, 
// //                            (const OraText *)alter.c_str(), (ub4) alter.size(), 
// //                            (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT);
// //      rc = ::OCIStmtExecute(p_svc, pStmt, p_err, (ub4) 1, (ub4) 0,
// //                            (CONST OCISnapshot *) NULL, (OCISnapshot *) NULL, OCI_DEFAULT);
// //      alter = "ALTER SESSION SET STATISTICS_LEVEL=ALL";
// //      rc = ::OCIStmtPrepare(pStmt, p_err, 
// //                            (const OraText *)alter.c_str(), (ub4) alter.size(), 
// //                            (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT);
// //      rc = ::OCIStmtExecute(p_svc, pStmt, p_err, (ub4) 1, (ub4) 0,
// //                            (CONST OCISnapshot *) NULL, (OCISnapshot *) NULL, OCI_DEFAULT);
//     alter = "ALTER SESSION SET SQL_TRACE=TRUE";
//     rc = ::OCIStmtPrepare(pStmt, p_err, 
//                           (const OraText *)alter.c_str(), (ub4) alter.size(), 
//                           (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT);
//     rc = ::OCIStmtExecute(p_svc, pStmt, p_err, (ub4) 1, (ub4) 0,
//                           (CONST OCISnapshot *) NULL, (OCISnapshot *) NULL, OCI_DEFAULT);
//     rc = OCIHandleFree((dvoid *) pStmt, OCI_HTYPE_STMT);    /* Free handles */
//   }

  std::string query("select * from " + table);
  int rc;
  /* Allocate and prepare SQL statement */
  rc = ::OCIHandleAlloc( (dvoid *) p_env, (dvoid **) &p_sql,
                         OCI_HTYPE_STMT, (size_t) 0, (dvoid **) 0);
  rc = ::OCIStmtPrepare(p_sql, p_err, 
                        (const OraText *) query.c_str(), (ub4) query.size(),
                        (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT);
  rc = ::OCIStmtExecute(p_svc, p_sql, p_err, (ub4) 1, (ub4) 0,
                        (CONST OCISnapshot *) NULL, (OCISnapshot *) NULL, OCI_DESCRIBE_ONLY);
  
  // TODO: compare metadata to make sure it is compatible!
  RecordMetadata metadata;
  OCIRecordMetadataVisitor metadataVisitor(metadata);
  ::BindOCIRecord(p_env, p_sql, p_err, metadataVisitor);
  
  OCIBufferVisitor bufferVisitor;
  ::BindOCIRecord(p_env, p_sql, p_err, bufferVisitor);
  OCIRowBuffer buffer;
  bufferVisitor.GetProduct(buffer);

  // Construct the insert statement
  query = "insert into " + table + " values (";
  for (boost::int32_t i=0; i<metadata.GetNumColumns(); i++)
  {
    if (i>0) 
      query += ", ";
    query += (boost::format(":%1%") % (i+1)).str();
  }
  query += ")";

  rc = ::OCIStmtPrepare(p_sql, p_err, 
                        (const OraText *) query.c_str(), (ub4) query.size(),
                        (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT);

  return new OraclePreparedStatement(p_svc, p_sql, p_err, parameters, metadata, buffer, 1000);
}

OracleResultSet * OracleConnection::ExecuteQuery(const std::string& query)
{
  OCIStmt * p_sql=NULL;
  int rc;
  /* Allocate and prepare SQL statement */
  rc = ::OCIHandleAlloc( (dvoid *) p_env, (dvoid **) &p_sql,
                         OCI_HTYPE_STMT, (size_t) 0, (dvoid **) 0);
  rc = ::OCIStmtPrepare(p_sql, p_err, 
                        (const OraText *) query.c_str(), (ub4) query.size(),
                        (ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT);
  rc = ::OCIStmtExecute(p_svc, p_sql, p_err, (ub4) 1, (ub4) 0,
                        (CONST OCISnapshot *) NULL, (OCISnapshot *) NULL, OCI_DESCRIBE_ONLY);
  
  RecordMetadata metadata;
  OCIRecordMetadataVisitor metadataVisitor(metadata);
  ::BindOCIRecord(p_env, p_sql, p_err, metadataVisitor);
  
  OCIBufferVisitor bufferVisitor;
  ::BindOCIRecord(p_env, p_sql, p_err, bufferVisitor);
  OCIRowBuffer buffer;
  bufferVisitor.GetProduct(buffer);

  return new OracleResultSet(p_svc, p_sql, p_err, metadata, buffer, 1000);
}

void OracleConnection::CommitTransaction()
{
  ::OCITransCommit(p_svc, p_err, OCI_DEFAULT);
}



DesignTimeOCIDatabaseInsert::DesignTimeOCIDatabaseInsert()
  :
  mBatchSize(1000),
  mCommitSize(1000)
{
  mInputPorts.insert(this, 0, L"input", false);
}

DesignTimeOCIDatabaseInsert::~DesignTimeOCIDatabaseInsert()
{
}

void DesignTimeOCIDatabaseInsert::type_check()
{
  const RecordMetadata * metadata = mInputPorts[0]->GetMetadata();

  COdbcConnectionInfo netMeter = COdbcConnectionManager::GetConnectionInfo("NetMeter"); 
  if (!netMeter.IsOracle())
    throw std::logic_error("OCI Database Insert only supports Oracle connections");

  // TODO: Support writing to stage.

  std::auto_ptr<COdbcConnection> conn (new COdbcConnection(netMeter));
  std::string utf8prefix = COdbcConnectionManager::GetConnectionInfo("NetMeter").GetCatalogPrefix();
  std::wstring prefix;
  ::ASCIIToWide(prefix, utf8prefix);

  for(std::vector<std::wstring>::const_iterator tblit = mTableNames.begin();
      tblit != mTableNames.end();
      ++tblit)
  {
    std::wstring prefixedTable = prefix + *tblit;

    std::auto_ptr<COdbcPreparedArrayStatement> stmt(conn->PrepareStatement(L"SELECT * FROM " + prefixedTable));
    const COdbcColumnMetadataVector& v(stmt->GetMetadata());

    // OK, we've got the record metadata, bind to the table.
    for(COdbcColumnMetadataVector::const_iterator it = v.begin();
        it != v.end();
        it++)
    {
      std::string utf8TargetName = (*it)->GetColumnName();
      boost::to_upper(utf8TargetName);
      std::wstring targetName;
      ::ASCIIToWide(targetName, utf8TargetName);
      if (!metadata->HasColumn(targetName))
      {
        throw MissingFieldException(*this, *mInputPorts[0], targetName);
      }
      // Check types.
      CheckTypeCompatibility(*this, *mInputPorts[0], **it, *metadata->GetColumn(targetName));
    }
  }
}

RunTimeOperator * DesignTimeOCIDatabaseInsert::code_generate(partition_t maxPartition)
{
  return new RunTimeOCIDatabaseInsert(GetName(), mTableNames, mBatchSize, mCommitSize, mTracePrefix, *mInputPorts[0]->GetMetadata());
}

void DesignTimeOCIDatabaseInsert::CheckTypeCompatibility(const DesignTimeOperator& op, const Port& port,
                                                      const COdbcColumnMetadata& db, const DataAccessor& accessor)
{
  switch(accessor.GetPhysicalFieldType()->GetPipelineType())
  {
  case MTPipelineLib::PROP_TYPE_INTEGER: 
  {
    if (db.GetDataType() != eInteger)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
	case MTPipelineLib::PROP_TYPE_DOUBLE: 
  {
    if (db.GetDataType() != eDouble)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
	case MTPipelineLib::PROP_TYPE_STRING: 
  {
    if (db.GetDataType() != eWideString)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
	case MTPipelineLib::PROP_TYPE_DATETIME: 
  {
    if (db.GetDataType() != eDatetime)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
	case MTPipelineLib::PROP_TYPE_TIME: 
  {
    if (db.GetDataType() != eInteger)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
	case MTPipelineLib::PROP_TYPE_BOOLEAN: 
  {
    if (db.GetDataType() != eString)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
	case MTPipelineLib::PROP_TYPE_ENUM: 
  {
    if (db.GetDataType() != eInteger)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
	case MTPipelineLib::PROP_TYPE_DECIMAL: 
  {
    if (db.GetDataType() != eDecimal)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
  case MTPipelineLib::PROP_TYPE_ASCII_STRING: 
  {
    if (db.GetDataType() != eString)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING: 
  {
    if (db.GetDataType() != eWideString)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
  case MTPipelineLib::PROP_TYPE_BIGINTEGER: 
  {
    if (db.GetDataType() != eBigInteger)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
	case MTPipelineLib::PROP_TYPE_OPAQUE: 
  {
    if (db.GetDataType() != eBinary)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
	default: throw std::exception("Unsupported data type");
  }
}

RunTimeOCIDatabaseInsert::RunTimeOCIDatabaseInsert ()
  :
  mBatchSize(0),
  mCommitSize(0),
  mState(START),
  mInputMessage(NULL),
  mConnection(NULL),
  mCurrentBatchCount(0),
  mCurrentTransactionCount(0),
  mNumRead(0LL)
{
}

RunTimeOCIDatabaseInsert::RunTimeOCIDatabaseInsert (Reactor * reactor, 
                                                    const std::wstring& name, 
                                                    partition_t partition, 
                                                    const std::vector<std::wstring> & tableNames,
                                                    boost::int32_t batchSize,
                                                    boost::int32_t commitSize,
                                                    const std::string& tracePrefix,
                                                    const RecordMetadata& metadata)

  :
  RunTimeOperator(reactor, name, partition),
  mTableNames(tableNames),
  mBatchSize(batchSize),
  mCommitSize(commitSize),
  mMetadata(metadata),
  mTracePrefix(tracePrefix),
  mState(START),
  mInputMessage(NULL),
  mConnection(NULL),
  mCurrentBatchCount(0),
  mCurrentTransactionCount(0),
  mNumRead(0LL)
{
}

RunTimeOCIDatabaseInsert::~RunTimeOCIDatabaseInsert()
{
  try
  {
    Close();
  }
  catch(...)
  {
  }
}

void RunTimeOCIDatabaseInsert::Close()
{
  if (mStatements.size() > 0)
  {
    if (mCurrentBatchCount > 0)
    {
      for(std::vector<OraclePreparedStatement *>::iterator it=mStatements.begin();
          it != mStatements.end();
          ++it)
      {
        (*it)->ExecuteBatch();
      }
      mCurrentBatchCount = 0;
    }
    if (mCurrentTransactionCount > 0)
    {
      mConnection->CommitTransaction();
      mCurrentTransactionCount = 0;
    }
    for(std::vector<OraclePreparedStatement *>::iterator it=mStatements.begin();
        it != mStatements.end();
        ++it)
    {
      delete (*it);
    }
    mStatements.clear();
  }
  delete mConnection;
  mConnection = NULL;
}

void RunTimeOCIDatabaseInsert::Start()
{
  COdbcConnectionInfo netMeter = COdbcConnectionManager::GetConnectionInfo("NetMeter"); 
  mConnection = new OracleConnection(netMeter.GetUserName(), netMeter.GetPassword(), netMeter.GetServer(), mTracePrefix);
  for(std::vector<std::wstring>::const_iterator it = mTableNames.begin();
      it != mTableNames.end();
      ++it)
  {
    std::string utf8Table;
    ::WideStringToUTF8(*it, utf8Table);
    mStatements.push_back(mConnection->PrepareInsertStatement(utf8Table, mMetadata));
  }

  // Enable tracing for inserts
//   boost::shared_ptr<COdbcStatement>(mConnection->CreateStatement())->ExecuteUpdate("ALTER SESSION SET timed_statistics=true");
//   boost::shared_ptr<COdbcStatement>(mConnection->CreateStatement())->ExecuteUpdate("ALTER SESSION SET max_dump_file_size=unlimited");
//   boost::shared_ptr<COdbcStatement>(mConnection->CreateStatement())->ExecuteUpdate("ALTER SESSION SET tracefile_identifier=PERFTEST");
//   boost::shared_ptr<COdbcStatement>(mConnection->CreateStatement())->ExecuteUpdate("ALTER SESSION SET events '10046 trace name context forever, level 8'");
//   boost::shared_ptr<COdbcStatement>(mConnection->CreateStatement())->ExecuteUpdate("ALTER SESSION SET SQL_TRACE=TRUE");

  mState = START;
  HandleEvent(NULL);
}

void RunTimeOCIDatabaseInsert::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    while(true)
    {
      RequestRead(0);
      mState = READ_0;
      return;
    case READ_0:
      ASSERT(ep == mInputs[0]);
      Read(mInputMessage, ep);
      if(!mMetadata.IsEOF(mInputMessage))
      {
        for(std::vector<OraclePreparedStatement *>::iterator it=mStatements.begin();
            it != mStatements.end();
            ++it)
        {
          (*it)->AddBatch(mInputMessage);
        }

        // Increment counters.
        mNumRead++;
        mCurrentBatchCount++;
        mCurrentTransactionCount++;

        // End of the road for this message.
        mMetadata.Free(mInputMessage); 

        // Check if batch is completed.
        if(mCurrentBatchCount >= mBatchSize)
        {
          for(std::vector<OraclePreparedStatement *>::iterator it=mStatements.begin();
              it != mStatements.end();
              ++it)
          {
            (*it)->ExecuteBatch();
          }
          mCurrentBatchCount = 0;

          // Check if time to commit.
          if (mCurrentTransactionCount >= mCommitSize)
          {
            mConnection->CommitTransaction();
            mCurrentTransactionCount = 0;
          }
        }
      }
      else 
      {
        // We're all done
        mMetadata.Free(mInputMessage); 
        Close();
        return;
      }
    }
  }
}
