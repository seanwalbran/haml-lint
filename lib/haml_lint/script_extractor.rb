module HamlLint
  # Utility class for extracting Ruby script from a HAML file that can then be
  # linted with a Ruby linter (i.e. is "legal" Ruby). The goal is to turn this:
  #
  #     - if signed_in?(viewer)
  #       %span Stuff
  #       = link_to 'Sign Out', sign_out_path
  #     - else
  #       .some-class{ class: my_method }= my_method
  #       = link_to 'Sign In', sign_in_path
  #
  # into this:
  #
  #     if signed_in?(viewer)
  #       link_to 'Sign Out', sign_out_path
  #     else
  #       { class: my_method }
  #       my_method
  #       link_to 'Sign In', sign_in_path
  #     end
  #
  class ScriptExtractor
    include HamlVisitor

    attr_reader :source, :source_map

    def initialize(parser)
      @parser = parser
    end

    def extract
      visit(@parser.tree)
      @source = @code.join("\n")
    end

    def visit_root(_node)
      @code = []
      @total_lines = 0
      @source_map = {}
      @indent_level = 0

      yield # Collect lines of code from children
    end

    def visit_plain(node)
      # Comment out the actual text as we don't want to deal with RuboCop
      # StringQuotes lints
      add_line("puts # #{node.text}", node)
    end

    def visit_tag(node)
      additional_attributes = node.dynamic_attributes_sources

      # Include dummy references to code executed in attributes list
      # (this forces a "use" of a variable to prevent "assigned but unused
      # variable" lints)
      additional_attributes.each do |attributes_code|
        # Normalize by removing excess whitespace to avoid format lints
        attributes_code = attributes_code.gsub(/\s*\n\s*/, ' ').strip

        # Attributes can either be a method call or a literal hash, so wrap it
        # in a method call itself in order to avoid having to differentiate the
        # two.
        add_line("{}.merge(#{attributes_code.strip})", node)
      end

      # We add a dummy puts statement to represent the tag name being output.
      # This prevents some erroneous RuboCop warnings.
      add_line("puts # #{node.tag_name}", node)

      code = node.script.strip
      add_line(code, node) unless code.empty?
    end

    def visit_script(node)
      code = node.text
      add_line(code.strip, node)

      start_block = anonymous_block?(code) || start_block_keyword?(code)

      if start_block
        @indent_level += 1
      end

      yield # Continue extracting code from children

      if start_block
        @indent_level -= 1
        add_line('end', node)
      end
    end

    def visit_silent_script(node, &block)
      visit_script(node, &block)
    end

    def visit_filter(node)
      if node.filter_type == 'ruby'
        node.text.split("\n").each_with_index do |line, index|
          add_line(line, node.line + index + 1)
        end
      else
        HamlLint::Utils.extract_interpolated_values(node.text) do |interpolated_code|
          add_line(interpolated_code, node)
        end
      end
    end

    private

    def add_line(code, node_or_line)
      return if code.empty?

      indent_level = @indent_level

      if node_or_line.respond_to?(:line)
        # Since mid-block keywords are children of the corresponding start block
        # keyword, we need to reduce their indentation level by 1. However, we
        # don't do this unless this is an actual tag node (a raw line number
        # means this came from a `:ruby` filter).
        indent_level -= 1 if mid_block_keyword?(code)
      end

      indent = (' ' * 2 * indent_level)

      @code << indent + code

      original_line =
        node_or_line.respond_to?(:line) ? node_or_line.line : node_or_line

      # For interpolated code in filters that spans multiple lines, the
      # resulting code will span multiple lines, so we need to create a
      # mapping for each line.
      (code.count("\n") + 1).times do
        @total_lines += 1
        @source_map[@total_lines] = original_line
      end
    end

    def anonymous_block?(text)
      text =~ /\bdo\s*(\|\s*[^\|]*\s*\|)?\z/
    end

    START_BLOCK_KEYWORDS = %w[if unless case begin for until while]
    def start_block_keyword?(text)
      START_BLOCK_KEYWORDS.include?(block_keyword(text))
    end

    MID_BLOCK_KEYWORDS = %w[else elsif when rescue ensure]
    def mid_block_keyword?(text)
      MID_BLOCK_KEYWORDS.include?(block_keyword(text))
    end

    def block_keyword(text)
      # Need to handle 'for'/'while' since regex stolen from HAML parser doesn't
      if keyword = text[/\A\s*([^\s]+)\s+/, 1]
        return keyword if %w[for until while].include?(keyword)
      end

      return unless keyword = text.scan(Haml::Parser::BLOCK_KEYWORD_REGEX)[0]
      keyword[0] || keyword[1]
    end
  end
end
