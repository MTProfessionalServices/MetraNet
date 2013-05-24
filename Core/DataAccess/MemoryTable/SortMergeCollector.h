#ifndef __SORTMERGECOLLECTOR_H__
#define __SORTMERGECOLLECTOR_H__

#include <queue>
#include "Scheduler.h"

using namespace std;

class DesignTimeSortKey
{
	public:	 
		METRAFLOW_DECL DesignTimeSortKey(){};
		METRAFLOW_DECL DesignTimeSortKey(std::wstring aName, SortOrder::SortOrderEnum aSortOrder);
		METRAFLOW_DECL ~DesignTimeSortKey(){};
		std::wstring GetSortKeyName() const
		{
		 return mSortKeyName;
		}
		
		void SetSortKeyName(std::wstring aName)
		{
			mSortKeyName = aName;
		}
		SortOrder::SortOrderEnum GetSortOrder() const
		{
			return mSortOrder;
		}

		void SetSortOrder(SortOrder::SortOrderEnum aSortOrder)
		{
			mSortOrder = mSortOrder;
		}

	private: 
		std::wstring mSortKeyName;
		SortOrder::SortOrderEnum mSortOrder;

		//
		// Serialization support
		//
		friend class boost::serialization::access;
		template<class Archive>
		void serialize(Archive & ar, const unsigned int version) 
		{
			ar & BOOST_SERIALIZATION_NVP(mSortKeyName);
			ar & BOOST_SERIALIZATION_NVP(mSortOrder);
		}  
};
class RunTimeSortKey
{
	public:	 
		METRAFLOW_DECL RunTimeSortKey(){};
		METRAFLOW_DECL RunTimeSortKey(std::wstring aName, SortOrder::SortOrderEnum aSortOrder, DataAccessor * accessor);
		METRAFLOW_DECL ~RunTimeSortKey(){};
		std::wstring GetSortKeyName() const
		{
		 return mSortKeyName;
		}
		
		void SetSortKeyName(std::wstring aName)
		{
			mSortKeyName = aName;
		}
		SortOrder::SortOrderEnum GetSortOrder() const
		{
			return mSortOrder;
		}

		void SetSortOrder(SortOrder::SortOrderEnum aSortOrder)
		{
			mSortOrder = mSortOrder;
		}

		void SetDataAccessor(DataAccessor * accessor)
		{
			mAccessor = accessor;
		}
		const DataAccessor * GetDataAccessor() const
		{
			return mAccessor;
		}
	private: 
		std::wstring mSortKeyName;
		SortOrder::SortOrderEnum mSortOrder;
		DataAccessor * mAccessor;

		//
		// Serialization support
		//
		friend class boost::serialization::access;
		template<class Archive>
		void serialize(Archive & ar, const unsigned int version) 
		{
			ar & BOOST_SERIALIZATION_NVP(mSortKeyName);
			ar & BOOST_SERIALIZATION_NVP(mSortOrder);
			ar & BOOST_SERIALIZATION_NVP(mAccessor);
		}  
};

class DesignTimeSortMergeCollector : public DesignTimeOperator
{
	public:
		METRAFLOW_DECL DesignTimeSortMergeCollector();
		METRAFLOW_DECL ~DesignTimeSortMergeCollector();
		METRAFLOW_DECL void type_check();
		METRAFLOW_DECL void AddSortKey(DesignTimeSortKey * aKey);
		METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

    /** Handle the given operator argument specifying operator behavior. */
    METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

    /** Clone the initial configured state of an operator. */
    METRAFLOW_DECL virtual DesignTimeSortMergeCollector* clone(
                                                const std::wstring& name,
                                                std::vector<OperatorArg*>& args, 
                                                int nInputs, int nOutputs) const;

	private: 
		//datastructure to store the keys
		std::vector<DesignTimeSortKey *> mSortKey;
		std::vector<RunTimeSortKey> mRunTimeSortKeys;
		std::wstring mSortKeyName;
		RecordMetadata *mColl;
		//
		// Serialization support
		//
		friend class boost::serialization::access;
		template<class Archive>
		void serialize(Archive & ar, const unsigned int version) 
		{
			ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
			ar & BOOST_SERIALIZATION_NVP(mSortKey);
			ar & BOOST_SERIALIZATION_NVP(mRunTimeSortKeys);
			ar & BOOST_SERIALIZATION_NVP(mSortKeyName);
			ar & BOOST_SERIALIZATION_NVP(mColl);
		}  
};

class QueueElement : public SortKeyBuffer
{
	public:
		MessagePtr mMsgPtr;
		Endpoint *mEp;
		METRAFLOW_DECL  QueueElement()
		{
			mMsgPtr = NULL;
			mEp = NULL;
		}
		METRAFLOW_DECL ~QueueElement()
		{
		}

		/*QueueElement(const QueueElement & QE)
		{
			mMsgPtr = QE.mMsgPtr;
			mEp = QE.mEp;

		}
		QueueElement& operator=(const QueueElement & QE)
		{
			SortKeyBuffer::operator=(QE);
			mMsgPtr = QE.mMsgPtr;
			mEp = QE.mEp;
			return *this;
		}*/
		MessagePtr GetMsgPtr()
		{
			return mMsgPtr;
		};
		void SetMsgPtr(MessagePtr thisptr)
		{
			mMsgPtr = thisptr;
		}
	
	
};

typedef std::vector<QueueElement *> myVectorForQueue;
typedef priority_queue<QueueElement *, myVectorForQueue, QueueElement::Less> PriorityQueue;

class RunTimeSortMergeCollector : public RunTimeOperator
{
public:
  friend class RunTimeSortMergeCollectorActivation;
private:
  RecordMetadata mMetadata;
  std::vector<RunTimeSortKey> mRunTimeSortKeys;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
    ar & BOOST_SERIALIZATION_NVP(mRunTimeSortKeys);
  }

public:
  METRAFLOW_DECL RunTimeSortMergeCollector(){};
  METRAFLOW_DECL RunTimeSortMergeCollector(const std::wstring& name,
                                           const RecordMetadata& metadata,
                                           const std::vector<RunTimeSortKey>& sortKey);
	                                 

        
  METRAFLOW_DECL ~RunTimeSortMergeCollector();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeSortMergeCollectorActivation : public RunTimeOperatorActivationImpl<RunTimeSortMergeCollector>
{
private:
  std::vector<RunTimeSortKey>::const_iterator mSortKeyIt;
  std::vector<Endpoint *>::iterator mIt;

  enum State {START, READ_INIT, WRITE_CHANNEL, READ_CHANNEL, WRITE_EOF};
  State mState;

  PriorityQueue mPQ;
  std::vector<QueueElement *> mQueueElements;
  std::vector<QueueElement *>::iterator mQueueElementsIt;

  QueueElement * mCurrentQueueElement;

public:
  METRAFLOW_DECL RunTimeSortMergeCollectorActivation(Reactor *reactor, 
                                                     partition_t partition,
                                                     const RunTimeSortMergeCollector * runTimeOperator);
  METRAFLOW_DECL ~RunTimeSortMergeCollectorActivation();

  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * in); 
};

#endif
