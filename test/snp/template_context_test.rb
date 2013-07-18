require 'test_helper'

describe Snp::TemplateContext do
  it 'responds to methods passed as hash' do
    context = Snp::TemplateContext.new(greeting: 'Hello', name: 'snp')
    context.greeting.must_equal 'Hello'
    context.name.must_equal 'snp'
  end

  it 'generates predicate methods for boolean attributes' do
    context = Snp::TemplateContext.new(awesome: true, sad: false)
    context.awesome?.must_equal true
    context.sad?.must_equal false
  end

  it 'politely responds to methods named after context keys' do
    context = Snp::TemplateContext.new(snp: 'snp')
    context.must_respond_to(:snp)
  end

  it 'raises proper error when called with non-existing property' do
    context = Snp::TemplateContext.new(snp: 'snp')
    lambda {
      context.invalid_property
    }.must_raise(Snp::TemplateContext::InsufficientContext)
  end
end
