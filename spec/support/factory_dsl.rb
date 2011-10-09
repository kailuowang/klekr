class Fixnum
  def pics
    self.times.map do
      Factory.next(:pic_info)
    end
  end

  def pictures(opts = {})
    self.times.map do
      Factory(:picture, opts)
    end
  end
  alias :pic :pics
end
