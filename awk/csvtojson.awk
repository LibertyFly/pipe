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
	                if ((vals[i] ~ /^[0-9]$/)||(vals[i] ~ /^[1-9][0-9]+$/) || (vals[i] ~/^[0-9]+\.[0-9]+$/))
                                jrec = jrec EC tags[i] EC ":" vals[i];
                        else
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
