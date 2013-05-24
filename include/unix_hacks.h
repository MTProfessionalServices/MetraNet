#ifndef UNIX_HACKS_H
#define UNIX_HACKS_H

/**************************************
 * This has all the defined hacks.    *
 **************************************/

#ifdef USE_TIME
#ifndef TIME_HACK
#define TIME_HACK
  #include <time.h>
  #define _TIME_T
  #define _CLOCK_T
  #ifdef __cplusplus
    using std::time_t; using std::clock_t;
  #endif
#endif
#endif

#ifdef USE_SIZE
#ifndef SIZE_HACK
#define SIZE_HACK
  #include <stddef.h>
  #define _SIZE_T
  #ifdef __cplusplus
    using std::size_t;
  #endif
#endif
#endif


#ifdef USE_IOS
#endif

#ifdef USE_MAP
#endif

#ifdef USE_STRING
#endif

#endif // UNIX_HACKS_H


