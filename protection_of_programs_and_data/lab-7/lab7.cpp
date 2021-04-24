//--------------------------------------------------------------------
// В данном лабоатороной работе производится зашифрование файла на 
// сеансовом ключе на основе пароля.
// 
// Нееобходимо создать файл, подлежаший зашифрованию, с именем "song.txt".
//--------------------------------------------------------------------

#include <iostream>
#include <Windows.h>
#include <wincrypt.h>

#define BLOCK_LENGTH 4096
#define password "Passw0rd"
#define pszProvider TEXT("Microsoft RSA SChannel Cryptographic Provider")
#define dwProvType 12
#define dwAlgid 26128

#define hashAlgid CALG_MD5
#define encryptAlgid CALG_RC2

static void HandleError(const char* s);
static void CleanUp(void);

//static LPCWSTR pszProvider = TEXT("Microsoft RSA SChannel Cryptographic Provider");
//static DWORD dwProvType = 12;
//static DWORD dwAlgid = 26128;
//static const char* password = "Passw0rd";

static HCRYPTPROV hProv = 0;            // Дескриптор CSP 
static HCRYPTKEY hKey = 0;              // Дескриптор закрытого ключа 
static HCRYPTHASH hHash = 0;

static FILE* source = NULL;               // Исходный файл
static FILE* Encrypt = NULL;              // Зашифрованный файл
static FILE* pass = NULL;
static FILE* Decrypt = NULL;
//static FILE* vectorf = NULL;              // Файл для хранения вектора инициализации

static BYTE* pbIV = NULL;               // Вектор инициализации сессионного ключа
static BYTE* passwordHash;

static DWORD passwordHashLen = 0;
static DWORD dwLength = (DWORD)strlen(password);

int main(void)
{
    BYTE pbContent[BLOCK_LENGTH];       // Указатель на содержимое исходного файла
    DWORD cbContent = 0;        // Длина содержимого
    DWORD dwIV = 0;             // Длина вектора инициализации
    DWORD bufLen = sizeof(pbContent);   // Длина буфера

    // Открытие файла, который будет зашифрован.
    //if(!fopen_s(&source, "source.txt", "r+b" ))
    if (fopen_s(&source, "song.txt", "rb"))
        HandleError("Problem opening the file 'source.txt'\n");
    printf("--- The file 'source.txt' was opened\n");

    // Открытие файла, в который будет производится запись зашифрованного файла.
    if (fopen_s(&Encrypt, "encrypt.bin", "wb"))
        HandleError("Problem opening the file 'encrypt.bin'\n");
    printf("--- The file 'encrypt.bin' was opened\n");

    // Открытие файла, в который будет производится запись хэша ключа.
    if (fopen_s(&pass, "pass.bin", "wb"))
        HandleError("Problem opening the file 'pass.bin'\n");
    printf("--- The file 'encrypt.bin' was opened\n");

    // Открытие файла, в который производится запись вектора инициализации.
    //if (fopen_s(&vectorf, "vector.bin", "wb"))
    //    HandleError("Problem opening the file 'vector.bin'\n");
    //printf("--- The file 'vector.bin' was opened\n");

    if (CryptAcquireContext(&hProv, NULL, pszProvider, dwProvType, CRYPT_VERIFYCONTEXT))
    {
        std::wcout << "--- The provider (" << pszProvider << ") has been acquired. \n";
        //----------------------------------------------------------------
        // Create an empty hash object.
        if (CryptCreateHash(hProv, hashAlgid, 0, 0, &hHash))
        {
            printf("--- An empty hash object has been created. \n");
        }
        else
        {
            HandleError("Error during CryptCreateHash.");
        }
        //----------------------------------------------------------------
        // Hash the password string.
        if (CryptHashData(hHash, (BYTE*)password, dwLength, 0))
        {
            printf("--- The password has been hashed. \n");
        }
        else
        {
            HandleError("Error during CryptHashData.");
        }
        //----------------------------------------------------------------
        // Create a session key based on the hash of the password.
        if (CryptDeriveKey(hProv, encryptAlgid, hHash, CRYPT_EXPORTABLE, &hKey))
        {
            printf("--- The key has been derived. \n");
        }
        else
        {
            HandleError("Error during CryptDeriveKey.");
        }
        //----------------------------------------------------------------
    }
    else {
        HandleError("Error during CryptAcquireContext.");
    }


    // Определение размера вектора инициализации сессионного ключа. 
    //if (CryptGetKeyParam(hKey, KP_IV, NULL, &dwIV, 0))
    //{
    //    printf("--- Size of the IV for the session key determined. \n");
    //}
    //else
    //{
    //    HandleError("Error computing IV length.");
    //}

    //pbIV = (BYTE*)malloc(dwIV);
    //if (!pbIV)
    //    HandleError("Out of memory. \n");

    // Определение вектора инициализации сессионного ключа.
    //if (CryptGetKeyParam(hKey, KP_IV, pbIV, &dwIV, 0))
    //{
    //    printf("--- CryptGetKeyParam succeeded. \n");
    //}
    //else
    //{
    //    HandleError("Error during CryptGetKeyParam.");
    //}


    //--------------------------------------------------------------------
    // Запись вектора инициализации в файл.

    //if (fwrite(pbIV, 1, dwIV, vectorf))
    //{
    //    printf("--- The IV was written to the 'vector.bin'\n");
    //}
    //else
    //{
    //    HandleError("The IV can not be written to the 'vector.bin'\n");
    //}

    //--------------------------------------------------------------------
    // Запись хэшированного пароля в файл.

    CryptGetHashParam(hHash, HP_HASHVAL, NULL, &passwordHashLen, 0);
    passwordHash = (BYTE*)malloc(passwordHashLen);
    CryptGetHashParam(hHash, HP_HASHVAL, passwordHash, &passwordHashLen, 0);

    if (fwrite(passwordHash, sizeof(BYTE), passwordHashLen, pass))
    {
        printf("--- The hash of key was written to the 'pass.bin'\n");
    }
    else
    {
        HandleError("The hash of key can not be written to the 'pass.bin'\n");
    }

    //--------------------------------------------------------------------
    // Чтение  файла, который будет зашифрован блоками по 4 КБ (BLOCK_LENGTH). 
    // Зашифрование прочитанного блока и запись его в файл "encrypt.bin".
    //--------------------------------------------------------------------

    do
    {
        cbContent = (DWORD)fread(pbContent, 1, BLOCK_LENGTH, source);
        if (cbContent)
        {
            BOOL bFinal = feof(source);
            // Зашифрование прочитанного блока на сессионном ключе.
            if (CryptEncrypt(hKey, 0, bFinal, 0, pbContent, &cbContent, bufLen))
            {
                printf("--- Encryption succeeded. \n");
                // Запись зашифрованного блока в файл.
                if (fwrite(pbContent, 1, cbContent, Encrypt))
                {
                    printf("--- The encrypted content was written to the 'encrypt.bin'\n");
                }
                else
                {
                    HandleError("The encrypted content can not be written to the 'encrypt.bin'\n");
                }
            }
            else
            {
                HandleError("Encryption failed.");
            }
        }
        else
        {
            HandleError("Problem reading the file 'source.txt'\n");
        }
    }     while (!feof(source));


    CleanUp();
    std::cout << "\n\n";


    // Открытие файла, из которого будет читаться шифртекст.
    if (fopen_s(&Encrypt, "encrypt.bin", "rb"))
        HandleError("Problem opening the file 'encrypt.bin'\n");
    printf("--- The file 'encrypt.bin' was opened\n");

    // Открытие файла, из которого будет читаться хэш пароля.
    if (fopen_s(&pass, "pass.bin", "rb"))
        HandleError("Problem opening the file 'pass.bin'\n");
    printf("--- The file 'pass.bin' was opened\n");

    // Открытие файла, в который будет записыватся зашифрованный текст.
    if (fopen_s(&Decrypt, "decrypt.txt", "w"))
        HandleError("Problem opening the file 'decrypt.txt'\n");
    printf("--- The file 'decrypt.txt' was opened\n");

    if (CryptAcquireContext(&hProv, NULL, pszProvider, dwProvType, CRYPT_VERIFYCONTEXT))
    {
        std::wcout << "--- The provider (" << pszProvider << ") has been acquired. \n";
        //----------------------------------------------------------------
        // Create an empty hash object.
        if (CryptCreateHash(hProv, hashAlgid, 0, 0, &hHash))
        {
            printf("--- An empty hash object has been created. \n");
        }
        else
        {
            HandleError("Error during CryptCreateHash.");
        }
        //----------------------------------------------------------------
        // Hash the password string.
        if (CryptHashData(hHash, (BYTE*)password, dwLength, 0))
        {
            printf("--- The password has been hashed. \n");
        }
        else
        {
            HandleError("Error during CryptHashData.");
        }
        //----------------------------------------------------------------
        // Create a session key based on the hash of the password.
        if (CryptDeriveKey(hProv, encryptAlgid, hHash, CRYPT_EXPORTABLE, &hKey))
        {
            printf("--- The key has been derived. \n");
        }
        else
        {
            HandleError("Error during CryptDeriveKey.");
        }
        //----------------------------------------------------------------
    }
    else {
        HandleError("Error during CryptAcquireContext.");
    }

    //fseek(pass, 0L, SEEK_END);
    //passwordHashLen = ftell(pass);
    //fseek(pass, 0L, SEEK_SET);
    //passwordHash = (BYTE*)malloc(passwordHashLen);
    //while (feof(pass) == 0)
    //{
    //    fread(passwordHash, 1, passwordHashLen, pass);
    //    if (!ferror(pass) == 0) {
    //        HandleError("Problem reading the file 'pass.bin'\n");
    //        break;
    //    }
    //}

    do
    {
        cbContent = (DWORD)fread(pbContent, 1, BLOCK_LENGTH, Encrypt);
        if (cbContent)
        {
            BOOL bFinal = feof(Encrypt);
            // Расшифрование прочитанного блока ключом.
            if (CryptDecrypt(hKey, 0, bFinal, 0, pbContent, &cbContent))
            {
                printf("--- Decryption succeeded. \n");
                // Запись расшифрованного блока в файл.
                if (fwrite(pbContent, 1, cbContent, Decrypt))
                {
                    printf("--- The decrypted content was written to the 'decrypt.txt'\n");
                }
                else
                {
                    HandleError("The decrypted content can not be written to the 'decrypt.txt'\n");
                }
            }
            else
            {
                HandleError("Decryption failed.");
            }
        }
        else
        {
            HandleError("Problem reading the file 'encrypt.bin'\n");
        }
    } while (!feof(Encrypt));

    CleanUp();
    printf("The program ran to completion without error. \n");
    return 0;
}

void CleanUp(void)
{
    if (source)
        fclose(source);
    if (Encrypt)
        fclose(Encrypt);
    if (Decrypt)
        fclose(Decrypt);
    if (pass)
        fclose(pass);
    //if (vectorf)
    //    fclose(vectorf);

    // Уничтожение дескриптора закрытого ключа.
    if (hKey)
        CryptDestroyKey(hKey);

    // Освобождение дескриптора провайдера.
    if (hProv)
        CryptReleaseContext(hProv, 0);
}

void HandleError(const char* error) {
    std::cout << error << '\n';
    CleanUp();
    exit(0);
}