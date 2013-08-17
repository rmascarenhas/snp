module Snp
  # Snp::TemplateContext
  #
  # This class aims to represent the context in which a snippet template is
  # compiled. It receives a hash of keys and values that act as properties to be
  # used in the template. For example, if you have a template with the content:
  #
  #   <html>
  #     <head><title><%= title %></title></head>
  #   </html>
  #
  # Then a proper context for this snippet compilation would be:
  #
  #   TemplateContext.for(title: 'My beautiful page')
  class TemplateContext
    class InsufficientContext < StandardError
      attr_reader :missing_property

      def initialize(property)
        @missing_property = property.to_s
        super
      end
    end

    # Public: returns the binding for the passed `attributes`.
    def self.for(attributes)
      new(attributes).erb_binding
    end

    # Public: creates a new Snp::TemplateContext object.
    #
    # context - a hash of properties and values to be used in as context of the template.
    #
    # The hash is used so that the resulting object responds to each key in `context`,
    # returning the accoring value.
    def initialize(context)
      @context = context

      context.each do |property, value|
        method_name = prepare(property)
        define_property(method_name, value)
      end
    end

    def erb_binding
      binding
    end

    def respond_to_missing?(method, *)
      @context.has_key?(method)
    end

    # In case an unknown method is called on the template context, we raise a proper
    # exception that must be rescued and properly handled.
    #
    # Reaching this point means we need variables in the snippet that were not provided.
    def method_missing(method, *)
      raise InsufficientContext.new(method)
    end

    private

    # Internal: returns a propperty name with underscores where dashes were present.
    #
    # name - the property name.
    #
    # Examples
    #
    #   prepare('name')       # => 'name'
    #   prepare('update-ref') # => 'update_ref'
    def prepare(name)
      name.to_s.gsub('-', '_')
    end

    # Internal: defines a method with `property` name, and returning `value`.
    # If `value` is a boolean, this method will also define a predicate method.
    def define_property(property, value)
      define_singleton_method(property) { value }

      if value == true || value == false
        define_singleton_method("#{property}?") { value }
      end
    end
  end
end
