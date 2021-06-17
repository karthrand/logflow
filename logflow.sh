#!/bin/bash
#环境初始化

#创建cache文件夹
if [ ! -f "$PWD/writecontent" ];then
    echo -e "\033[33m日志打流writecontent内容未配置，已自动创建文件，请配置内容！\033[0m"
    touch $PWD/writecontent
    exit 0
fi

#获取写入日志文件的内容
content=`cat writecontent`
if [ ! -n "$content" ];then  #文件存在且不为空
    echo -e "\033[31m日志打流内容为空，请先配置当前目录下writecontent文件，输入打流内容!\033[0m"
    exit 0
fi

#fucntions
#------------------------
function filesize(){
    c_size=`ls -l $filelocation | awk '{print $5}'`
    echo "${c_size}"
}

function filesize_unit(){
    c_size_unit=`ls -lh $filelocation | awk '{print $5}'`
    echo "${c_size_unit}"
}

function targetsize(){
    if [[ $targe =~ K$ || $targe =~ M$ || $targe =~ G$ ]];then
        unit=`echo $targe|grep -o .$`            #获取目标值的单位
        purevalue=`echo ${targe} | sed 's/.$//'` #获取目标值的值
        #判断目标值的值是否为数字
        echo ${purevalue} | grep [^0-9.] >/dev/null && echo -e "\033[31m输入值不是数字(不含单位)\033[0m"

        #根据单位输出最后的字节为单位的数
        case $unit in
        "K")
            
            totalsize_k=`awk 'BEGIN{print "'$purevalue'" * "1024"}'`
            echo "${totalsize_k}"
        ;;
        "M")
            totalsize_m=`awk 'BEGIN{print "'$purevalue'" * "1048576"}'`
            echo "${totalsize_m}"
        ;;
        "G")
            totalsize_g=`awk 'BEGIN{print "'$purevalue'" * "1073741824"}'`
            echo "${totalsize_g}"
        ;;
        esac
        
    else
        echo -e  "\033[31m打流后文件大小的单位格式错误!\033[0m"
        exit 0
    fi

}

function check(){
which bc
if [ "$?" != "0" ];then
    #未安装bc，flag置0
    bc_flag=0
else
    bc_flag=1
fi

}

function  flow(){
    #获取总文件大小
    total_size=`targetsize`
    current_size=`filesize`
    declare -i i=0
    while [[ ${current_size} -lt ${total_size} ]]
    do
        echo "$content" >> $filelocation
        current_size=`filesize`
        current_size_unit=`filesize_unit`

        #每隔10次打印一次进度
        if [[ "$i" == "100" ]];then
            if [[ "$bc_flag" == "0" ]];then
                echo -e "\033[1;1H进度: $current_size_unit/$targe\033[0m"
            else
                percent=`echo "scale=4; $current_size / $total_size" *100 | bc`
                echo -e "\033[1;1H进度: $current_size_unit/$targe,${percent}%\033[0m"
            fi
            i=0
        fi


        i=$[$i+1]
    done
}
#--------------------
#输入判断
if [ $# != 2 ];then
    echo "请使用以下格式:"
    echo "bash writelog.sh [被打流的日志文件] [打流后文件的大小(原本文件大小也会自动计算在内)，使用K、M、G单位结尾]"
    exit 0
else
    clear
    filelocation=$1
    targe=$2
    check
    flow filelocation totalsize
fi