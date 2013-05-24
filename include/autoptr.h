#ifndef __AUTOPTR_H__
#define __AUTOPTR_H__

#ifdef WIN32
#include <winbase.h>
#endif
template <class T>
class MTautoptr {
	//private:
	public:
		MTautoptr() : pObject(NULL),mpCount(NULL) {}

public:
	// constructors
	MTautoptr(T* pIn);
	MTautoptr(const MTautoptr<T>& aRhs);
	~MTautoptr();

	// assignment operators
	MTautoptr<T>& operator=(const MTautoptr<T>& aIn);
	MTautoptr<T>& operator=(T*);
	
	// other operators
	T* operator->();
	const T* operator->() const;

	T& operator*();
	const T& operator*() const;

	T* operator&() { return pObject; }
	const T* operator&() const { return pObject; }

	T* GetObject() { return pObject; }
	const T* GetObject() const { return pObject; }

  // For compatibility with boost::shared_ptr
	T* get() { return pObject; }
	const T* get() const { return pObject; }

	operator T*() { return pObject; }
	operator const T*() const { return pObject; }

#ifdef WIN32
	operator bool() { return pObject ? true : false; }
	bool operator!() { return pObject? false : true; }
#else
	operator BOOL() { return pObject ? TRUE : FALSE; }
	BOOL operator!() {return pObject? FALSE : TRUE; }
#endif

	// reference count stuff

	long AddRef();
	long Release();

protected:
	T* pObject;

private:
	long* mpCount;
};


//////////////////////////////////////////////////////////////////////////////////
// Constructors
//////////////////////////////////////////////////////////////////////////////////

template <class T> MTautoptr<T>::MTautoptr(const MTautoptr<T>& aRhs)
{

	pObject = aRhs.pObject;
	mpCount = aRhs.mpCount;
	if(mpCount)
	{
		AddRef();
		ASSERT(*mpCount >= 0);
	}
}


template <class T> MTautoptr<T>::MTautoptr(T* pIn) : pObject(pIn)
{
	if (NULL == pIn)
		mpCount = NULL;
	else {
		mpCount = new long;
		*mpCount = 1;
	}
}

//////////////////////////////////////////////////////////////////////////////////
// Destructors
//////////////////////////////////////////////////////////////////////////////////


template <class T> MTautoptr<T>::~MTautoptr()
{
	Release();

	// even if it wasn't released we clear out the autoptr
	pObject = NULL;
	mpCount = NULL;
}

//////////////////////////////////////////////////////////////////////////////////
// Misc operators
//////////////////////////////////////////////////////////////////////////////////

template <class T> T* MTautoptr<T>::operator->()
{
	//ASSERT(pObject != NULL);
	return pObject;
}

template <class T> const T* MTautoptr<T>::operator->() const
{
	//ASSERT(pObject != NULL);
	return pObject;
}

template <class T> T& MTautoptr<T>::operator*()
{
	//ASSERT(pObject != NULL);
	return *pObject;
}

//////////////////////////////////////////////////////////////////////////////////
// reference counting
//////////////////////////////////////////////////////////////////////////////////


template <class T> long MTautoptr<T>::AddRef()
{
// Check the point of mpCount, make sure it isn't NULL
	ASSERT(mpCount);
#ifdef WIN32
	return ::InterlockedIncrement(mpCount);
#else
	// this needs to be atomic
	return ++(*mpCount);
#endif
}

template <class T> long MTautoptr<T>::Release()
{
// if mpCount is NULL, do nothing
	if(NULL == mpCount)
		return 0;

 	long aCount;
#ifdef WIN32
 aCount = ::InterlockedDecrement(mpCount);
#else
 aCount = (*mpCount)--;
#endif

 ASSERT(aCount >= 0);
 if(aCount == 0) {
	 try
	 {
		 delete pObject;
	 }
	 catch (...)
	 {
		 // if the object's destructor throws, continue to clean up the object
		 pObject = NULL;
		 delete mpCount;
		 mpCount = NULL;
		 throw;
	 }

	 pObject = NULL;
	 delete mpCount;
	 mpCount = NULL;
 }
 return aCount;
}

//////////////////////////////////////////////////////////////////////////////////
// Assignment operators
//////////////////////////////////////////////////////////////////////////////////

template <class T> MTautoptr<T>& MTautoptr<T>::operator=(const MTautoptr<T>& aIn)
{
//	ASSERT(aIn.mpCount);
	if(NULL == aIn.mpCount)
	{
		Release();
		pObject = NULL;
		mpCount = NULL;
		return *this;
	}

	Release();
	pObject = aIn.pObject;
	mpCount = aIn.mpCount;
	AddRef();
	ASSERT(*mpCount >= 0);
	return *this;
}

template <class T> MTautoptr<T>& MTautoptr<T>::operator=(T* aNewObject)
{
	if (NULL == aNewObject)
		{
			Release();
			mpCount = NULL;
			pObject = NULL;
			return * this;
		}
/*
	if(NULL == mpCount)
		{
			mpCount = new long;
			* mpCount = 0;
		}
*/
	if(NULL!= mpCount && *mpCount > 0) {
		Release();
	}
	pObject = aNewObject;
	mpCount = new long;
	*mpCount = 0;
	AddRef();
	return *this;
}

#endif //__AUTOPTR_H__
