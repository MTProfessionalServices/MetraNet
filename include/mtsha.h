//
// Public headers for sha class wrapper
//

#ifndef _mtsha_h_
#define _mtsha_h_

#define MT_SHA_CBLOCK      	64
#define MT_SHA_LAST_BLOCK  	56
#define MT_SHA_LBLOCK      	16
#define MT_SHA_BLOCK       	16
#define MT_SHA_LENGTH_BLOCK 	8
#define MT_SHA_DIGEST_LENGTH 	20


class MTSHA
{
// @access Public
public:
    // @cmember Constructor which creates memory and initializes member data
    MTSHA(void);

    // @cmember Destructor used to free the object and its member data
    ~MTSHA(void);

    void Init(void);
    void Hash(unsigned char *data, unsigned long n, unsigned char *hash);
    void Update(unsigned char *data, unsigned long size);
    void Final(unsigned char *digest_outbuf);

private:

    void Block(unsigned long *ptr);

    unsigned long	A0;
    unsigned long	B0;
    unsigned long	C0;
    unsigned long	D0;
    unsigned long	E0;
    
    unsigned long 	Nl;
    unsigned long	Nh;
    unsigned long 	data[MT_SHA_LBLOCK];
    int 		num;

};

#endif /* _mtsha_h_ */
