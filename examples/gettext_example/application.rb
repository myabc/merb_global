class GettextExample < Merb::Controller
  language do
    'pl' # It'll be always in Polish
  end
  def index
    _('Hi! Hello world!')
  end
end
