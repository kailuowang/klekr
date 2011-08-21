class Fixnum
  def pics
    self.times.map do
      Factory.next(:pic_info)
    end
  end
  alias :pic :pics
end
