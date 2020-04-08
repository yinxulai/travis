#!/bin/bash

# 检查 key
checkKey() {
  if [ -z $WORK_WECHAT_ROBOT_KEY ]; then
    echo 'WORK_WECHAT_ROBOT_KEY is nil'
    exit 1
  fi
}

# 推送消息
# @params $! message body
pushNotice() {
  CURL_BODY=$1
  CURL_HEAD='Content-Type:application/json'
  CURL_URL='https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key='$WORK_WECHAT_ROBOT_KEY
  echo "curl $CURL_URL -H $CURL_HEAD -d $CURL_BODY"
  CURL_RESULT=`curl $CURL_URL -H $CURL_HEAD -d $CURL_BODY`

  # TODO: 重试、通知
  echo $CURL_RESULT
}

# 生成消息
generateMessage() {
  MESSAGE_FILE=`mktemp`
  # 头
  echo "{"                            >> $MESSAGE_FILE
  echo '"msgtype":"markdown",'        >> $MESSAGE_FILE
  echo '  "markdown":{'               >> $MESSAGE_FILE
  echo '    "content":'               >> $MESSAGE_FILE
  echo '"'                              >> $MESSAGE_FILE

  echo '##### 公共依赖库变更：'           >> $MESSAGE_FILE
  echo "> $TRAVIS_COMMIT_MESSAGE"       >> $MESSAGE_FILE

  echo '"'                              >> $MESSAGE_FILE
  echo " }"                           >> $MESSAGE_FILE
  echo "}"                            >> $MESSAGE_FILE

  # TODO: 仅仅只允许 4096 个字节 utf8
  # https://work.weixin.qq.com/help?person_id=1&doc_id=13376

  # 使用 echo 向外输出结果
  echo @$MESSAGE_FILE
}

checkKey
pushNotice `generateMessage`
