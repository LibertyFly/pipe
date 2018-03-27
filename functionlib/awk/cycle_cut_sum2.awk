#!/usr/bin/awk -f
BEGIN {
  counter=0
  }
{
   if(key_cnt==0)
    {
      key=1
    }else
    if(key_cnt==1){
        key=$1
    }else
    if(key_cnt==2){
        key=$1","$2
    }else
     if(key_cnt==3){
          key=$1","$2","$3
    }else
    if(key_cnt==4){
          key=$1","$2","$3","$4
    }else
    if(key_cnt==5){
          key=$1","$2","$3","$4","$5
    }else
    if(key_cnt==6){
          key=$1","$2","$3","$4","$5","$6
    }

    if(sum1[key]=="")
    {
      if(counter==count)
      {
          delete sum1[key]
          printResult()
          counter=0
          delete sum1
          delete sum2
      }
      counter++
    }
    sum1[key]+=$(key_cnt+1); 
    sum2[key]+=$(key_cnt+2)
 } 
END {
   printResult()
}
function printResult()
{
 if(key_cnt==0)
   {   
        for(i in sum1){
        printf("%d %d\n", sum1[i],sum2[i])
       }
   }else 
  if(key_cnt==1)
   {   
      for(i in sum1){
        printf("%s %d %d\n", i,sum1[i],sum2[i])
      }   
   }else 
  if(key_cnt==2)
   {  
      for(i in sum1){
        split(i,myarray,",");
        printf("%s %s %d %d\n", myarray[1],myarray[2],sum1[i],sum2[i])
      }
   }else if(key_cnt==3)
   {  
      for(i in sum1){
        split(i,myarray,",");
        printf("%s %s %s %d %d\n", myarray[1],myarray[2],myarray[3],sum1[i],sum2[i])
      }
  } else if(key_cnt==4)
  {
        for(i in sum1){
        split(i,myarray,",");
        printf("%s %s %s %s %d %d\n", myarray[1],myarray[2],myarray[3],myarray[4],sum1[i],sum2[i])
      }
  }else if(key_cnt==5)
  {
        for(i in sum1){
        split(i,myarray,",");
        printf("%s %s %s %s %s %d %d\n", myarray[1],myarray[2],myarray[3],myarray[4],myarray[5],sum1[i],sum2[i])
      }
  }else if(key_cnt==6)
  {
        for(i in sum1){
        split(i,myarray,",");
        printf("%s %s %s %s %s %s %d %d\n", myarray[1],myarray[2],myarray[3],myarray[4],myarray[5],myarray[6],sum1[i],sum2[i])
      }
   }
}


