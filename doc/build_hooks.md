# -- Build Hooks --

You can implement hooks in your machine definition to customize the build process.
The following hooks are currently available:

* `:before_create` before box is created
* `:after_create` after box is created
* `:after_up` after box is started
* `:after_boot_sequence` after boot command sequence is executed
* `:before_postinstall` before post-install files are executed
* `:after_postinstall` after post-install files are executed
* `:before_ssh` before each SSH login

The hooks are triggered in `lib/veewee/provider/core/box/build.rb`

* Hooks are defined under the `:hooks` key in the box definition hash in your `definition.rb`
* Hooks must be instances of `Proc` (or respond to `call`)

## -- Examples --

### -- Upload arbitrary files --

Sure you should use postinstall to copy and execute scripts.
But if you want to copy arbitrary files to the guest you can do this in a hook.

<pre>
Veewee::Definition.declare({
  :hooks => {
      :after_postinstall => Proc.new { definition.box.scp('/tmp/foo.txt', '/tmp/bar.txt') }
  }
})
</pre>

### -- Guarded SSH login --

SSH login is triggered from a separate Thread.
If SSH is available before the boot command sequence is finished
and the account password is changed in the command sequence authentication may fail.

Guarded SSH login using the `:before_ssh` hook:

<pre>
class MyHooks
  def initialize(definition)
    @definition = definition
  end

  def after_boot_sequence
    puts "unlocked ssh. port is #{@definition.ssh_host_port}"
    @ssh_enabled = true
  end

  def before_ssh
    sleep 0.5 until @ssh_enabled
  end
end

myhooks = Hooks.new(veewee_definition)

Veewee::Definition.declare({
  :hooks => {
      :after_boot_sequence => Proc.new { myhooks.after_boot_sequence },
      :before_ssh => Proc.new { myhooks.before_ssh }
  }
})
</pre>




