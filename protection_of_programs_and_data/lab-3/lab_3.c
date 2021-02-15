#include <Windows.h>
#include <wincrypt.h>
#include <stdio.h>


static HCRYPTPROV hProv;
static HCRYPTHASH hHash;


static void providerAndHashConnect(LPCTSTR pszProvider, DWORD dwProvType, DWORD dwAlgid) {
	CryptAcquireContext(&hProv, NULL, pszProvider, dwProvType, CRYPT_VERIFYCONTEXT);
	CryptCreateHash(hProv, dwAlgid, 0, 0, &hHash);
}


static void providerAndHashDisconnect() {
	CryptDestroyHash(hHash);
	CryptReleaseContext(hProv, 0);
}


static void getHashFromFile(const char* fileName, BYTE* pbHashValue, DWORD dwHashSize) {

	FILE* myFile;
	BYTE* buffer = (BYTE*)malloc(100);
	size_t howManyRead;
	DWORD dwDataLen;

	printf("Reading file '%s'...\n", fileName);
	if (!fopen_s(&myFile, fileName, "rb")) {
		while (feof(myFile) == 0)
		{
			howManyRead = fread(buffer, 1, 96, myFile);
			if (ferror(myFile) == 0)
			{
				dwDataLen = howManyRead;
				CryptHashData(hHash, buffer, dwDataLen, 0);
			}
			else
			{
				printf("Error...\n");
				break;
			}
		}
		CryptGetHashParam(hHash, HP_HASHVAL, pbHashValue, &dwHashSize, 0);
	}
	if (myFile) fclose(myFile);
}


static void printHashSum(const char* pszProvider, DWORD dwProvType, DWORD dwAlgid) {

	DWORD dwHashSize = 20;
	BYTE* pbHashValue = (BYTE*)malloc(dwHashSize);

	providerAndHashConnect(pszProvider, dwProvType, dwAlgid);

	getHashFromFile("text.txt", pbHashValue, dwHashSize);
	if (pbHashValue) {
		pbHashValue[16] = '\0';
		printf("Hash of file: %s\n", pbHashValue);
		for (char i = 0; i < 16; i++) {
			printf("0x%.2X ", pbHashValue[i]);
		}
		printf("\n");
		free(pbHashValue);
	}

	providerAndHashDisconnect();
}


void main()
{
	SetConsoleCP(1251);
	SetConsoleOutputCP(1251);

	printf("\n");

	printHashSum(TEXT("Microsoft RSA SChannel Cryptographic Provider"), 12, 32771);
	// printHashSum(TEXT("Microsoft Strong Cryptographic Provider"), 1);

	printf("\n");

}