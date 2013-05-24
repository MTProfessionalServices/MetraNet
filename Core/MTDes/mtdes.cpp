#include "des_locl.h"


int encryptDES(char * apSrc, long aSrcLength, char ** appDest, long * apDestLength, const char * apKey)
{

	des_cblock kk; 
	unsigned char iv[8]; 
	des_key_schedule ks;

	des_string_to_key((char *)apKey,(C_Block *)kk);
	des_set_key((C_Block *)kk,ks);
	memset(kk,0,sizeof(kk));
	memset(iv,0,sizeof(iv));

  //Need to ensure input buffer is a multiple of 8 bytes
  //Create a new buffer and pad with x00
  char * pTempSource;
  long lTempSourceLength;
  lTempSourceLength= aSrcLength + (8-(aSrcLength%8));
  pTempSource= new char[lTempSourceLength];
  memset(pTempSource,0,lTempSourceLength);
  memcpy(pTempSource,apSrc,aSrcLength);
  
  *appDest= new char[lTempSourceLength];

  des_cbc_encrypt((des_cblock *)pTempSource,(des_cblock *)*appDest,
	                (long)lTempSourceLength,ks,(des_cblock *)iv,DES_ENCRYPT);

  *apDestLength=lTempSourceLength;

  delete pTempSource;

	return 1;

}

int decryptDES(char * apSrc, long aSrcLength, char ** appDest, long * apDestLength, const char * apKey)
{
	des_cblock kk; 
	unsigned char iv[8]; 
	des_key_schedule ks;

	des_string_to_key((char *)apKey,(C_Block *)kk);
	des_set_key((C_Block *)kk,ks);
	memset(kk,0,sizeof(kk));
	memset(iv,0,sizeof(iv));

  *appDest= new char[aSrcLength];

	des_cbc_encrypt((des_cblock *)apSrc,(des_cblock *)*appDest,
					(long)aSrcLength,ks,(des_cblock *)iv,DES_DECRYPT);

  *apDestLength=aSrcLength;

	return 1;

}
