#!/usr/bin/env bash

#
# 設定
#

# Tomcat のホームディレクトリ
tomcat_home=

# 依存サーバーのIP
# Tomcatが複数台あるような構成で、順番に起動した場合サーバごとに設定
depended_servers=()
#depended_servers=("www.yyy.zzz.xxx" "www.yyy.zzz.xxx" "www.yyy.zzz.xxx")

# 依存サーバ起動確認用URL
# サーバ側にTomcatが起動していればステータスコード200を返すものを用意しておく
# http://$depended_servers[n]:$depended_servers_check_port/$depended_servers_check_url のように組み立てられる
depended_servers_check_url=
depended_servers_check_port=8080

# 依存サーバ起動確認のインターバル
depended_servers_check_retry_interval=3

# プロセス終了確認のリトライ回数
process_check_retry_count=3
# プロセス終了確認のインターバル
process_check_retry_interval=3

###########################################################

#
# スタートポイント
#
function main() {
  shutdown_tomcat_completly

  wait_for_depended_servers_to_start

  startup_tomcat
}

###########################################################

#
# ローカルのTomcatを完全にシャットダウンします
#
function shutdown_tomcat_completly() {
  # ローカルのTomcatプロセスをShutDownする
  echo 'Tomcat shutdown started.'
  $tomcat_home/bin/shutdown.sh

  local is_local_server_killed=1
  for i in $(seq 1 $process_check_retry_count)
  do
    echo "check local process. count -> $i"

    is_local_server_killed
    is_local_server_killed=$?

    if [ $is_local_server_killed -eq 0 ]
    then
      echo 'local tomcat process killed.'
      break
    else
      sleep $process_check_retry_interval
    fi
  done

  # Shutdown 実施後規定時間待ってもプロセスが死んでない場合
  if [ $is_local_server_killed -eq 1 ]
  then
    echo 'cant stop local tomcat process normaly. kill commad will executed.'
    local_tomcat_process_id=`get_local_tomcat_process_id`
    kill $local_tomcat_process_id
    sleep 5
    is_local_server_killed
    is_local_server_killed=$?
    if [ $is_local_server_killed -eq 0]
    then
      echo 'local tomcat process killed.'
    else
      echo 'cant kill local tomcat process by kill command. kill -9 command will executed.'
      kill -9 $local_tomcat_process_id
    fi
  fi
}

#
# 他のサーバーが起動してから、自分自身を起動するため依存するサーバの起動をまちます
#
function wait_for_depended_servers_to_start() {
  # 依存するサーバの指定がなければチェックしない
  if [ ${#depended_servers[@]} -eq 0 ]
  then
    return 0
  fi

  local is_all_alive=1
  while [ $is_all_alive -eq 1 ]
  do
    is_depended_servers_all_alive
    is_all_alive=$?
    sleep $depended_servers_check_retry_interval
  done
}

function startup_tomcat() {
  # ローカルのTomcatプロセスを立ち上げる
  echo 'Tomcat startup started.'
  $tomcat_home/bin/startup.sh
}


###########################################################

#
# 依存するサーバがすべて起動済みかどうかを確認する
# @return すべて起動済みの場合 : 0, どれか一つでも未起動の場合 : 1
#
function is_depended_servers_all_alive() {
  for server in ${depended_servers[@]}
  do
    is_server_response_ok $server
    local is_server_alive=$?
    if [ $is_server_alive -eq 0 ]
    then
      continue
    else
      return 1
    fi
  done
  return 0
}


#
# 指定されたIPのTomcatからレスポンスが200で返ってくるかを判定します
# @param $1 : 起動済みか判定するサーバのIP
# @return レスポンスコードが200の場合 0, 200以外 1
#
function is_server_response_ok() {
  if [ $# -lt 1 ]
  then
    echo 'Arugument for ServerIP must required.'
    return 1
  fi

  local server=$1
  local check_alive_url=http://$server:$depended_servers_check_port/$depended_servers_check_url

  # wget のオプション
  # --server-response : サーバーからのレスポンス情報を表示
  # --spider          : コンテンツのダウンロードは行わない
  # --no-proxy        : proxyを使用しない
  # --quiet           : server response 以外のログを出力しない
  local status_code=`wget --server-response --spider --no-proxy $check_alive_url 2>&1 | awk '/^  HTTP/{print $2}'`
  if [ "$status_code" != "200" ]
  then
    return 1
  else
    return 0
  fi
}

#
# シェルを起動したサーバーのTomcatプロセスが死んでいるかどうかを判定します
# @return Tomcatプロセスが死んでいるとき : 0, 生きているとき : 1
#
function is_local_server_killed() {
  local process_id=`get_local_tomcat_process_id`
  if [ "$process_id" = "" ]
  then
    return 0
  else
    return 1
  fi
}

#
# ローカルで起動しているTomcatプロセスのIDを取得します
# @return プロセスID
#
function get_local_tomcat_process_id() {
  # jps コマンドはJDKがないと使用できないため psコマンドで行う
  #process_id=`jps | grep Bootstrap | awk -F" " '{ print $1 }'`
  echo `ps -ef | grep Bootstrap | grep java | awk -F" " '{ print $2 }'`
}

###########################################################

main
