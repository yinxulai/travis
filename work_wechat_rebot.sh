#!/bin/bash
# set -u

# env
# TRAVIS_EVENT_TYPE='pull_request'
# TRAVIS_REPO_SLUG='test/test'
# WORK_WECHAT_ROBOT_KEY='ae930e31-7693-47ee-a139-774fd5b9e468'
# TRAVIS_COMMIT_MESSAGE='aa31233213 [x] 通知前端工作群 xxxxxx [x] @前端工作群所有人'

# 仓库信息
REPO_SLUG=$TRAVIS_REPO_SLUG
# 事件类型
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
  return 0

  # 读不到 PR message
  MATCH_STRING='[x] 通知前端工作群'
  if [[ $COMMIT_MESSAGE == *"$MATCH_STRING"* ]]; then 
    return 0
  fi
  return 1
}

# 是否艾特所有人
isAtAll() {
  return 0
  
  # 读不到 PR message
  MATCH_STRING='[x] @前端工作群所有人'
  if [[ $COMMIT_MESSAGE == *"$MATCH_STRING"* ]]; then 
    return 0
  fi

  return 1
}

# 是否是 PR
isPushRequest() {
  if [ $EVENT_TYPE == 'pull_request' ]; then
    return 0
  fi

  return 1
}

# 推送消息
# @params $1 message body
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
  MESSAGE_TITLE='公共依赖库变更：'
  MESSAGE_CONTENT=`gitCommitMessage -1`
  GIT_REPOSITORIE_LINK=`gitRepositorieLink`

  # 清空
  echo '' > $MESSAGE_FILE

  # 写入头
  echo "{"                                          >> $MESSAGE_FILE
  echo '"msgtype":"markdown",'                      >> $MESSAGE_FILE
  echo '  "markdown":{'                             >> $MESSAGE_FILE
  echo '    "content":'                             >> $MESSAGE_FILE

  # 标题 & 正文
  echo '"#### '$MESSAGE_TITLE'\\n'                  >> $MESSAGE_FILE
  # 仅仅只允许 4096 个字节 utf8, 这里简单处理一下
  # 就当全是汉字（2个字节），最多 2000 个字，4000 字节
  # https://work.weixin.qq.com/help?person_id=1&doc_id=13376
  # echo '> '${MESSAGE_CONTENT:0:2000}...'\n'        >> $MESSAGE_FILE

  echo '> '$MESSAGE_CONTENT...'\n'                  >> $MESSAGE_FILE

  echo '[前去围观]('$GIT_REPOSITORIE_LINK')"'        >> $MESSAGE_FILE

    # 艾特所有人
  if isAtAll; then
      echo ','                                     >> $MESSAGE_FILE
      echo '"mentioned_list":["@all"]'             >> $MESSAGE_FILE
  fi 

  # 写入尾
  echo " }"                                        >> $MESSAGE_FILE
  echo "}"                                         >> $MESSAGE_FILE

  # 使用 echo 向外输出结果
  echo @$MESSAGE_FILE
}

# 获取 commit message
# medged 事件的最新一条 message 永远是 Merge pull request ID from **/**
gitCommitMessage() {
  INDEX=${1-"-1"}
  echo `git log --pretty=format:%s $INDEX`
}

# 仓库链接
gitRepositorieLink() {
  echo "https://github.com/$REPO_SLUG"
}

if isPush; then
  checkKey
  pushNotice `generateMessage`
fi
