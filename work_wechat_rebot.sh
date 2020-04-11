#!/bin/bash

# 遇到异常主动推出
-ex


# 时间类型
EVENT_TYPE=$TRAVIS_EVENT_TYPE
# commit 信息
COMMIT_MESSAGE=$TRAVIS_COMMIT_MESSAGE
# 机器人 key
WORK_WECHAT_ROBOT_KEY=$WORK_WECHAT_ROBOT_KEY


# 检查 key
checkKey() {
  if [ -z $WORK_WECHAT_ROBOT_KEY ]; then
    echo 'WORK_WECHAT_ROBOT_KEY is nil'
    exit 1
  fi
}


# 是否推送
isPush() {
  MATCH_STRING='[x] 通知前端工作群'
  if [[ $COMMIT_MESSAGE == *$MATCH_STRING* ]]; then 
    return true
  fi

  return false
}

# 是否艾特所有人
isAtAll() {
  MATCH_STRING='[x] @前端工作群所有人'
  if [[ $COMMIT_MESSAGE == *$MATCH_STRING* ]]; then 
    return true
  fi

  return false
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
   MESSAGE_FILE=`mktemp`
  MESSAGE_FILE='senddata'
  MESSAGE_TITLE='公共依赖库变更：'

  # 清空
  echo '' > $MESSAGE_FILE

  # 写入头
  echo "{"                                          >> $MESSAGE_FILE
  echo '"msgtype":"markdown",'                      >> $MESSAGE_FILE
  echo '  "markdown":{'                             >> $MESSAGE_FILE
  echo '    "content":'                             >> $MESSAGE_FILE

  # 标题 & 正文
  echo  '"#### '$MESSAGE_TITLE'\\n'                  >> $MESSAGE_FILE
  # 仅仅只允许 4096 个字节 utf8, 这里简单处理一下
  # 就当全是汉字（2个字节），最多 2000 个字，4000 字节
  # https://work.weixin.qq.com/help?person_id=1&doc_id=13376
  echo  '> '${TRAVIS_COMMIT_MESSAGE:0:2000}...'\\n"' >> $MESSAGE_FILE

    # 艾特所有人
  if [ isAtAll ]; then
      echo ','                                     >> $MESSAGE_FILE
      echo '"mentioned_list":["@all"]'             >> $MESSAGE_FILE
  fi 

  # 写入尾
  echo " }"                                        >> $MESSAGE_FILE
  echo "}"                                         >> $MESSAGE_FILE


  # 使用 echo 向外输出结果
  echo @$MESSAGE_FILE
}

if [ isPush ]; then 
  checkKey
  if [ isPush ]; then
      pushNotice `generateMessage`
  fi
fi
