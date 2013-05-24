#ifndef __DESIGNTIMEEXPRESSION_H__
#define __DESIGNTIMEEXPRESSION_H__

#include "Scheduler.h"

class DesignTimeExpression : public DesignTimeOperator
{
private:
  std::wstring mProgram;
  RecordMetadata * mProgramOutputMetadata;
  RecordMerge * mMerger;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mProgram);
    ar & BOOST_SERIALIZATION_NVP(mProgramOutputMetadata);
    ar & BOOST_SERIALIZATION_NVP(mMerger);
  }  

  static PhysicalFieldType GetPhysicalFieldType(int ty);
public:
  METRAFLOW_DECL DesignTimeExpression();
  METRAFLOW_DECL ~DesignTimeExpression();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  METRAFLOW_DECL const std::wstring& GetProgram() const
  {
    return mProgram;
  }
  METRAFLOW_DECL void SetProgram(const std::wstring& program)
  {
    mProgram = program;
  }

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeExpression* clone(
                                      const std::wstring& name,
                                      std::vector<OperatorArg*>& args, 
                                      int nInputs, int nOutputs) const;
};

class DesignTimeExpressionGenerator : public DesignTimeOperator
{
private:
  std::wstring mProgram;
  RecordMetadata * mProgramOutputMetadata;
  RecordMerge * mMerger;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mProgram);
    ar & BOOST_SERIALIZATION_NVP(mProgramOutputMetadata);
    ar & BOOST_SERIALIZATION_NVP(mMerger);
  }  

  static PhysicalFieldType GetPhysicalFieldType(int ty);
public:
  METRAFLOW_DECL DesignTimeExpressionGenerator();
  METRAFLOW_DECL ~DesignTimeExpressionGenerator();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  METRAFLOW_DECL const std::wstring& GetProgram() const
  {
    return mProgram;
  }
  METRAFLOW_DECL void SetProgram(const std::wstring& program)
  {
    mProgram = program;
  }

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeExpressionGenerator* clone(
                                               const std::wstring& name,
                                               std::vector<OperatorArg*>& args, 
                                               int nInputs, int nOutputs) const;
};

class DesignTimeGenerator : public DesignTimeOperator
{
private:
  std::wstring mProgram;
  RecordMetadata * mProgramOutputMetadata;
  boost::int64_t mNumRecords;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mProgram);
    ar & BOOST_SERIALIZATION_NVP(mProgramOutputMetadata);
    ar & BOOST_SERIALIZATION_NVP(mNumRecords);
  }  
  static PhysicalFieldType GetPhysicalFieldType(int ty);

public:
  METRAFLOW_DECL DesignTimeGenerator();
  METRAFLOW_DECL ~DesignTimeGenerator();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  METRAFLOW_DECL const std::wstring& GetProgram() const
  {
    return mProgram;
  }
  METRAFLOW_DECL void SetProgram(const std::wstring& program)
  {
    mProgram = program;
  }
  METRAFLOW_DECL const boost::int64_t GetNumRecords() const
  {
    return mNumRecords;
  }
  METRAFLOW_DECL void SetNumRecords(boost::int64_t numRecords)
  {
    mNumRecords = numRecords;
  }

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeGenerator* clone(
                                     const std::wstring& name,
                                     std::vector<OperatorArg*>& args, 
                                     int nInputs, int nOutputs) const;
};

#endif
