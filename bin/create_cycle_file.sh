#!/bin/bash
#-------------CopyRight------------- 
#   Name:create_cycle_file
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
AWK_FOLD="$binFold/awk"
etlFold="$binFold/etl/create_f"
dataTypes=(_2G _3G _LTE)
dataTypes_n=${#dataTypes[*]}

shijian1=""
_DATE1=""
_HOUR1=""
cycle=""
HEAD_FILE=""
FILE_NAME=""
source_file=""
month_day_count=""
count_size=10000000

data_cell=5


function set_count_size()
{
    case $cycle in 
     h)
	count_size=10000000 ;;
     *)
	count_size=5000000 ;;
    esac
}

#--------------Function-------------- 

source  $binFold/config.conf
for file in $(find $etlFold -name "*.etl" );do
source $file
done

function init_dataFold()
{
 dataType=$1
 RESULT_FOLD="$ROOT_FOLD/datasource/$dataType"
 SOURCE_FOLD="$ROOT_FOLD/datasource/$dataType"
 m_SOURCE_FOLD="$ROOT_FOLD/datasource/$dataType/fifminute"
 F_SOURCE_FOLD="$ROOT_FOLD/datasource/$dataType/fiveminute"
 T_SOURCE_FOLD="$ROOT_FOLD/datasource/$dataType/tenminute"
 H_SOURCE_FOLD="$ROOT_FOLD/datasource/$dataType/hour"
 D_SOURCE_FOLD="$ROOT_FOLD/datasource/$dataType/day"
 W_SOURCE_FOLD="$ROOT_FOLD/datasource/$dataType/week"
 M_SOURCE_FOLD="$ROOT_FOLD/datasource/$dataType/month"
 S_SOURCE_FOLD="$ROOT_FOLD/datasource/$dataType/season"
 Y_SOURCE_FOLD="$ROOT_FOLD/datasource/$dataType/year"
}
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

function usage()
{
    echo "Usage:  `basename $0` "    
    echo "     [-h|--help  ]       "
    echo "     [-H|--head  ]      "
     ls $ROOT_FOLD/datasource/$dataType/fiveminute
    echo "     [-t|--time  ]   yyyymmdd yyyymmddHH"
    echo "     [-c|--cycle ]   <t|f|h|d|w|m|s|y> "
    echo "     [-y|--yuan  ]   datasource type"
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
                shift
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

    return
}
function check_daylight_saving()
{
   _check_date=$1 
   daylight_saving=0
   error_cnt=`date -d "_check_date" +%s 2>&1|grep invalid|wc -l `
   if [  $error_cnt -eq 1 ] ;then
    daylight_saving=1
   fi
   
}
function set_fiveminute_source_file()
{
    local last_date=$1;
    local last_hour=$2;
    local last_minute=$3
    local _SOURCE_FOLD=$F_SOURCE_FOLD/$HEAD_FILE
          RESULT_FOLD=$F_SOURCE_FOLD
          tmp_file=$(date -d  "${last_date} ${last_hour}:${last_minute}  " "+%Y%m%d_%H%M".txt)
          if [ -s  $_SOURCE_FOLD/$tmp_file ];then
                    source_file="$source_file $_SOURCE_FOLD/$tmp_file"
           fi
}
function set_tenminute_source_file()
{
    local last_date=$1;
    local last_hour=$2;
    local last_minute=$3
    local _SOURCE_FOLD=$F_SOURCE_FOLD/$HEAD_FILE
          RESULT_FOLD=$T_SOURCE_FOLD

     _tdate=$(date -d  "${last_date} ${last_hour}:${last_minute} 10minutes ago" "+%Y%m%d %H:%M")
     for ((mdate=0;mdate<2;mdate++))
     do
              _minutes=$((5*mdate))
              tmp_file=$(date -d  "$_tdate  ${_minutes}minutes " "+%Y%m%d%H%M".txt)
              if [ -s  $_SOURCE_FOLD/$tmp_file ];then
                    source_file="$source_file $_SOURCE_FOLD/$tmp_file"
              fi
     done
}
function set_fifminute_source_file()
{
    local last_date=$1;
    local last_hour=$2;
    local last_minute=$3
    local _SOURCE_FOLD=$F_SOURCE_FOLD/$HEAD_FILE
    	  RESULT_FOLD=$m_SOURCE_FOLD

     _tdate=$(date -d  "${last_date} ${last_hour}:${last_minute}  15minutes ago " "+%Y%m%d %H:%M")
     for ((mdate=0;mdate<3;mdate++))
     do
              _minutes=$((5*mdate))
              tmp_file=$(date -d  "$_tdate  ${_minutes}minutes " "+%Y%m%d%H%M".txt)                                                       
              if [ -s  $_SOURCE_FOLD/$tmp_file ];then
                    source_file="$source_file $_SOURCE_FOLD/$tmp_file"
              fi
     done
}
function set_hour_source_file()
{
    local last_date=$1; 
    local last_hour=$2;
    local _SOURCE_FOLD=$F_SOURCE_FOLD/$HEAD_FILE
    	  RESULT_FOLD=$H_SOURCE_FOLD
     _tdate=$(date -d  "${last_date} ${last_hour}" "+%Y%m%d %H:%M")
    if [ "$data_cell" -eq 5 ];then
	    _SOURCE_FOLD=$F_SOURCE_FOLD/$HEAD_FILE
        for ((mdate=0;mdate<12;mdate++))
        do
              _minutes=$((5*mdate))
              tmp_file=$(date -d  "$_tdate  ${_minutes}minutes " "+%Y%m%d_%H%M".txt)
              if [ -s  $_SOURCE_FOLD/$tmp_file ];then
                    source_file="$source_file $_SOURCE_FOLD/$tmp_file"
              fi
        done
   else
       _SOURCE_FOLD=$m_SOURCE_FOLD/$HEAD_FILE
       for ((mdate=0;mdate<4;mdate++))
       do
              _minutes=$((15*mdate))
              tmp_file=$(date -d  "$_tdate  ${_minutes}minutes " "+%Y%m%d_%H%M".txt)
              if [ -s  $_SOURCE_FOLD/$tmp_file ];then
                    source_file="$source_file $_SOURCE_FOLD/$tmp_file"
              fi
       done
   fi
}

function set_day_source_file()
{
    local last_date=$1; 
    local _SOURCE_FOLD=$H_SOURCE_FOLD/$HEAD_FILE
    RESULT_FOLD=$D_SOURCE_FOLD
    check_daylight_saving $last_date
    if [ $daylight_saving -eq 0 ] ;then
     _tdate=$(date -d  "${last_date} " "+%Y%m%d %H:%M")
     _max_hour=24
    else
     _tdate=$(date -d  "${last_date} 01" "+%Y%m%d %H:%M")
     _max_hour=23
    fi
    
     for ((mdate=0;mdate<$_max_hour;mdate++))
     do
              tmp_file=$(date -d  "$_tdate  ${mdate}hours " "+%Y%m%d%H"00.txt)
              if [ -s  $_SOURCE_FOLD/$tmp_file ];then
                    source_file="$source_file $_SOURCE_FOLD/${tmp_file}"
              fi
     done
}

function set_Nday_source_file()
{
    local last_date=$1; 
    local day_count=$2;
    local _SOURCE_FOLD=$D_SOURCE_FOLD/$HEAD_FILE
 
    for ((sdate=0;sdate<"$day_count";sdate++))
    do
            tmp_file=$(date -d  "${last_date} 01:00  ${sdate}days ago " +%Y%m%d.txt)
            if [ -s  $_SOURCE_FOLD/$tmp_file ];then
                 source_file="$source_file $_SOURCE_FOLD/$tmp_file"
            fi
    done
}

function set_week_source_file()
{
   local last_date=$1;
   RESULT_FOLD=$W_SOURCE_FOLD
   set_Nday_source_file $last_date 7
}

function get_month_day_count()
{
   local t_shijian=$1;
   local month_start=${t_shijian:0:6}"01";
   local month_start_date=$(date -d "$month_start  1days ago" "+%s");
   local next_month=$(date -d "$month_start  1months  " "+%Y%m%d");
   local month_end_date=$(date -d "$next_month  1days ago " "+%s");
   month_day_count=$(((month_end_date-month_start_date)/86400))
   
}

function set_month_source_file()
{
   local last_date=$1;
   RESULT_FOLD=$M_SOURCE_FOLD
   get_month_day_count $last_date
   set_Nday_source_file $last_date $month_day_count
}


function set_season_source_file()
{
    local last_date=$1;
    local _SOURCE_FOLD=$M_SOURCE_FOLD/$HEAD_FILE
    RESULT_FOLD=$S_SOURCE_FOLD
    for ((sdate=0;sdate<3;sdate++))
    do
            next_month_first_day=$(date -d  "${last_date} 01:00  1days " +%Y%m%d)
            month_first_day=$(date -d  "${next_month_first_day}   ${sdate}months ago " +%Y%m%d)
            month_last_date=$(date -d  "${month_first_day}   1days ago " +%Y%m%d)
            tmp_file=${month_last_date}.txt
            if [ -s  $_SOURCE_FOLD/$tmp_file ];then
                  source_file="$source_file $_SOURCE_FOLD/$tmp_file"
            fi
    done
}

function set_year_source_file()
{
    local last_date=$1;
    local _SOURCE_FOLD=$S_SOURCE_FOLD/$HEAD_FILE
    RESULT_FOLD=$Y_SOURCE_FOLD
    for ((sdate=0;sdate<4;sdate++))
    do
            t_date=$((sdate*3))
            next_month_first_day=$(date -d  "${last_date} 01:00  1days " +%Y%m%d)
            seaon_next_month_first_day=$(date -d  "${next_month_first_day}   ${t_date}months ago " +%Y%m%d)
            season_last_date=$(date -d  "${seaon_next_month_first_day}   1days ago " +%Y%m%d)
            tmp_file=${season_last_date}.txt
            if [ -s  $_SOURCE_FOLD/$tmp_file ];then
                  source_file="$source_file $_SOURCE_FOLD/$tmp_file"
            fi
    done
}


function set_source_file()
{
   case $cycle in
         f)
                  set_fiveminute_source_file $_DATE1 $_HOUR1 $_MINUTE1 ;;
	  t)
		  set_tenminute_source_file $_DATE1 $_HOUR1 $_MINUTE1 ;;
	  F)  
		  set_fifminute_source_file $_DATE1 $_HOUR1 $_MINUTE1 ;;
      h)
          set_hour_source_file $_DATE1 $_HOUR1;;
      d)
          set_day_source_file $_DATE1 ;;
      w)
          set_week_source_file $_DATE1 ;;
      m)
          set_month_source_file $_DATE1 ;;
      s)
          set_season_source_file $_DATE1 ;;
      y)
          set_year_source_file $_DATE1 ;;
      *)
          echo_error "wrong cycle!"
   esac

}

function set_pre_variables()
{
    case $cycle in
    f|t|F)
		_HOUR1=${shijian1:8:2};
		_MINUTE1=${shijian1:10:2};
	    ;;
    h)
		_HOUR1=${shijian1:8:2};
		;;
   esac
        _DATE1=${shijian1:0:8};
}
function set_last_variables()
{
   case $cycle in
	f|t|F)
		FILE_NAME=${_DATE1}${_HOUR1}${_MINUTE1}.txt
		;;
	h)
		FILE_NAME=${_DATE1}${_HOUR1}00.txt
		;;
    *)
		FILE_NAME=${_DATE1}.txt
		;;
   esac

   RESULT_FOLD=$RESULT_FOLD/$HEAD_FILE
   check_result_fold
}


function create_cycle()
{
    if [[ -z  $source_file ]];then
                  return
    fi
   $HEAD_FILE
   if [ $_is_cut -eq 1 ];then
        set_count_size
       shellcmd="sort -S 10G $source_file "
   else
       shellcmd="cat $source_file "
   fi
   if [[ "$cycle" == "f" ]];then
        [ "${_trans_awk}"    !=  "" ] && shellcmd="${shellcmd} | ${_trans_awk}" 
   fi
    shellcmd="${shellcmd} | awk -v count=$count_size -v key_cnt=${_key_cnt}  ${_awk_v}  -f ${AWK_FOLD}/${_awk_file}" 
    echo "$shellcmd"|sh  >$RESULT_FOLD/$FILE_NAME
}


function main()
{
   check_dataType
   init_dataFold $dataType
   set_pre_variables
   set_source_file;
   set_last_variables;
   create_cycle;
   if [ -s $RESULT_FOLD/$FILE_NAME ];then 
   	echo $RESULT_FOLD/$FILE_NAME
   else
	echo "Nothing $RESULT_FOLD/$FILE_NAME"
   fi 
}

get_option "$@"
main
