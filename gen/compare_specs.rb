require 'rubygems'
require 'rspec'
require 'pry'

=begin
rspec ./gen/compare_specs.rb

Generates a list of all /spec/upstream/ specs and compares them to the
protractor/spec/ specs.

Uses regex to extract 'it' and 'do' from the JS and Ruby specs.
=end

describe 'compare ruby and protractor specs' do
  def ruby_to_js_rel path
    path.sub(ruby_protractor_spec_folder, '').sub(/\.rb\Z/, '.js')
  end

  def base_path
    @base_path ||= File.expand_path File.join(__dir__, '..')
  end

  def ruby_protractor_spec_folder
    @ruby_protractor_spec_folder ||= File.expand_path File.join(base_path, 'spec', 'upstream')
  end

  before :all do
    ruby_protractor_files = Dir.glob ruby_protractor_spec_folder + '/**/*.rb'
    ruby_protractor_files.map! &File.method(:expand_path)

    js_protractor_spec_folder = File.expand_path File.join(base_path, 'protractor/spec')

    # [[ruby_spec, js_spec]]
    spec_pairs                = []

    relative_paths = []

    # validate all Ruby protractor specs have matching JavaScript protractor specs
    ruby_protractor_files.each do |spec|
      rb_spec_relative = ruby_to_js_rel spec
      relative_paths << rb_spec_relative

      js_spec = File.join(js_protractor_spec_folder, rb_spec_relative)
      raise "Matching protractor spec does not exist\n#{js_spec}" unless File.exist?(js_spec)

      spec_pairs << [spec, js_spec]
    end

    @longest_rel_path = relative_paths.max_by(&:length).length

    @spec_pairs = spec_pairs
  end

  def longest_rel_path
    @longest_rel_path
  end

  def spec_pairs
    @spec_pairs
  end

  def js_keyword keyword
    /#{keyword}\W*\(\W*['|"](.*?)['|"]\W*,/
  end

  def ruby_keyword keyword
    /#{keyword}\W*['|"](.*?)['|"]\W*do/
  end

  def puts_array array
    indent = ' ' * 2
    puts indent + array.join("\n" + indent)
  end

  # Ruby specs must have the same describes as the JS files.
  it 'ruby and protractor specs have identical "describe" and "it"' do
    spec_pairs

    spec_pairs.each do |ruby_spec, js_spec|
      current_rel_path = ruby_to_js_rel(ruby_spec)
      print "#{current_rel_path}"
      js_spec        = File.read js_spec
      ruby_spec      = File.read ruby_spec

      # match 'describe'
      #
      # describe('ElementFinder', function() {
      describe       = 'describe'
      js_describes   = js_spec.scan(js_keyword describe).flatten
      # describe 'ElementFinder' do
      ruby_describes = ruby_spec.scan(ruby_keyword describe).flatten

      indent = ' ' * ((longest_rel_path - current_rel_path.length) + 1)
      desc_count = js_describes.length
      print "#{indent}describes: #{desc_count},#{' ' * (desc_count.to_s.length - 3).abs}"

      difference = js_describes - ruby_describes
      none       = []

      # redundant checks for more human readable rspec failure messages
      expect(difference).to eq(none)
      expect(js_describes.length).to eq(ruby_describes.length)

      # expect order to be the same
      js_describes.each_with_index do |expected, index|
        begin
          actual = ruby_describes[index]
          expect(actual).to eq(expected)
        rescue Exception
          puts_array js_describes
          raise
        end
      end

      # and they should be identical
      expect(js_describes).to eq(ruby_describes)

      # -- it

      # match 'it'
      #
      # it('should return the same result as browser.findElement', function() {
      it       = 'it'
      js_its   = js_spec.scan(js_keyword it).flatten
      # it 'should return the same result as browser.findElement' do
      ruby_its = ruby_spec.scan(ruby_keyword it).flatten

      puts "its: #{js_its.length}"

      difference = js_its - ruby_its

      # redundant checks for more human readable rspec failure messages
      expect(difference).to eq(none)
      expect(js_its.length).to eq(ruby_its.length)

      # expect order to be the same
      js_its.each_with_index do |expected, index|
        begin
          actual = ruby_its[index]
          expect(actual).to eq(expected)
        rescue Exception
          puts_array js_its
          raise
        end
      end

      # and they should be identical
      expect(js_its).to eq(ruby_its)
    end
  end
end
