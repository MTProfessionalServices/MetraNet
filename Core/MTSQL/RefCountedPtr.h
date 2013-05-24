#ifndef _REFCOUNTEDPTR_H_
#define _REFCOUNTEDPTR_H_

template<class T>
class RefCountedPtr {
private:
	struct Ref {
		T* const ptr;
		unsigned int count;

		Ref(T* p) : ptr(p), count(1) {}
		~Ref() {delete ptr;}
		Ref* increment() {++count;return this;}
		bool decrement() {return (--count==0);}
	private:
		Ref(const Ref&);
		Ref& operator=(const Ref&);
	}* ref;

public:
	explicit RefCountedPtr(T* p=0) 
		: ref(p ? new Ref(p) : 0)
	{
	}
	RefCountedPtr(const RefCountedPtr<T>& other) 
		: ref(other.ref ? other.ref->increment() : 0)
	{
	}
	~RefCountedPtr()
	{
		if (ref && ref->decrement()) delete ref;
	}
	RefCountedPtr<T>& operator=(const RefCountedPtr<T>& other)
	{
		Ref* tmp=other.ref ? other.ref->increment() : 0;
		if (ref && ref->decrement()) delete ref;
		ref=tmp;
		return *this;
	}

	// This is needed if one is to use RefCountedPtr in an STL map
	friend bool operator<(const RefCountedPtr<T>& lhs, const RefCountedPtr<T>& rhs) 
		{
			return (lhs.ref ? lhs.ref->ptr : 0) < (rhs.ref ? rhs.ref->ptr : 0);			
		}

	friend bool operator==(const RefCountedPtr<T>& lhs, const RefCountedPtr<T>& rhs) 
		{
			return (lhs.ref ? lhs.ref->ptr : 0) == (rhs.ref ? rhs.ref->ptr : 0);			
		}

	friend bool operator!=(const RefCountedPtr<T>& lhs, const RefCountedPtr<T>& rhs) 
		{
			return (lhs.ref ? lhs.ref->ptr : 0) != (rhs.ref ? rhs.ref->ptr : 0);			
		}

	operator T* () const
		{ return ref ? ref->ptr : 0; }
	T* operator->() const
		{ return ref ? ref->ptr : 0; }
	T* get() const
		{ return ref ? ref->ptr : 0; }
};

template<class T>
class SafeRefCountedPtr {
private:
	struct Ref {
		T* const ptr;
		long count;

		Ref(T* p) : ptr(p), count(1) {}
		~Ref() {delete ptr;}
		Ref* increment() {::InterlockedIncrement(&count);return this;}
		bool decrement() {return (::InterlockedDecrement(&count)==0);}
	private:
		Ref(const Ref&);
		Ref& operator=(const Ref&);
	}* ref;

public:
	explicit SafeRefCountedPtr(T* p=0) 
		: ref(p ? new Ref(p) : 0)
	{
	}
	SafeRefCountedPtr(const SafeRefCountedPtr<T>& other) 
		: ref(other.ref ? other.ref->increment() : 0)
	{
	}
	~SafeRefCountedPtr()
	{
		if (ref && ref->decrement()) delete ref;
	}
	SafeRefCountedPtr<T>& operator=(const SafeRefCountedPtr<T>& other)
	{
		Ref* tmp=other.ref ? other.ref->increment() : 0;
		if (ref && ref->decrement()) delete ref;
		ref=tmp;
		return *this;
	}

	// This is needed if one is to use SafeRefCountedPtr in an STL map
	friend bool operator<(const SafeRefCountedPtr<T>& lhs, const SafeRefCountedPtr<T>& rhs) 
		{
			return (lhs.ref ? lhs.ref->ptr : 0) < (rhs.ref ? rhs.ref->ptr : 0);			
		}

	friend bool operator==(const SafeRefCountedPtr<T>& lhs, const SafeRefCountedPtr<T>& rhs) 
		{
			return (lhs.ref ? lhs.ref->ptr : 0) == (rhs.ref ? rhs.ref->ptr : 0);			
		}

	friend bool operator!=(const SafeRefCountedPtr<T>& lhs, const SafeRefCountedPtr<T>& rhs) 
		{
			return (lhs.ref ? lhs.ref->ptr : 0) != (rhs.ref ? rhs.ref->ptr : 0);			
		}

	operator T* () const
		{ return ref ? ref->ptr : 0; }
	T* operator->() const
		{ return ref ? ref->ptr : 0; }
	T* get() const
		{ return ref ? ref->ptr : 0; }
};

#endif
