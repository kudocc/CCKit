#ifndef __OBJC2__
#define __OBJC2__
#endif
struct objc_selector; struct objc_class;
struct __rw_objc_super { 
	struct objc_object *object; 
	struct objc_object *superClass; 
	__rw_objc_super(struct objc_object *o, struct objc_object *s) : object(o), superClass(s) {} 
};
#ifndef _REWRITER_typedef_Protocol
typedef struct objc_object Protocol;
#define _REWRITER_typedef_Protocol
#endif
#define __OBJC_RW_DLLIMPORT extern
__OBJC_RW_DLLIMPORT void objc_msgSend(void);
__OBJC_RW_DLLIMPORT void objc_msgSendSuper(void);
__OBJC_RW_DLLIMPORT void objc_msgSend_stret(void);
__OBJC_RW_DLLIMPORT void objc_msgSendSuper_stret(void);
__OBJC_RW_DLLIMPORT void objc_msgSend_fpret(void);
__OBJC_RW_DLLIMPORT struct objc_class *objc_getClass(const char *);
__OBJC_RW_DLLIMPORT struct objc_class *class_getSuperclass(struct objc_class *);
__OBJC_RW_DLLIMPORT struct objc_class *objc_getMetaClass(const char *);
__OBJC_RW_DLLIMPORT void objc_exception_throw( struct objc_object *);
__OBJC_RW_DLLIMPORT int objc_sync_enter( struct objc_object *);
__OBJC_RW_DLLIMPORT int objc_sync_exit( struct objc_object *);
__OBJC_RW_DLLIMPORT Protocol *objc_getProtocol(const char *);
#ifdef _WIN64
typedef unsigned long long  _WIN_NSUInteger;
#else
typedef unsigned int _WIN_NSUInteger;
#endif
#ifndef __FASTENUMERATIONSTATE
struct __objcFastEnumerationState {
	unsigned long state;
	void **itemsPtr;
	unsigned long *mutationsPtr;
	unsigned long extra[5];
};
__OBJC_RW_DLLIMPORT void objc_enumerationMutation(struct objc_object *);
#define __FASTENUMERATIONSTATE
#endif
#ifndef __NSCONSTANTSTRINGIMPL
struct __NSConstantStringImpl {
  int *isa;
  int flags;
  char *str;
#if _WIN64
  long long length;
#else
  long length;
#endif
};
#ifdef CF_EXPORT_CONSTANT_STRING
extern "C" __declspec(dllexport) int __CFConstantStringClassReference[];
#else
__OBJC_RW_DLLIMPORT int __CFConstantStringClassReference[];
#endif
#define __NSCONSTANTSTRINGIMPL
#endif
#ifndef BLOCK_IMPL
#define BLOCK_IMPL
struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};
// Runtime copy/destroy helper functions (from Block_private.h)
#ifdef __OBJC_EXPORT_BLOCKS
extern "C" __declspec(dllexport) void _Block_object_assign(void *, const void *, const int);
extern "C" __declspec(dllexport) void _Block_object_dispose(const void *, const int);
extern "C" __declspec(dllexport) void *_NSConcreteGlobalBlock[32];
extern "C" __declspec(dllexport) void *_NSConcreteStackBlock[32];
#else
__OBJC_RW_DLLIMPORT void _Block_object_assign(void *, const void *, const int);
__OBJC_RW_DLLIMPORT void _Block_object_dispose(const void *, const int);
__OBJC_RW_DLLIMPORT void *_NSConcreteGlobalBlock[32];
__OBJC_RW_DLLIMPORT void *_NSConcreteStackBlock[32];
#endif
#endif
#define __block
#define __weak

#include <stdarg.h>
struct __NSContainer_literal {
  void * *arr;
  __NSContainer_literal (unsigned int count, ...) {
	va_list marker;
	va_start(marker, count);
	arr = new void *[count];
	for (unsigned i = 0; i < count; i++)
	  arr[i] = va_arg(marker, void *);
	va_end( marker );
  };
  ~__NSContainer_literal() {
	delete[] arr;
  }
};
extern "C" __declspec(dllimport) void * objc_autoreleasePoolPush(void);
extern "C" __declspec(dllimport) void objc_autoreleasePoolPop(void *);

struct __AtAutoreleasePool {
  __AtAutoreleasePool() {atautoreleasepoolobj = objc_autoreleasePoolPush();}
  ~__AtAutoreleasePool() {objc_autoreleasePoolPop(atautoreleasepoolobj);}
  void * atautoreleasepoolobj;
};

#define __OFFSETOFIVAR__(TYPE, MEMBER) ((long long) &((TYPE *)0)->MEMBER)


__attribute__((visibility("default"))) __attribute__((availability(macosx,introduced=10_8)))

#ifndef _REWRITER_typedef_NSXPCListenerEndpoint
#define _REWRITER_typedef_NSXPCListenerEndpoint
typedef struct objc_object NSXPCListenerEndpoint;
typedef struct {} _objc_exc_NSXPCListenerEndpoint;
#endif

struct NSXPCListenerEndpoint_IMPL {
	struct NSObject_IMPL NSObject_IVARS;
	void *_internal;
};

/* @end */


typedef void(*captureScalar)(void);

captureScalar _block;

struct __Block_byref_mutableA_0 {
  void *__isa;
__Block_byref_mutableA_0 *__forwarding;
 int __flags;
 int __size;
 int mutableA;
};

struct __blockMethod_block_impl_0 {
  struct __block_impl impl;
  struct __blockMethod_block_desc_0* Desc;
  int a;
  __Block_byref_mutableA_0 *mutableA; // by ref
  __blockMethod_block_impl_0(void *fp, struct __blockMethod_block_desc_0 *desc, int _a, __Block_byref_mutableA_0 *_mutableA, int flags=0) : a(_a), mutableA(_mutableA->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static void __blockMethod_block_func_0(struct __blockMethod_block_impl_0 *__cself) {
  __Block_byref_mutableA_0 *mutableA = __cself->mutableA; // bound by ref
  int a = __cself->a; // bound by copy

        int b = a;
        ++b;
        (mutableA->__forwarding->mutableA) = 1024;
    }
static void __blockMethod_block_copy_0(struct __blockMethod_block_impl_0*dst, struct __blockMethod_block_impl_0*src) {_Block_object_assign((void*)&dst->mutableA, (void*)src->mutableA, 8/*BLOCK_FIELD_IS_BYREF*/);}

static void __blockMethod_block_dispose_0(struct __blockMethod_block_impl_0*src) {_Block_object_dispose((void*)src->mutableA, 8/*BLOCK_FIELD_IS_BYREF*/);}

static struct __blockMethod_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __blockMethod_block_impl_0*, struct __blockMethod_block_impl_0*);
  void (*dispose)(struct __blockMethod_block_impl_0*);
} __blockMethod_block_desc_0_DATA = { 0, sizeof(struct __blockMethod_block_impl_0), __blockMethod_block_copy_0, __blockMethod_block_dispose_0};
void blockMethod() {
    int a = 10;
    __attribute__((__blocks__(byref))) __Block_byref_mutableA_0 mutableA = {(void*)0,(__Block_byref_mutableA_0 *)&mutableA, 0, sizeof(__Block_byref_mutableA_0), 100};
    captureScalar block = ((void (*)())&__blockMethod_block_impl_0((void *)__blockMethod_block_func_0, &__blockMethod_block_desc_0_DATA, a, (__Block_byref_mutableA_0 *)&mutableA, 570425344));

    ((id (*)(id, SEL))(void *)objc_msgSend)((id)block, sel_registerName("copy"));
}
static struct IMAGE_INFO { unsigned version; unsigned flag; } _OBJC_IMAGE_INFO = { 0, 2 };
