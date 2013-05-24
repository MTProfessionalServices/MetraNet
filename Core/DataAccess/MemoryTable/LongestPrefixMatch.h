#ifndef __LONGEST_PREFIX_MATCH__
#define __LONGEST_PREFIX_MATCH__

#include "Scheduler.h"
#include "LogAdapter.h"

template <class _Char, class _Payload>
class TernarySearchTree 
{
public:
  class Node
  {
  public:
    _Char mSplitchar;
    Node * mLo;
    Node * mEq;
    Node * mHi;
    _Payload * mPayload;

    Node(_Char splitchar)
      :
      mSplitchar(splitchar),
      mLo(NULL),
      mEq(NULL),
      mHi(NULL),
      mPayload(NULL)
    {
    }

    ~Node()
    {
      delete mLo;
      delete mEq;
      delete mHi;

      // allocator template for payload?
    }
  };


private:
  Node * mRoot;
public:
  TernarySearchTree()
    :
    mRoot(NULL)
  {
  }
  
  ~TernarySearchTree()
  {
    delete mRoot;
  }

  void Insert(const _Char * it, const _Char * end, _Payload * payload)
  {
    if (it >= end) throw std::runtime_error("TernarySearchTree::Insert invalid argument");

    Node ** p = &mRoot;
    while(it != end)
    {
      if (*p == NULL)
      {
        *p = new Node (*it);
      }
      if (*it < (*p)->mSplitchar)
      {
        p = &((*p)->mLo);
      }
      else if (*it == (*p)->mSplitchar)
      {
        if (++it == end)
        {
          (*p)->mPayload = payload;
          return;
        }
        else
        {
          p = &((*p)->mEq);
        }
      }
      else
      {
        p = &((*p)->mHi);
      }
    }
  }

  _Payload * Search(const _Char * it, const _Char * end)
  {
    Node * p = mRoot;
    while (p)
    {
      if (*it < p->mSplitchar)
      {
        p = p->mLo;
      }
      else if (*it == p->mSplitchar)
      {
        if (++it == end)
        {
          // Note that I can be here either because of a match or a 
          // input that is a prefix of something in the dictionary.
          // Only the former will have a valid payload.
          return p->mPayload;
        }
        else
          p = p->mEq;
      }
      else
      {
        p = p->mHi;
      }
    }
    return NULL;
  }

  _Payload * LongestPrefixSearch(const _Char * it, const _Char * end)
  {
    _Payload * lastPrefixMatch=NULL;
    Node * p = mRoot;
    while (p)
    {
      if (*it < p->mSplitchar)
      {
        p = p->mLo;
      }
      else if (*it == p->mSplitchar)
      {
        // Check for a payload since this indicates a prefix match
        if (p->mPayload)
          lastPrefixMatch = p->mPayload;

        if (++it == end)
        {
          // Note that I can be here either because of a match or a 
          // input that is a prefix of something in the dictionary.
          // Only the former will have a valid payload.
          return lastPrefixMatch;
        }
        else
          p = p->mEq;
      }
      else
      {
        p = p->mHi;
      }
    }
    return lastPrefixMatch;
  }
};

/**
 * Computes a merge equijoin of two sorted data streams.
 *
 * The LongestPrefixMatch takes two input streams and produces a single output stream that is the equijoin of the underlying sets.
 * The input streams are required to be sorted on the configured equijoin keys.  Failure to do will not result in a runtime failure
 * but will result in incorrect results.
 * The two input ports of the operator have labels "probe" and "table".
 *
 */
class DesignTimeLongestPrefixMatch : public DesignTimeOperator
{
private:
  std::vector<std::wstring> mProbeEquiJoinKeys;
  std::vector<std::wstring> mTableEquiJoinKeys;
  RecordMerge * mMerger;

public:
  /**
   * Default constructor 
   */
  METRAFLOW_DECL DesignTimeLongestPrefixMatch();
  /**
   * Destructor
   */
  METRAFLOW_DECL ~DesignTimeLongestPrefixMatch();
  /**
   * Type check operator.  
   * Output of the operator includes the concatenation of the input records of its two inputs.
   * @exception MissingKeyException Thrown if the equijoin keys are not configured on either the left or right input.
   * @exception KeySizeMismatchException Thrown if the number of keys on the left and right inputs are not the same.
   * @exception MissingFieldException Thrown if the equijoin keys do not exist in the input.
   * @exception TypeMismatchException Thrown if copositioned equijoin keys from the two inputs have different data types.
   * @exception MTSQLException Thrown if the residual predicate has syntax errors.
   */
  METRAFLOW_DECL void type_check();
  /**
   * Create a run time operator for the physical plan.
   * @return A RunTimeLongestPrefixMatch operator.  
   */
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  /**
   * Add an equijoin key to the current equijoin key list for the left input.
   * @todo Throw an exception if there are duplicate key names in the key list?
   */
  METRAFLOW_DECL void AddProbeKey(const std::wstring& equiJoinKey);
  /**
   * Add an equijoin key to the current equijoin key list for the right input.
   * @todo Throw an exception if there are duplicate key names in the key list?
   */
  METRAFLOW_DECL void AddTableKey(const std::wstring& equiJoinKey);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeLongestPrefixMatch* clone(
                                              const std::wstring& name,
                                              std::vector<OperatorArg*>& args, 
                                              int nInputs, int nOutputs) const;
};

class RunTimeLongestPrefixMatch : public RunTimeOperator
{
public:
  friend class RunTimeLongestPrefixMatchActivation;
private:
  RecordMetadata mTableMetadata;
  RecordMetadata mProbeMetadata;
  std::vector<RunTimeDataAccessor> mProbeKeys;
  std::vector<RunTimeDataAccessor> mTableKeys;
  RecordMerge mMerger;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mTableMetadata);
    ar & BOOST_SERIALIZATION_NVP(mProbeMetadata);
    ar & BOOST_SERIALIZATION_NVP(mProbeKeys);
    ar & BOOST_SERIALIZATION_NVP(mTableKeys);
    ar & BOOST_SERIALIZATION_NVP(mMerger);
  }  
  METRAFLOW_DECL RunTimeLongestPrefixMatch();

public:
  METRAFLOW_DECL RunTimeLongestPrefixMatch(const std::wstring& name, 
                                           const RecordMetadata& tableMetadata,
                                           const RecordMetadata& probeMetadata,
                                           const std::vector<RunTimeDataAccessor>& tableKeys,
                                           const std::vector<RunTimeDataAccessor>& probeKeys,
                                           const RecordMerge& merger);
  METRAFLOW_DECL ~RunTimeLongestPrefixMatch();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeLongestPrefixMatchActivation : public RunTimeOperatorActivationImpl<RunTimeLongestPrefixMatch>
{
private:
  enum State {START, READ_PROBE, READ_TABLE, WRITE, WRITE_EOF};

  MessagePtr mMessage;
  State mState;
  TernarySearchTree<wchar_t, boost::uint8_t> * mTST;
public:
  METRAFLOW_DECL RunTimeLongestPrefixMatchActivation(Reactor * reactor, 
                                                     partition_t partition, 
                                                     const RunTimeLongestPrefixMatch * runTimeOperator);
  METRAFLOW_DECL ~RunTimeLongestPrefixMatchActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

#endif
