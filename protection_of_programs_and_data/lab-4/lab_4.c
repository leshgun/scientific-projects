#include <Windows.h>
#include <wincrypt.h>
#include <stdio.h>

static void printContKeyError() {
	switch (GetLastError())
	{
	case ERROR_INVALID_HANDLE:
		printf("ERROR_INVALID_HANDLE \n");
		break;
	case ERROR_INVALID_PARAMETER:
		printf("ERROR_INVALID_PARAMETER \n");
		break;
	case NTE_BAD_KEY:
		printf("NTE_BAD_KEY \n");
		break;
	case NTE_BAD_UID:
		printf("NTE_BAD_UID \n");
		break;
	case NTE_NO_KEY:
		printf("NTE_NO_KEY \n");
		break;
	default:
		printf("Невідома помилка... \n");
		break;
	}
}

static void printContKeys(LPCWSTR pszProvider, DWORD dwProvType, LPCWSTR contName) {

	HCRYPTPROV hCryptProv = NULL;
	HCRYPTKEY hKey = 0;

	printf("Container's name: %S\n", contName);

	if (CryptAcquireContext(&hCryptProv, contName, pszProvider, dwProvType, 0))
	{
		printf("--- Private key: ");
		if (CryptGetUserKey(hCryptProv, AT_KEYEXCHANGE, &hKey))printf("%X\n", hKey);
		else printContKeyError();
		CryptDestroyKey(hKey);

		printf("--- Signature: ");
		if (CryptGetUserKey(hCryptProv, AT_SIGNATURE, &hKey))printf("%X\n", hKey);
		else printContKeyError();
		CryptDestroyKey(hKey);
	}
	else
	{
		printf("--- Last Error: %x \n", GetLastError());
		printf("--- A cryptographic service handle could not be "
			"acquired.\n\n");
	}
	CryptReleaseContext(hCryptProv, 0);
	
}

static void printProvCont(LPCWSTR pszProvider, DWORD dwProvType) {

	HCRYPTPROV hCryptProv = NULL;
	LPCWSTR pbData[70];
	DWORD dwDataLen = sizeof(pbData);
	DWORD dwFlags = CRYPT_FIRST;

	if (CryptAcquireContext(
		&hCryptProv,						// handle to the CSP
		NULL,								// container name 
		pszProvider,						// provider name
		dwProvType,							// provider type
		CRYPT_VERIFYCONTEXT))				// flag values
	{
		char i = 1;
		while (CryptGetProvParam(hCryptProv, PP_ENUMCONTAINERS, &pbData, &dwDataLen, dwFlags)) {
			printf("--- Container Name (%d): %s\n", strlen(pbData), pbData);
			dwFlags = CRYPT_NEXT;
			i += 1;
		}
	}

	//-------------------------------------------------------------------
	// When the handle is no longer needed, it must be released.
	if (CryptReleaseContext(hCryptProv, 0)) printf("The handle has been released.\n");
	else printf("The handle could not be released.\n");

}

static void createNewProvCont(LPCWSTR pszProvider, DWORD dwProvType, LPCWSTR UserName) {

	HCRYPTPROV hCryptProv = NULL; 
	
	if (CryptAcquireContext(&hCryptProv, UserName, pszProvider, dwProvType, 0))
	{
		printf("A cryptographic context with the %s key container \n", UserName);
		printf("has been acquired.\n\n");
	}
	else
	{
		//-------------------------------------------------------------------
		// An error occurred in acquiring the context. This could mean
		// that the key container requested does not exist. In this case,
		// the function can be called again to attempt to create a new key 
		// container. Error codes are defined in Winerror.h.
		if (GetLastError() == NTE_BAD_KEYSET)
		{
			if (CryptAcquireContext(
				&hCryptProv,
				UserName,
				NULL,
				PROV_RSA_FULL,
				CRYPT_NEWKEYSET))
			{
				printf("A new key container has been created.\n");
			}
			else
			{
				printf("Could not create a new key container.\n");
				exit(1);
			}
		}
		else
		{
			printf("A cryptographic service handle could not be "
				"acquired.\n");
			exit(1);
		}

	} // End of else.
	//-------------------------------------------------------------------
	// A cryptographic context and a key container are available. Perform
	// any functions that require a cryptographic provider handle.

	//-------------------------------------------------------------------
	// When the handle is no longer needed, it must be released.

	if (CryptReleaseContext(hCryptProv, 0)) printf("The handle has been released.\n");
	else printf("The handle could not be released.\n");

}


static void genProvContKeys(LPCWSTR pszProvider, DWORD dwProvType, LPCWSTR contName, DWORD dwAlgid) {

	HCRYPTPROV hCryptProv = NULL;
	HCRYPTKEY phKey;
	DWORD dwFlags;


	if (CryptAcquireContext(&hCryptProv, contName, pszProvider, dwProvType, 0))
	{
		if (CryptGenKey(hCryptProv, dwAlgid, 0, &phKey))
		{
			printf("Key has been created...\n");
		}
		else
		{
			switch (GetLastError())
			{
			case ERROR_INVALID_HANDLE:
				printf("ERROR_INVALID_HANDLE \n");
				break;
			case ERROR_INVALID_PARAMETER:
				printf("ERROR_INVALID_PARAMETER \n");
				break;
			case NTE_BAD_ALGID:
				printf("NTE_BAD_ALGID \n");
				break;
			case NTE_BAD_FLAGS:
				printf("NTE_BAD_FLAGS \n");
				break;
			case NTE_BAD_UID:
				printf("NTE_BAD_UID \n");
				break;
			case NTE_FAIL:
				printf("NTE_FAIL \n");
				break;
			case NTE_SILENT_CONTEXT:
				printf("NTE_SILENT_CONTEXT \n");
				break;
			default:
				printf("Невідома помилка... \n");
				break;
			}
		}
		CryptDestroyKey(phKey);
	}
	if (CryptReleaseContext(hCryptProv, 0)) printf("The handle has been released.\n");
	else printf("The handle could not be released.\n");

}


static void printProviderContainers(LPCWSTR pszProvider, DWORD dwProvType) {

	//createNewProvCont(pszProvider, dwProvType, TEXT("lab4test"));
	//createNewProvCont(pszProvider, dwProvType, TEXT("А на елфійском мовою?"));
	//genProvContKeys(pszProvider, dwProvType, TEXT("lab4test"), CALG_RSA_KEYX);
	//genProvContKeys(pszProvider, dwProvType, TEXT("test"), AT_SIGNATURE);
	
	printProvCont(pszProvider, dwProvType);
	printf("\n");
	printContKeys(pszProvider, dwProvType, TEXT("123"));
	printf("\n");
	printContKeys(pszProvider, dwProvType, TEXT("Logitech Update Container"));
	printf("\n");
	printContKeys(pszProvider, dwProvType, TEXT("CoolContainer"));
	printf("\n");
	printContKeys(pszProvider, dwProvType, TEXT("lab4test"));
	printf("\n");
	printContKeys(pszProvider, dwProvType, TEXT("Alexey"));
	printf("\n");
	printContKeys(pszProvider, dwProvType, TEXT("test"));

}


void main()
{
	SetConsoleCP(1251);
	SetConsoleOutputCP(1251);
	printProviderContainers(TEXT("Microsoft Strong Cryptographic Provider"), 1);
	printf("\n");
}	
