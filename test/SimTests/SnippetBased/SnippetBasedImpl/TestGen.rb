# frozen_string_literal: true

require 'Utility/gen_emitter'
require 'yaml'
require_relative 'Target/RISCV/Formatter'
require_relative 'Parsers/QEMUParser'

module SimTest
  class FinalAsmGen
    attr_reader :ir

    def initialize(ir)
      @ir = ir
    end

    def generate(formatter, snippet_content, init_yaml_file, ref_log_file, output_file)
      emitter = Utility::GenEmitter.new()

      initreg2value = YAML.load_file(init_yaml_file)
      refreg2value = QEMULogParser.parse(ref_log_file)

      formatter.prologue(emitter)
      formatter.init_register(emitter, @ir, initreg2value)

      emitter.emit_line 'j _snippet'
      emitter.decrease_indent
      emitter.emit_line '_snippet:'
      emitter.increase_indent
      formatter.insert_snippet(emitter, snippet_content)
      emitter.emit_line 'j _exit_snippet'
      emitter.decrease_indent
      emitter.emit_line '_exit_snippet:'
      emitter.increase_indent

      formatter.insert_check(emitter, @ir, refreg2value)

      formatter.epilogue(emitter)
      File.write(output_file, emitter.to_s)
    end
  end
end

if __FILE__ == $0
  if ARGV.size != 5
    puts "Usage: #{$0} <ir_yaml_file> <snippets_dir> <init_json_dir> <log_dir> <output_dir>"
    exit 1
  end

  ir_file = ARGV[0]
  snippets_dir = ARGV[1]
  init_json_dir = ARGV[2]
  log_dir = ARGV[3]
  output_dir = ARGV[4]

  ir = YAML.load_file(ir_file, symbolize_names: true)
  generator = SimTest::FinalAsmGen.new(ir)
  formatter = SimTest::RiscVFormatter.new

  log_files = Dir.glob(File.join(log_dir, '*')).select { |f| File.file?(f) }

  log_files.each do |log_path|
    log_basename = File.basename(log_path)

    match = log_basename.match(/^(.*)_(\d+)\.init\.log$/)
    snippet = match[1]
    index = match[2].to_i

    snippet_path = Dir.glob(File.join(snippets_dir, '*')).find do |f|
      File.file?(f) && File.basename(f, '.*') == snippet
    end

    unless snippet_path
      puts "Warning: snippet file for '#{snippet}' not found in #{snippets_dir}, skipping"
      next
    end

    init_yaml_file = File.join(init_json_dir, "#{snippet}_#{index}.init.yaml")

    output_file = File.join(output_dir, "#{snippet}_#{index}.s")
    snippet_content = File.read(snippet_path)

    generator.generate(formatter, snippet_content, init_yaml_file, log_path, output_file)
    puts "Generated: #{output_file}"
  end
end
