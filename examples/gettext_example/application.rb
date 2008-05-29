class GettextExample < Merb::Controller
  def index
    _('Hi! Hello world!')
  end
end
