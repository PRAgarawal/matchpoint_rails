module RestfulHelper
  def rename_params_for_nested_attributes(klass, params)
    klass.nested_attributes_options.keys.each do |klass_symbol|
      rename_param(klass_symbol, klass, params)
    end
    params
  end

  # klass_symbol is the symbol for the nested attribute.
  # parent_klass is the class that has klass_symbol as a nested attribute
  def rename_param(klass_symbol, parent_klass, params)
    name = klass_symbol.to_s
    klass = symbol_to_constant_class(klass_symbol, parent_klass)

    # This occurs if there are multiple nested attributes with the same name
    if params.is_a? Array
      params.each do |element|
        rename_param(name, parent_klass, element)
      end
    elsif not params[name].nil?
      content = params.delete name
      renamed = "#{name}_attributes"
      klass.nested_attributes_options.keys.each do |nested_klass_symbol|

        rename_param(nested_klass_symbol, klass, content)
      end

      params[renamed] = content
    end
  end


  # Changes a symbol into a class
  def symbol_to_constant_class(symbol, parent_class)
    name = symbol.to_s
    # If the classified version of the symbol is defined, then it has a model and can be made into a constant
    if Object.const_defined?(name.singularize.classify)
      name.singularize.classify.constantize
    else
      # If it isn't defined, this means that the attribute is a renamed version of a class
      parent_class.reflect_on_all_associations.each do |assoc|
        if assoc.name.to_s == name
          return assoc.class_name.classify.constantize
        end
      end
    end
  end

  # Put all nested objects in a hash on the same level.
  # e.g. flatten_hash({a: 1, b: {c: 2}}) -> {a: 1, b-c: 2}
  def flatten_hash(hash, parent_prefix = nil)
    res = {}

    hash.each_with_index do |elem, i|
      if elem.is_a?(Array)
        k, v = elem
      else
        k, v = i, elem
      end

      # assign key name for result hash
      key = parent_prefix ? "#{parent_prefix}-#{k}" : k

      if v.is_a? Enumerable
        # recursive call to flatten child elements
        res.merge!(flatten_hash(v, key))
      else
        res[key] = v
      end
    end

    res
  end
end
