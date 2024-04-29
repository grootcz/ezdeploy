#!/usr/bin/env bash

#####################################################################################
# 功能： 颜色输出前缀
# 入参： $1 - 需要输出的信息， $2 - 颜色后缀
# 出参： 在终端输出带颜色的信息
# 示例： 
# 注意： 
#------------------------------------------------------------------------------------
colourText() {
    echo -e " \e[0;$2m$1\e[0m"
}

#####################################################################################
# 功能： 白色打印
# 入参： $1 - 需要输出的信息
# 出参： 在终端输出带颜色的信息
# 示例： 
# 注意： 
#------------------------------------------------------------------------------------
White() {
    echo $(colourText "[DEBUG] $1" "37")
}

#####################################################################################
# 功能： 绿色打印
# 入参： $1 - 需要输出的信息
# 出参： 在终端输出带颜色的信息
# 示例： 
# 注意： 
#------------------------------------------------------------------------------------
Green() {
    echo $(colourText "[INFO] $1" "32")
}

#####################################################################################
# 功能： 黄色打印
# 入参： $1 - 需要输出的信息
# 出参： 在终端输出带颜色的信息
# 示例： 
# 注意： 
#------------------------------------------------------------------------------------
Yellow() {
    echo $(colourText "[WARN] $1" "33")
}

#####################################################################################
# 功能： 红色打印
# 入参： $1 - 需要输出的信息
# 出参： 在终端输出带颜色的信息
# 示例： 
# 注意： 
#------------------------------------------------------------------------------------
Red() {
    echo $(colourText "[ERROR] $1" "31")
}

#####################################################################################
# 功能： 紫红色打印
# 入参： $1 - 需要输出的信息
# 出参： 在终端输出带颜色的信息
# 示例： 
# 注意： 
#------------------------------------------------------------------------------------
Violet() {
    echo $(colourText "[PANIC] $1" "35")
}

#####################################################################################
# 功能：获取当前脚本命令行环境的工作全路径
# 入参： 无
# 出参： 当前脚本命令行环境的工作全路径
# 示例： 
# 注意： 
#------------------------------------------------------------------------------------
CurWorkFullPath() {
    curFullPath=$(
        cd $(dirname $0)
        pwd
    )
    
    echo $curFullPath
    return $?
}

#####################################################################################
# 功能： 去除开头结尾的空白字符
# 入参： $1 - 需要处理的字符串
# 出参： 去除开头结尾的空白字符后的字符串
# 示例： 
# 注意： 
#------------------------------------------------------------------------------------
trim() {
    str=""

    if [ $# -gt 0 ]; then
        str="$1"
    fi
    
    echo "$str" | sed -e 's/^[ \t\r\n]*//g' | sed -e 's/[ \t\r\n]*$//g'
}

#####################################################################################
# 功能： 获取系统标识符如 ubuntu、centos、alpine等
# 入参： 无
# 出参： 系统标识符如 ubuntu、centos、alpine等
# 示例： 
# 注意： 
#------------------------------------------------------------------------------------
os() {
    os=$(trim $(cat /etc/os-release 2>/dev/null | grep ^ID= | awk -F= '{print $2}'))

    if [ "$os" = "" ]; then
        os=$(trim $(lsb_release -i 2>/dev/null | awk -F: '{print $2}'))
    fi
    if [ ! "$os" = "" ]; then
        os=$(echo $os | tr '[A-Z]' '[a-z]')
    fi

    echo $os
}

#####################################################################################
# 功能： 根据系统标识符如 ubuntu、centos、alpine等，确定软件安装命令使用yum还是apt
# 入参： 无
# 出参： 确定软件安装命令使用yum或apt
# 示例： 
# 注意： 
#------------------------------------------------------------------------------------
GetPm()
{
    PM=""
    
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
    elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
        DISTRO='RHEL'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
        DISTRO='Aliyun'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        PM='apt'
    elif grep -Eqi "Kali" /etc/issue || grep -Eq "Kali" /etc/*-release; then
        DISTRO='Kali'
        PM='apt'
    else
        DISTRO='unknow'
        PM='unknow'
    fi
    
    echo $PM
}

#####################################################################################
# 功能： 获取系统IP
# 入参： $1 - 网卡名称
# 出参： 系统IP
# 示例： 
# 注意： 
#------------------------------------------------------------------------------------
HostIp() {
    localAddress=$(ifconfig $1 | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}')
    echo $localAddress

    return $?
}

#####################################################################################
# 功能： 进程是否在运行
# 入参： $1 - 进程名称
# 出参： 0 - 不在运行， 1 - 运行中
# 示例： 
# 注意： 
#------------------------------------------------------------------------------------
IsRuning() {
    isRuning=$(ps aux | grep $1 | grep -v grep | awk {'print("memInfo=%s; myStatus=%s; processName=%s", $4, $8, $11)'})
    if [ "$isRuning" ]; then
        echo 1
    else
        echo 0
    fi

    return $?
}

#####################################################################################
# 功能： 检查docker是否安装
# 入参： 无
# 出参： docker版本
# 示例： 
# 注意： 
#------------------------------------------------------------------------------------
checkDockerInstall() {
    checkRet=$(sudo docker version | grep Version | awk -F" " '{print $2}' | awk 'NR==1{print}')
    echo $checkRet
}

#####################################################################################
# 功能： 通过dockerfile构建镜像
# 入参： $1 - dockerfile路径, $2 - 生成的镜像名称, $3 - 镜像版本.
# 出参： 无
# 示例： 
# 注意： dockerfile中ADD、COPY等命令中的src实现是相对于此脚本当前环境路径的
#------------------------------------------------------------------------------------
dockerImageBuild() {
    dockerfile=$1
    imageName=$2
    imageVersion=$3
    
    sudo docker build --file $dockerfile -t $imageName:$imageVersion .
}

#####################################################################################
# 功能： 是否存在指定名称的镜像
# 入参： $1 - 镜像名称
# 出参： 0 - 不存在， 1 - 存在
# 示例： 
# 注意： 
#------------------------------------------------------------------------------------
CheckDockerImage() {
    imageCheck=$(sudo docker images | grep $1 | awk '{print $1}')
    if [ "$imageCheck" ]; then
        echo 1
    else
        echo 0
    fi

    return $?
}

#####################################################################################
# 功能： 是否存在指定名称的容器，包括stop状态的
# 入参： $1 - 容器名称
# 出参： 0 - 不存在， 1 - 存在
# 示例： 
# 注意： 
#------------------------------------------------------------------------------------
CheckDockerContainer() {
    containerCheck=$(sudo docker ps -a | grep $1)
    if [ "$containerCheck" ]; then
        echo 1
    else
        echo 0
    fi

    return $?
}

#####################################################################################
# 功能： 是否存在指定dir
# 入参： $1 - dir
# 出参： 0 - 不存在， 1 - 存在
# 示例： 
# 注意： 
#------------------------------------------------------------------------------------
IsDirExist() {
	if [ ! -d "$1" ]; then
	  mkdir $1
	fi
}

Green "########################################################################################"
Green "#                                                                                       "
Green "#                                                                                       "
Green "#                                 begin to run                                          "
Green "#                                                                                       "
Green "#                                                                                       "
Green "########################################################################################"

hostRootPath=$(cd `dirname $0`; pwd)
Green "now work at "$hostRootPath

hostVolumeConfigPath="$hostRootPath/conf"
hostVolumeDataPath="$hostRootPath/data"
hostVolumeLogPath="$hostRootPath/log"

IsDirExist "$hostVolumeDataPath"
chmod -R 777 $hostVolumeDataPath

IsDirExist "$hostVolumeLogPath"
chmod -R 777 $hostVolumeLogPath

Green "finished init host variables"

containerConfigPath="/usr/local/etc/redis"
containerDataPath="/data"
containerLogPath="/var/lib/redis_log"

Green "finished init container variables"

Yellow "please make sure that redis.conf requirepass and logfile has modify to what you want"

docker run -d \
-p 26379:6379 \
-e MYSQL_ROOT_PASSWORD=$MysqlRootPw \
-v $hostVolumeDataPath:$containerDataPath \
-v $hostVolumeConfigPath:$containerConfigPath \
-v $hostVolumeLogPath:$containerLogPath \
--restart always --name redis_7 redis:7.0.11 redis-server /usr/local/etc/redis/redis.conf





