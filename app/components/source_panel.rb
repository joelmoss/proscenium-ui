# frozen_string_literal: true

module Components
  class SourcePanel < Application
    extend Literal::Properties

    LEXERS = {
      '.rb' => Rouge::Lexers::Ruby,
      '.css' => Rouge::Lexers::Scss,
      '.js' => Rouge::Lexers::Javascript
    }.freeze

    prop :view, Views::Application, :positional

    def view_template
      div class: :@root do
        div class: :@tabs, role: :tablist do
          source_files.each_with_index do |(label, _), index|
            button role: :tab, aria_selected: index.zero?.to_s,
                   data: { tab: index } do
              plain label
            end
          end
        end

        source_files.each_with_index do |(_, content), index|
          div class: :@tab_panel, role: :tabpanel, data: { panel: index },
              hidden: !index.zero? || nil do
            raw content # rubocop:disable Rails/OutputSafety
          end
        end
      end
    end

    private

      def source_files
        @source_files ||= [['View', highlight(view_template_body, '.rb')]] + asset_files
      end

      def asset_files
        base = source_file&.delete_suffix('.rb')
        return [] if base.nil?

        %W[#{base}.css #{base}.module.css #{base}.js].filter_map do |path|
          if File.exist?(path)
            ext = File.extname(path)
            label = path.end_with?('.module.css') ? 'MODULE.CSS' : ext.delete_prefix('.').upcase
            [label, highlight(File.read(path), ext)]
          end
        end
      end

      def source_file
        @source_file ||= @view.method(:view_template).source_location&.first
      end

      def view_template_body
        file, start_line = @view.method(:view_template).source_location
        return '' if file.nil?

        lines = File.readlines(file)
        body_lines = []
        depth = 0
        lines[(start_line - 1)..].each do |line|
          depth += line.scan(/\b(?:do|def|if|unless|case|begin|class|module)\b/).size
          depth -= line.scan(/\bend\b/).size
          body_lines << line
          break if depth <= 0
        end

        body_lines = body_lines[1...-1] # strip def/end lines
        indent = body_lines.first&.match(/^(\s*)/).then { |m| m ? m[1].length : 0 }
        body_lines.map { |l| l.delete_prefix(' ' * indent) }.join
      end

      def highlight(source, ext)
        lexer = LEXERS.fetch(ext, Rouge::Lexers::PlainText).new
        "<pre><code>#{formatter.format(lexer.lex(source))}</code></pre>".html_safe # rubocop:disable Rails/OutputSafety
      end

      def formatter
        @formatter ||= Rouge::Formatters::HTMLInline.new(Rouge::Themes::Github.new)
      end
  end
end
