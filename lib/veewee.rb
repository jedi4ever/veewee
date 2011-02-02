class VeeweeCommand < Vagrant::Command::GroupBase
  register "veewee", "creates boxes"

  desc "hello", "Says hello"
  def hello
    puts "HELLO!"
  end

  desc "goodbye", "Says goodbye"
  def goodbye
    puts "GOODBYE!"
  end
end
