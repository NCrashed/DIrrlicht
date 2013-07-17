// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" and the "irrXML" project.
// For conditions of distribution and use, see copyright notice in irrlicht.h and irrXML.h
module irrlicht.core.irrAllocator;

//import irrlicht.IrrCompileConfig;

/// Very simple allocator implementation, containers using it can be used across dll boundaries
class irrAllocator(T : Object)
{
	public
	{
		/// Allocate memory for an array of objects
		T* allocate(size_t cnt)
		{
			return cast(T*)internal_new(cnt * sizeof(T));
		}

		/// Deallocate memory for an array of objects
		void deallocate(T* ptr)
		{
			internal_delete(ptr);
		}

		/// Construct an element
		void construct(T* ptr, const ref T e)
		{
			new(cast(void*)ptr) T(e);
		}

		/// Destruct an element
		void destruct(T* ptr)
		{
			ptr.destroy();
		}
	}
	protected
	{
		//static if(CUSTOM_MEMORY_MANAGMENT)
		//{
			import std.c.stdlib; 
			import core.exception; 
			import core.memory : GC;

			void* internal_new(size_t cnt)
			{
				void* p; 

				p = std.c.stdlib.malloc(sz); 

				if(!p) 
					throw new OutOfMemoryError(); 

				GC.addRange(p, sz); 
				return p; 
			}

			void internal_delete(void* ptr)
			{
				if (ptr) 
				{ 
					GC.removeRange(ptr); 
					std.c.stdlib.free(ptr); 
				}
			}
		//}
	}
}

/// Fast allocator, only to be used in containers inside the same memory heap.
/** 
* Containers using it are NOT able to be used it across dll boundaries. Use this
* when using in an internal class or function or when compiled into a static lib 
*/
/*class irrAllocatorFast(T : Object)
{
	public
	{
		/// Allocate memory for an array of objects
		T* allocate(size_t cnt)
		{
			return (T*)operator new(cnt* sizeof(T));
		}

		/// Deallocate memory for an array of objects
		void deallocate(T* ptr)
		{
			operator delete(ptr);
		}

		/// Construct an element
		void construct(T* ptr, const ref T e)
		{
			new(cast(void*)ptr) T(e);
		}

		/// Destruct an element
		void destruct(T* ptr)
		{
			ptr.destroy();
		}
	}
}*/

/// defines an allocation strategy
enum eAllocStrategy
{
	ALLOC_STRATEGY_SAFE   = 0,
	ALLOC_STRATEGY_DOUBLE = 1,
	ALLOC_STRATEGY_SQRT   = 2,
}