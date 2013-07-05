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
    # Public: creates a new Snp::TemplateContext object.
    #
    # context - a hash of properties and values to be used in as context of the template.
    #
    # The hash is used so that the resulting object responds to each key in `context`,
    # returning the accoring value.
    def initialize(context)
      @context = context

      context.each do |property, value|
        define_property(property, value)
      end
    end

    def respond_to_missing?(method, *)
      @context.has_key?(method)
    end

    private

    # Internal: defines a method with `property` name, and returning `value`.
    def define_property(property, value)
      define_singleton_method(property) { value }
    end
  end
end
