module Kernel
  def enum(values)
    Module.new do |mod|
      values.each_with_index{ |v,i| mod.const_set(v, i) }
    end
  end
end
