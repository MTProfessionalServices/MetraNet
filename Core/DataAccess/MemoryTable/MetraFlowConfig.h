#ifndef __METRAFLOWCONFIG_H__
#define __METRAFLOWCONFIG_H__

#include <boost/config.hpp>
#include <set>

#if defined(BOOST_HAS_DECLSPEC)
#  if defined(MEMORYTABLE_DEF)
#    define METRAFLOW_DECL __declspec(dllexport)
#  else
#    define METRAFLOW_DECL __declspec(dllimport)
#  endif
#else
#  define METRAFLOW_DECL
#endif

#endif
