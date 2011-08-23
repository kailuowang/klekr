class Fixnum
  def pics
    self.times.map do
      Factory.next(:pic_info)
    end
  end

  def pictures
    self.times.map do
      Factory(:picture)
    end
  end
  alias :pic :pics
end
