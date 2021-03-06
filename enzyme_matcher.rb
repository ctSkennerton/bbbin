#!/usr/bin/env ruby

# for matching lists of enzymes
# input is 2 files. First is a list of possible restriction sites. Second is a
# list of restriction enzymes.

require 'optparse'

class EnzymeMatcher
  ENCYME_NAME_CHARACTERS = 'a-zA-Z0-9'
  NON_ENZYME_CHARACTER='&'
  def self.match?(clean, dirty)
    filthy = "#{NON_ENZYME_CHARACTER}#{dirty}#{NON_ENZYME_CHARACTER}"
    return true if matches = filthy.match(/[^#{ENCYME_NAME_CHARACTERS}]#{clean}[^#{ENCYME_NAME_CHARACTERS}]/)
    return false
  end
end

if __FILE__ == $0
  # Parse options
  options = {
    :properly_formatted_enzyme_list_path => nil,
    :enzymes => [],
  }
  o = OptionParser.new do |opts|
    opts.banner = [
      'Usage: enzyme_matcher.rb -f <restriction_enzyme_list1> <restriction_enzyme_list2>',
      "\tthe first list must have 1 restriction enzyme per line, without anything else. The second list must be one per line, but is more relaxed. It can have a 'non-enzyme' character(s) before or following the enzyme name e.g. 'BamHI,'"
    ]
    opts.on("-f", "--enzyme-list-1 FILENAME", "A well formatted list of enzymes to match with") do |f|
      options[:properly_formatted_enzyme_list_path] = f
    end
    opts.on('-e', "--enzymes ENZYME_NAMES", "Use this enzyme to do the cutting") do |e|
      options[:enzymes] = e.split(',')
    end
  end
  o.parse!
  if ARGV.length != 1
    $stderr.puts o.banner
    exit
  end

  # Parse properly formatted enzyme lists
  if options[:properly_formatted_enzyme_list_path].nil?
    raise Exception, "Undefined enzyme list 1. Quitting."
  end
  enzyme_list_1 = []
  unless options[:properly_formatted_enzyme_list_path].nil?
    enzyme_list_1 = File.open(options[:properly_formatted_enzyme_list_path]).read.split(/\s/)
  end
  options[:enzymes].each do |e|
    enzyme_list_1.push e
  end

  # Go through the second list looking for correctly formatted entries
  File.open(ARGV[0]).each_line do |line|
  # superfluosly add a non-enzyme character to the start and the end so that programming is simpler with the regexes

    enzyme_list_1.each do |e|
    # match match non-enzyme-char, enzyme name, non-enzyme-char without breaks in between, or lies
      if EnzymeMatcher.match?(e, line)
        puts line
      end
    end
  end
end