
Veewee::Definition.declare_yaml('definition.yml', :hooks => { :before_ssh => Proc.new { sleep 10 } })
