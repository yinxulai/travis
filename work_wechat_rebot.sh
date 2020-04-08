#!/bin/bash

checkKey() {
  if [ -z $WORK_WECHAT_ROBOT_KEY ]; then
    echo 'WORK_WECHAT_ROBOT_KEY is nil'
    exit 1
  fi
}

pushNotice() {
  CURL_BODY=$1
  CURL_HEAD='Content-Type:application/json'
  CURL_URL='https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key='$WORK_WECHAT_ROBOT_KEY
  echo "curl $CURL_URL -H $CURL_HEAD -d $CURL_BODY"
  CURL_RESULT=`curl $CURL_URL -H $CURL_HEAD -d $CURL_BODY`

  # TODO: 重试、通知
  echo $CURL_RESULT
}

checkKey
pushNotice '{"msgtype":"markdown","markdown":{"content":"test"}}'
