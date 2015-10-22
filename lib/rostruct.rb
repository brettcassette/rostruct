require "active_support/core_ext/hash/indifferent_access"

class ROstruct
  def initialize(options = {})
    @as_hash = options.with_indifferent_access

    options.each do |key, value|
      if value.is_a?(Hash)
        value = ROStruct.new(value)
      end

      send("#{key}=", value)
    end
  end

  def to_h
    @as_hash
  end

  private

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.include?("=") || super
  end

  def eigenclass
    class << self
      self
    end
  end

  def method_missing(method_name, *args, &block)
    if method_name.to_s.include?("=")
      method_name = method_name.to_s.gsub(/\=/) {}

      eigenclass.send :define_method, method_name do
        instance_variable_get("@#{method_name}")
      end

      eigenclass.send :define_method, "#{method_name}=" do |value|
        instance_variable_set("@#{method_name}", value)
      end

      send("#{method_name}=", *args, &block)
    else
      nil
    end
  end
end
