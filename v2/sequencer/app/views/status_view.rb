require 'view'

class StatusView < View
  
  def initialize(app, parent, layout = {})
    @app = app
    @app.add_observer(self)
    super(parent, layout)
  end

  def update
  end
end
