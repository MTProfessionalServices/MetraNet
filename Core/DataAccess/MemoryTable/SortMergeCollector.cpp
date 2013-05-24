#include "SortMergeCollector.h"
#include "OperatorArg.h"

DesignTimeSortMergeCollector::DesignTimeSortMergeCollector()
{
  mInputPorts.insert(this, 0, L"input", false);
  mOutputPorts.insert(this, 0, L"output", false);  
}

DesignTimeSortMergeCollector::~DesignTimeSortMergeCollector()
{
}

void DesignTimeSortMergeCollector::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"key", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddSortKey(new DesignTimeSortKey(arg.getNormalizedString(),
                                     SortOrder::ASCENDING));
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeSortMergeCollector* DesignTimeSortMergeCollector::clone(
                                                              const std::wstring& name,
                                                              std::vector<OperatorArg *>& args, 
                                                              int nInputs, int nOutputs) const
{
  DesignTimeSortMergeCollector* result = new DesignTimeSortMergeCollector();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}


void DesignTimeSortMergeCollector::type_check()
{
  //set up the output port to have the same record format as the input port.
  mOutputPorts[0]->SetMetadata(new RecordMetadata(*mInputPorts[0]->GetMetadata()));

  //make sure at least one key is specified.
  if (mSortKey.size() <= 0)
	  throw std::runtime_error("SortMergeCollector: No sort keys have been specified");

  //make sure that there is one and only one field in the record meta data corresponding to
  //each sort key.  The data type of the field should be one of the supported types.
  //Currently only bigint and datetime types are supported.
 
  for (std::size_t i = 0; i != mSortKey.size(); i++)
  {
	mSortKeyName = (mSortKey[i])->GetSortKeyName();
	mColl = (RecordMetadata *)(mInputPorts[0]->GetMetadata());
	if (!mColl->HasColumn(mSortKeyName))
		throw std::runtime_error("SortMergeCollector: SortKey not found in the record!");
  
  if (!mInputPorts[0]->GetMetadata()->GetColumn(mSortKeyName)->IsSortable())
	  throw std::runtime_error("SortMergeCollector: Unsupported data type for sort key.  Currently only DATETIME, INTEGER and BIGINT can be used.");

	 mRunTimeSortKeys.push_back(RunTimeSortKey(mSortKeyName,
												mSortKey[i]->GetSortOrder(),
                                                mInputPorts[0]->GetMetadata()->GetColumn(mSortKeyName)));
  }

}

void DesignTimeSortMergeCollector::AddSortKey(DesignTimeSortKey * aKey)
{
	mSortKey.push_back(aKey);
	
}

RunTimeOperator * DesignTimeSortMergeCollector::code_generate(partition_t maxPartition)
{
	return new RunTimeSortMergeCollector(mName, *mInputPorts[0]->GetMetadata(), mRunTimeSortKeys);
}


DesignTimeSortKey::DesignTimeSortKey(std::wstring aName, SortOrder::SortOrderEnum aSortOrder)
:
mSortKeyName(aName),
mSortOrder(aSortOrder)
{
}

RunTimeSortKey::RunTimeSortKey(std::wstring aName, SortOrder::SortOrderEnum aSortOrder, DataAccessor * aAccessor)
:
mSortKeyName(aName),
mSortOrder(aSortOrder),
mAccessor (aAccessor)
{
}

////////////////////////////////////////////////////////////////
///////////////// RunTimeSortMergeCollector Class //////////////
////////////////////////////////////////////////////////////////

RunTimeSortMergeCollector::RunTimeSortMergeCollector(const std::wstring& name,
                                                     const RecordMetadata& metadata,
                                                     const std::vector<RunTimeSortKey>& sortKey)
                           
  :
  RunTimeOperator(name),
  mMetadata(metadata),
  mRunTimeSortKeys(sortKey)
{
  // Make sure that the sort keys have accessors taken from the private metadata
  // of this operator.
  for(std::vector<RunTimeSortKey>::iterator it =  mRunTimeSortKeys.begin();
      it != mRunTimeSortKeys.end();
      it++)
  {
    ASSERT(mMetadata.HasColumn(it->GetSortKeyName()));
    it->SetDataAccessor(mMetadata.GetColumn(it->GetSortKeyName()));
  }
}	

RunTimeSortMergeCollector::~RunTimeSortMergeCollector()
{
}

RunTimeOperatorActivation * RunTimeSortMergeCollector::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeSortMergeCollectorActivation(reactor, partition, this);
}

RunTimeSortMergeCollectorActivation::RunTimeSortMergeCollectorActivation(Reactor *reactor, 
                                                                         partition_t partition,
                                                                         const RunTimeSortMergeCollector * runTimeOperator)
                           
  :
  RunTimeOperatorActivationImpl<RunTimeSortMergeCollector>(reactor, partition, runTimeOperator)
{
}	

RunTimeSortMergeCollectorActivation::~RunTimeSortMergeCollectorActivation()
{
  for(std::size_t i = 0; i<mQueueElements.size(); i++)
  {
    delete mQueueElements[i];
  }
}

void RunTimeSortMergeCollectorActivation::Start()
{
  mState = START;
  mCurrentQueueElement = NULL;
  //allocate a vector of QueueElements based on the number of input endpoints.
  for(std::vector<Endpoint *>::iterator it = mInputs.begin();
      it != mInputs.end();
      it++)
  {
    mQueueElements.push_back(new QueueElement());
  }
  HandleEvent(NULL);
}

void RunTimeSortMergeCollectorActivation::HandleEvent(Endpoint * in) 
{
	switch (mState)
	{ 
		case START:
			mQueueElementsIt = mQueueElements.begin();
			for (mIt = mInputs.begin();
				 mIt != mInputs.end();
				 mIt++)
			{
				mReactor->RequestRead(this, *mIt);
				mState = READ_INIT;
				return;
			
		case READ_INIT:
				ASSERT(*mIt == in);
				Read((*mQueueElementsIt)->mMsgPtr, in);
				if (!mOperator->mMetadata.IsEOF((*mQueueElementsIt)->mMsgPtr))
				{
					(*mQueueElementsIt)->mEp = in;
				    //for each sort key, get the sort key representation
					//and add it to the queue element
					for (mSortKeyIt = mOperator->mRunTimeSortKeys.begin();
						mSortKeyIt != mOperator->mRunTimeSortKeys.end();
						mSortKeyIt++)
					{
						mSortKeyIt->GetDataAccessor()->ExportSortKey((*mQueueElementsIt)->mMsgPtr, mSortKeyIt->GetSortOrder(), *(*mQueueElementsIt));
					}
					mPQ.push(*mQueueElementsIt);
				}
        else
        {
          mOperator->mMetadata.Free((*mQueueElementsIt)->mMsgPtr);
          (*mQueueElementsIt)->mMsgPtr = NULL;
        }
				mQueueElementsIt++;
			}
			while (mPQ.size() > 0)
			{
				mReactor->RequestWrite(this, mOutputs[0]);
				mState = WRITE_CHANNEL;
				return;
				case WRITE_CHANNEL:
					ASSERT(mOutputs[0] = in);
					Write(mPQ.top()->GetMsgPtr(), in);
					mState = READ_CHANNEL;
					mReactor->RequestRead(this, mPQ.top()->mEp);
					return;
					case READ_CHANNEL:
					 ASSERT(mPQ.top()->mEp == in);
					 mCurrentQueueElement = mPQ.top();
					 Read(mCurrentQueueElement->mMsgPtr, in);
					 mPQ.pop();
					 if(!mOperator->mMetadata.IsEOF(mCurrentQueueElement->mMsgPtr))
					 {
					   mCurrentQueueElement->mEp = in;
					   mCurrentQueueElement->Clear();
						//for each sort key, get the sort key representation
						//and add it to the queue element
						for (mSortKeyIt = mOperator->mRunTimeSortKeys.begin();
							mSortKeyIt != mOperator->mRunTimeSortKeys.end();
							mSortKeyIt++)
						{
							mSortKeyIt->GetDataAccessor()->ExportSortKey(mCurrentQueueElement->mMsgPtr, mSortKeyIt->GetSortOrder(), (*mCurrentQueueElement));
						}
						mPQ.push(mCurrentQueueElement);
					  }
            else
            {
              mOperator->mMetadata.Free(mCurrentQueueElement->mMsgPtr);
              mCurrentQueueElement->mMsgPtr = NULL;
            }
			}
			mReactor->RequestWrite(this, mOutputs[0]);
			mState = WRITE_EOF;
			return;
			case WRITE_EOF:
					Write(mOperator->mMetadata.AllocateEOF(), in, true);

	}
}
