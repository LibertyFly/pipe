#!/bin/bash
#-------------CopyRight------------- 
#   Name:get_cycle_result.sh
#   Version Number:5.01
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
binFold="/usr/local/functionlib"
includeFold="$binFold/include"
etlFold="$binFold/etl/query"
titleFold="$binFold/title"


source  $binFold/config.conf
source $includeFold/common.ini
source $includeFold/muti.ini
source $includeFold/zidian.ini
source $includeFold/datasource.ini
source $includeFold/percent_total.ini

dbShell=`cat  $binFold/db.cnf|grep mysql_info|awk -F= '{print $2}'`

shijian1=""
DATE1=""
HOUR1=""
MINUTE1=""
cycle=""
detail=0
last=0
apercent="";
top=400000
count=0
HEAD_FILE=""
head_file=""
index=0
index_file=""
time=""
pre_cycle_time=""
keyvalue=100

PAGE_SIZE=20000
PAGE_NUM=1
sort=0;
csv=0;
src_head="";
rev=r;
timeValue=3600
detail_cycle="d"

#--------------------------------------------
# Analyse data begin.
#--------------------------------------------
for file in $(find $etlFold -name "*.etl" );do
source $file
done
#-----------------------------------------------
# Print help information.
#-----------------------------------------------
function usage()
{
    echo "Usage: `basename $0` "
    echo "                    [-h|--help    ]"    
    echo "                    [-H|--head    ]    "
   find  $binFold/etl/create_r  -name  "*.etl"|xargs grep -h "^function"|sed -r 's/(function|\(\)| )//g'|\
        sort|awk 'BEGIN{count=1}{printf("%-43s",$0);count++;if(count==3){print "";count=0}}END{print ""}'
    echo "                    [-t|--time      ]  yyyymmdd yyyymmddHH"
    echo "                    [-c|--cycle     ]  <h|d|w|m|s|y>"
    echo "                    [-d|--detail    ]  whether get detail"
    echo "                    [-l|--last      ]  whether get last cycle data"
    echo "                    [-i|--index     ]  whether use index"
    echo "                    [-a|--apercent  ]  percent type "
    echo "                    [-p|--param     ]  parameters "
    echo "                    [-T|--top       ]  TOP N default value 2000 "
    echo "                    [-N|--number    ]  page number  "
    echo "                    [-S|--size      ]  page size    "
    echo "                    [-s|--sort      ]  sort column number "
    echo "                    [-r|--rev       ]  sort rev "
    echo "                    [-C|--count     ]  row count    "
    echo "                    [-f|--csv       ]  return csv "
    echo "                    [-L|--language  ]  <en|zh>" 
    echo "                    [-y|--yuan      ]  <GN_3G>"
    echo "                    [-v|--value     ]  key value set "
    echo "                    [-m|--muti      ]  whether use  muti "
    exit 1
}


#
# Set parameters for shell program.
#

function get_option()
{
    ARGS="`getopt -u -o "hrlidCfmH:t:c:p:T:N:S:s:L:y:a:v:g:" -l "help,last,index,detail,count,csv,muti, \
			head:,time:,cycle:,param:,top:,number:,size:,sort:,rev,language:,yuan:,apercent:,value:" -- "$@"`"
    [ $? -ne 0 ] && usage
    set -- ${ARGS}

    while [ true ] ; do
        case $1 in
            -h|--help)
                usage
                ;;
            -H|--head)
	            	src_head=$2
                HEAD_FILE=$2
                index_str="$index_str$1$2"
                shift
                ;;
            -t|--time)
                shijian1=$2
                index_str="$index_str$1$2"
                shift
                ;;
            -c|--cycle)
                cycle=$2
                index_str="$index_str$1$2"
                shift
                ;;
            -d|--detail)
                detail=1
                index_str="$index_str$1$2"
                ;;
            -l|--last)
               last=1
               index_str="$index_str$1$2"
                ;;
	          -a|--apercent)
                apercent=$2
                index_str="$index_str$1$2"
		             shift
                ;;
            -p|--param)
                 param=$2
                 index_str="$index_str$1$2"
                 shift;
                 ;;
            -T|--top)
                 top=$2
                 index_str="$index_str$1$2"
                 shift;
                 ;;
	          -L|--language)
                 language=$2
                 index_str="$index_str$1$2"
                 shift;
                 ;;
            -y|--yuan)
		             dataType=$2
	               index_str="$index_str$1$2"
                 shift
                ;;
            -v|--value)
                 keyvalue=$2
                 index_str="$index_str$1$2"
                 shift;
                 ;;
            -N|--number)
                 PAGE_NUM=$2
                 shift;
                 ;;
            -S|--size)
                 PAGE_SIZE=$2
                 shift;
                 ;;
	          -s|--sort)
                 sort=$2
                 shift;
                 ;;
            -r|rev)
                 rev=""
                 ;;
             -i|--index)
                 index=1
                 ;;
	    -C|--count)
                 count=1
                 ;;
            -g)
                 detail_cycle=$2
                 shift;
                 ;;
            -f|--csv)
		            csv=1
		             ;;
	          -m|--muti)
	             	muti=1
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


function check_data()
{
    if [ ! -s $index_file ];then
      echo_error  "${cycle} index file not found";
    fi         
}


function get_pre_cycle_time()
{
   local _date=$DATE1
   case $cycle in 
     f)
	local _hour=$HOUR1
        local _minute=$MINUTE1
	    pre_cycle_time=$(date -d "$_date ${_hour}${_minute}  5minutes ago" +%Y%m%d%H)
        ;; 	
     t)
        local _hour=$HOUR1
        local _minute=$MINUTE1
        pre_cycle_time=$(date -d "$_date ${_hour}${_minute} 10minutes ago" +%Y%m%d%H)
        ;;
     F)
        local _hour=$HOUR1
        local _minute=$MINUTE1
          pre_cycle_time=$(date -d "$_date ${_hour}${_minute} 15minutes ago" +%Y%m%d%H)
          ;;
     h)
		  local _hour=$HOUR1
	      pre_cycle_time=$(date -d "$_date $_hour  1hours ago" +%Y%m%d%H)
          ;;   	
     d)
          pre_cycle_time=$(date -d "$_date 1days ago" +%Y%m%d)
          ;;
     w)
          pre_cycle_time=$(date -d "$_date 7days ago" +%Y%m%d)
          ;;
     m)
           month_start=${_date:0:6}"01";
           pre_cycle_time=$(date -d "$month_start  1days ago" +%Y%m%d)
           ;;
     s)
           next_month_first_day=$(date -d  "${_date}   1days " +%Y%m%d)
           season_first_day=$(date -d  "${next_month_first_day}   3months ago " +%Y%m%d)
           pre_cycle_time=$(date -d  "${season_first_day}   1days ago " +%Y%m%d)
           ;;
     y)
            next_month_first_day=$(date -d  "${_date}   1days " +%Y%m%d)
            year_first_day=$(date -d  "${next_month_first_day}   12months ago " +%Y%m%d)
            pre_cycle_time=$(date -d  "${year_first_day}   1days ago " +%Y%m%d)
            ;;
     *)
          echo_error "get_pre_cycle_time wrong cycle";         
    esac     
}

source $includeFold/set_source.ini

function set_pre_variables()
{
  case $cycle in
    f|F)
	  DATE1=${shijian1:0:8}
	  HOUR1=${shijian1:8:2}
	  MINUTE1=${shijian1:10:2}
	  ;; 
    h)
          DATE1=${shijian1:0:8}
          HOUR1=${shijian1:8:2}  
	  ;;
    *)
          DATE1=${shijian1:0:8} ;;
  esac
     
}

#
# Exec function  by different "HEAD_FILE" 
#

function print_source_result()
{
   local _time=$1
   local _id=$2
   if [ "$muti" -ne 1 ];then
      if [[ -z $source_file ]] && [[ ${HEAD_FILE} != "npm_device_warning" ]] ;then
        return
      fi
   fi
   setGrepFile
   if [ "$top" -gt  0 ];then
       grepFile="$grepFile|head -n $top"
   fi
   source $includeFold/set_query_function.ini

}

function check_daylight_saving()
{
   _check_date=$1
   daylight_saving=0
   error_cnt=`date -d "$_check_date" +%s 2>&1|grep invalid|wc -l `
   if [  $error_cnt -eq 1 ] ;then
    daylight_saving=1
   fi

}

#
# If cycle is "h" and "-d" is true,then query 24 hours's data
#

function hour_detail_query()
{
   local t_time=$1;
   local t_timeValue=300
   local _time=""
   local last_time=""
   local str_param=""
   [ "$param" != "" ] && str_param=" -p $param" 
   if [[ $muti == 1 ]];then
     set_source_file  h  $t_time
     for((i=0;i<$servers_n;i++));do
     {
         ssh root@${servers[$i]}  \
           "/usr/local/functionlib/get_detail_file -H $detail_head_file  -c h -t $t_time -d -y $dataType $str_param" > ${muti_tmp_file}_${i}
      }&  
      done
      wait
      for((i=0;i<$servers_n;i++));do
      {
         if [ -s ${muti_tmp_file}_${i} ];then
            cat  ${muti_tmp_file}_${i} >> ${muti_tmp_file}
            rm -fr ${muti_tmp_file}_${i}
         fi  
      }   
      done
      if [  -z  $muti_tmp_file ];then
      rm -fr  ${muti_tmp_file}
          echo_error "there is   no data file  exists!"
      fi  
      print_source_result  $t_time $t_timeValue
  else
	    if [[ $cycle == "h" ]];then
      		 local mDATE=${t_time:0:8}
     		 local mHOUR=${t_time:8:2}
		fi
      for((sdate=0;sdate<$12;sdate++));do
	_minutes=$((5*sdate))	
        _time=$(date -d "$mDATE $mHOUR  ${_minutes}minutes " +"%Y%m%d%H%M");
        last_time=$(date -d "$mDATE $mHOUR  ${_minutes}minutes " +%s);
        set_source_file "f"  $_time
        print_source_result  $last_time  $t_timeValue
      done
 fi
}

#
# If cycle is "d" and "-d" is true,then query 24 hours's data
#

function day_detail_query()
{
   local t_time=$1;
   local t_timeValue=3600
   local _time=""
   local last_time=""
   local str_param=""
   [ "$param" != "" ] && str_param=" -p $param" 
   if [[ $muti == 1 ]];then
     set_source_file  d  $t_time
     for((i=0;i<$servers_n;i++));do
     {
         ssh root@${servers[$i]}  \
           "/usr/local/functionlib/get_detail_file -H $detail_head_file  -c d -t $t_time -d -y $dataType  $str_param" > ${muti_tmp_file}_${i}
      }&
      done
      wait
      for((i=0;i<$servers_n;i++));do
      {
         if [ -s ${muti_tmp_file}_${i} ];then
            cat  ${muti_tmp_file}_${i} >> ${muti_tmp_file}
            rm -fr ${muti_tmp_file}_${i}
         fi
      }
      done
      if [  -z  $muti_tmp_file ];then
	  rm -fr  ${muti_tmp_file}
          echo_error "there is   no data file  is not exists!"
      fi
      print_source_result  $t_time $t_timeValue
  else
      check_daylight_saving "$t_time"  
      if [[ "$detail_cycle" == "f" ]];then 
          if [ $daylight_saving -eq 0 ] ;then
             _tdate=$(date -d  "$t_time " "+%Y%m%d %H:%M")
             _max_cnt=276
          else
             _tdate=$(date -d  "$t_time 00:05" "+%Y%m%d %H:%M")
             _max_cnt=275
          fi
           t_timeValue=300  
             for((sdate=0;sdate<=$_max_cnt;sdate++));do
             _minutes=$((5*sdate))
             _time=$(date -d "$_tdate   ${_minutes}minutes " +"%Y%m%d%H%M");
            last_time=$(date -d "$_tdate  ${_minutes}minutes " +%s);
            set_source_file "f"  $_time
            print_source_result  $last_time  $t_timeValue
            done 
       else
          if [ $daylight_saving -eq 0 ] ;then
             _tdate=$(date -d  "$t_time " "+%Y%m%d %H:%M")
             _max_cnt=23
          else
             _tdate=$(date -d  "$t_time 01:00" "+%Y%m%d %H:%M")
             _max_cnt=22
          fi
         for((sdate=0;sdate<=$_max_cnt;sdate++));do
         _time=$(date -d "$_tdate  ${sdate}hours " +%Y%m%d%H);
         last_time=$(date -d "$_tdate ${sdate}hours " +%s);     
         set_source_file "h"  $_time
          print_source_result  $last_time  $t_timeValue 
         done
       fi
 fi
}



#
# If cycle is "w" and "-d" is true,then query 7 days's data
#

function week_detail_query()
{
   local  t_time=$1; 
   local  t_id=$2;
   local  _time="" 
   local  last_time=""
   local str_param=""
   [ "$param" != "" ] && str_param=" -p $param" 
   if [[ $muti == 1 ]];then
      set_source_file  w  $t_time
     for((i=0;i<$servers_n;i++));do
     {
         ssh root@${servers[$i]}  \
           "/usr/local/functionlib/get_detail_file -H $detail_head_file  -c w -t $t_time -d -y $dataType $str_param" > ${muti_tmp_file}_${i}
      }&
      done
      wait
      for((i=0;i<$servers_n;i++));do
      {
         if [ -s ${muti_tmp_file}_${i} ];then
            cat  ${muti_tmp_file}_${i} >> ${muti_tmp_file}
            rm -fr ${muti_tmp_file}_${i}
         fi
      }
      done
      if [  -z  $muti_tmp_file ];then
	   rm -fr ${muti_tmp_file}
          echo_error "there is   no data file  is not exists!"
      fi
      print_source_result  $t_time $t_id
   else
       for((sdate=6;sdate>=0;sdate--));do
       		_time=$(date -d "$t_time  ${sdate}days ago  " +%Y%m%d);
      		last_time=$(date -d "$t_time  ${sdate}days ago " +%s);
      		set_source_file "d"   $_time
      		print_source_result  $last_time $t_id
       done
  fi
}

#
# If cycle is "m" and "-d" is true,then query  the month days's data
#

function month_detail_query()
{
   local _time=""
   local last_time=""
   local str_param=""
   [ "$param" != "" ] && str_param=" -p $param"  
   local t_time=$1;
   local t_id=$2;
   local month_start=${t_time:0:6}"01";
   local month_start_date=$(date -d "$month_start  1days ago" +%s);
   local next_month=$(date -d "$month_start  1months  " +%Y%m%d);
   local month_end_date=$(date -d "$next_month  1days ago " +%s);
   month_day_count=$(((month_end_date-month_start_date)/86400-1))   
   if [[ $muti == 1 ]];then
       set_source_file  m  $t_time
     for((i=0;i<$servers_n;i++));do
     {
         ssh root@${servers[$i]}  \
           "/usr/local/functionlib/get_detail_file -H $detail_head_file  -c m -t $t_time -d -y $dataType $str_param" > ${muti_tmp_file}_${i}
      }&
      done
      wait
      for((i=0;i<$servers_n;i++));do
      {
         if [ -s ${muti_tmp_file}_${i} ];then
            cat  ${muti_tmp_file}_${i} >> ${muti_tmp_file}
            rm -fr ${muti_tmp_file}_${i}
         fi
      }
      done
      if [  -z  $muti_tmp_file ];then
	   rm -fr ${muti_tmp_file}
          echo_error "there is   no data file  is not exists!"
      fi
      print_source_result  $t_time $t_id
  else
   for((sdate="$month_day_count";sdate>=0;sdate--));do
      _time=$(date -d "${t_time}  ${sdate}days ago  " +%Y%m%d);
      last_time=$(date -d "$t_time  ${sdate}days ago " +%s);
      set_source_file "d"  $_time 
      print_source_result  $last_time  $t_id
   done
  fi
}

#
# If cycle is "s" and "-d" is true,then query the season days's data
#

function season_detail_query()
{
   
   local _time=""
   local last_time=""
   local str_param=""
   [ "$param" != "" ] && str_param=" -p $param" 
   local t_time=$1;
   local t_id=$2;
   local season_end_date=$(date -d "$t_time " +%s);
   local next_month_first_day=$(date -d "$t_time  1days  " +%Y%m%d);
   local season_first_day=$(date -d "$next_month_first_day  3months ago  " +%Y%m%d);
   local season_start_date=$(date -d "$season_first_day  1days ago" +%s);
   season_day_count=$(((season_end_date-season_start_date)/86400-1))
   if [[ $muti == 1 ]];then
      set_source_file  s  $t_time
     for((i=0;i<$servers_n;i++));do
     {
         ssh root@${servers[$i]}  \
           "/usr/local/functionlib/get_detail_file -H $detail_head_file  -c s -t $t_time -d -y $dataType $str_param" > ${muti_tmp_file}_${i}
      }&
      done
      wait
      for((i=0;i<$servers_n;i++));do
      {
         if [ -s ${muti_tmp_file}_${i} ];then
            cat  ${muti_tmp_file}_${i} >> ${muti_tmp_file}
            rm -fr ${muti_tmp_file}_${i}
         fi
      }
      done
      if [  -z  $muti_tmp_file ];then
	  rm -fr ${muti_tmp_file}
          echo_error "there is   no data file  is not exists!"
      fi
      print_source_result  $t_time $t_id
  else
   for((sdate="$season_day_count";sdate>=0;sdate--));do
      _time=$(date -d "${t_time}  ${sdate}days ago  " +%Y%m%d);
      last_time=$(date -d "$t_time  ${sdate}days ago " +%s);
      set_source_file "d"  $_time
      print_source_result  $last_time  $t_id
   done
  fi
}

#
# If cycle is "y" and "-d" is true,then query 12 months's data
#

function year_detail_query()
{
   local _time=""
   local last_time=""
   local str_param=""
   [ "$param" != "" ] && str_param=" -p $param" 
   local t_time=$1;
   local t_id=$2;

   year_next_day=$(date -d "$t_time  1days  " +%Y%m%d);

   if [[ $muti == 1 ]];then
      set_source_file  y  $t_time
     for((i=0;i<$servers_n;i++));do
     {
         ssh root@${servers[$i]}  \
           "/usr/local/functionlib/get_detail_file -H $detail_head_file  -c y -t $t_time -d -y $dataType $str_param" > ${muti_tmp_file}_${i}
      }&
      done
      wait
      for((i=0;i<$servers_n;i++));do
      {
         if [ -s ${muti_tmp_file}_${i} ];then
            cat  ${muti_tmp_file}_${i} >> ${muti_tmp_file}
            rm -fr ${muti_tmp_file}_${i}
         fi
      }
      done
      if [  -z  $muti_tmp_file ];then
	 rm -fr ${muti_tmp_file}
          echo_error "there is   no data file  is not exists!"
      fi
      print_source_result  $t_time $t_id
  else
   for((sdate=11;sdate>=0;sdate--));do
       last_month_first_day=$(date -d "$year_next_day  ${sdate}months ago " +%Y%m%d);
       _time=$(date -d "$last_month_first_day   1days ago " +%Y%m%d);
       last_time=$(date -d "$last_month_first_day   1days ago " +%s);
      set_source_file "m"  $_time
      print_source_result  $last_time  $t_id
   done
  fi
}

#
# For different cycle detail query
#
function query_cycle()
{
    local t_time=$1
    local t_id=$2
    case $cycle in 
      h)
	   hour_detail_query $t_time $t_id
	   ;;
      d)
       day_detail_query $t_time $t_id 
       ;;
     w)
       week_detail_query  $t_time $t_id
       ;;
     m)
       month_detail_query  $t_time $t_id
       ;;
    s)
       season_detail_query  $t_time $t_id
       ;;
    y)
       year_detail_query  $t_time $t_id
       ;;
    
  esac    
       
}
function query()
{
  set_pre_variables
  check_result_fold
  set_expr
  case $cycle in
	 f)
		 query_time=$(date -d "$DATE1 ${HOUR1}:${MINUTE1}" +%s) 
                 timeValue=300
                 ;;
	 h)
		 query_time=$(date -d "$DATE1 ${HOUR1}" +%s)  
                 timeValue=3600 
                 ;;
         d)
                 query_time=$(date -d "$DATE1  " +%s)   
                 myday=$(date  +%Y%m%d)
                 mysecond=$(date +%s)
                 if [[ "$myday" == "$DATE1" ]];then
                    timeValue=$((mysecond-query_time)) 
                 else
                    timeValue=86400
                 fi
                 ;;
  esac	    
  if [[ $detail == 0  ]];then
       set_source_file $cycle  $shijian1
       print_source_result  $query_time "$timeValue" 
  else
        query_cycle $shijian1  "$timeValue"
  fi 
}


function set_head_file()
{
     source $includeFold/set_query_head_file.ini 
}
function main()
{
  init_dataFold $dataType $ROOT_FOLD 
  init_zidianFold $language; 
  check_index;
  rm -fr  $muti_tmp_file
  if [ -s  $RESULT_FOLD/$FILE_NAME ];then
     start_row=$((PAGE_SIZE*(PAGE_NUM-1)+1))
     end_row=$((PAGE_SIZE*PAGE_NUM))
     if((csv == 1 ));then
	  set_head_file
          if((sort > 1 ));then
               cat $RESULT_FOLD/$FILE_NAME|awk -F ","  'BEGIN{OFS=" "}{$1=$1;print $0}'|sort  -n${rev} -k ${sort}\
		 |awk 'BEGIN{OFS=","}{$1=$1;print $0}'|cat  ${HEAD_FOLD}/${head_file} -
         else
                cat  ${HEAD_FOLD}/${head_file} $RESULT_FOLD/$FILE_NAME 
         fi 
	 exit 1
     fi 
     if ((count == 1 ));then
          rows_count="$(awk '{a+=1}END{print a}' $RESULT_FOLD/$FILE_NAME)"
          echo "[{\"rows_count\":$rows_count}]" 
     else
         set_head_file	  
	 if((sort > 1 ));then
          awk -F ","  -f ${AWK_FOLD}/csvtojson.awk  <(cat ${HEAD_FOLD}/${head_file} ) \
          	<(cat $RESULT_FOLD/$FILE_NAME|sed -r 's/\\//g'|awk -F ","  'BEGIN{OFS=" "}{$1=$1;print $0}'|sort  -n${rev} -k ${sort}\
                 |awk 'BEGIN{OFS=","}{$1=$1;print $0}'|sed -n "${start_row},${end_row}p"  ) |sed 's/,\(.\)$/\1/'
	 else
	   awk -F ","  -f ${AWK_FOLD}/csvtojson.awk  <(cat ${HEAD_FOLD}/${head_file} ) \
                <(sed -n "${start_row},${end_row}p;${end_row}q"  $RESULT_FOLD/$FILE_NAME|sed -r 's/\\//g' ) |sed 's/,\(.\)$/\1/'
         fi 
     fi	
  else
	 if ((count == 1 ));then
         	 echo "[{\"rows_count\":0}]"
    	 else
        	echo_error  "there is nodata between times";
	 fi
  fi
#  rm $RESULT_FOLD/$FILE_NAME;

}

get_option "$@"
main
