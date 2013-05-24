#ifndef __MTSQLCONFIG_H__
#define __MTSQLCONFIG_H__

#include <boost/config.hpp>

#if defined(BOOST_HAS_DECLSPEC)
#  if defined(MTSQL_DEF)
#    define MTSQL_DECL __declspec(dllexport)
#  else
#    define MTSQL_DECL __declspec(dllimport)
#  endif
#else
#  define MTSQL_DECL
#endif

#endif
