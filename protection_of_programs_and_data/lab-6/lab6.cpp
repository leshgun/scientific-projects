#include <iostream>
#include <Windows.h>
#include <wincrypt.h>


#define PROV_NAME TEXT("Microsoft Enhanced RSA and AES Cryptographic Provider")
#define PROV_TYPE 24
#define ALGID 41984
#define HASH_ALGID CALG_MD5
#define BUFFER_SIZE 100
#define ERROR "123"


static const char* GetError(void);
static void HandleError(const char* s);
static void HandlePrint(const char* s);
static void CleanUp(void);

static HCRYPTPROV hProv = 0;
static HCRYPTKEY hKey = 0;
static HCRYPTHASH hHash = 0;
static DWORD dwBlobLen = 0;
static DWORD dwHashSize = 0;
static BYTE* pbBlob = NULL;
static FILE* myFile;


void lab6_1() {

	if (CryptAcquireContext(&hProv, NULL, PROV_NAME, PROV_TYPE, 0))
		HandlePrint("The provider has been acquired");
	else HandleError("Error during CryptAcquireContext.");

	if (CryptGetUserKey(hProv, AT_SIGNATURE, &hKey))
		HandlePrint("The provider signature has been acquired");
	else {
		if (GetLastError() == NTE_NO_KEY) {
			if (CryptGenKey(hProv, AT_SIGNATURE, CRYPT_EXPORTABLE, &hKey))
				HandlePrint("Exportale key has been created");
			else HandleError("Error during CryptGenKey.");
		}
		else HandleError("Error during CryptGetUserKey.");
	}

	if (CryptExportKey(hKey, 0, PUBLICKEYBLOB, 0, NULL, &dwBlobLen))
		HandlePrint("Size of the BLOB for the responder public key determined");
	else HandleError("Error computing BLOB length.");

	pbBlob = (BYTE*)malloc(dwBlobLen);

	if (pbBlob) HandlePrint("Memory has been allocated for the BLOB");
	else HandleError("Out of memory. \n");

	if (CryptExportKey(hKey, 0, PUBLICKEYBLOB, 0, pbBlob, &dwBlobLen))
		HandlePrint("Contents have been written to the BLOB");
	else HandleError("Error during CryptExportKey.");

	if (!fopen_s(&myFile, "lab6-1.bin", "wb"))
		fwrite(pbBlob, 1, dwBlobLen, myFile);
	if (myFile) fclose(myFile);
	
	//CleanUp();

}


void lab6_2() {

	DWORD howManyRead = 0;
	BYTE* buffer = (BYTE*)malloc(BUFFER_SIZE);
	
	/*if (CryptAcquireContext(&hProv, NULL, PROV_NAME, PROV_TYPE, CRYPT_VERIFYCONTEXT))
		HandlePrint("The provider has been acquired");
	else HandleError("Error during CryptAcquireContext.");*/

	if (CryptCreateHash(hProv, HASH_ALGID, NULL, 0, &hHash))
		HandlePrint("The hash algorithm has been created");
	else HandleError("Error during CryptCreateHash.");

	if (fopen_s(&myFile, "lab6-2-song.txt", "rb"))
		HandleError("Error with oppening the file \"lab6-2-song.txt\".");

	while (feof(myFile) == 0)
	{
		howManyRead = fread(buffer, 1, BUFFER_SIZE-4, myFile);
		if (!ferror(myFile)) {
			dwBlobLen = howManyRead;
			CryptHashData(hHash, buffer, dwBlobLen, 0);
		}
		else HandleError("Error with ferror.");
	}
	if (myFile) fclose(myFile);

	if (CryptGetHashParam(hHash, HP_HASHVAL, NULL, &dwHashSize, 0))
		HandlePrint("Size of the hash value determined");
	else HandleError("Error computing hash value length.");

	buffer = (BYTE*)malloc(dwHashSize);

	if (CryptGetHashParam(hHash, HP_HASHVAL, buffer, &dwHashSize, 0))
		HandlePrint("The hash value has been created");
	else HandleError("Error during CryptGetHashParam.");

	if (!fopen_s(&myFile, "lab6-2-hash.bin", "wb"))
		fwrite(buffer, 1, dwHashSize, myFile);
	if (myFile) fclose(myFile);

	if (CryptSignHash(hHash, AT_SIGNATURE, NULL, 0, NULL, &dwHashSize))
		HandlePrint("Size of the sign determined");
	else HandleError("Error computing sign length.");

	buffer = (BYTE*)malloc(dwHashSize);

	if (CryptSignHash(hHash, AT_SIGNATURE, NULL, 0, buffer, &dwHashSize))
		HandlePrint("The sign has been created");
	else HandleError("Error during CryptSignHash.");

	if (!fopen_s(&myFile, "lab6-2-sign.bin", "wb"))
		fwrite(buffer, 1, dwHashSize, myFile);
	if (myFile) fclose(myFile);

	free(buffer);
}


void lab6_3() {
	if (!fopen_s(&myFile, "lab6-2-sign.bin", "rb")) {
		fseek(myFile, 0L, SEEK_END);
		dwBlobLen = (DWORD)ftell(myFile);
		fseek(myFile, 0L, SEEK_SET);
	}
	else HandleError("Error with oppening the file \"lab6-2-sign.bin\".");

	pbBlob = (BYTE*)malloc(dwBlobLen);

	if (pbBlob) HandlePrint("Memory has been allocated for the sign");
	else HandleError("Out of memory. \n");

	if (fread(pbBlob, 1, dwBlobLen, myFile))
		HandlePrint("Sign have been read from the file \"lab6-2-sign.bin\"");
	else HandleError("Error with reading the file \"lab6-2-sign.bin\".");
	fclose(myFile);

	if (CryptVerifySignature(hHash, pbBlob, dwBlobLen, hKey, NULL, 0))
		HandlePrint("The signature is accepted");
	else {
		if (GetLastError() == NTE_BAD_SIGNATURE)
			HandlePrint("The signature is not accepted");
		else
			HandleError("Error during CryptVerifySignature.");
	}
}


void lab6_4() {

	DWORD end = 1;

	if (!fopen_s(&myFile, "lab6-2-sign.bin", "ab+"))
		fseek(myFile, 0L, SEEK_END);
		fwrite(ERROR, 1, sizeof(ERROR), myFile);
	if (myFile) fclose(myFile);
	HandlePrint("The signature have been changed");
	lab6_3();

}


int main()
{
	std::cout << "\nStep 1\n";
	lab6_1();
	std::cout << "\nStep 2\n";
	lab6_2();
	std::cout << "\nStep 3\n";
	lab6_3();
	std::cout << "\nStep 4\n";
	lab6_4();

	printf("\nThe program ran to completion without error. \n");
	CleanUp();
	return 0;
}


static const char* GetError() {
	switch (GetLastError())
	{
	case ERROR_INVALID_HANDLE:
		return "ERROR_INVALID_HANDLE";
	case ERROR_INVALID_PARAMETER:
		return "ERROR_INVALID_PARAMETER";
	case ERROR_MORE_DATA:
		return "ERROR_MORE_DATA";
	case NTE_BAD_ALGID:
		return "NTE_BAD_ALGID";
	case NTE_BAD_DATA:
		return "NTE_BAD_DATA";
	case NTE_BAD_FLAGS:
		return "NTE_BAD_FLAGS";
	case NTE_BAD_HASH:
		return "NTE_BAD_HASH";
	case NTE_BAD_KEY:
		return "NTE_BAD_KEY";
	case NTE_BAD_KEY_STATE:
		return "NTE_BAD_KEY_STATE";
	case NTE_BAD_PUBLIC_KEY:
		return "NTE_BAD_PUBLIC_KEY";
	case NTE_BAD_TYPE:
		return "NTE_BAD_TYPE";
	case NTE_BAD_UID:
		return "NTE_BAD_UID";
	case NTE_FAIL:
		return "NTE_FAIL";
	case NTE_NO_KEY:
		return "NTE_NO_KEY";
	case NTE_NO_MEMORY:
		return "NTE_NO_MEMORY";
	case NTE_SILENT_CONTEXT:
		return "NTE_SILENT_CONTEXT";
	default:
		std::cout << GetLastError() << '\n';
		return "Невідома помилка";
	}
}

static void HandlePrint(const char* s) {
	std::cout << "--- " << s << "..." << "\n";
}

static void HandleError(const char* s) {
	HandlePrint(s);
	HandlePrint(GetError());
	CleanUp();
	exit(0);
}

void CleanUp(void)
{

	free(pbBlob);

	// Закрытие файлов.
	if (myFile) fclose(myFile);

	// Уничтожение дескрипторов.
	if (hKey) CryptDestroyKey(hKey);

	// Освобождение дескриптора провайдера.
	if (hProv) CryptReleaseContext(hProv, 0);

	// Уничтожение хешей.
	if (hHash) CryptDestroyHash(hHash);
}
