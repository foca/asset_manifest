require "asset_manifest"
require "nokogiri"

# Check whether two HTML elements are equal, regardless of the order of their
# attributes or details like that.
def assert_html(exp, act, err = "#{exp.inspect} != #{act.inspect}")
  exp = Nokogiri(exp).root
  act = Nokogiri(act).root
  assert Hexp::Nokogiri::Equality.new(exp, act).call, err
end

# Copyright (c) 2013-2014 Arne Brasseur
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
module Hexp
  module Nokogiri
    # Used in test to see if two Nokogiri objects have the same content,
    # i.e. are equivalent as far as we are concerned
    #
    class Equality
      CLASSES = [
        ::Nokogiri::HTML::Document,
        ::Nokogiri::HTML::DocumentFragment,
        ::Nokogiri::XML::Document,
        ::Nokogiri::XML::Node,
        ::Nokogiri::XML::Text,
        ::Nokogiri::XML::Element,
        ::Nokogiri::XML::DocumentFragment,
        ::Nokogiri::XML::DTD,
      ]

      def initialize(this, that)
        @this, @that = this, that
        [this, that].each do |input|
          raise "#{input.class} is not a Nokogiri element." unless CLASSES.include?(input.class)
        end
      end

      def call
        [ equal_class?,
          equal_name?,
          equal_children?,
          equal_attributes?,
          equal_text? ].all?
      end

      def equal_class?
        @this.class == @that.class
      end

      def equal_name?
        @this.name == @that.name
      end

      def equal_children?
        return true unless @this.respond_to? :children
        @this.children.count == @that.children.count &&
          compare_children.all?
      end

      def compare_children
        @this.children.map.with_index do |child, idx|
          self.class.new(child, @that.children[idx]).call
        end
      end

      def equal_attributes?
        return true unless @this.respond_to? :attributes
        @this.attributes.keys.all? do |key|
          @this[key] == @that[key]
        end
      end

      def equal_text?
        return true unless @this.instance_of?(::Nokogiri::XML::Text)
        @this.text == @that.text
      end
    end
  end
end
