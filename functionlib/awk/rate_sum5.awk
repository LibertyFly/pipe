#!/usr/bin/awk -f
BEGIN {
}
{
    if(key_cnt==1){
        key=$1
        rate_key=1
    }else 
    if(key_cnt==2){
        key=$1","$2
        rate_key=$1
    }else
     if(key_cnt==3){
          key=$1","$2","$3 
          rate_key=$1","$2
    }else
    if(key_cnt==4){
          key=$1","$2","$3","$4
          rate_key=$1","$2","$3
    }else
    if(key_cnt==5){
          key=$1","$2","$3","$4","$5
          rate_key=$1","$2","$3","$4
    }else
    if(key_cnt==6){
          key=$1","$2","$3","$4","$5","$6
          rate_key=$1","$2","$3","$4","$5
    }
    sum1[key]+=$(key_cnt+1);
    sum2[key]+=$(key_cnt+2); 
    sum3[key]+=$(key_cnt+3);
    sum4[key]+=$(key_cnt+4);
    sum5[key]+=$(key_cnt+5);
       if(rate_col==1){sum[key]=sum1[key]; rate_sum[rate_key]+=$(key_cnt+1)}
    else 
    if(rate_col==2){sum[key]=sum2[key];rate_sum[rate_key]+=$(key_cnt+2)}
    else
     if(rate_col==3){sum[key]=sum3[key];rate_sum[rate_key]+=$(key_cnt+3)}
    else
    if(rate_col==4){sum[key]=sum4[key];rate_sum[rate_key]+=$(key_cnt+4)}
    else
    if(rate_col==5){sum[key]=sum5[key];rate_sum[rate_key]+=$(key_cnt+5)} 
}
END {
  if(key_cnt==1)
   {   
      for(i in sum4){
        printf("%s %d %d %d %d %d %.6f\n",i,sum1[i],sum2[i],sum3[i],sum4[i],sum5[i],sum[i]==0?0:sum[i]g/rate_sum[1])
      }   
   }else
  if(key_cnt==2)
   {  
      for(i in sum4){
        split(i,myarray,",");
        printf("%s %s %d %d %d %d %d %.6f\n", myarray[1],myarray[2],sum1[i],sum2[i],sum3[i],sum4[i],sum5[i],sum[i]==0?0:sum[i]g/rate_sum[myarray[1]])
      }
   }else if(key_cnt==3)
   {  
      for(i in sum4){
        split(i,myarray,",");
        printf("%s %s %s %d %d %d %d %d %.6f\n", myarray[1],myarray[2],myarray[3],sum1[i],sum2[i],sum3[i],sum4[i],sum5[i],sum[i]==0?0:sum[i]g/rate_sum[myarray[1]","myarray[2]])
      }
  } else if(key_cnt==4)
  {
        for(i in sum4){
        split(i,myarray,",");
        printf("%s %s %s %s %d %d %d %d %d %.6f\n", myarray[1],myarray[2],myarray[3],myarray[4],sum1[i],sum2[i],sum3[i],sum4[i],sum5[i],sum[i]==0?0:sum[i]g/rate_sum[myarray[1]","myarray[2]","myarray[3]])
      }
  } else if(key_cnt==5)
  {
        for(i in sum4){
        split(i,myarray,",");
        printf("%s %s %s %s %s %d %d %d %d %d %.6f\n", myarray[1],myarray[2],myarray[3],myarray[4],myarray[5],sum1[i],sum2[i],sum3[i],sum4[i],sum5[i],sum[i]==0?0:sum[i]g/rate_sum[myarray[1]","myarray[2]","myarray[3]","myarray[4]])
      }
   }else if(key_cnt==6)
  {
        for(i in sum4){
        split(i,myarray,",");
        printf("%s %s %s %s %s %s %d %d %d %d %d %.6f\n", myarray[1],myarray[2],myarray[3],myarray[4],myarray[5],myarray[6],sum1[i],sum2[i],sum3[i],sum4[i],sum5[i],sum[i]==0?0:sum[i]g/rate_sum[myarray[1]","myarray[2]","myarray[3]","myarray[4]","myarray[5]])
      }   
   }
}   
