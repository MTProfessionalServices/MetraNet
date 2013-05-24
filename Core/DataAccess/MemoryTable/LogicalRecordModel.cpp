#include "LogicalRecordModel.h"
#include "RecordModel.h"
#include "MTSQLParam.h"
#include "MTUtil.h"
#include "SharedDefs.h"

#include <boost/format.hpp>
#include <boost/tokenizer.hpp>

FieldMap::FieldMap()
{
}

FieldMap::FieldMap(const FieldMap& fm)
  :
  mMemberMap(fm.mMemberMap)
{
}

FieldMap::FieldMap(const FieldMap& a, const FieldMap& b)
{
  for(FieldMap::const_iterator it = a.begin();
      it != a.end();
      ++it)
  {
    mMemberMap[it->first] = b.Apply(it->second);
  }
}

FieldMap::~FieldMap()
{
}

void FieldMap::Add(const RecordMember& from, const RecordMember& to)
{
  mMemberMap[from.GetName()] = to.GetName();
}

const std::wstring& FieldMap::Apply(const std::wstring& fieldName) const
{
  return mMemberMap.find(fieldName)->second;
}

FieldMap::const_iterator FieldMap::begin() const
{
  return mMemberMap.begin();
}

FieldMap::const_iterator FieldMap::end() const
{
  return mMemberMap.end();
}

LogicalFieldType LogicalFieldType::String(bool isNullable)
{
  LogicalFieldType ty(MTPipelineLib::PROP_TYPE_STRING, 
                      std::numeric_limits<boost::int32_t>::max()/sizeof(wchar_t), 
                      true, 
                      isNullable);
  return ty;
}
LogicalFieldType LogicalFieldType::UTF8String(bool isNullable)
{
  LogicalFieldType ty(MTPipelineLib::PROP_TYPE_ASCII_STRING, 
                      std::numeric_limits<boost::int32_t>::max()/sizeof(char), 
                      true, 
                      isNullable);
  return ty;
}

LogicalFieldType::LogicalFieldType()
  :
  mPipelineType(MTPipelineLib::PROP_TYPE_INTEGER),
  mMaxLength(0),
  mIsVariableLength(false),
  mIsNullable(false)
{
}

LogicalFieldType::LogicalFieldType(MTPipelineLib::PropValType pipelineType, int maxLength, bool isVariableLength, bool isNullable)
  :
  mPipelineType(pipelineType),
  mMaxLength(maxLength),
  mIsVariableLength(isVariableLength),
  mIsNullable(isNullable)
{
  if(mMaxLength == 1)
    throw std::runtime_error("Not good");
}

LogicalFieldType::LogicalFieldType(const LogicalRecord& nestedRecord, bool isList)
  :
  mPipelineType(MTPipelineLib::PROP_TYPE_SET),
  mMaxLength(isList ? std::numeric_limits<boost::int32_t>::max() : 0),
  mIsVariableLength(isList),
  mIsNullable(true),
  mNestedRecord(nestedRecord)
{
  if(mMaxLength == 1)
    throw std::runtime_error("Not good");
}

LogicalFieldType::LogicalFieldType(const LogicalFieldType& pft)
  :
  mPipelineType(pft.mPipelineType),
  mMaxLength(pft.mMaxLength),
  mIsVariableLength(pft.mIsVariableLength),
  mIsNullable(pft.mIsNullable),
  mNestedRecord(pft.mNestedRecord)
{
  if(mMaxLength == 1)
    throw std::runtime_error("Not good");
}

// LogicalFieldType::LogicalFieldType(const PhysicalFieldType& pft, bool isNullable)
//   :
//   mPipelineType(pft.GetPipelineType()),
//   mMaxLength(pft.GetMaxLength()),
//   mIsVariableLength(false),
//   mIsNullable(isNullable)
// {
//   switch(pft.GetPipelineType())
//   {
//   case MTPipelineLib::PROP_TYPE_ASCII_STRING:
//   case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
//     mIsVariableLength = true;
//   case MTPipelineLib::PROP_TYPE_SET:
//     mIsVariableLength = pft.IsList();
//   default:
//     mIsVariableLength = false;
//   }

//   // if (mPipelineType == MTPipelineLib::PROP_TYPE_SET)
//   //   mNestedRecord = *pft.GetMetadata();
//   if(mMaxLength == 1)
//     throw std::runtime_error("Not good");
// }

LogicalFieldType::~LogicalFieldType()
{
}

const LogicalFieldType& LogicalFieldType::operator=(const LogicalFieldType & rhs)
{
  mPipelineType = rhs.mPipelineType;
  mMaxLength = rhs.mMaxLength;
  mIsVariableLength = rhs.mIsVariableLength;
  mIsNullable = rhs.mIsNullable;
  mNestedRecord = rhs.mNestedRecord;
  if(mMaxLength == 1)
    throw std::runtime_error("Not good");
  return *this;
}

LogicalFieldType LogicalFieldType::Record(const LogicalRecord& nestedRecord, bool isList, bool isNullable)
{
  LogicalFieldType ty(nestedRecord, isList);
  return ty;
}

std::wstring LogicalFieldType::GetMTSQLDatatype(MTPipelineLib::PropValType valType)
{
  switch(valType)
  {
  case MTPipelineLib::PROP_TYPE_INTEGER: return L"INTEGER";

  case MTPipelineLib::PROP_TYPE_DOUBLE: return L"DOUBLE PRECISION";

  case MTPipelineLib::PROP_TYPE_STRING: return L"NVARCHAR";

  case MTPipelineLib::PROP_TYPE_DATETIME: return L"DATETIME";

  case MTPipelineLib::PROP_TYPE_TIME: return L"DATETIME";

  case MTPipelineLib::PROP_TYPE_BOOLEAN: return L"BOOLEAN";

  case MTPipelineLib::PROP_TYPE_ENUM: return L"ENUM";

  case MTPipelineLib::PROP_TYPE_DECIMAL: return L"DECIMAL";

  case MTPipelineLib::PROP_TYPE_ASCII_STRING: return L"VARCHAR";

  case MTPipelineLib::PROP_TYPE_UNICODE_STRING: return L"NVARCHAR";

  case MTPipelineLib::PROP_TYPE_BIGINTEGER: return L"BIGINT";

  case MTPipelineLib::PROP_TYPE_OPAQUE: return L"BINARY";

  default: throw std::runtime_error("Unsupported data type");
  }
}

std::wstring LogicalFieldType::ToString() const
{
  return GetMTSQLDatatype(mPipelineType);
}

bool LogicalFieldType::operator==(const LogicalFieldType & rhs) const
{
  return mPipelineType == rhs.mPipelineType &&
    mMaxLength == rhs.mMaxLength &&
    mIsVariableLength == rhs.mIsVariableLength &&
    mIsNullable == rhs.mIsNullable &&
    mNestedRecord == rhs.mNestedRecord;
}

bool LogicalFieldType::operator!=(const LogicalFieldType & rhs) const
{
  return !this->operator==(rhs);
}

bool LogicalFieldType::CanReadAs(const LogicalFieldType & rhs) const
{
  return mPipelineType == rhs.mPipelineType &&
    mMaxLength == rhs.mMaxLength &&
    mIsVariableLength == rhs.mIsVariableLength &&
    (!mIsNullable || rhs.mIsNullable)&&
    mNestedRecord == rhs.mNestedRecord;
}

std::wstring LogicalFieldType::GetSQLServerDatatype() const
{
  std::wstring suffix(mIsNullable ? L"" : L" NOT NULL");
  switch(mPipelineType)
  {
  case MTPipelineLib::PROP_TYPE_INTEGER: return L"INTEGER" + suffix ;
    case MTPipelineLib::PROP_TYPE_DOUBLE: return L"DOUBLE PRECISION" + suffix;
    case MTPipelineLib::PROP_TYPE_STRING: return L"NVARCHAR(255)" + suffix;
    case MTPipelineLib::PROP_TYPE_DATETIME: return L"DATETIME" + suffix;
    case MTPipelineLib::PROP_TYPE_TIME: return L"DATETIME" + suffix;
    case MTPipelineLib::PROP_TYPE_BOOLEAN: return L"CHAR(1)" + suffix;
    case MTPipelineLib::PROP_TYPE_ENUM: return L"INTEGER" + suffix;
    case MTPipelineLib::PROP_TYPE_DECIMAL: return METRANET_DECIMAL_PRECISION_AND_SCALE_MAX_WSTR + suffix;
  case MTPipelineLib::PROP_TYPE_ASCII_STRING: return L"VARCHAR(255)" + suffix;
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING: return L"NVARCHAR(255)" + suffix;
  case MTPipelineLib::PROP_TYPE_BIGINTEGER: return L"BIGINT" + suffix;
    case MTPipelineLib::PROP_TYPE_OPAQUE: return L"BINARY(16)" + suffix;
    default: throw std::exception("Unsupported data type");
  }
}

std::wstring LogicalFieldType::GetOracleDatatype() const
{
  std::wstring suffix(mIsNullable ? L"" : L" NOT NULL");
  switch(mPipelineType)
  {
  case MTPipelineLib::PROP_TYPE_INTEGER: return L"NUMBER(10)" + suffix;
    case MTPipelineLib::PROP_TYPE_DOUBLE: return METRANET_NUMBER_PRECISION_AND_SCALE_MAX_WSTR + suffix;
    case MTPipelineLib::PROP_TYPE_STRING: return L"NVARCHAR2(255)" + suffix;
    case MTPipelineLib::PROP_TYPE_DATETIME: return L"DATE" + suffix;
    case MTPipelineLib::PROP_TYPE_TIME: return L"DATE" + suffix;
    case MTPipelineLib::PROP_TYPE_BOOLEAN: return L"CHAR(1)" + suffix;
    case MTPipelineLib::PROP_TYPE_ENUM: return L"NUMBER(10)" + suffix;
    case MTPipelineLib::PROP_TYPE_DECIMAL: return METRANET_NUMBER_PRECISION_AND_SCALE_MAX_WSTR + suffix;
  case MTPipelineLib::PROP_TYPE_ASCII_STRING: return L"VARCHAR(255)" + suffix;
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING: return L"NVARCHAR(255)" + suffix;
  case MTPipelineLib::PROP_TYPE_BIGINTEGER: return L"NUMBER(20)" + suffix;
    case MTPipelineLib::PROP_TYPE_OPAQUE: return L"RAW(16)" + suffix;
    default: throw std::exception("Unsupported data type");
  }
}

LogicalFieldType LogicalFieldType::Get(const MTSQLParam& param)
{
  switch(param.GetType())
  {
  case MTSQLParam::TYPE_INVALID: throw std::runtime_error("TYPE_INVALID seen in Expresssion");
  case MTSQLParam::TYPE_INTEGER: return LogicalFieldType::Integer(true);
  case MTSQLParam::TYPE_DOUBLE: return LogicalFieldType::Double(true);
  case MTSQLParam::TYPE_STRING: return LogicalFieldType::UTF8String(true);
  case MTSQLParam::TYPE_BOOLEAN: return LogicalFieldType::Boolean(true);
  case MTSQLParam::TYPE_DECIMAL: return LogicalFieldType::Decimal(true);
  case MTSQLParam::TYPE_DATETIME: return LogicalFieldType::Datetime(true);
  case MTSQLParam::TYPE_TIME: return LogicalFieldType::Datetime(true); 
  case MTSQLParam::TYPE_ENUM: return LogicalFieldType::Enum(true);
  case MTSQLParam::TYPE_WSTRING: return LogicalFieldType::String(true);
  case MTSQLParam::TYPE_NULL: throw std::runtime_error("TYPE_INVALID seen in Expresssion");
  case MTSQLParam::TYPE_BIGINTEGER: return LogicalFieldType::BigInteger(true);
  case MTSQLParam::TYPE_BINARY: return LogicalFieldType::Binary(true);
  default: throw std::runtime_error("Invalid MTSQL type seen in Expression");
  }
}

RecordMember::RecordMember()
{
}

bool RecordMember::operator==(const RecordMember& rhs) const
{
  return mName == rhs.mName && mType == rhs.mType;
}

bool RecordMember::IsValidTopLevelName(const std::wstring& name)
{
  // I'd like to be much more restrictive, 
  // but am worried about backward compatibility
  return std::wstring::npos == name.find_first_of(LogicalRecord::GetFieldSeparator());
}

static LogicalRecord sEmpty;
const LogicalRecord& LogicalRecord::Get()
{
  return sEmpty;
}

static std::wstring sSeparator(L".");
const std::wstring& LogicalRecord::GetFieldSeparator()
{
  return sSeparator;
}

void LogicalRecord::Tokenize(const std::wstring& name, 
                             std::vector<std::wstring>& tokenized)
{
  typedef boost::tokenizer<boost::char_separator<wchar_t>, std::wstring::const_iterator, std::wstring> tk;
  boost::char_separator<wchar_t> sep(GetFieldSeparator().c_str());
  tk tok(name, sep);
  for(tk::iterator it = tok.begin(); it != tok.end(); ++it)
    tokenized.push_back(*it);
}

LogicalRecord::LogicalRecord()
{
}

LogicalRecord::LogicalRecord(const LogicalRecord& rhs)
  :
  mMembers(rhs.mMembers),
  mUniqueNameIndex(rhs.mUniqueNameIndex)
{
}

LogicalRecord::LogicalRecord(const std::vector<const LogicalRecord *>& toConcat)
{
  for(std::vector<const LogicalRecord *>::const_iterator it = toConcat.begin();
      it != toConcat.end();
      ++it)
  {
    for(LogicalRecord::const_iterator fieldIt = (*it)->begin();
        fieldIt != (*it)->end();
        ++fieldIt)
    {
      push_back(*fieldIt);
    }
  }
}

LogicalRecord::~LogicalRecord()
{
}

bool LogicalRecord::operator==(const LogicalRecord& rhs) const
{
  if (mMembers.size() != rhs.mMembers.size()) return false;
  for(std::size_t i=0; i<mMembers.size(); ++i)
  {
    if (!(mMembers[i] == rhs.mMembers[i])) return false;
  }
  return true;
}

void LogicalRecord::push_back(const RecordMember& member)
{
  std::wstring nameUpper = boost::to_upper_copy(member.GetName());
  if (mUniqueNameIndex.find(nameUpper) != mUniqueNameIndex.end())
  {
    std::string s;
    ::WideStringToUTF8(member.GetName(), s);
    throw std::logic_error(
          "Duplicate column names detected. You are attempting to merge "
          "two rows containing identical columns names. " 
          "Colliding column name: " + s);
  }

  mMembers.push_back(member);
  mUniqueNameIndex[nameUpper] = mMembers.size()-1;
}

void LogicalRecord::push_back(const std::wstring& name, const LogicalFieldType& ty)
{
  push_back(RecordMember(name, ty));
}

std::vector<RecordMember>::const_iterator LogicalRecord::begin() const
{
  return mMembers.begin();
}

std::vector<RecordMember>::const_iterator LogicalRecord::end() const
{
  return mMembers.end();
}

bool LogicalRecord::HasColumn(const std::wstring& name) const
{
  return mUniqueNameIndex.find(boost::to_upper_copy(name)) != mUniqueNameIndex.end();
}

bool LogicalRecord::HasColumn(const std::wstring& name, bool isRecursive) const
{
  if (isRecursive)
  {
    std::vector<std::wstring> tokd;
    Tokenize(name, tokd);
    return HasColumn(tokd);
  }
  else
  {
    return HasColumn(name);
  }
}

bool LogicalRecord::HasColumn(const std::vector<std::wstring>& name) const
{
  const LogicalRecord * ctxt = this;

  for(std::vector<std::wstring>::const_iterator it = name.begin();;)
  {
    if (false == ctxt->HasColumn(*it, false)) return false;
    const RecordMember & col(ctxt->GetColumn(*it));
    // If last part of string, then we're done.  Not sure whether we should
    // disallow accessing an entire subrecord at this point.  Probably should
    // since we don't support most operations on subrecords.
    if(++it == name.end()) return col.GetType().GetPipelineType() != MTPipelineLib::PROP_TYPE_SET;
    // Else must be searching into a subrecord.  Right now we don't allow
    // searching into a sublist but only a scalar subrecord. Pick the subrecord
    // and continue to the next level.
    if (col.GetType().GetPipelineType() != MTPipelineLib::PROP_TYPE_SET ||
        col.GetType().IsList()) return false;
    ctxt = &col.GetType().GetMetadata();
  }
  // Should never get here.
  return false;
}

const RecordMember& LogicalRecord::GetColumn(const std::wstring& name) const
{
  return mMembers[mUniqueNameIndex.find(boost::to_upper_copy(name))->second];
}

std::wstring LogicalRecord::GetRootColumn(const std::wstring& name) const
{
  std::vector<std::wstring> tokd;
  Tokenize(name, tokd);
  // Assume validity and just return root token
  return tokd[0];
}

void LogicalRecord::RenameMember(const RecordMember& member,
                                 const std::wstring& newName,
                                 const std::wstring& oldPath,
                                 const std::wstring& newPath,
                                 std::map<std::wstring, std::wstring>& primitiveTypeFieldRemapping) const
{
  std::wstring fullyQualifiedOld = oldPath.size() > 0 ? oldPath + GetFieldSeparator() + member.GetName() : member.GetName();
  std::wstring fullyQualifiedNew = newPath.size() > 0 ? newPath + GetFieldSeparator() + newName : newName;

  if (member.GetType().GetPipelineType() == MTPipelineLib::PROP_TYPE_SET && 
      !member.GetType().IsList())
  {
    // Add nothing for this member itself, recurse looking for primitive fields
    for(LogicalRecord::const_iterator it = member.GetType().GetMetadata().begin();
        it != member.GetType().GetMetadata().end();
        ++it)
    {
      RenameMember(*it, 
                   it->GetName(), 
                   fullyQualifiedOld, 
                   fullyQualifiedNew, 
                   primitiveTypeFieldRemapping);
    }
  }
  else
  {
    // Note that we take a nested collection as a primitive type for the purpose
    // of this procedure.
    primitiveTypeFieldRemapping[fullyQualifiedOld] = fullyQualifiedNew;
  }
}                                 

void LogicalRecord::Rename(const std::map<std::wstring, std::wstring>& renaming,
                           LogicalRecord& result,
                           std::map<std::wstring, std::wstring>& primitiveTypeFieldRemapping) const
{
  std::vector<std::wstring> fieldFilter;
  Rename(renaming, fieldFilter, result, primitiveTypeFieldRemapping);
}

void LogicalRecord::Rename(const std::map<std::wstring, std::wstring>& renaming,
                           const std::vector<std::wstring>& fieldFilter,
                           LogicalRecord& result,
                           std::map<std::wstring, std::wstring>& primitiveTypeFieldRemapping) const
{
  primitiveTypeFieldRemapping.clear();

  // renameOldToNew contains a mapping from old name (uppercase) to new name
  std::map<std::wstring,std::wstring> renameOldToNew;

  // renameParentNameToPrefix contains a mapping from
  std::map<std::wstring,std::wstring> renameParentNameToPrefix;

  for(std::map<std::wstring,std::wstring>::const_iterator ciit = renaming.begin();
      ciit != renaming.end();
      ++ciit)
  {
    // See if the "from" name is subrecord (contains a .)
    std::vector<std::wstring> tokd;
    Tokenize(ciit->first, tokd);
    
    if (tokd.size() == 1)
    {
      // This is a mapping from a field to another field name
      // or a mapping from a field to a subrecord (a to myRec.aaa)
      renameOldToNew[boost::to_upper_copy<std::wstring>(ciit->first)] = ciit->second;
    }
    else if (tokd.size() == 2)
    {
      // This is a subrecord reference.
      // We expect the user to give us something like this: Usage.*, _
      // This means that a field named Usage.abc becomes the field _abc
      if (tokd[1] != L"*")
      {
        std::string utf8Msg;
        ::WideStringToUTF8((boost::wformat(
          L"Renaming error. Invalid 'from' format specified. The '.' must be followed by '*'.  From field: %1%") % ciit->first).str(),
          utf8Msg);
        throw std::logic_error(utf8Msg);
      }

      // Make sure they haven't used a . in the To of the rename.
      // For example, we can only go from usage.* to new field names
      // like usage_a, usage_b.
      std::string toName;
      ::WideStringToUTF8(ciit->second, toName);
      if (toName.find(".") != string::npos)
      {
        std::string utf8Msg;
        ::WideStringToUTF8((boost::wformat(
          L"Renaming error. Invalid 'to' format specified. The from field (contains .*) indicates you are promoting subrecords to regular fields, you may not have a '.' in the to field.  To field: %1%") % ciit->second).str(),
          utf8Msg);
        throw std::logic_error(utf8Msg);
      }

      // This is a map of subrecord parent name to new record prefix.
      // For example "USAGE" to "_"
      renameParentNameToPrefix[boost::to_upper_copy<std::wstring>(tokd[0])] = ciit->second;
    }
    else
    {
      std::string utf8Msg;
      ::WideStringToUTF8((boost::wformat(
          L"Renaming error. Invalid 'from' format specified. From field: %1%") % ciit->first).str(),
          utf8Msg);
      throw std::logic_error(utf8Msg);
    }
  }

  // Convert filter to case insensitive.
  std::set<std::wstring> ciFilter;
  for(std::vector<std::wstring>::const_iterator fit = fieldFilter.begin();
      fit != fieldFilter.end();
      ++fit)
  {
    ciFilter.insert(boost::to_upper_copy<std::wstring>(*fit));
  }

  std::map<std::wstring, LogicalRecord > subrecs;

  // Allow pushing down of fields into a subrecord (provided that subrecord 
  // doesn't exist).
  
  // Iterate through all the fields in this record.
  for(const_iterator it = this->begin();
      it != this->end();
      ++it)
  {
    // Check if the field name is in our ParentNameToPrefix map.
    // For example, suppose that we have Usage.a and Usage.b. 
    // This should appear as one field: Usage that contains a sublist of a and b.
    std::map<std::wstring,std::wstring>::const_iterator unnestIt = 
      renameParentNameToPrefix.find(boost::to_upper_copy<std::wstring>(it->GetName()));
    
    // If we found the field in the ParentNameToPrefix map
    // This would be the case where the user specified for
    // example: rename["Usage.*", "blah_"] and we have a field
    // that is a sublist named "Usage".  In this case, we will
    // change the sublist "Usage" into a subrecord,
    // remapping each sublist member into the subrecord
    if (unnestIt != renameParentNameToPrefix.end())
    {
      // Check if this field is actual a sublist.
      // 
      if (it->GetType().GetPipelineType() != MTPipelineLib::PROP_TYPE_SET ||
          it->GetType().IsList())
      {
        std::string utf8Msg;
        ::WideStringToUTF8((boost::wformat(
          L"Renaming error. The from field (%1%.*) indicated this was a subrecord, but the field is NOT a subrecord.") % unnestIt->first ).str(),
          utf8Msg);
        throw std::logic_error(utf8Msg);
      }
      
      // Iterate through the sublist.
      // In our example above, we are iterating thru Usage.a, Usage.b
      for(LogicalRecord::const_iterator fieldIt = it->GetType().GetMetadata().begin();
          fieldIt != it->GetType().GetMetadata().end();
          ++fieldIt)
      {
        result.push_back(unnestIt->second + fieldIt->GetName(), fieldIt->GetType());
        if (ciFilter.size() == 0 ||
        ciFilter.end() != ciFilter.find(boost::to_upper_copy(it->GetName())))
          RenameMember(*fieldIt,              // Example: a
               unnestIt->second +     //          blah_ + 
             fieldIt->GetName(),  //          a
               it->GetName(),         //          Usage
               L"", 
               primitiveTypeFieldRemapping);
      }
    }
    else
    {
      // Check if this field is in the rename map
      std::map<std::wstring,std::wstring>::const_iterator mapIt = 
        renameOldToNew.find(boost::to_upper_copy<std::wstring>(it->GetName()));

      // If it is in the map, get the new name.
      // Otherwise just pretend the new name is the same as the old.
      std::wstring newName = mapIt == renameOldToNew.end() ? it->GetName() : mapIt->second;

      // Check if the new name refers to subrecord
      // Example (a renamed to myRec.aaa)
      std::vector<std::wstring> tokd;
      Tokenize(newName, tokd);

      if (tokd.size() == 1)
      {
    // No subrecords.  Just a normal rename
        result.push_back(newName, it->GetType());
        if (ciFilter.size() == 0 || ciFilter.end() != ciFilter.find(boost::to_upper_copy(it->GetName())))
          RenameMember(*it, newName, L"", L"", primitiveTypeFieldRemapping);
      }
      else if (tokd.size() == 2)
      {
        // We are renaming a field to be a subrecord. Example: from=a to=myRec.aaa
        subrecs[tokd[0]].push_back(RecordMember(tokd[1], it->GetType()));
        if (ciFilter.size() == 0 || 
            ciFilter.end() != ciFilter.find(boost::to_upper_copy(it->GetName())))
          RenameMember(*it,      // Example: a
               tokd[1],          // Example: myRec
               L"", 
               tokd[0],          // Example: aaa
               primitiveTypeFieldRemapping);
      }
      else
      {
        std::string utf8Msg;
        ::WideStringToUTF8((boost::wformat(
          L"Renaming error. The 'to' field cannot specify a depth greater than 1. To field: %1%") % newName).str(),
          utf8Msg);
        throw std::logic_error(utf8Msg);
      }
    }
  }

  // Process and subrecord rearrangement
  for(std::map<std::wstring, LogicalRecord >::const_iterator it=subrecs.begin();
      it != subrecs.end();
      ++it)
  {
    result.push_back(it->first, LogicalFieldType::Record(it->second, false, false));
  }
}

void LogicalRecord::Project(const std::vector<std::wstring>& projectionColumns,
                             bool takeComplement,
                             LogicalRecord& result,
                             std::vector<std::wstring>& missingColumns) const
{
  // Blank slate.
  missingColumns.clear();

  if (takeComplement)
  {
    // Implement case insensitive filtering on column list.
    std::set<std::wstring> exclusionSet;
    for(std::vector<std::wstring>::const_iterator it = projectionColumns.begin();
        it != projectionColumns.end();
        it++)
    {
      exclusionSet.insert(boost::to_upper_copy(*it));
    }

    for(const_iterator it = this->begin(); 
        it != this->end();
        ++it)
    {
      std::wstring colName = boost::to_upper_copy(it->GetName());
      // Make sure that the column is not in the projection list.
      if (exclusionSet.end() == exclusionSet.find(colName))
      {
        result.push_back(*it);
      }
    }
  }
  else
  {
    for(std::vector<std::wstring>::const_iterator it = projectionColumns.begin();
        it != projectionColumns.end();
        it++)
    {
      // We only allow specifying projections of top level columns,
      // so don't do a recursive search for column.
      if (!this->HasColumn(*it, false))
      {
        missingColumns.push_back(*it);
        continue;
      }    
      result.push_back(this->GetColumn(*it));
    }
  }  
}

bool LogicalRecord::NestCollection(const std::wstring& nestColumn,
                                    const LogicalRecord& nestedRecord,
                                    LogicalRecord& result) const
{
  bool ret = true;
  if (this->HasColumn(nestColumn, false))
  {
    // Let everyone know that the result can't be trusted.
    // Still do our best so that a type check can continue if it wants to.
    // Create a unique name and use that as the nest column.
    boost::int32_t i = 1;
    while(true)
    {
      if (!this->HasColumn((boost::wformat(L"%1%%2%") % nestColumn % i).str(), false))
      {
        break;
      }
      i += 1;
    }
    ret = false;
  }

  for(const_iterator it = this->begin();
      it != this->end();
      ++it)
  {
    result.push_back(*it);
  }

  // Add the nested record to the parent
  result.push_back(nestColumn, 
                   LogicalFieldType::Record(nestedRecord, true, false));
  return ret;
}

bool LogicalRecord::NestColumns(const std::wstring& nestColumn,
                                const std::vector<std::wstring>& childColumns,
                                bool nestCollection,
                                LogicalRecord& result) const
{
  std::set<std::wstring> groupSet;
  // Make child lookup case insensitive and faster.
  for(std::vector<std::wstring>::const_iterator it = childColumns.begin();
      it != childColumns.end();
      ++it)
  {
    groupSet.insert(boost::to_upper_copy(*it));
  }

  LogicalRecord childRecord;
  for(const_iterator it = this->begin();
      it != this->end();
      ++it)
  {
    if(groupSet.find(boost::to_upper_copy<std::wstring>(it->GetName())) == groupSet.end())
    {
      result.push_back(*it);
    }
    else
    {
      childRecord.push_back(*it);
    }
  }

  // Add the record to the parent; nested or not depending on configuration.
  result.push_back(nestColumn, 
                   LogicalFieldType::Record(childRecord, nestCollection, false));

  return true;
}

void LogicalRecord::UnnestColumn(const std::wstring& nestColumn,
                                  LogicalRecord& result,
                                  std::vector<std::wstring>& columnCollisions) const
{
  columnCollisions.clear();

  // Column to unnest must be at top level.
  if(!this->HasColumn(nestColumn, false))
  {
    result = *this;
    // throw MissingFieldException(*this, *mInputPorts[0], nestColumn);
  }

  if(this->GetColumn(nestColumn).GetType().GetPipelineType() != MTPipelineLib::PROP_TYPE_SET ||
     !this->GetColumn(nestColumn).GetType().IsList())
  {
    // std::string utf8Msg;
    // ::WideStringToUTF8((boost::wformat(L"Field %1% of operator %2% must be a list of records") % nestColumn % mName).str(), utf8Msg);
    // throw std::logic_error(utf8Msg);
  }

  // All parent fields except the nested collection stay in the parent.
  // All nested collection fields are raised into the parent.
  // Parent fields have prefix applied.
  for(const_iterator it = begin(); it != end(); ++it)
  {
    if (boost::algorithm::iequals(it->GetName(), nestColumn)) continue;
    result.push_back(*it);
  }

  const LogicalRecord& nest(this->GetColumn(nestColumn).GetType().GetMetadata());
  for(LogicalRecord::const_iterator it = nest.begin();
      it != nest.end();
      ++it)
  {
    // Check for collisions at top level.
    if (result.HasColumn(it->GetName(), false))
    {
      columnCollisions.push_back(it->GetName());
    }
    else
    {
      result.push_back(*it);
    }
  }
}

void LogicalRecord::ColumnComplement(const std::vector<std::wstring>& columns,
                                      std::vector<std::wstring>& columnComplement,
                                      std::vector<std::wstring>& missingColumns) const
{
  columnComplement.clear();
  missingColumns.clear();

  std::map<std::wstring, bool> groupMap;
  // Make column lookup case insensitive and faster.  Also detect whether
  // there are names in the columns collection that are missing from this record structure.
  for(std::vector<std::wstring>::const_iterator it = columns.begin();
      it != columns.end();
      ++it)
  {
    // Inidicate that we have not yet matched by a column in this.
    groupMap[boost::to_upper_copy(*it)] = false;
  }

  for(const_iterator it = this->begin();
      it != this->end();
      ++it)
  {
    std::wstring upperCol = boost::to_upper_copy<std::wstring>(it->GetName());
    if(groupMap.find(upperCol) == groupMap.end())
    {
      columnComplement.push_back(it->GetName());
    }
    else
    {
      groupMap[upperCol] = true;
    }
  }

  for(std::map<std::wstring, bool>::const_iterator mapIt = groupMap.begin();
      mapIt != groupMap.end();
      ++mapIt)
  {
    if (!mapIt->second)
      missingColumns.push_back(mapIt->first);
  }
}
