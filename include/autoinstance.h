/**************************************************************************
 * @doc
 *
 * Copyright 1998 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Carl Shimer
 *
 * $Date$
 * $Author$
 * $Revision$
 */


#ifndef __AUTOINSTANCE_H_
#define __AUTOINSTANCE_H_
#include <MTSingleton.h>
#include <errobj.h>
#pragma warning( disable : 4290 ) 

template<class T> class MTAutoInstance : public MTSingleton<T> {

public:
  MTAutoInstance() :MTSingleton<T>(), m_Instance(NULL) {}
  ~MTAutoInstance() 
	{ 
		if(m_Instance) 
			ReleaseInstance();
	}

  T* operator->() throw(ErrorObject)
  {
    if(!m_Instance) {
      m_Instance = GetInstance();
      if(!m_Instance) {
        ErrorObject aError(E_OUTOFMEMORY,ERROR_MODULE,ERROR_LINE,"MTAutoInstance::operator->");
        throw aError;
      }
    }
     return m_Instance;
  }
	void Destroy() 
	{
		if(m_Instance) ReleaseInstance();
		m_Instance = NULL;


	}


protected:
  T* m_Instance;
};

template<class T> class MTAutoSingleton  {
	public:

	MTAutoSingleton() : pInstance(NULL) {}
	~MTAutoSingleton()
	{
		if(pInstance) {
			T::ReleaseInstance();
		}
	}

	T* operator->() throw(ErrorObject)
	{
		if(pInstance) return pInstance;
		pInstance = T::GetInstance();
		if(!pInstance) {
			ErrorObject aError(E_OUTOFMEMORY,ERROR_MODULE,ERROR_LINE,"MTAutoSingleton::operator->");
			throw aError;
		}
		return pInstance;
	}
	T* operator&() { return operator->(); }

	protected:
		T* pInstance;
};


template<class T> class MTAutoCreatePtr {

public:
	MTAutoCreatePtr() : mpInstance(NULL) {}
	MTAutoCreatePtr(T* pIn) : mpInstance(pIn) {}
	~MTAutoCreatePtr() 
	{ 
		if(mpInstance)
			delete mpInstance; 
	}
	T* operator->() throw(ErrorObject) {

		if(!mpInstance) {
			mpInstance = new T;
			if(!mpInstance) {
					ErrorObject aError(E_OUTOFMEMORY,ERROR_MODULE,ERROR_LINE,"MTAutoInstance::operator->");
					throw aError;
			}
		}
		return mpInstance;
	}

	T* operator&() { return operator->(); }
	operator bool() { return mpInstance ? true : false; }
	operator T*() { return mpInstance; }
	bool operator !() { return  mpInstance ? false : true; }

protected:
	T* mpInstance;
};

#pragma warning( default  : 4290 ) 

#endif // __AUTOINSTANCE_H_
