#!/usr/bin/awk -f
BEGIN {
  printf("%s","[");
}
{
        if (NR == 1){
               split($0, tags);
               if (EC == "") EC = "\"";
       }
        else {
               split($0, vals);
               jrec = "{";
               for (i = 1; i <= NF; ++i) {
               	                jrec = jrec EC tags[i] EC ":" EC vals[i] EC;
			if (i < NF) 
                           jrec = jrec ", ";
       	                 else
			   jrec = jrec "},"
		}
          printf("%s", jrec); 	
	}
}
END {
	printf("%s","]");
}
