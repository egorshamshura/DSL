# frozen_string_literal: true

require 'yaml'
require 'etc'
require 'parallel'
require 'optparse'
require 'Utility/gen_emitter'
require 'Utility/type'
require_relative 'Target/RISCV/Formatter'
require_relative 'Parsers/QEMUParser'


module SimTest
    class SnippetGen
        attr_reader :ir

        def initialize(ir)
            @ir = ir
            remove_special_regs(ir[:regfiles])
        end

        def generate_snippets()
            snippets = []
            @ir[:instructions].each do |instr|
                next if isBranch(instr)
                next if isMemory(instr)
                next if isSyscall(instr)
                next if isEmptyCode(instr)
                variables = get_variables(instr)
                random_regs = generate_random_regs(variables)
                snippets << instr[:asm_str] % random_regs.to_h
            end
            snippets
        end

        def generate_random_regs(variables)
            variables.map { |v|
                regfile = find_regfile_by_name(v[:regset])
                if regfile.nil?
                    [v[:name], "0x#{rand(0..15).to_s(16)}"]
                else
                    [v[:name], regfile[:regs].sample[:name]]
                end
            }
        end

        def isEmptyCode(instr)
            instr[:code][:tree].empty?
        end

        def remove_special_regs(regfiles)
            regfiles.each do |rf|
                rf[:regs].reject! { |r| r[:attrs].include?(:zero) || r[:attrs].include?(:pc) || r[:attrs].include?(:sp) }
            end
        end

        def find_regfile_by_name(regfile_name)
            @ir[:regfiles].find { |rf| rf[:name] == regfile_name }
        end

        def get_variables(instr)
            variables = []
            instr[:map][:tree].each do |stmt|
                if stmt[:name] == :new_var
                    variables << stmt[:oprnds][0]
                end
            end
            variables
        end

        def isBranch(instr)
            instr[:code][:tree].each do |stmt|
                return true if stmt[:name] == :branch
            end
            return false
        end

        def isMemory(instr)
            instr[:code][:tree].each do |stmt|
                return true if stmt[:name] == :readMem || stmt[:name] == :writeMem
            end
            return false
        end

        def isSyscall(instr)
            instr[:code][:tree].each do |stmt|
                return true if stmt[:name] == :sysCall
            end
            return false
        end
    end
end

if __FILE__ == $0
    options = {}

    parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{$0} [options] <ir_yaml_file>"

        opts.on('-h', '--help', 'Show this help message') do
            puts opts
            exit
        end
    end

    parser.parse!

    if ARGV.length != 2
        puts "Error: Expected exactly two arguments (IR YAML file and output dir)"
        puts parser
        exit 1
    end

    ir_yaml_file = ARGV[0]
    output_dir = ARGV[1]
    ir = YAML.load_file(ir_yaml_file)

    snippet_gen = SimTest::SnippetGen.new(ir)
    snippets = snippet_gen.generate_snippets()
    Dir.mkdir(output_dir) unless Dir.exist?(output_dir)
    snippets.each_with_index do |snippet, index|
        File.write("#{output_dir}/generated#{index}snippet.s", snippet)
    end
end
