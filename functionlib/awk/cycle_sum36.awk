#!/usr/bin/awk -f
BEGIN {
}
{
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
    }    
    sum1[key]+=$(key_cnt+1);
    sum2[key]+=$(key_cnt+2);
    sum3[key]+=$(key_cnt+3);
    sum4[key]+=$(key_cnt+4);
    sum5[key]+=$(key_cnt+5);
    sum6[key]+=$(key_cnt+6);
    sum7[key]+=$(key_cnt+7);
 sum8[key]+=$(key_cnt+8);			
 sum9[key]+=$(key_cnt+9);			
 sum10[key]+=$(key_cnt+10);		
 sum11[key]+=$(key_cnt+11);		
 sum12[key]+=$(key_cnt+12);		
 sum13[key]+=$(key_cnt+13);		
 sum14[key]+=$(key_cnt+14);		
 sum15[key]+=$(key_cnt+15);		
 sum16[key]+=$(key_cnt+16);		
 sum17[key]+=$(key_cnt+17);		
 sum18[key]+=$(key_cnt+18);		
 sum19[key]+=$(key_cnt+19);
 sum20[key]+=$(key_cnt+20);
 sum21[key]+=$(key_cnt+21);
 sum22[key]+=$(key_cnt+22);
 sum23[key]+=$(key_cnt+23);
 sum24[key]+=$(key_cnt+24);
 sum25[key]+=$(key_cnt+25);
 sum26[key]+=$(key_cnt+26);
 sum27[key]+=$(key_cnt+27);
 sum28[key]+=$(key_cnt+28);
 sum29[key]+=$(key_cnt+29);
 sum30[key]+=$(key_cnt+30);
 sum31[key]+=$(key_cnt+31);
 sum32[key]+=$(key_cnt+32);
 sum33[key]+=$(key_cnt+33);
 sum34[key]+=$(key_cnt+34);
 sum35[key]+=$(key_cnt+35);
 sum36[key]+=$(key_cnt+36);
    
}
END {
  if(key_cnt==1)
   {
      for(i in sum4){
        printf("%s %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d \n", i,sum1[i],sum2[i],sum3[i],sum4[i],sum5[i],sum6[i],sum7[i],sum8[i],sum9[i],sum10[i],sum11[i],sum12[i],sum13[i],sum14[i],sum15[i],sum16[i],sum17[i],sum18[i],sum19[i],sum20[i],sum21[i],sum22[i],sum23[i],sum24[i],sum25[i],sum26[i],sum27[i],sum28[i],sum29[i],sum30[i],sum31[i],sum32[i],sum33[i],sum34[i],sum35[i],sum36[i])
      }
   }else 
  if(key_cnt==2)
   {  
      for(i in sum4){
        split(i,myarray,",");
        printf("%s %s %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d \n", myarray[1],myarray[2],sum1[i],sum2[i],sum3[i],sum4[i],sum5[i],sum6[i],sum7[i],sum8[i],sum9[i],sum10[i],sum11[i],sum12[i],sum13[i],sum14[i],sum15[i],sum16[i],sum17[i],sum18[i],sum19[i],sum20[i],sum21[i],sum22[i],sum23[i],sum24[i],sum25[i],sum26[i],sum27[i],sum28[i],sum29[i],sum30[i],sum31[i],sum32[i],sum33[i],sum34[i],sum35[i],sum36[i])
      }
   }else if(key_cnt==3)
   {  
      for(i in sum4){
        split(i,myarray,",");
        printf("%s %s %s %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d \n", myarray[1],myarray[2],myarray[3],sum1[i],sum2[i],sum3[i],sum4[i],sum5[i],sum6[i],sum7[i],sum8[i],sum9[i],sum10[i],sum11[i],sum12[i],sum13[i],sum14[i],sum15[i],sum16[i],sum17[i],sum18[i],sum19[i],sum20[i],sum21[i],sum22[i],sum23[i],sum24[i],sum25[i],sum26[i],sum27[i],sum28[i],sum29[i],sum30[i],sum31[i],sum32[i],sum33[i],sum34[i],sum35[i],sum36[i])
      }
  } else if(key_cnt==4)
  {
        for(i in sum4){
        split(i,myarray,",");
        printf("%s %s %s %s %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d \n", myarray[1],myarray[2],myarray[3],myarray[4],sum1[i],sum2[i],sum3[i],sum4[i],sum5[i],sum6[i],sum7[i],sum8[i],sum9[i],sum10[i],sum11[i],sum12[i],sum13[i],sum14[i],sum15[i],sum16[i],sum17[i],sum18[i],sum19[i],sum20[i],sum21[i],sum22[i],sum23[i],sum24[i],sum25[i],sum26[i],sum27[i],sum28[i],sum29[i],sum30[i],sum31[i],sum32[i],sum33[i],sum34[i],sum35[i],sum36[i])
      }
  } else if(key_cnt==5)
  {
        for(i in sum4){
        split(i,myarray,",");
        printf("%s %s %s %s %s %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d \n", myarray[1],myarray[2],myarray[3],myarray[4],myarray[5],sum1[i],sum2[i],sum3[i],sum4[i],sum5[i],sum6[i],sum7[i],sum8[i],sum9[i],sum10[i],sum11[i],sum12[i],sum13[i],sum14[i],sum15[i],sum16[i],sum17[i],sum18[i],sum19[i],sum20[i],sum21[i],sum22[i],sum23[i],sum24[i],sum25[i],sum26[i],sum27[i],sum28[i],sum29[i],sum30[i],sum31[i],sum32[i],sum33[i],sum34[i],sum35[i],sum36[i])
      }
   }
}   
