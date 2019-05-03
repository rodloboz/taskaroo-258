require_relative 'record'

class Task < Record
  def done?
    @done == 1
  end
end
