#!/usr/bin/env bash
# ===============================================================
#  gitai — AI-Powered Git CLI
#  Author : Suhail Roushan <hi@suhailroushan.com>
#  Repo   : https://github.com/suhailroushan13/gitai
#  License: MIT
# ===============================================================

export TZ=Asia/Kolkata

# ---------------------------------------------------------------
# API CONFIG  (set DEEPSEEK_API_KEY in your shell env)
# ---------------------------------------------------------------
DEEPSEEK_API_KEY="${DEEPSEEK_API_KEY:-}"
DEEPSEEK_API_URL="https://api.deepseek.com/v1/chat/completions"
DEEPSEEK_MODEL="deepseek-chat"

# ---------------------------------------------------------------
# COLORS
# ---------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
BG_BLUE='\033[44m'
RESET='\033[0m'

# ---------------------------------------------------------------
# CHECK DEPENDENCIES
# ---------------------------------------------------------------
for cmd in git jq curl; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo -e "${RED}❌ '$cmd' is required but not installed.${RESET}"
    echo -e "${DIM}   Install it and try again.${RESET}"
    exit 1
  }
done

# ---------------------------------------------------------------
# CLI ARGS (e.g. gitai --docs | gitai docs)
# ---------------------------------------------------------------
show_git_docs() {
  cat << 'GITDOCS'

╔══════════════════════════════════════════════════════════════════════════════╗
║                        GIT — COMPLETE REFERENCE & NOTES                      ║
╚══════════════════════════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 1. INSTALL GIT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  • macOS (Homebrew):    brew install git
  • Ubuntu/Debian:       sudo apt update && sudo apt install git
  • Windows:             https://git-scm.com/download/win
  • Verify:              git --version

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 2. GLOBAL CONFIG (first-time setup)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Set your identity (used in every commit):

    git config --global user.name "Your Name"
    git config --global user.email "your.email@example.com"

  Optional useful globals:

    git config --global init.defaultBranch main
    git config --global core.editor "code --wait"
    git config --global pull.rebase false
    git config --global credential.helper store

  View all global config:

    git config --global --list

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 3. SSH KEY SETUP (for GitHub/GitLab)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Step 1 — Generate Ed25519 key (recommended):

    ssh-keygen -t ed25519 -C "your.email@example.com"

    • Press Enter to accept default path (~/.ssh/id_ed25519)
    • Optionally set a passphrase

  Step 2 — Start ssh-agent and add key:

    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519

  Step 3 — Copy public key to clipboard (macOS):

    pbcopy < ~/.ssh/id_ed25519.pub

  Or print it to paste manually:

    cat ~/.ssh/id_ed25519.pub

  Step 4 — Add key on GitHub:

    • GitHub → Settings → SSH and GPG keys → New SSH key
    • Paste the key, give it a title, Save

  Step 5 — Test:

    ssh -T git@github.com

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 4. FIRST REPO — FROM SCRATCH TO FIRST COMMIT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Create project folder and init:

    mkdir my-project && cd my-project
    git init

  Add files and first commit:

    git add .
    git status
    git commit -m "Initial commit"

  Add remote (use SSH URL after setting up keys):

    git remote add origin git@github.com:username/my-project.git

  Push to GitHub (first time):

    git push -u origin main

  If your branch is master:

    git branch -M main
    git push -u origin main

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 5. CLONE EXISTING REPO
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  HTTPS:
    git clone https://github.com/username/repo.git
    cd repo

  SSH (after SSH key setup):
    git clone git@github.com:username/repo.git
    cd repo

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 6. DAILY WORKFLOW — COMMANDS & EXAMPLES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Status & diff:
    git status
    git diff
    git diff --cached

  Stage & commit:
    git add .
    git add file.txt
    git add -p
    git commit -m "feat: add login"
    git commit --amend -m "New message"

  Push & pull:
    git push
    git push origin branch-name
    git pull
    git pull --rebase
    git fetch && git merge origin/main

  Branches:
    git branch
    git branch -a
    git checkout -b feature/xyz
    git checkout main
    git switch main
    git branch -d feature/old
    git push origin --delete branch-name

  Undo & reset:
    git reset --soft HEAD~1
    git reset --hard HEAD
    git restore file.txt
    git restore --staged file.txt

  Stash:
    git stash
    git stash push -m "WIP: feature"
    git stash list
    git stash pop
    git stash apply stash@{0}

  Log & history:
    git log --oneline -20
    git log --oneline --graph --all
    git log -p file.txt
    git log --grep="fix"

  Remotes:
    git remote -v
    git remote add upstream https://github.com/owner/repo.git
    git remote set-url origin git@github.com:user/repo.git

  Tags:
    git tag v1.0.0
    git tag -a v1.0.0 -m "Release 1.0"
    git push origin v1.0.0
    git push origin --tags

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 7. USEFUL GLOBAL CONFIG OPTIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  git config --global init.defaultBranch main
  git config --global core.autocrlf input
  git config --global core.editor "code --wait"
  git config --global pull.rebase true
  git config --global push.autoSetupRemote true
  git config --global fetch.prune true
  git config --global alias.lg "log --oneline --graph --decorate -20"
  git config --global alias.st status
  git config --global alias.co checkout
  git config --global alias.br branch

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 8. COMMIT MESSAGE PREFIXES (conventional commits)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  feat:     new feature
  fix:      bug fix
  docs:     documentation
  style:    formatting
  refactor: code change, no feature/fix
  test:     tests
  chore:    maintenance

  Example:  git commit -m "feat: add user login with OAuth"

GITDOCS
}

case "${1:-}" in
  --help|-h)
    echo "  gitai — AI-powered Git CLI"
    echo "  Usage: gitai [option]"
    echo ""
    echo "  Options:"
    echo "    --docs, -d, docs   Show full Git reference (setup, SSH, commands)"
    echo "    --help, -h         Show this help"
    echo ""
    echo "  With no options, starts the interactive menu."
    exit 0
    ;;
  --docs|-d|docs) show_git_docs; exit 0 ;;
esac

# ---------------------------------------------------------------
# CHECK API KEY
# ---------------------------------------------------------------
if [ -z "$DEEPSEEK_API_KEY" ]; then
  echo -e "${RED}❌ DEEPSEEK_API_KEY is not set.${RESET}"
  echo -e "${DIM}   Add this to your ~/.zshrc or ~/.bashrc:${RESET}"
  echo -e "${CYAN}   export DEEPSEEK_API_KEY=\"sk-your-key-here\"${RESET}"
  echo -e "${DIM}   Then run:  source ~/.zshrc   (or source ~/.bashrc)${RESET}"
  echo -e "${DIM}   Or open a new terminal so your config is loaded.${RESET}"
  exit 1
fi

# ---------------------------------------------------------------
# GIT USER INFO
# ---------------------------------------------------------------
GIT_USER_NAME=$(git config --global user.name 2>/dev/null || echo "Unknown")
GIT_USER_EMAIL=$(git config --global user.email 2>/dev/null || echo "unknown@email.com")
GIT_USER_INITIALS=$(echo "$GIT_USER_NAME" \
  | awk '{for(i=1;i<=NF&&i<=2;i++) printf substr($i,1,1)}' \
  | tr '[:lower:]' '[:upper:]')
NOW=$(date +"%a, %d %b %Y • %I:%M %p")

# ---------------------------------------------------------------
# HELPERS
# ---------------------------------------------------------------
get_commit_time() {
  local DAY SUFFIX
  DAY=$(date +"%d" | sed 's/^0//')
  case $DAY in
    1|21|31) SUFFIX="st" ;;
    2|22)    SUFFIX="nd" ;;
    3|23)    SUFFIX="rd" ;;
    *)       SUFFIX="th" ;;
  esac
  echo "${DAY}${SUFFIX} $(date +"%b %Y %I:%M %p")"
}

require_repo() {
  if [ "$IS_REPO" = false ]; then
    echo -e "\n  ${RED}❌ Not inside a Git repository. cd into one first.${RESET}\n"
    return 1
  fi
  return 0
}

do_push() {
  echo -e "\n  ${DIM}Pushing to origin/${BRANCH}...${RESET}"
  if git push origin "$BRANCH" 2>&1; then
    echo -e "  ${GREEN}✅ Pushed to ${BOLD}${BRANCH}${RESET}"
    return 0
  fi
  echo -e "  ${RED}❌ Push rejected.${RESET}"
  echo -e "  ${DIM}Try: Pull & Rebase (5), Pull & Merge (6), or Force Push (4)${RESET}"
  return 1
}

refresh_repo_state() {
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    IS_REPO=true
    BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
    REPO_NAME=$(basename "$(git rev-parse --show-toplevel)" 2>/dev/null)
    STAGED=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
    UNSTAGED=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
    UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
    AHEAD=$(git rev-list @{u}..HEAD 2>/dev/null | wc -l | tr -d ' ')
    BEHIND=$(git rev-list HEAD..@{u} 2>/dev/null | wc -l | tr -d ' ')
  else
    IS_REPO=false
    BRANCH=""
    REPO_NAME=""
    STAGED=0; UNSTAGED=0; UNTRACKED=0; AHEAD=0; BEHIND=0
  fi
}

# ---------------------------------------------------------------
# AI QUERY
# ---------------------------------------------------------------
ai_query() {
  local system_prompt="$1"
  local user_prompt="$2"
  local max_tokens="${3:-300}"

  local PAYLOAD
  PAYLOAD=$(jq -n \
    --arg model   "$DEEPSEEK_MODEL" \
    --arg sys     "$system_prompt" \
    --arg usr     "$user_prompt" \
    --argjson tok "$max_tokens" \
    '{
      model: $model,
      max_tokens: $tok,
      temperature: 0.4,
      messages: [
        { role: "system", content: $sys },
        { role: "user",   content: $usr }
      ]
    }')

  local RAW RESPONSE_JSON
  RAW=$(curl -s --max-time 60 "$DEEPSEEK_API_URL" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
    -d "$PAYLOAD")

  # Check for API error (invalid key, rate limit, etc.)
  if echo "$RAW" | jq -e '.error' >/dev/null 2>&1; then
    echo "AI unavailable — $(echo "$RAW" | jq -r '.error.message // .error' 2>/dev/null || echo "API error")."
    return
  fi

  RESPONSE_JSON=$(echo "$RAW" | jq -r '.choices[0].message.content // empty')
  if [ -z "$RESPONSE_JSON" ]; then
    echo "AI unavailable — check your API key or connection."
  else
    echo "$RESPONSE_JSON"
  fi
}

# ---------------------------------------------------------------
# DRAW HEADER
# ---------------------------------------------------------------
draw_header() {
  clear
  echo ""
  echo -e "  ${DIM}╔══════════════════════════════════════════════════════╗${RESET}"
  echo -e "  ${DIM}║${RESET}                                                      ${DIM}║${RESET}"
  echo -e "  ${DIM}║${RESET}   ${BOLD}${CYAN} ██████╗ ██╗████████╗ █████╗ ██╗${RESET}                   ${DIM}║${RESET}"
  echo -e "  ${DIM}║${RESET}   ${BOLD}${CYAN}██╔════╝ ██║╚══██╔══╝██╔══██╗██║${RESET}                   ${DIM}║${RESET}"
  echo -e "  ${DIM}║${RESET}   ${BOLD}${CYAN}██║  ███╗██║   ██║   ███████║██║${RESET}                   ${DIM}║${RESET}"
  echo -e "  ${DIM}║${RESET}   ${BOLD}${CYAN}██║   ██║██║   ██║   ██╔══██║██║${RESET}                   ${DIM}║${RESET}"
  echo -e "  ${DIM}║${RESET}   ${BOLD}${CYAN}╚██████╔╝██║   ██║   ██║  ██║██║${RESET}                   ${DIM}║${RESET}"
  echo -e "  ${DIM}║${RESET}   ${BOLD}${CYAN} ╚═════╝ ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝${RESET}  ${DIM}AI-Powered CLI${RESET}  ${DIM}║${RESET}"
  echo -e "  ${DIM}║${RESET}                                                      ${DIM}║${RESET}"
  echo -e "  ${DIM}╚══════════════════════════════════════════════════════╝${RESET}"
  echo ""

  # User card
  echo -e "  ${DIM}┌─────────────────────────────────────────────────────┐${RESET}"
  echo -e "  ${DIM}│${RESET}  ${BG_BLUE}${WHITE}${BOLD}  ${GIT_USER_INITIALS}  ${RESET}  ${BOLD}${WHITE}Welcome back, ${CYAN}${GIT_USER_NAME}${WHITE}!${RESET}"
  echo -e "  ${DIM}│${RESET}        ${DIM}${GIT_USER_NAME}${RESET}"
  echo -e "  ${DIM}│${RESET}        ${DIM}${GIT_USER_EMAIL}${RESET}"
  echo -e "  ${DIM}│${RESET}        ${DIM}${NOW}${RESET}"
  echo -e "  ${DIM}└─────────────────────────────────────────────────────┘${RESET}"
  echo ""

  # Repo card
  if [ "$IS_REPO" = true ]; then
    echo -e "  ${DIM}┌─── Repo ──────────────────────────────────────────────┐${RESET}"
    echo -e "  ${DIM}│${RESET}  📁 ${BOLD}${REPO_NAME}${RESET}  ${DIM}on branch${RESET}  ${YELLOW}⎇  ${BRANCH}${RESET}"
    echo -e "  ${DIM}│${RESET}  ${GREEN}●${RESET} Staged: ${BOLD}${STAGED}${RESET}   ${YELLOW}●${RESET} Unstaged: ${BOLD}${UNSTAGED}${RESET}   ${RED}●${RESET} Untracked: ${BOLD}${UNTRACKED}${RESET}"
    { [ "$AHEAD"  -gt 0 ] 2>/dev/null && echo -e "  ${DIM}│${RESET}  ${CYAN}↑ ${AHEAD} commit(s) ahead of remote${RESET}"; } || true
    { [ "$BEHIND" -gt 0 ] 2>/dev/null && echo -e "  ${DIM}│${RESET}  ${MAGENTA}↓ ${BEHIND} commit(s) behind remote${RESET}"; } || true
    echo -e "  ${DIM}└──────────────────────────────────────────────────────┘${RESET}"
    echo ""
  fi
}

# ---------------------------------------------------------------
# MENU
# ---------------------------------------------------------------
show_menu() {
  echo -e "  ${BOLD}${WHITE}── COMMIT & PUSH ──────────────────────────────────────${RESET}"
  echo -e "  ${CYAN}${BOLD} 1)${RESET}  🤖  AI Commit & Push          ${DIM}auto-generate message + push${RESET}"
  echo -e "  ${CYAN}${BOLD} 2)${RESET}  ✍️   Manual Commit & Push       ${DIM}write your own message${RESET}"
  echo -e "  ${CYAN}${BOLD} 3)${RESET}  📦  Stage All & Status         ${DIM}git add . && git status${RESET}"
  echo -e "  ${CYAN}${BOLD} 4)${RESET}  💥  Force Push                 ${DIM}overwrite remote (careful!)${RESET}"
  echo ""
  echo -e "  ${BOLD}${WHITE}── SYNC & BRANCHES ────────────────────────────────────${RESET}"
  echo -e "  ${CYAN}${BOLD} 5)${RESET}  🔄  Pull & Rebase              ${DIM}fetch + replay your commits${RESET}"
  echo -e "  ${CYAN}${BOLD} 6)${RESET}  🔀  Pull & Merge               ${DIM}fetch + merge commit${RESET}"
  echo -e "  ${CYAN}${BOLD} 7)${RESET}  🌿  List Branches              ${DIM}all local + remote branches${RESET}"
  echo -e "  ${CYAN}${BOLD} 8)${RESET}  ➕  Create & Switch Branch     ${DIM}git checkout -b <name>${RESET}"
  echo -e "  ${CYAN}${BOLD} 9)${RESET}  🔃  Switch Branch              ${DIM}git checkout <name>${RESET}"
  echo -e "  ${CYAN}${BOLD}10)${RESET}  🗑️   Delete Branch              ${DIM}local and/or remote${RESET}"
  echo ""
  echo -e "  ${BOLD}${WHITE}── HISTORY & DIFF ─────────────────────────────────────${RESET}"
  echo -e "  ${CYAN}${BOLD}11)${RESET}  📜  Git Log                    ${DIM}recent commits (pretty graph)${RESET}"
  echo -e "  ${CYAN}${BOLD}12)${RESET}  🔍  Show Diff                  ${DIM}staged or unstaged changes${RESET}"
  echo -e "  ${CYAN}${BOLD}13)${RESET}  📋  Git Status                 ${DIM}full working tree status${RESET}"
  echo -e "  ${CYAN}${BOLD}14)${RESET}  🏷️   List Tags                  ${DIM}all git tags (newest first)${RESET}"
  echo -e "  ${CYAN}${BOLD}15)${RESET}  🔎  Search Commits             ${DIM}grep through commit messages${RESET}"
  echo ""
  echo -e "  ${BOLD}${WHITE}── STASH & UNDO ───────────────────────────────────────${RESET}"
  echo -e "  ${CYAN}${BOLD}16)${RESET}  🗃️   Stash Changes              ${DIM}save work temporarily${RESET}"
  echo -e "  ${CYAN}${BOLD}17)${RESET}  📤  Pop Stash                  ${DIM}restore stashed changes${RESET}"
  echo -e "  ${CYAN}${BOLD}18)${RESET}  📋  List Stashes               ${DIM}see all stash entries${RESET}"
  echo -e "  ${CYAN}${BOLD}19)${RESET}  ↩️   Undo Last Commit           ${DIM}soft reset (keep changes staged)${RESET}"
  echo -e "  ${CYAN}${BOLD}20)${RESET}  🧹  Discard All Changes        ${DIM}hard reset to last commit${RESET}"
  echo ""
  echo -e "  ${BOLD}${WHITE}── AI TOOLS ───────────────────────────────────────────${RESET}"
  echo -e "  ${CYAN}${BOLD}21)${RESET}  🧠  AI Explain Last Commit     ${DIM}plain-English summary${RESET}"
  echo -e "  ${CYAN}${BOLD}22)${RESET}  💡  AI Suggest Branch Name     ${DIM}based on your staged diff${RESET}"
  echo -e "  ${CYAN}${BOLD}23)${RESET}  📝  AI Generate PR Description ${DIM}from recent commits${RESET}"
  echo -e "  ${CYAN}${BOLD}24)${RESET}  🔐  AI Security Scan Diff      ${DIM}spot secrets & risky changes${RESET}"
  echo ""
  echo -e "  ${BOLD}${WHITE}── CONFIG ─────────────────────────────────────────────${RESET}"
  echo -e "  ${CYAN}${BOLD}25)${RESET}  👤  Show Git Config            ${DIM}name, email, remotes${RESET}"
  echo -e "  ${CYAN}${BOLD}26)${RESET}  🔗  List Remotes               ${DIM}all remote URLs${RESET}"
  echo -e "  ${CYAN}${BOLD}27)${RESET}  ➕  Add Remote                 ${DIM}add a new remote${RESET}"
  echo -e "  ${CYAN}${BOLD}28)${RESET}  🔁  Refresh                    ${DIM}re-fetch and redraw screen${RESET}"
  echo ""
  echo -e "  ${BOLD}${WHITE}── DOCS ──────────────────────────────────────────────${RESET}"
  echo -e "  ${CYAN}${BOLD}29)${RESET}  📖  Git Docs                   ${DIM}full git reference & examples${RESET}"
  echo ""
  echo -e "  ${RED}${BOLD} 0)${RESET}  🚪  Exit"
  echo ""
  echo -ne "  ${BOLD}${WHITE}❯ Choose an option: ${RESET}"
}

# ---------------------------------------------------------------
# BOOT
# ---------------------------------------------------------------
IS_REPO=false
refresh_repo_state
draw_header

# ---------------------------------------------------------------
# MAIN LOOP
# ---------------------------------------------------------------
while true; do
  show_menu
  read -r choice
  echo ""

  case $choice in

    # ── 1. AI COMMIT & PUSH ────────────────────────────────────
    1)
      require_repo || continue
      git add .
      if git diff --cached --quiet; then
        echo -e "  ${YELLOW}⚠️  Nothing staged — no changes to commit.${RESET}"
      else
        DIFF=$(git diff --cached | head -c 12000)
        echo -e "  ${DIM}🤖 Asking AI for commit message...${RESET}"
        AI_MSG=$(ai_query \
          "You are a Git expert. Generate ONE semantic commit message. Use exactly one prefix from: feat, fix, refactor, docs, chore. Format strictly as '<type>: <message>' (max 72 chars total). Return ONLY the commit message — no quotes, no explanation." \
          "Generate a commit message for this diff:\n${DIFF}" \
          80)
        { [ -z "$AI_MSG" ] || [ "${AI_MSG#AI unavailable}" != "$AI_MSG" ]; } \
          && AI_MSG="chore: update project files"
        COMMIT_MSG="${AI_MSG}"
        echo -e "\n  📝 ${BOLD}${COMMIT_MSG}${RESET}\n"
        git commit -m "$COMMIT_MSG" && do_push
      fi
      ;;

    # ── 2. MANUAL COMMIT & PUSH ────────────────────────────────
    2)
      require_repo || continue
      git add .
      if git diff --cached --quiet; then
        echo -e "  ${YELLOW}⚠️  Nothing staged — no changes to commit.${RESET}"
      else
        echo -ne "  ${BOLD}Commit message: ${RESET}"
        read -r manual_msg
        if [ -z "$manual_msg" ]; then
          echo -e "  ${RED}Aborted — empty message.${RESET}"
        else
          COMMIT_MSG="${manual_msg}"
          echo -e "\n  📝 ${BOLD}${COMMIT_MSG}${RESET}\n"
          git commit -m "$COMMIT_MSG" && do_push
        fi
      fi
      ;;

    # ── 3. STAGE ALL & STATUS ──────────────────────────────────
    3)
      require_repo || continue
      git add .
      echo -e "  ${GREEN}✅ All changes staged.${RESET}\n"
      git status
      ;;

    # ── 4. FORCE PUSH ──────────────────────────────────────────
    4)
      require_repo || continue
      echo -ne "  ${RED}⚠️  Force push will overwrite remote. Type 'yes' to confirm: ${RESET}"
      read -r confirm
      if [ "$confirm" = "yes" ]; then
        echo -e "  ${DIM}Fetching to update tracking refs...${RESET}"
        git fetch origin "$BRANCH" 2>/dev/null
        git push --force origin "$BRANCH" \
          && echo -e "  ${GREEN}✅ Force pushed to ${BOLD}${BRANCH}${RESET}" \
          || echo -e "  ${RED}❌ Force push failed. Check permissions.${RESET}"
      else
        echo -e "  ${YELLOW}Cancelled.${RESET}"
      fi
      ;;

    # ── 5. PULL & REBASE ───────────────────────────────────────
    5)
      require_repo || continue
      echo -e "  ${DIM}Pulling with rebase...${RESET}\n"
      if git pull --rebase origin "$BRANCH"; then
        echo -e "  ${GREEN}✅ Rebase complete.${RESET}"
        echo -ne "\n  Push now? (y/n): "
        read -r p; [ "$p" = "y" ] && do_push
      else
        echo -e "  ${RED}❌ Rebase conflict. Resolve then run: git rebase --continue${RESET}"
      fi
      ;;

    # ── 6. PULL & MERGE ────────────────────────────────────────
    6)
      require_repo || continue
      echo -e "  ${DIM}Pulling with merge...${RESET}\n"
      if git pull origin "$BRANCH"; then
        echo -e "  ${GREEN}✅ Merge complete.${RESET}"
        echo -ne "\n  Push now? (y/n): "
        read -r p; [ "$p" = "y" ] && do_push
      else
        echo -e "  ${RED}❌ Merge conflict. Resolve manually and commit.${RESET}"
      fi
      ;;

    # ── 7. LIST BRANCHES ───────────────────────────────────────
    7)
      require_repo || continue
      echo -e "  ${BOLD}Local branches:${RESET}"
      git branch -v
      echo -e "\n  ${BOLD}Remote branches:${RESET}"
      git branch -rv 2>/dev/null || echo -e "  ${DIM}No remotes configured.${RESET}"
      ;;

    # ── 8. CREATE & SWITCH BRANCH ──────────────────────────────
    8)
      require_repo || continue
      echo -ne "  ${BOLD}New branch name: ${RESET}"
      read -r bname
      if [ -z "$bname" ]; then
        echo -e "  ${RED}Aborted — empty name.${RESET}"
      else
        git checkout -b "$bname" \
          && echo -e "  ${GREEN}✅ Created and switched to ${YELLOW}${bname}${RESET}"
      fi
      ;;

    # ── 9. SWITCH BRANCH ───────────────────────────────────────
    9)
      require_repo || continue
      echo -e "  ${BOLD}Available branches:${RESET}\n"
      git branch -a
      echo -ne "\n  ${BOLD}Switch to: ${RESET}"
      read -r bname
      [ -z "$bname" ] && { echo -e "  ${RED}Aborted.${RESET}"; continue; }
      git checkout "$bname" \
        && echo -e "  ${GREEN}✅ Switched to ${YELLOW}${bname}${RESET}"
      ;;

    # ── 10. DELETE BRANCH ──────────────────────────────────────
    10)
      require_repo || continue
      echo -e "  ${BOLD}Local branches:${RESET}\n"
      git branch
      echo -ne "\n  ${BOLD}Branch to delete: ${RESET}"
      read -r bname
      [ -z "$bname" ] && { echo -e "  ${RED}Aborted.${RESET}"; continue; }
      bname=$(echo "$bname" | sed 's/^\* *//')
      if [ "$bname" = "$BRANCH" ]; then
        echo -e "  ${RED}❌ Cannot delete current branch (${BRANCH}). Switch to another branch first (option 9).${RESET}"
      else
      echo -ne "  Also delete from remote? (y/n): "
      read -r del_remote
      git branch -d "$bname" \
        && echo -e "  ${GREEN}✅ Deleted local branch ${YELLOW}${bname}${RESET}" \
        || echo -e "  ${RED}❌ Could not delete local branch (unmerged?). Use -D to force.${RESET}"
      if [ "$del_remote" = "y" ]; then
        git push origin --delete "$bname" \
          && echo -e "  ${GREEN}✅ Deleted remote branch ${YELLOW}${bname}${RESET}" \
          || echo -e "  ${RED}❌ Could not delete remote branch.${RESET}"
      fi
      fi
      ;;

    # ── 11. GIT LOG ────────────────────────────────────────────
    11)
      require_repo || continue
      git log --oneline --graph --decorate --color -25
      ;;

    # ── 12. SHOW DIFF ──────────────────────────────────────────
    12)
      require_repo || continue
      echo -e "  ${BOLD}1) Staged diff   2) Unstaged diff   3) Diff vs last commit${RESET}"
      echo -ne "  Choose: "
      read -r dtype
      case $dtype in
        1) git diff --cached ;;
        2) git diff ;;
        3) git diff HEAD ;;
        *) echo -e "  ${RED}Invalid.${RESET}" ;;
      esac
      ;;

    # ── 13. GIT STATUS ─────────────────────────────────────────
    13)
      require_repo || continue
      git status
      ;;

    # ── 14. LIST TAGS ──────────────────────────────────────────
    14)
      require_repo || continue
      TAGS=$(git tag --sort=-creatordate | head -20)
      if [ -z "$TAGS" ]; then
        echo -e "  ${DIM}No tags found.${RESET}"
      else
        echo -e "  ${BOLD}Tags (newest first):${RESET}\n"
        echo "$TAGS" | sed 's/^/  /'
      fi
      ;;

    # ── 15. SEARCH COMMITS ─────────────────────────────────────
    15)
      require_repo || continue
      echo -ne "  ${BOLD}Search term: ${RESET}"
      read -r term
      [ -z "$term" ] && { echo -e "  ${RED}Aborted.${RESET}"; continue; }
      RESULTS=$(git log --oneline --color --grep="$term")
      if [ -z "$RESULTS" ]; then
        echo -e "  ${DIM}No commits matching '${term}'.${RESET}"
      else
        echo "$RESULTS"
      fi
      ;;

    # ── 16. STASH ──────────────────────────────────────────────
    16)
      require_repo || continue
      echo -ne "  ${BOLD}Stash message (leave blank for default): ${RESET}"
      read -r smsg
      if [ -z "$smsg" ]; then
        git stash && echo -e "  ${GREEN}✅ Changes stashed.${RESET}"
      else
        git stash push -m "$smsg" && echo -e "  ${GREEN}✅ Stashed: ${smsg}${RESET}"
      fi
      ;;

    # ── 17. POP STASH ──────────────────────────────────────────
    17)
      require_repo || continue
      STASH_COUNT=$(git stash list | wc -l | tr -d ' ')
      if [ "$STASH_COUNT" -eq 0 ]; then
        echo -e "  ${DIM}No stashes found.${RESET}"
      else
        echo -e "  ${BOLD}Available stashes:${RESET}\n"
        git stash list | head -10 | sed 's/^/  /'
        echo -ne "\n  ${BOLD}Pop stash index (default 0): ${RESET}"
        read -r sidx
        [ -z "$sidx" ] && sidx=0
        git stash pop "stash@{${sidx}}" \
          && echo -e "  ${GREEN}✅ Stash ${sidx} applied.${RESET}" \
          || echo -e "  ${RED}❌ Failed to apply stash.${RESET}"
      fi
      ;;

    # ── 18. LIST STASHES ───────────────────────────────────────
    18)
      require_repo || continue
      STASH_LIST=$(git stash list)
      if [ -z "$STASH_LIST" ]; then
        echo -e "  ${DIM}No stashes found.${RESET}"
      else
        echo -e "  ${BOLD}All stashes:${RESET}\n"
        echo "$STASH_LIST" | sed 's/^/  /'
      fi
      ;;

    # ── 19. UNDO LAST COMMIT (soft) ────────────────────────────
    19)
      require_repo || continue
      LAST=$(git log -1 --pretty="%s" 2>/dev/null)
      echo -e "  ${DIM}Last commit: ${LAST}${RESET}"
      echo -ne "  ${YELLOW}⚠️  Undo this commit and keep changes staged? (yes/no): ${RESET}"
      read -r confirm
      if [ "$confirm" = "yes" ]; then
        git reset --soft HEAD~1 \
          && echo -e "  ${GREEN}✅ Commit undone. Changes are still staged.${RESET}"
      else
        echo -e "  ${YELLOW}Cancelled.${RESET}"
      fi
      ;;

    # ── 20. DISCARD ALL CHANGES ────────────────────────────────
    20)
      require_repo || continue
      echo -e "  ${RED}${BOLD}⚠️  WARNING: This will permanently discard all uncommitted changes.${RESET}"
      echo -ne "  ${RED}Type 'yes' to confirm: ${RESET}"
      read -r confirm
      if [ "$confirm" = "yes" ]; then
        git reset --hard HEAD
        git clean -fd
        echo -e "  ${GREEN}✅ Working tree cleaned.${RESET}"
      else
        echo -e "  ${YELLOW}Cancelled.${RESET}"
      fi
      ;;

    # ── 21. AI EXPLAIN LAST COMMIT ─────────────────────────────
    21)
      require_repo || continue
      echo -e "  ${DIM}🤖 Analysing last commit...${RESET}\n"
      LAST_STAT=$(git show --stat HEAD 2>/dev/null)
      LAST_MSG=$(git log -1 --pretty="%s" 2>/dev/null)
      EXPLANATION=$(ai_query \
        "You are a senior software engineer. Explain what this git commit did in plain English. Be concise — 3 to 5 sentences max. No bullet points." \
        "Commit message: ${LAST_MSG}\n\nFile changes:\n${LAST_STAT}")
      echo -e "  ${BOLD}${CYAN}🧠 AI Explanation:${RESET}\n"
      echo "$EXPLANATION" | fold -s -w 65 | sed 's/^/  /'
      ;;

    # ── 22. AI SUGGEST BRANCH NAME ─────────────────────────────
    22)
      require_repo || continue
      git add .
      DIFF=$(git diff --cached | head -c 5000)
      [ -z "$DIFF" ] && DIFF=$(git diff | head -c 5000)
      if [ -z "$DIFF" ]; then
        echo -e "  ${YELLOW}⚠️  No changes detected to analyse.${RESET}"
      else
        echo -e "  ${DIM}🤖 Generating branch name from diff...${RESET}\n"
        BNAME=$(ai_query \
          "Suggest ONE git branch name for these changes. Use kebab-case. Format: type/short-description. Examples: feat/user-auth, fix/payment-crash, refactor/api-layer. Return ONLY the branch name — nothing else." \
          "${DIFF}" \
          30)
        # Strip quotes if AI wraps in them
        BNAME=$(echo "$BNAME" | tr -d '"' | tr -d "'" | xargs)
        echo -e "  ${BOLD}${CYAN}💡 Suggested branch:${RESET}  ${YELLOW}${BNAME}${RESET}"
        echo -ne "\n  Create and switch to this branch? (y/n): "
        read -r create
        if [ "$create" = "y" ]; then
          git checkout -b "$BNAME" \
            && echo -e "  ${GREEN}✅ Created and switched to ${YELLOW}${BNAME}${RESET}"
        fi
      fi
      ;;

    # ── 23. AI PR DESCRIPTION ──────────────────────────────────
    23)
      require_repo || continue
      echo -e "  ${DIM}🤖 Generating PR description from recent commits...${RESET}\n"
      RECENT=$(git log --oneline -15 2>/dev/null)
      CHANGED=$(git diff --stat HEAD~5 HEAD 2>/dev/null | tail -1)
      PR_DESC=$(ai_query \
        "You are a senior engineer. Write a concise GitHub Pull Request description. Include these exact sections: ## Summary, ## Changes, ## Testing. Be technical and clear. No fluff." \
        "Recent commits:\n${RECENT}\n\nStats: ${CHANGED}")
      echo -e "  ${BOLD}${CYAN}📝 PR Description:${RESET}\n"
      echo "$PR_DESC" | fold -s -w 65 | sed 's/^/  /'
      ;;

    # ── 24. AI SECURITY SCAN ───────────────────────────────────
    24)
      require_repo || continue
      git add .
      DIFF=$(git diff --cached | head -c 12000)
      [ -z "$DIFF" ] && DIFF=$(git diff HEAD | head -c 12000)
      if [ -z "$DIFF" ]; then
        echo -e "  ${YELLOW}⚠️  No diff to scan.${RESET}"
      else
        echo -e "  ${DIM}🤖 Scanning diff for security issues...${RESET}\n"
        SCAN=$(ai_query \
          "You are a security engineer. Scan this git diff for: hardcoded secrets, API keys, passwords, tokens, SQL injection risks, exposed .env values, insecure dependencies, or other vulnerabilities. List each issue with file and line context if visible. If nothing is found, say 'No issues detected'." \
          "${DIFF}")
        echo -e "  ${BOLD}${RED}🔐 Security Report:${RESET}\n"
        echo "$SCAN" | fold -s -w 65 | sed 's/^/  /'
      fi
      ;;

    # ── 25. SHOW GIT CONFIG ────────────────────────────────────
    25)
      echo -e "  ${BOLD}Global Git Config:${RESET}"
      echo -e "  Name :  ${CYAN}$(git config --global user.name  2>/dev/null || echo 'not set')${RESET}"
      echo -e "  Email:  ${CYAN}$(git config --global user.email 2>/dev/null || echo 'not set')${RESET}"
      EDITOR=$(git config --global core.editor 2>/dev/null || echo 'default')
      echo -e "  Editor: ${CYAN}${EDITOR}${RESET}"
      if [ "$IS_REPO" = true ]; then
        echo -e "\n  ${BOLD}Remotes:${RESET}"
        git remote -v 2>/dev/null || echo -e "  ${DIM}No remotes.${RESET}"
      fi
      ;;

    # ── 26. LIST REMOTES ───────────────────────────────────────
    26)
      require_repo || continue
      REMOTES=$(git remote -v 2>/dev/null)
      if [ -z "$REMOTES" ]; then
        echo -e "  ${DIM}No remotes configured.${RESET}"
      else
        echo -e "  ${BOLD}Remotes:${RESET}\n"
        echo "$REMOTES" | sed 's/^/  /'
      fi
      ;;

    # ── 27. ADD REMOTE ─────────────────────────────────────────
    27)
      require_repo || continue
      echo -ne "  ${BOLD}Remote name (e.g. origin): ${RESET}"
      read -r rname
      echo -ne "  ${BOLD}Remote URL: ${RESET}"
      read -r rurl
      if [ -z "$rname" ] || [ -z "$rurl" ]; then
        echo -e "  ${RED}Aborted — name and URL required.${RESET}"
      else
        git remote add "$rname" "$rurl" \
          && echo -e "  ${GREEN}✅ Added remote ${BOLD}${rname}${RESET}${GREEN} → ${rurl}${RESET}" \
          || echo -e "  ${RED}❌ Failed. Remote '${rname}' may already exist.${RESET}"
      fi
      ;;

    # ── 28. REFRESH ────────────────────────────────────────────
    28)
      echo -e "  ${DIM}Fetching latest from remote...${RESET}"
      git fetch --all --prune 2>/dev/null && echo -e "  ${GREEN}✅ Fetched.${RESET}"
      refresh_repo_state
      draw_header
      continue
      ;;

    # ── 29. GIT DOCS ───────────────────────────────────────────
    29)
      show_git_docs
      ;;

    # ── 0. EXIT ────────────────────────────────────────────────
    0)
      echo -e "  ${DIM}Bye, ${GIT_USER_NAME}! 👋${RESET}\n"
      exit 0
      ;;

    *)
      echo -e "  ${RED}Invalid option. Enter a number between 0 and 29.${RESET}"
      ;;

  esac

  echo ""
  echo -ne "  ${DIM}Press Enter to return to menu...${RESET}"
  read -r
  refresh_repo_state
  draw_header

done