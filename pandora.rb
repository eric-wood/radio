# pandora.rb
# Pandora interface!
# Makes liberal use of Pianobar: http://6xq.net/projects/pianobar/
#

class Pandora
  def initialize
    # Start pianobar
    `pianobar`
  end
end
