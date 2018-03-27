#!/bin/bash
#-------------CopyRight------------- 
#   Name:create_cycle_result
#   Version Number:1.00
#   Type:DataQuery
#   Language:bash shell 
#   Date:2013-03-20
#   Author:LYJ
#   Email:
#------------Environment------------ 
#   Linux 3.5.0 x86_64
#   GNU Bash 4.2.37
#------------------------------------

#--------------Variable-------------- 
binFold="pipe"
source  $binFold/config.conf
AWK_FOLD="$binFold/awk"
etlFold="$binFold/etl/create_r"
titleFold="$binFold/title"
includeFold="$binFold/include"
ZIDIAN_FOLD="$ROOT_FOLD/zidian"

dataTypes=(_2G _3G _LTE)
dataTypes_n=${#dataTypes[*]}

source $includeFold/zidian.ini

shijian1=""
cycle=""
number=1
HEAD_FILE=""
source_file=""
pre_source_file=""
FILE_NAME=""
top=10000
count_size=60000000
#--------------Function-------------- 

#source $etlFold/service.etl
#source $etlFold/4g.etl
#source $etlFold/cgi_service.etl
#source $etlFold/net_que.etl
#source $etlFold/phone_service.etl
#source $etlFold/signal_que.etl
#source $etlFold/terminal_service.etl
#source $etlFold/kpi.etl
#source $etlFold/kqi.etl
#source $etlFold/vokpi/diameter.etl

for file in $(find $etlFold -name "*.etl" );do
source $file
done

function check_dataType()
{
   flag=0;
   for((i=0;i<$dataTypes_n;i++));do
    if [[ ${dataTypes[$i]} == $dataType ]];then
       flag=1;
       return;
    fi
  done
  echo_error "yuan is wrong !"
}
function init_dataFold()
{
dataType=$1
if [ -z $dataType ];then
   echo_error "param dataType need !"
fi
RESULT_FOLD="$ROOT_FOLD/result/$dataType"
SOURCE_FOLD="$ROOT_FOLD/datasource/$dataType"
f_SOURCE_FOLD="$ROOT_FOLD/datasource/$dataType/fiveminute"
T_SOURCE_FOLD="$ROOT_FOLD/datasource/$dataType/tenminute"
F_SOURCE_FOLD="$ROOT_FOLD/datasource/$dataType/fifminute"
H_SOURCE_FOLD="$ROOT_FOLD/datasource/$dataType/hour"
D_SOURCE_FOLD="$ROOT_FOLD/datasource/$dataType/day"
W_SOURCE_FOLD="$ROOT_FOLD/datasource/$dataType/week"
M_SOURCE_FOLD="$ROOT_FOLD/datasource/$dataType/month"
S_SOURCE_FOLD="$ROOT_FOLD/datasource/$dataType/season"
Y_SOURCE_FOLD="$ROOT_FOLD/datasource/$dataType/year"

f_RESULT_FOLD="$ROOT_FOLD/result/$dataType/fiveminute"
T_RESULT_FOLD="$ROOT_FOLD/result/$dataType/tenminute"
F_RESULT_FOLD="$ROOT_FOLD/result/$dataType/fifminute"
H_RESULT_FOLD="$ROOT_FOLD/result/$dataType/hour"
D_RESULT_FOLD="$ROOT_FOLD/result/$dataType/day"
W_RESULT_FOLD="$ROOT_FOLD/result/$dataType/week"
M_RESULT_FOLD="$ROOT_FOLD/result/$dataType/month"
S_RESULT_FOLD="$ROOT_FOLD/result/$dataType/season"
Y_RESULT_FOLD="$ROOT_FOLD/result/$dataType/year"
 
}


function disk_size_total()
{
   fileCount=`find  $RESULT_FOLD  -name "${shijian1}.txt"|wc -l`
   local myfold=$RESULT_FOLD
    RESULT_FOLD=$RESULT_FOLD/$HEAD_FILE
    check_result_fold
   if [[ $fileCount > 0 ]];then
      find  $myfold  -name "${shijian1}.txt"|xargs du| awk '{total_size+=$1}END{print total_size/1024}' > $RESULT_FOLD/$FILE_NAME 
   else
     echo 0 >$RESULT_FOLD/$FILE_NAME
   fi
}
function usage()
{
   echo "Usage: `basename $0`	"
   echo "                       [-h|--help ]"
   echo "                       [-H|--head ]    "
   find  $binFold/etl/create_r  -name  "*.etl"|xargs grep -h "^function"|sed -r 's/(function|\(\)| )//g'|\
	sort|awk 'BEGIN{count=1}{printf("%-43s",$0);count++;if(count==3){print "";count=0}}END{print ""}'
   echo "                       [-t|--time ]    yyyymmdd yyyymmddHH"
   echo "                       [-c|--cycle]    <f|h|d|w|m|s|y> "
   echo "                       [-y|--yuan ]    datasource type"
    exit 1
}


function get_option()
{
    ARGS="`getopt -u -o "hH:t:c:y:" -l "help,head:,time:,cycle:yuan:" -- "$@"`"
    [ $? -ne 0 ] && usage
    set -- ${ARGS}

    while [ true ] ; do
        case $1 in
            -h|--help)
                usage
                ;;
            -H|--head)
                HEAD_FILE=$2
                shift
                ;;
            -t|--time)
                shijian1=$2
                shift
                ;;
            -c|--cycle)
                cycle=$2
                shift;
                ;;
            -y|--yuan)
		dataType=$2
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                usage
                ;;
        esac
        shift
    done
   

   if [ -z $shijian1 ];then
       usage
       exit 1
   fi
}
function echo_error()
{
        echo "[{\"error\":\"$1\"}]";
        exit;
}
function check_result_fold()
{
   if [ ! -d $RESULT_FOLD ];then
          mkdir -p $RESULT_FOLD
   fi
}

function check_data()
{
    if [ ! -s $HEAD_FOLD/$HEAD_FILE ];then
      echo_error "head not found" ;
    fi
}
function echo_error()
{
	echo "[{\"error\":\"$1\"}]";
	exit;
}
function set_pre_variables()
{
  case $cycle in
	  f)
		 SOURCE_FOLD=$f_SOURCE_FOLD
         RESULT_FOLD=$f_RESULT_FOLD
         ;;  
	  t)
		SOURCE_FOLD=$T_SOURCE_FOLD
        RESULT_FOLD=$T_RESULT_FOLD
         ;;  	
	  F)
		SOURCE_FOLD=$F_SOURCE_FOLD
        RESULT_FOLD=$F_RESULT_FOLD
         ;;
      h)
         number=0.042;
         SOURCE_FOLD=$H_SOURCE_FOLD
         RESULT_FOLD=$H_RESULT_FOLD
         ;;
      d)
        number=1;
        SOURCE_FOLD=$D_SOURCE_FOLD
        RESULT_FOLD=$D_RESULT_FOLD
        ;;
      w)
        number=7;
        SOURCE_FOLD=$W_SOURCE_FOLD 
        RESULT_FOLD=$W_RESULT_FOLD
        ;;
      m)
        number=30
        SOURCE_FOLD=$M_SOURCE_FOLD 
        RESULT_FOLD=$M_RESULT_FOLD
        ;;
      s)
        number=90
        SOURCE_FOLD=$S_SOURCE_FOLD 
        RESULT_FOLD=$S_RESULT_FOLD
        ;;
      y)
        number=365
        SOURCE_FOLD=$Y_SOURCE_FOLD 
        RESULT_FOLD=$Y_RESULT_FOLD
        ;;
      *)
          echo_error "wrong cycle!"
   esac 
}
function set_last_variables()
{
  if [[ "$HEAD_FILE"  != "disk_size_total" ]];then
     RESULT_FOLD=$RESULT_FOLD/$HEAD_FILE
  fi
  check_result_fold
}

function set_source_file()
{
   case $cycle in
    f)
          mDATE=${shijian1:0:8}
          mHOURMinute=${shijian1:8:4}
	 tmp_file=${mDATE}_${mHOURMinute}.txt
          ;;
     h)
         mDATE=${shijian1:0:8}
          mHOUR=${shijian1:8:2}
         tmp_file=${mDATE}${mHOUR}00.txt
         ;;
     *)
         tmp_file=${shijian1}.txt
	  ;;
   esac
    if [ -s  $SOURCE_FOLD/$tmp_file ];then
     source_file="$source_file $SOURCE_FOLD/$tmp_file"
    fi
}
function set_pre_source_file()
{

   case $cycle in
    f)
          mDATE=${shijian1:0:8}
          mHOUR=${shijian1:8:2}
          mMinute=${shijian1:10:2}
         pre_time=$(date -d "${mDATE}${mHOUR}:${mMinute} 5minutes ago " +%Y%m%d%H%M)
         tmp_file=${pre_time}.txt
          ;;
     h)
         mDATE=${shijian1:0:8}
          mHOUR=${shijian1:8:2}
         pre_time=$(date -d "${mDATE}${mHOUR} 1hours ago " +%Y%m%d%H)
         tmp_file=${pre_time}00.txt
         ;;
     *)
        pre_time=$(date -d "${mDATE} 01:00 1days ago " +%Y%m%d)
         tmp_file=${pre_time}.txt
          ;;
   esac
   if [ -s  $SOURCE_FOLD/$tmp_file ];then
     pre_source_file="$SOURCE_FOLD/$tmp_file"
    fi
   
}

function set_datasoure()
{
  source $includeFold/set_create_source.ini 
}


function create_result()
{
   ${HEAD_FILE}
   SOURCE_FOLD="$SOURCE_FOLD/${_source_file}" 
   set_source_file
   if [[ -z $source_file ]] && [[ ${HEAD_FILE} != "npm_npass_stat" ]];then
        return
   fi  
   case ${HEAD_FILE} in
    GN_PROVINCE_PROVINCE_SVCINCRE10_DA|\
    GN_PROVINCE_PROVINCE_SVCINCRERANGE10_DA)
          set_pre_source_file
          shellcmd="cat $pre_source_file $source_file"
          ;;
    *)
  	 shellcmd="cat $source_file"
	  ;;
    esac
    
   [ "${_source_shell}" !=  "" ] && shellcmd="${shellcmd} | ${_source_shell}"
   [ "${_trans_awk}"    !=  "" ] && shellcmd="${shellcmd} | ${_trans_awk}" 
   [ "${_awk_file}"     !=  "" ] && shellcmd="${shellcmd} | awk ${_awk_v}  -f ${AWK_FOLD}/${_awk_file}" 
   [ "${_sort_cmd}"    !=  "" ] && shellcmd="${shellcmd} | ${_sort_cmd}" 
#   echo "$shellcmd" 
#   exit
   echo "$shellcmd"|sh  >$RESULT_FOLD/$FILE_NAME

}

function init_FILENAME()
{
   FILE_NAME=$shijian1.txt
}

function check_result_today()
{
   local _t_now=0;
   local row=0
   row="`grep function  $binFold/etl/create_r/npm.etl|sed 's/function//g'|awk -F'(' '{print $1}'|awk -v head=$HEAD_FILE '{if($1==head){print NR}}'`"
   source_head="`grep _source_file $binFold/etl/create_r/npm.etl|awk -F'"' -v row_cnt=$row '{if(NR==row_cnt){print $2}}'`"
   case $cycle in
      h)
       _t_now=$(date +"%Y%m%d%H")
       if [ "$_t_now" == "$shijian1" ];then
           init_dataFold $dataType "/run"
       fi
       ;;
      d)
        _t_now=$(date +"%Y%m%d")
       if [ "$_t_now" == "$shijian1" ];then
           init_dataFold $dataType  "/run"
       fi
      ;;
   esac
}
function main()
{
  check_dataType
  init_dataFold $dataType $ROOT_FOLD
  #check_result_today
  init_FILENAME
  set_pre_variables
  set_last_variables
  create_result
  if [ -s $RESULT_FOLD/$FILE_NAME ];then
        echo $RESULT_FOLD/$FILE_NAME
   else
        echo "Nothing $RESULT_FOLD/$FILE_NAME"
   fi
}

get_option "$@"
main
