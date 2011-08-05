def reload_network
  When you recreate machines often and maybe some of the parts of the script fail, I found it useful to restart the VMWare Fusion network 

  <% codify (:shell) do %>
  sudo sh -c "/Library/Application\ Support/VMware\ Fusion/boot.sh --restart"
  <% end %>
  
end
