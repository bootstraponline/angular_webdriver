require 'rubygems'
require 'rspec'
require 'pry'

=begin
rspec ./gen/compare_specs.rb
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

    # validate all Ruby protractor specs have matching JavaScript protractor specs
    ruby_protractor_files.each do |spec|
      rb_spec_relative = ruby_to_js_rel spec

      js_spec = File.join(js_protractor_spec_folder, rb_spec_relative)
      raise "Matching protractor spec does not exist\n#{js_spec}" unless File.exist?(js_spec)

      spec_pairs << [spec, js_spec]
    end

    @spec_pairs = spec_pairs
  end

  def spec_pairs
    @spec_pairs
  end

  # Ruby specs must have the same describes as the JS files.
  it 'ruby specs have idential describes to protractor specs' do
    spec_pairs.each do |ruby_spec, js_spec|
      puts "Comparing: #{ruby_to_js_rel(ruby_spec)}"
      js_spec        = File.read js_spec
      ruby_spec      = File.read ruby_spec

      # match describes
      js_describes   = js_spec.scan(/describe\W*\(\W*['|"](.*?)['|"]\W*,/).flatten
      ruby_describes = ruby_spec.scan(/describe\W*['|"](.*?)['|"]\W*do/).flatten

      difference = js_describes - ruby_describes
      none       = []

      # redundant checks for more human readable rspec failure messages
      expect(difference).to eq(none)
      expect(js_describes.length).to eq(ruby_describes.length)

      # expect order to be the same
      js_describes.each_with_index do |describe, index|
        begin
          expect(describe).to eq(ruby_describes[index])
        rescue
          puts js_describes.join("\n")
          raise
        end
      end

      # and they should be identical
      expect(js_describes).to eq(ruby_describes)
    end
  end
end
