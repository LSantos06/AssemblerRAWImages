.data  
fin: .asciiz "teste.txt"      # filename for input
FODA: .space 1

.text
#open a file for writing
li   $v0, 13       # system call for open file
la   $a0, fin      # board file name
li   $a1, 0        # Open for reading
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor 

#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor 
la   $a1, FODA   # address of buffer to which to read
li   $a2, 1	   # hardcoded buffer length
syscall            # read from file

# Close the file 
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall            # close file

