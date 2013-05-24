// 
// SHA code mostly from SSLeay by Eric Young
//

#include <mtsha.h>
#include <stdlib.h>
#include <string.h>
#ifdef UNIX
#include <metraunix.h>
#endif
#include "sha_local.h"

#define INIT_DATA_A (unsigned long)0x67452301L
#define INIT_DATA_B (unsigned long)0xefcdab89L
#define INIT_DATA_C (unsigned long)0x98badcfeL
#define INIT_DATA_D (unsigned long)0x10325476L
#define INIT_DATA_E (unsigned long)0xc3d2e1f0L

#define K_00_19	0x5a827999L
#define K_20_39 0x6ed9eba1L
#define K_40_59 0x8f1bbcdcL
#define K_60_79 0xca62c1d6L

MTSHA::MTSHA(void)
{
    Init();
}


MTSHA::~MTSHA(void)
{

}

void MTSHA::Init(void)
{
    A0 = INIT_DATA_A;
    B0 = INIT_DATA_B;
    C0 = INIT_DATA_C;
    D0 = INIT_DATA_D;
    E0 = INIT_DATA_E;
    Nl = 0;
    Nh = 0;
    num = 0;
}


void MTSHA::Update(unsigned char *buf, unsigned long size)
{
    register ULONG *p;
    int ew,ec,sw,sc;
    ULONG l;

    if (size == 0) 
	return;

    l = (Nl + (size<<3)) & 0xffffffff;
    if (l < Nl) /* overflow */
	Nh++;
    Nh += (size>>29);
    Nl = l;
    
    if (num != 0)
    {
	p = (unsigned long *)data;
	sw = num>>2;
	sc = num&0x03;
	
	if ((num+size) >= MT_SHA_CBLOCK)
	{
	    l =  p[sw];
	    p_c2nl(buf,l,sc);
	    p[sw++] = l;
	    for (; sw<MT_SHA_LBLOCK; sw++)
	    {
		c2nl(buf,l);
		p[sw] = l;
	    }
	    size -= (MT_SHA_CBLOCK-num);
	    
	    Block(p);
	    num = 0;
	    /* drop through and do the rest */
	}
	else
	{
	    int ew,ec;
	    
	    num += (int)size;
	    if ((sc+size) < 4) /* ugly, add char's to a word */
	    {
		l =  p[sw];
		p_c2nl_p(buf,l,sc,size);
		p[sw] = l;
	    }
	    else
	    {
		ew = (num>>2);
		ec = (num&0x03);
		l =  p[sw];
		p_c2nl(buf,l,sc);
		p[sw++] = l;
		for (; sw < ew; sw++)
		{ c2nl(buf,l); p[sw] = l; }
		if (ec)
		{
		    c2nl_p(buf,l,ec);
		    p[sw] = l;
		}
	    }
	    return;
	}
    }
    /* we now can process the input data in blocks of MT_SHA_CBLOCK
     * chars and save the leftovers to data. */
    p = (unsigned long *)data;
    while (size >= MT_SHA_CBLOCK)
    {
#if defined(B_ENDIAN) || defined(L_ENDIAN)
	memcpy(p,buf,MT_SHA_CBLOCK);
	buf+=MT_SHA_CBLOCK;
#ifdef L_ENDIAN
	for (sw = (MT_SHA_LBLOCK/4); sw; sw--)
	{
	    Endian_Reverse32(p[0]);
	    Endian_Reverse32(p[1]);
	    Endian_Reverse32(p[2]);
	    Endian_Reverse32(p[3]);
	    p+=4;
	}
#endif
#else
	for (sw=(MT_SHA_LBLOCK/4); sw; sw--)
	{
	    c2nl(buf,l); *(p++) = l;
	    c2nl(buf,l); *(p++) = l;
	    c2nl(buf,l); *(p++) = l;
	    c2nl(buf,l); *(p++) = l;
	}
#endif
	p = (unsigned long *)data;
	Block(p);
	size-=MT_SHA_CBLOCK;
    }
    ec = (int)size;
    num = ec;
    ew = (ec>>2);
    ec&=0x03;
    
    for (sw = 0; sw < ew; sw++)
    { 
	c2nl(buf,l); 
	p[sw] = l; 
    }
    c2nl_p(buf,l,ec);
    p[sw] = l;

}

void MTSHA::Final(unsigned char *digest_outbuf)
{
    register int i,j;
    register ULONG l;
    register ULONG *p;
    static unsigned char end[4]={0x80,0x00,0x00,0x00};
    unsigned char *cp=end;
    
    /* num should definitly have room for at least one more byte. */
    p = data;
    j = num;
    i = j>>2;
#ifdef PURIFY
    if ((j & 0x03) == 0) p[i] = 0;
#endif
    l = p[i];
    p_c2nl(cp,l,j&0x03);
    p[i] = l;
    i++;
    /* i is the next 'undefined word' */
    if (num >= MT_SHA_LAST_BLOCK)
    {
	for (; i<MT_SHA_LBLOCK; i++)
	    p[i] = 0;
	Block(p);
	i = 0;
    }
    for (; i<(MT_SHA_LBLOCK-2); i++)
	p[i] = 0;
    p[MT_SHA_LBLOCK-2] = Nh;
    p[MT_SHA_LBLOCK-1] = Nl;
    Block(p);
    cp = digest_outbuf;
    l = A0; nl2c(l,cp);
    l = B0; nl2c(l,cp);
    l = C0; nl2c(l,cp);
    l = D0; nl2c(l,cp);
    l = E0; nl2c(l,cp);
    /* clear stuff, mt_sha_block may be leaving some stuff on the stack
     * but I'm not worried :-) */
    num = 0;
}


void MTSHA::Block(unsigned long *X)
{
    register ULONG A,B,C,D,E,T;

    A = A0;
    B = B0;
    C = C0;
    D = D0;
    E = E0;

    BODY_00_15( 0,A,B,C,D,E,T);
    BODY_00_15( 1,T,A,B,C,D,E);
    BODY_00_15( 2,E,T,A,B,C,D);
    BODY_00_15( 3,D,E,T,A,B,C);
    BODY_00_15( 4,C,D,E,T,A,B);
    BODY_00_15( 5,B,C,D,E,T,A);
    BODY_00_15( 6,A,B,C,D,E,T);
    BODY_00_15( 7,T,A,B,C,D,E);
    BODY_00_15( 8,E,T,A,B,C,D);
    BODY_00_15( 9,D,E,T,A,B,C);
    BODY_00_15(10,C,D,E,T,A,B);
    BODY_00_15(11,B,C,D,E,T,A);
    BODY_00_15(12,A,B,C,D,E,T);
    BODY_00_15(13,T,A,B,C,D,E);
    BODY_00_15(14,E,T,A,B,C,D);
    BODY_00_15(15,D,E,T,A,B,C);
    BODY_16_19(16,C,D,E,T,A,B);
    BODY_16_19(17,B,C,D,E,T,A);
    BODY_16_19(18,A,B,C,D,E,T);
    BODY_16_19(19,T,A,B,C,D,E);

    BODY_20_39(20,E,T,A,B,C,D);
    BODY_20_39(21,D,E,T,A,B,C);
    BODY_20_39(22,C,D,E,T,A,B);
    BODY_20_39(23,B,C,D,E,T,A);
    BODY_20_39(24,A,B,C,D,E,T);
    BODY_20_39(25,T,A,B,C,D,E);
    BODY_20_39(26,E,T,A,B,C,D);
    BODY_20_39(27,D,E,T,A,B,C);
    BODY_20_39(28,C,D,E,T,A,B);
    BODY_20_39(29,B,C,D,E,T,A);
    BODY_20_39(30,A,B,C,D,E,T);
    BODY_20_39(31,T,A,B,C,D,E);
    BODY_20_39(32,E,T,A,B,C,D);
    BODY_20_39(33,D,E,T,A,B,C);
    BODY_20_39(34,C,D,E,T,A,B);
    BODY_20_39(35,B,C,D,E,T,A);
    BODY_20_39(36,A,B,C,D,E,T);
    BODY_20_39(37,T,A,B,C,D,E);
    BODY_20_39(38,E,T,A,B,C,D);
    BODY_20_39(39,D,E,T,A,B,C);

    BODY_40_59(40,C,D,E,T,A,B);
    BODY_40_59(41,B,C,D,E,T,A);
    BODY_40_59(42,A,B,C,D,E,T);
    BODY_40_59(43,T,A,B,C,D,E);
    BODY_40_59(44,E,T,A,B,C,D);
    BODY_40_59(45,D,E,T,A,B,C);
    BODY_40_59(46,C,D,E,T,A,B);
    BODY_40_59(47,B,C,D,E,T,A);
    BODY_40_59(48,A,B,C,D,E,T);
    BODY_40_59(49,T,A,B,C,D,E);
    BODY_40_59(50,E,T,A,B,C,D);
    BODY_40_59(51,D,E,T,A,B,C);
    BODY_40_59(52,C,D,E,T,A,B);
    BODY_40_59(53,B,C,D,E,T,A);
    BODY_40_59(54,A,B,C,D,E,T);
    BODY_40_59(55,T,A,B,C,D,E);
    BODY_40_59(56,E,T,A,B,C,D);
    BODY_40_59(57,D,E,T,A,B,C);
    BODY_40_59(58,C,D,E,T,A,B);
    BODY_40_59(59,B,C,D,E,T,A);

    BODY_60_79(60,A,B,C,D,E,T);
    BODY_60_79(61,T,A,B,C,D,E);
    BODY_60_79(62,E,T,A,B,C,D);
    BODY_60_79(63,D,E,T,A,B,C);
    BODY_60_79(64,C,D,E,T,A,B);
    BODY_60_79(65,B,C,D,E,T,A);
    BODY_60_79(66,A,B,C,D,E,T);
    BODY_60_79(67,T,A,B,C,D,E);
    BODY_60_79(68,E,T,A,B,C,D);
    BODY_60_79(69,D,E,T,A,B,C);
    BODY_60_79(70,C,D,E,T,A,B);
    BODY_60_79(71,B,C,D,E,T,A);
    BODY_60_79(72,A,B,C,D,E,T);
    BODY_60_79(73,T,A,B,C,D,E);
    BODY_60_79(74,E,T,A,B,C,D);
    BODY_60_79(75,D,E,T,A,B,C);
    BODY_60_79(76,C,D,E,T,A,B);
    BODY_60_79(77,B,C,D,E,T,A);
    BODY_60_79(78,A,B,C,D,E,T);
    BODY_60_79(79,T,A,B,C,D,E);

    A0 = (A0+E)&0xffffffff; 
    B0 = (B0+T)&0xffffffff;
    C0 = (C0+A)&0xffffffff;
    D0 = (D0+B)&0xffffffff;
    E0 = (E0+C)&0xffffffff;
}

void MTSHA::Hash(unsigned char *buf, unsigned long n, 
		  unsigned char *hash)
{
    Init();
    Update(buf, n);
    Final(hash);
}

