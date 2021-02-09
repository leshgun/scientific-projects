#include <Windows.h>
#include <wincrypt.h>
#include <stdio.h>

static HCRYPTPROV hProv;

static void providerConnect(LPCTSTR pszProvider, DWORD dwProvType) {
	CryptAcquireContext(&hProv, NULL, pszProvider, dwProvType, CRYPT_VERIFYCONTEXT);
}

static void providerDisconnect() {
	CryptReleaseContext(hProv, 0);
}

static const char* getProvIMPType() {
	DWORD bData;
	DWORD dwDataLen = sizeof(bData);
	BOOL result;
	result = CryptGetProvParam(hProv, PP_IMPTYPE, (BYTE*)&bData, &dwDataLen, 0);
	if (result) {
		switch (bData)
		{
		case CRYPT_IMPL_HARDWARE:
			return "Криптопровайдер реализован аппаратно";
		case CRYPT_IMPL_SOFTWARE:
			return "Криптопровайдер реализован программно";
		case CRYPT_IMPL_MIXED:
			return "Смешанная реализация";
		case CRYPT_IMPL_UNKNOWN:
			return "Реализация неизвестна";
		case CRYPT_IMPL_REMOVABLE:
			return "Криптопровайдер реализован на съёмном носителе";
		default:
			return 0;
		}
	}
}

static const char* getAlgClass(DWORD *aiAlgid, char* pHasKeys) {
	switch (GET_ALG_CLASS(*aiAlgid))
	{
	case ALG_CLASS_DATA_ENCRYPT:
		*pHasKeys = 1;
		return "Алгоритм для шифрования данных";
	case ALG_CLASS_HASH:
		return "Алгоритм хеширования";
	case ALG_CLASS_KEY_EXCHANGE:
		*pHasKeys = 1;
		return "Алгоритм для обмена ключами";
	case ALG_CLASS_SIGNATURE:
		*pHasKeys = 1;
		return "Алгоритм для цифровой подписи";
	default:
		return "Алгоритм иного назначения";
	}
}

static const char* getAlgType(DWORD* aiAlgid) {
	switch (GET_ALG_TYPE(*aiAlgid))
	{
	case ALG_TYPE_DSS:
		return "Действует по схеме DSS";
	case ALG_TYPE_RSA:
		return "Действуюет по схеме RSA";
	case ALG_TYPE_BLOCK:
		return "Блочный шифр";
	case ALG_TYPE_STREAM:
		return "Поточный шифр";
	default:
		return "Тип - неизвестен";
	}
}

static char getAlgProtocols(DWORD* dwProtocols, char* buf, char bufLen) {
	strcpy_s(buf, bufLen, "");
	char i = 0;
	if (*dwProtocols & CRYPT_FLAG_IPSEC) { strcat_s(buf, bufLen, "IPSec, "); i += 1; }
	if (*dwProtocols & CRYPT_FLAG_PCT1) { strcat_s(buf, bufLen, "PCT_1, "); i += 1; }
	if (*dwProtocols & CRYPT_FLAG_SIGNING) { strcat_s(buf, bufLen, "ЭЦП, "); i += 1; }
	if (*dwProtocols & CRYPT_FLAG_SSL2) { strcat_s(buf, bufLen, "SSL_2, "); i += 1; }
	if (*dwProtocols & CRYPT_FLAG_SSL3) { strcat_s(buf, bufLen, "SSL_3, "); i += 1; }
	if (*dwProtocols & CRYPT_FLAG_TLS1) { strcat_s(buf, bufLen, "TLS_1, "); i += 1; }
	if (i) buf[strlen(buf)-2] = '\0';
	return i;
}

static char getProvVersion(char* vHigh, char* vLow) {
	DWORD bData;
	DWORD dwDataLen = sizeof(bData);
	BOOL result;
	result = CryptGetProvParam(hProv, PP_VERSION, (BYTE*)&bData, &dwDataLen, 0);
	if (result) {
		*vHigh = (bData & 0xFF00) >> 8;
		*vLow = bData & 0xFF;
		return 1;
	}
	return 0;
}

static void printProvAlg() {
	PROV_ENUMALGS_EX bData;
	DWORD dwDataLen = sizeof(PROV_ENUMALGS_EX);
	DWORD dwFlags = CRYPT_FIRST;
	char buf[50], numAlg, hasKeys;
	char i = 1;
	while (CryptGetProvParam(hProv, PP_ENUMALGS_EX, (BYTE*)&bData, &dwDataLen, dwFlags)) {
		printf("(%d)\n", i);
		printf("--- ID: %d\n", bData.aiAlgid);
		printf("--- Name: %s (%s)\n", bData.szLongName, bData.szName);
		hasKeys = 0;
		printf("--- %s\n", getAlgClass(&bData.aiAlgid, &hasKeys));
		printf("--- %s\n", getAlgType(&bData.aiAlgid));
		if (hasKeys) {
			printf("--- Default key length: %d (bit)\n", bData.dwDefaultLen);
			printf("--- Minimal key length: %d (bit)\n", bData.dwMinLen);
			printf("--- Maximum key length: %d (bit)\n", bData.dwMaxLen);
		}
		numAlg = getAlgProtocols(&bData.dwProtocols, &buf, 40);
		if (numAlg) {
			printf("--- Available %d protocol(-s): ", numAlg);
			printf(" %s\n", buf);
		}
		dwFlags = CRYPT_NEXT;
		i += 1;
	}
}

static void printIncSteps() {
	DWORD bData;
	DWORD dwDataLen = sizeof(bData);
	BOOL result;
	result = CryptGetProvParam(hProv, PP_SIG_KEYSIZE_INC, (BYTE*)&bData, &dwDataLen, 0);
	if (result) printf("Incremental step for digital signature key length: %d\n", bData);
	result = CryptGetProvParam(hProv, PP_KEYX_KEYSIZE_INC, (BYTE*)&bData, &dwDataLen, 0);
	if (result) printf("Шncremental step for the key length the key exchange algorithm: %d\n", bData);
}

static void printProviderDescription(const char * pszProvider, DWORD dwProvType) {
	char vHigh, vLow;
	providerConnect(pszProvider, dwProvType);
	printf("\n*** %S ***\n", pszProvider);
	printf("%s\n", getProvIMPType());
	getProvVersion(&vHigh, &vLow);
	printf("Версия провайдера: %d.%d\n", vHigh, vLow);
	printIncSteps();
	printf("Supported Algorithms:\n");
	printProvAlg();
	providerDisconnect();
}

void main()
{
	SetConsoleCP(1251);
	SetConsoleOutputCP(1251);

	//printProviderDescription(TEXT("Microsoft Strong Cryptographic Provider"), 1);
	printProviderDescription(TEXT("Microsoft RSA SChannel Cryptographic Provider"),12);

	printf("\n");

}