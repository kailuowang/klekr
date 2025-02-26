# Ruby >= 2.4 uses Integer instead of Fixnum
class Integer
  def pics
    self.times.map do
       FactoryBot.generate(:pic_info)
    end
  end

  def pictures(opts = {})
    self.times.map do
      FactoryBot.create(:picture, opts)
    end
  end
  alias :pic :pics
end
