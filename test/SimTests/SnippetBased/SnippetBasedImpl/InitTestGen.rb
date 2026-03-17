# frozen_string_literal: true

require 'Utility/gen_emitter'
require 'yaml'
require_relative 'Target/RISCV/Formatter'

module SimTest
  class InitAsmGen
    attr_reader :ir, :reg2value

    def initialize(ir)
      @ir = ir
    end

    def generate_random_values
      values = {}
      ir[:regfiles].each do |regfile|
        regfile[:regs].each do |reg|
          attrs = reg[:attrs] || []
          next if attrs.include?(:zero) || attrs.include?(:pc)
          size = reg[:size] || 32
          max = (1 << size) - 1
          values[reg[:name]] = rand(0..max)
        end
      end
      values
    end

    def generate(formatter, snippet_content, output_file)
      emitter = Utility::GenEmitter.new()
      @reg2value = generate_random_values

      formatter.prologue(emitter)
      formatter.init_register(emitter, ir, @reg2value)

      emitter.emit_line 'j _snippet'
      emitter.decrease_indent
      emitter.emit_line '_snippet:'
      emitter.increase_indent
      formatter.insert_snippet(emitter, snippet_content)
      emitter.emit_line 'j _exit_snippet'
      emitter.decrease_indent
      emitter.emit_line '_exit_snippet:'
      emitter.increase_indent

      formatter.epilogue(emitter)
      File.write(output_file + 'yaml', @reg2value.to_yaml)
      File.write(output_file + 's', emitter.to_s)
    end
  end
end

if __FILE__ == $0
  if ARGV.size < 3 || ARGV.size > 4
    puts "Usage: #{$0} <ir_yaml_file> <snippets_directory> <output_directory> [num_tests]"
    exit 1
  end

  ir_file = ARGV[0]
  snippets_dir = ARGV[1]
  output_directory = ARGV[2]
  num_tests = ARGV[3] ? ARGV[3].to_i : 4

  ir = YAML.load_file(ir_file, symbolize_names: true)
  generator = SimTest::InitAsmGen.new(ir)
  formatter = SimTest::RiscVFormatter.new

  Dir.glob(File.join(snippets_dir, '*')).each do |snippet_path|
    next unless File.file?(snippet_path)

    snippet_content = File.read(snippet_path)
    base = File.basename(snippet_path, '.*')

    num_tests.times do |i|
      output_file = File.join(output_directory, "#{base}_#{i}.init.")
      generator.generate(formatter, snippet_content, output_file)
      puts "Generated: #{output_file}s (test #{i+1}/#{num_tests})"
    end
  end
end
