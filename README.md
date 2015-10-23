
	 
	
# Greenplum Database Sandbox Builder
<img src="https://raw.githubusercontent.com/dbbaskette/gpdb-sandbox/gh-pages/images/Sandman_(William_Baker).JPG?token=ACbVkUI1WnnUpyJAOIAZbDH4AHJsBj63ks5WM91-wA%3D%3D" width="300">  
Packer-Based Virtual Appliance Build Tool for the Greenplum Database
Requirements:  
* Packer  
* Virtual Box   
* Greenplum Database Binaries  
* Greenplum Command Center Binaries  
* MADLib Binaries  
* PL/R, PL/Perl, PL/Java Binaries  
* Apache Zepplin Binaries (tar ball)  

Modifications Required:  
			
  * Change the following entry in the gpdb-sandbox.json file to point to the 
  	 absolute path of the directory where you have stored the binaries.  Make
  	 sure and end the "source"	entry with a /.   This keeps the directory
  	 structure the tool is expecting intact.	 

        {
              "type": "file",   
              "source": "/Users/dbaskette/Software/GREENPLUM/",   
              "destination": "/tmp/bins/"  
        }
        

 
1) Install Packer  
2) Clone Repo  
3) Modify json to point to binary location  
4) execute: `packer build -force gpdb-sandbox.json`  or to build either vbox or vmware add "-only=vbox" or "-only=vmware"

This will generate the OVA which can then be imported into VirtualBox, and/or a zip file for use with VMware

