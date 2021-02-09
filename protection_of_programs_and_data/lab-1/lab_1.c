#include <Windows.h>
#include <wincrypt.h>
#include <stdio.h>

static void printNamesAllProviders() {
	DWORD dwProvType, cbProvName, errorNo;
	DWORD dwBufSize = 40;
	LPCSTR pszProvName = (CHAR*)malloc(dwBufSize);

	BOOL result = 1;
	DWORD i = 0;
	while (result)
	{
		cbProvName = dwBufSize;
		result = CryptEnumProviders(i, NULL, 0, &dwProvType, pszProvName, &cbProvName);
		errorNo = GetLastError();
		if (result == 0)
		{
			if (errorNo == 259) break;
			free(pszProvName);
			dwBufSize = cbProvName;
			pszProvName = (TCHAR*)malloc(dwBufSize);
			result = CryptEnumProviders(i, NULL, 0, &dwProvType, pszProvName, &cbProvName);
		}
		printf("%S - %d \n", pszProvName, dwProvType);
		i = i + 1;
	}
}

static void printNamesAllProviderTypes() {
	DWORD dwProvType, cbTypeName, errorNo;
	DWORD dwBufSize = 100;
	LPCSTR pszTypeName = (CHAR*)malloc(dwBufSize);

	BOOL result = 1;
	DWORD i = 0;
	while (result)
	{
		result = CryptEnumProviderTypes(i, NULL, 0, &dwProvType, pszTypeName, &cbTypeName);
		errorNo = GetLastError();
		if (result == 0)
		{
			if (errorNo == 259) break;
			free(pszTypeName);
			dwBufSize = cbTypeName;
			pszTypeName = (TCHAR*)malloc(dwBufSize);
			result = CryptEnumProviderTypes(i, NULL, 0, &dwProvType, pszTypeName, &cbTypeName);
		}
		printf("%S\n", pszTypeName);
		i = i + 1;
	}
}

void main()
{
	SetConsoleCP(1251);
	SetConsoleOutputCP(1251);

	printNamesAllProviders();
	printf("\n");
	printNamesAllProviderTypes();
	printf("\n");

}