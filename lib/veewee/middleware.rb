class BaseBoxMiddleware
  def initialize(app, env)
    @app = app
  end

  def call(env)
    env["ui"].info "Hello!"
    @app.call(env)
  end
end