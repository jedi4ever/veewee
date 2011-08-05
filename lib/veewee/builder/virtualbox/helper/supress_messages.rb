module Veewee
  module Builder
    module Virtualbox
       def suppress_messages
         #Setting this annoying messages to register
         VirtualBox::ExtraData.global["GUI/RegistrationData"]="triesLeft=0"
         VirtualBox::ExtraData.global["GUI/UpdateDate"]="1 d, 2009-09-20"
         VirtualBox::ExtraData.global["GUI/SuppressMessages"]="confirmInputCapture,remindAboutAutoCapture,remindAboutMouseIntegrationOff"
         VirtualBox::ExtraData.global["GUI/UpdateCheckCount"]="60"
         update_date=Time.now+86400
         VirtualBox::ExtraData.global["GUI/UpdateDate"]="1 d, #{update_date.year}-#{update_date.month}-#{update_date.day}, stable"
         VirtualBox::ExtraData.global.save
       end
     end
   end
 end