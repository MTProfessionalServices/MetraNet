#ifndef __METRAFLOW_LOGICALDATAMODEL_H__
#define __METRAFLOW_LOGICALDATAMODEL_H__

#include "MetraFlowConfig.h"

// #include <boost/archive/xml_woarchive.hpp>
// #include <boost/archive/xml_wiarchive.hpp>
#include <boost/serialization/serialization.hpp>
#include <boost/serialization/string.hpp>
#include <boost/serialization/vector.hpp>
#include <boost/serialization/map.hpp>

#include <stack>

class MTSQLParam;
class PhysicalFieldType;

#if defined(WIN32)
#import <MTPipelineLib.tlb> rename("EOF", "EOFX")
#else
class MTPipelineLib
{
public:
  enum PropValType {
    PROP_TYPE_UNKNOWN = 0,
    PROP_TYPE_DEFAULT = 1,
    PROP_TYPE_INTEGER = 2,
    PROP_TYPE_DOUBLE = 3,
    PROP_TYPE_STRING = 4,
    PROP_TYPE_DATETIME = 5,
    PROP_TYPE_TIME = 6,
    PROP_TYPE_BOOLEAN = 7,
    PROP_TYPE_SET = 8,
    PROP_TYPE_OPAQUE = 9,
    PROP_TYPE_ENUM = 10,
    PROP_TYPE_DECIMAL = 11,
    PROP_TYPE_ASCII_STRING = 12,
    PROP_TYPE_UNICODE_STRING = 13,
    PROP_TYPE_BIGINTEGER = 14
  };
  typedef long IMTSQLRowsetPtr;
};
#endif

class RecordMember;
class LogicalFieldType;

class FieldMap
{
public:
  typedef std::map<std::wstring, std::wstring>::const_iterator const_iterator;
private:
  std::map<std::wstring, std::wstring> mMemberMap;
public:
  METRAFLOW_DECL FieldMap();
  METRAFLOW_DECL FieldMap(const FieldMap& fm);
  /**
   * Construct the composition of FieldMaps.  First apply a then b.
   */
  METRAFLOW_DECL FieldMap(const FieldMap& a, const FieldMap& b);
  METRAFLOW_DECL ~FieldMap();
  METRAFLOW_DECL void Add(const RecordMember& from, const RecordMember& to);
  /**
   * Not sure I want this to be the interface, but that is all I need right now.
   */
  METRAFLOW_DECL const std::wstring& Apply(const std::wstring& fieldName) const;
  METRAFLOW_DECL const_iterator begin() const;
  METRAFLOW_DECL const_iterator end() const;
};

class LogicalRecord
{
public:
  typedef std::vector<RecordMember>::const_iterator const_iterator;

  /**
   * Get Default empty record.
   */
  static const LogicalRecord& Get();

  /**
   * Separator for subrecord field names.
   */
  static const std::wstring& GetFieldSeparator();

private:
  std::vector<RecordMember> mMembers;
  /**
   * Case insensitive unique index on name of the member.
   */
  std::map<std::wstring, std::size_t> mUniqueNameIndex;

  /**
   * Tokenize a compound field name.
   */
  static void Tokenize(const std::wstring& name, std::vector<std::wstring>& tokenized);

  /**
   * Collect all renaming of primitive fields given the renaming of a member.
   * This is using the DOT syntax when renaming a subrecord (not a subrecord collection).
   */
  void RenameMember(const RecordMember& member,
                    const std::wstring& name,
                    const std::wstring& oldPath,
                    const std::wstring& newPath,
                    std::map<std::wstring, std::wstring>& primitiveTypeFieldRemapping) const;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_NVP(mMembers);
    ar & BOOST_SERIALIZATION_NVP(mUniqueNameIndex);
  }  
public:
  METRAFLOW_DECL LogicalRecord();
  METRAFLOW_DECL LogicalRecord(const LogicalRecord& rhs);
  METRAFLOW_DECL LogicalRecord(const std::vector<const LogicalRecord*>& toConcat);
  METRAFLOW_DECL ~LogicalRecord();
  METRAFLOW_DECL bool operator==(const LogicalRecord& rhs) const;
  METRAFLOW_DECL void push_back(const RecordMember& member);
  METRAFLOW_DECL void push_back(const std::wstring& name, const LogicalFieldType& ty);
  METRAFLOW_DECL std::vector<RecordMember>::const_iterator begin() const;
  METRAFLOW_DECL std::vector<RecordMember>::const_iterator end() const;
  METRAFLOW_DECL bool HasColumn(const std::wstring& name) const;
  METRAFLOW_DECL bool HasColumn(const std::wstring& name, bool isRecursive) const;
  METRAFLOW_DECL bool HasColumn(const std::vector<std::wstring>& name) const;
  METRAFLOW_DECL const RecordMember& GetColumn(const std::wstring& name) const;
  /**
   * For a field in the record that might be in a nested subrecord (not collection),
   * retrieve the top level field containing it.
   */
  METRAFLOW_DECL std::wstring GetRootColumn(const std::wstring& name) const;

  /** 
   * Create a new record with members renamed.  Note that this only handles renaming
   * from the top level of the record to either the top level or to one level down.
   * An attempt to rename a field into a preexising subrecord will fail.
   */
  METRAFLOW_DECL void Rename(const std::map<std::wstring, std::wstring>& renaming,
                             LogicalRecord& result,
                             std::map<std::wstring, std::wstring>& primitiveTypeFieldMapping) const;

  /** 
   * Create a new record with members renamed.  Note that this only handles renaming
   * at the top level of the record.
   * @param renaming The field mappings in source to target format.  The source fields
   * must be top level identifiers while the target fields may be either top level or one level nested.
   * Nesting is expressed using a DOT in the target identifier.
   * @param fieldFilter Only return entries in primitiveTypeFieldMapping that are under a top
   * level field specified in fieldFilter.  If fieldFilter is empty then return all
   * mappings.
   */
  METRAFLOW_DECL void Rename(const std::map<std::wstring, std::wstring>& renaming,
                             const std::vector<std::wstring>& fieldFilter,
                             LogicalRecord& result,
                             std::map<std::wstring, std::wstring>& primitiveTypeFieldMapping) const;

  /** 
   * If takeComplement is false, project metadata onto the list of columns.
   * If takeComplement is false, project metadata not in the list of columns.
   * Column names are case insensitive.
   * If a column name is not found, then returns list of unresolved columns
   * in the output array.
   */
  METRAFLOW_DECL void Project(const std::vector<std::wstring>& columns,
                              bool takeComplement,
                              LogicalRecord& result,
                              std::vector<std::wstring>& missingColumns) const;

  /** 
   * Nest the record nestedRecord under a new column nestColumn in the current
   * record.  If nestColumn already exists in this, return false;
   */
  METRAFLOW_DECL bool NestCollection(const std::wstring& nestColumn,
                                     const LogicalRecord& nestedRecord,
                                     LogicalRecord& result) const;
  
  /** 
   * Nest the listed child columns in a new nest.  If nestCollection is true
   * make the children into a collection of subrecords, otherwise just make a subrecord.
   */
  METRAFLOW_DECL bool NestColumns(const std::wstring& nestColumn,
                                  const std::vector<std::wstring>& childColumns,
                                  bool nestCollection,
                                  LogicalRecord& result) const;

  /** 
   * Unnest the named column.  The named column is either a subrecord or a collection of subrecords.
   * Returns all column name collisions from the nested record in columnCollisions.
   */
  METRAFLOW_DECL void UnnestColumn(const std::wstring& nestColumn,
                                   LogicalRecord& result,
                                   std::vector<std::wstring>& columnCollisions) const;
  /**
   * Calculate the list of columns from this metadata that are not in the input
   * list. Also outputs the list of any columns in the input that are not in the 
   * metadata. TODO: Make this a bit more STL generic by using iterators or ranges.
   */
  METRAFLOW_DECL void ColumnComplement(const std::vector<std::wstring>& columns,
                                       std::vector<std::wstring>& columnComplement,
                                       std::vector<std::wstring>& missingColumns) const;
};

// Represents a storage mechanism for a logical data type.
class LogicalFieldType
{
private:
  MTPipelineLib::PropValType mPipelineType;
  // If an array structure, what is the length (this is 0 for scalar types).
  // This does not include terminator if used (e.g. strings).
  int mMaxLength;
  // If an array structure is this variable length.
  bool mIsVariableLength;
  // If an array structure is this variable length.
  bool mIsNullable;
  // For a nested record type this is the record format
  LogicalRecord mNestedRecord;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_NVP(mPipelineType);
    ar & BOOST_SERIALIZATION_NVP(mMaxLength);
    ar & BOOST_SERIALIZATION_NVP(mIsVariableLength);
    ar & BOOST_SERIALIZATION_NVP(mIsNullable);
    ar & BOOST_SERIALIZATION_NVP(mNestedRecord);
  }  

public:

  METRAFLOW_DECL LogicalFieldType();

  METRAFLOW_DECL LogicalFieldType(MTPipelineLib::PropValType pipelineType, int maxLength, bool isVariableLength, bool isNullable);

  /**
   * Create a LogicalFieldType corresponding to a subrecord.
   */
  METRAFLOW_DECL LogicalFieldType(const LogicalRecord& nestedRecord, bool isList);
  /**
   * Create a LogicalFieldType from a PhysicalFieldType.  
   * INTERNAL USE ONLY - We want this method to disappear.
   */
  // METRAFLOW_DECL LogicalFieldType(const PhysicalFieldType& pft, bool isNullable);
  METRAFLOW_DECL LogicalFieldType(const LogicalFieldType& pft);
  METRAFLOW_DECL ~LogicalFieldType();
  METRAFLOW_DECL const LogicalFieldType& operator=(const LogicalFieldType & rhs);
  METRAFLOW_DECL bool operator==(const LogicalFieldType & rhs) const;
  METRAFLOW_DECL bool operator!=(const LogicalFieldType & rhs) const;
  /**
   * Checks whether a type can be read as another (i.e. implicit conversions).
   * Current we only allow a non-nullable type to be read as corresponding nullable.
   */
  METRAFLOW_DECL bool CanReadAs(const LogicalFieldType& ty) const;

  static LogicalFieldType Integer(bool isNullable)
  {
    LogicalFieldType ty(MTPipelineLib::PROP_TYPE_INTEGER, 0, false, isNullable);
    return ty;
  }
  static LogicalFieldType Enum(bool isNullable)
  {
    LogicalFieldType ty(MTPipelineLib::PROP_TYPE_ENUM, 0, false, isNullable);
    return ty;
  }
  static LogicalFieldType Boolean(bool isNullable)
  {
    LogicalFieldType ty(MTPipelineLib::PROP_TYPE_BOOLEAN, 0, false, isNullable);
    return ty;
  }
  static LogicalFieldType Datetime(bool isNullable)
  {
    LogicalFieldType ty(MTPipelineLib::PROP_TYPE_DATETIME, 0, false, isNullable);
    return ty;
  }
  static LogicalFieldType BigInteger(bool isNullable)
  {
    LogicalFieldType ty(MTPipelineLib::PROP_TYPE_BIGINTEGER, 0, false, isNullable);
    return ty;
  }
  static LogicalFieldType Double(bool isNullable)
  {
    LogicalFieldType ty(MTPipelineLib::PROP_TYPE_DOUBLE, 0, false, isNullable);
    return ty;
  }
  METRAFLOW_DECL static LogicalFieldType String(bool isNullable);
  METRAFLOW_DECL static LogicalFieldType UTF8String(bool isNullable);
  static LogicalFieldType Decimal(bool isNullable)
  {
    LogicalFieldType ty(MTPipelineLib::PROP_TYPE_DECIMAL, 0, false, isNullable);
    return ty;
  }
  static LogicalFieldType Binary(bool isNullable)
  {
    LogicalFieldType ty(MTPipelineLib::PROP_TYPE_OPAQUE, 16, false, isNullable);
    return ty;
  }
  METRAFLOW_DECL static LogicalFieldType Record(const LogicalRecord& nestedRecord, bool isList, bool isNullable);

  MTPipelineLib::PropValType GetPipelineType() const
  {
    return mPipelineType;
  }

  std::wstring ToString() const;

  const LogicalRecord& GetMetadata() const
  {
    return mNestedRecord;
  }

  /**
   * Is this a list type?
   * Current data model doesn't really support lists of lists, but it isn't
   * hard to fake them out with a list of records with a single field that is a list type.
   */
  bool IsList() const
  {
    return mMaxLength >= 1;
  }

  /**
   * Get string representing the appropriate datatype mapping for a SQL Server
   * database.
   */
  METRAFLOW_DECL std::wstring GetSQLServerDatatype() const;
  /**
   * Get string representing the appropriate datatype mapping for an Oracle
   * database.
   */
  METRAFLOW_DECL std::wstring GetOracleDatatype() const;
  /** Get the MTSQL name for the physical field type. */
  static std::wstring GetMTSQLDatatype(MTPipelineLib::PropValType valType);

  /**
   * Create a LogicalFieldType from an MTSQL type
   */
  static LogicalFieldType Get(const MTSQLParam& param);
};

class RecordMember
{
private:
  std::wstring mName;
  LogicalFieldType mType;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_NVP(mName);
    ar & BOOST_SERIALIZATION_NVP(mType);
  }  
  METRAFLOW_DECL RecordMember();

public:
  METRAFLOW_DECL RecordMember(const std::wstring& name,
                              const LogicalFieldType& memberType)
  :
    mName(name),
    mType(memberType)
  {
  }

  METRAFLOW_DECL ~RecordMember() {}
  METRAFLOW_DECL bool operator==(const RecordMember& rhs) const;
  const std::wstring& GetName() const { return mName; }
  const LogicalFieldType& GetType() const { return mType; }

public:
  static bool IsValidTopLevelName(const std::wstring& name);
};

class RecordMemberIterator
{
private:
  std::vector<RecordMember>& mToIterate;
public:
  void Blah()
  {
    // Want to iterate over fixed length fields first.
    // When encountering a non-array record, descend into that record
    // and add to the same buffer.  
    
  }
};

#endif
