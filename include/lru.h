#ifndef _LRU_H
#define _LRU_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif
#include <iostream>
#include <map>
#include <exception>
#include <autocritical.h>
#include <NTThreadLock.h>
#include <observedevent.h>
#include <namedpipe.h>

using namespace std;

template <typename K, typename V>
class LRUCache : public EventObserver
{
private:
  class Node;
  static NTThreadLock mLock;
  typedef typename map<K, Node*>::iterator It;
  class Node 
  {
  public:
    It it;
    V v;
    Node *L, *R;
    Node() : it(map<K, Node*>().end()), v(NULL) {}
    virtual ~Node()
    {
      if(v != NULL)
        delete v;
    }
  };
  map<K, Node*> m;
  long mSize;
  Node* q;

  EventObservable mObservable;  
  void InitObservable();

  //for statistics
  __int64 mTotalHits;
  __int64 mTotalMisses;
  __int64 mTotalEvictions;
  
  struct HitsMissesEvictions
  {
    __int64 Hits;
    __int64 Misses;
    __int64 Evictions;
    int NumRS;
  };

  typedef typename map<int, HitsMissesEvictions> ParamTableStats;
  ParamTableStats mParamTableStats;
  bool mLogDetails;
 

public:
  
  typedef V mapped_type;
  typedef K key_type;
  LRUCache(long Size);
  virtual ~LRUCache();

  void insert(const K& k, const V& v);
  const V find(const K& k, const int& ptid /*param table id is only needed for statistics report*/);
  void erase(const K& k);
  void clear();
  int size();

  /*
  mapped_type& operator[](const key_type& K)
  {	
    // find element matching K or insert with default mapped
    It it;
	  mapped_type existing = this->find(K);
	  if (existing == NULL)
    {	
      it = this->insert(K, mapped_type());
	  }
    else
      it = existing.it;
    return ((*it).second);
  };
*/
  LRUCache<K, V> & operator =(const LRUCache<K, V> & arCache);
  LRUCache(const LRUCache &c);
  
  virtual void EventOccurred();
	
};

template <typename K, typename V>
NTThreadLock LRUCache<K, V>::mLock;

template <typename K, typename V>
LRUCache<K, V> & LRUCache<K, V>::operator =(const LRUCache<K, V> & arCache)
{
  AutoCriticalSection lock(&mLock);
  mSize = arCache.mSize;
	return *this;
}

template <typename K, typename V>
LRUCache<K, V>::LRUCache(const LRUCache<K, V> &c)
{
	*this = c;
}

template <typename K, typename V>
LRUCache<K, V>::LRUCache(long sz) : mSize(sz), mTotalHits(0), mTotalMisses(0), mTotalEvictions(0)
{
  AutoCriticalSection lock(&mLock);
  q = new Node;
  //self point the neighbors
  q->L = q->R = q;
  mLogDetails = PCCache::GetLogger().IsOkToLog(LOG_INFO) ? true : false;
  InitObservable();
}

template <typename K, typename V>
LRUCache<K, V>::~LRUCache()
{
 clear();
}

template <typename K, typename V>
void LRUCache<K, V>::insert(const K& k, const V& v)
{
  if(mSize < 0)
    throw new LRUCacheException("Cache size out of range");
  AutoCriticalSection lock(&mLock);
  Node* t;
  It it = m.find(k);
  if (it == m.end()) 
  {
    if (int(m.size()) == mSize) 
    {
      //erase LRU element from the map
      m.erase(q->R->it);
      //eliminate the LRU guy from the list
      q->R = q->R->R;
      if(mLogDetails)
      {
       int ptid = q->R->L->v->ParameterTable();
       mParamTableStats[ptid].Evictions++;
       mParamTableStats[ptid].NumRS--;
      }
      //delete the element that we just eliminated from the list
      delete q->R->L;
      //complete the circle
      q->R->L = q;
      mTotalEvictions++;
      
    }
    t = new Node;
    t->it = m.insert(m.begin(), make_pair(k, t)); 
    t->v = v;
    if(mLogDetails)
    {
      int ptid = t->v->ParameterTable();
      mParamTableStats[ptid].NumRS++;
    }
  } 
  else 
  {
    t = it->second;
    t->L->R = t->R;
    t->R->L = t->L;
    if(t->v != NULL)
    {
      delete t->v;
    }
    t->v = v;
  }
  //update q ends:
  //insert MRU (either freshly inserted or not)
  t->L = q->L;
  t->R = q;
  t->L->R = t;
  //t->R is q
  t->R->L = t;
}



template <typename K, typename V>
const V LRUCache<K, V>::find(const K& k, const int& aPTID)
{
  if(mSize < 0)
    throw new LRUCacheException("Cache size out of range");
  AutoCriticalSection lock(&mLock);
  It it = m.find(k);
  if (it == m.end())
  {
    mTotalMisses++;
    if(mLogDetails)
    {
      mParamTableStats[aPTID].Misses++;
    }
    return NULL;
  }
  mTotalHits++;
  Node* t = it->second;
  if(mLogDetails)
  {
    int ptid = t->v->ParameterTable();
    mParamTableStats[ptid].Hits++;
  }

  
  //cut out this element from
  //its previous position in the list.
  //This is done because we need to promote it now
  //to MRU
  t->L->R = t->R;
  t->R->L = t->L;

  //update q ends:
  //this guy is now MRU (resulted from cache hit)
  t->L = q->L;
  t->R = q;
  t->L->R = t;
  t->R->L = t;
  return t->v;
}


template <typename K, typename V> void LRUCache<K, V>::erase(const K& k)
{
  if(mSize < 0)
    throw new LRUCacheException("Cache size out of range");
  AutoCriticalSection lock(&mLock);
  
  It it = m.find(k);
  if (it == m.end()) return;
  Node* t = it->second;

  //cut out this element from the list.
  t->L->R = t->R;
  t->R->L = t->L;
  
  delete t;
  m.erase(it);
}

template <typename K, typename V> void LRUCache<K, V>::clear()
{
  if(mSize < 0)
    throw new LRUCacheException("Cache size out of range");
  AutoCriticalSection lock(&mLock);
  
  Node* d = q, *t;
  do 
  {
    t = d->R;
    delete d;
    d = t;
  } 
  while (d != q);
  m.clear();
}

template <typename K, typename V>
int LRUCache<K, V>::size()
{
  if(mSize < 0)
    throw new LRUCacheException("Cache size out of range");
  
  return m.size();
}
template <typename K, typename V>
void LRUCache<K, V>::InitObservable()
{
  mObservable.Init("DUMP_LRUCACHE_STATS");
	mObservable.AddObserver(*this);
	if (!mObservable.StartThread())
		throw new LRUCacheException("Unable to start observer thread");
}

template <typename K, typename V>
void LRUCache<K, V>::EventOccurred()
{
   char buf0[255];
   char buf1[512];
   char buf2[512];
   sprintf(buf0, "RS Cache Statistics (number of cached rate schedules):");
   int percent = m.size() * 100/mSize;
   sprintf(buf1, "Used/Max: %d/%d (%d percent used)", m.size(), mSize, percent);
   sprintf(buf2, "Hits: %I64d, Misses: %I64d, Evictions: %I64d", mTotalHits, mTotalMisses, mTotalEvictions);
  
  try
  {
    NamedPipeServer nps("\\\\.\\pipe\\rscachestats", 1000);
    bool ret = nps.CreateAndWaitForConnection();
    if(!ret)
    {
      cout << "There was an error trying to create named pipe. Writing statistics to log file..." <<  endl;
    }
    else
    {
      nps.WritePipe(buf0);
      nps.WritePipe(buf1);
      nps.WritePipe(buf2);
      if(mLogDetails && mParamTableStats.size() > 0)
      {
        nps.WritePipe("\n");
        nps.WritePipe("RS Cache Statistics Details:");
        nps.WritePipe("PTID        Num Cached RS  Hits        Misses      Evictions");
        nps.WritePipe("-----------|--------------|-----------|-----------|---------|");
        for (ParamTableStats::iterator it = mParamTableStats.begin(); it !=  mParamTableStats.end(); it++)
        {
          HitsMissesEvictions hme = it->second;
          char hmeline[256];
          sprintf(hmeline, "%-12d%-15d%-12I64d%-12I64d%-12I64d", it->first, hme.NumRS, hme.Hits, hme.Misses, hme.Evictions);
          nps.WritePipe(hmeline);
        }
      }
      else
      {
        nps.WritePipe("\n");
        nps.WritePipe("Set Log level to INFO for more details.");
      }
    }
  }
  catch(...)
  {
  }

  PCCache::GetLogger().LogThis(LOG_WARNING, buf0);
  PCCache::GetLogger().LogThis(LOG_WARNING, buf1);
  PCCache::GetLogger().LogThis(LOG_WARNING, buf2);

}




class LRUCacheException : public std::exception 
{
public:
  LRUCacheException(const char* str) : std::exception(str) {}
};






#endif

