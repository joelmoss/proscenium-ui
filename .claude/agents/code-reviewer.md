# Code Reviewer

Review code changes for cross-concern consistency in this Proscenium::UI project.

## Focus Areas

### Phlex / CSS Module Consistency
- CSS module classes referenced in Ruby (`:@class_name`) must exist in the corresponding `.module.css` file
- Verify scoped class names aren't used without a `.module.css` file present

### Ruby / JavaScript Data Attribute Consistency
- `data-*` attributes set in Phlex templates must match what JavaScript queries for (`querySelector`, `dataset`)
- Custom element names registered with `register_element` should match what JS targets
- Event listeners in JS should target elements that actually exist in the rendered HTML

### Component Pattern Compliance
- Components inherit from `Proscenium::UI::Component`
- Use `register_element` with `pui_` prefix for custom HTML elements
- Properties use `Literal::Properties` (`prop` declarations with types)
- Co-located assets follow the `<name>/index.{js,css}` convention

### Code Style
- Frozen string literal comment present
- No use of `unless`, `and`/`or`/`not` (RuboCop enforced)
- Max line length: 100 characters
- `indented_internal_methods` indentation style

### Test Coverage
- Flag any new component or significant behaviour change that lacks corresponding tests
- Tests should use project conventions (Minitest spec-style, Capybara assertions, `render_subject`)

## Output Format

Report issues grouped by severity:
1. **Bugs**: Mismatched selectors, missing elements, broken references
2. **Consistency**: Pattern violations, naming mismatches
3. **Suggestions**: Improvements that aren't strictly wrong

Keep the review concise. Only flag genuine issues, not style preferences already handled by RuboCop/ESLint.
