module Veewee  
  module Builder
    module Core
      module BuilderCommand
        def build(definition_name,box_name,options)
      
          # If no box_name was given, let's give the box the same name as the definition
          if box_name.nil?
            box_name=definition_name
          end
          
          env.ui.info "building #{definition_name} #{box_name} #{options}"
          
          definition=get_definition(definition_name)
          box=get_box(box_name)

          if box.exists?
            # check if --force option was given
            if option[:force]==true
              box.destroy
            else
              env.ui.error "you need to provide --force because the box #{box_name} already exists"
            end            
          end
          
          # By now the box should have been gone, just checking again
          box=get_box(box_name)
          if box.exists?
            env.ui.error "The box should have been deleted by now. Something went terribly wrong. Sorry"            
          end
          
          box.assemble(definition)          
          
        end
      end
    end
  end
end