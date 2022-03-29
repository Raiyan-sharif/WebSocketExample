#### PockeTalk SB iOS Labo:
Current Version 0.1.22
Last Updated 29 March 2022

Releases Names:
==============
1) AppStoreBJIT
- Log is opened
- LanguageEngineUrlForStageBuild set as LanguageEngineURL
- BJIT_IAP_ProductIDs, bjitAppSpecificSharedSecret is Used
- Bundle Identifier Used : com.sourcenext.pocketalk.ios.staging
- BASE_URL = https:\/\/test2.pt-v.com
- AUDIO_STREAM_BASE_URL = wss:\/\/test2.pt-v.com
- IMEI = 000001006154923
>>>>> Used in Development BJIT Engineers (Pocketalk-iOS-Labo Only)

2) AppStoreSN
- Log is opened
- LanguageEngineUrlForStageBuild set as LanguageEngineURL
- Bundle Identifier Used : com.sourcenext.pocketalk.ios.stg
- sNIAPProducts, snIAPSharedSecret is Used
- BASE_URL = https:\/\/test2.pt-v.com
- AUDIO_STREAM_BASE_URL = wss:\/\/test2.pt-v.com
- IMEI = 000001006154923
>>>>> Used for Uploading to TestFligh/Release Build by SN in SN Account
 
3) LoadEngineFromAsset
- Log is opened
- LanguageEngineUrlForStageBuild set as LanguageEngineURL
- Bundle Identifier Used : com.sourcenext.pocketalk.ios.staging
- BJIT_IAP_ProductIDs, bjitAppSpecificSharedSecret is Used
- BASE_URL = https:\/\/test2.pt-v.com
- AUDIO_STREAM_BASE_URL = wss:\/\/test2.pt-v.com
- IMEI = 000001006154923
>>>>> To Run Engine asset that loads from Projects Local Directory in BJIT Development Environment

4) Production
- Log is Closed
- LanguageEngineUrlForProductionBuild set as LanguageEngineURL
- productionIAPProduts, productionIAPSharedSecret is Used
- Bundle Identifier Used : com.pocketalk.ios.pt.translation
- BASE_URL = https:\/\/pt-v.com
- AUDIO_STREAM_BASE_URL = wss:\/\/pt-v.com
- IMEI = 000001006154923
>>>>> Used for Uploading to TestFligh/Release Build by Pocketalk (SN) in Pocketalk Appstore Account

5) ServerAPILog
- Log is opened
- LanguageEngineUrlForStageBuild set as LanguageEngineURL
- BJIT_IAP_ProductIDs, bjitAppSpecificSharedSecret is Used
- Bundle Identifier Used : com.sourcenext.pocketalk.ios.staging
- BASE_URL = https:\/\/test2.pt-v.com
- AUDIO_STREAM_BASE_URL = wss:\/\/test2.pt-v.com
- IMEI = 000001006154923
>>>>> Used for Quality Assurance Engineers for downloading log from Settings(Pocketalk-iOS-Labo Only)

6) Stage
- Log is opened
- LanguageEngineUrlForStageBuild set as LanguageEngineURL
- stagingIAPProduts, stagingIAPSharedSecret is Used
- Bundle Identifier Used : com.pocketalk.ios.pt.translation.stg
- BASE_URL = https:\/\/test2.pt-v.com
- AUDIO_STREAM_BASE_URL = wss:\/\/test2.pt-v.com
- IMEI = 000001006154923
>>>>> Used for TestFligh/Release in Stage Environment by Pocketalk (SN) in Pocketalk Appstore Account

7) ProductionWithStageURL
- Log is Closed
- LanguageEngineUrlForProductionBuild set as LanguageEngineURL
- productionIAPProduts, productionIAPSharedSecret is Used
- Bundle Identifier Used : com.pocketalk.ios.pt.translation
- BASE_URL = https:\/\/test2.pt-v.com
- AUDIO_STREAM_BASE_URL = wss:\/\/test2.pt-v.com
- IMEI = 000001006154923
>>>>> Used for Testing Production Build with Staging Base URL
