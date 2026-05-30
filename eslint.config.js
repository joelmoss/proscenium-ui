import js from '@eslint/js'
import css from '@eslint/css'
import prettier from 'eslint-plugin-prettier/recommended'
import globals from 'globals'

export default [
  { ignores: ['node_modules/', 'public/'] },

  // JavaScript
  {
    files: ['**/*.js'],
    ...js.configs.recommended,
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: {
        ...globals.browser,
        proscenium: true
      }
    }
  },

  // CSS — lint with @eslint/css, minus the three rules that clash with this project:
  //   no-invalid-at-rules   → off; rejects Proscenium's PostCSS @mixin/@define-mixin
  //   no-invalid-properties → off; can't validate our --pui-* custom-property theming
  //   use-baseline          → off; this library is deliberately modern-CSS-first (nesting,
  //                           ::marker, overscroll-behavior, ui-monospace), which the rule fights
  // tolerant parsing lets the @define-mixin blocks through. Prettier (below) formats CSS.
  // This leaves the structural checks active (empty blocks, duplicate imports, etc.).
  {
    files: ['**/*.css'],
    plugins: { css },
    language: 'css/css',
    languageOptions: { tolerant: true },
    rules: {
      ...css.configs.recommended.rules,
      'css/no-invalid-at-rules': 'off',
      'css/no-invalid-properties': 'off',
      'css/use-baseline': 'off'
    }
  },

  // Prettier — keep last so it disables conflicting rules and runs Prettier on both JS and CSS
  prettier
]
