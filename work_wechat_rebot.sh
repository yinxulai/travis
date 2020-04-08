#!/bin/bash

WORK_WECHAT_ROBOT_KEY='ae930e31-7693-47ee-a139-774fd5b9e468'

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

  echo 'TRAVIS_EVENT_TYPE':$TRAVIS_EVENT_TYPE
  echo 'TRAVIS_COMMIT_MESSAGE:'$TRAVIS_COMMIT_MESSAGE
  echo '\n'

# 生成消息
generateMessage() {
  MESSAGE_CONTENT='dasdsadassd\\n>\\ndadada\\ndadas\\ndasdas'
  MESSAGE_TEMPLATE='{"msgtype":"markdown","markdown":{"content":"'$MESSAGE_CONTENT'"}}'

  # 使用 echo 向外输出结果
  echo $MESSAGE_TEMPLATE
}

# checkKey
pushNotice `generateMessage`
