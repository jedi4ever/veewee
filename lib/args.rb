# quit unless our script gets two command line arguments
unless ARGV.length == 2
   puts "Dude, not the right number of arguments."
     puts "Usage: ruby MyScript.rb InputFile.csv SortedOutputFile.csv\n"


     # our input file should be the first command line arg
      input_file = ARGV[0]
     #
     # # our output file should be the second command line arg
      output_file = ARGV[1]
end
