@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
title  IT YONETIM SISTEMI V3.0
color 0A

:: ============================================================
::  PC BILGI VE YONETIM SISTEMI V3.0
::  Guncelleme: Cift Sutun Menu, Guc Yonetimi, Envanter, Mesaj
:: ============================================================

:: -----------------------------
:: Global vars
set "TARGET_INPUT="
set "TARGET_IP="
set "AUTH_USER="
set "AUTH_PASS="
set "REPORT_MODE=0"

:: UI helpers
set "LINE=--------------------------------------------------------------------------------"
set "TITLE_1=YUNUS İNAN TARAFINDAN GELİŞTİRİLMİŞTİR"
set "TITLE_2=PC BİLGİ VE YÖNETİM SİSTEMİ V3.0"

:MENU
cls
call :HEADER

echo.
echo   BILGI TOPLAMA (IZLEME)                     MUDAHALE VE ANALIZ (AKSIYON)
echo   ----------------------------------------   ----------------------------------------
echo   [1]  IP + MAC (Ping/Arp/Getmac)            [11] Paylasim Klasorleri
echo   [2]  BIOS Seri Numarasi                    [12] Event Log (Son 20 Hata)
echo   [3]  Disk Bilgileri (Size/Free)            [13] CPU ve RAM Kullanimi
echo   [4]  OS Bilgisi (Ver/Build/Date)           [14] Process Listesi (Gorev Ynt.)
echo   [5]  Uptime (Acilis Zamani)                [15] Servis Yonetimi (Start/Stop)
echo   [6]  Aktif Kullanici + PC Ozeti            [16] OTOMATIK RAPOR (Txt Kaydet)
echo   [7]  Son 20 Hotfix (Guncelleme)            [17] Yuklu Yazilimlar (Envanter)
echo   [8]  Servis Durumu (Sorgula)               [18] Yerel Kullanicilari Listele
echo   [9]  Hizli Ozet (Ekrana Basar)             [19] Personele Mesaj Gonder (Popup)
echo   [10] Port Kontrol (Telnet Test)            [20] GUC: Yeniden Baslat / Kapat
echo.
echo   --------------------------------------------------------------------------------
echo   [P] PC Degistir / Hedef Sec      [C] Kimlik Ayarla      [0] Cikis
echo.

set "SECIM="
set /p SECIM="Komut Numarasi Giriniz: "

if "%SECIM%"=="0" goto EXIT
if /i "%SECIM%"=="P" goto CHANGE_PC
if /i "%SECIM%"=="C" goto CREDS

:: Sol Sutun
if "%SECIM%"=="1" goto IP_MAC
if "%SECIM%"=="2" goto BIOS_SERIAL
if "%SECIM%"=="3" goto DISKINFO
if "%SECIM%"=="4" goto OSINFO
if "%SECIM%"=="5" goto UPTIME
if "%SECIM%"=="6" goto SUMMARY
if "%SECIM%"=="7" goto HOTFIX
if "%SECIM%"=="8" goto SERVICE_CHECK
if "%SECIM%"=="9" goto QUICK_REPORT_SCREEN
if "%SECIM%"=="10" goto PORT_CHECK

:: Sag Sutun
if "%SECIM%"=="11" goto SHARE_CHECK
if "%SECIM%"=="12" goto EVENT_LOG
if "%SECIM%"=="13" goto CPU_RAM
if "%SECIM%"=="14" goto PROCESS_LIST
if "%SECIM%"=="15" goto SERVICE_CONTROL
if "%SECIM%"=="16" goto AUTO_REPORT
if "%SECIM%"=="17" goto SOFT_LIST
if "%SECIM%"=="18" goto USER_LIST
if "%SECIM%"=="19" goto MSG_SEND
if "%SECIM%"=="20" goto POWER_OP

goto MENU

:: ------------------------------------------------------------
:HEADER
echo %LINE%
echo  %TITLE_1%
echo  %TITLE_2%
echo %LINE%
if defined TARGET_IP (
  echo  HEDEF: %TARGET_INPUT%  [ IP: %TARGET_IP% ]
) else (
  echo  HEDEF: (Secilmedi - Lutfen [P] ile secin)
)
if defined AUTH_USER (
  echo  YETKI: %AUTH_USER%
) else (
  echo  YETKI: (Standart Yerel Oturum)
)
echo %LINE%
goto :eof

:: ------------------------------------------------------------
:CHANGE_PC
cls
call :HEADER
call :ASK_TARGET
goto MENU

:: ------------------------------------------------------------
:CREDS
cls
echo %LINE%
echo                 KIMLIK BILGISI (Opsiyonel)
echo %LINE%
echo.
echo Mevcut:
if defined AUTH_USER (
  echo   User: %AUTH_USER%
) else (
  echo   (TANIMLI DEGIL)
)
echo.
echo [1] Kullanici/Parola Gir (Admin yetkisi gerektiren isler icin)
echo [2] Temizle
echo [0] Iptal
echo.
set "C_SEC="
set /p C_SEC="Secim: "

if "%C_SEC%"=="0" goto MENU
if "%C_SEC%"=="2" (
  set "AUTH_USER="
  set "AUTH_PASS="
  goto MENU
)
if "%C_SEC%"=="1" (
  echo.
  set "AUTH_USER="
  set "AUTH_PASS="
  set /p AUTH_USER="Kullanici (orn: DOMAIN\User): "
  set /p AUTH_PASS="Parola: "
  goto MENU
)
goto MENU

:: ------------------------------------------------------------
:ASK_TARGET
echo.
set "TARGET_INPUT="
set "TARGET_IP="
set /p TARGET_INPUT="PC Adi veya IP girin: "
if not defined TARGET_INPUT goto :eof

call :RESOLVE_TARGET "%TARGET_INPUT%"

if not defined TARGET_IP (
  echo.
  echo [HATA] Hedef bulunamadi.
  echo.
  pause
) else (
  echo.
  echo [OK] Hedef IP: %TARGET_IP%
  timeout /t 1 >nul
)
goto :eof

:: ------------------------------------------------------------
:RESOLVE_TARGET
set "IN=%~1"
set "TARGET_IP="
echo(%IN%| findstr /r "^[0-9][0-9]*\.[0-9]" >nul
if %errorlevel%==0 (
  set "TARGET_IP=%IN%"
  goto :eof
)
for /f "tokens=2 delims=[]" %%A in ('ping -4 -n 1 "%IN%" ^| findstr /i "Pinging"') do (
  set "TARGET_IP=%%A"
)
if defined TARGET_IP goto :eof
nbtstat -a "%IN%" >nul 2>&1
if %errorlevel%==0 (
  for /f "tokens=2 delims=[]" %%A in ('ping -4 -n 1 "%IN%" ^| findstr /i "Pinging"') do (
    set "TARGET_IP=%%A"
  )
)
if defined TARGET_IP goto :eof
for /f "tokens=2 delims=: " %%A in ('nslookup "%IN%" 2^>nul ^| findstr /i "Address"') do (
  if not "%%A"=="" set "TARGET_IP=%%A"
)
goto :eof

:: ------------------------------------------------------------
:AUTH_WMIC
set "CMD=%~1"
if defined AUTH_USER (
  %CMD% /user:"%AUTH_USER%" /password:"%AUTH_PASS%"
) else (
  %CMD%
)
goto :eof

:AUTH_GETMAC
if defined AUTH_USER (
  getmac /s "%~1" /u "%AUTH_USER%" /p "%AUTH_PASS%" /fo table /v
) else (
  getmac /s "%~1" /fo table /v
)
goto :eof

:: ------------------------------------------------------------
:NEED_TARGET
if not defined TARGET_IP call :ASK_TARGET
if not defined TARGET_IP goto MENU
goto :eof

:WAIT_IF_NOT_REPORT
if "%REPORT_MODE%"=="0" pause
goto :eof

:: ============================================================
::                FONKSIYONLAR (SOL SUTUN)
:: ============================================================

:IP_MAC
if "%REPORT_MODE%"=="0" cls
if "%REPORT_MODE%"=="0" call :NEED_TARGET
if not defined TARGET_IP goto MENU
echo.
echo [1] IP ve MAC ADRESI
echo --------------------
ping -n 1 "%TARGET_IP%" >nul
arp -a "%TARGET_IP%"
echo.
call :AUTH_GETMAC "%TARGET_IP%"
echo.
call :WAIT_IF_NOT_REPORT
if "%REPORT_MODE%"=="0" goto MENU
goto :eof

:BIOS_SERIAL
if "%REPORT_MODE%"=="0" cls
if "%REPORT_MODE%"=="0" call :NEED_TARGET
if not defined TARGET_IP goto MENU
echo.
echo [2] BIOS SERI NO
echo ----------------
call :AUTH_WMIC "wmic /node:%TARGET_IP% bios get serialnumber"
echo.
call :WAIT_IF_NOT_REPORT
if "%REPORT_MODE%"=="0" goto MENU
goto :eof

:DISKINFO
if "%REPORT_MODE%"=="0" cls
if "%REPORT_MODE%"=="0" call :NEED_TARGET
if not defined TARGET_IP goto MENU
echo.
echo [3] DISK BILGILERI
echo ------------------
call :AUTH_WMIC "wmic /node:%TARGET_IP% diskdrive get model,size"
call :AUTH_WMIC "wmic /node:%TARGET_IP% logicaldisk where drivetype=3 get name,freespace,size /format:table"
echo.
call :WAIT_IF_NOT_REPORT
if "%REPORT_MODE%"=="0" goto MENU
goto :eof

:OSINFO
if "%REPORT_MODE%"=="0" cls
if "%REPORT_MODE%"=="0" call :NEED_TARGET
if not defined TARGET_IP goto MENU
echo.
echo [4] ISLETIM SISTEMI
echo -------------------
call :AUTH_WMIC "wmic /node:%TARGET_IP% os get Caption,Version,BuildNumber,InstallDate,OSArchitecture /format:table"
echo.
call :WAIT_IF_NOT_REPORT
if "%REPORT_MODE%"=="0" goto MENU
goto :eof

:UPTIME
if "%REPORT_MODE%"=="0" cls
if "%REPORT_MODE%"=="0" call :NEED_TARGET
if not defined TARGET_IP goto MENU
echo.
echo [5] UPTIME (SON ACILIS)
echo -----------------------
call :AUTH_WMIC "wmic /node:%TARGET_IP% os get LastBootUpTime /value"
echo.
call :WAIT_IF_NOT_REPORT
if "%REPORT_MODE%"=="0" goto MENU
goto :eof

:SUMMARY
if "%REPORT_MODE%"=="0" cls
if "%REPORT_MODE%"=="0" call :NEED_TARGET
if not defined TARGET_IP goto MENU
echo.
echo [6] KULLANICI VE SISTEM OZETI
echo -----------------------------
call :AUTH_WMIC "wmic /node:%TARGET_IP% computersystem get username,model,manufacturer,totalphysicalmemory /format:table"
echo.
call :WAIT_IF_NOT_REPORT
if "%REPORT_MODE%"=="0" goto MENU
goto :eof

:HOTFIX
if "%REPORT_MODE%"=="0" cls
if "%REPORT_MODE%"=="0" call :NEED_TARGET
if not defined TARGET_IP goto MENU
echo.
echo [7] HOTFIX (GUNCELLEMELER)
echo --------------------------
call :AUTH_WMIC "wmic /node:%TARGET_IP% qfe get HotFixID,InstalledOn,Description /format:table"
echo.
call :WAIT_IF_NOT_REPORT
if "%REPORT_MODE%"=="0" goto MENU
goto :eof

:SERVICE_CHECK
if "%REPORT_MODE%"=="0" cls
if "%REPORT_MODE%"=="0" call :NEED_TARGET
if not defined TARGET_IP goto MENU
echo.
echo [8] SERVIS SORGULA
echo ------------------
if "%REPORT_MODE%"=="1" goto :eof
set "SVC="
set /p SVC="Servis adi (orn: Spooler, WinRM): "
if not defined SVC goto MENU
sc \\%TARGET_IP% query "%SVC%"
echo.
pause
goto MENU

:QUICK_REPORT_SCREEN
cls
call :NEED_TARGET
echo.
echo *** HIZLI EKRAN RAPORU ***
echo.
set "REPORT_MODE=1"
call :IP_MAC
call :BIOS_SERIAL
call :DISKINFO
call :OSINFO
call :UPTIME
call :SUMMARY
call :HOTFIX
set "REPORT_MODE=0"
echo.
pause
goto MENU

:PORT_CHECK
cls
call :NEED_TARGET
echo.
echo [10] PORT KONTROL
echo -----------------
set "P_PORT="
set /p P_PORT="Port No (orn: 3389 RDP, 445 SMB): "
if not defined P_PORT goto MENU
echo.
echo PowerShell ile test ediliyor...
powershell -Command "try { $t = New-Object Net.Sockets.TcpClient; $t.Connect('%TARGET_IP%', %P_PORT%); Write-Host '>> PORT %P_PORT% ACIK (BASARILI)' -ForegroundColor Green } catch { Write-Host '>> PORT %P_PORT% KAPALI veya ULASILAMIYOR' -ForegroundColor Red }"
echo.
pause
goto MENU

:: ============================================================
::                FONKSIYONLAR (SAG SUTUN - AKSIYON)
:: ============================================================

:SHARE_CHECK
if "%REPORT_MODE%"=="0" cls
if "%REPORT_MODE%"=="0" call :NEED_TARGET
if not defined TARGET_IP goto MENU
echo.
echo [11] PAYLASIM KLASORLERI
echo ------------------------
net view \\%TARGET_IP%
echo.
call :WAIT_IF_NOT_REPORT
if "%REPORT_MODE%"=="0" goto MENU
goto :eof

:EVENT_LOG
if "%REPORT_MODE%"=="0" cls
if "%REPORT_MODE%"=="0" call :NEED_TARGET
if not defined TARGET_IP goto MENU
echo.
echo [12] EVENT LOG (Son 20 Hata/Uyari)
echo ----------------------------------
call :AUTH_WMIC "wmic /node:%TARGET_IP% ntevent where ^(Logfile='System' and ^(EventType=1 or EventType=2)^) get TimeGenerated,SourceName,Message /format:table" | more
echo.
call :WAIT_IF_NOT_REPORT
if "%REPORT_MODE%"=="0" goto MENU
goto :eof

:CPU_RAM
if "%REPORT_MODE%"=="0" cls
if "%REPORT_MODE%"=="0" call :NEED_TARGET
if not defined TARGET_IP goto MENU
echo.
echo [13] CPU ve RAM
echo ---------------
call :AUTH_WMIC "wmic /node:%TARGET_IP% cpu get LoadPercentage /value"
call :AUTH_WMIC "wmic /node:%TARGET_IP% os get FreePhysicalMemory,TotalVisibleMemorySize /format:table"
echo.
call :WAIT_IF_NOT_REPORT
if "%REPORT_MODE%"=="0" goto MENU
goto :eof

:PROCESS_LIST
if "%REPORT_MODE%"=="0" cls
if "%REPORT_MODE%"=="0" call :NEED_TARGET
if not defined TARGET_IP goto MENU
echo.
echo [14] PROCESS LISTESI
echo --------------------
if defined AUTH_USER (
    tasklist /s %TARGET_IP% /u %AUTH_USER% /p %AUTH_PASS%
) else (
    tasklist /s %TARGET_IP%
)
echo.
call :WAIT_IF_NOT_REPORT
if "%REPORT_MODE%"=="0" goto MENU
goto :eof

:SERVICE_CONTROL
cls
call :NEED_TARGET
echo.
echo [15] SERVIS YONETIMI
echo --------------------
echo [1] BASLAT (Start)
echo [2] DURDUR (Stop)
echo [0] Iptal
set /p S_ACT="Secim: "
if "%S_ACT%"=="0" goto MENU
set /p S_NAME="Servis Adi (orn: Spooler): "
if not defined S_NAME goto MENU
if "%S_ACT%"=="1" sc \\%TARGET_IP% start "%S_NAME%"
if "%S_ACT%"=="2" sc \\%TARGET_IP% stop "%S_NAME%"
echo Islem gonderildi.
pause
goto MENU

:SOFT_LIST
if "%REPORT_MODE%"=="0" cls
if "%REPORT_MODE%"=="0" call :NEED_TARGET
if not defined TARGET_IP goto MENU
echo.
echo [17] YUKLU YAZILIM ENVANTERI
echo ----------------------------
echo DIKKAT: Bu islem sistemdeki yuklu programa gore zaman alabilir. Bekleyin...
call :AUTH_WMIC "wmic /node:%TARGET_IP% product get name,version"
echo.
call :WAIT_IF_NOT_REPORT
if "%REPORT_MODE%"=="0" goto MENU
goto :eof

:USER_LIST
if "%REPORT_MODE%"=="0" cls
if "%REPORT_MODE%"=="0" call :NEED_TARGET
if not defined TARGET_IP goto MENU
echo.
echo [18] YEREL KULLANICI LISTESI
echo ----------------------------
call :AUTH_WMIC "wmic /node:%TARGET_IP% useraccount list brief"
echo.
call :WAIT_IF_NOT_REPORT
if "%REPORT_MODE%"=="0" goto MENU
goto :eof

:MSG_SEND
cls
call :NEED_TARGET
echo.
echo [19] PERSONELE MESAJ GONDER
echo ---------------------------
echo Not: Windows Pro/Enterprise surumlerinde calisir. Home surumunde calismaz.
echo.
set "MSG_TEXT="
set /p MSG_TEXT="Gonderilecek Mesaj: "
if not defined MSG_TEXT goto MENU
echo.
echo Gonderiliyor...
msg * /server:%TARGET_IP% /time:30 "%MSG_TEXT%"
if %errorlevel%==0 ( echo BASARILI ) else ( echo HATA: Iletilemedi. )
echo.
pause
goto MENU

:POWER_OP
cls
call :NEED_TARGET
echo.
echo [20] GUC YONETIMI - TEHLIKELI BOLGE
echo -----------------------------------
echo Hedef: %TARGET_IP%
echo.
echo [1] YENIDEN BASLAT (Restart)
echo [2] KAPAT (Shutdown)
echo [0] IPTAL
echo.
set "P_ACT="
set /p P_ACT="Karariniz: "

if "%P_ACT%"=="0" goto MENU
if "%P_ACT%"=="1" (
    echo.
    echo %TARGET_IP% YENIDEN BASLATILIYOR...
    shutdown /m \\%TARGET_IP% /r /f /t 0
    goto MENU
)
if "%P_ACT%"=="2" (
    echo.
    echo %TARGET_IP% KAPATILIYOR...
    shutdown /m \\%TARGET_IP% /s /f /t 0
    goto MENU
)
goto MENU

:AUTO_REPORT
cls
call :NEED_TARGET
set "R_DATE=%date:~-4%-%date:~3,2%-%date:~0,2%"
set "R_TIME=%time:~0,2%-%time:~3,2%"
set "R_TIME=%R_TIME: =0%"
set "FOLDER=RAPORLAR"
set "FILENAME=%FOLDER%\Rapor_%TARGET_IP%_%R_DATE%_%R_TIME%.txt"
if not exist "%FOLDER%" mkdir "%FOLDER%"

echo.
echo ==================================================
echo   OTOMATIK RAPOR OLUSTURULUYOR...
echo   Lutfen bekleyin. Yazilim listesi biraz surebilir.
echo ==================================================

set "REPORT_MODE=1"
(
    echo RAPOR TARIHI: %date% %time%
    echo HEDEF SISTEM: %TARGET_INPUT% - %TARGET_IP%
    echo OLUSTURAN: %TITLE_1%
    echo BOLUM: %TITLE_2%
    echo ==================================================
    call :IP_MAC
    echo --------------------------------------------------
    call :BIOS_SERIAL
    echo --------------------------------------------------
    call :DISKINFO
    echo --------------------------------------------------
    call :OSINFO
    echo --------------------------------------------------
    call :UPTIME
    echo --------------------------------------------------
    call :SUMMARY
    echo --------------------------------------------------
    call :HOTFIX
    echo --------------------------------------------------
    call :SHARE_CHECK
    echo --------------------------------------------------
    call :CPU_RAM
    echo --------------------------------------------------
    echo [SON HATA LOGLARI]
    call :AUTH_WMIC "wmic /node:%TARGET_IP% ntevent where ^(Logfile='System' and EventType=1^) get TimeGenerated,SourceName,Message /format:table"
    echo --------------------------------------------------
    echo [YEREL KULLANICILAR]
    call :AUTH_WMIC "wmic /node:%TARGET_IP% useraccount list brief"
    echo --------------------------------------------------
    echo [YUKLU YAZILIMLAR]
    call :AUTH_WMIC "wmic /node:%TARGET_IP% product get name,version"
    echo --------------------------------------------------
    echo RAPOR SONU
) > "%FILENAME%"

set "REPORT_MODE=0"
echo.
echo [OK] Rapor Kaydedildi:
echo %CD%\%FILENAME%
echo.
pause
goto MENU

:EXIT
echo Cikis yapiliyor...
timeout /t 1 >nul
exit