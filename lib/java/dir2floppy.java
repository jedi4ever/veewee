package be.jedi.dir2floppy;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;

import de.waldheinz.fs.FileSystem;
import de.waldheinz.fs.FsDirectoryEntry;
import de.waldheinz.fs.FsFile;
import de.waldheinz.fs.fat.SuperFloppyFormatter;
import de.waldheinz.fs.util.FileDisk;

/**
 * Hello world!
 *
 */
public class Dir2Floppy 
{
    public static void main( String[] args )
    {
    	if (args.length < 2) {
    		System.out.println("Usage: java -jar dir2floppy.jar <sourcedir> <floppyfile>");
    		System.exit(-1);
    	}
 
    	FileDisk device = null;

    	//Create the floppy
    	try {
            device = FileDisk.create(new File(args[1]),(long)1440 * 1024);
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            System.exit(-1);
        }

        //Format the floppy
        FileSystem fs=null;
        try {
            fs = SuperFloppyFormatter.get(device).format();
 
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            System.exit(-1);

        }

        //Iterate of directories
        File dir = new File(args[0]);

        String[] children = dir.list();
        if (children == null) {
            // Either dir does not exist or is not a directory
        	System.out.println("Error. does the directory exist?");
        	System.exit(-1);        	
        } else {
            for (int i=0; i<children.length; i++) {
                // Get filename of file or directory
            	File aFile=new File(dir.getAbsolutePath()+System.getProperty("file.separator")+children[i]);
            	
        	    try {        	
            	// Create the entry on the floppy
                FsDirectoryEntry floppyEntry = fs.getRoot().addFile(children[i]);
                //floppyEntry.setName(children[i]);
                System.out.print("- Processing file: "+children[i]+" ");
                
                FsFile floppyfile = floppyEntry.getFile();
            	
            	// Copy the file over                
            	if (aFile.isFile()) {
            		FileInputStream fis= new FileInputStream(aFile);
            		
            		FileChannel fci = fis.getChannel();
            		ByteBuffer buffer = ByteBuffer.allocate(1024);
            		
            		long counter=0;
            	    int len;
            	    
            	 //   http://www.kodejava.org/examples/49.html
            	 // Here we start to read the source file and write it
                    // to the destination file. We repeat this process
                    // until the read method of input stream channel return
                    // nothing (-1).
                    while(true)
                    {
                        // read a block of data and put it in the buffer
                        int read = fci.read(buffer);

                        // did we reach the end of the channel? if yes
                        // jump out the while-loop
                        if (read == -1)
                            break;

                        // flip the buffer
                        buffer.flip();

                        // write to the destination channel
          	    	  System.out.print(".");
                      floppyfile.write(counter*1024, buffer);
                      counter++;

                        
                        // clear the buffer and user it for the next read
                        // process
                        buffer.clear();
                    }
                    System.out.println();
                    
            	      floppyfile.flush();

						fis.close();
            	}
				} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
				
            	}
 
            }
        }


        try {
			fs.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
        System.out.println( "Done" );
    }
    
}

