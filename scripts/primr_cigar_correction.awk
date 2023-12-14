#!/usr/bin/awk -f

BEGIN {
    FS = "\t"
    OFS = "\t"
}

# Skip over header lines (lines that start with "@")
/^@/ {
    print
    next
}

{
    # Collect the CIGAR string from column 6
    cigar = $6

    # Parse the CIGAR string to get the different operations 
    num_ops = split(cigar, ops, /[0-9]/)  # GET letters

    # Remove empty elements in ops
    j=1
    for (i=1; i<=length(ops); i++) {
       if (ops[i]!=""){
          clean_ops[j] = ops[i]
	  j++
	}
    }
 
    # Parse the CIGAR string to get the number of soft-clipped bases
    num_counts = split(cigar, counts, /[^0-9]/) # GET numbers

    for (i=1; i<=length(counts); i++) {
       if (counts[i]==""){
          counts[i] = 0
        }
    }    
	
    leading_clip = 0
    trailing_clip = 0
    num_match = 0
    num_ins = 0
    num_del = 0
    num_int = 0
    
    j=1
    for (i = 1; i <= length(clean_ops); i++) {
	count = counts[j]
        op = clean_ops[i]
        
        if (op == "S" && i == 1) {
	   leading_clip += count

        } else if (op == "S" && i > 1) {
            trailing_clip += count
 
        } else if (op == "M") {
            num_match += count

        } else if (op == "I") {
            num_ins += count

        } else if (op == "D") {
            num_del += count

        } else if (op == "N") {
            num_int += count
        }
    j+=1
    }

    # Final Output columns    
    chr = $3
	
    # Subtract the number of soft-clipped bases at the beginning from the position 
    pos = $4 - leading_clip   

    # Add the number of soft-clipped bases at the end to the end position 
    end_pos = $4 + num_match + trailing_clip + num_int - 1

    qname = $1
    
    flag = $2
    

    # Output the modified BAM record
     print chr, pos, end_pos, qname, flag, cigar
#     print cigar " - " leading_clip "S" num_match "M" trailing_clip "S" num_ins "I" num_del "D" num_int "N"
}
