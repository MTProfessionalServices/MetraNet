#ifndef _MTSSL_H
#define _MTSSL_H

#include <stdio.h>

#ifdef UNIX
	#ifdef __cplusplus
		using namespace std;
	#endif
#endif

#ifdef USE_RSA_SSL
#include <sslc.h>
#else
#include <ssl.h>
#endif

#endif
