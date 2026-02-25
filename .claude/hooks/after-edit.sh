#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path')

cd "$CLAUDE_PROJECT_DIR"

# Auto-format JS/CSS with Prettier
if [[ "$FILE_PATH" == *.js || "$FILE_PATH" == *.css || "$FILE_PATH" == *.json ]]; then
  RESULT=$(npx prettier --write "$FILE_PATH" 2>&1)
  if [ $? -ne 0 ]; then
    printf '{"decision":"block","reason":"Prettier failed:\n%s"}' "$RESULT"
    exit 0
  fi
fi

# Auto-lint Ruby with RuboCop
if [[ "$FILE_PATH" == *.rb ]]; then
  RESULT=$(bin/rubocop -A "$FILE_PATH" 2>&1)
  if [ $? -ne 0 ]; then
    printf '{"decision":"block","reason":"RuboCop violations found:\n%s"}' "$RESULT"
    exit 0
  fi
fi

exit 0
