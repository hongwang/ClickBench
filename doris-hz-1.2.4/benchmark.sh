#!/bin/bash
set -ex

# This benchmark should run on Amazon Linux

# Install
ROOT=$(pwd)

# Create Database and table
mysql -h 127.0.0.1 -P9030 -uroot test <"$ROOT"/create.sql

gzip -d hits.tsv.gz

echo "start loading hits.tsv, estimated to take about 9 minutes ..."
date
START=$(date +%s)
curl --location-trusted \
    -u root: \
    -T "hits.tsv" \
    -H "label:hits" \
    -H "columns: WatchID,JavaEnable,Title,GoodEvent,EventTime,EventDate,CounterID,ClientIP,RegionID,UserID,CounterClass,OS,UserAgent,URL,Referer,IsRefresh,RefererCategoryID,RefererRegionID,URLCategoryID,URLRegionID,ResolutionWidth,ResolutionHeight,ResolutionDepth,FlashMajor,FlashMinor,FlashMinor2,NetMajor,NetMinor,UserAgentMajor,UserAgentMinor,CookieEnable,JavascriptEnable,IsMobile,MobilePhone,MobilePhoneModel,Params,IPNetworkID,TraficSourceID,SearchEngineID,SearchPhrase,AdvEngineID,IsArtifical,WindowClientWidth,WindowClientHeight,ClientTimeZone,ClientEventTime,SilverlightVersion1,SilverlightVersion2,SilverlightVersion3,SilverlightVersion4,PageCharset,CodeVersion,IsLink,IsDownload,IsNotBounce,FUniqID,OriginalURL,HID,IsOldCounter,IsEvent,IsParameter,DontCountHits,WithHash,HitColor,LocalEventTime,Age,Sex,Income,Interests,Robotness,RemoteIP,WindowName,OpenerName,HistoryLength,BrowserLanguage,BrowserCountry,SocialNetwork,SocialAction,HTTPError,SendTiming,DNSTiming,ConnectTiming,ResponseStartTiming,ResponseEndTiming,FetchTiming,SocialSourceNetworkID,SocialSourcePage,ParamPrice,ParamOrderID,ParamCurrency,ParamCurrencyID,OpenstatServiceName,OpenstatCampaignID,OpenstatAdID,OpenstatSourceID,UTMSource,UTMMedium,UTMCampaign,UTMContent,UTMTerm,FromTag,HasGCLID,RefererHash,URLHash,CLID" \
    http://127.0.0.1:8030/api/test/hits/_stream_load
END=$(date +%s)
LOADTIME=$(echo "$END - $START" | bc)
echo "Load data costs $LOADTIME seconds"
echo "$LOADTIME" >loadtime

# Dataset contains 99997497 rows, storage size is about 17319588503 bytes
mysql -h 127.0.0.1 -P9030 -uroot test -e "SELECT count(*) FROM hits"

# Run queries
./run.sh 2>&1 | tee -a run.log
date