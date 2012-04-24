class Fixnum
  def pics
    self.times.map do
       FactoryGirl.generate(:pic_info)
    end
  end

  def pictures(opts = {})
    self.times.map do
      FactoryGirl.create(:picture, opts)
    end
  end
  alias :pic :pics
end
